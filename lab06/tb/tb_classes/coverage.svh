class coverage extends uvm_subscriber #(command_s);
    `uvm_component_utils(coverage)


    operation_t op;
//------------------------------------------------------------------------------
// covergroups
//------------------------------------------------------------------------------
// Covergroup checking the adressing
    covergroup op_adres;

        option.name = "cg_op_adres";

        coverpoint addr_cov {
            bins A1_all_addr[] = {[0:255]} iff (op == config_op);
        }

        coverpoint port_cov {
            bins A2_all_ports[] = {[0:1]} iff (op == config_op);
        }


    endgroup

    covergroup op_data;

        option.name = "cg_op_data";

        coverpoint data_cov {
            // #A1 test all adresses
            bins A1_all_data[]     = {[0:255]} iff (op == func_op);

        }

    endgroup

    // Covergroup checking the adressing
    // covergroup op_options;

    //     option.name = "cg_op_options";

    //     coverpoint bfm.prog {
    //         // #A1 test if programing mode was tested
    //         bins A1_prog[]     = {[0:1]};
    //     }
    //     coverpoint bfm.rst_n {
    //         // #A2 test if rst_n was triggered
    //         bins A2_Reset_n[]      = {[0:1]};

    //     }

    // endgroup

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
        op_adres = new();
        op_data = new();
        //op_options = new();  

    endfunction : new


//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(command_s t);
        
        op = t.op;
        op_adres.sample();
        op_data.sample();
        //op_options.sample();  

    endfunction : write

endclass : coverage