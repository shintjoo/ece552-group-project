onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/clk
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/rst_n
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/hlt
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/pc
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/RegWrite
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MemRead
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MemWrite
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/Branch
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MemtoReg
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ALUSrc
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/pcs_select
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/hlt_select
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ALUSrc8bit
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/LoadByte
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/BranchReg
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/Flush
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/IF_pc_out
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/IF_instruction
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/IF_pc_increment
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/IF_pc_choose
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_instruction
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_instruction_or_nop
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_pc_increment
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_pc_branch
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_reg_datain
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_dataout1
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_dataout2
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/Opcode
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_rs
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_rd
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_rt
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/imm8bit
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/imm9bit
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/sextimm
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ccc
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/reg1
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/reg2
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/Stall
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/RegWrite_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MemtoReg_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/pcs_select_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MemRead_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MemWrite_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ALUSrc_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ALUSrc8bit_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/hlt_select_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_dataout1_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_dataout2_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/sextimm_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_rs_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_rt_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ID_rd_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/Opcode_NOP
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_dataout1
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_dataout2
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_sextimm
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_rs
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_rd
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_rt
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_ALUop
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_ALUSrc
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_ALUSrc8bit
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_MemRead
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_MemWrite
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_pcs_select
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_MemtoReg
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_RegWrite
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_hlt_select
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/Flags
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/aluin2
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_aluout
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ALUFwdIn1
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ALUFwdIn2
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ALUFwdReg
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/EX_pc_increment
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/destReg
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ALUFwd1
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/ALUFwd2
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_aluout
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_dmem_in
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_destReg
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_mem_out
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEMFwdIn
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_pc_increment
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_MemRead
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_MemWrite
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_pcs_select
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_MemtoReg
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_RegWrite
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEM_hlt_select
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/MEMFwd
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/WB_mem_out
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/WB_aluout
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/WB_pc_increment
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/WB_destReg
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/WB_pcs_select
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/WB_MemtoReg
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/WB_RegWrite
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/WB_hlt_select
add wave -noupdate -radix hexadecimal /cpu_ptb/DUT/error
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2057 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2 ns}
