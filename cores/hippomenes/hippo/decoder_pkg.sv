package hippo_decoder_DecoderPkg;
    typedef logic [5-1:0]  Reg ;
    typedef logic [32-1:0] Word;

    // https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
    // table on page 104
    typedef enum logic [7-1:0] {
        Op_OP_LUI = $bits(logic [7-1:0])'(7'b0110111),
        Op_OP_AUIPC = $bits(logic [7-1:0])'(7'b0010111),
        Op_OP_JAL = $bits(logic [7-1:0])'(7'b1101111),
        Op_OP_JALR = $bits(logic [7-1:0])'(7'b1100111),
        Op_OP_BRANCH = $bits(logic [7-1:0])'(7'b1100011),
        Op_OP_LOAD = $bits(logic [7-1:0])'(7'b0000011),
        Op_OP_STORE = $bits(logic [7-1:0])'(7'b0100011),
        Op_OP_ALUI = $bits(logic [7-1:0])'(7'b0010011), // OP-IMM
        Op_OP_ALU = $bits(logic [7-1:0])'(7'b0110011),
        Op_OP_FENCE = $bits(logic [7-1:0])'(7'b0001111),
        Op_OP_SYSTEM = $bits(logic [7-1:0])'(7'b1110011)
    } Op;

    typedef struct packed {
        logic [7-1:0] funct7;
        Reg           rs2   ;
        Reg           rs1   ;
        logic [3-1:0] funct3;
        Reg           rd    ;
        Op            opcode;
    } RType;

    typedef struct packed {
        logic [12-1:0] imm_11_0;
        Reg            rs1     ;
        logic [3-1:0]  funct3  ;
        Reg            rd      ;
        Op             opcode  ;
    } IType;

    typedef struct packed {
        logic [7-1:0] imm_11_5;
        Reg           rs2     ;
        Reg           rs1     ;
        logic [3-1:0] funct3  ;
        logic [5-1:0] imm_4_0 ;
        Op            opcode  ;
    } SType;

    typedef struct packed {
        logic         imm_12  ;
        logic [6-1:0] imm_10_5;
        Reg           rs2     ;
        Reg           rs1     ;
        logic [3-1:0] funct3  ;
        logic [4-1:0] imm_4_1 ;
        logic         imm_11  ;
        Op            opcode  ;
    } BType;

    typedef struct packed {
        logic [20-1:0] imm_31_12;
        Reg            rd       ;
        Op             opcode   ;
    } UType;

    typedef struct packed {
        logic [1-1:0]  imm_20   ;
        logic [10-1:0] imm_10_1 ;
        logic          imm_11   ;
        logic [8-1:0]  imm_19_12;
        Reg            rd       ;
        Op             opcode   ;
    } JType;

    typedef union packed {
        IType i_type;
        RType r_type;
        SType s_type;
        BType b_type;
        UType u_type;
        JType j_type;
    } Instr;

    typedef enum logic [1-1:0] {
        PcMux_PC_NEXT = $bits(logic [1-1:0])'(1'b0),
        PcMux_PC_BRANCH = $bits(logic [1-1:0])'(1'b1)
    } PcMux;

    typedef enum logic [1-1:0] {
        PcInterruptMux_PC_NORMAL = $bits(logic [1-1:0])'(1'b0),
        PcInterruptMux_PC_INTERRUPT = $bits(logic [1-1:0])'(1'b1)
    } PcInterruptMux;

    typedef enum logic [2-1:0] {
        MulOp_MUL_MUL = $bits(logic [2-1:0])'(2'b00),
        MulOp_MUL_MULH = $bits(logic [2-1:0])'(2'b01),
        MulOp_MUL_MULHSU = $bits(logic [2-1:0])'(2'b10),
        MulOp_MUL_MULHU = $bits(logic [2-1:0])'(2'b11)
    } MulOp;

    // enum AluOp: logic<3> {
    //     ALU_ADD = 3'b000, // ADDI
    //     ALU_SLL = 3'b001, // SLLI
    //     ALU_SLT = 3'b010, // SLLI
    //     ALU_SLTU = 3'b011, // SLTIU
    //     ALU_EXOR = 3'b100, // EXORI
    //     ALU_SR = 3'b101, // SRL, SRA, SRLI, SRAI
    //     ALU_OR = 3'b110, // ORI
    //     ALU_AND = 3'b111, // ANDI
    // }

    typedef enum logic [2-1:0] {
        AluAMux_A_IMM = $bits(logic [2-1:0])'(2'b00),
        AluAMux_A_RS1 = $bits(logic [2-1:0])'(2'b01),
        AluAMux_A_ZERO = $bits(logic [2-1:0])'(2'b10)
    } AluAMux;

    typedef enum logic [3-1:0] {
        AluBMux_B_RS2,
        AluBMux_B_IMM_EXT,
        AluBMux_B_PC_PLUS_4,
        AluBMux_B_PC,
        AluBMux_B_SHAMT
    } AluBMux;

    typedef enum logic [3-1:0] {
        BranchOp_BL_BEQ = $bits(logic [3-1:0])'(3'b000),
        BranchOp_BL_BNE = $bits(logic [3-1:0])'(3'b001),
        BranchOp_BL_BLT = $bits(logic [3-1:0])'(3'b100),
        BranchOp_BL_BGE = $bits(logic [3-1:0])'(3'b101),
        BranchOp_BL_BLTU = $bits(logic [3-1:0])'(3'b110),
        BranchOp_BL_BGEU = $bits(logic [3-1:0])'(3'b111)
    } BranchOp;

    typedef enum logic [2-1:0] {
        WbMux_WB_ALU,
        //    WB_DM,
        WbMux_WB_CSR,
        WbMux_WB_PC_PLUS_4,
        WbMux_WB_MUL
    } WbMux;

    typedef enum logic [1-1:0] {
        MemSel_MEM_DM,
        MemSel_MEM_ROM
    } MemSel;

    typedef enum logic [1-1:0] {
        WbMemMux_WB_OTHER,
        WbMemMux_WB_MEM
    } WbMemMux;

    typedef enum logic [2-1:0] {
        WtMuxSel_WT_RF_OUT,
        WtMuxSel_WT_RF_IN,
        WtMuxSel_WT_MAGIC
    } WtMuxSel;

endpackage
//# sourceMappingURL=decoder_pkg.sv.map
