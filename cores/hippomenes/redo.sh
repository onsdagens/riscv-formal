rm -rf hippo
rm -rf checks
python copy.py
cd hippo
sv2v alu_pkg.sv config_pkg.sv decoder_pkg.sv regfile_pkg.sv alu.sv  regfile_instance.sv regfile_stack.sv memory.sv decoder.sv hippo_top.sv > hippo.v
cd ..
python3 ../../checks/genchecks.py
