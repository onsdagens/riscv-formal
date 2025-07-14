// src/regfile.veryl

module veryl_stacked_regfile_RegFile (
    input  var logic          i_clk   , // dedicated clock
    input  var logic          i_reset , // dedicated reset
    input  var logic [5-1:0]  i_a_addr,
    input  var logic [5-1:0]  i_b_addr,
    input  var logic          i_w_ena ,
    input  var logic [5-1:0]  i_w_addr,
    input  var logic [32-1:0] i_w_data,
    output var logic [32-1:0] o_a_data,
    output var logic [32-1:0] o_b_data
);
    logic [32-1:0] regs [0:32-1];
    always_ff @ (posedge i_clk) begin
        if (i_reset) begin
            // regs = {{32'0} repeat 32};
            for (int unsigned i = 0; i < 32; i++) begin
                regs[i] <= 0;
            end
        end else begin
            if (i_w_ena) begin
                regs[i_w_addr] <= i_w_data;
            end
        end
    end

    always_comb begin
        o_a_data = ((i_a_addr == 0) ? ( 0 ) : ( regs[i_a_addr] ));
        o_b_data = ((i_b_addr == 0) ? ( 0 ) : ( regs[i_b_addr] ));
    end
endmodule
//# sourceMappingURL=regfile.sv.map
