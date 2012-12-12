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

// function to execute compiled code
#include "c_files/mrbb_entry_point.c"

int
main(int argc, char **argv)
{
  mrb_state *mrb = mrb_open();

  if (mrb == NULL) {
    fprintf(stderr, "Invalid mrb_state, exiting driver");
    return EXIT_FAILURE;
  }

  mrbb_exec_entry_point(mrb, mrb_top_self(mrb));

  mrb_close(mrb);
  return EXIT_SUCCESS;
}
