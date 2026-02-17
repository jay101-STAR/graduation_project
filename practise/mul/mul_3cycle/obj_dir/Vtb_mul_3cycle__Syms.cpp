// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb_mul_3cycle__pch.h"
#include "Vtb_mul_3cycle.h"
#include "Vtb_mul_3cycle___024root.h"

// FUNCTIONS
Vtb_mul_3cycle__Syms::~Vtb_mul_3cycle__Syms()
{
}

Vtb_mul_3cycle__Syms::Vtb_mul_3cycle__Syms(VerilatedContext* contextp, const char* namep, Vtb_mul_3cycle* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
        // Check resources
        Verilated::stackCheck(4472);
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
}
