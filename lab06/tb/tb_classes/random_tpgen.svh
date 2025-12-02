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
class random_tpgen extends funct_tpgen;
    `uvm_component_utils (random_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    // function void build_phase(uvm_phase phase);
    //     if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
    //         $fatal(1,"Failed to get BFM");
    // endfunction : build_phase

//------------------------------------------------------------------------------
// functions and tasks
//------------------------------------------------------------------------------
   

    function uart_packet_t create_random_functional_packet();
        uart_packet_t funct_packet;
        bit [7:0] data;
        bit [7:0] address;

        data = $urandom_range(0, 255);
        address = $urandom_range(0, 255);
        

        funct_packet.adres_frame = create_uart_frame(address);
        funct_packet.data_frame  = create_uart_frame(data);

        return funct_packet;

    endfunction

    protected function uart_packet_t get_packet();
        uart_packet_t packet;
        packet = create_random_functional_packet();
        return packet;
    endfunction : get_packet

endclass : random_tpgen






