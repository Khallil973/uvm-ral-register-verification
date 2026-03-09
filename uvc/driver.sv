//Driver 

class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)

  transaction tr;
  virtual top_if vif;

  function new(input string path = "driver", uvm_component parent = null);
    super.new(path,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    if(!uvm_config_db#(virtual top_if)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
      `uvm_error("drv","Unable to access Interface");
  endfunction
  
  ///////////////reset DUT at the start
  task reset_dut();
    @(posedge vif.clk);
    vif.rst  <= 1'b1;
    vif.wr   <= 1'b0;
    vif.din  <= 8'h00;
    vif.addr <= 1'b0;
    repeat(5)@(posedge vif.clk);
    `uvm_info("DRV", "System Reset", UVM_NONE);
    vif.rst  <= 1'b0;
  endtask
  
  //////////////drive DUT
  
  task drive_dut();
    //@(posedge tif.clk);
    vif.rst  <= 1'b0;
    vif.wr   <= tr.wr;
    vif.addr <= tr.addr;
    if(tr.wr == 1'b1)
       begin
          vif.din <= tr.din;
         `uvm_info("DRV", $sformatf("Data Write -> Wdata : %0d",tr.din), UVM_NONE);
         repeat(3) @(posedge vif.clk);
             end
      else begin  
         repeat(2) @(posedge vif.clk);
         `uvm_info("DRV", $sformatf("Data Read -> Rdata : %0d",vif.dout), UVM_NONE);
           tr.dout = vif.dout;
         @(posedge vif.clk);
       end    
  endtask
  
  
  
  ///////////////Driver task
  
   virtual task run_phase(uvm_phase phase);
      tr = transaction::type_id::create("tr");
     forever begin
        seq_item_port.get_next_item(tr);
        drive_dut();
        seq_item_port.item_done();  
      end
   endtask

endclass
