// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mul_3cycle.h for the primary calling header

#include "Vtb_mul_3cycle__pch.h"
#include "Vtb_mul_3cycle__Syms.h"
#include "Vtb_mul_3cycle___024root.h"

VL_ATTR_COLD void Vtb_mul_3cycle___024root___eval_initial__TOP(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_initial__TOP\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlWide<5>/*159:0*/ __Vtemp_1;
    // Body
    __Vtemp_1[0U] = 0x2e766364U;
    __Vtemp_1[1U] = 0x79636c65U;
    __Vtemp_1[2U] = 0x6c5f3363U;
    __Vtemp_1[3U] = 0x625f6d75U;
    __Vtemp_1[4U] = 0x74U;
    vlSymsp->_vm_contextp__->dumpfile(VL_CVT_PACK_STR_NW(5, __Vtemp_1));
    VL_PRINTF_MT("-Info: tb_mul_3cycle.v:258: $dumpvar ignored, as Verilated without --trace\n");
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mul_3cycle___024root___dump_triggers__stl(Vtb_mul_3cycle___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_mul_3cycle___024root___eval_triggers__stl(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_triggers__stl\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered.set(0U, (IData)(vlSelfRef.__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mul_3cycle___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
