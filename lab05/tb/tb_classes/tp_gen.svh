class tp_gen;

    protected virtual switch_bfm bfm;

    function new (virtual switch_bfm b);
        bfm = b;
    endfunction : new


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

    task automatic send_uart_frame(
        input uart_frame_t frame, 
        ref bit input_sin,
        input bit force_parity_error = 0
    );
        bit parity_bit_to_send;

        input_sin = frame.start_bit;
        repeat (CLKS_PER_BIT) @(posedge bfm.clk);

        for (int i = 0; i < 8; i++) begin
            input_sin = frame.data_bits[i];
            repeat (CLKS_PER_BIT) @(posedge bfm.clk);
        end

        if (force_parity_error)
            parity_bit_to_send = ~frame.parity_bit;
        else
            parity_bit_to_send = frame.parity_bit;

        input_sin = parity_bit_to_send;
        repeat (CLKS_PER_BIT) @(posedge bfm.clk);

        input_sin = frame.stop_bit;
        repeat (CLKS_PER_BIT) @(posedge bfm.clk);
    endtask



    task automatic send_uart_packet(input uart_packet_t packet, ref bit input_sin);
        addr_cov = packet.adres_frame.data_bits;
        data_cov = packet.data_frame.data_bits;
        port_cov = packet.data_frame.data_bits;
        send_uart_frame(packet.adres_frame, input_sin);
        send_uart_frame(packet.data_frame, input_sin);
    endtask

    task automatic generate_config_packets();
        uart_packet_t pkt;
        bit [7:0] port;

        for (int i = 0; i < 256; i++) begin
            // generowanie portu losowego
            port = $urandom_range(0, 1);

            // tworzenie pakietu programowania
            pkt.adres_frame = create_uart_frame(i);
            pkt.data_frame  = create_uart_frame(port);

            // dodanie do kolejki i mapy adresów
            bfm.packet_q.push_back(pkt);
            address_map[i] = pkt.data_frame.data_bits;
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


    task automatic generate_functional_packets();
        uart_packet_t pkt;
        uart_observed_t exp;

        for (int i = 0; i < 256; i++) begin
            pkt = create_functional_packet(i);
            bfm.packet_q.push_back(pkt);

            exp.address = i;
            exp.data    = pkt.data_frame.data_bits;
            exp.port    = address_map[i];
            bfm.expected_data_q.push_back(exp);
            $display("Sent packet: addr=%0d data=0x%0h expected_port=%0d",
            exp.address, exp.data, exp.port);
        end
        
    endtask


    task automatic send_functional_packets();
        $display("Switched to functional mode. Sending functional packets...");

        generate_functional_packets();

        while (bfm.packet_q.size() > 0) begin
            uart_packet_t pkt;
            pkt = bfm.packet_q.pop_front();
            send_uart_packet(pkt, bfm.sin);
        end

        $display("Functional packets done.");

    endtask

    // task reset_scoreboard();
    //     $display("=== Starting RESET test ===");
    //     if (bfm.sout0 !== 1'b1 || bfm.sout1 !== 1'b1) begin
    //             set_print_color(COLOR_BOLD_BLACK_ON_RED);
    //             $display("RESET TEST → FAIL (sout0=%b, sout1=%b)", bfm.sout0, bfm.sout1);
    //             set_print_color(COLOR_DEFAULT);
    //             test_result = TEST_FAILED;
    //         end else begin
    //             set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
    //             $display("RESET TEST → PASS (sout0=%b, sout1=%b)", bfm.sout0, bfm.sout1);
    //             set_print_color(COLOR_DEFAULT);
    //         end
    // endtask

    task automatic test_bad_parity();
        uart_packet_t pkt;
        int obs_size_before;
        uart_observed_t obs;

        for (int i = 0; i < 5; i++) begin
            bit [7:0] random_parity_addr;
            random_parity_addr = $urandom_range(0, 255);
            pkt = create_programing_packet(random_parity_addr);
            obs_size_before = bfm.observed_q.size();

            send_uart_frame(pkt.adres_frame, bfm.sin, 1);
            send_uart_frame(pkt.adres_frame, bfm.sin, 1);

            -> bfm.ev_bad_parity_test_start;

        end
    endtask


    task execute();
        bfm.reset();
        bfm.prog = 1;
        send_config_packets();
        bfm.prog = 0;
        send_functional_packets();
        #(CLKS_PER_BIT*12*256);
        test_bad_parity();
        repeat (6*CLKS_PER_BIT) @(posedge bfm.clk);
        bfm.reset();
        #(CLKS_PER_BIT*10);
        -> bfm.ev_end_of_test;
        #(CLKS_PER_BIT*10);
        $finish;
    endtask
endclass : tp_gen