class apb_config extends uvm_object;
  `uvm_object_utils(apb_config)
  
  // Configuration fields
  bit en_mem = 1;                  // Enable memory for APB read/write
  int unsigned mem[1024];          // Memory array for APB slave simulation
  
  // Constructor
  function new(input string path = "apb_config");
    super.new(path);
  endfunction
  
endclass : apb_config

