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
class funct_transaction extends command_transaction;
    `uvm_object_utils(funct_transaction)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint funct_packet {
        adres_frame.data_bits inside {0, 255}; 
        data_frame.data_bits  inside {0, 255};

        adres_frame.start_bit == 1'b0;
        adres_frame.stop_bit  == 1'b1;
        data_frame.start_bit  == 1'b0;
        data_frame.stop_bit   == 1'b1;
        adres_frame.parity_bit == ^adres_frame.data_bits;
        data_frame.parity_bit  == ^data_frame.data_bits;
    }

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name="");
        super.new(name);
    endfunction
    
    
endclass : funct_transaction


