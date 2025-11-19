
class bad_parity_tpgen extends funct_tpgen;
    `uvm_component_utils(bad_parity_tpgen)
    


//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new



    protected function uart_packet_t get_packet();
        uart_packet_t packet;
        bit [7:0] random_parity_addr;
        random_parity_addr = $urandom_range(0, 255);
        packet = create_programing_packet(random_parity_addr);
        -> bfm.ev_bad_parity_test_start;
        return packet;
    endfunction : get_packet

endclass : bad_parity_tpgen
