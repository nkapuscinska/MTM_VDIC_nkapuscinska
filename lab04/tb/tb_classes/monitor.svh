class monitor  ;

    protected virtual switch_bfm bfm;

    function new (virtual switch_bfm b);
        bfm = b;
    endfunction : new

    task execute();

        uart_observed_t obs;
        static bit [7:0] shift_reg = 0;
        static bit [3:0] bit_index = 0;
        static bit frame_phase = 0; // 0 = address frame, 1 = data frame
        static bit [7:0] received_address;
        static bit current_port;
        static bit [7:0] received_data;
        static bit prev_sout0 = 1;
        static bit prev_sout1 = 1;

        forever begin
            @(posedge bfm.clk);

            if ((prev_sout0 == 1 && bfm.sout0 == 0) || (prev_sout1 == 1 && bfm.sout1 == 0)) begin
                current_port = (bfm.sout1 == 0);
                shift_reg = 0;

                for (bit_index = 0; bit_index < 8; bit_index++) begin
                    repeat (CLKS_PER_BIT) @(posedge bfm.clk);
                    shift_reg[bit_index] = (current_port == 1) ? bfm.sout1 : bfm.sout0;
                end

                repeat (CLKS_PER_BIT * 2) @(posedge bfm.clk);

                if (frame_phase == 0) begin
                    received_address = shift_reg;
                    frame_phase = 1;
                end else begin
                    received_data = shift_reg;
                    frame_phase = 0;

                    obs.address = received_address;
                    obs.data    = received_data;
                    obs.port    = current_port;
                    bfm.observed_q.push_back(obs);

                    $display("Received packet: addr=%0d data=0x%0h actual_port=%0d",
                             obs.address, obs.data, obs.port);
                end
            end

            prev_sout0 = bfm.sout0;
            prev_sout1 = bfm.sout1;
        end
    endtask : execute
endclass : monitor