
module tb;
  
    
  top_if vif();
    
  top dut (vif.clk, vif.rst, vif.wr, vif.addr, vif.din, vif.dout);

  
  initial begin
   vif.clk <= 0;
  end

  always #10 vif.clk = ~vif.clk;

  
  
  initial begin
    uvm_config_db#(virtual top_if)::set(null, "*", "vif", vif);
    
    uvm_config_db#(int)::set(null,"*","include_coverage", 0);

    run_test("test");
   end
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  
endmodule
