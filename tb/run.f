-timescale 1ns/1ns
-64
-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d

-incdir /home/cc/Music/AXI_UVC/uvc
-incdir /home/cc/Music/AXI_UVC/DUT
-incdir /home/cc/Music/AXI_UVC/uvc2


/home/cc/Music/AXI_UVC/uvc/fifo_uvc_pkg.sv
/home/cc/Music/AXI_UVC/uvc/fifo_if.sv

/home/cc/Music/AXI_UVC/uvc2/apb_pkg.sv
/home/cc/Music/AXI_UVC/uvc2/apb_if.sv



/home/cc/Music/AXI_UVC/DUT/Bridge_DP.sv
/home/cc/Music/AXI_UVC/DUT/Bridge_CP.sv
/home/cc/Music/AXI_UVC/DUT/Bridge_Complete.sv
top.sv

// options
+UVM_TESTNAME=simple_test
+UVM_VERBOSITY=UVM_HIGH
+SVSEED=random

-gui 
-access 
+rwc
//-covdut top 
-coverage all -covoverwrite
-linedebug
