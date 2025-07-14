module hippo_alu_veryl_HippoALU (
	a,
	b,
	sub_arith,
	op,
	res
);
	reg _sv2v_0;
	input wire [31:0] a;
	input wire [31:0] b;
	input wire sub_arith;
	input wire [2:0] op;
	output reg [31:0] res;
	always @(*) begin
		if (_sv2v_0)
			;
		if (op == 3'd0)
			res = (sub_arith == 1 ? a - b : a + b);
		else if (op == 3'd1)
			res = a << b[4:0];
		else if (op == 3'd2)
			res = ($signed(a) < $signed(b) ? 1 : 0);
		else if (op == 3'd3)
			res = (a < b ? 1 : 0);
		else if (op == 3'd4)
			res = a ^ b;
		else if (op == 3'd5) begin
			if (sub_arith == 1)
				res = $signed(a) >>> b[4:0];
			else
				res = a >> b[4:0];
		end
		else if (op == 3'd6)
			res = a | b;
		else if (op == 3'd7)
			res = a & b;
		else
			res = 0;
	end
	initial _sv2v_0 = 0;
endmodule
module veryl_stacked_regfile_RegFileInstance (
	i_clk,
	i_reset,
	i_command,
	i_push_data,
	i_pop_data,
	o_data
);
	reg _sv2v_0;
	parameter [31:0] mask = 32'hffffffff;
	input wire i_clk;
	input wire i_reset;
	input wire [1:0] i_command;
	input wire [1023:0] i_push_data;
	input wire [1023:0] i_pop_data;
	output reg [1023:0] o_data;
	reg [1023:0] regs;
	always @(posedge i_clk) begin : sv2v_autoblock_1
		reg [31:0] i;
		for (i = 0; i < 32; i = i + 1)
			if (i_reset | ~mask[i])
				regs[(31 - i) * 32+:32] <= 0;
			else if (i_command == 2'd1)
				regs[(31 - i) * 32+:32] <= i_push_data[(31 - i) * 32+:32];
			else if (i_command == 2'd2)
				regs[(31 - i) * 32+:32] <= i_pop_data[(31 - i) * 32+:32];
	end
	always @(*) begin
		if (_sv2v_0)
			;
		o_data = regs;
	end
	initial _sv2v_0 = 0;
endmodule
module veryl_stacked_regfile_RegFileStack (
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
	reg _sv2v_0;
	parameter [31:0] Depth = 4;
	parameter [31:0] mask = 32'b11111111111111111111111111100110;
	parameter [31:0] stack_mask = 32'b11110000000000111111110011100000;
	input wire i_clk;
	input wire i_reset;
	input wire [1:0] i_command;
	input wire [4:0] i_a_addr;
	input wire [4:0] i_b_addr;
	input wire i_w_ena;
	input wire [4:0] i_w_addr;
	input wire [31:0] i_w_data;
	output reg [31:0] o_a_data;
	output reg [31:0] o_b_data;
	reg [1023:0] rf_stack [0:Depth + 0];
	genvar _gv_i_1;
	generate
		for (_gv_i_1 = 0; _gv_i_1 < (Depth - 1); _gv_i_1 = _gv_i_1 + 1) begin : label
			localparam i = _gv_i_1;
			wire [1024:1] sv2v_tmp_rf_o_data;
			always @(*) rf_stack[i + 1] = sv2v_tmp_rf_o_data;
			veryl_stacked_regfile_RegFileInstance #(.mask(stack_mask)) rf(
				.i_clk(i_clk),
				.i_reset(i_reset),
				.i_command(i_command),
				.i_push_data(rf_stack[i]),
				.i_pop_data(rf_stack[i + 2]),
				.o_data(sv2v_tmp_rf_o_data)
			);
		end
	endgenerate
	reg [1023:0] regs;
	always @(posedge i_clk) begin : sv2v_autoblock_1
		reg [31:0] i;
		for (i = 0; i < 32; i = i + 1)
			if (i_reset | ~mask[i])
				regs[(31 - i) * 32+:32] <= 0;
			else if (i_command == 2'd2) begin
				if (stack_mask[i])
					regs[(31 - i) * 32+:32] <= rf_stack[1][(31 - i) * 32+:32];
			end
			else if (i_w_ena && mask[i])
				regs[(31 - i_w_addr) * 32+:32] <= i_w_data;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rf_stack[0] = regs;
		o_a_data = regs[(31 - i_a_addr) * 32+:32];
		o_b_data = regs[(31 - i_b_addr) * 32+:32];
	end
	initial _sv2v_0 = 0;
endmodule
module hippo_memory___Memory__32 (
	clk_i,
	rst_i,
	address_i,
	we_i,
	data_i,
	data_o
);
	parameter [31:0] Depth = 256;
	parameter [31:0] AddrWidth = $clog2(Depth);
	parameter [0:0] Writeable = 1'b0;
	input wire clk_i;
	input wire rst_i;
	input wire [AddrWidth - 1:0] address_i;
	input wire we_i;
	input wire [31:0] data_i;
	output reg [31:0] data_o;
	reg [31:0] memory [0:Depth - 1];
	always @(posedge clk_i or negedge rst_i)
		if (!rst_i)
			data_o <= 1'sb0;
		else if (we_i)
			memory[address_i] <= data_i;
		else
			data_o <= memory[address_i];
endmodule
module hippo_memory___Memory__8 (
	clk_i,
	rst_i,
	address_i,
	we_i,
	data_i,
	data_o
);
	parameter [31:0] Depth = 256;
	parameter [31:0] AddrWidth = $clog2(Depth);
	parameter [0:0] Writeable = 1'b0;
	input wire clk_i;
	input wire rst_i;
	input wire [AddrWidth - 1:0] address_i;
	input wire we_i;
	input wire [7:0] data_i;
	output reg [7:0] data_o;
	reg [7:0] memory [0:Depth - 1];
	always @(posedge clk_i or negedge rst_i)
		if (!rst_i)
			data_o <= 1'sb0;
		else if (we_i)
			memory[address_i] <= data_i;
		else
			data_o <= memory[address_i];
endmodule
module hippo_memory_InterleavedMemory (
	clk_i,
	rst_i,
	width_i,
	sign_extend_i,
	addr_i,
	data_i,
	we_i,
	data_o
);
	reg _sv2v_0;
	parameter [31:0] MEMORY_DEPTH_BYTES = 1024;
	parameter [31:0] ADDR_WIDTH = $clog2(MEMORY_DEPTH_BYTES);
	parameter [31:0] BLOCK_DEPTH = MEMORY_DEPTH_BYTES / 4;
	input wire clk_i;
	input wire rst_i;
	input wire [3:0] width_i;
	input wire sign_extend_i;
	input wire [ADDR_WIDTH - 1:0] addr_i;
	input wire [31:0] data_i;
	input wire we_i;
	output reg data_o;
	wire [1:0] address_clocked;
	wire [1:0] width_clocked;
	wire sign_extend_clocked;
	wire [7:0] block_0_dout;
	wire [7:0] block_1_dout;
	wire [7:0] block_2_dout;
	wire [7:0] block_3_dout;
	reg [7:0] block_0_din;
	reg [7:0] block_1_din;
	reg [7:0] block_2_din;
	reg [7:0] block_3_din;
	reg [ADDR_WIDTH - 3:0] block_0_addr;
	reg [ADDR_WIDTH - 3:0] block_1_addr;
	reg [ADDR_WIDTH - 3:0] block_2_addr;
	reg [ADDR_WIDTH - 3:0] block_3_addr;
	reg block_0_we;
	reg block_1_we;
	reg block_2_we;
	reg block_3_we;
	reg [1:0] alignment;
	always @(*) begin
		if (_sv2v_0)
			;
		alignment = addr_i[1:0];
	end
	hippo_memory___Memory__8 #(
		.Depth(BLOCK_DEPTH),
		.Writeable(1'b1)
	) block_0(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.address_i(block_0_addr),
		.we_i(block_0_we),
		.data_i(block_0_din),
		.data_o(block_0_dout)
	);
	hippo_memory___Memory__8 #(
		.Depth(BLOCK_DEPTH),
		.Writeable(1'b1)
	) block_1(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.address_i(block_1_addr),
		.we_i(block_1_we),
		.data_i(block_1_din),
		.data_o(block_1_dout)
	);
	hippo_memory___Memory__8 #(
		.Depth(BLOCK_DEPTH),
		.Writeable(1'b1)
	) block_2(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.address_i(block_2_addr),
		.we_i(block_2_we),
		.data_i(block_2_din),
		.data_o(block_2_dout)
	);
	hippo_memory___Memory__8 #(
		.Depth(BLOCK_DEPTH),
		.Writeable(1'b1)
	) block_3(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.address_i(block_3_addr),
		.we_i(block_3_we),
		.data_i(block_3_din),
		.data_o(block_3_dout)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		if (alignment == 0) begin
			block_0_addr = addr_i[ADDR_WIDTH - 1:2];
			block_1_addr = addr_i[ADDR_WIDTH - 1:2];
			block_2_addr = addr_i[ADDR_WIDTH - 1:2];
			block_3_addr = addr_i[ADDR_WIDTH - 1:2];
			block_0_din = data_i[7:0];
			block_1_din = data_i[15:8];
			block_2_din = data_i[23:16];
			block_3_din = data_i[31:24];
			if (width_i == 4'b0001) begin
				block_0_we = we_i;
				block_1_we = 0;
				block_2_we = 0;
				block_3_we = 0;
				if (sign_extend_i)
					data_o = {{24 {block_0_dout[7]}}, block_0_dout};
				else
					data_o = {{24 {0}}, block_0_dout};
			end
			else if (width_i == 4'b0011) begin
				block_0_we = we_i;
				block_1_we = we_i;
				block_2_we = 0;
				block_3_we = 0;
				if (sign_extend_i)
					data_o = {{24 {block_1_dout[7]}}, block_1_dout, block_0_dout};
			end
			else if (width_i == 4'b1111) begin
				block_0_we = we_i;
				block_1_we = we_i;
				block_2_we = we_i;
				block_3_we = we_i;
				data_o = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
			end
			else begin
				block_0_we = 0;
				block_1_we = 0;
				block_2_we = 0;
				block_3_we = 0;
				data_o = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
			end
			data_o = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
		end
		else if (alignment == 1) begin
			block_0_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
			block_1_addr = addr_i[ADDR_WIDTH - 1:2];
			block_2_addr = addr_i[ADDR_WIDTH - 1:2];
			block_3_addr = addr_i[ADDR_WIDTH - 1:2];
			block_1_din = data_i[7:0];
			block_2_din = data_i[15:8];
			block_3_din = data_i[23:16];
			block_0_din = data_i[31:24];
			if (width_i == 4'b0001) begin
				block_1_we = we_i;
				block_2_we = 0;
				block_3_we = 0;
				block_0_we = 0;
				if (sign_extend_i)
					data_o = {{24 {block_1_dout[7]}}, block_1_dout};
				else
					data_o = {{24 {0}}, block_1_dout};
			end
			else if (width_i == 4'b0011) begin
				block_1_we = we_i;
				block_2_we = we_i;
				block_3_we = 0;
				block_0_we = 0;
				if (sign_extend_i)
					data_o = {{16 {block_2_dout[7]}}, block_2_dout, block_1_dout};
				else
					data_o = {{16 {0}}, block_2_dout, block_1_dout};
			end
			else if (width_i == 4'b1111) begin
				block_1_we = we_i;
				block_2_we = we_i;
				block_3_we = we_i;
				block_0_we = we_i;
				data_o = {block_0_dout, block_3_dout, block_2_dout, block_1_dout};
			end
			else begin
				block_0_we = 0;
				block_1_we = 0;
				block_2_we = 0;
				block_3_we = 0;
				data_o = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
			end
			data_o = {block_0_dout, block_3_dout, block_2_dout, block_1_dout};
		end
		else if (alignment == 2) begin
			block_0_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
			block_1_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
			block_2_addr = addr_i[ADDR_WIDTH - 1:2];
			block_3_addr = addr_i[ADDR_WIDTH - 1:2];
			block_2_din = data_i[7:0];
			block_3_din = data_i[15:8];
			block_0_din = data_i[23:16];
			block_1_din = data_i[31:24];
			if (width_i == 4'b0001) begin
				block_2_we = we_i;
				block_3_we = 0;
				block_0_we = 0;
				block_1_we = 0;
				if (sign_extend_i)
					data_o = {{24 {block_2_dout[7]}}, block_2_dout};
				else
					data_o = {{24 {0}}, block_2_dout};
			end
			else if (width_i == 4'b0011) begin
				block_2_we = we_i;
				block_3_we = we_i;
				block_0_we = 0;
				block_1_we = 0;
				if (sign_extend_i)
					data_o = {{16 {block_3_dout[7]}}, block_3_dout, block_2_dout};
				else
					data_o = {{16 {0}}, block_3_dout, block_2_dout};
			end
			else if (width_i == 4'b1111) begin
				block_2_we = we_i;
				block_3_we = we_i;
				block_0_we = we_i;
				block_1_we = we_i;
				data_o = {block_1_dout, block_0_dout, block_3_dout, block_2_dout};
			end
			else begin
				block_0_we = 0;
				block_1_we = 0;
				block_2_we = 0;
				block_3_we = 0;
				data_o = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
			end
		end
		else if (alignment == 3) begin
			block_0_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
			block_1_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
			block_2_addr = addr_i[ADDR_WIDTH - 1:2] + 1;
			block_3_addr = addr_i[ADDR_WIDTH - 1:2];
			block_3_din = data_i[7:0];
			block_0_din = data_i[15:8];
			block_1_din = data_i[23:16];
			block_2_din = data_i[31:24];
			if (width_i == 4'b0001) begin
				block_3_we = (we_i ? 1 : 0);
				block_0_we = 0;
				block_1_we = 0;
				block_2_we = 0;
				if (sign_extend_i)
					data_o = {{24 {block_3_dout[7]}}, block_3_dout};
				else
					data_o = {{24 {0}}, block_3_dout};
			end
			else if (width_i == 4'b0011) begin
				block_3_we = (we_i ? 1 : 0);
				block_0_we = (we_i ? 1 : 0);
				block_1_we = 0;
				block_2_we = 0;
				if (sign_extend_i)
					data_o = {{16 {block_0_dout[7]}}, block_0_dout, block_3_dout};
				else
					data_o = {{16 {0}}, block_0_dout, block_3_dout};
			end
			else if (width_i == 4'b1111) begin
				block_3_we = (we_i ? 1 : 0);
				block_0_we = (we_i ? 1 : 0);
				block_1_we = (we_i ? 1 : 0);
				block_2_we = (we_i ? 1 : 0);
				data_o = {block_2_dout, block_1_dout, block_0_dout, block_3_dout};
			end
			else begin
				block_0_we = 0;
				block_1_we = 0;
				block_2_we = 0;
				block_3_we = 0;
				data_o = {block_3_dout, block_2_dout, block_1_dout, block_0_dout};
			end
		end
	end
	initial _sv2v_0 = 0;
endmodule
module hippo_decoder_Decoder (
	i_instr,
	o_imm,
	o_csr_addr,
	o_rs1,
	o_rs2,
	o_rd,
	o_rf_we,
	o_alu_a_mux_sel,
	o_alu_b_mux_sel,
	o_alu_op,
	o_sub,
	o_csr_enable,
	o_funct3,
	o_trap,
	o_branch,
	o_jump,
	o_mem_width,
	o_mem_we,
	o_load_insn
);
	reg _sv2v_0;
	input wire [31:0] i_instr;
	output reg [31:0] o_imm;
	output wire [11:0] o_csr_addr;
	output reg [4:0] o_rs1;
	output reg [4:0] o_rs2;
	output reg [4:0] o_rd;
	output reg [4:0] o_rf_we;
	output reg [1:0] o_alu_a_mux_sel;
	output reg [2:0] o_alu_b_mux_sel;
	output reg [2:0] o_alu_op;
	output reg o_sub;
	output wire o_csr_enable;
	output reg [2:0] o_funct3;
	output reg o_trap;
	output reg o_branch;
	output reg o_jump;
	output reg [2:0] o_mem_width;
	output reg o_mem_we;
	output reg o_load_insn;
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		o_rs1 = i_instr[19-:5];
		o_rs2 = i_instr[24-:5];
		o_rd = i_instr[11-:5];
		o_imm = 0;
		o_funct3 = i_instr[14-:3];
		o_mem_width = i_instr[14-:3];
		if (i_instr[6-:7] == 7'b0110111) begin
			o_imm = {i_instr[31-:20], {12 {1'b0}}};
			o_alu_a_mux_sel = 2'b10;
			o_alu_b_mux_sel = 3'd1;
			o_alu_op = 3'd6;
			o_trap = 0;
			o_rf_we = 1;
			o_sub = 0;
			o_branch = 0;
			o_jump = 0;
			o_mem_we = 0;
			o_load_insn = 0;
		end
		else if (i_instr[6-:7] == 7'b0010111) begin
			o_imm = {i_instr[31-:20], {12 {1'b0}}};
			o_alu_a_mux_sel = 2'b00;
			o_alu_b_mux_sel = 3'd3;
			o_alu_op = 3'd0;
			o_trap = 0;
			o_rf_we = 1;
			o_sub = 0;
			o_branch = 0;
			o_jump = 0;
			o_mem_we = 0;
			o_load_insn = 0;
		end
		else if (i_instr[6-:7] == 7'b1101111) begin
			o_imm = {{12 {i_instr[31]}}, i_instr[19-:8], i_instr[20], i_instr[30-:10], 1'b0};
			o_alu_a_mux_sel = 2'b00;
			o_alu_b_mux_sel = 3'd3;
			o_alu_op = 3'd0;
			o_trap = 0;
			o_rf_we = 1;
			o_sub = 0;
			o_branch = 0;
			o_jump = 1;
			o_mem_we = 0;
			o_load_insn = 0;
		end
		else if (i_instr[6-:7] == 7'b1100111) begin
			o_imm = {{20 {i_instr[31]}}, i_instr[31-:12]};
			o_alu_a_mux_sel = 2'b01;
			o_alu_b_mux_sel = 3'd1;
			o_alu_op = 3'd0;
			o_trap = 0;
			o_rf_we = 1;
			o_sub = 0;
			o_branch = 0;
			o_jump = 1;
			o_mem_we = 0;
			o_load_insn = 0;
		end
		else if (i_instr[6-:7] == 7'b1100011) begin
			o_imm = {{20 {i_instr[31]}}, i_instr[7], i_instr[30-:6], i_instr[11-:4], 1'b0};
			o_alu_a_mux_sel = 2'b00;
			o_alu_b_mux_sel = 3'd3;
			o_alu_op = 3'd0;
			o_trap = 0;
			o_rf_we = 0;
			o_sub = 0;
			o_branch = 1;
			o_jump = 0;
			o_mem_we = 0;
			o_load_insn = 0;
		end
		else if (i_instr[6-:7] == 7'b0000011) begin
			o_imm = {{20 {i_instr[31]}}, i_instr[31-:12]};
			o_alu_a_mux_sel = 2'b01;
			o_alu_b_mux_sel = 3'd1;
			o_alu_op = 3'd0;
			o_trap = 0;
			o_rf_we = 1;
			o_sub = 0;
			o_branch = 0;
			o_jump = 0;
			o_mem_we = 0;
			o_load_insn = 1;
		end
		else if (i_instr[6-:7] == 7'b0100011) begin
			o_imm = {{20 {i_instr[31]}}, i_instr[31-:7], i_instr[11-:5]};
			o_alu_a_mux_sel = 2'b01;
			o_alu_b_mux_sel = 3'd1;
			o_alu_op = 3'd0;
			o_trap = 0;
			o_rf_we = 0;
			o_sub = 0;
			o_branch = 0;
			o_jump = 0;
			o_mem_we = 1;
			o_load_insn = 0;
		end
		else if (i_instr[6-:7] == 7'b0010011) begin
			o_imm = {{20 {i_instr[31]}}, i_instr[31-:12]};
			o_alu_a_mux_sel = 2'b01;
			o_alu_b_mux_sel = 3'd1;
			o_alu_op = sv2v_cast_3(i_instr[14-:3]);
			o_trap = 0;
			o_rf_we = 1;
			o_sub = 0;
			o_branch = 0;
			o_jump = 0;
			o_mem_we = 0;
			o_load_insn = 0;
		end
		else if (i_instr[6-:7] == 7'b0110011) begin
			o_alu_a_mux_sel = 2'b01;
			o_alu_b_mux_sel = 3'd0;
			o_alu_op = sv2v_cast_3(i_instr[14-:3]);
			o_trap = 0;
			o_rf_we = 1;
			o_sub = i_instr[30];
			o_branch = 0;
			o_jump = 0;
			o_mem_we = 0;
			o_load_insn = 0;
		end
		else if (i_instr[6-:7] == 7'b0001111) begin
			o_alu_a_mux_sel = 2'd0;
			o_alu_b_mux_sel = 3'd0;
			o_alu_op = 3'd0;
			o_trap = 0;
			o_rf_we = 0;
			o_sub = 0;
			o_branch = 0;
			o_jump = 0;
			o_mem_we = 0;
			o_load_insn = 0;
		end
		else if (i_instr[6-:7] == 7'b1110011) begin
			o_alu_a_mux_sel = 2'd0;
			o_alu_b_mux_sel = 3'd0;
			o_alu_op = 3'd0;
			o_trap = 0;
			o_rf_we = 0;
			o_sub = 0;
			o_branch = 0;
			o_jump = 0;
			o_mem_we = 0;
			o_load_insn = 0;
		end
		else begin
			$display("-- non matched op --");
			o_alu_a_mux_sel = 2'd0;
			o_alu_b_mux_sel = 3'd0;
			o_alu_op = 3'd0;
			o_trap = 1;
			o_rf_we = 0;
			o_sub = 0;
			o_branch = 0;
			o_jump = 0;
			o_mem_we = 0;
			o_load_insn = 0;
		end
	end
	initial _sv2v_0 = 0;
endmodule
module hippomenes_veryl_HippoTop (
	clk_i,
	rst_i,
	rvfi_valid,
	rvfi_order,
	rvfi_insn,
	rvfi_trap,
	rvfi_halt,
	rvfi_intr,
	rvfi_mode,
	rvfi_ixl,
	rvfi_rs1_addr,
	rvfi_rs2_addr,
	rvfi_rs1_rdata,
	rvfi_rs2_rdata,
	rvfi_rd_addr,
	rvfi_rd_wdata,
	rvfi_pc_rdata,
	rvfi_pc_wdata,
	rvfi_mem_addr,
	rvfi_mem_rmask,
	rvfi_mem_wmask,
	rvfi_mem_rdata,
	rvfi_mem_wdata
);
	reg _sv2v_0;
	parameter [31:0] IMemAddrWidth = 5;
	parameter [IMemAddrWidth - 1:0] IMemStartAddr = 0;
	parameter [31:0] IMemMaxAddr = IMemAddrWidth ** 2;
	input wire clk_i;
	input wire rst_i;
	output reg rvfi_valid;
	output reg [63:0] rvfi_order;
	output reg [31:0] rvfi_insn;
	output reg rvfi_trap;
	output reg rvfi_halt;
	output reg rvfi_intr;
	output reg [1:0] rvfi_mode;
	output reg [1:0] rvfi_ixl;
	output reg [4:0] rvfi_rs1_addr;
	output reg [4:0] rvfi_rs2_addr;
	output reg [31:0] rvfi_rs1_rdata;
	output reg [31:0] rvfi_rs2_rdata;
	output reg [4:0] rvfi_rd_addr;
	output reg [31:0] rvfi_rd_wdata;
	output reg [31:0] rvfi_pc_rdata;
	output reg [31:0] rvfi_pc_wdata;
	output reg [31:0] rvfi_mem_addr;
	output reg [3:0] rvfi_mem_rmask;
	output reg [3:0] rvfi_mem_wmask;
	output reg [3:0] rvfi_mem_rdata;
	output reg [3:0] rvfi_mem_wdata;
	reg [31:0] pc;
	reg [31:0] pc_next;
	reg take_branch;
	reg misaligned_trap;
	wire take_jump;
	reg [31:0] pc_plus4;
	always @(*) begin
		if (_sv2v_0)
			;
		pc_plus4 = pc + 4;
	end
	always @(posedge clk_i or negedge rst_i)
		if (!rst_i)
			pc <= IMemStartAddr;
		else
			pc <= pc_next;
	wire [31:0] alu_res;
	wire jump_insn;
	always @(*) begin
		if (_sv2v_0)
			;
		if (!take_branch && !jump_insn) begin
			pc_next = pc_plus4;
			misaligned_trap = (pc_next[1:0] != 0 ? 1 : 0);
		end
		else if (take_branch) begin
			pc_next = alu_res;
			misaligned_trap = (alu_res[1:0] != 0 ? 1 : 0);
		end
		else begin
			pc_next = alu_res;
			misaligned_trap = (alu_res[1:0] != 0 ? 1 : 0);
		end
	end
	wire branch_insn;
	wire [2:0] funct3;
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;
	always @(*) begin
		if (_sv2v_0)
			;
		if (branch_insn) begin : sv2v_autoblock_1
			reg equal;
			reg ge;
			reg geu;
			equal = rs1_data == rs2_data;
			ge = rs1_data >= rs2_data;
			geu = $unsigned(rs1_data) >= $unsigned(rs2_data);
			if (funct3 == 3'b000)
				take_branch = equal;
			else if (funct3 == 3'b001)
				take_branch = ~equal;
			else if (funct3 == 3'b100)
				take_branch = ~ge;
			else if (funct3 == 3'b101)
				take_branch = ge;
			else if (funct3 == 3'b110)
				take_branch = ~geu;
			else if (funct3 == 3'b111)
				take_branch = geu;
			else
				take_branch = 0;
		end
		else
			take_branch = 0;
	end
	wire [31:0] instruction;
	function automatic [IMemAddrWidth - 1:0] sv2v_cast_AAFF1;
		input reg [IMemAddrWidth - 1:0] inp;
		sv2v_cast_AAFF1 = inp;
	endfunction
	hippo_memory___Memory__32 #(
		.Depth(IMemAddrWidth ** 2),
		.Writeable(1'b0)
	) instruction_memory(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.address_i(sv2v_cast_AAFF1(pc)),
		.we_i(0),
		.data_i(0),
		.data_o(instruction)
	);
	wire [31:0] immediate;
	wire [11:0] csr_addr;
	wire csr_enable;
	wire [4:0] regfile_rs1;
	wire [4:0] regfile_rs2;
	wire [4:0] regfile_rd;
	wire [1:0] alu_a_mux_sel;
	wire [2:0] alu_b_mux_sel;
	wire [2:0] alu_op;
	wire decoder_trap;
	wire alu_sub_arith;
	wire rf_we;
	wire [2:0] mem_width;
	wire mem_we;
	wire load_insn;
	hippo_decoder_Decoder decoder(
		.i_instr(instruction),
		.o_imm(immediate),
		.o_csr_addr(csr_addr),
		.o_rs1(regfile_rs1),
		.o_rs2(regfile_rs2),
		.o_rd(regfile_rd),
		.o_alu_a_mux_sel(alu_a_mux_sel),
		.o_alu_b_mux_sel(alu_b_mux_sel),
		.o_alu_op(alu_op),
		.o_sub(alu_sub_arith),
		.o_csr_enable(csr_enable),
		.o_trap(decoder_trap),
		.o_rf_we(rf_we),
		.o_funct3(funct3),
		.o_branch(branch_insn),
		.o_jump(jump_insn),
		.o_mem_width(mem_width),
		.o_mem_we(mem_we),
		.o_load_insn(load_insn)
	);
	reg [31:0] rf_wb_data;
	localparam [31:0] veryl_stacked_regfile_RegFilePkg_GlobalMaskIABI = 32'b11111111111111111111111111100110;
	localparam [31:0] veryl_stacked_regfile_RegFilePkg_StackMaskIABI = 32'b11110000000000111111110011100000;
	veryl_stacked_regfile_RegFileStack #(
		.Depth(1),
		.mask(veryl_stacked_regfile_RegFilePkg_GlobalMaskIABI),
		.stack_mask(veryl_stacked_regfile_RegFilePkg_StackMaskIABI)
	) reg_file_stack(
		.i_clk(clk_i),
		.i_reset(rst_i),
		.i_command(2'd0),
		.i_a_addr(regfile_rs1),
		.i_b_addr(regfile_rs2),
		.i_w_ena(rf_we),
		.i_w_addr(regfile_rd),
		.i_w_data(rf_wb_data),
		.o_a_data(rs1_data),
		.o_b_data(rs2_data)
	);
	reg [31:0] alu_a;
	always @(*) begin
		if (_sv2v_0)
			;
		if (alu_a_mux_sel == 2'b01)
			alu_a = rs1_data;
		else if (alu_a_mux_sel == 2'b00)
			alu_a = immediate;
		else
			alu_a = 0;
	end
	reg [31:0] alu_b;
	always @(*) begin
		if (_sv2v_0)
			;
		if (alu_b_mux_sel == 3'd0)
			alu_b = rs2_data;
		else if (alu_b_mux_sel == 3'd1)
			alu_b = immediate;
		else if (alu_b_mux_sel == 3'd3)
			alu_b = pc;
		else
			alu_b = 0;
	end
	hippo_alu_veryl_HippoALU alu(
		.a(alu_a),
		.b(alu_b),
		.sub_arith(alu_sub_arith),
		.op(alu_op),
		.res(alu_res)
	);
	wire [31:0] dmem_data;
	reg [3:0] mem_mask;
	always @(*) begin
		if (_sv2v_0)
			;
		mem_mask = ((mem_width == 0) == 1'b1 ? 4'b0001 : ((mem_width == 1) == 1'b1 ? 4'b0011 : ((mem_width == 2) == 1'b1 ? 4'b1111 : 4'b0000)));
	end
	hippo_memory_InterleavedMemory data_memory(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.width_i(mem_mask),
		.sign_extend_i(0),
		.addr_i(alu_res),
		.data_i(rs2_data),
		.we_i(mem_we),
		.data_o(dmem_data)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		rf_wb_data = (regfile_rd != 0 ? (jump_insn ? pc_plus4 : (load_insn ? dmem_data : alu_res)) : 32'sd0);
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_mem_addr = alu_res;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_mem_rmask = 4'b1111;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_mem_wmask = (mem_we ? mem_mask : 4'b0000);
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_mem_rdata = dmem_data;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_mem_wdata = rs2_data;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_valid = ~decoder_trap && ~misaligned_trap;
	end
	always @(posedge clk_i or negedge rst_i)
		if (!rst_i)
			rvfi_order <= 0;
		else
			rvfi_order <= rvfi_order + 1;
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_insn = instruction;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_trap = decoder_trap | misaligned_trap;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_halt = (pc == IMemMaxAddr ? 1 : 0);
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_intr = 0;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_mode = 3;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_ixl = 1;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_rs1_addr = regfile_rs1;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_rs2_addr = regfile_rs2;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_rs1_rdata = rs1_data;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_rs2_rdata = rs2_data;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_rd_addr = (!rf_we ? 0 : regfile_rd);
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_rd_wdata = (!rf_we ? 0 : rf_wb_data);
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_pc_rdata = pc;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rvfi_pc_wdata = pc_next;
	end
	initial _sv2v_0 = 0;
endmodule
