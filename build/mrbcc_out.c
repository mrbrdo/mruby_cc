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
