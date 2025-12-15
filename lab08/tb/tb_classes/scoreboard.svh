class scoreboard extends uvm_subscriber #(result_transaction);
    `uvm_component_utils(scoreboard)

    uvm_tlm_analysis_fifo #(command_transaction) cmd_f;

    typedef enum bit { TEST_PASSED, TEST_FAILED } test_result_t;
    local test_result_t tr = TEST_PASSED;

    //----------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void set_print_color(print_color_t c);
        string ctl;
        case (c)
            COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033[1;30m\033[102m";
            COLOR_BOLD_BLACK_ON_RED   : ctl  = "\033[1;30m\033[101m";
            COLOR_BOLD_BLACK_ON_YELLOW: ctl  = "\033[1;30m\033[103m";
            COLOR_DEFAULT             : ctl  = "\033[0m";
            default: ctl = "";
        endcase
        $write(ctl);
    endfunction

    //------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    local function void print_test_result (test_result_t r);
        if(tr == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write ("-----------------------------------\n");
            $write ("----------- Test PASSED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write ("-----------------------------------\n");
            $write ("----------- Test FAILED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
    endfunction

    //----------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        cmd_f = new("cmd_f", this);
    endfunction : build_phase

    //----------------------------------------------------------------------
    local function result_transaction predict_result(command_transaction cmd);
        result_transaction predicted;
        predicted = new("predicted");

        predicted.packet.adres_frame = cmd.adres_frame;
        predicted.packet.data_frame  = cmd.data_frame;
        predicted.packet.port  = cmd.port;
        predicted.op = cmd.op;
        predicted.port = cmd.port;

        return predicted;
    endfunction

    //----------------------------------------------------------------------
    function void write(result_transaction t);
        string data_str;
        command_transaction cmd;
        result_transaction predicted;

        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");

        while ((cmd.op == config_op)||(cmd.op == rst_op));

        predicted = predict_result(cmd);

        // if(predicted.do_compare(t)) begin
        //     set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
        //     $display("[%0t] PASS: %s", $time, t.convert2string());
        // end else begin
        //     set_print_color(COLOR_BOLD_BLACK_ON_RED);
        //     $display("[%0t] FAIL: %s / Expected: %s", 
        //              $time, t.convert2string(), predicted.convert2string());
        //     tr = TEST_FAILED;
        // end
        // set_print_color(COLOR_DEFAULT);

        data_str  = {"\n", cmd.convert2string(),
            "\n ==>  Actual    " , t.convert2string(),
            "\n ==>  Predicted ",predicted.convert2string(), "\n"};

        if (!predicted.compare(t)) begin
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
            tr = TEST_FAILED;
        end
        else
            `uvm_info("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
    endfunction

    //----------------------------------------------------------------------
    function void end_of_test();
        if(tr == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $display("TEST RESULT: PASS");
        end else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $display("TEST RESULT: FAIL");
        end
        set_print_color(COLOR_DEFAULT);
    endfunction

    //----------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SELF CHECKTER", "Reporting test result below", UVM_NONE)
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard
