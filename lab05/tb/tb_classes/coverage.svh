class coverage extends uvm_component;
    `uvm_component_utils(coverage)

    protected virtual switch_bfm bfm;


    
//------------------------------------------------------------------------------
// covergroups
//------------------------------------------------------------------------------
// Covergroup checking the adressing
    covergroup op_adres;

        option.name = "cg_op_adres";

        coverpoint addr_cov {
            bins A1_all_addr[] = {[0:255]} iff (bfm.prog == 1);
        }

        coverpoint port_cov {
            bins A2_all_ports[] = {[0:1]} iff (bfm.prog == 1);
        }


    endgroup

    covergroup op_data;

        option.name = "cg_op_data";

        coverpoint data_cov {
            // #A1 test all adresses
            bins A1_all_data[]     = {[0:255]} iff (bfm.prog == 0);

        }

    endgroup

    // Covergroup checking the adressing
    covergroup op_options;

        option.name = "cg_op_options";

        coverpoint bfm.prog {
            // #A1 test if programing mode was tested
            bins A1_prog[]     = {[0:1]};
        }
        coverpoint bfm.rst_n {
            // #A2 test if rst_n was triggered
            bins A2_Reset_n[]      = {[0:1]};

        }

    endgroup

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
        op_adres = new();
        op_data = new();
        op_options = new();  

    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual switch_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        forever begin : sampling_block
            @(negedge bfm.clk);

            op_adres.sample();
            op_data.sample();
            op_options.sample();  
        end : sampling_block
    endtask : run_phase



endclass : coverage