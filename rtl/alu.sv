// --------------------------------------------------------
// ALU - RTL (Refined, no $signed, proper default placement)
// --------------------------------------------------------
import risc_pkg::*;
module alu (
  // Operands
  input  logic [31:0] alu_a,   // ALU input A
  input  logic [31:0] alu_b,   // ALU input B

  // Operation selector
  input  alu_op_t     alu_op,      // ALU operation from risc_pkg

  // Result
  output logic [31:0] alu_res       // ALU output
);

  

// ---------------------------------------------------------------------
// Internal signed versions for arithmetic comparison/shift
// ---------------------------------------------------------------------
logic signed [31:0] signed_a;
logic signed [31:0] signed_b;

assign signed_a = alu_a;
assign signed_b = alu_b;

// --------------------------------------------------------
// ALU operation logic
// --------------------------------------------------------

always_comb begin
    // Default assignment before case to avoid latches
    alu_res = 32'd0;

    case (alu_op)

        ADD  : alu_res = alu_a + alu_b;
        SUB  : alu_res = alu_a - alu_b;

        SLL  : alu_res = alu_a << alu_b[4:0];
        SRL  : alu_res = alu_a >> alu_b[4:0];
        SRA  : alu_res = signed_a >>> alu_b[4:0];   // Arithmetic shift right

        OR   : alu_res = alu_a | alu_b;
        AND  : alu_res = alu_a & alu_b;
        XOR  : alu_res = alu_a ^ alu_b;

        SLTIU : alu_res = (alu_a < alu_b) ? 32'd1 : 32'd0;
        SLT   : alu_res = (signed_a < signed_b) ? 32'd1 : 32'd0;

    endcase
end



endmodule

