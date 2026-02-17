// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mul_3cycle.h for the primary calling header

#include "Vtb_mul_3cycle__pch.h"
#include "Vtb_mul_3cycle___024root.h"

VL_ATTR_COLD void Vtb_mul_3cycle___024root___eval_initial__TOP(Vtb_mul_3cycle___024root* vlSelf);
VlCoroutine Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__0(Vtb_mul_3cycle___024root* vlSelf);
VlCoroutine Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__1(Vtb_mul_3cycle___024root* vlSelf);
VlCoroutine Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__2(Vtb_mul_3cycle___024root* vlSelf);

void Vtb_mul_3cycle___024root___eval_initial(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_initial\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_mul_3cycle___024root___eval_initial__TOP(vlSelf);
    Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__2(vlSelf);
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mul_3cycle__DOT__clk__0 
        = vlSelfRef.tb_mul_3cycle__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mul_3cycle__DOT__rst_n__0 
        = vlSelfRef.tb_mul_3cycle__DOT__rst_n;
}

VL_INLINE_OPT VlCoroutine Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__0(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__0\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_mul_3cycle__DOT__clk = 0U;
    while (1U) {
        co_await vlSelfRef.__VdlySched.delay(0x1388ULL, 
                                             nullptr, 
                                             "tb_mul_3cycle.v", 
                                             58);
        vlSelfRef.tb_mul_3cycle__DOT__clk = (1U & (~ (IData)(vlSelfRef.tb_mul_3cycle__DOT__clk)));
    }
}

