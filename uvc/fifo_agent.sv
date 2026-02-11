class fifo_agent extends uvm_agent;
    `uvm_component_utils_begin(fifo_agent)
       `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
     `uvm_component_utils_end

    // Sequencer, driver, and monitor instances
    fifo_sequencer seqr;
    fifo_driver    driv;
    fifo_monitor   mon;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    // Build phase: create sequencer, driver, and monitor
    virtual function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
	// Monitor is always created
        mon  = fifo_monitor::type_id::create("mon",  this);

	// Create driver and sequencer only if agent is active
	if (is_active == UVM_ACTIVE) begin
          seqr = fifo_sequencer::type_id::create("seqr", this);
          driv = fifo_driver::type_id::create("driv", this);
	end
    endfunction

    // Connect phase: connect driver to sequencer
    virtual function void connect_phase(uvm_phase phase);
	if (is_active == UVM_ACTIVE) begin
           driv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction

    // Start of simulation: info message
    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Running Simulation ... (%s)", get_full_name()), UVM_HIGH)
    endfunction
endclass

