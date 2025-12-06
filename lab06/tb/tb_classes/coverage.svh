class coverage extends uvm_subscriber #(command_s);
    `uvm_component_utils(coverage)


    operation_t op;
//------------------------------------------------------------------------------
// covergroups
//------------------------------------------------------------------------------

        covergroup op_adres;

        option.name = "cg_op_adres";

        coverpoint addr_cov {
            bins A1_all_addr[] = {[0:255]};
        }

        coverpoint port_cov {
            bins A2_all_ports[] = {[0:1]};
        }


    endgroup

    covergroup op_data;

        option.name = "cg_op_data";

        coverpoint data_cov {
            // #A1 test all adresses
            bins A1_all_data[]     = {[0:255]};

        }

    endgroup


//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
        op_adres = new();
        op_data = new();

    endfunction : new


//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(command_s t);
        
        op = t.op;
        op_adres.sample();
        op_data.sample();

    endfunction : write

endclass : coverage