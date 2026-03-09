# UVM RAL Register Verification Example

This project demonstrates a simple UVM verification environment integrated
with the UVM Register Abstraction Layer (RAL).

## DUT Description
The RTL module implements a simple register-based design:
- Write data using `wr=1`
- Read data using `wr=0`
- Address `0` stores data
- Reset clears the register

## Verification Environment
The verification environment is built using SystemVerilog UVM.

Components implemented:

- UVM Driver
- UVM Monitor
- UVM Agent
- UVM Scoreboard
- UVM Environment
- UVM Test

## UVM RAL Integration

- Register modeled using `uvm_reg`
- Register field using `uvm_reg_field`
- Register block using `uvm_reg_block`
- Custom `uvm_reg_adapter`
- Explicit `uvm_reg_predictor`
- Register read/write sequence
- Functional coverage on register values

## Tools Used
EDA Playground  
SystemVerilog  
UVM

## EDA Playground Link
https://www.edaplayground.com/x/LpyX
## Learning Outcome
This project demonstrates how register verification is implemented using
UVM RAL with explicit prediction.
