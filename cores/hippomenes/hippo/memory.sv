// Really this may be generic over the address and data TYPES
// For interleaved memory (allowing unaligned access), you would combine 4
// of these into one top level memory module, TODO
module hippo_memory___Memory__32 #(
    parameter int unsigned Depth     = 1024 / 4     ,
    parameter int unsigned AddrWidth = $clog2(Depth),
    parameter logic        Writeable = 1'b0     
    // param InitFile : string = ""           ,
) (
    input  var logic                 clk_i    ,
    input  var logic                 rst_i    ,
    input  var logic [AddrWidth-1:0] address_i,
    input  var logic                 we_i     ,
    input  var logic [32-1:0]         data_i   ,
    output var logic [32-1:0]         data_o   
);
    logic [32-1:0] memory [0:Depth-1];
    always_ff @ (posedge clk_i, negedge rst_i) begin
        if (!rst_i) begin
            // if there is no InitFile, this is defined to initialize to 0's.
            //         $readmemh(InitFile, memory);
            data_o <= '0;
        end else begin
            if (we_i) begin
                memory[address_i] <= data_i;
            end else begin
                data_o <= memory[address_i];
            end
        end
    end
endmodule
module hippo_memory___Memory__8 #(
    parameter int unsigned Depth     = 1024 / 4     ,
    parameter int unsigned AddrWidth = $clog2(Depth),
    parameter logic        Writeable = 1'b0     
    // param InitFile : string = ""           ,
) (
    input  var logic                 clk_i    ,
    input  var logic                 rst_i    ,
    input  var logic [AddrWidth-1:0] address_i,
    input  var logic                 we_i     ,
    input  var logic [8-1:0]         data_i   ,
    output var logic [8-1:0]         data_o   
);
    logic [8-1:0] memory [0:Depth-1];
    always_ff @ (posedge clk_i, negedge rst_i) begin
        if (!rst_i) begin
            // if there is no InitFile, this is defined to initialize to 0's.
            //         $readmemh(InitFile, memory);
            data_o <= '0;
        end else begin
            if (we_i) begin
                memory[address_i] <= data_i;
            end else begin
                data_o <= memory[address_i];
            end
        end
    end
endmodule
//# sourceMappingURL=memory.sv.map
