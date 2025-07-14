# Hippo-Formal
This repo shows a minimal formal verification flow for the Veryl reimplementation of Hippomenes.

## Prerequisites
- [Yosys OSS Suite](https://yosyshq.readthedocs.io/projects/sby/en/latest/install.html), also install Boolector as listed on the page.
- [Veryl](https://veryl-lang.org/install/) for transpiling Hippomenes to SystemVerilog.
- [sv2v](https://github.com/zachjs/sv2v) for transpiling the SystemVerilog to Verilog.

### Install Notes
On Arch at least, Boolector cannot be built with the packaged GCC (15.1.1 as of writing). I've personally gotten around this by `downgrade`, i.e. `yay -S downgrade` `sudo downgrade gcc` down to GCC 14.2.1.

Also for Arch, `sv2v` provided by AUR, i.e. `yay -S sv2v` is sufficient, and probably less messy for setting up since Haskell and Arch don't seem to play nice.

## Contents
- `./hippo_veryl/` The Veryl implementation of Hippomenes. This is pending an actual release, i.e. this directory will eventually disappear in favor of
actual, released, Veryl packages.
- `checks.cfg` contains configuration for the checks we want to run. For more details refer to comments in that file.
- `copy.py` convenience script for copying the Veryl-SV transpilation results into `./hippo`. Relies on the Veryl filelist existing in this directory (`hippomenes_veryl.f`). Should probably not be used standalone.
- `redo.sh` convenience script for cleaning up this directory, running `copy.py`, generating the `riscv-formal` checks specified by `checks.cfg`, and transpiling the Hippo SV into Verilog.
- `failing_tests.py` can be ran after running verification to get an overview of the passing/failing checks.
- `wrapper.sv` contains a simple RVFI wrapper.

## Typical workflow

```
cd hippo_veryl/hippomenes_veryl
veryl build
```
Transpiles the included Hippomenes Veryl implementation into SystemVerilog. It also generates a filelist, we will need this now.

```
cd ../..
cp <HIPPO_PATH>/hippomenes_veryl.f 
```

To copy the Veryl filelist into this directory.

```
./redo.sh 
```

To copy the Hippomenes SV into `./hippo`, transpile it into Verilog, and generate checks according to `checks.cfg`

```
make -C checks -j$(nproc)
```

Runs the formal verification.
Once that is finished

```
python failing_tests.py
```

lists the passing/failing checks.

