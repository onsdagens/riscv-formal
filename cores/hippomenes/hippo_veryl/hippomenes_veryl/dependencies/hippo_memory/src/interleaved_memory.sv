// TODO: We could make this generic over the word width.
module hippo_memory_InterleavedMemory #(
    // param INIT_FILE_B0      : string = ""                        ,
    // param INIT_FILE_B1      : string = ""                        ,
    // param INIT_FILE_B2      : string = ""                        ,
    // param INIT_FILE_B3      : string = ""                        ,
    parameter int unsigned MEMORY_DEPTH_BYTES = 1024                      ,
    parameter int unsigned ADDR_WIDTH         = $clog2(MEMORY_DEPTH_BYTES),
    parameter int unsigned BLOCK_DEPTH        = MEMORY_DEPTH_BYTES / 4
) (
    input  var logic                  clk_i        ,
    input  var logic                  rst_i        ,
    input  var logic [4-1:0]          width_i      , // TODO: make this into a type
    input  var logic                  sign_extend_i,
    input  var logic [ADDR_WIDTH-1:0] addr_i       , // TODO: this should also be a type
    input  var logic [32-1:0]         data_i       ,
    input  var logic                  we_i         ,
    output var logic                  data_o   
);
    logic [2-1:0] address_clocked    ; // cargo cult variables, let's see...
    logic [2-1:0] width_clocked      ;
    logic         sign_extend_clocked;
    logic [8-1:0] block_0_dout       ;
    logic [8-1:0] block_1_dout       ;
    logic [8-1:0] block_2_dout       ;
    logic [8-1:0] block_3_dout       ;

    logic [8-1:0] block_0_din;
    logic [8-1:0] block_1_din;
    logic [8-1:0] block_2_din;
    logic [8-1:0] block_3_din;

    logic [ADDR_WIDTH - 2-1:0] block_0_addr;
    logic [ADDR_WIDTH - 2-1:0] block_1_addr;
    logic [ADDR_WIDTH - 2-1:0] block_2_addr;
    logic [ADDR_WIDTH - 2-1:0] block_3_addr;

    logic block_0_we;
    logic block_1_we;
    logic block_2_we;
    logic block_3_we;

    logic [2-1:0] alignment; always_comb alignment = addr_i[1:0];

    hippo_memory___Memory__8 #(
        .Depth (BLOCK_DEPTH),
        //     InitFile : INIT_FILE_B0,
        .Writeable (1'b1)
    ) block_0 (
        .clk_i     (clk_i       ),
        .rst_i     (rst_i       ),
        .address_i (block_0_addr),
        .we_i      (block_0_we  ),
        .data_i    (block_0_din ),
        .data_o    (block_0_dout)
    );
    hippo_memory___Memory__8 #(
        .Depth (BLOCK_DEPTH),
        //   InitFile : INIT_FILE_B1,
        .Writeable (1'b1)
    ) block_1 (
        .clk_i     (clk_i       ),
        .rst_i     (rst_i       ),
        .address_i (block_1_addr),
        .we_i      (block_1_we  ),
        .data_i    (block_1_din ),
        .data_o    (block_1_dout)
    );
    hippo_memory___Memory__8 #(
        .Depth (BLOCK_DEPTH),
        //  InitFile : INIT_FILE_B2,
        .Writeable (1'b1)
    ) block_2 (
        .clk_i     (clk_i       ),
        .rst_i     (rst_i       ),
        .address_i (block_2_addr),
        .we_i      (block_2_we  ),
        .data_i    (block_2_din ),
        .data_o    (block_2_dout)
    );
    hippo_memory___Memory__8 #(
        .Depth (BLOCK_DEPTH),
        //  InitFile : INIT_FILE_B3,
        .Writeable (1'b1)
    ) block_3 (
        .clk_i     (clk_i       ),
        .rst_i     (rst_i       ),
        .address_i (block_3_addr),
        .we_i      (block_3_we  ),
        .data_i    (block_3_din ),
        .data_o    (block_3_dout)
    );
    always_comb begin
        if ((alignment == 0)) begin
            block_0_addr = addr_i[ADDR_WIDTH - 1:2];
            block_1_addr = addr_i[ADDR_WIDTH - 1:2];
            block_2_addr = addr_i[ADDR_WIDTH - 1:2];
            block_3_addr = addr_i[ADDR_WIDTH - 1:2];
            block_0_din  = data_i[7:0];
            block_1_din  = data_i[15:8];
            block_2_din  = data_i[23:16];
            block_3_din  = data_i[31:24];
            case (width_i) inside
                4'b0001: begin
                    block_0_we = we_i;
                    block_1_we = 0;
                    block_2_we = 0;
                    block_3_we = 0;
                    if (sign_extend_i) begin
                        data_o = {{24{block_0_dout[($size(block_0_dout, 1) - 1)]}}, block_0_dout};
                    end else begin
                        data_o = {{24{0}}, block_0_dout};
                    end
                end
                4'b0011: begin
                    block_0_we = we_i;
                    block_1_we = we_i;
                    block_2_we = 0;
                    block_3_we = 0;
                    if (sign_extend_i) begin
                        data_o = {{24{block_1_dout[($size(block_1_dout, 1) - 1)]}}, block_1_dout, block_0_dout};
                    end
                end
                4'b1111: begin
                    block_0_we = we_i;
                    block_1_we = we_i;
                    block_2_we = we_i;
                    block_3_we = we_i;
                    data_o     = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
                end
                default: begin
                    block_0_we = 0;
                    block_1_we = 0;
                    block_2_we = 0;
                    block_3_we = 0;
                    data_o     = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
                end
            endcase
            data_o = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
        end else if ((alignment == 1)) begin
            block_0_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
            block_1_addr = addr_i[ADDR_WIDTH - 1:2];
            block_2_addr = addr_i[ADDR_WIDTH - 1:2];
            block_3_addr = addr_i[ADDR_WIDTH - 1:2];
            block_1_din  = data_i[7:0];
            block_2_din  = data_i[15:8];
            block_3_din  = data_i[23:16];
            block_0_din  = data_i[31:24];
            case (width_i) inside
                4'b0001: begin
                    block_1_we = we_i;
                    block_2_we = 0;
                    block_3_we = 0;
                    block_0_we = 0;
                    if (sign_extend_i) begin
                        data_o = {{24{block_1_dout[($size(block_1_dout, 1) - 1)]}}, block_1_dout};
                    end else begin
                        data_o = {{24{0}}, block_1_dout};
                    end
                end
                4'b0011: begin
                    block_1_we = we_i;
                    block_2_we = we_i;
                    block_3_we = 0;
                    block_0_we = 0;
                    if (sign_extend_i) begin
                        data_o = {{16{block_2_dout[($size(block_2_dout, 1) - 1)]}}, block_2_dout, block_1_dout};
                    end else begin
                        data_o = {{16{0}}, block_2_dout, block_1_dout};
                    end
                end
                4'b1111: begin
                    block_1_we = we_i;
                    block_2_we = we_i;
                    block_3_we = we_i;
                    block_0_we = we_i;
                    // sign extend doesn't matter since access is word wide
                    data_o = {block_0_dout, block_3_dout, block_2_dout, block_1_dout};
                end
                default: begin
                    block_0_we = 0;
                    block_1_we = 0;
                    block_2_we = 0;
                    block_3_we = 0;
                    data_o     = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
                end
            endcase
            data_o = {block_0_dout, block_3_dout, block_2_dout, block_1_dout};
        end else if ((alignment == 2)) begin
            block_0_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
            block_1_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
            block_2_addr = addr_i[ADDR_WIDTH - 1:2];
            block_3_addr = addr_i[ADDR_WIDTH - 1:2];
            block_2_din  = data_i[7:0];
            block_3_din  = data_i[15:8];
            block_0_din  = data_i[23:16];
            block_1_din  = data_i[31:24];
            case (width_i) inside
                4'b0001: begin
                    block_2_we = we_i;
                    block_3_we = 0;
                    block_0_we = 0;
                    block_1_we = 0;
                    if (sign_extend_i) begin
                        data_o = {{24{block_2_dout[($size(block_2_dout, 1) - 1)]}}, block_2_dout};
                    end else begin
                        data_o = {{24{0}}, block_2_dout};
                    end
                end
                4'b0011: begin
                    block_2_we = we_i;
                    block_3_we = we_i;
                    block_0_we = 0;
                    block_1_we = 0;
                    if (sign_extend_i) begin
                        data_o = {{16{block_3_dout[($size(block_3_dout, 1) - 1)]}}, block_3_dout, block_2_dout};
                    end else begin
                        data_o = {{16{0}}, block_3_dout, block_2_dout};
                    end
                end
                4'b1111: begin
                    block_2_we = we_i;
                    block_3_we = we_i;
                    block_0_we = we_i;
                    block_1_we = we_i;
                    // sign extension doesn't matter since access is word wide
                    data_o = {block_1_dout, block_0_dout, block_3_dout, block_2_dout};
                end
                default: begin
                    block_0_we = 0;
                    block_1_we = 0;
                    block_2_we = 0;
                    block_3_we = 0;
                    data_o     = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
                end
            endcase
        end else if ((alignment == 3)) begin
            block_0_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
            block_1_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
            block_2_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
            block_3_addr = addr_i[ADDR_WIDTH - 1:2];
            block_3_din  = data_i[7:0];
            block_0_din  = data_i[15:8];
            block_1_din  = data_i[23:16];
            block_2_din  = data_i[31:24];
            case (width_i) inside
                4'b0001: begin
                    block_3_we = ((we_i) ? ( 1 ) : ( 0 ));
                    block_0_we = 0;
                    block_1_we = 0;
                    block_2_we = 0;
                    if (sign_extend_i) begin
                        data_o = {{24{block_3_dout[($size(block_3_dout, 1) - 1)]}}, block_3_dout};
                    end else begin
                        data_o = {{24{0}}, block_3_dout};
                    end
                end
                4'b0011: begin
                    block_3_we = ((we_i) ? ( 1 ) : ( 0 ));
                    block_0_we = ((we_i) ? ( 1 ) : ( 0 ));
                    block_1_we = 0;
                    block_2_we = 0;
                    if (sign_extend_i) begin
                        data_o = {{16{block_0_dout[($size(block_0_dout, 1) - 1)]}}, block_0_dout, block_3_dout};
                    end else begin
                        data_o = {{16{0}}, block_0_dout, block_3_dout};
                    end
                end
                4'b1111: begin
                    block_3_we = ((we_i) ? ( 1 ) : ( 0 ));
                    block_0_we = ((we_i) ? ( 1 ) : ( 0 ));
                    block_1_we = ((we_i) ? ( 1 ) : ( 0 ));
                    block_2_we = ((we_i) ? ( 1 ) : ( 0 ));
                    // sign extension doesn't matter since access is word wide
                    data_o = {block_2_dout, block_1_dout, block_0_dout, block_3_dout};
                end
                default: begin
                    block_0_we = 0;
                    block_1_we = 0;
                    block_2_we = 0;
                    block_3_we = 0;
                    data_o     = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
                end
            endcase
        end
    end
endmodule
//# sourceMappingURL=interleaved_memory.sv.map
