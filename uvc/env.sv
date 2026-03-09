
class env extends uvm_env;
 `uvm_component_utils(env)
  
  agent          agent_inst;
  top_reg_block  regmodel;   
  top_adapter    adapter_inst;
  uvm_reg_predictor   #(transaction)  predictor_inst;
  
  sco s;
  
  
  // constructor
  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase - create the components
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    predictor_inst = uvm_reg_predictor#(transaction)::type_id::create("predictor_inst", this);
    agent_inst = agent::type_id::create("agent_inst", this);
    s = sco::type_id::create("s", this);
    regmodel   = top_reg_block::type_id::create("regmodel", this);
    regmodel.build();
    
    
    adapter_inst = top_adapter::type_id::create("adapter_inst",, get_full_name());
    

  endfunction 
  

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    agent_inst.m.mon_ap.connect(s.recv);
     
    regmodel.default_map.set_sequencer( .sequencer(agent_inst.seqr), .adapter(adapter_inst) );
    regmodel.default_map.set_base_addr(0);
    
    
    
    predictor_inst.map       = regmodel.default_map;
    predictor_inst.adapter   = adapter_inst;
    agent_inst.m.mon_ap.connect(predictor_inst.bus_in);
   
    
    regmodel.default_map.set_auto_predict(0);
  endfunction 

endclass