VL_INLINE_OPT VlCoroutine Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__1(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__1\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ tb_mul_3cycle__DOT__test_count;
    tb_mul_3cycle__DOT__test_count = 0;
    IData/*31:0*/ tb_mul_3cycle__DOT__pass_count;
    tb_mul_3cycle__DOT__pass_count = 0;
    IData/*31:0*/ tb_mul_3cycle__DOT__fail_count;
    tb_mul_3cycle__DOT__fail_count = 0;
    QData/*63:0*/ tb_mul_3cycle__DOT__expected_result;
    tb_mul_3cycle__DOT__expected_result = 0;
    IData/*31:0*/ tb_mul_3cycle__DOT____Vrepeat0;
    tb_mul_3cycle__DOT____Vrepeat0 = 0;
    IData/*31:0*/ tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 0;
    IData/*31:0*/ tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 0;
    CData/*0:0*/ tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign = 0;
    CData/*0:0*/ tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__0__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__1__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__2__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__3__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__4__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__5__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__6__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__7__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__8__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__9__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__10__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__11__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__12__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__13__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__14__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__15__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__16__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__17__test_name;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a = 0;
    IData/*31:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed = 0;
    CData/*0:0*/ __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed = 0;
    std::string __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name;
    // Body
    tb_mul_3cycle__DOT__test_count = 0U;
    tb_mul_3cycle__DOT__pass_count = 0U;
    tb_mul_3cycle__DOT__fail_count = 0U;
    vlSelfRef.tb_mul_3cycle__DOT__rst_n = 0U;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = 0U;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = 0U;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = 0U;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = 0U;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    VL_WRITEF_NX("============================================================\n3\345\221\250\346\234\237\344\271\230\346\263\225\345\231\250\346\265\213\350\257\225\345\274\200\345\247\213\n============================================================\n\n",0);
    co_await vlSelfRef.__VdlySched.delay(0x4e20ULL, 
                                         nullptr, "tb_mul_3cycle.v", 
                                         140);
    vlSelfRef.tb_mul_3cycle__DOT__rst_n = 1U;
    co_await vlSelfRef.__VdlySched.delay(0x4e20ULL, 
                                         nullptr, "tb_mul_3cycle.v", 
                                         142);
    VL_WRITEF_NX("------------------------------------------------------------\n\346\265\213\350\257\225\347\273\204 1: \345\237\272\346\234\254\346\227\240\347\254\246\345\217\267\344\271\230\346\263\225\n------------------------------------------------------------\n",0);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__0__test_name = 
        std::string{"0 * 0"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a = 0U;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__0__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__0__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel1;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel1: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__0__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__0__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__0__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__0__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__0__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__0__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__0__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__1__test_name = 
        std::string{"1 * 1"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a = 1U;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__1__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__1__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel2;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel2: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__1__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__1__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__1__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__1__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__1__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__1__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__1__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__2__test_name = 
        std::string{"2 * 3"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b = 3U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a = 2U;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__2__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__2__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel3;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel3: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__2__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__2__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__2__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__2__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__2__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__2__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__2__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__3__test_name = 
        std::string{"10 * 20"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b = 0x14U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a = 0xaU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__3__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__3__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel4;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel4: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__3__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__3__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__3__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__3__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__3__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__3__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__3__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__4__test_name = 
        std::string{"100 * 100"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b = 0x64U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a = 0x64U;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__4__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__4__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel5;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel5: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__4__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__4__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__4__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__4__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__4__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__4__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__4__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    VL_WRITEF_NX("------------------------------------------------------------\n\346\265\213\350\257\225\347\273\204 2: \350\276\271\347\225\214\345\200\274\346\265\213\350\257\225\357\274\210\346\227\240\347\254\246\345\217\267\357\274\211\n------------------------------------------------------------\n",0);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__5__test_name = 
        std::string{"MAX_UINT * 1"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a = 0xffffffffU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__5__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__5__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel6;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel6: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__5__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__5__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__5__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__5__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__5__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__5__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__5__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__6__test_name = 
        std::string{"MAX_UINT * MAX_UINT"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b = 0xffffffffU;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a = 0xffffffffU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__6__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__6__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel7;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel7: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__6__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__6__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__6__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__6__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__6__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__6__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__6__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__7__test_name = 
        std::string{"2^31 * 2"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b = 2U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a = 0x80000000U;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__7__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__7__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel8;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel8: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__7__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__7__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__7__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__7__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__7__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__7__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__7__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    VL_WRITEF_NX("------------------------------------------------------------\n\346\265\213\350\257\225\347\273\204 3: \345\237\272\346\234\254\346\234\211\347\254\246\345\217\267\344\271\230\346\263\225\n------------------------------------------------------------\n",0);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__8__test_name = 
        std::string{"signed: 1 * 1"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a = 1U;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__8__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__8__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel9;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel9: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__8__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__8__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__8__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__8__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__8__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__8__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__8__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__9__test_name = 
        std::string{"signed: -1 * 1"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a = 0xffffffffU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__9__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__9__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel10;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel10: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__9__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__9__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__9__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__9__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__9__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__9__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__9__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__10__test_name = 
        std::string{"signed: -1 * -1"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b = 0xffffffffU;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a = 0xffffffffU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__10__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__10__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel11;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel11: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__10__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__10__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__10__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__10__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__10__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__10__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__10__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__11__test_name = 
        std::string{"signed: -5 * 10"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b = 0xaU;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a = 0xfffffffbU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__11__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__11__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel12;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel12: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__11__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__11__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__11__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__11__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__11__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__11__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__11__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    VL_WRITEF_NX("------------------------------------------------------------\n\346\265\213\350\257\225\347\273\204 4: \346\234\211\347\254\246\345\217\267\350\276\271\347\225\214\345\200\274\n------------------------------------------------------------\n",0);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__12__test_name = 
        std::string{"signed: MAX_INT * 1"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a = 0x7fffffffU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__12__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__12__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel13;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel13: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__12__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__12__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__12__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__12__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__12__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__12__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__12__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__13__test_name = 
        std::string{"signed: MIN_INT * 1"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a = 0x80000000U;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__13__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__13__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel14;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel14: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__13__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__13__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__13__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__13__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__13__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__13__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__13__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__14__test_name = 
        std::string{"signed: MAX_INT * MAX_INT"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b = 0x7fffffffU;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a = 0x7fffffffU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__14__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__14__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel15;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel15: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__14__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__14__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__14__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__14__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__14__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__14__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__14__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    VL_WRITEF_NX("------------------------------------------------------------\n\346\265\213\350\257\225\347\273\204 5: \346\234\211\347\254\246\345\217\267\303\227\346\227\240\347\254\246\345\217\267 (MULHSU)\n------------------------------------------------------------\n",0);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__15__test_name = 
        std::string{"MULHSU: 10 * 20"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b = 0x14U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a = 0xaU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__15__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__15__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel16;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel16: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__15__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__15__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__15__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__15__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__15__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__15__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__15__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__16__test_name = 
        std::string{"MULHSU: -5 * 10"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b = 0xaU;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a = 0xfffffffbU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__16__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__16__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel17;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel17: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__16__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__16__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__16__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__16__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__16__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__16__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__16__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    __Vtask_tb_mul_3cycle__DOT__test_multiply__17__test_name = 
        std::string{"MULHSU: MAX_INT * MAX_UINT"};
    __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b_signed = 0U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a_signed = 1U;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b = 0xffffffffU;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a = 0x7fffffffU;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__b))))));
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__17__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__17__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel18;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel18: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__17__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__17__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__17__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__17__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__17__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__17__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__17__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    VL_WRITEF_NX("------------------------------------------------------------\n\346\265\213\350\257\225\347\273\204 6: \351\232\217\346\234\272\346\265\213\350\257\225 (20 cases)\n------------------------------------------------------------\n",0);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_0: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel19;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel19: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_1: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel20;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel20: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_2: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel21;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel21: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_3: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel22;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel22: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_4: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel23;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel23: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_5: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel24;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel24: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_6: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel25;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel25: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_7: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel26;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel26: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_8: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel27;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel27: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_9: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel28;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel28: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_10: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel29;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel29: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_11: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel30;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel30: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_12: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel31;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel31: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_13: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel32;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel32: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_14: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel33;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel33: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_15: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel34;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel34: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_16: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel35;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel35: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_17: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel36;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel36: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_18: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel37;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel37: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b = 
        VL_RANDOM_I();
    tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign 
        = (1U & VL_MODDIVS_III(32, (IData)(VL_RANDOM_I()), (IData)(2U)));
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name 
        = VL_SFORMATF_N_NX("random_19: 0x%x * 0x%x (%s\303\227%s)",0,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_a,
                           32,tb_mul_3cycle__DOT__random_tests__DOT__rand_b,
                           8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign)
                               ? 0x53U : 0x55U),8,((IData)(tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign)
                                                    ? 0x53U
                                                    : 0x55U)) ;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a_sign;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_b;
    __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a 
        = tb_mul_3cycle__DOT__random_tests__DOT__rand_a;
    tb_mul_3cycle__DOT__expected_result = (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                            & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                            ? VL_MULS_QQQ(64, 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                          VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                            : (((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed) 
                                                & (~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed)))
                                                ? VL_MULS_QQQ(64, 
                                                              VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a), 
                                                              VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))
                                                : (
                                                   ((~ (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed)) 
                                                    & (IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed))
                                                    ? 
                                                   VL_MULS_QQQ(64, 
                                                               VL_EXTENDS_QQ(64,33, (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a))), 
                                                               VL_EXTENDS_QI(64,32, __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))
                                                    : 
                                                   ((QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a)) 
                                                    * (QData)((IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b))))));
    tb_mul_3cycle__DOT__test_count = ((IData)(1U) + tb_mul_3cycle__DOT__test_count);
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_i = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b;
    vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign = __Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed;
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 1U;
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         90);
    vlSelfRef.tb_mul_3cycle__DOT__mul_start = 0U;
    tb_mul_3cycle__DOT____Vrepeat0 = 5U;
    {
        while (VL_LTS_III(32, 0U, tb_mul_3cycle__DOT____Vrepeat0)) {
            co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_mul_3cycle.clk)", 
                                                                 "tb_mul_3cycle.v", 
                                                                 95);
            if (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg) {
                goto __Vlabel38;
            }
            tb_mul_3cycle__DOT____Vrepeat0 = (tb_mul_3cycle__DOT____Vrepeat0 
                                              - (IData)(1U));
        }
        __Vlabel38: ;
    }
    if ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
         == tb_mul_3cycle__DOT__expected_result)) {
        tb_mul_3cycle__DOT__pass_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__pass_count);
        VL_WRITEF_NX("[PASS] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result=0x%x (expected=0x%x)\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    } else {
        tb_mul_3cycle__DOT__fail_count = ((IData)(1U) 
                                          + tb_mul_3cycle__DOT__fail_count);
        VL_WRITEF_NX("[FAIL] Test %0d: %@\n       a=0x%x, b=0x%x, a_sign=%b, b_sign=%b\n       result  =0x%x\n       expected=0x%x\n",0,
                     32,tb_mul_3cycle__DOT__test_count,
                     -1,&(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__test_name),
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a,
                     32,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b,
                     1,(IData)(__Vtask_tb_mul_3cycle__DOT__test_multiply__18__a_signed),
                     1,__Vtask_tb_mul_3cycle__DOT__test_multiply__18__b_signed,
                     64,vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg,
                     64,tb_mul_3cycle__DOT__expected_result);
    }
    VL_WRITEF_NX("\n",0);
    co_await vlSelfRef.__VtrigSched_h91307ded__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mul_3cycle.clk)", 
                                                         "tb_mul_3cycle.v", 
                                                         115);
    VL_WRITEF_NX("============================================================\n\346\265\213\350\257\225\345\256\214\346\210\220\n============================================================\n\346\200\273\346\265\213\350\257\225\346\225\260: %0d\n\351\200\232\350\277\207\346\225\260\351\207\217: %0d\n\345\244\261\350\264\245\346\225\260\351\207\217: %0d\n",0,
                 32,tb_mul_3cycle__DOT__test_count,
                 32,tb_mul_3cycle__DOT__pass_count,
                 32,tb_mul_3cycle__DOT__fail_count);
    if (VL_UNLIKELY(VL_LTS_III(32, 0U, tb_mul_3cycle__DOT__test_count))) {
        VL_WRITEF_NX("\351\200\232\350\277\207\347\216\207: %0.2f%%\n",0,
                     64,((100.0 * VL_ISTOR_D_I(32, tb_mul_3cycle__DOT__pass_count)) 
                         / VL_ISTOR_D_I(32, tb_mul_3cycle__DOT__test_count)));
    }
    VL_WRITEF_NX("============================================================\n",0);
    if ((0U == tb_mul_3cycle__DOT__fail_count)) {
        VL_WRITEF_NX("\342\234\223 \346\211\200\346\234\211\346\265\213\350\257\225\351\200\232\350\277\207\357\274\2013\345\221\250\346\234\237\344\271\230\346\263\225\345\231\250\345\212\237\350\203\275\346\255\243\347\241\256\n",0);
    } else {
        VL_WRITEF_NX("\342\234\227 \345\217\221\347\216\260 %0d \344\270\252\351\224\231\350\257\257\357\274\214\351\234\200\350\246\201\350\260\203\350\257\225\n",0,
                     32,tb_mul_3cycle__DOT__fail_count);
    }
    VL_WRITEF_NX("============================================================\n",0);
    co_await vlSelfRef.__VdlySched.delay(0xc350ULL, 
                                         nullptr, "tb_mul_3cycle.v", 
                                         249);
    VL_FINISH_MT("tb_mul_3cycle.v", 250, "");
}

