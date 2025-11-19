class funct_tpgen extends base_tpgen;

    `uvm_component_utils(funct_tpgen)


    //protected virtual switch_bfm bfm;


    function automatic uart_packet_t send_functional_packets();
        static byte unsigned i = 0;
        uart_packet_t packet;
        uart_observed_t exp;
        
        packet = create_functional_packet(i);
        //send_uart_packet(packet, bfm.sin);
        
        exp.address = i;
        exp.data    = packet.data_frame;
        exp.port    = address_map[i];
        bfm.expected_data_q.push_back(exp);
        $display("Sent packet: addr=%0d data=0x%0h",
        packet.adres_frame, packet.data_frame);
        i = (i == 255) ? 0 : i + 1;

        return packet;
    endfunction

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new


    protected function uart_packet_t get_packet();
        uart_packet_t packet;
        packet = send_functional_packets();
        return packet;
    endfunction : get_packet

endclass