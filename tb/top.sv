module top;

    import uvm_pkg::*;
    import fifo_uvc_pkg::*;
    import apb_pkg::*;

    `include "uvm_macros.svh"
    `include "fifo_scoreboard.sv"
    `include "coverage.sv"
    `include "tb_env.sv"
    `include "fifo_test.sv"

    // Clock and reset signals
    logic PCLK = 0;
    logic PRESET = 0;

    // Clock generation
    always #5 PCLK = ~PCLK;

    // Interface instances
    fifo_if #(32,32) fifo_vif(PCLK, PRESET);
    apb_if vif (PCLK, PRESET);

    // APB configuration instance
    apb_config cfg = apb_config::type_id::create("cfg");

    // DUT instantiation
    Bridge_Complete dut(
        .PCLK(PCLK),
        .PRESET(PRESET),

        // FIFO connections
        .req_fifo_empty(fifo_vif.req_fifo_empty),
        .req_fifo_rd_data(fifo_vif.req_fifo_rd_data),
        .req_fifo_rd_en(fifo_vif.req_fifo_rd_en),

        .wr_fifo_empty(fifo_vif.wr_fifo_empty),
        .wr_fifo_rd_data(fifo_vif.wr_fifo_rd_data),
        .wr_fifo_rd_en(fifo_vif.wr_fifo_rd_en),

        .rd_fifo_full(fifo_vif.rd_fifo_full),
        .rd_fifo_wr_en(fifo_vif.rd_fifo_wr_en),
        .rd_fifo_wr_data(fifo_vif.rd_fifo_wr_data),

        // APB interface connections
        .PTRANSFER(vif.PTRANSFER),
        .PWRITE(vif.PWRITE),
        .PADDR(vif.PADDR),
        .PWDATA(vif.PWDATA),
        .PSTRB(vif.PSTRB),
        .PREADY(vif.PREADY),     
        .PRDATA(vif.PRDATA)
    );

    initial begin
        // Bind virtual interfaces to UVM config DB
        uvm_config_db #(virtual fifo_if)::set(null, "*", "vif", fifo_vif);
        uvm_config_db #(virtual apb_if)::set(null, "*", "vif1", vif);

        run_test();
    end

    initial begin
       PRESET = 0;
       #5 PRESET = 1;   // Release reset 
    end
endmodule

