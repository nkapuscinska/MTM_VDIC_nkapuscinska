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
class result_transaction extends uvm_transaction;

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    uart_packet_t packet;
    operation_t op;
    bit port;
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// transaction methods - do_copy, convert2string, do_compare
//------------------------------------------------------------------------------

function void do_copy(uvm_object rhs);
    result_transaction copied_transaction_h;
    assert(rhs != null) else
        `uvm_fatal("RESULT_TRANSACTION","Tried to copy null transaction");
    
    super.do_copy(rhs);
    assert($cast(copied_transaction_h, rhs)) else
        `uvm_fatal("RESULT_TRANSACTION","Failed cast in do_copy");
    
    // kopiowanie wszystkich pól
    packet   = copied_transaction_h.packet;
    op    = copied_transaction_h.op;
    port   = copied_transaction_h.port;
endfunction


function string convert2string();
    string s;
    s = $sformatf(
        "op=%0s, addr=0x%0h, data=0x%0h, port=0x%0h -- packet{adres_frame.start_bit=0x%h, adres_frame.data_bits=0x%h, adres_frame.parity_bit=0x%h, adres_frame.stop_bit=0x%h, data_frame.start_bit=0x%h, data_frame.data_bits=0x%h, data_frame.parity_bit=0x%h, data_frame.stop_bit=0x%h, port=0x%h}",
        op.name(), packet.adres_frame.data_bits, packet.data_frame.data_bits, port, packet.adres_frame.start_bit, packet.adres_frame.data_bits, packet.adres_frame.parity_bit, packet.adres_frame.stop_bit, packet.data_frame.start_bit, packet.data_frame.data_bits, packet.data_frame.parity_bit, packet.data_frame.stop_bit, packet.port
    );
    return s;
endfunction

function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    result_transaction RHS;
    bit same;
    assert(rhs != null) else
        `uvm_fatal("RESULT_TRANSACTION","Tried to compare null transaction");

    same = super.do_compare(rhs, comparer);
    $cast(RHS, rhs);

    same = (packet == RHS.packet) &&
            (port == RHS.port) &&
           same;

    return same;
endfunction



endclass : result_transaction
