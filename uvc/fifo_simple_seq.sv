// Base simple sequence class
class fifo_simple_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(fifo_simple_seq)

  function new(string name="fifo_simple_seq");
    super.new(name);
  endfunction

  // Raise objection at start
  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask

  // Drop objection at end
  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask
endclass


// Extended sequence with predefined WR/READ transactions
class basic_read_write_seq extends fifo_simple_seq;
    `uvm_object_utils(basic_read_write_seq)

    function new(string name="basic_read_write_seq");
        super.new(name);
    endfunction

    task body();
        fifo_seq_item req;

        `uvm_do_with(req, { is_write == 1; addr=='h1; data=='hAAAA_AAAA; strb==4'hF; });
        `uvm_do_with(req, { is_write == 1; addr=='h2; data=='hBBBB_BBBB; strb==4'hA; });

        `uvm_do_with(req, { is_write == 0; addr=='h1; });
        `uvm_do_with(req, { is_write == 0; addr=='h2; });

    endtask
endclass


// Write-then-read sequence repeated
class read_after_write_seq extends fifo_simple_seq;
  `uvm_object_utils(read_after_write_seq)

  function new(string name="read_after_write_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item wr_req, rd_req;
    bit [31:0] saved_addr;

    repeat (5) begin
      // WRITE
      `uvm_do_with(wr_req, { is_write==1; addr inside {[1:10]};  });
      saved_addr = wr_req.addr;

      // READ same address
      `uvm_do_with(rd_req, { is_write==0; addr==saved_addr; });
    end
  endtask
endclass


// 10 WRITES followed by 10 READS
class consective_ten_write_ten_read_seq extends fifo_simple_seq;
  `uvm_object_utils(consective_ten_write_ten_read_seq)

  function new(string name="consective_ten_write_ten_read_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item wr_req, rd_req;
    bit [31:0] addr_q[$];
    int i;

    // 4 WRITES
    for (i=0; i<10; i++) begin
      `uvm_do_with(wr_req, { is_write==1; addr inside {[1:100]};});
      addr_q.push_back(wr_req.addr);
      #30;
    end

    // 4 READS
    foreach (addr_q[i]) begin
      `uvm_do_with(rd_req, { is_write==0; addr==addr_q[i]; });
      #30;
    end
  endtask
endclass


// Repeat 4W-4R sequence 5 times
class consective_four_write_four_read_seq_repeat_5 extends fifo_simple_seq;
  `uvm_object_utils(consective_four_write_four_read_seq_repeat_5)

  function new(string name="consective_four_write_four_read_seq_repeat_5");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item wr_req, rd_req;
    bit [31:0] addr_q[$];
    int i, iter;

    for (iter=0; iter<5; iter++) begin
      addr_q.delete();
      `uvm_info(get_type_name(), $sformatf("Iteration %0d of 4W-4R", iter+1), UVM_MEDIUM)

      for (i=0; i<4; i++) begin
        `uvm_do_with(wr_req, { is_write==1; addr inside {[1:10]}; strb==4'hF; });
        addr_q.push_back(wr_req.addr);
	#30;
      end

      foreach(addr_q[i]) begin
        `uvm_do_with(rd_req, { is_write==0; addr==addr_q[i]; });
	#30;
      end
    end
  endtask
endclass


// Fully random sequence
class random_seq extends fifo_simple_seq;
  `uvm_object_utils(random_seq)

  function new(string name="random_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item req;

    repeat(500) begin
      req = fifo_seq_item::type_id::create("rand_req");
      start_item(req);
      if (!req.randomize()) begin
        `uvm_warning("SEQ","Randomization failed")
        continue;
      end
      finish_item(req);
      #40; // give DUT time to process
    end
  endtask
endclass


// Write-read reverse sequence
class write_read_reverse_seq extends fifo_simple_seq;
  `uvm_object_utils(write_read_reverse_seq)

  function new(string name="write_read_reverse_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item wr_req, rd_req;
    bit [31:0] addr_q[$];
    int i;
    int N = 10;

    // WRITES
    for (i=0; i<N; i++) begin
      `uvm_do_with(wr_req, { is_write==1; addr inside {[1:20]}; strb==4'hF; });
      addr_q.push_back(wr_req.addr);
      #40;
    end

    // READS in reverse
    for (i=addr_q.size()-1; i>=0; i--) begin
      `uvm_do_with(rd_req, { is_write==0; addr==addr_q[i]; });
      #40;
    end
  endtask
endclass


// Random mixed 70% write, 30% read
class fifo_random_mix_seq extends fifo_simple_seq;
  `uvm_object_utils(fifo_random_mix_seq)

  function new(string name="fifo_random_mix_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item req;
    int i, num_txn=100, rand_sel;

    for (i=0; i<num_txn; i++) begin
      rand_sel = $urandom_range(0,99);
      if(rand_sel < 70) begin
        `uvm_do_with(req, { is_write==1; addr inside {[1:50]}; });
      end
      else begin
        `uvm_do_with(req, { is_write==0; addr inside {[1:50]}; });
      end
      #40;
    end
  endtask
endclass


// Killer stress sequence
class fifo_killer_stress_seq extends fifo_simple_seq;
  `uvm_object_utils(fifo_killer_stress_seq)

  function new(string name="fifo_killer_stress_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item wr_req, rd_req;
    bit [31:0] write_addr_q[$];
    int iter, i, burst_w, burst_r;

    for(iter=0; iter<5000; iter++) begin
      `uvm_info(get_type_name(), $sformatf("Stress iteration %0d", iter), UVM_MEDIUM)
      write_addr_q.delete();

      // Random WRITE burst
      burst_w = $urandom_range(2,6);
      for(i=0; i<burst_w; i++) begin
        `uvm_do_with(wr_req, { is_write==1; addr inside {[1:50]}; strb==4'hF; });
        write_addr_q.push_back(wr_req.addr);
	#30;
      end
      

      // Random READ burst
      burst_r = $urandom_range(2,6);
      for(i=0; i<burst_r; i++) begin
        if(write_addr_q.size()!=0 && $urandom_range(0,99)<70) begin
          int idx = $urandom_range(0,write_addr_q.size()-1);
          `uvm_do_with(rd_req, { is_write==0; addr==write_addr_q[idx]; });
        end
        else begin
          `uvm_do_with(rd_req, { is_write==0; addr inside {[1:50]}; });
        end
	#30;
      end
    end
  endtask
endclass



class fifo_exhaustive_seq extends fifo_simple_seq;
  `uvm_object_utils(fifo_exhaustive_seq)

  function new(string name="fifo_exhaustive_seq");
    super.new(name);
  endfunction

  virtual task body();

    basic_read_write_seq                          seq_basic;
    read_after_write_seq                          seq_raw;
    consective_ten_write_ten_read_seq             seq_10w10r;
    consective_four_write_four_read_seq_repeat_5  seq_4w4r_5x;
    random_seq                                    seq_random;
    write_read_reverse_seq                        seq_reverse;
    fifo_random_mix_seq                           seq_mix;
    fifo_killer_stress_seq                        seq_killer;
    fifo_illegal_addr_seq                         seq_illegal;

    `uvm_info(get_type_name(),
      "Starting FIFO EXHAUSTIVE SEQUENCE",
      UVM_LOW)

    //----------------------------------
    `uvm_info(get_type_name(), "Running basic_read_write_seq", UVM_MEDIUM)
    seq_basic = basic_read_write_seq::type_id::create("seq_basic");
    seq_basic.start(m_sequencer);

    //----------------------------------
    `uvm_info(get_type_name(), "Running read_after_write_seq", UVM_MEDIUM)
    seq_raw = read_after_write_seq::type_id::create("seq_raw");
    seq_raw.start(m_sequencer);

    //----------------------------------
    `uvm_info(get_type_name(), "Running 10W-10R sequence", UVM_MEDIUM)
    seq_10w10r = consective_ten_write_ten_read_seq::type_id::create("seq_10w10r");
    seq_10w10r.start(m_sequencer);

    //----------------------------------
    `uvm_info(get_type_name(), "Running 4W-4R x5 sequence", UVM_MEDIUM)
    seq_4w4r_5x =
      consective_four_write_four_read_seq_repeat_5::type_id::create("seq_4w4r_5x");
    seq_4w4r_5x.start(m_sequencer);

    //----------------------------------
    `uvm_info(get_type_name(), "Running fully random sequence", UVM_MEDIUM)
    seq_random = random_seq::type_id::create("seq_random");
    seq_random.start(m_sequencer);

    //----------------------------------
    `uvm_info(get_type_name(), "Running write-read reverse sequence", UVM_MEDIUM)
    seq_reverse = write_read_reverse_seq::type_id::create("seq_reverse");
    seq_reverse.start(m_sequencer);

    //----------------------------------
    `uvm_info(get_type_name(), "Running random mix sequence", UVM_MEDIUM)
    seq_mix = fifo_random_mix_seq::type_id::create("seq_mix");
    seq_mix.start(m_sequencer);

    //----------------------------------
    `uvm_info(get_type_name(), "Running killer stress sequence", UVM_MEDIUM)
    seq_killer = fifo_killer_stress_seq::type_id::create("seq_killer");
    seq_killer.start(m_sequencer);

/*    //----------------------------------
    `uvm_info(get_type_name(), "Running illegal address sequence", UVM_MEDIUM)
    seq_illegal = fifo_illegal_addr_seq::type_id::create("seq_illegal");
    seq_illegal.start(m_sequencer);
*/
    //----------------------------------
    `uvm_info(get_type_name(),
      "FIFO EXHAUSTIVE SEQUENCE COMPLETED",
      UVM_LOW)

  endtask
endclass



