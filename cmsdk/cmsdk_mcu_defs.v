//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2015 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//  Version and Release Control Information:
//
//  File Revision       : $Revision: 368442 $
//  File Date           : $Date: 2017-07-25 15:07:59 +0100 (Tue, 25 Jul 2017) $
//
//  Release Information : Cortex-M0 DesignStart-r2p0-00rel0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
// Abstract : System configurations for Cortex-M0 example system
//-----------------------------------------------------------------------------


// ============= MCU System options ===========

//------------------------------------------------------------------------------
// Option for debug protocol
// It can either be SWD (Serial Wire Debug protocol) or JTAG
// These options specified here cannot be controlled purely by parameters
// due to impact on I/O ports
//
//`define ARM_CMSDK_INCLUDE_JTAG

//------------------------------------------------------------------------------
// Memory types
//------------------------------------------------------------------------------

//`include "cmsdk_ahb_memory_models_defs.v"

// Memory types used in the Example system

// Memory wait state parameters - used by behaviorial model if applicable*/
   // Boot ROM non-sequential and sequential waitstate
`define ARM_CMSDK_BOOT_MEM_WS_N   0
`define ARM_CMSDK_BOOT_MEM_WS_S   0

   // ROM non-sequential and sequential waitstate
`define ARM_CMSDK_ROM_MEM_WS_N    0
`define ARM_CMSDK_ROM_MEM_WS_S    0

   // RAM non-sequential and sequential waitstate
`define ARM_CMSDK_RAM_MEM_WS_N    0
`define ARM_CMSDK_RAM_MEM_WS_S    0


