// src/regfile_stack.veryl


module veryl_stacked_regfile_RegFileStack
    import veryl_stacked_regfile_RegFilePkg::*;
#(
    parameter int unsigned          Depth = 4,
    parameter logic        [32-1:0] mask  = {
        1'b1, // x31 t6
        1'b1, // x30 t5
        1'b1, // x29 t4
        1'b1, // x28 t3

        1'b1, // x27 s11
        1'b1, // x26 s10
        1'b1, // x25 s9
        1'b1, // x24 s8
        1'b1, // x23 s7
        1'b1, // x22 s6
        1'b1, // x21 s5
        1'b1, // x20 s4
        1'b1, // x19 s3
        1'b1, // x18 s2

        1'b1, // x17 a7
        1'b1, // x16 a6
        1'b1, // x15 a5
        1'b1, // x14 a4
        1'b1, // x13 a3
        1'b1, // x12 a2
        1'b1, // x11 a1
        1'b1, // x10 a0

        1'b1, // x9  s1
        1'b1, // x8  s0

        1'b1, // x7  t2
        1'b1, // x6  t1
        1'b1, // x5  t0

        1'b0, // x4  tp
        1'b0, // x3  gp
        1'b1, // x2  sp
        1'b1, // x1  ra
        1'b0
    },
    parameter logic [32-1:0] stack_mask = {
        1'b1, // x31 t6
        1'b1, // x30 t5
        1'b1, // x29 t4
        1'b1, // x28 t3

        1'b0, // x27 s11
        1'b0, // x26 s10
        1'b0, // x25 s9
        1'b0, // x24 s8
        1'b0, // x23 s7
        1'b0, // x22 s6
        1'b0, // x21 s5
        1'b0, // x20 s4
        1'b0, // x19 s3
        1'b0, // x18 s2

        1'b1, // x17 a7
        1'b1, // x16 a6
        1'b1, // x15 a5
        1'b1, // x14 a4
        1'b1, // x13 a3
        1'b1, // x12 a2
        1'b1, // x11 a1
        1'b1, // x10 a0

        1'b0, // x9  s1
        1'b0, // x8  s0

        1'b1, // x7  t2
        1'b1, // x6  t1
        1'b1, // x5  t0

        1'b0, // x4  tp
        1'b0, // x3  gp
        1'b0, // x2  sp
        1'b0, // x1  ra
        1'b0
    }
) (
    input  var logic            i_clk    , // dedicated clock
    input  var logic            i_reset  , // dedicated reset
    input  var Command          i_command,
    input  var logic   [5-1:0]  i_a_addr ,
    input  var logic   [5-1:0]  i_b_addr ,
    input  var logic            i_w_ena  ,
    input  var logic   [5-1:0]  i_w_addr ,
    input  var logic   [32-1:0] i_w_data ,
    output var logic   [32-1:0] o_a_data ,
    output var logic   [32-1:0] o_b_data 
);
    logic [32-1:0] rf_stack [0:Depth + 1-1][0:32-1];

    for (genvar i = 0; i < Depth - 1; i++) begin :label
        veryl_stacked_regfile_RegFileInstance #(
            .mask (stack_mask)
        ) rf (
            .i_clk       (i_clk          ),
            .i_reset     (i_reset        ),
            .i_command   (i_command      ),
            .i_push_data (rf_stack[i]    ),
            .i_pop_data  (rf_stack[i + 2]),
            .o_data      (rf_stack[i + 1])
        );
    end

    logic [32-1:0] regs [0:32-1];
    always_ff @ (posedge i_clk) begin
        for (int unsigned i = 0; i < 32; i++) begin
            if (i_reset | ~mask[i]) begin
                regs[i] <= 0;
            end else begin
                case (i_command) inside
                    // pop
                    veryl_stacked_regfile_RegFilePkg::Command_pop: if (stack_mask[i]) begin
                        regs[i] <= rf_stack[1][i];
                    end
                    // none, push
                    default: if (i_w_ena && mask[i]) begin
                        regs[i_w_addr] <= i_w_data;
                    end
                endcase
            end
        end
    end

    always_comb begin
        // connect top level
        rf_stack[0] = regs; // skip register 0

        // connect outputs with write forwarding
        // this is a mistake i think.
        //o_a_data = if i_w_ena && (i_a_addr != 0) && (i_a_addr == i_w_addr) ? i_w_data : regs[i_a_addr];
        //o_b_data = if i_w_ena && (i_b_addr != 0) && (i_b_addr == i_w_addr) ? i_w_data : regs[i_b_addr];
        o_a_data = regs[i_a_addr];
        o_b_data = regs[i_b_addr];
    end

endmodule
//# sourceMappingURL=regfile_stack.sv.map
