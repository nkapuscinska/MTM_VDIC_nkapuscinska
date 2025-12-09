class command_transaction extends uvm_transaction;

    `uvm_object_utils(command_transaction)


    //----------------------------------------------------------------------//
    // Pola transakcji
    //----------------------------------------------------------------------//
    operation_t op;
    rand uart_frame_t  adres_frame;
    rand uart_frame_t  data_frame;
    bit           port;

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint data {
        adres_frame.data_bits dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
        data_frame.data_bits dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
        adres_frame.start_bit dist {1'b0:=1, 1'b1:=0};
        adres_frame.stop_bit  dist {1'b1:=1, 1'b0:=0};
        data_frame.start_bit  dist {1'b0:=1, 1'b1:=0};
        data_frame.stop_bit   dist {1'b1:=1, 1'b0:=0};
        adres_frame.parity_bit dist {^adres_frame.data_bits:=1, ~^adres_frame.data_bits:=0};
        data_frame.parity_bit  dist {^data_frame.data_bits:=1, ~^data_frame.data_bits:=0};
    }


    //----------------------------------------------------------------------//
    // Konstruktor
    //----------------------------------------------------------------------//
    function new(string name="");
        super.new(name);
    endfunction

    //----------------------------------------------------------------------//
    // Kopiowanie transakcji
    //----------------------------------------------------------------------//
    function void do_copy(uvm_object rhs);
        command_transaction rhs_tx;
        assert(rhs != null) else
            `uvm_fatal("CMD_TX","Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(rhs_tx, rhs)) else
            `uvm_fatal("CMD_TX","Failed cast in do_copy");

        op          = rhs_tx.op;
        adres_frame = rhs_tx.adres_frame;
        data_frame  = rhs_tx.data_frame;
        port        = rhs_tx.port;
    endfunction

    //----------------------------------------------------------------------//
    // Porównywanie transakcji
    //----------------------------------------------------------------------//
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        command_transaction rhs_tx;
        bit same;
        assert(rhs != null) else
            `uvm_fatal("CMD_TX","Tried to compare null transaction");

        same = super.do_compare(rhs, comparer);
        $cast(rhs_tx, rhs);

        same = (op          == rhs_tx.op) &&
               (adres_frame == rhs_tx.adres_frame) &&
               (data_frame  == rhs_tx.data_frame) &&
               (port        == rhs_tx.port) &&
               same;

        return same;
    endfunction

    //----------------------------------------------------------------------//
    // Konwersja do string
    //----------------------------------------------------------------------//
    function string convert2string();
        string s;
        s = $sformatf("op=%0s, port=%0d, adres_frame={start=%b,data=0x%0h,parity=%b,stop=%b}, data_frame={start=%b,data=0x%0h,parity=%b,stop=%b}",
                       op.name(), port,
                       adres_frame.start_bit, adres_frame.data_bits, adres_frame.parity_bit, adres_frame.stop_bit,
                       data_frame.start_bit, data_frame.data_bits, data_frame.parity_bit, data_frame.stop_bit);
        return s;
    endfunction

endclass : command_transaction
