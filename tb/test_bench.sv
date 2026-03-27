module test_bench();
  logic clk;
  logic reset_n;
  integer cycle_count = 0;  
  // Clk
  always #5 clk = ~clk;  

  top #(.RESET_PC(32'h0)) dut (
    .clk(clk),
    .reset_n(reset_n)
  );

  always @(posedge clk) begin
    cycle_count <= cycle_count + 1;
    if (cycle_count == 200) begin
      $finish;
    end
  end

  // initialization
  initial begin
    clk = 0;           
    reset_n = 0;       
    
    // reset 
    #10 reset_n = 1;   
  end
endmodule
