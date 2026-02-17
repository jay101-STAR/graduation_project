// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VTB_MUL_3CYCLE__SYMS_H_
#define VERILATED_VTB_MUL_3CYCLE__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vtb_mul_3cycle.h"

// INCLUDE MODULE CLASSES
#include "Vtb_mul_3cycle___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vtb_mul_3cycle__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vtb_mul_3cycle* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vtb_mul_3cycle___024root       TOP;

    // CONSTRUCTORS
    Vtb_mul_3cycle__Syms(VerilatedContext* contextp, const char* namep, Vtb_mul_3cycle* modelp);
    ~Vtb_mul_3cycle__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
