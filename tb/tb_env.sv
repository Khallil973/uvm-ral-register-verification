class tb_env extends uvm_env;
    `uvm_component_utils(tb_env)

    // Agent instances
    fifo_agent fifo_ag;
    apb_agent apb_ag;

    // Scoreboard instance
    bridge_scoreboard sb;
 
    // Coverage instance
    coverage fifo_cov;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: create agents, scoreboard, and coverage
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        fifo_ag = fifo_agent::type_id::create("fifo_ag", this);
        apb_ag = apb_agent::type_id::create("apb_ag", this);

        sb  = bridge_scoreboard::type_id::create("sb", this);
        fifo_cov = coverage::type_id::create("fifo_cov", this);
    endfunction

    // Connect phase: connect analysis ports and exports
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        fifo_ag.mon.ap.connect(sb.fifo_imp);
        apb_ag.mon.apb_ap.connect(sb.apb_imp);
        fifo_ag.mon.ap.connect(fifo_cov.analysis_export);
    endfunction

endclass

