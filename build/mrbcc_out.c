#include "mruby.h"
#include "mruby/proc.h"
#include "mruby/class.h"
#include "mruby/array.h"
#include "mruby/hash.h"
#include "mruby/dump.h"
#include "mruby/range.h"
// #include "mruby/cdump.h"
#include "mruby/compile.h"
#include "mruby/variable.h"
#include "mruby/string.h"
#include "../mruby/src/error.h"
#include "../mruby/src/opcode.h" // for OP_L_CAPTURE used in OP_LAMBDA
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "c_files/debug.c"
#include "c_files/modified_defines.c"
#include "c_files/vm_extern.c"
#include "c_files/vm.c"
#include "c_files/exception.c"
#include "c_files/vm_changed.c"
#include "c_files/proc.c"
#include "c_files/method_dispatch.c"

// compiled code
#include "c_files/out.c"

extern mrb_value mrbb_exec_entry_point(mrb_state *mrb, mrb_value recv) {
  mrb_callinfo *ci;
  struct RProc *p;
  int ai = mrb->arena_idx;
  jmp_buf *prev_jmp = mrb->jmp;
  jmp_buf c_jmp;
  mrb_value result;

  if (setjmp(c_jmp) == 0) {
    mrb->jmp = &c_jmp;
  }
  else {
    mrb->jmp = prev_jmp;
    printf("Uncaught exception:\n");
    mrb_p(mrb, mrb_obj_value(mrb->exc));
    return mrb_obj_value(mrb->exc);
  }

  mrbb_rescue_push(mrb, &c_jmp);

  if (!mrb->stack) {
    stack_init(mrb);
  }

  // Patch Proc
  {
    struct RProc *m = mrb_proc_new_cfunc(mrb, mrbb_proc_call);
    mrb_define_method_raw(mrb, mrb->proc_class, mrb_intern(mrb, "call"), m);
    mrb_define_method_raw(mrb, mrb->proc_class, mrb_intern(mrb, "[]"), m);
  }

  mrb->ci->nregs = 0;
  /* prepare stack */
  ci = cipush(mrb);
  ci->acc = -1;
  ci->mid = mrb_intern(mrb, "<compiled entry point>");
  ci->stackidx = mrb->stack - mrb->stbase;
  ci->argc = 0;
  ci->target_class = mrb_class(mrb, recv);

  /* prepare stack */
  mrb->stack[0] = recv;

  p = mrbb_proc_new(mrb, script_entry_point);
  p->target_class = ci->target_class;
  ci->proc = p;

  result = p->body.func(mrb, recv);
  mrb->arena_idx = ai;
  mrb_gc_protect(mrb, result);

  mrb->stack = mrb->stbase + mrb->ci->stackidx;
  cipop(mrb);

  mrbb_rescue_pop(mrb);

  return result;
}
