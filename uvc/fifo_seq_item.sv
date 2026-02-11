class fifo_seq_item extends uvm_sequence_item;

    // Transaction fields
    rand bit is_write;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;

    // Flag for read response
    bit is_read_rsp;

    // Address constraint: limit addr to 0–500
    constraint addr_c {
       addr inside {[0:500]};
    }

    // UVM field automation for copying, printing, and comparison
    `uvm_object_utils_begin(fifo_seq_item)
        `uvm_field_int(is_write, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(data, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(strb, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(is_read_rsp, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name="fifo_seq_item");
        super.new(name);
    endfunction
endclass

