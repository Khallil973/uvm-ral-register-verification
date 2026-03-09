//Transaction class

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)

       bit [7:0] din;
       bit       wr;
       bit       addr;
       bit       rst;
       bit [7:0] dout;   
  
  function new(string name = "transaction");
    super.new(name);
  endfunction
  
 

endclass
