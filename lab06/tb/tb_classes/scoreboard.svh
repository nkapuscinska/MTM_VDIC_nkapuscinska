class scoreboard extends uvm_subscriber #(uart_packet_t);
    `uvm_component_utils(scoreboard)


     uvm_tlm_analysis_fifo #(command_s) cmd_f; 


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
        cmd_f = new("cmd_f", this);
    endfunction : build_phase


//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------




    // task reset_scoreboard();
    //     forever begin
    //         @ (bfm.ev_reset_test_start);
    //         $display("=== Starting RESET test ===");
    //         repeat (3) @(posedge bfm.clk);
    //         if (bfm.sout0 !== 1'b1 || bfm.sout1 !== 1'b1) begin
    //             set_print_color(COLOR_BOLD_BLACK_ON_RED);
    //             $display("RESET TEST → FAIL (sout0=%b, sout1=%b)", bfm.sout0, bfm.sout1);
    //             set_print_color(COLOR_DEFAULT);
    //         end else begin
    //             set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
    //             $display("RESET TEST → PASS (sout0=%b, sout1=%b)", bfm.sout0, bfm.sout1);
    //             set_print_color(COLOR_DEFAULT);
    //         end
    //         set_print_color(COLOR_DEFAULT);
    //     end
    // endtask

    // task bad_parity_monitor();
    //     int obs_before;
    //     forever begin
    //         @ (bfm.ev_bad_parity_test_start);
    //         obs_before = bfm.observed_q.size();

    //         $display("=== Starting BAD PARITY test ===");

    //         # (CLKS_PER_BIT * 20); //waiting for dut 
    //         if (bfm.observed_q.size() > obs_before) begin
    //             set_print_color(COLOR_BOLD_BLACK_ON_RED);
    //             $display("FAIL: DUT forwarded bad parity frame");
    //             set_print_color(COLOR_DEFAULT);
    //         end else begin
    //             set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
    //             $display("PASS: DUT ignored bad parity frame");
    //             set_print_color(COLOR_DEFAULT);
    //         end
    //         set_print_color(COLOR_DEFAULT);
    //     end
    // endtask

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
// subscriber write function
//------------------------------------------------------------------------------
    function void write(uart_packet_t t);
        shortint predicted_result;
        command_s cmd;
        
        uart_packet_t exp;
        uart_packet_t obs;
        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");

        while ((cmd.op == config_op)||(cmd.op == rst_op));
        exp = cmd.packet;
        obs = t;

        $display("Scoreboard running... waiting for packets.");

            if (t.data_frame.data_bits  ===  cmd.packet.data_frame.data_bits &&
                obs.port    === address_map[exp.adres_frame.data_bits]) begin
                set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
                $display("[%0t] PASS addr=%0d exp_port=%0d obs_port=%0d exp_data=0x%0h obs_data=0x%0h",
                         $time, obs.adres_frame.data_bits, address_map[exp.adres_frame.data_bits], obs.port, exp.data_frame.data_bits, obs.data_frame.data_bits);
            end else begin
                set_print_color(COLOR_BOLD_BLACK_ON_RED);
                $display("[%0t] FAIL addr=%0d exp_port=%0d obs_port=%0d exp_data=0x%0h obs_data=0x%0h",
                         $time, obs.adres_frame.data_bits, address_map[obs.adres_frame.data_bits], obs.port, exp.data_frame.data_bits, obs.data_frame.data_bits);
            end
            set_print_color(COLOR_DEFAULT);

    endfunction : write

//-------------------------------
//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        end_of_test();
    endfunction : report_phase


endclass : scoreboard
