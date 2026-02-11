interface fifo_if #(parameter ADDR_WIDTH = 32,
                    parameter DATA_WIDTH = 32)
(
    input logic PCLK,
    input logic PRESET
);

    // Request FIFO interface signals
    logic                    req_fifo_empty;
    logic [ADDR_WIDTH:0]     req_fifo_rd_data;
    logic                    req_fifo_rd_en;

    // Write FIFO interface signals
    logic                    wr_fifo_empty;
    logic [DATA_WIDTH+((DATA_WIDTH/8)-1):0] wr_fifo_rd_data;
    logic                    wr_fifo_rd_en;

    // Read FIFO interface signals
    logic                    rd_fifo_full;
    logic                    rd_fifo_wr_en;
    logic [DATA_WIDTH-1:0]  rd_fifo_wr_data;

    // Assertions to check FIFO correctness

    // No underflow on request FIFO
    property no_req_fifo_underflow;
      @(posedge PCLK)
      req_fifo_rd_en |-> !req_fifo_empty;
    endproperty
    assert_req_fifo_underflow:
      assert property (no_req_fifo_underflow)
      else $error("REQ FIFO underflow detected");

    // No underflow on write FIFO
    property no_wr_fifo_underflow;
      @(posedge PCLK)
      wr_fifo_rd_en |-> !wr_fifo_empty;
    endproperty
    assert_wr_fifo_underflow:
      assert property (no_wr_fifo_underflow)
      else $error("WR FIFO underflow detected");

    // No overflow on read FIFO
    property no_rd_fifo_overflow;
      @(posedge PCLK)
      rd_fifo_wr_en |-> !rd_fifo_full;
    endproperty
    assert_rd_fifo_overflow:
      assert property (no_rd_fifo_overflow)
      else $error("Read FIFO overflow detected");

endinterface

