//------------------------------------------------------------------------------
// RESULT MONITOR - obserwacja wyjść DUT + reset
//------------------------------------------------------------------------------ 
class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

    protected virtual switch_bfm bfm;
    uvm_analysis_port #(uart_packet_t) ap; // teraz wysyłamy uart_packet_t

    function new(string name, uvm_component parent);
        super.new(name,parent);
        ap   = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
        bfm.result_monitor_h = this;
    endfunction

    task run_phase(uvm_phase phase);
        // usunąłem uart_observed_t obs; → nie chcemy tego typu
        command_s cmd;
        bit [7:0] shift_reg;
        bit [3:0] bit_index;
        bit frame_phase = 0;
        bit [7:0] received_address, received_data;
        bit current_port;
        bit prev_sout0 = 1, prev_sout1 = 1;

        // pkt, który złożymy i wyślemy do scoreboardu
        uart_packet_t pkt;

        @(posedge bfm.rst_n); // początek obserwacji po reset
        forever begin
            @(negedge bfm.sout0 or negedge bfm.sout1);

            // Odczyt bitów przychodzących
            current_port = (bfm.sout1 == 0);
            shift_reg = 0;
            repeat(CLKS_PER_BIT/2) @(posedge bfm.clk);
            for (bit_index = 0; bit_index < 10; bit_index++) begin
                if (bit_index != 0 && bit_index != 9)
                    shift_reg[bit_index-1] = (current_port == 1) ? bfm.sout1 : bfm.sout0;
                repeat(CLKS_PER_BIT) @(posedge bfm.clk);
            end

            if (frame_phase == 0) begin
                received_address = shift_reg;
                frame_phase = 1;
            end else begin
                received_data = shift_reg;
                frame_phase = 0;

                // Wypełnij pkt zgodnie z definicją uart_packet_t
                // Zakładam, że struktura ma pola adres_frame, data_frame i port
                // — jeśli nazwy/struktury są inne, dostosuj poniżej.
                pkt = '{default: '0}; // zainicjuj wszystkie pola (SystemVerilog aggregate literal)
                pkt.adres_frame.data_bits = received_address;
                pkt.adres_frame.start_bit  = 1'b0; // opcjonalne, ustaw jeśli masz takie pola
                pkt.adres_frame.parity_bit = 1'b0; // opcjonalne
                pkt.adres_frame.stop_bit   = 1'b1; // opcjonalne

                pkt.data_frame.data_bits   = received_data;
                pkt.data_frame.start_bit   = 1'b0; // opcjonalne
                pkt.data_frame.parity_bit  = 1'b0; // opcjonalne
                pkt.data_frame.stop_bit    = 1'b1; // opcjonalne

                pkt.port = current_port;

                // Wyślij pakiet do scoreboardu (ten typ scoreboard oczekuje)
                ap.write(pkt);
            end

            prev_sout0 = bfm.sout0;
            prev_sout1 = bfm.sout1;

            // // Obsługa resetu DUT (jeśli potrzebna)
            // if (!bfm.rst_n) begin
            //     cmd.op = rst_op;
            //     reset_ap.write(cmd);
            // end
        end
    endtask

endclass : result_monitor
