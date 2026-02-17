// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mul_3cycle.h for the primary calling header

#include "Vtb_mul_3cycle__pch.h"
#include "Vtb_mul_3cycle___024root.h"

VL_ATTR_COLD void Vtb_mul_3cycle___024root___eval_static(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_static\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_mul_3cycle___024root___eval_final(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_final\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mul_3cycle___024root___dump_triggers__stl(Vtb_mul_3cycle___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_mul_3cycle___024root___eval_phase__stl(Vtb_mul_3cycle___024root* vlSelf);

VL_ATTR_COLD void Vtb_mul_3cycle___024root___eval_settle(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_settle\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY((0x64U < __VstlIterCount))) {
#ifdef VL_DEBUG
            Vtb_mul_3cycle___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("tb_mul_3cycle.v", 7, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vtb_mul_3cycle___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelfRef.__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mul_3cycle___024root___dump_triggers__stl(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___dump_triggers__stl\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VstlTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_mul_3cycle___024root___stl_sequent__TOP__0(Vtb_mul_3cycle___024root* vlSelf);

VL_ATTR_COLD void Vtb_mul_3cycle___024root___eval_stl(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_stl\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        Vtb_mul_3cycle___024root___stl_sequent__TOP__0(vlSelf);
    }
}

extern const VlUnpacked<CData/*1:0*/, 8> Vtb_mul_3cycle__ConstPool__TABLE_hfd730721_0;

VL_ATTR_COLD void Vtb_mul_3cycle___024root___stl_sequent__TOP__0(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___stl_sequent__TOP__0\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp1;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp1);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp2;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp2);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp3;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp3);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp4;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp4);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp5;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp5);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp6;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp6);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp7;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp7);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp8;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp8);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp9;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp9);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp10;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp10);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp11;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp11);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp12;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp12);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp13;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp13);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp14;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp14);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp15;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp15);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__pp16;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__pp16);
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__out51;
    VL_ZERO_W(69, tb_mul_3cycle__DOT__dut__DOT__out51);
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__out52;
    VL_ZERO_W(69, tb_mul_3cycle__DOT__dut__DOT__out52);
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__out61;
    VL_ZERO_W(69, tb_mul_3cycle__DOT__dut__DOT__out61);
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__out62;
    VL_ZERO_W(69, tb_mul_3cycle__DOT__dut__DOT__out62);
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_1;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_1 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_2;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_2 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_4;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_4 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_5;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_5 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_6;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_6 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_7;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_7 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_8;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_8 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_9;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_9 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_10;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_10 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_11;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_11 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_12;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_12 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_13;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_13 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_14;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_14 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_15;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_15 = 0;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_16;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_16 = 0;
    CData/*2:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18;
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18 = 0;
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w1;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w1);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w1;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w1);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w1;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w1);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w1;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w1);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2);
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0;
    VL_ZERO_W(69, tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0);
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1;
    VL_ZERO_W(69, tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2);
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0;
    VL_ZERO_W(69, tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0);
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1;
    VL_ZERO_W(69, tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1);
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1;
    VL_ZERO_W(68, tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1);
    CData/*2:0*/ __Vtableidx1;
    __Vtableidx1 = 0;
    VlWide<3>/*95:0*/ __Vtemp_2;
    VlWide<3>/*95:0*/ __Vtemp_3;
    VlWide<3>/*95:0*/ __Vtemp_6;
    VlWide<3>/*95:0*/ __Vtemp_7;
    VlWide<3>/*95:0*/ __Vtemp_12;
    VlWide<3>/*95:0*/ __Vtemp_13;
    VlWide<3>/*95:0*/ __Vtemp_16;
    VlWide<3>/*95:0*/ __Vtemp_17;
    VlWide<3>/*95:0*/ __Vtemp_22;
    VlWide<3>/*95:0*/ __Vtemp_23;
    VlWide<3>/*95:0*/ __Vtemp_26;
    VlWide<3>/*95:0*/ __Vtemp_27;
    VlWide<3>/*95:0*/ __Vtemp_33;
    VlWide<3>/*95:0*/ __Vtemp_34;
    VlWide<3>/*95:0*/ __Vtemp_37;
    VlWide<3>/*95:0*/ __Vtemp_38;
    VlWide<3>/*95:0*/ __Vtemp_44;
    VlWide<3>/*95:0*/ __Vtemp_45;
    VlWide<3>/*95:0*/ __Vtemp_47;
    VlWide<3>/*95:0*/ __Vtemp_48;
    VlWide<3>/*95:0*/ __Vtemp_54;
    VlWide<3>/*95:0*/ __Vtemp_55;
    VlWide<3>/*95:0*/ __Vtemp_57;
    VlWide<3>/*95:0*/ __Vtemp_58;
    VlWide<3>/*95:0*/ __Vtemp_72;
    VlWide<3>/*95:0*/ __Vtemp_73;
    VlWide<3>/*95:0*/ __Vtemp_76;
    VlWide<3>/*95:0*/ __Vtemp_77;
    VlWide<3>/*95:0*/ __Vtemp_83;
    VlWide<3>/*95:0*/ __Vtemp_84;
    VlWide<3>/*95:0*/ __Vtemp_87;
    VlWide<3>/*95:0*/ __Vtemp_88;
    VlWide<3>/*95:0*/ __Vtemp_93;
    VlWide<3>/*95:0*/ __Vtemp_94;
    VlWide<3>/*95:0*/ __Vtemp_96;
    VlWide<3>/*95:0*/ __Vtemp_97;
    // Body
    __Vtableidx1 = (((IData)(vlSelfRef.tb_mul_3cycle__DOT__mul_start) 
                     << 2U) | (IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__state));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__next_state 
        = Vtb_mul_3cycle__ConstPool__TABLE_hfd730721_0
        [__Vtableidx1];
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18 
        = ((((IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_sign_reg)
              ? (3U & (- (IData)((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                  >> 0x1fU)))) : 0U) 
            << 1U) | (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                      >> 0x1fU));
    __Vtemp_2[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[0U];
    __Vtemp_2[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[1U];
    __Vtemp_2[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_3, __Vtemp_2, 1U);
    __Vtemp_6[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[0U];
    __Vtemp_6[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[1U];
    __Vtemp_6[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_7, __Vtemp_6, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[0U] 
        = ((__Vtemp_3[0U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U]) 
           | (__Vtemp_7[0U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U]));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[1U] 
        = ((__Vtemp_3[1U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U]) 
           | (__Vtemp_7[1U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U]));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[2U] 
        = (0xfU & ((__Vtemp_3[2U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[2U]) 
                   | (__Vtemp_7[2U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[2U])));
    __Vtemp_12[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[0U];
    __Vtemp_12[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[1U];
    __Vtemp_12[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_13, __Vtemp_12, 1U);
    __Vtemp_16[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[0U];
    __Vtemp_16[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[1U];
    __Vtemp_16[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_17, __Vtemp_16, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[0U] 
        = ((__Vtemp_13[0U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U]) 
           | (__Vtemp_17[0U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U]));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[1U] 
        = ((__Vtemp_13[1U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U]) 
           | (__Vtemp_17[1U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U]));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[2U] 
        = (0xfU & ((__Vtemp_13[2U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[2U]) 
                   | (__Vtemp_17[2U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[2U])));
    __Vtemp_22[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[0U];
    __Vtemp_22[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[1U];
    __Vtemp_22[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_23, __Vtemp_22, 1U);
    __Vtemp_26[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[0U];
    __Vtemp_26[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[1U];
    __Vtemp_26[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_27, __Vtemp_26, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[0U] 
        = (((__Vtemp_23[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U]) 
            & (__Vtemp_27[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U])) 
           << 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[1U] 
        = ((((__Vtemp_23[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U]) 
             & (__Vtemp_27[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U])) 
            >> 0x1fU) | (((__Vtemp_23[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U]) 
                          & (__Vtemp_27[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U])) 
                         << 1U));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[2U] 
        = ((((__Vtemp_23[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U]) 
             & (__Vtemp_27[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U])) 
            >> 0x1fU) | (0x1eU & (((__Vtemp_23[2U] 
                                    | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[2U]) 
                                   & (__Vtemp_27[2U] 
                                      | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[2U])) 
                                  << 1U)));
    __Vtemp_33[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[0U];
    __Vtemp_33[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[1U];
    __Vtemp_33[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_34, __Vtemp_33, 1U);
    __Vtemp_37[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[0U];
    __Vtemp_37[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[1U];
    __Vtemp_37[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_38, __Vtemp_37, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[0U] 
        = (((__Vtemp_34[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U]) 
            & (__Vtemp_38[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U])) 
           << 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[1U] 
        = ((((__Vtemp_34[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U]) 
             & (__Vtemp_38[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U])) 
            >> 0x1fU) | (((__Vtemp_34[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U]) 
                          & (__Vtemp_38[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U])) 
                         << 1U));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[2U] 
        = ((((__Vtemp_34[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U]) 
             & (__Vtemp_38[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U])) 
            >> 0x1fU) | (0x1eU & (((__Vtemp_34[2U] 
                                    | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[2U]) 
                                   & (__Vtemp_38[2U] 
                                      | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[2U])) 
                                  << 1U)));
    __Vtemp_44[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[0U];
    __Vtemp_44[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[1U];
    __Vtemp_44[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_45, __Vtemp_44, 1U);
    __Vtemp_47[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[0U];
    __Vtemp_47[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[1U];
    __Vtemp_47[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_48, __Vtemp_47, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[0U] 
        = (__Vtemp_45[0U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U] 
                             ^ (__Vtemp_48[0U] ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[1U] 
        = (__Vtemp_45[1U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U] 
                             ^ (__Vtemp_48[1U] ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[2U] 
        = (0xfU & (__Vtemp_45[2U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[2U] 
                                     ^ (__Vtemp_48[2U] 
                                        ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[2U]))));
    __Vtemp_54[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[0U];
    __Vtemp_54[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[1U];
    __Vtemp_54[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_55, __Vtemp_54, 1U);
    __Vtemp_57[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[0U];
    __Vtemp_57[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[1U];
    __Vtemp_57[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_58, __Vtemp_57, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[0U] 
        = (__Vtemp_55[0U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U] 
                             ^ (__Vtemp_58[0U] ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[1U] 
        = (__Vtemp_55[1U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U] 
                             ^ (__Vtemp_58[1U] ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[2U] 
        = (0xfU & (__Vtemp_55[2U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[2U] 
                                     ^ (__Vtemp_58[2U] 
                                        ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[2U]))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x = 
        (((QData)((IData)(((IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_a_sign_reg)
                            ? (3U & (- (IData)((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_a_reg 
                                                >> 0x1fU))))
                            : 0U))) << 0x20U) | (QData)((IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_a_reg)));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[0U];
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[1U];
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
        = ((0x10U & (tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[0U] 
                     >> 0xfU)) | tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[2U]);
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[0U];
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[1U];
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
        = ((0x10U & (tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[0U] 
                     >> 0xfU)) | tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[2U]);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_17 
        = (0x3ffffffffULL & (((1U == (IData)(tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18)) 
                              | (2U == (IData)(tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18)))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (IData)(tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18)) 
                                  | (6U == (IData)(tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18)))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (IData)(tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (IData)(tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_1 
        = (0x3ffffffffULL & ((1U == (3U & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : ((3U == (3U & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((2U == (3U & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg))
                                      ? VL_SHIFTL_QQI(34,34,32, 
                                                      (1ULL 
                                                       + 
                                                       (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                      : 0ULL))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_2 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 1U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 1U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 1U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 1U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 1U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 1U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 3U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 3U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 3U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 3U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 3U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 3U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_4 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 5U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 5U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 5U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 5U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 5U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 5U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_5 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 7U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 7U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 7U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 7U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 7U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 7U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_6 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 9U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 9U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 9U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 9U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 9U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 9U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_7 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0xbU))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 0xbU))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 0xbU))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 0xbU))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 0xbU)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 0xbU)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_8 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0xdU))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 0xdU))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 0xdU))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 0xdU))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 0xdU)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 0xdU)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_9 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0xfU))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 0xfU))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 0xfU))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 0xfU))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 0xfU)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 0xfU)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_10 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0x11U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 0x11U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 0x11U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 0x11U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 0x11U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 0x11U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_11 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0x13U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 0x13U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 0x13U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 0x13U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 0x13U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 0x13U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_12 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0x15U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 0x15U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 0x15U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 0x15U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 0x15U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 0x15U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_13 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0x17U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 0x17U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 0x17U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 0x17U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 0x17U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 0x17U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_14 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0x19U))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 0x19U))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 0x19U))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 0x19U))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 0x19U)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 0x19U)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_15 
        = (0x3ffffffffULL & (((1U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0x1bU))) 
                              | (2U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                              >> 0x1bU))))
                              ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                >> 0x1bU))) 
                                  | (6U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                  >> 0x1bU))))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (7U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                   >> 0x1bU)))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (7U 
                                                 & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                    >> 0x1bU)))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_16 
        = (0x3ffffffffULL & (((1U == (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                      >> 0x1dU)) | 
                              (2U == (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                      >> 0x1dU))) ? tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x
                              : (((5U == (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                          >> 0x1dU)) 
                                  | (6U == (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                            >> 0x1dU)))
                                  ? (1ULL + (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x))
                                  : ((3U == (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                             >> 0x1dU))
                                      ? VL_SHIFTL_QQI(34,34,32, tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x, 1U)
                                      : ((4U == (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                                 >> 0x1dU))
                                          ? VL_SHIFTL_QQI(34,34,32, 
                                                          (1ULL 
                                                           + 
                                                           (~ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT__x)), 1U)
                                          : 0ULL)))));
    tb_mul_3cycle__DOT__dut__DOT__out52[0U] = (tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                                               ^ tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]);
    tb_mul_3cycle__DOT__dut__DOT__out52[1U] = (tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                                               ^ tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]);
    tb_mul_3cycle__DOT__dut__DOT__out52[2U] = (tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                                               ^ tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]);
    tb_mul_3cycle__DOT__dut__DOT__out51[0U] = ((tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                                                & tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]) 
                                               | ((~ 
                                                   tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[0U]) 
                                                  & tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[0U]));
    tb_mul_3cycle__DOT__dut__DOT__out51[1U] = ((tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                                                & tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]) 
                                               | ((~ 
                                                   tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[1U]) 
                                                  & tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[1U]));
    tb_mul_3cycle__DOT__dut__DOT__out51[2U] = ((tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                                                & tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]) 
                                               | ((~ 
                                                   tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_0[2U]) 
                                                  & ((0x10U 
                                                      & (tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[0U] 
                                                         >> 0xfU)) 
                                                     | tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[2U])));
    tb_mul_3cycle__DOT__dut__DOT__out62[0U] = (tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                                               ^ tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]);
    tb_mul_3cycle__DOT__dut__DOT__out62[1U] = (tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                                               ^ tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]);
    tb_mul_3cycle__DOT__dut__DOT__out62[2U] = (tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                                               ^ tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]);
    tb_mul_3cycle__DOT__dut__DOT__out61[0U] = ((tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                                                & tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]) 
                                               | ((~ 
                                                   tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[0U]) 
                                                  & tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[0U]));
    tb_mul_3cycle__DOT__dut__DOT__out61[1U] = ((tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                                                & tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]) 
                                               | ((~ 
                                                   tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[1U]) 
                                                  & tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[1U]));
    tb_mul_3cycle__DOT__dut__DOT__out61[2U] = ((tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                                                & tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]) 
                                               | ((~ 
                                                   tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_0[2U]) 
                                                  & ((0x10U 
                                                      & (tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[0U] 
                                                         >> 0xfU)) 
                                                     | tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[2U])));
    tb_mul_3cycle__DOT__dut__DOT__pp1[0U] = (IData)(tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_1);
    tb_mul_3cycle__DOT__dut__DOT__pp1[1U] = (((IData)(
                                                      (0x3ffffffffULL 
                                                       & (- (QData)((IData)(
                                                                            (1U 
                                                                             & (IData)(
                                                                                (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_1 
                                                                                >> 0x21U)))))))) 
                                              << 2U) 
                                             | (IData)(
                                                       (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_1 
                                                        >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp1[2U] = (((IData)(
                                                      (0x3ffffffffULL 
                                                       & (- (QData)((IData)(
                                                                            (1U 
                                                                             & (IData)(
                                                                                (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_1 
                                                                                >> 0x21U)))))))) 
                                              >> 0x1eU) 
                                             | ((IData)(
                                                        ((0x3ffffffffULL 
                                                          & (- (QData)((IData)(
                                                                               (1U 
                                                                                & (IData)(
                                                                                (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_1 
                                                                                >> 0x21U))))))) 
                                                         >> 0x20U)) 
                                                << 2U));
    tb_mul_3cycle__DOT__dut__DOT__pp2[0U] = (IData)(
                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_2 
                                                     << 2U));
    tb_mul_3cycle__DOT__dut__DOT__pp2[1U] = (((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_2 
                                                                     >> 0x21U))))) 
                                              << 4U) 
                                             | (IData)(
                                                       ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_2 
                                                         << 2U) 
                                                        >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp2[2U] = ((- (IData)(
                                                        (1U 
                                                         & (IData)(
                                                                   (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_2 
                                                                    >> 0x21U))))) 
                                             >> 0x1cU);
    tb_mul_3cycle__DOT__dut__DOT__pp3[0U] = ((IData)(
                                                     (((QData)((IData)(
                                                                       (0x3fffffffU 
                                                                        & (- (IData)(
                                                                                (1U 
                                                                                & (IData)(
                                                                                (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3 
                                                                                >> 0x21U)))))))) 
                                                       << 0x22U) 
                                                      | tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3)) 
                                             << 4U);
    tb_mul_3cycle__DOT__dut__DOT__pp3[1U] = (((IData)(
                                                      (((QData)((IData)(
                                                                        (0x3fffffffU 
                                                                         & (- (IData)(
                                                                                (1U 
                                                                                & (IData)(
                                                                                (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3 
                                                                                >> 0x21U)))))))) 
                                                        << 0x22U) 
                                                       | tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3)) 
                                              >> 0x1cU) 
                                             | ((IData)(
                                                        ((((QData)((IData)(
                                                                           (0x3fffffffU 
                                                                            & (- (IData)(
                                                                                (1U 
                                                                                & (IData)(
                                                                                (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3 
                                                                                >> 0x21U)))))))) 
                                                           << 0x22U) 
                                                          | tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3) 
                                                         >> 0x20U)) 
                                                << 4U));
    tb_mul_3cycle__DOT__dut__DOT__pp3[2U] = ((IData)(
                                                     ((((QData)((IData)(
                                                                        (0x3fffffffU 
                                                                         & (- (IData)(
                                                                                (1U 
                                                                                & (IData)(
                                                                                (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3 
                                                                                >> 0x21U)))))))) 
                                                        << 0x22U) 
                                                       | tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_3) 
                                                      >> 0x20U)) 
                                             >> 0x1cU);
    tb_mul_3cycle__DOT__dut__DOT__pp4[0U] = (IData)(
                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_4 
                                                     << 6U));
    tb_mul_3cycle__DOT__dut__DOT__pp4[1U] = (((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_4 
                                                                     >> 0x21U))))) 
                                              << 8U) 
                                             | (IData)(
                                                       ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_4 
                                                         << 6U) 
                                                        >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp4[2U] = (0xfU & 
                                             ((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_4 
                                                                     >> 0x21U))))) 
                                              >> 0x18U));
    tb_mul_3cycle__DOT__dut__DOT__pp5[0U] = (IData)(
                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_5 
                                                     << 8U));
    tb_mul_3cycle__DOT__dut__DOT__pp5[1U] = (((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_5 
                                                                     >> 0x21U))))) 
                                              << 0xaU) 
                                             | (IData)(
                                                       ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_5 
                                                         << 8U) 
                                                        >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp5[2U] = (0xfU & 
                                             ((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_5 
                                                                     >> 0x21U))))) 
                                              >> 0x16U));
    tb_mul_3cycle__DOT__dut__DOT__pp6[0U] = (IData)(
                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_6 
                                                     << 0xaU));
    tb_mul_3cycle__DOT__dut__DOT__pp6[1U] = (((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_6 
                                                                     >> 0x21U))))) 
                                              << 0xcU) 
                                             | (IData)(
                                                       ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_6 
                                                         << 0xaU) 
                                                        >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp6[2U] = (0xfU & 
                                             ((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_6 
                                                                     >> 0x21U))))) 
                                              >> 0x14U));
    tb_mul_3cycle__DOT__dut__DOT__pp7[0U] = (IData)(
                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_7 
                                                     << 0xcU));
    tb_mul_3cycle__DOT__dut__DOT__pp7[1U] = (((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_7 
                                                                     >> 0x21U))))) 
                                              << 0xeU) 
                                             | (IData)(
                                                       ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_7 
                                                         << 0xcU) 
                                                        >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp7[2U] = (0xfU & 
                                             ((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_7 
                                                                     >> 0x21U))))) 
                                              >> 0x12U));
    tb_mul_3cycle__DOT__dut__DOT__pp8[0U] = (IData)(
                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_8 
                                                     << 0xeU));
    tb_mul_3cycle__DOT__dut__DOT__pp8[1U] = (((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_8 
                                                                     >> 0x21U))))) 
                                              << 0x10U) 
                                             | (IData)(
                                                       ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_8 
                                                         << 0xeU) 
                                                        >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp8[2U] = (0xfU & 
                                             ((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_8 
                                                                     >> 0x21U))))) 
                                              >> 0x10U));
    tb_mul_3cycle__DOT__dut__DOT__pp9[0U] = (IData)(
                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_9 
                                                     << 0x10U));
    tb_mul_3cycle__DOT__dut__DOT__pp9[1U] = (((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_9 
                                                                     >> 0x21U))))) 
                                              << 0x12U) 
                                             | (IData)(
                                                       ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_9 
                                                         << 0x10U) 
                                                        >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp9[2U] = (0xfU & 
                                             ((- (IData)(
                                                         (1U 
                                                          & (IData)(
                                                                    (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_9 
                                                                     >> 0x21U))))) 
                                              >> 0xeU));
    tb_mul_3cycle__DOT__dut__DOT__pp10[0U] = (IData)(
                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_10 
                                                      << 0x12U));
    tb_mul_3cycle__DOT__dut__DOT__pp10[1U] = (((- (IData)(
                                                          (1U 
                                                           & (IData)(
                                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_10 
                                                                      >> 0x21U))))) 
                                               << 0x14U) 
                                              | (IData)(
                                                        ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_10 
                                                          << 0x12U) 
                                                         >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp10[2U] = (0xfU 
                                              & ((- (IData)(
                                                            (1U 
                                                             & (IData)(
                                                                       (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_10 
                                                                        >> 0x21U))))) 
                                                 >> 0xcU));
    tb_mul_3cycle__DOT__dut__DOT__pp11[0U] = (IData)(
                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_11 
                                                      << 0x14U));
    tb_mul_3cycle__DOT__dut__DOT__pp11[1U] = (((- (IData)(
                                                          (1U 
                                                           & (IData)(
                                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_11 
                                                                      >> 0x21U))))) 
                                               << 0x16U) 
                                              | (IData)(
                                                        ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_11 
                                                          << 0x14U) 
                                                         >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp11[2U] = (0xfU 
                                              & ((- (IData)(
                                                            (1U 
                                                             & (IData)(
                                                                       (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_11 
                                                                        >> 0x21U))))) 
                                                 >> 0xaU));
    tb_mul_3cycle__DOT__dut__DOT__pp12[0U] = (IData)(
                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_12 
                                                      << 0x16U));
    tb_mul_3cycle__DOT__dut__DOT__pp12[1U] = (((- (IData)(
                                                          (1U 
                                                           & (IData)(
                                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_12 
                                                                      >> 0x21U))))) 
                                               << 0x18U) 
                                              | (IData)(
                                                        ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_12 
                                                          << 0x16U) 
                                                         >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp12[2U] = (0xfU 
                                              & ((- (IData)(
                                                            (1U 
                                                             & (IData)(
                                                                       (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_12 
                                                                        >> 0x21U))))) 
                                                 >> 8U));
    tb_mul_3cycle__DOT__dut__DOT__pp13[0U] = (IData)(
                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_13 
                                                      << 0x18U));
    tb_mul_3cycle__DOT__dut__DOT__pp13[1U] = (((- (IData)(
                                                          (1U 
                                                           & (IData)(
                                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_13 
                                                                      >> 0x21U))))) 
                                               << 0x1aU) 
                                              | (IData)(
                                                        ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_13 
                                                          << 0x18U) 
                                                         >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp13[2U] = (0xfU 
                                              & ((- (IData)(
                                                            (1U 
                                                             & (IData)(
                                                                       (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_13 
                                                                        >> 0x21U))))) 
                                                 >> 6U));
    tb_mul_3cycle__DOT__dut__DOT__pp14[0U] = (IData)(
                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_14 
                                                      << 0x1aU));
    tb_mul_3cycle__DOT__dut__DOT__pp14[1U] = (((- (IData)(
                                                          (1U 
                                                           & (IData)(
                                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_14 
                                                                      >> 0x21U))))) 
                                               << 0x1cU) 
                                              | (IData)(
                                                        ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_14 
                                                          << 0x1aU) 
                                                         >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp14[2U] = (0xfU 
                                              & ((- (IData)(
                                                            (1U 
                                                             & (IData)(
                                                                       (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_14 
                                                                        >> 0x21U))))) 
                                                 >> 4U));
    tb_mul_3cycle__DOT__dut__DOT__pp15[0U] = (IData)(
                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_15 
                                                      << 0x1cU));
    tb_mul_3cycle__DOT__dut__DOT__pp15[1U] = (((- (IData)(
                                                          (1U 
                                                           & (IData)(
                                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_15 
                                                                      >> 0x21U))))) 
                                               << 0x1eU) 
                                              | (IData)(
                                                        ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_15 
                                                          << 0x1cU) 
                                                         >> 0x20U)));
    tb_mul_3cycle__DOT__dut__DOT__pp15[2U] = (0xfU 
                                              & ((- (IData)(
                                                            (1U 
                                                             & (IData)(
                                                                       (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_15 
                                                                        >> 0x21U))))) 
                                                 >> 2U));
    tb_mul_3cycle__DOT__dut__DOT__pp16[0U] = (IData)(
                                                     (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_16 
                                                      << 0x1eU));
    tb_mul_3cycle__DOT__dut__DOT__pp16[1U] = (IData)(
                                                     ((tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_16 
                                                       << 0x1eU) 
                                                      >> 0x20U));
    tb_mul_3cycle__DOT__dut__DOT__pp16[2U] = (0xfU 
                                              & (- (IData)(
                                                           (1U 
                                                            & (IData)(
                                                                      (tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_16 
                                                                       >> 0x21U))))));
    __Vtemp_72[0U] = tb_mul_3cycle__DOT__dut__DOT__out51[0U];
    __Vtemp_72[1U] = tb_mul_3cycle__DOT__dut__DOT__out51[1U];
    __Vtemp_72[2U] = tb_mul_3cycle__DOT__dut__DOT__out51[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_73, __Vtemp_72, 1U);
    __Vtemp_76[0U] = tb_mul_3cycle__DOT__dut__DOT__out61[0U];
    __Vtemp_76[1U] = tb_mul_3cycle__DOT__dut__DOT__out61[1U];
    __Vtemp_76[2U] = tb_mul_3cycle__DOT__dut__DOT__out61[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_77, __Vtemp_76, 1U);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[0U] 
        = (((__Vtemp_73[0U] | tb_mul_3cycle__DOT__dut__DOT__out52[0U]) 
            & (__Vtemp_77[0U] | tb_mul_3cycle__DOT__dut__DOT__out62[0U])) 
           << 1U);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[1U] 
        = ((((__Vtemp_73[0U] | tb_mul_3cycle__DOT__dut__DOT__out52[0U]) 
             & (__Vtemp_77[0U] | tb_mul_3cycle__DOT__dut__DOT__out62[0U])) 
            >> 0x1fU) | (((__Vtemp_73[1U] | tb_mul_3cycle__DOT__dut__DOT__out52[1U]) 
                          & (__Vtemp_77[1U] | tb_mul_3cycle__DOT__dut__DOT__out62[1U])) 
                         << 1U));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[2U] 
        = ((((__Vtemp_73[1U] | tb_mul_3cycle__DOT__dut__DOT__out52[1U]) 
             & (__Vtemp_77[1U] | tb_mul_3cycle__DOT__dut__DOT__out62[1U])) 
            >> 0x1fU) | (0x1eU & (((__Vtemp_73[2U] 
                                    | tb_mul_3cycle__DOT__dut__DOT__out52[2U]) 
                                   & (__Vtemp_77[2U] 
                                      | tb_mul_3cycle__DOT__dut__DOT__out62[2U])) 
                                  << 1U)));
    __Vtemp_83[0U] = tb_mul_3cycle__DOT__dut__DOT__out51[0U];
    __Vtemp_83[1U] = tb_mul_3cycle__DOT__dut__DOT__out51[1U];
    __Vtemp_83[2U] = tb_mul_3cycle__DOT__dut__DOT__out51[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_84, __Vtemp_83, 1U);
    __Vtemp_87[0U] = tb_mul_3cycle__DOT__dut__DOT__out61[0U];
    __Vtemp_87[1U] = tb_mul_3cycle__DOT__dut__DOT__out61[1U];
    __Vtemp_87[2U] = tb_mul_3cycle__DOT__dut__DOT__out61[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_88, __Vtemp_87, 1U);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[0U] 
        = ((__Vtemp_84[0U] & tb_mul_3cycle__DOT__dut__DOT__out52[0U]) 
           | (__Vtemp_88[0U] & tb_mul_3cycle__DOT__dut__DOT__out62[0U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[1U] 
        = ((__Vtemp_84[1U] & tb_mul_3cycle__DOT__dut__DOT__out52[1U]) 
           | (__Vtemp_88[1U] & tb_mul_3cycle__DOT__dut__DOT__out62[1U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[2U] 
        = (0xfU & ((__Vtemp_84[2U] & tb_mul_3cycle__DOT__dut__DOT__out52[2U]) 
                   | (__Vtemp_88[2U] & tb_mul_3cycle__DOT__dut__DOT__out62[2U])));
    __Vtemp_93[0U] = tb_mul_3cycle__DOT__dut__DOT__out51[0U];
    __Vtemp_93[1U] = tb_mul_3cycle__DOT__dut__DOT__out51[1U];
    __Vtemp_93[2U] = tb_mul_3cycle__DOT__dut__DOT__out51[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_94, __Vtemp_93, 1U);
    __Vtemp_96[0U] = tb_mul_3cycle__DOT__dut__DOT__out61[0U];
    __Vtemp_96[1U] = tb_mul_3cycle__DOT__dut__DOT__out61[1U];
    __Vtemp_96[2U] = tb_mul_3cycle__DOT__dut__DOT__out61[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_97, __Vtemp_96, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[0U] 
        = (__Vtemp_94[0U] ^ (tb_mul_3cycle__DOT__dut__DOT__out52[0U] 
                             ^ (__Vtemp_97[0U] ^ tb_mul_3cycle__DOT__dut__DOT__out62[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[1U] 
        = (__Vtemp_94[1U] ^ (tb_mul_3cycle__DOT__dut__DOT__out52[1U] 
                             ^ (__Vtemp_97[1U] ^ tb_mul_3cycle__DOT__dut__DOT__out62[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[2U] 
        = (0xfU & (__Vtemp_94[2U] ^ (tb_mul_3cycle__DOT__dut__DOT__out52[2U] 
                                     ^ (__Vtemp_97[2U] 
                                        ^ tb_mul_3cycle__DOT__dut__DOT__out62[2U]))));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w2[0U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp1[0U] & 
            tb_mul_3cycle__DOT__dut__DOT__pp2[0U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp3[0U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp4[0U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w2[1U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp1[1U] & 
            tb_mul_3cycle__DOT__dut__DOT__pp2[1U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp3[1U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp4[1U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w2[2U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp1[2U] & 
            tb_mul_3cycle__DOT__dut__DOT__pp2[2U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp3[2U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp4[2U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[0U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp1[0U] | 
            tb_mul_3cycle__DOT__dut__DOT__pp2[0U]) 
           & (tb_mul_3cycle__DOT__dut__DOT__pp3[0U] 
              | tb_mul_3cycle__DOT__dut__DOT__pp4[0U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[1U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp1[1U] | 
            tb_mul_3cycle__DOT__dut__DOT__pp2[1U]) 
           & (tb_mul_3cycle__DOT__dut__DOT__pp3[1U] 
              | tb_mul_3cycle__DOT__dut__DOT__pp4[1U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[2U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp1[2U] | 
            tb_mul_3cycle__DOT__dut__DOT__pp2[2U]) 
           & (tb_mul_3cycle__DOT__dut__DOT__pp3[2U] 
              | tb_mul_3cycle__DOT__dut__DOT__pp4[2U]));
    tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w1[0U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp1[0U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp2[0U] ^ 
            (tb_mul_3cycle__DOT__dut__DOT__pp3[0U] 
             ^ tb_mul_3cycle__DOT__dut__DOT__pp4[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w1[1U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp1[1U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp2[1U] ^ 
            (tb_mul_3cycle__DOT__dut__DOT__pp3[1U] 
             ^ tb_mul_3cycle__DOT__dut__DOT__pp4[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w1[2U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp1[2U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp2[2U] ^ 
            (tb_mul_3cycle__DOT__dut__DOT__pp3[2U] 
             ^ tb_mul_3cycle__DOT__dut__DOT__pp4[2U])));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1[0U] 
        = (((tb_mul_3cycle__DOT__dut__DOT__pp5[0U] 
             | tb_mul_3cycle__DOT__dut__DOT__pp6[0U]) 
            & (tb_mul_3cycle__DOT__dut__DOT__pp7[0U] 
               | tb_mul_3cycle__DOT__dut__DOT__pp8[0U])) 
           << 1U);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1[1U] 
        = ((((tb_mul_3cycle__DOT__dut__DOT__pp5[0U] 
              | tb_mul_3cycle__DOT__dut__DOT__pp6[0U]) 
             & (tb_mul_3cycle__DOT__dut__DOT__pp7[0U] 
                | tb_mul_3cycle__DOT__dut__DOT__pp8[0U])) 
            >> 0x1fU) | (((tb_mul_3cycle__DOT__dut__DOT__pp5[1U] 
                           | tb_mul_3cycle__DOT__dut__DOT__pp6[1U]) 
                          & (tb_mul_3cycle__DOT__dut__DOT__pp7[1U] 
                             | tb_mul_3cycle__DOT__dut__DOT__pp8[1U])) 
                         << 1U));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1[2U] 
        = ((((tb_mul_3cycle__DOT__dut__DOT__pp5[1U] 
              | tb_mul_3cycle__DOT__dut__DOT__pp6[1U]) 
             & (tb_mul_3cycle__DOT__dut__DOT__pp7[1U] 
                | tb_mul_3cycle__DOT__dut__DOT__pp8[1U])) 
            >> 0x1fU) | (((tb_mul_3cycle__DOT__dut__DOT__pp5[2U] 
                           | tb_mul_3cycle__DOT__dut__DOT__pp6[2U]) 
                          & (tb_mul_3cycle__DOT__dut__DOT__pp7[2U] 
                             | tb_mul_3cycle__DOT__dut__DOT__pp8[2U])) 
                         << 1U));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w2[0U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp5[0U] & 
            tb_mul_3cycle__DOT__dut__DOT__pp6[0U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp7[0U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp8[0U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w2[1U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp5[1U] & 
            tb_mul_3cycle__DOT__dut__DOT__pp6[1U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp7[1U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp8[1U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w2[2U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp5[2U] & 
            tb_mul_3cycle__DOT__dut__DOT__pp6[2U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp7[2U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp8[2U]));
    tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w1[0U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp5[0U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp6[0U] ^ 
            (tb_mul_3cycle__DOT__dut__DOT__pp7[0U] 
             ^ tb_mul_3cycle__DOT__dut__DOT__pp8[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w1[1U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp5[1U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp6[1U] ^ 
            (tb_mul_3cycle__DOT__dut__DOT__pp7[1U] 
             ^ tb_mul_3cycle__DOT__dut__DOT__pp8[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w1[2U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp5[2U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp6[2U] ^ 
            (tb_mul_3cycle__DOT__dut__DOT__pp7[2U] 
             ^ tb_mul_3cycle__DOT__dut__DOT__pp8[2U])));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1[0U] 
        = (((tb_mul_3cycle__DOT__dut__DOT__pp9[0U] 
             | tb_mul_3cycle__DOT__dut__DOT__pp10[0U]) 
            & (tb_mul_3cycle__DOT__dut__DOT__pp11[0U] 
               | tb_mul_3cycle__DOT__dut__DOT__pp12[0U])) 
           << 1U);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1[1U] 
        = ((((tb_mul_3cycle__DOT__dut__DOT__pp9[0U] 
              | tb_mul_3cycle__DOT__dut__DOT__pp10[0U]) 
             & (tb_mul_3cycle__DOT__dut__DOT__pp11[0U] 
                | tb_mul_3cycle__DOT__dut__DOT__pp12[0U])) 
            >> 0x1fU) | (((tb_mul_3cycle__DOT__dut__DOT__pp9[1U] 
                           | tb_mul_3cycle__DOT__dut__DOT__pp10[1U]) 
                          & (tb_mul_3cycle__DOT__dut__DOT__pp11[1U] 
                             | tb_mul_3cycle__DOT__dut__DOT__pp12[1U])) 
                         << 1U));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1[2U] 
        = ((((tb_mul_3cycle__DOT__dut__DOT__pp9[1U] 
              | tb_mul_3cycle__DOT__dut__DOT__pp10[1U]) 
             & (tb_mul_3cycle__DOT__dut__DOT__pp11[1U] 
                | tb_mul_3cycle__DOT__dut__DOT__pp12[1U])) 
            >> 0x1fU) | (((tb_mul_3cycle__DOT__dut__DOT__pp9[2U] 
                           | tb_mul_3cycle__DOT__dut__DOT__pp10[2U]) 
                          & (tb_mul_3cycle__DOT__dut__DOT__pp11[2U] 
                             | tb_mul_3cycle__DOT__dut__DOT__pp12[2U])) 
                         << 1U));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w2[0U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp9[0U] & 
            tb_mul_3cycle__DOT__dut__DOT__pp10[0U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp11[0U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp12[0U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w2[1U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp9[1U] & 
            tb_mul_3cycle__DOT__dut__DOT__pp10[1U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp11[1U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp12[1U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w2[2U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp9[2U] & 
            tb_mul_3cycle__DOT__dut__DOT__pp10[2U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp11[2U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp12[2U]));
    tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w1[0U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp9[0U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp10[0U] 
            ^ (tb_mul_3cycle__DOT__dut__DOT__pp11[0U] 
               ^ tb_mul_3cycle__DOT__dut__DOT__pp12[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w1[1U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp9[1U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp10[1U] 
            ^ (tb_mul_3cycle__DOT__dut__DOT__pp11[1U] 
               ^ tb_mul_3cycle__DOT__dut__DOT__pp12[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w1[2U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp9[2U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp10[2U] 
            ^ (tb_mul_3cycle__DOT__dut__DOT__pp11[2U] 
               ^ tb_mul_3cycle__DOT__dut__DOT__pp12[2U])));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1[0U] 
        = (((tb_mul_3cycle__DOT__dut__DOT__pp13[0U] 
             | tb_mul_3cycle__DOT__dut__DOT__pp14[0U]) 
            & (tb_mul_3cycle__DOT__dut__DOT__pp15[0U] 
               | tb_mul_3cycle__DOT__dut__DOT__pp16[0U])) 
           << 1U);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1[1U] 
        = ((((tb_mul_3cycle__DOT__dut__DOT__pp13[0U] 
              | tb_mul_3cycle__DOT__dut__DOT__pp14[0U]) 
             & (tb_mul_3cycle__DOT__dut__DOT__pp15[0U] 
                | tb_mul_3cycle__DOT__dut__DOT__pp16[0U])) 
            >> 0x1fU) | (((tb_mul_3cycle__DOT__dut__DOT__pp13[1U] 
                           | tb_mul_3cycle__DOT__dut__DOT__pp14[1U]) 
                          & (tb_mul_3cycle__DOT__dut__DOT__pp15[1U] 
                             | tb_mul_3cycle__DOT__dut__DOT__pp16[1U])) 
                         << 1U));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1[2U] 
        = ((((tb_mul_3cycle__DOT__dut__DOT__pp13[1U] 
              | tb_mul_3cycle__DOT__dut__DOT__pp14[1U]) 
             & (tb_mul_3cycle__DOT__dut__DOT__pp15[1U] 
                | tb_mul_3cycle__DOT__dut__DOT__pp16[1U])) 
            >> 0x1fU) | (((tb_mul_3cycle__DOT__dut__DOT__pp13[2U] 
                           | tb_mul_3cycle__DOT__dut__DOT__pp14[2U]) 
                          & (tb_mul_3cycle__DOT__dut__DOT__pp15[2U] 
                             | tb_mul_3cycle__DOT__dut__DOT__pp16[2U])) 
                         << 1U));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w2[0U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp13[0U] 
            & tb_mul_3cycle__DOT__dut__DOT__pp14[0U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp15[0U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp16[0U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w2[1U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp13[1U] 
            & tb_mul_3cycle__DOT__dut__DOT__pp14[1U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp15[1U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp16[1U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w2[2U] 
        = ((tb_mul_3cycle__DOT__dut__DOT__pp13[2U] 
            & tb_mul_3cycle__DOT__dut__DOT__pp14[2U]) 
           | (tb_mul_3cycle__DOT__dut__DOT__pp15[2U] 
              & tb_mul_3cycle__DOT__dut__DOT__pp16[2U]));
    tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w1[0U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp13[0U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp14[0U] 
            ^ (tb_mul_3cycle__DOT__dut__DOT__pp15[0U] 
               ^ tb_mul_3cycle__DOT__dut__DOT__pp16[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w1[1U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp13[1U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp14[1U] 
            ^ (tb_mul_3cycle__DOT__dut__DOT__pp15[1U] 
               ^ tb_mul_3cycle__DOT__dut__DOT__pp16[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w1[2U] 
        = (tb_mul_3cycle__DOT__dut__DOT__pp13[2U] ^ 
           (tb_mul_3cycle__DOT__dut__DOT__pp14[2U] 
            ^ (tb_mul_3cycle__DOT__dut__DOT__pp15[2U] 
               ^ tb_mul_3cycle__DOT__dut__DOT__pp16[2U])));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[0U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[1U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
        = ((0x10U & (tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[0U] 
                     >> 0xfU)) | tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[2U]);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w1[0U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w1[1U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
        = ((0x10U & (tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w1[0U] 
                     >> 0xfU)) | tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w1[2U]);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w1[0U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w1[1U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
        = ((0x10U & (tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w1[0U] 
                     >> 0xfU)) | tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w1[2U]);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w1[0U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w1[1U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
        = ((0x10U & (tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w1[0U] 
                     >> 0xfU)) | tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w1[2U]);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w1[0U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
        = tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w1[1U];
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
        = ((0x10U & (tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w1[0U] 
                     >> 0xfU)) | tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w1[2U]);
}

VL_ATTR_COLD void Vtb_mul_3cycle___024root___eval_triggers__stl(Vtb_mul_3cycle___024root* vlSelf);

VL_ATTR_COLD bool Vtb_mul_3cycle___024root___eval_phase__stl(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_phase__stl\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtb_mul_3cycle___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelfRef.__VstlTriggered.any();
    if (__VstlExecute) {
        Vtb_mul_3cycle___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mul_3cycle___024root___dump_triggers__act(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___dump_triggers__act\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge tb_mul_3cycle.clk or negedge tb_mul_3cycle.rst_n)\n");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((4ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 2 is active: @(posedge tb_mul_3cycle.clk)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mul_3cycle___024root___dump_triggers__nba(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___dump_triggers__nba\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge tb_mul_3cycle.clk or negedge tb_mul_3cycle.rst_n)\n");
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((4ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 2 is active: @(posedge tb_mul_3cycle.clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_mul_3cycle___024root___ctor_var_reset(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___ctor_var_reset\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelf->tb_mul_3cycle__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->tb_mul_3cycle__DOT__rst_n = VL_RAND_RESET_I(1);
    vlSelf->tb_mul_3cycle__DOT__mul_a_i = VL_RAND_RESET_I(32);
    vlSelf->tb_mul_3cycle__DOT__mul_b_i = VL_RAND_RESET_I(32);
    vlSelf->tb_mul_3cycle__DOT__mul_a_sign = VL_RAND_RESET_I(1);
    vlSelf->tb_mul_3cycle__DOT__mul_b_sign = VL_RAND_RESET_I(1);
    vlSelf->tb_mul_3cycle__DOT__mul_start = VL_RAND_RESET_I(1);
    vlSelf->tb_mul_3cycle__DOT__dut__DOT__state = VL_RAND_RESET_I(2);
    vlSelf->tb_mul_3cycle__DOT__dut__DOT__next_state = VL_RAND_RESET_I(2);
    vlSelf->tb_mul_3cycle__DOT__dut__DOT__mul_a_reg = VL_RAND_RESET_I(32);
    vlSelf->tb_mul_3cycle__DOT__dut__DOT__mul_b_reg = VL_RAND_RESET_I(32);
    vlSelf->tb_mul_3cycle__DOT__dut__DOT__mul_a_sign_reg = VL_RAND_RESET_I(1);
    vlSelf->tb_mul_3cycle__DOT__dut__DOT__mul_b_sign_reg = VL_RAND_RESET_I(1);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage1_out11);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage1_out12);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage1_out21);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage1_out22);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage1_out31);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage1_out32);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage1_out41);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage1_out42);
    VL_RAND_RESET_W(68, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage1_pp17);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage2_out71);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage2_out72);
    VL_RAND_RESET_W(68, vlSelf->tb_mul_3cycle__DOT__dut__DOT__stage2_pp17);
    vlSelf->tb_mul_3cycle__DOT__dut__DOT__result_reg = VL_RAND_RESET_Q(64);
    vlSelf->tb_mul_3cycle__DOT__dut__DOT__done_reg = VL_RAND_RESET_I(1);
    vlSelf->tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_17 = VL_RAND_RESET_Q(34);
    VL_RAND_RESET_W(68, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w2);
    VL_RAND_RESET_W(68, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0);
    VL_RAND_RESET_W(68, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w2);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1);
    VL_RAND_RESET_W(68, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w2);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1);
    VL_RAND_RESET_W(68, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w2);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1);
    VL_RAND_RESET_W(68, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0);
    VL_RAND_RESET_W(69, vlSelf->tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1);
    vlSelf->__Vtrigprevexpr___TOP__tb_mul_3cycle__DOT__clk__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__tb_mul_3cycle__DOT__rst_n__0 = VL_RAND_RESET_I(1);
}
