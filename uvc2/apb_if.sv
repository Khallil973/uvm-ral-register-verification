interface apb_if(input logic PCLK, input logic PRESET);
  
  logic PTRANSFER;
  logic PWRITE;
  logic [31:0] PADDR;
  logic [31:0] PWDATA;
  logic [3:0] PSTRB;
  
  logic PREADY;
  logic [31:0] PRDATA;
endinterface

