class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    // Virtual interface for APB signals
    virtual apb_if vif;

    // Analysis port for sending APB transactions
    uvm_analysis_port #(apb_transaction) apb_ap;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        apb_ap = new("apb_ap", this);
    endfunction

    // Build phase: bind virtual interface
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif1", vif)) begin
            `uvm_fatal("NOVIF", "Virtual interface must be set for: APB Monitor")
        end
    endfunction

    // Run phase: sample APB transactions when PREADY is high
    task run_phase(uvm_phase phase);
        apb_transaction tr;
        forever begin
            @(posedge vif.PCLK);
            if (vif.PREADY) begin
                tr = apb_transaction::type_id::create("tr", this);
                tr.is_write = vif.PWRITE;
                tr.addr     = vif.PADDR;
                tr.strb     = vif.PSTRB;
                
                // Capture write or read data
                if (vif.PWRITE)
                    tr.data = vif.PWDATA;
                else
                    tr.data = vif.PRDATA;
		void'(begin_tr(tr, "APB Packet"));
                `uvm_info("APB_MONITOR", $sformatf("Receiving Packet :\n%s", tr.sprint()), UVM_HIGH)
		#10;
		end_tr(tr);
                apb_ap.write(tr);
            end
        end
    endtask

endclass

