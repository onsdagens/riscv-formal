// src/regfile_stack_test.veryl

`ifdef __veryl_test_hippomenes_veryl_regfile_stack__
    `ifdef __veryl_wavedump_hippomenes_veryl_regfile_stack__
        module __veryl_wavedump;
            initial begin
                $dumpfile("regfile_stack.vcd");
                $dumpvars();
            end
        endmodule
    `endif
`ifndef SYNTHESIS
    import veryl_stacked_regfile_RegFilePkg::*;
    module test;
        logic i_clk;
        logic i_reset;

        Command i_command;
        logic [4:0] i_a_addr;
        logic [4:0] i_b_addr;
        logic i_w_ena;
        logic [4:0] i_w_addr;
        logic [31:0] i_w_data;
        logic [31:0] o_a_data;
        logic [31:0] o_b_data;
        
        veryl_stacked_regfile_RegFileStack regfile(
            i_clk,
            i_reset, 
            i_command,
            i_a_addr,
            i_b_addr,
            i_w_ena,
            i_w_addr,
            i_w_data,
            o_a_data,
            o_b_data
        );

        initial begin
            i_clk = 0; 
            i_reset = 1; 
            i_a_addr = 0; 
            i_b_addr = 0; 
            i_w_ena = 0; 
            i_w_addr = 0; 
            i_w_data = 0; 
            i_command = Command_none;

            // hold reset
            #10; i_clk=1; #10; i_clk=0;
            assert (o_a_data == 0) else $error("0");
            assert (o_b_data == 0) else $error("0");

            // release reset
            i_reset = 0;
            #10; i_clk=1; #10; i_clk=0;
            
            // write to reg 0
            i_w_ena = 1;
            i_w_addr = 0; 
            i_w_data = 'h10;
            i_a_addr = 0;
            i_b_addr = 0;
            #10; i_clk=1; #10; i_clk=0;

            // read reg 0
            i_w_ena = 0;
            i_w_addr = 0; 
            i_w_data = 'h10;
            i_a_addr = 0;
            i_b_addr = 0;
            #10; i_clk=1; #10; i_clk=0;
              
            // write to reg 1
            i_w_ena = 1;
            i_w_addr = 1;
            i_w_data = 'h100;
            i_a_addr = 1;
            #10; i_clk=1; #10; i_clk=0;          

            // write to reg 2
            i_w_addr = 2;
            i_w_data = 'h1000;
            i_b_addr = 2;
            #10; i_clk=1; #10; i_clk=0;         

            // write to reg 2, with iw_ena false
            i_w_ena = 0;
            i_w_data = 'h2000;
            #10; i_clk=1; #10; i_clk=0;     

            #10; i_clk=1; #10; i_clk=0;    

            // reset 
            i_reset = 1;
            #10; i_clk=1; #10; i_clk=0;
            assert (o_a_data == 0) else $error("0");
            assert (o_b_data == 0) else $error("0");
        
            i_reset = 0;
            #10; i_clk=1; #10; i_clk=0;

            // test stacking
            // reg[1] <- 'h1000_0000;
            i_a_addr = 1; 
            i_b_addr = 31; 
            i_w_ena = 1; 
            i_w_addr = 1; 
            i_w_data = 'h1000_0000; 

            #10; i_clk=1; #10; i_clk=0;

            i_w_addr = 31;
            i_w_data = 'h2000_0000;
            // reg[31] <- 'h2000_0000; 

            #10; i_clk=1; #10; i_clk=0;

            // push
            i_command = Command_push;
            i_w_ena = 1;
            i_w_addr = 1; 
            i_w_data = 'h1000_1000; 
            // reg[1] <- 'h1000_1000;

            #10; i_clk=1; #10; i_clk=0;
            assert (o_a_data == 'h1000_1000) else $error("write to new context");
            assert (o_b_data == 'h2000_0000) else $error("old context read");

            // nop
            i_command = Command_none; 
            i_w_addr = 31; 
            i_w_data = 'h2000_2000; 
            // reg[31] <- 'h2000_2000;
            #10; i_clk=1; #10; i_clk=0;
            assert (o_a_data == 'h1000_1000) else $error("new context, value stored");
            assert (o_b_data == 'h2000_2000) else $error("write to new context");

            // pop
            i_command = Command_pop; 
            i_w_ena = 1;
            i_w_addr = 10;
            i_w_data = 'h1010_1010; 
            // reg[10] <- 'h1010_1010;
            #10; i_clk=1; #10; i_clk=0;
            assert (o_a_data == 'h1000_0000) else $error("old context, value re-stored");
            assert (o_b_data == 'h2000_0000) else $error("old context, value re-stored");

            // nop
            i_command = Command_none;
            i_w_ena = 0;
            i_a_addr = 10;
            #10; i_clk=1; #10; i_clk=0;
            assert (o_a_data == 'h0000_0000) else $error("old context, new value ignored on pop");

            $finish;
         end
   endmodule
`endif
`endif
//# sourceMappingURL=regfile_stack_test.sv.map