VL_INLINE_OPT VlCoroutine Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__2(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_initial__TOP__Vtiming__2\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0x5f5e100ULL, 
                                         nullptr, "tb_mul_3cycle.v", 
                                         265);
    VL_WRITEF_NX("ERROR: Simulation timeout!\n",0);
    VL_FINISH_MT("tb_mul_3cycle.v", 267, "");
}

void Vtb_mul_3cycle___024root___act_comb__TOP__0(Vtb_mul_3cycle___024root* vlSelf);

void Vtb_mul_3cycle___024root___eval_act(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_act\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((6ULL & vlSelfRef.__VactTriggered.word(0U))) {
        Vtb_mul_3cycle___024root___act_comb__TOP__0(vlSelf);
    }
}

extern const VlUnpacked<CData/*1:0*/, 8> Vtb_mul_3cycle__ConstPool__TABLE_hfd730721_0;

VL_INLINE_OPT void Vtb_mul_3cycle___024root___act_comb__TOP__0(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___act_comb__TOP__0\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*2:0*/ __Vtableidx1;
    __Vtableidx1 = 0;
    // Body
    __Vtableidx1 = (((IData)(vlSelfRef.tb_mul_3cycle__DOT__mul_start) 
                     << 2U) | (IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__state));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__next_state 
        = Vtb_mul_3cycle__ConstPool__TABLE_hfd730721_0
        [__Vtableidx1];
}

