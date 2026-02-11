class apb_transaction extends uvm_sequence_item;

    // APB transaction fields
    rand bit is_write;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;

    // UVM field automation for copying, printing, and comparison
    `uvm_object_utils_begin(apb_transaction)
        `uvm_field_int(is_write, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(data, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(strb, UVM_ALL_ON | UVM_BIN)
    `uvm_object_utils_end

    // Constructor
    function new(string name="apb_transaction");
        super.new(name);
    endfunction
endclass

