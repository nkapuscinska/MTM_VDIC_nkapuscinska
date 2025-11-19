/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
virtual class base_tpgen extends uvm_component;

// The macro is not there as we never instantiate/use the base_tpgen
//    `uvm_component_utils(base_tpgen)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual switch_bfm bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    
    pure virtual protected function uart_packet_t get_packet();


//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase


//------------------------------------------------------------------------------
// functions
//------------------------------------------------------------------------------

    function uart_frame_t create_uart_frame(bit [7:0] data);
        uart_frame_t frame;

        frame.start_bit = 0;
        frame.data_bits = data;
        frame.parity_bit = ^data;
        frame.stop_bit = 1;

        return frame;

    endfunction

    function uart_packet_t create_functional_packet(bit [7:0] address);
        uart_packet_t funct_packet;
        bit [7:0] data;

        data = $urandom_range(0, 255);
        

        funct_packet.adres_frame = create_uart_frame(address);
        funct_packet.data_frame  = create_uart_frame(data);
        $display("created functional packet: addr=%0d data=0x%0h",
            address,
            data);

        return funct_packet;
    endfunction
    


    function uart_packet_t create_programing_packet(bit [7:0] address);
        uart_packet_t prog_packet;
        bit [7:0] port;

        port = $urandom_range(0, 1);

        prog_packet.adres_frame = create_uart_frame(address);
        prog_packet.data_frame  = create_uart_frame(port);

        return prog_packet;
    endfunction


    function void send_uart_packet(input uart_packet_t packet, ref bit input_sin);
        addr_cov = packet.adres_frame.data_bits;
        data_cov = packet.data_frame.data_bits;
        port_cov = packet.data_frame.data_bits;
        $display("Sending UART packet: addr=%0d data=0x%0h",
            packet.adres_frame.data_bits,
            packet.data_frame.data_bits);
        bfm.send_uart_frame(packet.adres_frame, input_sin);
        bfm.send_uart_frame(packet.data_frame, input_sin);

    endfunction

    task automatic generate_config_packets();
        uart_packet_t pkt;
        bit [7:0] port;

        for (int conf_addr = 0; conf_addr < 256; conf_addr++) begin
            // generowanie portu losowego
            port = $urandom_range(0, 1);

            // tworzenie pakietu programowania
            pkt.adres_frame = create_uart_frame(conf_addr);
            pkt.data_frame  = create_uart_frame(port);

            // dodanie do kolejki i mapy adresów
            bfm.packet_q.push_back(pkt);
            address_map[conf_addr] = pkt.data_frame.data_bits;
        end
    endtask



    task automatic send_config_packets();
        $display("Starting to send config packets...");

        generate_config_packets();

        while (bfm.packet_q.size() > 0) begin
            uart_packet_t pkt;
            pkt = bfm.packet_q.pop_front();
            send_uart_packet(pkt, bfm.sin);
        end

        $display("Config packets done.");
    endtask

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        uart_packet_t packet;
        shortint result;

        phase.raise_objection(this);

        bfm.reset();
        bfm.prog = 1;
        send_config_packets();
        bfm.prog = 0;

        repeat (8) begin : random_loop
            packet = get_packet();
            send_uart_packet(packet, bfm.sin);
        end : random_loop
        -> bfm.ev_end_of_test;

//      #500;

        phase.drop_objection(this);

    endtask : run_phase


endclass : base_tpgen
