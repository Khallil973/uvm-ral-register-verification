class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    // Virtual interface and analysis port
    virtual fifo_if mon_vif;
    uvm_analysis_port #(fifo_seq_item) ap;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    // Build phase: virtual interface
    virtual function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", mon_vif))
            `uvm_fatal("NOVIF","No interface bound to monitor")
    endfunction

    // Run phase: monitor FIFO requests and read responses
    virtual task run_phase(uvm_phase phase);
        fifo_seq_item tx;

        forever begin
            @(posedge mon_vif.PCLK);

            // Monitor REQUEST FIFO
            if (mon_vif.req_fifo_rd_en && !mon_vif.req_fifo_empty) begin
                tx = fifo_seq_item::type_id::create("tx_req");

                // Sample after pop
                @(posedge mon_vif.PCLK);

                tx.is_write = mon_vif.req_fifo_rd_data[32];
                tx.addr     = mon_vif.req_fifo_rd_data[31:0];
                tx.is_read_rsp = 0;

                // If write request, capture write-data

		if (tx.is_write) begin
		    @(posedge mon_vif.PCLK);
		    while (!(mon_vif.wr_fifo_rd_en && !mon_vif.wr_fifo_empty))
			@(posedge mon_vif.PCLK);

		    // data becomes valid one cycle AFTER rd_en
		    @(posedge mon_vif.PCLK);

		    tx.data = mon_vif.wr_fifo_rd_data[31:0];
		    tx.strb = mon_vif.wr_fifo_rd_data[35:32];
		end

                void'(begin_tr(tx, "FIFO REQ"));
                `uvm_info(get_type_name(),
                    $sformatf("REQUEST:\n%s", tx.sprint()),
                    UVM_LOW)
		#10;
                end_tr(tx);

                ap.write(tx); 
            end

            // Monitor READ RESPONSE FIFO
            if (mon_vif.rd_fifo_wr_en) begin
                tx = fifo_seq_item::type_id::create("tx_rsp");

                tx.is_write    = 0;
                tx.is_read_rsp = 1;
                tx.data        = mon_vif.rd_fifo_wr_data;

                void'(begin_tr(tx, "READ RSP"));
                `uvm_info(get_type_name(),
                    $sformatf("READ RESPONSE:\n%s", tx.sprint()),
                    UVM_LOW)
		#10;
                end_tr(tx);

                ap.write(tx);
            end
        end
    endtask

    // Start of simulation: info message
    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Running Simulation ... (%s)", get_full_name()), UVM_HIGH)
    endfunction
endclass

