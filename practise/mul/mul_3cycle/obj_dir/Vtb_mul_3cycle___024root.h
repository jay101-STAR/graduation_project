// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mul_3cycle.h for the primary calling header

#ifndef VERILATED_VTB_MUL_3CYCLE___024ROOT_H_
#define VERILATED_VTB_MUL_3CYCLE___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_mul_3cycle__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mul_3cycle___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ tb_mul_3cycle__DOT__clk;
    CData/*0:0*/ tb_mul_3cycle__DOT__rst_n;
    CData/*0:0*/ tb_mul_3cycle__DOT__mul_a_sign;
    CData/*0:0*/ tb_mul_3cycle__DOT__mul_b_sign;
    CData/*0:0*/ tb_mul_3cycle__DOT__mul_start;
    CData/*1:0*/ tb_mul_3cycle__DOT__dut__DOT__state;
    CData/*1:0*/ tb_mul_3cycle__DOT__dut__DOT__next_state;
    CData/*0:0*/ tb_mul_3cycle__DOT__dut__DOT__mul_a_sign_reg;
    CData/*0:0*/ tb_mul_3cycle__DOT__dut__DOT__mul_b_sign_reg;
    CData/*0:0*/ tb_mul_3cycle__DOT__dut__DOT__done_reg;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_mul_3cycle__DOT__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_mul_3cycle__DOT__rst_n__0;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ tb_mul_3cycle__DOT__mul_a_i;
    IData/*31:0*/ tb_mul_3cycle__DOT__mul_b_i;
    IData/*31:0*/ tb_mul_3cycle__DOT__dut__DOT__mul_a_reg;
    IData/*31:0*/ tb_mul_3cycle__DOT__dut__DOT__mul_b_reg;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage1_out11;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage1_out12;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage1_out21;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage1_out22;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage1_out31;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage1_out32;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage1_out41;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage1_out42;
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__stage1_pp17;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage2_out71;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__stage2_out72;
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__stage2_pp17;
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w2;
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0;
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w2;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1;
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w2;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1;
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w2;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1;
    VlWide<3>/*67:0*/ tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0;
    VlWide<3>/*68:0*/ tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1;
    IData/*31:0*/ __VactIterCount;
    QData/*63:0*/ tb_mul_3cycle__DOT__dut__DOT__result_reg;
    QData/*33:0*/ tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_17;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h91307ded__0;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<3> __VactTriggered;
    VlTriggerVec<3> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vtb_mul_3cycle__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vtb_mul_3cycle___024root(Vtb_mul_3cycle__Syms* symsp, const char* v__name);
    ~Vtb_mul_3cycle___024root();
    VL_UNCOPYABLE(Vtb_mul_3cycle___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
