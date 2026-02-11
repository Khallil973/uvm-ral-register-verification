class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
      
  // Driver, monitor, and configuration object
  apb_drv drv;
  apb_config cfg;
  apb_monitor mon;
      
  // Constructor
  function new(input string path = "apb_agent", uvm_component parent);
    super.new(path, parent);
  endfunction
      
  // Build phase: create driver and monitor, set/get configuration
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = apb_monitor::type_id::create("mon", this);
    drv = apb_drv::type_id::create("drv", this);
    
    // Create or fetch configuration object
    if (!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg)) begin
      cfg = apb_config::type_id::create("cfg");
      uvm_config_db#(apb_config)::set(this, "*", "cfg", cfg);
    end
  endfunction
endclass

