// --------------------------------------------------------
// Instruction Memory - RTL (Parameterized)
// --------------------------------------------------------

module instruction_memory #(
	parameter ADDR_WIDTH = 7,                      // Address bits (2^7 = 128 depth)
	parameter DATA_WIDTH = 8                       // Data width per memory cell
)(
  input  logic             imem_req,               // Read enable
  input  logic [31:0]      imem_addr,              // Byte address (word-aligned)
  output logic [31:0]      imem_data               // Output instruction
);

  // --------------------------------------------------------
  // Memory Declaration (ROM)
  // --------------------------------------------------------
  logic [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

  initial begin
	$readmemh("find_maximum_in_array_machine_code.mem", mem); // Initialize ROM with data from memory.list file
  end
  
   always_comb begin
  if (imem_req) begin
    imem_data = {
      mem[imem_addr],
      mem[imem_addr + 1],
      mem[imem_addr + 2],
      mem[imem_addr + 3]
    };
  end else begin
    imem_data = 32'd0;
  end
end


endmodule

