
/* Define amount of linear stack growth. */
#ifndef MRB_STACK_GROWTH
#define MRB_STACK_GROWTH 128
#endif

/* Maximum stack depth. Should be set lower on memory constrained systems.
The value below allows about 60000 recursive calls in the simplest case. */
#ifndef MRB_STACK_MAX
#define MRB_STACK_MAX 10000//((1<<18) - MRB_STACK_GROWTH)
#endif
// TODO: need to test if default MRB_STACK_MAX still leads to segfault
// if not then use the default

static void
stack_extend(mrb_state *mrb, int room, int keep)
{
  int size, off;
  if (mrb->stack + room >= mrb->stend) {
    mrb_value *oldbase = mrb->stbase;

    size = mrb->stend - mrb->stbase;
    off = mrb->stack - mrb->stbase;

    /* Use linear stack growth.
       It is slightly slower than doubling thestack space,
       but it saves memory on small devices. */
    if (room <= size)
      size += MRB_STACK_GROWTH;
    else
      size += room;

    mrb->stbase = (mrb_value *)mrb_realloc(mrb, mrb->stbase, sizeof(mrb_value) * size);
    mrb->stack = mrb->stbase + off;
    mrb->stend = mrb->stbase + size;
    envadjust(mrb, oldbase, mrb->stbase);
    /* Raise an exception if the new stack size will be too large,
    to prevent infinite recursion. However, do this only after resizing the stack, so mrb_raisef has stack space to work with. */
    if(size > MRB_STACK_MAX) {
      //mrb_raisef(mrb, E_RUNTIME_ERROR, "stack level too deep. (limit=%d)", MRB_STACK_MAX);
      const char *msg = "stack level too deep."; // TODO: tell limit
      mrb_value exc = mrb_exc_new(mrb, E_RUNTIME_ERROR, msg, strlen(msg));
      mrb->exc = (struct RObject*)mrb_object(exc);
      mrbb_raise(mrb, 0);
    }
  }

  if (room > keep) {
    int i;
    for (i=keep; i<room; i++) {
#ifndef MRB_NAN_BOXING
      static const mrb_value mrb_value_zero = { { 0 } };
      mrb->stack[i] = mrb_value_zero;
#else
      SET_NIL_VALUE(mrb->stack[i]);
#endif
    }
  }
}
