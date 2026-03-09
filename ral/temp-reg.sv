//building reg model

class temp_reg extends uvm_reg;
  `uvm_object_utils(temp_reg)
   

  rand uvm_reg_field temp;

//adding coverpoints     
  
 covergroup temp_cov;
    
   option.per_instance = 1;
    
    
   coverpoint temp.value[7:0] 
    {
      bins lower = {[0:63]};
      bins mid = {[64:127]};
      bins high = {[128:255]};
    }
     
  endgroup

  ///checking coverage and adding new method to covergroup
  
  function new (string name = "temp_reg");
    super.new(name,8,UVM_CVR_FIELD_VALS);
    
    if(has_coverage(UVM_CVR_FIELD_VALS))
      temp_cov = new();
    
  endfunction

// implementation of sample and sample_Values  
  
  
  virtual function void sample(uvm_reg_data_t data,
                                uvm_reg_data_t byte_en,
                                bit            is_read,
                                uvm_reg_map    map);
    
         temp_cov.sample();
   endfunction
  
  
  
   virtual function void sample_values();
    super.sample_values();
     
    temp_cov.sample();
     
  endfunction
  
  
  
  
  
///////////////user defined build function
  
  function void build; 
    
 
    temp = uvm_reg_field::type_id::create("temp");   
    // Configure
    temp.configure(  .parent(this), 
                     .size(8), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(1)); 

    
  endfunction
  
endclass
