module hippo_alu_veryl_HippoALU (
    input  var logic                             [32-1:0] a        ,
    input  var logic                             [32-1:0] b        ,
    input  var logic                                      sub_arith,
    input  var hippo_alu_veryl_ALUPackage::ALUOp          op       ,
    output var logic                             [32-1:0] res  
);
    always_comb begin
        case (op) inside
            hippo_alu_veryl_ALUPackage::ALUOp_ALU_ADD : res = ((sub_arith == 1) ? ( a - b ) : ( a + b ));
            hippo_alu_veryl_ALUPackage::ALUOp_ALU_SLL : res = a << b[4:0];
            hippo_alu_veryl_ALUPackage::ALUOp_ALU_SLT : res = (($signed(a) < $signed(b)) ? ( 1 ) : ( 0 ));
            hippo_alu_veryl_ALUPackage::ALUOp_ALU_SLTU: res = ((a < b) ? ( 1 ) : ( 0 ));
            hippo_alu_veryl_ALUPackage::ALUOp_ALU_XOR : res = a ^ b;
            hippo_alu_veryl_ALUPackage::ALUOp_ALU_SR  : if (sub_arith == 1) begin
                res = $signed(a) >>> b[4:0];
            end else begin
                res = a >> b[4:0];
            end
            hippo_alu_veryl_ALUPackage::ALUOp_ALU_OR : res = a | b;
            hippo_alu_veryl_ALUPackage::ALUOp_ALU_AND: res = a & b;
            default                                  : res = 0;
        endcase
    end
endmodule
//# sourceMappingURL=alu.sv.map
