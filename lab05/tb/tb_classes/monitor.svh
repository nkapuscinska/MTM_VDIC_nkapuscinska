class monitor extends uvm_component;
    `uvm_component_utils(monitor)

    protected virtual switch_bfm bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

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

        uart_observed_t obs;
        static bit [7:0] shift_reg = 0;
        static bit [3:0] bit_index = 0;
        static bit frame_phase = 0; // 0 = address frame, 1 = data frame
        static bit [7:0] received_address;
        static bit current_port;
        static bit [7:0] received_data;
        static bit prev_sout0 = 1;
        static bit prev_sout1 = 1;

        $display("Monitor: Starting run phase...");
        @(posedge bfm.rst_n);
        forever begin

            @(negedge bfm.sout0 or negedge bfm.sout1);

                // $display("%t ,Monitor: Waiting for start bit... %0d, %0d",$time, bfm.sout0, bfm.sout1);

            if ((prev_sout0 == 1 && bfm.sout0 == 0) || (prev_sout1 == 1 && bfm.sout1 == 0)) begin
                current_port = (bfm.sout1 == 0);
                shift_reg = 0;
                repeat (CLKS_PER_BIT/2) @(posedge bfm.clk);
                for (bit_index = 0; bit_index < 10; bit_index++) begin
                    // $display("Monitor: Receiving bit %0d from port %0d: %0b",
                    //          bit_index, (current_port == 1) ? 1 : 0,
                    //          (current_port == 1) ? bfm.sout1 : bfm.sout0);
                    if (bit_index == 0) begin
                        // Start bit, just wait
                    end
                    else if (bit_index == 9) begin
                        // Parity Bit
                    end
                    else begin
                    shift_reg[bit_index-1] = (current_port == 1) ? bfm.sout1 : bfm.sout0;
                    end
                    repeat (CLKS_PER_BIT) @(posedge bfm.clk);
                end

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
                    // $display("Monitor: Observed packet on port %0d: address = 0x%0h, data = 0x%0h",
                    //          (current_port == 1) ? 1 : 0,
                    //          obs.address,
                    //          obs.data);
                end
            end

            prev_sout0 = bfm.sout0;
            prev_sout1 = bfm.sout1;
        

        end
    endtask : run_phase
endclass : monitor