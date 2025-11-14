class testbench;

    virtual switch_bfm bfm;

    tp_gen tp_gen_h;
    coverage coverage_h;
    scoreboard scoreboard_h;
    monitor monitor_h;

    function new (virtual switch_bfm b);
        bfm          = b;
        tp_gen_h      = new(bfm);
        coverage_h   = new(bfm);
        scoreboard_h = new(bfm);
        monitor_h = new(bfm);

    endfunction : new

    task execute();
        fork
            coverage_h.execute();
            scoreboard_h.execute();
            tp_gen_h.execute();
            monitor_h.execute();
        join_none
    endtask : execute

endclass : testbench


