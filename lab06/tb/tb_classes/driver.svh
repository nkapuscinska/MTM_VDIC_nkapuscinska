class driver extends uvm_component;
    `uvm_component_utils(driver)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual switch_bfm bfm;
    uvm_get_port #(command_s) command_port;
    
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
        if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
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
        command_s command;
        
        forever begin : command_loop
            command_port.get(command);
            case(command.op)
                rst_op: begin
                    $display("Starting reset...");
                    bfm.prog = 0;
                    bfm.reset();
                end

                func_op: begin
                    bfm.prog = 0;
                    bfm.send_uart_frame(command.packet, func_op);
                    send_uart_packet(command.packet);
                end

                bparity_op: begin
                    bfm.prog = 0;
                    $display("Sending UART frame with bad parity...");
                    bfm.send_uart_frame(command.packet, func_op, 1);
                    send_uart_packet(command.packet);
                end

                config_op: begin 
                    bfm.prog = 1;
                    bfm.send_uart_frame(command.packet, config_op);
                    bfm.prog = 0;
                end
            endcase
        end : command_loop
    endtask : run_phase
    

endclass : driver
