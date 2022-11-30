# create_phy_cell.tcl
set CORE_POWER_LIST  [list core_vdd1 core_vdd2 core_vdd3 core_vdd4]
set CORE_GROUND_LIST [list core_vss1 core_vss2 core_vss3 core_vss4]
set PAD_POWER_LIST   [list io_vdd01 io_vdd02 io_vdd03 io_vdd04 io_vdd05 \
io_vdd06 io_vdd07 io_vdd08 io_vdd09 io_vdd10 \
io_vdd11 io_vdd12 io_vdd13 io_vdd14 io_vdd15 \
io_vdd16 io_vdd17 io_vdd18 io_vdd19 ]
set PAD_GROUND_LIST  [list io_vss01 io_vss02 io_vss03 io_vss04 io_vss05 \
io_vss06 io_vss07 io_vss08 io_vss09 io_vss10 \
io_vss11 io_vss12 io_vss13 io_vss14 io_vss15 \
io_vss16 io_vss17 io_vss18 io_vss19 io_vss20 ]
set CORNER_LIST      [list cornerUL cornerUR cornerLR cornerLL]
set POC_LIST         [list io_vdd20]
 
create_cell $CORE_POWER_LIST  PVDD1DGZ
create_cell $CORE_GROUND_LIST PVSS1DGZ
create_cell $PAD_POWER_LIST   PVDD2DGZ
create_cell $PAD_GROUND_LIST  PVSS2DGZ
create_cell $CORNER_LIST      PCORNER
create_cell $POC_LIST         PVDD2POC
