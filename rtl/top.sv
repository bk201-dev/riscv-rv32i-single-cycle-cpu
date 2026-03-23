
// --------------------------------------------------------
// Top-Level RISC-V Processor (Single-Cycle)
// --------------------------------------------------------
import risc_pkg::*;

module top #(
  parameter RESET_PC = 32'h0000
)(
  input logic clk,
  input logic reset_n
);

// ---------------------------------------------------------------
// Instruction Memory Interface
// ---------------------------------------------------------------
logic        imem_req;
logic [31:0] imem_addr;
logic [31:0] imem_data;

// ---------------------------------------------------------------
// Data Memory Interface
// ---------------------------------------------------------------
logic        dmem_req;
logic        dmem_wr_en;
mem_size_t  dmem_size;
logic        dmem_zero_extend;
logic [31:0] dmem_addr;
logic [31:0] dmem_wr_data;
logic [31:0] dmem_rd_data;

// -----------------------------------------------------------------------------
// Core Datapath Signals
// -----------------------------------------------------------------------------
logic [31:0] pc, next_pc, next_seq_pc;
logic        pc_sel, reset_seen;

logic [31:0] instruction;
logic [6:0]  opcode;
logic [2:0]  funct3;
logic [6:0]  funct7;

logic [4:0]  rs1_addr, rs2_addr, rd_addr;
logic [31:0] rs1_data, rs2_data, wr_data;
logic [31:0] immediate;

logic        r_type, i_type, s_type, b_type, u_type, j_type;
logic [31:0] alu_a, alu_b, alu_res;
alu_op_t     alu_op;

wb_src_t     rf_wr_data_sel;
logic        rf_wr_en;
logic        op1_sel, op2_sel;
logic        branch_taken;

// -----------------------------------------------------------------------------
// Reset and PC logic
// -----------------------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        reset_seen <= 1'b0;
    else
        reset_seen <= 1'b1;
end

assign next_seq_pc = pc + 32'd4;
assign next_pc = (branch_taken | pc_sel) ? {alu_res[31:1], 1'b0} : next_seq_pc;

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        pc <= RESET_PC;
    else if (reset_seen)
        pc <= next_pc;
end

// -----------------------------------------------------------------------------
// Instruction Memory
// -----------------------------------------------------------------------------
instruction_memory u_instruction_memory (
    .imem_req   (imem_req),
    .imem_addr  (imem_addr),
    .imem_data  (imem_data)
);

// -----------------------------------------------------------------------------
// Fetch
// -----------------------------------------------------------------------------
fetch u_fetch (
    .clk         (clk),
    .reset_n     (reset_n),
    .pc          (pc),
    .imem_req    (imem_req),
    .imem_addr   (imem_addr),
    .imem_data   (imem_data),
    .instruction (instruction)
);

// ---------------------------------------------------------------
// Decode
// ---------------------------------------------------------------
decode u_decode (
    .instruction (instruction),
    .rs1_addr    (rs1_addr),
    .rs2_addr    (rs2_addr),
    .rd_addr     (rd_addr),
    .opcode      (opcode),
    .funct3      (funct3),
    .funct7      (funct7),
    .r_type      (r_type),
    .i_type      (i_type),
    .s_type      (s_type),
    .b_type      (b_type),
    .u_type      (u_type),
    .j_type      (j_type),
    .immediate   (immediate)
);

// ------------------------------------------------------------
// Register File
// ------------------------------------------------------------
always_comb begin
    case (rf_wr_data_sel)
        WB_SRC_ALU: wr_data = alu_res;
        WB_SRC_MEM: wr_data = dmem_rd_data;
        WB_SRC_IMM: wr_data = immediate;
        WB_SRC_PC : wr_data = next_seq_pc;
    endcase
end

register_file u_register_file (
    .clk        (clk),
    .reset_n    (reset_n),
    .rs1_addr   (rs1_addr),
    .rs2_addr   (rs2_addr),
    .rd_addr    (rd_addr),
    .rf_wr_en   (rf_wr_en),
    .wr_data    (wr_data),
    .rs1_data   (rs1_data),
    .rs2_data   (rs2_data)
);

// ------------------------------------------------------------
// Control Unit
// ------------------------------------------------------------
control u_control (
    .r_type             (r_type),
    .i_type             (i_type),
    .s_type             (s_type),
    .b_type             (b_type),
    .u_type             (u_type),
    .j_type             (j_type),
    .funct3             (funct3),
    .funct7             (funct7),
    .opcode             (opcode),
    .pc_sel             (pc_sel),
    .op1_sel            (op1_sel),
    .op2_sel            (op2_sel),
    .alu_op             (alu_op),
    .rf_wr_data_sel     (rf_wr_data_sel),
    .dmem_req           (dmem_req),
    .dmem_size          (dmem_size),
    .dmem_wr_en         (dmem_wr_en),
    .dmem_zero_extend   (dmem_zero_extend),
    .rf_wr_en           (rf_wr_en)
);

// ------------------------------------------------------------
// Branch Control
// ------------------------------------------------------------
branch_control u_branch_control (
    .opr_a         (rs1_data),
    .opr_b         (rs2_data),
    .is_b_type     (b_type),
    .funct3        (funct3),
    .branch_taken  (branch_taken)
);

// ------------------------------------------------------------
// ALU
// ------------------------------------------------------------
assign alu_a = op1_sel ? pc          : rs1_data;
assign alu_b = op2_sel ? immediate  : rs2_data;

alu u_alu (
    .alu_a    (alu_a),
    .alu_b    (alu_b),
    .alu_op   (alu_op),
    .alu_res  (alu_res)
);

// ------------------------------------------------------------
// Data Memory
// ------------------------------------------------------------
// We dont need to use assign but its easier
// becouse now we give meaning to the Input
assign dmem_addr     = alu_res;
assign dmem_wr_data  = rs2_data;

data_memory u_data_memory (
    .clk               (clk),
    .dmem_req          (dmem_req),
    .dmem_wr_en        (dmem_wr_en),
    .dmem_data_size   (dmem_size),
    .dmem_addr        (dmem_addr),
    .dmem_wr_data     (dmem_wr_data),
    .dmem_zero_extend (dmem_zero_extend),
    .dmem_rd_data     (dmem_rd_data)
);



endmodule
