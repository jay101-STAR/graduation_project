// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mul_3cycle.h for the primary calling header

#include "Vtb_mul_3cycle__pch.h"
#include "Vtb_mul_3cycle__Syms.h"
#include "Vtb_mul_3cycle___024root.h"

void Vtb_mul_3cycle___024root___ctor_var_reset(Vtb_mul_3cycle___024root* vlSelf);

Vtb_mul_3cycle___024root::Vtb_mul_3cycle___024root(Vtb_mul_3cycle__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , __VdlySched{*symsp->_vm_contextp__}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vtb_mul_3cycle___024root___ctor_var_reset(this);
}

void Vtb_mul_3cycle___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vtb_mul_3cycle___024root::~Vtb_mul_3cycle___024root() {
}
