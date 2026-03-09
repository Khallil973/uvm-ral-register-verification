///////creating reg block

class top_reg_block extends uvm_reg_block;
  `uvm_object_utils(top_reg_block)
  

  rand temp_reg 	temp_reg_inst; 
  

  function new (string name = "top_reg_block");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction


  function void build;
    
    uvm_reg::include_coverage("*", UVM_CVR_ALL);

    temp_reg_inst = temp_reg::type_id::create("temp_reg_inst");
    temp_reg_inst.build();
    temp_reg_inst.configure(this);
    temp_reg_inst.set_coverage(UVM_CVR_FIELD_VALS); //////enabling coverage for specific reg instance       


    default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN); // name, base, nBytes
    default_map.add_reg(temp_reg_inst	, 'h0, "RW");  // reg, offset, access
    
    lock_model();
  endfunction
endclass