void Vtb_mul_3cycle___024root___nba_sequent__TOP__0(Vtb_mul_3cycle___024root* vlSelf);

void Vtb_mul_3cycle___024root___eval_nba(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_nba\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vtb_mul_3cycle___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((7ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vtb_mul_3cycle___024root___act_comb__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Vtb_mul_3cycle___024root___nba_sequent__TOP__0(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___nba_sequent__TOP__0\n"); );
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
    VlWide<3>/*95:0*/ __Vtemp_20;
    VlWide<3>/*95:0*/ __Vtemp_21;
    VlWide<3>/*95:0*/ __Vtemp_24;
    VlWide<3>/*95:0*/ __Vtemp_25;
    VlWide<3>/*95:0*/ __Vtemp_29;
    VlWide<3>/*95:0*/ __Vtemp_30;
    VlWide<3>/*95:0*/ __Vtemp_34;
    VlWide<3>/*95:0*/ __Vtemp_35;
    VlWide<3>/*95:0*/ __Vtemp_38;
    VlWide<3>/*95:0*/ __Vtemp_39;
    VlWide<3>/*95:0*/ __Vtemp_42;
    VlWide<3>/*95:0*/ __Vtemp_43;
    VlWide<3>/*95:0*/ __Vtemp_48;
    VlWide<3>/*95:0*/ __Vtemp_49;
    VlWide<3>/*95:0*/ __Vtemp_52;
    VlWide<3>/*95:0*/ __Vtemp_53;
    VlWide<3>/*95:0*/ __Vtemp_59;
    VlWide<3>/*95:0*/ __Vtemp_60;
    VlWide<3>/*95:0*/ __Vtemp_62;
    VlWide<3>/*95:0*/ __Vtemp_63;
    VlWide<3>/*95:0*/ __Vtemp_69;
    VlWide<3>/*95:0*/ __Vtemp_70;
    VlWide<3>/*95:0*/ __Vtemp_73;
    VlWide<3>/*95:0*/ __Vtemp_74;
    VlWide<3>/*95:0*/ __Vtemp_79;
    VlWide<3>/*95:0*/ __Vtemp_80;
    VlWide<3>/*95:0*/ __Vtemp_83;
    VlWide<3>/*95:0*/ __Vtemp_84;
    VlWide<3>/*95:0*/ __Vtemp_90;
    VlWide<3>/*95:0*/ __Vtemp_91;
    VlWide<3>/*95:0*/ __Vtemp_93;
    VlWide<3>/*95:0*/ __Vtemp_94;
    VlWide<3>/*95:0*/ __Vtemp_113;
    VlWide<3>/*95:0*/ __Vtemp_114;
    VlWide<3>/*95:0*/ __Vtemp_117;
    VlWide<3>/*95:0*/ __Vtemp_118;
    VlWide<3>/*95:0*/ __Vtemp_124;
    VlWide<3>/*95:0*/ __Vtemp_125;
    VlWide<3>/*95:0*/ __Vtemp_128;
    VlWide<3>/*95:0*/ __Vtemp_129;
    VlWide<3>/*95:0*/ __Vtemp_134;
    VlWide<3>/*95:0*/ __Vtemp_135;
    VlWide<3>/*95:0*/ __Vtemp_137;
    VlWide<3>/*95:0*/ __Vtemp_138;
    // Body
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__done_reg 
        = ((IData)(vlSelfRef.tb_mul_3cycle__DOT__rst_n) 
           && (3U == (IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__state)));
    if (vlSelfRef.tb_mul_3cycle__DOT__rst_n) {
        if (((0U == (IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__state)) 
             & (IData)(vlSelfRef.tb_mul_3cycle__DOT__mul_start))) {
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_sign_reg 
                = vlSelfRef.tb_mul_3cycle__DOT__mul_b_sign;
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                = vlSelfRef.tb_mul_3cycle__DOT__mul_b_i;
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_a_reg 
                = vlSelfRef.tb_mul_3cycle__DOT__mul_a_i;
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_a_sign_reg 
                = vlSelfRef.tb_mul_3cycle__DOT__mul_a_sign;
        }
        if ((3U == (IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__state))) {
            __Vtemp_20[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[0U];
            __Vtemp_20[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[1U];
            __Vtemp_20[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[2U];
            VL_SHIFTL_WWI(68,68,32, __Vtemp_21, __Vtemp_20, 1U);
            __Vtemp_24[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[0U];
            __Vtemp_24[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[1U];
            __Vtemp_24[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[2U];
            VL_SHIFTL_WWI(68,68,32, __Vtemp_25, __Vtemp_24, 2U);
            __Vtemp_29[0U] = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[0U] 
                              | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[0U]);
            __Vtemp_29[1U] = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[1U] 
                              | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[1U]);
            __Vtemp_29[2U] = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[2U] 
                              | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[2U]);
            VL_SHIFTL_WWI(68,68,1, __Vtemp_30, __Vtemp_29, 1U);
            __Vtemp_34[0U] = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[0U] 
                              & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[0U]);
            __Vtemp_34[1U] = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[1U] 
                              & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[1U]);
            __Vtemp_34[2U] = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[2U] 
                              & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[2U]);
            VL_SHIFTL_WWI(68,68,1, __Vtemp_35, __Vtemp_34, 1U);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg 
                = (((((QData)((IData)(__Vtemp_21[1U])) 
                      << 0x20U) | (QData)((IData)(__Vtemp_21[0U]))) 
                    ^ ((((QData)((IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[1U])) 
                         << 0x20U) | (QData)((IData)(
                                                     vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[0U]))) 
                       ^ (((QData)((IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[1U])) 
                           << 0x20U) | (QData)((IData)(
                                                       vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[0U]))))) 
                   + (((((QData)((IData)(__Vtemp_25[1U])) 
                         << 0x20U) | (QData)((IData)(
                                                     __Vtemp_25[0U]))) 
                       & (((QData)((IData)(__Vtemp_30[1U])) 
                           << 0x20U) | (QData)((IData)(
                                                       __Vtemp_30[0U])))) 
                      | (((QData)((IData)(__Vtemp_35[1U])) 
                          << 0x20U) | (QData)((IData)(
                                                      __Vtemp_35[0U])))));
        }
        if ((2U == (IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__state))) {
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[0U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[1U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[2U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[0U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[0U]) 
                      & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[0U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[1U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[1U]) 
                      & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[1U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[2U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_0[2U]) 
                      & ((0x10U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[0U] 
                                   >> 0xfU)) | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[2U])));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[0U] 
                = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_pp17[0U];
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[1U] 
                = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_pp17[1U];
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[2U] 
                = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_pp17[2U];
        }
        if ((1U == (IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__state))) {
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[2U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[2U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[2U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                   ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                   ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[0U] 
                      << 1U));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                   ^ ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[0U] 
                       >> 0x1fU) | (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[1U] 
                                    << 1U)));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[2U] 
                = (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                   ^ ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[1U] 
                       >> 0x1fU) | (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[2U] 
                                    << 1U)));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[0U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[0U]) 
                      & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w2[0U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[1U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[1U]) 
                      & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w2[1U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[2U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT____VdfgRegularize_h7b20a0b2_0_0[2U]) 
                      & ((0x10U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w2[0U] 
                                   >> 0xfU)) | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress3__DOT__w2[2U])));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[0U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[0U]) 
                      & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w2[0U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[1U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[1U]) 
                      & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w2[1U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[2U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT____VdfgRegularize_h7b20a0b2_0_0[2U]) 
                      & ((0x10U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w2[0U] 
                                   >> 0xfU)) | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress2__DOT__w2[2U])));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[0U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                    & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[0U] 
                       << 1U)) | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[0U]) 
                                  & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w2[0U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[1U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                    & ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[0U] 
                        >> 0x1fU) | (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[1U] 
                                     << 1U))) | ((~ 
                                                  vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[1U]) 
                                                 & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w2[1U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[2U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                    & ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[1U] 
                        >> 0x1fU) | (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w3[2U] 
                                     << 1U))) | ((~ 
                                                  vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT____VdfgRegularize_h7b20a0b2_0_0[2U]) 
                                                 & ((0x10U 
                                                     & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w2[0U] 
                                                        >> 0xfU)) 
                                                    | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress1__DOT__w2[2U])));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[0U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[0U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1[0U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[0U]) 
                      & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w2[0U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[1U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[1U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1[1U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[1U]) 
                      & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w2[1U]));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[2U] 
                = ((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[2U] 
                    & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_1[2U]) 
                   | ((~ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT____VdfgRegularize_h7b20a0b2_0_0[2U]) 
                      & ((0x10U & (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w2[0U] 
                                   >> 0xfU)) | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress4__DOT__w2[2U])));
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_pp17[0U] = 0U;
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_pp17[1U] 
                = (IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_17);
            vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_pp17[2U] 
                = ((0xcU & ((- (IData)((1U & (IData)(
                                                     (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_17 
                                                      >> 0x21U))))) 
                            << 2U)) | (IData)((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_17 
                                               >> 0x20U)));
        }
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__state 
            = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__next_state;
    } else {
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_sign_reg = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__result_reg = 0ULL;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_a_reg = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_a_sign_reg = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out72[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_out71[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage2_pp17[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_pp17[0U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_pp17[1U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_pp17[2U] = 0U;
        vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__state = 0U;
    }
    __Vtemp_38[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[0U];
    __Vtemp_38[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[1U];
    __Vtemp_38[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_39, __Vtemp_38, 1U);
    __Vtemp_42[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[0U];
    __Vtemp_42[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[1U];
    __Vtemp_42[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_43, __Vtemp_42, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[0U] 
        = ((__Vtemp_39[0U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U]) 
           | (__Vtemp_43[0U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U]));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[1U] 
        = ((__Vtemp_39[1U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U]) 
           | (__Vtemp_43[1U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U]));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w2[2U] 
        = (0xfU & ((__Vtemp_39[2U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[2U]) 
                   | (__Vtemp_43[2U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[2U])));
    __Vtemp_48[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[0U];
    __Vtemp_48[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[1U];
    __Vtemp_48[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_49, __Vtemp_48, 1U);
    __Vtemp_52[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[0U];
    __Vtemp_52[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[1U];
    __Vtemp_52[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_53, __Vtemp_52, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[0U] 
        = (((__Vtemp_49[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U]) 
            & (__Vtemp_53[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U])) 
           << 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[1U] 
        = ((((__Vtemp_49[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U]) 
             & (__Vtemp_53[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U])) 
            >> 0x1fU) | (((__Vtemp_49[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U]) 
                          & (__Vtemp_53[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U])) 
                         << 1U));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT____VdfgRegularize_h7b20a0b2_0_1[2U] 
        = ((((__Vtemp_49[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U]) 
             & (__Vtemp_53[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U])) 
            >> 0x1fU) | (0x1eU & (((__Vtemp_49[2U] 
                                    | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[2U]) 
                                   & (__Vtemp_53[2U] 
                                      | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[2U])) 
                                  << 1U)));
    __Vtemp_59[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[0U];
    __Vtemp_59[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[1U];
    __Vtemp_59[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out11[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_60, __Vtemp_59, 1U);
    __Vtemp_62[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[0U];
    __Vtemp_62[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[1U];
    __Vtemp_62[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out21[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_63, __Vtemp_62, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[0U] 
        = (__Vtemp_60[0U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[0U] 
                             ^ (__Vtemp_63[0U] ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[1U] 
        = (__Vtemp_60[1U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[1U] 
                             ^ (__Vtemp_63[1U] ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress5__DOT__w1[2U] 
        = (0xfU & (__Vtemp_60[2U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out12[2U] 
                                     ^ (__Vtemp_63[2U] 
                                        ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out22[2U]))));
    __Vtemp_69[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[0U];
    __Vtemp_69[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[1U];
    __Vtemp_69[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_70, __Vtemp_69, 1U);
    __Vtemp_73[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[0U];
    __Vtemp_73[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[1U];
    __Vtemp_73[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_74, __Vtemp_73, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[0U] 
        = ((__Vtemp_70[0U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U]) 
           | (__Vtemp_74[0U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U]));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[1U] 
        = ((__Vtemp_70[1U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U]) 
           | (__Vtemp_74[1U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U]));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w2[2U] 
        = (0xfU & ((__Vtemp_70[2U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[2U]) 
                   | (__Vtemp_74[2U] & vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[2U])));
    __Vtemp_79[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[0U];
    __Vtemp_79[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[1U];
    __Vtemp_79[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_80, __Vtemp_79, 1U);
    __Vtemp_83[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[0U];
    __Vtemp_83[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[1U];
    __Vtemp_83[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_84, __Vtemp_83, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[0U] 
        = (((__Vtemp_80[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U]) 
            & (__Vtemp_84[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U])) 
           << 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[1U] 
        = ((((__Vtemp_80[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U]) 
             & (__Vtemp_84[0U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U])) 
            >> 0x1fU) | (((__Vtemp_80[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U]) 
                          & (__Vtemp_84[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U])) 
                         << 1U));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT____VdfgRegularize_h7b20a0b2_0_1[2U] 
        = ((((__Vtemp_80[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U]) 
             & (__Vtemp_84[1U] | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U])) 
            >> 0x1fU) | (0x1eU & (((__Vtemp_80[2U] 
                                    | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[2U]) 
                                   & (__Vtemp_84[2U] 
                                      | vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[2U])) 
                                  << 1U)));
    __Vtemp_90[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[0U];
    __Vtemp_90[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[1U];
    __Vtemp_90[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out31[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_91, __Vtemp_90, 1U);
    __Vtemp_93[0U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[0U];
    __Vtemp_93[1U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[1U];
    __Vtemp_93[2U] = vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out41[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_94, __Vtemp_93, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[0U] 
        = (__Vtemp_91[0U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[0U] 
                             ^ (__Vtemp_94[0U] ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[1U] 
        = (__Vtemp_91[1U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[1U] 
                             ^ (__Vtemp_94[1U] ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress6__DOT__w1[2U] 
        = (0xfU & (__Vtemp_91[2U] ^ (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out32[2U] 
                                     ^ (__Vtemp_94[2U] 
                                        ^ vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__stage1_out42[2U]))));
    tb_mul_3cycle__DOT__dut__DOT__booth1__DOT____VdfgRegularize_hc9735931_0_18 
        = ((((IData)(vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_sign_reg)
              ? (3U & (- (IData)((vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                                  >> 0x1fU)))) : 0U) 
            << 1U) | (vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__mul_b_reg 
                      >> 0x1fU));
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
    __Vtemp_113[0U] = tb_mul_3cycle__DOT__dut__DOT__out51[0U];
    __Vtemp_113[1U] = tb_mul_3cycle__DOT__dut__DOT__out51[1U];
    __Vtemp_113[2U] = tb_mul_3cycle__DOT__dut__DOT__out51[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_114, __Vtemp_113, 1U);
    __Vtemp_117[0U] = tb_mul_3cycle__DOT__dut__DOT__out61[0U];
    __Vtemp_117[1U] = tb_mul_3cycle__DOT__dut__DOT__out61[1U];
    __Vtemp_117[2U] = tb_mul_3cycle__DOT__dut__DOT__out61[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_118, __Vtemp_117, 1U);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[0U] 
        = (((__Vtemp_114[0U] | tb_mul_3cycle__DOT__dut__DOT__out52[0U]) 
            & (__Vtemp_118[0U] | tb_mul_3cycle__DOT__dut__DOT__out62[0U])) 
           << 1U);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[1U] 
        = ((((__Vtemp_114[0U] | tb_mul_3cycle__DOT__dut__DOT__out52[0U]) 
             & (__Vtemp_118[0U] | tb_mul_3cycle__DOT__dut__DOT__out62[0U])) 
            >> 0x1fU) | (((__Vtemp_114[1U] | tb_mul_3cycle__DOT__dut__DOT__out52[1U]) 
                          & (__Vtemp_118[1U] | tb_mul_3cycle__DOT__dut__DOT__out62[1U])) 
                         << 1U));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT____VdfgRegularize_h7b20a0b2_0_1[2U] 
        = ((((__Vtemp_114[1U] | tb_mul_3cycle__DOT__dut__DOT__out52[1U]) 
             & (__Vtemp_118[1U] | tb_mul_3cycle__DOT__dut__DOT__out62[1U])) 
            >> 0x1fU) | (0x1eU & (((__Vtemp_114[2U] 
                                    | tb_mul_3cycle__DOT__dut__DOT__out52[2U]) 
                                   & (__Vtemp_118[2U] 
                                      | tb_mul_3cycle__DOT__dut__DOT__out62[2U])) 
                                  << 1U)));
    __Vtemp_124[0U] = tb_mul_3cycle__DOT__dut__DOT__out51[0U];
    __Vtemp_124[1U] = tb_mul_3cycle__DOT__dut__DOT__out51[1U];
    __Vtemp_124[2U] = tb_mul_3cycle__DOT__dut__DOT__out51[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_125, __Vtemp_124, 1U);
    __Vtemp_128[0U] = tb_mul_3cycle__DOT__dut__DOT__out61[0U];
    __Vtemp_128[1U] = tb_mul_3cycle__DOT__dut__DOT__out61[1U];
    __Vtemp_128[2U] = tb_mul_3cycle__DOT__dut__DOT__out61[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_129, __Vtemp_128, 1U);
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[0U] 
        = ((__Vtemp_125[0U] & tb_mul_3cycle__DOT__dut__DOT__out52[0U]) 
           | (__Vtemp_129[0U] & tb_mul_3cycle__DOT__dut__DOT__out62[0U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[1U] 
        = ((__Vtemp_125[1U] & tb_mul_3cycle__DOT__dut__DOT__out52[1U]) 
           | (__Vtemp_129[1U] & tb_mul_3cycle__DOT__dut__DOT__out62[1U]));
    vlSelfRef.tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w2[2U] 
        = (0xfU & ((__Vtemp_125[2U] & tb_mul_3cycle__DOT__dut__DOT__out52[2U]) 
                   | (__Vtemp_129[2U] & tb_mul_3cycle__DOT__dut__DOT__out62[2U])));
    __Vtemp_134[0U] = tb_mul_3cycle__DOT__dut__DOT__out51[0U];
    __Vtemp_134[1U] = tb_mul_3cycle__DOT__dut__DOT__out51[1U];
    __Vtemp_134[2U] = tb_mul_3cycle__DOT__dut__DOT__out51[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_135, __Vtemp_134, 1U);
    __Vtemp_137[0U] = tb_mul_3cycle__DOT__dut__DOT__out61[0U];
    __Vtemp_137[1U] = tb_mul_3cycle__DOT__dut__DOT__out61[1U];
    __Vtemp_137[2U] = tb_mul_3cycle__DOT__dut__DOT__out61[2U];
    VL_SHIFTL_WWI(68,68,32, __Vtemp_138, __Vtemp_137, 1U);
    tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[0U] 
        = (__Vtemp_135[0U] ^ (tb_mul_3cycle__DOT__dut__DOT__out52[0U] 
                              ^ (__Vtemp_138[0U] ^ 
                                 tb_mul_3cycle__DOT__dut__DOT__out62[0U])));
    tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[1U] 
        = (__Vtemp_135[1U] ^ (tb_mul_3cycle__DOT__dut__DOT__out52[1U] 
                              ^ (__Vtemp_138[1U] ^ 
                                 tb_mul_3cycle__DOT__dut__DOT__out62[1U])));
    tb_mul_3cycle__DOT__dut__DOT__compress7__DOT__w1[2U] 
        = (0xfU & (__Vtemp_135[2U] ^ (tb_mul_3cycle__DOT__dut__DOT__out52[2U] 
                                      ^ (__Vtemp_138[2U] 
                                         ^ tb_mul_3cycle__DOT__dut__DOT__out62[2U]))));
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

void Vtb_mul_3cycle___024root___timing_resume(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___timing_resume\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VtrigSched_h91307ded__0.resume(
                                                   "@(posedge tb_mul_3cycle.clk)");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_mul_3cycle___024root___timing_commit(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___timing_commit\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (4ULL & vlSelfRef.__VactTriggered.word(0U)))) {
        vlSelfRef.__VtrigSched_h91307ded__0.commit(
                                                   "@(posedge tb_mul_3cycle.clk)");
    }
}

void Vtb_mul_3cycle___024root___eval_triggers__act(Vtb_mul_3cycle___024root* vlSelf);

bool Vtb_mul_3cycle___024root___eval_phase__act(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_phase__act\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<3> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_mul_3cycle___024root___eval_triggers__act(vlSelf);
    Vtb_mul_3cycle___024root___timing_commit(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vtb_mul_3cycle___024root___timing_resume(vlSelf);
        Vtb_mul_3cycle___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vtb_mul_3cycle___024root___eval_phase__nba(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_phase__nba\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vtb_mul_3cycle___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mul_3cycle___024root___dump_triggers__nba(Vtb_mul_3cycle___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mul_3cycle___024root___dump_triggers__act(Vtb_mul_3cycle___024root* vlSelf);
#endif  // VL_DEBUG

void Vtb_mul_3cycle___024root___eval(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Vtb_mul_3cycle___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("tb_mul_3cycle.v", 7, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelfRef.__VactIterCount))) {
#ifdef VL_DEBUG
                Vtb_mul_3cycle___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("tb_mul_3cycle.v", 7, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vtb_mul_3cycle___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vtb_mul_3cycle___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vtb_mul_3cycle___024root___eval_debug_assertions(Vtb_mul_3cycle___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_mul_3cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mul_3cycle___024root___eval_debug_assertions\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
