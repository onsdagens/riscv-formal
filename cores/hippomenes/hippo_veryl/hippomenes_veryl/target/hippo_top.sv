// these two should be top level
// or even just parameters, these package files are kind of annoying





module hippomenes_veryl_HippoTop
    import hippo_decoder_DecoderPkg::*;
    import hippo_decoder_ConfigPkg::*;
    import veryl_stacked_regfile_RegFilePkg::*;
    import hippo_alu_veryl_ALUPackage::*;
#(
    parameter int unsigned                     IMemAddrWidth = 5,
    parameter logic        [IMemAddrWidth-1:0] IMemStartAddr = 0,
    //param IMemInitFile : string                = ""                ,
    parameter int unsigned IMemMaxAddr = IMemAddrWidth ** 2
) (
    input var logic clk_i,
    input var logic rst_i,



    // RVFI
    // Instruction metadata
    output var logic          rvfi_valid,
    output var logic [64-1:0] rvfi_order,
    output var logic [32-1:0] rvfi_insn ,
    output var logic          rvfi_trap ,
    output var logic          rvfi_halt ,
    output var logic          rvfi_intr ,
    output var logic [2-1:0]  rvfi_mode ,
    output var logic [2-1:0]  rvfi_ixl  ,
    // Integer register read/write
    output var logic [5-1:0]  rvfi_rs1_addr ,
    output var logic [5-1:0]  rvfi_rs2_addr ,
    output var logic [32-1:0] rvfi_rs1_rdata,
    output var logic [32-1:0] rvfi_rs2_rdata,
    output var logic [5-1:0]  rvfi_rd_addr  ,
    output var logic [32-1:0] rvfi_rd_wdata ,
    // Program Counter
    output var logic [32-1:0] rvfi_pc_rdata,
    output var logic [32-1:0] rvfi_pc_wdata,
    // Memory access
    output var logic [32-1:0] rvfi_mem_addr ,
    output var logic [4-1:0]  rvfi_mem_rmask,
    output var logic [4-1:0]  rvfi_mem_wmask,
    output var logic [4-1:0]  rvfi_mem_rdata,
    output var logic [4-1:0]  rvfi_mem_wdata
);



    // ---------- Program Counter ----------
    logic [32-1:0] pc             ;
    logic [32-1:0] pc_next        ;
    logic          take_branch    ;
    logic          misaligned_trap;
    logic          take_jump      ;
    logic [32-1:0] pc_plus4       ; always_comb pc_plus4        = pc + 4;
    always_ff @ (posedge clk_i, negedge rst_i) begin
        if (!rst_i) begin
            pc <= IMemStartAddr;
        end else begin
            pc <= pc_next;
        end
    end
    // PC Selection (Pc + 4/Branch/Jump etc.)
    always_comb begin
        // Pc + 4
        if (!(take_branch) && !(jump_insn)) begin
            pc_next         = pc_plus4;
            misaligned_trap = ((pc_next[1:0] != 0) ? ( 1 ) : ( 0 ));
        end
        // Branch
         else if (take_branch) begin
            pc_next         = alu_res;
            misaligned_trap = ((alu_res[1:0] != 0) ? ( 1 ) : ( 0 ));
        end
        // Jump (probably really there is no difference between take_branch and jump)
         else begin
            pc_next         = alu_res;
            misaligned_trap = ((alu_res[1:0] != 0) ? ( 1 ) : ( 0 ));
        end
    end

    // Branch Logic, note beq is inverse of bne, blt is inverse of bge and bltu is inverse of bgeu, i.e. we can optimize this
    always_comb begin
        if (branch_insn) begin
            logic equal;
            logic ge   ;
            logic geu  ;
            equal = rs1_data == rs2_data;
            ge    = rs1_data >= rs2_data;
            geu   = $unsigned(rs1_data) >= $unsigned(rs2_data);
            case (hippo_decoder_DecoderPkg::BranchOp'(funct3)) inside
                hippo_decoder_DecoderPkg::BranchOp_BL_BEQ: begin
                    take_branch = equal;
                end
                hippo_decoder_DecoderPkg::BranchOp_BL_BNE: begin
                    take_branch = ~equal;
                end
                hippo_decoder_DecoderPkg::BranchOp_BL_BLT: begin
                    take_branch = ~ge;
                end
                hippo_decoder_DecoderPkg::BranchOp_BL_BGE: begin
                    take_branch = ge;
                end
                hippo_decoder_DecoderPkg::BranchOp_BL_BLTU: begin
                    take_branch = ~geu;
                end
                hippo_decoder_DecoderPkg::BranchOp_BL_BGEU: begin
                    take_branch = geu;
                end
                default: begin
                    take_branch = 0;
                end
            endcase
        end else begin
            take_branch = 0;
        end
    end
    // ----------


    // ---------- Instruction Memory ----------
    // TODO: Memory generic over data TYPE
    logic [32-1:0] instruction;
    hippo_memory___Memory__32 #(
        .Depth     (IMemAddrWidth ** 2),
        .Writeable (1'b0              )
        // InitFile : IMemInitFile      , Unfortunately, from what i can tell
        //                                yosys cannot handle non-existant init files.
        //                                SV spec says if readmemh file does not exist,
        //                                the memory should be zeroed, we could have
        //                                dummy files doing exactly that.
    ) instruction_memory (
        .clk_i     (clk_i             ),
        .rst_i     (rst_i             ),
        .address_i (IMemAddrWidth'(pc)),
        .we_i      (0                 ),
        .data_i    (0                 ),
        .data_o    (instruction       )
    );
    // ----------

    // ---------- Decoder ----------
    Word            immediate    ;
    CsrAddr         csr_addr     ;
    logic           csr_enable   ;
    Reg             regfile_rs1  ;
    Reg             regfile_rs2  ;
    Reg             regfile_rd   ;
    AluAMux         alu_a_mux_sel;
    AluBMux         alu_b_mux_sel;
    ALUOp           alu_op       ;
    logic           decoder_trap ;
    logic           alu_sub_arith;
    logic           rf_we        ;
    logic   [3-1:0] funct3       ;
    logic           branch_insn  ;
    logic           jump_insn    ;
    logic   [3-1:0] mem_width    ;
    logic           mem_we       ;
    logic           load_insn    ;
    hippo_decoder_Decoder decoder (
        .i_instr         (Instr'(instruction)),
        .o_imm           (immediate          ),
        .o_csr_addr      (csr_addr           ),
        .o_rs1           (regfile_rs1        ),
        .o_rs2           (regfile_rs2        ),
        .o_rd            (regfile_rd         ),
        .o_alu_a_mux_sel (alu_a_mux_sel      ),
        .o_alu_b_mux_sel (alu_b_mux_sel      ),
        .o_alu_op        (alu_op             ),
        .o_sub           (alu_sub_arith      ),
        .o_csr_enable    (csr_enable         ),
        .o_trap          (decoder_trap       ),
        .o_rf_we         (rf_we              ),
        .o_funct3        (funct3             ),
        .o_branch        (branch_insn        ),
        .o_jump          (jump_insn          ),
        .o_mem_width     (mem_width          ),
        .o_mem_we        (mem_we             ),
        .o_load_insn     (load_insn          )
    );
    // ----------


    // ---------- Register File ----------
    logic [32-1:0] rs1_data;
    logic [32-1:0] rs2_data;
    veryl_stacked_regfile_RegFileStack #(
        .Depth      (1             ),
        .mask       (GlobalMaskIABI),
        .stack_mask (StackMaskIABI )
    ) reg_file_stack (
        .i_clk     (clk_i                                         ),
        .i_reset   (rst_i                                         ),
        .i_command (veryl_stacked_regfile_RegFilePkg::Command_none), // For now
        .i_a_addr  (regfile_rs1                                   ),
        .i_b_addr  (regfile_rs2                                   ),
        .i_w_ena   (rf_we                                         ),
        .i_w_addr  (regfile_rd                                    ),
        .i_w_data  (rf_wb_data                                    ),
        .o_a_data  (rs1_data                                      ),
        .o_b_data  (rs2_data                                      )
    );
    // ----------

    // ---------- ALU machinery ----------
    // Pick ALU source A
    logic [32-1:0] alu_a;
    always_comb begin
        case (alu_a_mux_sel) inside
            hippo_decoder_DecoderPkg::AluAMux_A_RS1: begin
                alu_a = rs1_data;
            end
            hippo_decoder_DecoderPkg::AluAMux_A_IMM: begin
                alu_a = immediate;
            end
            default: begin
                alu_a = 0;
            end
        endcase
    end
    // Pick ALU source B
    logic [32-1:0] alu_b;
    always_comb begin
        case (alu_b_mux_sel) inside
            hippo_decoder_DecoderPkg::AluBMux_B_RS2: begin
                alu_b = rs2_data;
            end
            hippo_decoder_DecoderPkg::AluBMux_B_IMM_EXT: begin
                alu_b = 32'(immediate);
            end
            hippo_decoder_DecoderPkg::AluBMux_B_PC: begin
                alu_b = 32'(pc);
            end
            default: begin
                alu_b = 0;
            end
        endcase
    end

    // ALU
    logic [32-1:0] alu_res;
    hippo_alu_veryl_HippoALU alu (
        .a         (alu_a        ),
        .b         (alu_b        ),
        .sub_arith (alu_sub_arith),
        .op        (alu_op       ),
        .res       (alu_res      )
    );
    // ----------

    // ---------- Data Memory ----------
    logic [32-1:0] dmem_data;
    logic [4-1:0]  mem_mask ; always_comb mem_mask  = (((mem_width == 0) == 1'b1) ? (
        4'b0001
    ) : ((mem_width == 1) == 1'b1) ? (
        4'b0011
    ) : ((mem_width == 2) == 1'b1) ? (
        4'b1111
    ) : (
        4'b0000
    ));
    hippo_memory_InterleavedMemory data_memory (
        .clk_i         (clk_i    ),
        .rst_i         (rst_i    ),
        .width_i       (mem_mask ),
        .sign_extend_i (0        ), // this needs fixed
        .addr_i        (alu_res  ),
        .data_i        (rs2_data ),
        .we_i          (mem_we   ),
        .data_o        (dmem_data)
    );
    // ----------

    // ---------- Writeback ----------
    logic [32-1:0] rf_wb_data; always_comb rf_wb_data = (((regfile_rd != 0)) ? ( ((((jump_insn)) ? ( pc_plus4 ) : ((load_insn)) ? ( dmem_data ) : ( alu_res ))) ) : ( 32'(0) )); // I think the RVFI kinda requires this
    // ----------

    // ---------- RVFI Specifics ----------
    // except for rvfi_order, i think if there is any logic here
    // i think we may be doing something wrong,
    always_comb rvfi_mem_addr  = alu_res;
    always_comb rvfi_mem_rmask = 4'b1111; // we do not have any weirdness, so may just go i think
    always_comb rvfi_mem_wmask = ((mem_we) ? ( mem_mask ) : ( 4'b0000 ));
    always_comb rvfi_mem_rdata = dmem_data;
    always_comb rvfi_mem_wdata = rs2_data;

    // Instruction metadata
    always_comb rvfi_valid = ~decoder_trap && ~misaligned_trap;
    // this should be unique for each executed instruction
    always_ff @ (posedge clk_i, negedge rst_i) begin
        if (!rst_i) begin
            rvfi_order <= 0;
        end else begin
            rvfi_order <= rvfi_order + (1);
        end
    end
    always_comb rvfi_insn = instruction;
    always_comb rvfi_trap = decoder_trap | misaligned_trap;
    always_comb rvfi_halt = ((pc == IMemMaxAddr) ? ( 1 ) : ( 0 ));

    // unclear, for now no traps, so let's call it 0
    always_comb rvfi_intr = 0;

    always_comb rvfi_mode = 3; // we only support M-Mode.
    always_comb rvfi_ixl  = 1; // and only 32-bit operation

    // Integer register read/write
    always_comb rvfi_rs1_addr  = regfile_rs1;
    always_comb rvfi_rs2_addr  = regfile_rs2;
    always_comb rvfi_rs1_rdata = rs1_data;
    always_comb rvfi_rs2_rdata = rs2_data;

    always_comb rvfi_rd_addr  = (((!rf_we)) ? ( 0 ) : ( regfile_rd ));
    always_comb rvfi_rd_wdata = (((!rf_we)) ? ( 0 ) : ( rf_wb_data ));

    // Program Counter
    always_comb rvfi_pc_rdata = 32'(pc);
    always_comb rvfi_pc_wdata = 32'(pc_next);
    // ----------
endmodule
//# sourceMappingURL=hippo_top.sv.map
