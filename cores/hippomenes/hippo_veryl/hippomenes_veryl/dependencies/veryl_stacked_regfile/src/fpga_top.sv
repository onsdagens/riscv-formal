// top module for synthesis tests
// stops optimization
module veryl_stacked_regfile_FPGATop (
    input  var logic rst ,
    input  var logic btn0,
    input  var logic btn1,
    input  var logic btn2,
    input  var logic btn3,
    output var logic led0,
    output var logic led1,
    output var logic led2,
    output var logic led3
);
    logic clk;

    OSC_TOP osc (
        .clk (clk)
    );

    logic [5-1:0]  a_addr  ;
    logic [5-1:0]  b_addr  ;
    logic [5-1:0]  w_addr  ;
    logic [32-1:0] w_data  ;
    logic          w_ena   ;
    logic [2-1:0]  command ;
    logic [32-1:0] r_a_data;
    logic [32-1:0] r_b_data;
    veryl_stacked_regfile_RegFileStack regfile (
        .i_clk     (clk     ),
        .i_reset   (rst     ),
        .i_command (command ),
        .i_a_addr  (a_addr  ),
        .i_b_addr  (b_addr  ),
        .i_w_ena   (w_ena   ),
        .i_w_addr  (w_addr  ),
        .i_w_data  (w_data  ),
        .o_a_data  (r_a_data),
        .o_b_data  (r_b_data)
    );

    logic [32-1:0] counter  ; // source of "non-determinism"
    logic [5-1:0]  state    ;
    logic [3-1:0]  viewstate;
    always_ff @ (posedge clk, negedge rst) begin
        if (!rst) begin
            counter   <= 0;
            a_addr    <= 0;
            b_addr    <= 0;
            w_addr    <= 0;
            w_data    <= 0;
            w_ena     <= 0;
            command   <= 0;
            state     <= 0;
            viewstate <= 0;
            led0      <= 0;
            led1      <= 0;
            led2      <= 0;
            led3      <= 0;
        end else begin
            counter <= counter + (1);
            if (btn0) begin
                state <= state + (1);
            end
            if (state == 0) begin
                a_addr <= counter[4:0];
            end
            if (state == 1) begin
                b_addr <= counter[4:0];
            end
            if (state == 2) begin
                w_addr <= counter[4:0];
            end
            if (state == 3) begin
                w_data <= counter;
            end
            if (state == 4) begin
                w_ena <= counter[0];
            end
            if (state == 5) begin
                command <= counter[1:0];
            end
            if (state == 6) begin
                led0 <= r_a_data[counter[4:0]];
                led1 <= r_b_data[counter[4:0]];
            end
        end
    end
endmodule
//# sourceMappingURL=fpga_top.sv.map
