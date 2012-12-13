#include "mruby.h"
#include "mruby/string.h"
#include "mruby/value.h"
#include "mruby/array.h"
#include "mruby/variable.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dlfcn.h>

mrb_value mrbcc_load_so(mrb_state *mrb, mrb_value self, const char *filename) {
  void *handle;
  mrb_value (*entry_point)(mrb_state*, mrb_value);
  mrb_value ary;
  char *error;
  char *fullpath;
  fullpath = realpath(filename, NULL);
  handle = dlopen(fullpath, RTLD_LAZY);
  free(fullpath);
  if (!handle) {
    fprintf (stderr, "%s\n", dlerror());
    return mrb_nil_value();
  }
  dlerror();    /* Clear any existing error */
  entry_point = dlsym(handle, "mrbb_exec_entry_point");
  if ((error = dlerror()) != NULL)  {
    fprintf (stderr, "%s\n", error);
    return mrb_nil_value();
  }
  ary = mrb_iv_get(mrb, mrb_obj_value(mrb->kernel_module),
    mrb_intern(mrb, "@loaded_compiled_mrb_handles"));
  mrb_ary_push(mrb, ary, mrb_fixnum_value((mrb_int) handle)); // TODO warning
  return (*entry_point)(mrb, self);
}

static mrb_value rb_load_compiled_mrb(mrb_state *mrb, mrb_value self)
{
  mrb_value rstr;
  const char *str;

  mrb_get_args(mrb, "S", &rstr);
  str = mrb_string_value_ptr(mrb, rstr);

  return mrbcc_load_so(mrb, self, str);
}

int
main(int argc, char **argv)
{
  mrb_state *mrb = mrb_open();

  if (mrb == NULL) {
    fprintf(stderr, "Invalid mrb_state, exiting driver");
    return EXIT_FAILURE;
  }

  mrb_iv_set(mrb, mrb_obj_value(mrb->kernel_module),
    mrb_intern(mrb, "@loaded_compiled_mrb_handles"),
      mrb_ary_new(mrb));

  // define load method on kernel
  mrb_define_method(mrb, mrb->kernel_module, "load_compiled_mrb",
    rb_load_compiled_mrb, ARGS_REQ(1));

  mrbcc_load_so(mrb, mrb_top_self(mrb), "mrblib.so");

  if (argc <= 1) {
    printf("Usage: %s compiled.so\n", argv[0]);
  } else {
    mrbcc_load_so(mrb, mrb_top_self(mrb), argv[1]);
  }

  mrb_close(mrb);

  // TODO: unload .so
  //dlclose(handle); // gotta keep a global array of loaded sos and not close
  return EXIT_SUCCESS;
}
