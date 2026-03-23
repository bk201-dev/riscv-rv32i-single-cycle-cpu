// --------------------------------------------------------
// Fetch - RTL (Refined)
// --------------------------------------------------------

module fetch (
  input  logic         clk,
  input  logic         reset_n,

  input  logic [31:0]  pc,               // Program Counter input

  output logic         imem_req,    // Instruction memory request
  output logic [31:0]  imem_addr,   // Address to instruction memory

  input  logic [31:0]  imem_data,        // Data read from memory
  output logic [31:0]  instruction       // Decoded instruction
);
   logic req_reg;

   always_ff @(posedge clk or negedge reset_n) begin
  if (!reset_n)
    req_reg <= 1'b0;
  else
    req_reg <= 1'b1;
end

  assign imem_req = req_reg;
  assign imem_addr = pc;
  assign instruction = imem_data;

endmodule


