// src/regfile_pkg.veryl

package veryl_stacked_regfile_RegFilePkg;

    typedef enum logic [2-1:0] {
        Command_none, //= 0, // normal operation
        Command_push, //= 1, // interrupt/trap entry
        Command_pop //= 2, // interrupt/trap exit
    } Command;

    localparam logic [32-1:0] GlobalMaskEABI = {
        1'b0, // x31 t6
        1'b0, // x30 t5
        1'b0, // x29 t4
        1'b0, // x28 t3

        1'b0, // x27 s11
        1'b0, // x26 s10
        1'b0, // x25 s9
        1'b0, // x24 s8
        1'b0, // x23 s7
        1'b0, // x22 s6
        1'b0, // x21 s5
        1'b0, // x20 s4
        1'b0, // x19 s3
        1'b0, // x18 s2

        1'b0, // x17 a7
        1'b0, // x16 a6
        1'b1, // x15 a5
        1'b1, // x14 a4
        1'b1, // x13 a3
        1'b1, // x12 a2
        1'b1, // x11 a1
        1'b1, // x10 a0

        1'b1, // x9  s1
        1'b1, // x8  s0

        1'b1, // x7  t2
        1'b1, // x6  t1
        1'b1, // x5  t0

        1'b0, // x4  tp
        1'b0, // x3  gp
        1'b1, // x2  sp
        1'b1, // x1  ra
        1'b0
    };

    localparam logic [32-1:0] StackMaskEABI = {
        1'b0, // x31 t6
        1'b0, // x30 t5
        1'b0, // x29 t4
        1'b0, // x28 t3

        1'b0, // x27 s11
        1'b0, // x26 s10
        1'b0, // x25 s9
        1'b0, // x24 s8
        1'b0, // x23 s7
        1'b0, // x22 s6
        1'b0, // x21 s5
        1'b0, // x20 s4
        1'b0, // x19 s3
        1'b0, // x18 s2

        1'b0, // x17 a7
        1'b0, // x16 a6
        1'b1, // x15 a5
        1'b1, // x14 a4
        1'b1, // x13 a3
        1'b1, // x12 a2
        1'b1, // x11 a1
        1'b1, // x10 a0

        1'b0, // x9  s1
        1'b0, // x8  s0

        1'b1, // x7  t2
        1'b1, // x6  t1
        1'b1, // x5  t0

        1'b0, // x4  tp
        1'b0, // x3  gp
        1'b0, // x2  sp
        1'b0, // x1  ra
        1'b0
    };

    localparam logic [32-1:0] GlobalMaskIABI = {
        1'b1, // x31 t6
        1'b1, // x30 t5
        1'b1, // x29 t4
        1'b1, // x28 t3

        1'b1, // x27 s11
        1'b1, // x26 s10
        1'b1, // x25 s9
        1'b1, // x24 s8
        1'b1, // x23 s7
        1'b1, // x22 s6
        1'b1, // x21 s5
        1'b1, // x20 s4
        1'b1, // x19 s3
        1'b1, // x18 s2

        1'b1, // x17 a7
        1'b1, // x16 a6
        1'b1, // x15 a5
        1'b1, // x14 a4
        1'b1, // x13 a3
        1'b1, // x12 a2
        1'b1, // x11 a1
        1'b1, // x10 a0

        1'b1, // x9  s1
        1'b1, // x8  s0

        1'b1, // x7  t2
        1'b1, // x6  t1
        1'b1, // x5  t0

        1'b0, // x4  tp
        1'b0, // x3  gp
        1'b1, // x2  sp
        1'b1, // x1  ra
        1'b0
    };

    localparam logic [32-1:0] StackMaskIABI = {
        1'b1, // x31 t6
        1'b1, // x30 t5
        1'b1, // x29 t4
        1'b1, // x28 t3

        1'b0, // x27 s11
        1'b0, // x26 s10
        1'b0, // x25 s9
        1'b0, // x24 s8
        1'b0, // x23 s7
        1'b0, // x22 s6
        1'b0, // x21 s5
        1'b0, // x20 s4
        1'b0, // x19 s3
        1'b0, // x18 s2

        1'b1, // x17 a7
        1'b1, // x16 a6
        1'b1, // x15 a5
        1'b1, // x14 a4
        1'b1, // x13 a3
        1'b1, // x12 a2
        1'b1, // x11 a1
        1'b1, // x10 a0

        1'b0, // x9  s1
        1'b0, // x8  s0

        1'b1, // x7  t2
        1'b1, // x6  t1
        1'b1, // x5  t0

        1'b0, // x4  tp
        1'b0, // x3  gp
        1'b0, // x2  sp
        1'b0, // x1  ra
        1'b0
    };

endpackage
//# sourceMappingURL=regfile_pkg.sv.map
