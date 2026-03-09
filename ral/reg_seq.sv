class top_reg_seq extends uvm_sequence;

  `uvm_object_utils(top_reg_seq)
  
   top_reg_block regmodel;
  
   
  function new (string name = "top_reg_seq"); 
    super.new(name);    
  endfunction
  

  task body;  
    uvm_status_e   status;
    bit [7:0] data;
    bit [7:0] read_d;
    bit [7:0] des, mir;
    
    
    
    for (int i = 0; i < 10; i++) begin
     data = $urandom;
     regmodel.temp_reg_inst.write(status, data);
     des = regmodel.temp_reg_inst.get();
     mir = regmodel.temp_reg_inst.get_mirrored_value();
    `uvm_info("SEQ", $sformatf("Write -> Des: %0d Mir: %0d", des, mir), UVM_NONE);
  
      
     regmodel.temp_reg_inst.read(status, read_d);
     des = regmodel.temp_reg_inst.get();
     mir = regmodel.temp_reg_inst.get_mirrored_value();
    `uvm_info("SEQ", $sformatf("Write -> Des: %0d Mir: %0d", des, mir), UVM_NONE);
  
     $display("---------------------------------------------------------------------------"); 
      
    end

  endtask
  
  
  
endclass