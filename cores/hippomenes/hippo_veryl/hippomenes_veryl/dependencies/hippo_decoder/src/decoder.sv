



module hippo_decoder_Decoder
    import hippo_decoder_DecoderPkg::*;
    import hippo_decoder_ConfigPkg::*;
    import hippo_alu_veryl_ALUPackage::*;
(
    input  var Instr           i_instr        ,
    output var Word            o_imm          ,
    output var CsrAddr         o_csr_addr     ,
    output var Reg             o_rs1          ,
    output var Reg             o_rs2          ,
    output var Reg             o_rd           ,
    output var Reg             o_rf_we        ,
    output var AluAMux         o_alu_a_mux_sel,
    output var AluBMux         o_alu_b_mux_sel,
    output var ALUOp           o_alu_op       ,
    output var logic           o_sub          ,
    output var logic           o_csr_enable   ,
    output var logic   [3-1:0] o_funct3       ,
    output var logic           o_trap         ,
    output var logic           o_branch       ,
    output var logic           o_jump         ,
    output var logic   [3-1:0] o_mem_width    ,
    output var logic           o_mem_we       ,
    output var logic           o_load_insn
);

    always_comb begin
        // splitters
        o_rs1       = i_instr.r_type.rs1;
        o_rs2       = i_instr.r_type.rs2;
        o_rd        = i_instr.i_type.rd;
        o_imm       = 0;
        o_funct3    = i_instr.r_type.funct3;
        o_mem_width = i_instr.r_type.funct3;
        case (i_instr.r_type.opcode) inside
            hippo_decoder_DecoderPkg::Op_OP_LUI: begin
                // UType instruction
                o_imm           = {i_instr.u_type.imm_31_12, {12{1'b0}}};
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux_A_ZERO;
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux_B_IMM_EXT;
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp_ALU_OR;
                o_trap          = 0;
                o_rf_we         = 1;
                o_sub           = 0;
                o_branch        = 0;
                o_jump          = 0;
                o_mem_we        = 0;
                o_load_insn     = 0;
            end

            hippo_decoder_DecoderPkg::Op_OP_AUIPC: begin
                o_imm           = {i_instr.u_type.imm_31_12, {12{1'b0}}}; // 20 bit immediate + pc
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux_A_IMM;
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux_B_PC;
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp_ALU_ADD;
                o_trap          = 0;
                o_rf_we         = 1;
                o_sub           = 0;
                o_branch        = 0;
                o_jump          = 0;
                o_mem_we        = 0;
                o_load_insn     = 0;
            end

            hippo_decoder_DecoderPkg::Op_OP_JAL: begin
                o_imm           = {{12{i_instr.j_type.imm_20}}, i_instr.j_type.imm_19_12, i_instr.j_type.imm_11, i_instr.j_type.imm_10_1, 1'b0};
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux_A_IMM;
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux_B_PC;
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp_ALU_ADD;
                o_trap          = 0;
                o_rf_we         = 1;
                o_sub           = 0;
                o_branch        = 0;
                o_jump          = 1;
                o_mem_we        = 0;
                o_load_insn     = 0;
            end

            hippo_decoder_DecoderPkg::Op_OP_JALR: begin
                o_imm           = {{20{i_instr.i_type.imm_11_0[($size(i_instr.i_type.imm_11_0, 1) - 1)]}}, i_instr.i_type.imm_11_0};
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux_A_RS1;
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux_B_IMM_EXT;
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp_ALU_ADD;
                o_trap          = 0;
                o_rf_we         = 1;
                o_sub           = 0;
                o_branch        = 0;
                o_jump          = 1;
                o_mem_we        = 0;
                o_load_insn     = 0;
            end

            hippo_decoder_DecoderPkg::Op_OP_BRANCH: begin
                o_imm           = {{20{i_instr.b_type.imm_12}}, i_instr.b_type.imm_11, i_instr.b_type.imm_10_5, i_instr.b_type.imm_4_1, 1'b0};
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux_A_IMM;
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux_B_PC;
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp_ALU_ADD;
                o_trap          = 0;
                o_rf_we         = 0;
                o_sub           = 0;
                o_branch        = 1;
                o_jump          = 0;
                o_mem_we        = 0;
                o_load_insn     = 0;
            end

            hippo_decoder_DecoderPkg::Op_OP_LOAD: begin
                o_imm           = {{20{i_instr.i_type.imm_11_0[($size(i_instr.i_type.imm_11_0, 1) - 1)]}}, i_instr.i_type.imm_11_0};
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux_A_RS1;
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux_B_IMM_EXT;
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp_ALU_ADD;
                o_trap          = 0;
                o_rf_we         = 1;
                o_sub           = 0;
                o_branch        = 0;
                o_jump          = 0;
                o_mem_we        = 0;
                o_load_insn     = 1;
            end

            hippo_decoder_DecoderPkg::Op_OP_STORE: begin
                o_imm           = {{20{i_instr.s_type.imm_11_5[($size(i_instr.s_type.imm_11_5, 1) - 1)]}}, i_instr.s_type.imm_11_5, i_instr.s_type.imm_4_0};
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux_A_RS1;
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux_B_IMM_EXT;
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp_ALU_ADD;
                o_trap          = 0;
                o_rf_we         = 0;
                o_sub           = 0;
                o_branch        = 0;
                o_jump          = 0;
                o_mem_we        = 1;
                o_load_insn     = 0;
            end

            hippo_decoder_DecoderPkg::Op_OP_ALUI: begin
                // IType
                o_imm           = {{20{i_instr.i_type.imm_11_0[($size(i_instr.i_type.imm_11_0, 1) - 1)]}}, i_instr.i_type.imm_11_0};
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux_A_RS1;
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux_B_IMM_EXT;
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp'(i_instr.i_type.funct3);
                o_trap          = 0;
                o_rf_we         = 1;
                o_sub           = 0;
                o_branch        = 0;
                o_jump          = 0;
                o_mem_we        = 0;
                o_load_insn     = 0;
            end

            hippo_decoder_DecoderPkg::Op_OP_ALU: begin
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux_A_RS1;
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux_B_RS2;
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp'(i_instr.r_type.funct3);
                o_trap          = 0;
                o_rf_we         = 1;
                o_sub           = i_instr.r_type.funct7[5];
                o_branch        = 0;
                o_jump          = 0;
                o_mem_we        = 0;
                o_load_insn     = 0;
            end

            hippo_decoder_DecoderPkg::Op_OP_FENCE: begin
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux'(0);
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux'(0);
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp'(0);
                o_trap          = 0;
                o_rf_we         = 0;
                o_sub           = 0;
                o_branch        = 0;
                o_jump          = 0;
                o_mem_we        = 0;
                o_load_insn     = 0;
            end

            hippo_decoder_DecoderPkg::Op_OP_SYSTEM: begin
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux'(0);
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux'(0);
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp'(0);
                o_trap          = 0;
                // for now, these are also CSR OPs
                o_rf_we     = 0;
                o_sub       = 0;
                o_branch    = 0;
                o_jump      = 0;
                o_mem_we    = 0;
                o_load_insn = 0;
            end

            default: begin
                $display       ("-- non matched op --");
                o_alu_a_mux_sel = hippo_decoder_DecoderPkg::AluAMux'(0);
                o_alu_b_mux_sel = hippo_decoder_DecoderPkg::AluBMux'(0);
                o_alu_op        = hippo_alu_veryl_ALUPackage::ALUOp'(0);
                o_trap          = 1;
                o_rf_we         = 0;
                o_sub           = 0;
                o_branch        = 0;
                o_jump          = 0;
                o_mem_we        = 0;
                o_load_insn     = 0;
            end
        endcase

    end
endmodule
//# sourceMappingURL=decoder.sv.map
