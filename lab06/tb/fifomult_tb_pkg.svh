
`timescale 1ns/1ps

package fifomult_tb_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

localparam int unsigned CLKS_PER_BIT = 16;

typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef struct packed {
    bit        start_bit;
    bit        [7:0]  data_bits;
    bit        parity_bit;
    bit        stop_bit;

} uart_frame_t;


typedef struct {
    uart_frame_t    adres_frame;
    uart_frame_t    data_frame;
    bit             port;
} uart_packet_t;

typedef enum {
    config_op,
    rst_op,
    func_op,
    bparity_op
} operation_t;

typedef struct {
    uart_packet_t packet;
    operation_t op;
} command_s;


bit [7:0] addr;
bit [7:0] data;
bit [7:0] port;
bit [7:0] addr_cov;
bit [7:0] data_cov;
bit [7:0] port_cov;
bit [7:0] rst_n_cov;
bit [7:0] op_address_sent;  
bit       op_port_sent;  


typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,                   
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;


typedef bit [7:0] addr_t;
typedef bit [7:0] port_t;

port_t temp;
addr_t key;

port_t address_map [bit [7:0]];


//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------


test_result_t        test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------

function void set_print_color (print_color_t c);
    string ctl;
    case (c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033[1;30m\033[102m";
        COLOR_BOLD_BLACK_ON_RED   : ctl  = "\033[1;30m\033[101m";
        COLOR_BOLD_BLACK_ON_YELLOW: ctl  = "\033[1;30m\033[103m";
        COLOR_DEFAULT             : ctl  = "\033[0m";
        default: ctl = "";
    endcase
    $write(ctl);
endfunction




`include "tb_classes/coverage.svh"



`include "tb_classes/base_tpgen.svh"


//------------------------------------------------------------------------------
// test classes
//------------------------------------------------------------------------------



`include "tb_classes/funct_tpgen.svh"
`include "tb_classes/random_tpgen.svh"


`include "tb_classes/scoreboard.svh"
`include "tb_classes/driver.svh"
`include "tb_classes/result_monitor.svh" 
`include "tb_classes/command_monitor.svh" 
`include "tb_classes/env.svh"

`include "tb_classes/funct_test.svh"
`include "tb_classes/random_test.svh"
endpackage : fifomult_tb_pkg