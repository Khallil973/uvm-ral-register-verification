class fifo_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(fifo_driver)

    // Virtual interface
    virtual fifo_if drv_vif;

    // Behavioral queues for FIFO transactions
    bit req_is_write_q[$];
    bit [31:0] req_addr_q[$];
    bit [31:0] wr_data_q[$];
    bit [3:0] wr_strb_q[$];
    bit [31:0] d;
    bit [3:0] s;
    bit wr;
    bit [31:0] addr;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: bind virtual interface
    virtual function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", drv_vif))
            `uvm_fatal("NOVIF","No interface bound to driver")
    endfunction

    // Main run phase: get sequence items and manage behavioral FIFOs
    virtual task run_phase(uvm_phase phase);
        // Initialize interface signals
        drv_vif.req_fifo_empty = 1;
        drv_vif.wr_fifo_empty  = 1;  
        drv_vif.req_fifo_rd_data = '0;
        drv_vif.wr_fifo_rd_data = '0;
        drv_vif.rd_fifo_full     = 0;

        // Start persistent pop-handler tasks in background
        fork           
            handle_req_fifo_pops();
            handle_wr_fifo_pops();     
        join_none

        // Accept sequence items and push into behavioral queues
        forever begin
            fifo_seq_item req;
            seq_item_port.get_next_item(req);
            `uvm_info(get_type_name(), $sformatf("Packet Generated:\n%s", req.sprint()),UVM_LOW)
            void'(begin_tr(req, "Driver_Packet"));

            // Push request info into queues
            req_is_write_q.push_back(req.is_write);
            req_addr_q.push_back(req.addr);

            if (req.is_write) begin
                wr_data_q.push_back(req.data);
                wr_strb_q.push_back(req.strb);
            end
            #20;
            end_tr(req);           
            seq_item_port.item_done();
        end
    endtask

task handle_req_fifo_pops();
    forever begin
        @(posedge drv_vif.PCLK);

        if (req_is_write_q.size() == 0) begin
            drv_vif.req_fifo_empty <= 1;
        end
        else begin
            drv_vif.req_fifo_empty <= 0;

            if (drv_vif.req_fifo_rd_en) begin
                wr   = req_is_write_q.pop_front();
                addr = req_addr_q.pop_front();
                drv_vif.req_fifo_rd_data <= {wr, addr};
            end
        end
    end
endtask

task handle_wr_fifo_pops();
    forever begin
        @(posedge drv_vif.PCLK);

        if (wr_data_q.size() == 0) begin
            drv_vif.wr_fifo_empty <= 1;
        end
        else begin
            drv_vif.wr_fifo_empty <= 0;

            if (drv_vif.wr_fifo_rd_en) begin
                d = wr_data_q.pop_front();
                s = wr_strb_q.pop_front();
                drv_vif.wr_fifo_rd_data <= {s, d};
            end
        end
    end
endtask

    // Start of simulation: info message
    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Running Simulation ... (%s)", get_full_name()), UVM_HIGH)
    endfunction

endclass

