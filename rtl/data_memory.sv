// --------------------------------------------------------
// Data Memory - RTL (Refined, Parameterized)
// --------------------------------------------------------

import risc_pkg::*;

module data_memory #(
  parameter ADDR_WIDTH = 6,  // 2^6 = 64
  parameter DATA_WIDTH = 8    // Byte-wide RAM
)(
  input logic 				  clk,
  input  logic                dmem_req,                 
  input  logic                dmem_wr_en,               
  input mem_size_t		      dmem_data_size,           
  input  logic [31:0]         dmem_addr,                
  input  logic [31:0]         dmem_wr_data,             
  input  logic                dmem_zero_extend,         

  output logic [31:0]         dmem_rd_data              
);

  // --------------------------------------------------------
  // RAM Declaration
  // --------------------------------------------------------
  logic [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];
 
  // --------------------------------------------------------
  // Write Logic - Store
  // --------------------------------------------------------

  always_ff @(posedge clk) begin
    if (dmem_req && dmem_wr_en) begin
      case (dmem_data_size)
        BYTE:       mem[dmem_addr] <= dmem_wr_data[7:0];                                   // SB
        HALF_WORD:  {mem[dmem_addr+1], mem[dmem_addr]} <= dmem_wr_data[15:0];               // SH
        WORD:       {mem[dmem_addr+3], mem[dmem_addr+2], mem[dmem_addr+1], mem[dmem_addr]} <= dmem_wr_data; // SW
      endcase
    end
  end

  // --------------------------------------------------------
  // Read Logic - Load
  // --------------------------------------------------------

  always_comb begin
    if (dmem_req && !dmem_wr_en) begin
      case (dmem_data_size)
        BYTE:       dmem_rd_data = dmem_zero_extend ?
                    {{24{1'b0}}, mem[dmem_addr]} :                                          // LBU
                    {{24{mem[dmem_addr][7]}}, mem[dmem_addr]};                              // LB

        HALF_WORD:  dmem_rd_data = dmem_zero_extend ?
                    {{16{1'b0}}, mem[dmem_addr+1], mem[dmem_addr]} :                        // LHU
                    {{16{mem[dmem_addr+1][7]}}, mem[dmem_addr+1], mem[dmem_addr]};          // LH

        WORD:       dmem_rd_data = {mem[dmem_addr+3], mem[dmem_addr+2], mem[dmem_addr+1], mem[dmem_addr]}; // LW
      endcase
    end else begin
      dmem_rd_data = 32'd0;
    end
  end


endmodule
