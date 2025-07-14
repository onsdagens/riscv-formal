// src/regfile_test.veryl

`ifdef __veryl_test_hippomenes_veryl_regfile_instance__
    `ifdef __veryl_wavedump_hippomenes_veryl_regfile_instance__
        module __veryl_wavedump;
            initial begin
                $dumpfile("regfile_instance.vcd");
                $dumpvars();
            end
        endmodule
    `endif
`ifndef SYNTHESIS
    import veryl_stacked_regfile_RegFilePkg::*;
    module test ;

        logic i_clk;
        logic i_reset;
        
        //Command i_command;
        logic [1:0] i_command;
        logic [31:0] i_push_data [32];
        logic [31:0] i_pop_data [32];
        
        logic [31:0] o_data [32];
        
        veryl_stacked_regfile_RegFileInstance regfile_instance(
            i_clk,
            i_reset,
            i_command,
            i_push_data,
            i_pop_data, 
            o_data
        );

        initial begin
            i_clk = 0; 
            i_reset = 1; 
            i_command = Command_push;
            i_push_data[0] = 1; // push
            i_push_data[1] = 2; // push
            i_pop_data[0] = 3;  // pop
            i_pop_data[1] = 4;  // pop
            
            // hold reset
            #10; i_clk=1; #10; i_clk=0;
            assert (o_data[0] == 0) else $error("0 -- reset");
            assert (o_data[1] == 0) else $error("0 -- reset");
            
            // release reset
            i_reset = 0;
            #10; i_clk=1; #10; i_clk=0;
            assert (o_data[0] == 1) else $error("1 -- push");
            assert (o_data[1] == 2) else $error("2 -- push");
            
            i_command = Command_pop;
            #10; i_clk=1; #10; i_clk=0; 
            assert (o_data[0] == 3) else $error("3 -- pop");
            assert (o_data[1] == 4) else $error("4 -- pop"); 

            i_command = Command_none; // nop
            i_push_data[0] = 42; // push
            i_push_data[1] = 43; // push
            i_pop_data[0] = 44;  // pop
            i_pop_data[1] = 45;  // pop

            #10; i_clk=1; #10; i_clk=0; 
            assert (o_data[0] == 3) else $error("3 -- retained");
            assert (o_data[1] == 4) else $error("4 -- retained"); 
              
            // reset 
            i_reset = 1;
            #10; i_clk=1; #10; i_clk=0;
            assert (o_data[0] == 0) else $error("0 -- re-reset");
            assert (o_data[1] == 0) else $error("0 -- re-reset");
        
            i_reset = 0;
            #10; i_clk=1; #10; i_clk=0;
            assert (o_data[0] == 0) else $error("0 -- re-reset");
            assert (o_data[1] == 0) else $error("0 -- re-reset");

            $finish;
         end
   endmodule
`endif
`endif
//# sourceMappingURL=regfile_instance_test.sv.map
