class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual switch_bfm bfm;

//------------------------------------------------------------------------------


    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new





    function void set_print_color (print_color_t c);
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
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase


//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
     task run_phase(uvm_phase phase);

        fork
            main_scoreboard();
            reset_scoreboard();
            bad_parity_monitor();
        join_none
        
    endtask : run_phase

    task main_scoreboard();
        automatic int errors = 0;
        uart_observed_t exp, obs;

        $display("Scoreboard running... waiting for packets.");

        forever begin
            wait (bfm.expected_data_q.size() > 0 && bfm.observed_q.size() > 0);
            exp = bfm.expected_data_q.pop_front();
            obs = bfm.observed_q.pop_front();

            if (obs.address === exp.address &&
                obs.data    === exp.data &&
                obs.port    === exp.port) begin
                set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
                $display("[%0t] PASS addr=%0d port=%0d data=0x%0h",
                         $time, exp.address, exp.port, exp.data);
            end else begin
                set_print_color(COLOR_BOLD_BLACK_ON_RED);
                $display("[%0t] FAIL addr=%0d exp_port=%0d obs_port=%0d exp_data=0x%0h obs_data=0x%0h",
                         $time, exp.address, exp.port, obs.port, exp.data, obs.data);
                errors++;
            end
            set_print_color(COLOR_DEFAULT);
        end
    endtask

    task reset_scoreboard();
        forever begin
            @ (bfm.ev_reset_test_start);
            $display("=== Starting RESET test ===");
            repeat (3) @(posedge bfm.clk);
            if (bfm.sout0 !== 1'b1 || bfm.sout1 !== 1'b1) begin
                set_print_color(COLOR_BOLD_BLACK_ON_RED);
                $display("RESET TEST → FAIL (sout0=%b, sout1=%b)", bfm.sout0, bfm.sout1);
                set_print_color(COLOR_DEFAULT);
            end else begin
                set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
                $display("RESET TEST → PASS (sout0=%b, sout1=%b)", bfm.sout0, bfm.sout1);
                set_print_color(COLOR_DEFAULT);
            end
            set_print_color(COLOR_DEFAULT);
        end
    endtask

    task bad_parity_monitor();
        int obs_before;
        forever begin
            @ (bfm.ev_bad_parity_test_start);
            obs_before = bfm.observed_q.size();

            $display("=== Starting BAD PARITY test ===");

            # (CLKS_PER_BIT * 20); //waiting for dut 
            if (bfm.observed_q.size() > obs_before) begin
                set_print_color(COLOR_BOLD_BLACK_ON_RED);
                $display("FAIL: DUT forwarded bad parity frame");
                set_print_color(COLOR_DEFAULT);
            end else begin
                set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
                $display("PASS: DUT ignored bad parity frame");
                set_print_color(COLOR_DEFAULT);
            end
            set_print_color(COLOR_DEFAULT);
        end
    endtask

    function void end_of_test();
        if (test_result == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $display("TEST RESULT: PASS");
            set_print_color(COLOR_DEFAULT);
        end else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $display("TEST RESULT: FAIL");
            set_print_color(COLOR_DEFAULT);
        end
    endfunction : end_of_test

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        end_of_test();
    endfunction : report_phase


endclass : scoreboard
