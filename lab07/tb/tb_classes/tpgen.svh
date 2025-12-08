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
class tpgen extends uvm_component;
    `uvm_component_utils (tpgen)

// The macro is not there as we never instantiate/use the tpgen
//    `uvm_component_utils(tpgen)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
 
    uvm_put_port #(command_transaction) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
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
        command_s command;
        bit [7:0] data;

        data = byte'($urandom_range(0, 255)); 
        

        funct_packet.adres_frame = create_uart_frame(address);
        funct_packet.data_frame  = create_uart_frame(data);

        return funct_packet;
    endfunction
    


    function uart_packet_t create_programing_packet(bit [7:0] address);
        uart_packet_t prog_packet;
        bit [7:0] port;

        port = byte'($urandom_range(0, 1));

        prog_packet.adres_frame = create_uart_frame(address);
        prog_packet.data_frame  = create_uart_frame(port);

        return prog_packet;
    endfunction

    function automatic uart_packet_t generate_config_packets();
        uart_packet_t pkt;
        bit [7:0] port;
        static byte unsigned i = 0;
        

            // generowanie portu losowego
            port = byte'($urandom_range(0, 1));

            // tworzenie pakietu programowania
            pkt.adres_frame = create_uart_frame(i);
            pkt.data_frame  = create_uart_frame(port);

            // dodanie do kolejki i mapy adresów
            // bfm.packet_q.push_back(pkt);
            i = (i == 255) ? 0 : i + 1;

            return pkt;

    endfunction


//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        command_transaction command;
        
        uart_packet_t      packet;

        phase.raise_objection(this);

        command    = new("command");
        command.op = rst_op;
        
        command_port.put(command);

        #100;
        command    = command_transaction::type_id::create("command");

        repeat (256) begin
            command    = new("command");
            command.op = config_op;
            packet = generate_config_packets(); 
            command.adres_frame = packet.adres_frame;
            command.data_frame  = packet.data_frame;
            command_port.put(command);
            #10;
        end
        

        repeat (5000) begin : random_loop
            command    = new("command");
            command.op = func_op;
            assert(command.randomize());
            command_port.put(command);

        end : random_loop

        //-> bfm.ev_end_of_test;

      #5000;

        phase.drop_objection(this);

    endtask : run_phase


endclass : tpgen
