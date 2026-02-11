class bridge_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(bridge_scoreboard)

  // Analysis port declarations
  `uvm_analysis_imp_decl(_fifo)
  `uvm_analysis_imp_decl(_apb)
  uvm_analysis_imp_fifo #(fifo_seq_item, bridge_scoreboard) fifo_imp;
  uvm_analysis_imp_apb #(apb_transaction, bridge_scoreboard) apb_imp;

  // Queues for tracking expected transactions
  fifo_seq_item fifo_q[$];        // FIFO request queue
  fifo_seq_item pending_read;     // Expected read response

  // Counters
  int total_fifo_req;
  int total_apb_tr;
  int write_pass, write_fail;
  int read_pass,  read_fail;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    fifo_imp = new("fifo_imp", this);
    apb_imp  = new("apb_imp", this);

    total_fifo_req = 0;
    total_apb_tr   = 0;
    write_pass = 0; write_fail = 0;
    read_pass  = 0; read_fail  = 0;
  endfunction

  // Handle FIFO transactions
  function void write_fifo(fifo_seq_item tx);

    // Handle read responses
    if (tx.is_read_rsp) begin
      if (pending_read == null) begin
        read_fail++;
        `uvm_error("SB", "Unexpected READ response from FIFO")
        return;
      end

      if (tx.data !== pending_read.data) begin
        read_fail++;
        `uvm_error("SB",
          $sformatf("READ DATA MISMATCH exp=%0h got=%0h",
                    pending_read.data, tx.data))
      end
      else begin
        read_pass++;
        `uvm_info("SB", "READ DATA MATCH", UVM_LOW)
      end

      pending_read = null;
      return;
    end

    // FIFO request
    total_fifo_req++;
    fifo_q.push_back(tx);
  endfunction

  // Handle APB transactions
  function void write_apb(apb_transaction tr);
    fifo_seq_item exp;

    total_apb_tr++;

    if (fifo_q.size() == 0) begin
      write_fail++;
      read_fail++;
      `uvm_error("SB", "APB transaction with no FIFO request")
      return;
    end

    exp = fifo_q.pop_front();

    // Check READ/WRITE type
    if (tr.is_write !== exp.is_write) begin
      `uvm_error("SB", "WRITE/READ type mismatch")
      if (tr.is_write)
        write_fail++;
      else
        read_fail++;
    end

    // Check address
    if (tr.addr !== exp.addr) begin
      `uvm_error("SB",
        $sformatf("ADDR MISMATCH exp=%0h got=%0h",
                  exp.addr, tr.addr))
      if (tr.is_write)
        write_fail++;
      else
        read_fail++;
    end

    // Write transaction check
    if (tr.is_write) begin
      if (tr.data !== exp.data || tr.strb !== exp.strb) begin
        write_fail++;
        `uvm_error("SB", "WRITE DATA / STRB mismatch")
      end
      else begin
        write_pass++;
      end
    end
    // Read transaction: store expected data for response check
    else begin
      exp.data = tr.data;
      pending_read = exp;
    end
  endfunction

  // Report scoreboard results
  function void report_phase(uvm_phase phase);
    string test_name;
      uvm_cmdline_processor clp;
    
    super.report_phase(phase);

  clp = uvm_cmdline_processor::get_inst();

  if (!clp.get_arg_value("+UVM_TESTNAME=", test_name))
    test_name = "UNKNOWN_TEST";

  `uvm_info("SB_REPORT",
    $sformatf("TEST NAME : %s", test_name),
    UVM_NONE)

    `uvm_info("SB_REPORT",
      "-------------------------------",
      UVM_NONE)

    `uvm_info("SB_REPORT",
      $sformatf("FIFO Requests   : %0d", total_fifo_req),
      UVM_NONE)

    `uvm_info("SB_REPORT",
      $sformatf("APB Transfers   : %0d", total_apb_tr),
      UVM_NONE)

    `uvm_info("SB_REPORT",
      $sformatf("WRITE  PASS/FAIL: %0d / %0d",
                write_pass, write_fail),
      UVM_NONE)

    `uvm_info("SB_REPORT",
      $sformatf("READ   PASS/FAIL: %0d / %0d",
                read_pass, read_fail),
      UVM_NONE)

    if ((write_fail + read_fail) == 0)
      `uvm_info("SB_REPORT", "SCOREBOARD RESULT : TEST PASS", UVM_NONE)
    else
      `uvm_error("SB_REPORT", "SCOREBOARD RESULT : **FAIL**")

    `uvm_info("SB_REPORT",
      "-------------------------------",
      UVM_NONE)
  endfunction

endclass

