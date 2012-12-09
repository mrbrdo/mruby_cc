#define MRB_GC_STRESS // TODO for debug
#include "mruby.h"
#include "mruby/proc.h"
#include "mruby/class.h"
#include "mruby/array.h"
#include "mruby/hash.h"
#include "mruby/dump.h"
#include "mruby/range.h"
#include "mruby/cdump.h"
#include "mruby/compile.h"
#include "mruby/variable.h"
#include "mruby/string.h"
#include "./../src/error.h"
#include "../../src/opcode.h" // for OP_L_CAPTURE used in OP_LAMBDA
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// my defines
#define NEXT

// removed first line from OP_CMP, also goto L_SEND in default (TODO)
#define OP_CMP(op) do {\
  /* need to check if - is overridden */\
  switch (TYPES2(mrb_type(regs[a]),mrb_type(regs[a+1]))) {\
  case TYPES2(MRB_TT_FIXNUM,MRB_TT_FIXNUM):\
    OP_CMP_BODY(op,attr_i,attr_i);\
    break;\
  case TYPES2(MRB_TT_FIXNUM,MRB_TT_FLOAT):\
    OP_CMP_BODY(op,attr_i,attr_f);\
    break;\
  case TYPES2(MRB_TT_FLOAT,MRB_TT_FIXNUM):\
    OP_CMP_BODY(op,attr_f,attr_i);\
    break;\
  case TYPES2(MRB_TT_FLOAT,MRB_TT_FLOAT):\
    OP_CMP_BODY(op,attr_f,attr_f);\
    break;\
  default:\
    mrbb_send(mrb, mrb_intern(mrb, #op ), 1, regs, a, 0);\
    break;\
  }\
} while (0)

// We need some functions from vm.c that are not exposed
#include "c_files/vm_extern.c"
#include "c_files/vm.c"
#include "c_files/exception.c"
#include "c_files/proc.c"
#include "c_files/method_dispatch.c"

mrb_value testfun(mrb_state *mrb, mrb_value args) {
  mrb_p(mrb, args);
  return mrb_nil_value();
}

void testfunc(mrb_state *mrb) {
  mrb_value *regs = NULL;
  regs = mrb->stack;
  regs[0] = mrb_top_self(mrb);

  mrb_define_method_vm(mrb, mrb_class(mrb, regs[0]),
    mrb_intern(mrb, "testfun"),
    mrb_obj_value(mrb_proc_new_cfunc(mrb, testfun)));

  mrb_funcall(mrb, regs[0], "testfun", 1, mrb_nil_value());
}

#include "codegen_rb/out.c"
#include "c_files/mrbb_main.c"

int
main(int argc, char **argv)
{
  mrb_state *mrb = mrb_open();
  mrb_callinfo *ci;

  if (mrb == NULL) {
    fprintf(stderr, "Invalid mrb_state, exiting driver");
    return EXIT_FAILURE;
  }

  // make it so state knows we are going into a function
  ci = cipush(mrb);
  ci->mid = mrb_intern(mrb, "main22");
  ci->stackidx = mrb->stack - mrb->stbase;
  ci->argc = 0;
  ci->nregs = 10; // TODO
  ci->target_class = ci[-1].target_class; //mrb_class(mrb, mrb_top_self(mrb));
  ci->acc = -1;

  mrbb_main(mrb);

  mrb_close(mrb);
  return EXIT_SUCCESS;
}
