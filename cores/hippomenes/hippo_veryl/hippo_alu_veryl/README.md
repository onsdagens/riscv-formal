# Hippomenes ALU

This project implements a simple ALU for the Hippomenes RV32I core.

## Testing

### Dependencies

- [Veryl](https://veryl-lang.org/) for transpiling Veryl to SystemVerilog.
- [Verilator](https://www.veripool.org/verilator/) for running simulation.
- [Surfer](https://surfer-project.org/) for inspecting waveform.

### Running tests

```
veryl test --wave --verbose
```

runs the included test bench in `src/test_bench.veryl`, and outputs a waveform trace `src/alu.vcd`. The `--verbose` flag is required for meaningful output from Verilator (for instance when dealing with an error).