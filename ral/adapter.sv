///////////////////////reg adapter

class top_adapter extends uvm_reg_adapter;
  `uvm_object_utils (top_adapter)


  // Constructor 
  function new (string name = "top_adapter");
      super.new (name);
   endfunction
  
  // reg2bus method 
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    transaction tr;    
    tr = transaction::type_id::create("tr");
    
    tr.wr    = (rw.kind == UVM_WRITE);
    tr.addr  = rw.addr;
    
    if(tr.wr == 1'b1) tr.din = rw.data;
    
    return tr;
  endfunction


  // bus2reg method 
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    transaction tr;
    
    assert($cast(tr, bus_item));

    rw.kind = (tr.wr == 1'b1) ? UVM_WRITE : UVM_READ;
    rw.data = (tr.wr == 1'b1) ? tr.din : tr.dout;
    rw.addr = tr.addr;
    rw.status = UVM_IS_OK;
  endfunction
endclass


