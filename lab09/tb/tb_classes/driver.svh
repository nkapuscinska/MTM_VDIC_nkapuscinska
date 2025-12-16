class driver extends uvm_component;
    `uvm_component_utils(driver)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual switch_bfm bfm;
    uvm_get_port #(command_transaction) command_port;
    
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
      switch_agent_config switch_agent_config_h;
      if(!uvm_config_db #(switch_agent_config)::get(this, "","config", switch_agent_config_h))
        `uvm_fatal("DRIVER", "Failed to get config");
      bfm = switch_agent_config_h.bfm;
      command_port = new("command_port",this);
   endfunction : build_phase

    
    function void send_uart_packet(input uart_packet_t packet);
    // wysterowuje bfma
        addr_cov = packet.adres_frame.data_bits;
        data_cov = packet.data_frame.data_bits;
        port_cov = packet.data_frame.data_bits;
        //command_monitor_h.write_to_monitor(command);
        // $display("Sending UART packet: addr=%0h data=0x%0h",
        //     packet.adres_frame.data_bits,
        //     packet.data_frame.data_bits);

    endfunction

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        command_transaction command;
        uart_packet_t packet;
        
        forever begin : command_loop
            command_port.get(command);
            packet.data_frame = command.data_frame;
            packet.adres_frame = command.adres_frame;
            
            case(command.op)
                rst_op: begin
                    $display("Starting reset...");
                    bfm.prog = 0;
                    bfm.reset();
                end

                func_op: begin
                    bfm.prog = 0;
                    bfm.send_uart_frame(packet, func_op);
                    send_uart_packet(packet);
                end

                bparity_op: begin
                    bfm.prog = 0;
                    //$display("Sending UART frame with bad parity...");
                    bfm.send_uart_frame(packet, func_op, 1);
                    send_uart_packet(packet);
                end

                config_op: begin 
                    bfm.prog = 1;
                    bfm.send_uart_frame(packet, config_op);
                    bfm.prog = 0;
                end
            endcase
        end : command_loop
    endtask : run_phase
    

endclass : driver
