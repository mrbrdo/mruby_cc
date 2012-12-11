mrb_value mrbb_main(mrb_state *mrb) {
  mrb_callinfo *ci;
  mrb_value recv = mrb_top_self(mrb);
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
    return;
  }

  if (!mrb->stack) {
    stack_init(mrb);
  }

  // Path Proc
  {
    struct RProc *m = mrb_proc_new_cfunc(mrb, mrbb_proc_call);
    mrb_define_method_raw(mrb, mrb->proc_class, mrb_intern(mrb, "call"), m);
    mrb_define_method_raw(mrb, mrb->proc_class, mrb_intern(mrb, "[]"), m);
  }

  /* prepare stack */
  ci = cipush(mrb);
  ci->acc = -1;
  ci->mid = 0;
  ci->stackidx = mrb->stack - mrb->stbase;
  ci->argc = 0;
  ci->target_class = mrb_class(mrb, recv);

  /* prepare stack */
  mrb->stack[0] = recv;

  p = mrbb_proc_new(mrb, rb_main);
  p->target_class = ci->target_class;
  ci->proc = p;

  result = p->body.func(mrb, recv);
  mrb->arena_idx = ai;
  mrb_gc_protect(mrb, result);

  mrb->stack = mrb->stbase + mrb->ci->stackidx;
  cipop(mrb);

  return result;
}
