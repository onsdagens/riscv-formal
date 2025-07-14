module rvfi_wrapper (
    input clock,
    input reset,
    `RVFI_OUTPUTS
);
  hippomenes_veryl_HippoTop #() uut (
      .clk_i(clock),
      .rst_i(~reset),

      `RVFI_CONN
  );
endmodule
