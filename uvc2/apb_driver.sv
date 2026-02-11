class apb_drv extends uvm_driver;
  `uvm_component_utils(apb_drv)
  
  // Virtual interface and configuration object
  virtual apb_if vif;
  apb_config cfg;
  
  // Constructor
  function new(input string path = "apb_drv", uvm_component parent);
    super.new(path, parent);
  endfunction
  
  // Build phase: fetch virtual interface and configuration
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif1", vif)) begin
      `uvm_fatal("NOVIF", "APB vif not set")
    end

    if(!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg)) begin
      `uvm_fatal("NOCFG", "APB slave cfg not set")
    end
  endfunction

  // Run phase: simulate APB slave behavior
  virtual task run_phase(uvm_phase phase);
    // Initialize APB interface signals
    vif.PREADY <= 0;
    vif.PRDATA <= 0;
    
    forever begin
      @(posedge vif.PCLK);
      
      if(!vif.PRESET) begin
        vif.PREADY <= 0;
        vif.PRDATA <= 0;
      end
      
      // Check for valid APB transfer
      if(vif.PTRANSFER) begin
        vif.PREADY <= 1;
        
        if(vif.PWRITE) begin
          // WRITE operation
          if(cfg.en_mem)
            cfg.mem[vif.PADDR] <= vif.PWDATA;
        end
        else begin
          // READ operation
          if(cfg.en_mem)
            vif.PRDATA <= cfg.mem[vif.PADDR];
          else 
            vif.PRDATA <= $urandom;
        end
        
        @(posedge vif.PCLK);
        vif.PREADY <= 0; 
      end
    end
  endtask 
endclass

