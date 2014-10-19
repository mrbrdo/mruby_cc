#include "mruby.h"
#include "mruby/proc.h"
#include "mruby/class.h"
#include "mruby/array.h"
#include "mruby/hash.h"
#include "mruby/dump.h"
#include "mruby/range.h"
#include "mruby/compile.h"
#include "mruby/variable.h"
#include "mruby/numeric.h"
#include "mruby/string.h"
#include "mruby/error.h"
#include "mruby/opcode.h" // for OP_L_CAPTURE used in OP_LAMBDA
#include "../mruby/src/mrb_throw.h"
#include "../mruby/src/value_array.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

//#define MRBB_COMPAT_INTERPRETER

#include "c_files/mrbb_struct.c"
#include "c_files/debug.c"
#include "c_files/modified_defines.c"
#include "c_files/vm_extern.c"
#include "c_files/vm.c"
#include "c_files/exception.c"
#include "c_files/vm_changed.c"
#include "c_files/proc.c"
#include "c_files/method_dispatch.c"

struct RProc *interpreted_proc_call = 0;

// compiled code
#include "c_files/out.c"

extern mrb_value mrbb_exec_entry_point(mrb_state *mrb, mrb_value recv) {
  mrb_callinfo *ci;
  struct RProc *p;
  int ai = mrb->arena_idx;
  struct mrb_jmpbuf *prev_jmp = mrb->jmp;
  struct mrb_jmpbuf c_jmp;
  mrb_value result;

  MRB_TRY(&c_jmp) {
    mrb->jmp = &c_jmp;
  }
  MRB_CATCH(&c_jmp) {
    mrb->jmp = prev_jmp;
    printf("Uncaught exception:\n");
    mrb_p(mrb, mrb_obj_value(mrb->exc));
    return mrb_obj_value(mrb->exc);
  }
  MRB_END_EXC(&c_jmp);

  mrbb_rescue_push(mrb, &c_jmp);

  if (!mrb->c->stack) {
    stack_init(mrb);
  }

  // Patch Proc
  {
    // TODO: this should be done only once, if multiple modules are loaded - could use instance variable to remember between modules
    struct RProc *m = mrb_proc_new_cfunc(mrb, mrbb_proc_call);
    interpreted_proc_call = mrb_method_search_vm(mrb, &mrb->proc_class, mrb_intern_cstr(mrb, "call"));
    mrb_define_method_raw(mrb, mrb->proc_class, mrb_intern_cstr(mrb, "call"), m);
    mrb_define_method_raw(mrb, mrb->proc_class, mrb_intern_cstr(mrb, "[]"), m);
  }

  mrb->c->ci->nregs = 0;
  /* prepare stack */
  ci = cipush(mrb);
  ci->acc = -1;
  ci->mid = mrb_intern_cstr(mrb, "<compiled entry point>");
  ci->stackent = mrb->c->stack;
  ci->argc = 0;
  if (mrb_obj_id(recv) == mrb_obj_id(mrb_top_self(mrb)))
    ci->target_class = mrb->object_class;
  else
    ci->target_class = mrb_class(mrb, recv);

  /* prepare stack */
  mrb->c->stack[0] = recv;

  p = mrbb_proc_new(mrb, script_entry_point);
  p->target_class = ci->target_class;
  ci->proc = p;

  result = p->body.func(mrb, recv);
  mrb->arena_idx = ai;
  mrb_gc_protect(mrb, result);

  mrb->c->stack = mrb->c->ci->stackent;
  cipop(mrb);

  mrbb_rescue_pop(mrb);

  return result;
}
