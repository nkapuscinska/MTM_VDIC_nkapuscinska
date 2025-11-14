
class coverage;

    protected virtual switch_bfm bfm;


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

    function new (virtual switch_bfm b);
        bfm = b;
        op_adres      = new();
        op_data      = new();
        op_options      = new();
    endfunction : new


    // op_adres      adrr_cov;
    // op_data         dat_cov;
    // op_options      op_cov;

    task execute();
    

    forever begin : sample_cov
        @(posedge bfm.clk);
        op_adres.sample();
        op_data.sample();
        op_options.sample();

    end
    endtask : execute

endclass : coverage