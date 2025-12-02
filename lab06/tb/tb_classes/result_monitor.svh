//------------------------------------------------------------------------------
// RESULT MONITOR - obserwacja wyjść DUT + reset
//------------------------------------------------------------------------------ 
class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

    protected virtual switch_bfm bfm;
    uvm_analysis_port #(uart_packet_t) ap; // teraz wysyłamy uart_packet_t

    function new(string name, uvm_component parent);
        super.new(name,parent);
        ap   = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
        bfm.result_monitor_h = this;
    endfunction

    function void write_to_monitor(uart_packet_t r);

        ap.write(r);
    endfunction : write_to_monitor

endclass : result_monitor
