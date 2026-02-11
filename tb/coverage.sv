class coverage extends uvm_subscriber #(fifo_seq_item);
  `uvm_component_utils(coverage)

  fifo_seq_item tr;

  covergroup fifo_cg;
   // option.per_instance = 1;

    // Read vs Write
    cp_rw : coverpoint tr.is_write {
      bins READ  = {0};
      bins WRITE = {1};
    }

    // Address range coverage
    cp_addr : coverpoint tr.addr 
    {
      bins low  = {[0:63]};
      bins mid  = {[64:255]};
      bins high = {[256:500]};
    }

    // Write strobe patterns (only valid for writes)
    cp_strb : coverpoint tr.strb iff (tr.is_write) {
      bins full = {4'b1111};
      bins specfic_byte = {4'b0001,4'b0010,4'b0100,4'b1000};
      bins misc = default;
    }

    // Cross: what kind of access at which address
    cross_rw_addr : cross cp_rw, cp_addr;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    fifo_cg = new();
  endfunction

  function void write(fifo_seq_item t);
    tr = t;
    fifo_cg.sample();
  endfunction

endclass

