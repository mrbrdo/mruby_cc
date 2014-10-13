
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
  if (mrb->c->stack + room >= mrb->c->stend) {
    mrb_value *oldbase = mrb->c->stbase;
    int size = mrb->c->stend - mrb->c->stbase;
    int off = mrb->c->stack - mrb->c->stbase;

#ifdef MRB_STACK_EXTEND_DOUBLING
    if (room <= size)
      size *= 2;
    else
      size += room;
#else
    /* Use linear stack growth.
       It is slightly slower than doubling the stack space,
       but it saves memory on small devices. */
    if (room <= MRB_STACK_GROWTH)
      size += MRB_STACK_GROWTH;
    else
      size += room;
#endif

    mrb->c->stbase = (mrb_value *)mrb_realloc(mrb, mrb->c->stbase, sizeof(mrb_value) * size);
    mrb->c->stack = mrb->c->stbase + off;
    mrb->c->stend = mrb->c->stbase + size;
    envadjust(mrb, oldbase, mrb->c->stbase);

    /* Raise an exception if the new stack size will be too large,
       to prevent infinite recursion. However, do this only after resizing the stack, so mrb_raise has stack space to work with. */
    if (size > MRB_STACK_MAX) {
      init_new_stack_space(mrb, room, keep);
      // mrb_raise(mrb, E_SYSSTACK_ERROR, "stack level too deep. (limit=" MRB_STRINGIZE(MRB_STACK_MAX) ")");
      const char *msg = "stack level too deep."; // TODO: tell limit
      mrb_value exc = mrb_exc_new(mrb, E_RUNTIME_ERROR, msg, strlen(msg));
      mrb->exc = (struct RObject*)mrb_obj_ptr(exc);
      mrbb_raise(mrb);
    }
  }
  init_new_stack_space(mrb, room, keep);
}
