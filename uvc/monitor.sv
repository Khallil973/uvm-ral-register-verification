//Monitor 
      
class monitor extends uvm_monitor;
    `uvm_component_utils( monitor )

    uvm_analysis_port   #(transaction)  mon_ap;
    virtual     top_if              vif;
    transaction tr;
    
    function new(string name="my_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction : new
  
    virtual function void build_phase(uvm_phase phase);
        super.build_phase (phase);
        mon_ap = new("mon_ap", this);
      if(! uvm_config_db#(virtual top_if)::get (this, "", "vif", vif))
        `uvm_error("MON", "Error getting Interface Handle")
    endfunction : build_phase
  
    virtual task run_phase(uvm_phase phase);
     tr = transaction::type_id::create("tr");
            forever begin
              repeat(3) @(posedge vif.clk);
                  tr.wr    = vif.wr;
                  tr.addr  = vif.addr;
                  tr.din   = vif.din;
                  tr.dout  = vif.dout;
                  `uvm_info("MON", $sformatf("Wr :%0b  Addr : %0d Din:%0d  Dout:%0d", tr.wr, tr.addr, tr.din, tr.dout), UVM_NONE)         
                  mon_ap.write(tr);
               
                end 
    endtask 

      
endclass
      