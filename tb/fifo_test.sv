class base_test extends uvm_test ;
   `uvm_component_utils(base_test)
   // env class handle
   tb_env env;
   // constructor 
   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction
   
   // build phase 
   function void build_phase(uvm_phase phase); 
      super.build_phase(phase);
     // Enable transaction recording
      uvm_config_int::set(this, "*", "recording_detail", 1);

      env = tb_env::type_id::create("env", this);
      `uvm_info(get_type_name(),"Build phase of the test is being executed",UVM_HIGH); 
   endfunction

   // ADD: run_phase with drain time
   virtual task run_phase(uvm_phase phase);
     uvm_objection obj;
      super.run_phase(phase);
      // Set drain time to allow packets to pass through router before simulation ends
      obj = phase.get_objection();
      obj.set_drain_time(this, 500ns);

   endtask : run_phase

   function void end_of_elaboration_phase(uvm_phase phase);
      uvm_top.print_topology();
   endfunction 

   function void check_phase(uvm_phase phase);
     super.check_phase(phase);
     check_config_usage();
   endfunction


  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
   `uvm_info(get_type_name(), $sformatf("Running Simulation ... (%s)", get_full_name()), UVM_HIGH)
  endfunction
endclass


class simple_test extends base_test;
  `uvm_component_utils(simple_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            basic_read_write_seq::get_type());
  endfunction

endclass 



//.........................................
//   Read After Write Test (Repeat 5)
//.........................................
class read_after_write_test extends base_test;
  `uvm_component_utils(read_after_write_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            read_after_write_seq::get_type());
  endfunction

endclass 




//.........................................
//   4 Read After 4 Write Test (Single Run)
//.........................................
class consective_ten_write_ten_read_test extends base_test;
  `uvm_component_utils(consective_ten_write_ten_read_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            consective_ten_write_ten_read_seq::get_type());
  endfunction

endclass 


//.........................................
//   4 Read After 4 Write Test (Repeat 5)
//.........................................
class consective_4_write_4_read_repeated_5_times_test extends base_test;
  `uvm_component_utils(consective_4_write_4_read_repeated_5_times_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            consective_four_write_four_read_seq_repeat_5::get_type());
  endfunction

endclass 



//.........................................
//   Fully Random
//.........................................
class random_seq_test extends base_test;
  `uvm_component_utils(random_seq_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            random_seq::get_type());
  endfunction

endclass 


//.........................................
//   Write and Read Reverse  Sequence Test
//.........................................
class write_read_reverse_seq_test extends base_test;
  `uvm_component_utils(write_read_reverse_seq_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            write_read_reverse_seq::get_type());
  endfunction

endclass 



//.........................................
//   Random Mix Sequence 70% write , 30% Read
//.........................................
class random_mix_seq_test extends base_test;
  `uvm_component_utils(random_mix_seq_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            fifo_random_mix_seq::get_type());
  endfunction

endclass 



//.........................................
//  Killer Stress Test
//.........................................
class fifo_killer_stress_seq_test extends base_test;
  `uvm_component_utils(fifo_killer_stress_seq_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            fifo_killer_stress_seq::get_type());
  endfunction

endclass 



//.........................................
//  fifo_illegal_addr_seq_test
//.........................................
class fifo_illegal_addr_seq_test extends base_test;
  `uvm_component_utils(fifo_illegal_addr_seq_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            fifo_illegal_addr_seq::get_type());
  endfunction

endclass


class all_tests extends base_test;
  `uvm_component_utils(all_tests)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction   

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "env.fifo_ag.seqr.run_phase",
                            "default_sequence",
                            fifo_exhaustive_seq::get_type());
  endfunction

endclass
