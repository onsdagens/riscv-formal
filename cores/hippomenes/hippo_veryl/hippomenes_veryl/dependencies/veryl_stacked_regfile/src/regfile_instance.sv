// src/regfile_instance.veryl


module veryl_stacked_regfile_RegFileInstance
    import veryl_stacked_regfile_RegFilePkg::*;
#(
    parameter logic [32-1:0] mask = 32'hffff_ffff
) (
    input var logic i_clk  , // dedicated clock
    input var logic i_reset, // dedicated reset

    input  var Command          i_command           ,
    input  var logic   [32-1:0] i_push_data [0:32-1],
    input  var logic   [32-1:0] i_pop_data  [0:32-1],
    output var logic   [32-1:0] o_data      [0:32-1]
);
    logic [32-1:0] regs [0:32-1];
    always_ff @ (posedge i_clk) begin
        for (int unsigned i = 0; i < 32; i++) begin
            if (i_reset | ~mask[i]) begin
                regs[i] <= 0;
            end else begin
                case (i_command) inside
                    veryl_stacked_regfile_RegFilePkg::Command_push: regs[i] <= i_push_data[i];
                    veryl_stacked_regfile_RegFilePkg::Command_pop : regs[i] <= i_pop_data[i];
                    default                                       : begin
                    end
                endcase
            end
        end
    end

    always_comb begin
        o_data = regs;
    end
endmodule
//# sourceMappingURL=regfile_instance.sv.map
