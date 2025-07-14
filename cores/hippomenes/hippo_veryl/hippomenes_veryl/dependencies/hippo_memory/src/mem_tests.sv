`ifdef __veryl_test_hippomenes_veryl_test_mem__
    `ifdef __veryl_wavedump_hippomenes_veryl_test_mem__
        module __veryl_wavedump;
            initial begin
                $dumpfile("test_mem.vcd");
                $dumpvars();
            end
        endmodule
    `endif

module hippo_memory_InstantiateMemory #() (
    input  var logic                 clk_i    ,
    input  var logic                 rst_i    ,
    input  var logic [$clog2(4)-1:0] address_i,
    input  var logic                 we_i     ,
    input  var logic [32-1:0]        data_i   ,
    output var logic [32-1:0]        data_o   
);
    hippo_memory___Memory__32 #(
        .Depth (4)
        //   InitFile: "test.mem",
    ) mem (
        .clk_i     (clk_i    ),
        .rst_i     (rst_i    ),
        .address_i (address_i),
        .we_i      (we_i     ),
        .data_i    (data_i   ),
        .data_o    (data_o   )
    );
endmodule
`ifndef SYNTHESIS
    module test_mem;
        logic clk;
        logic rst;
        logic[$clog2(4)-1:0] address;
        logic we;
        logic[31:0] data_i;
        logic[31:0] data_o;        
        hippo_memory___Memory__32 #(
            .Depth(4),
         //   .InitFile("test.mem"),
            .Writeable(1)
        ) mem_dut(
            .clk_i(clk),
            .rst_i(rst),
            .address_i(address),
            .we_i(we),
            .data_i(data_i),
            .data_o(data_o)
        );
        initial begin
            rst = 0;
            clk = 0;
            we = 0;
            address = 0;
            data_i = 0;
            #15 rst = 1;
        end
        always #10 clk = ~clk;

        initial begin
            #40;
            assert(data_o == 'hDEADBEEF);
            #20; 
            $finish;
        end
    endmodule
`endif
`endif
//# sourceMappingURL=mem_tests.sv.map
