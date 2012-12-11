
void mrbb_main(mrb_state *mrb) {
  int a = 0;
  mrb_callinfo *ci;
  mrb_value recv = mrb_top_self(mrb);
  struct RProc *p;
  int ai = mrb->arena_idx;
  jmp_buf *prev_jmp = (jmp_buf *)mrb->jmp;
  jmp_buf c_jmp;
  mrb_value result;

  if (setjmp(c_jmp) == 0) {
    mrb->jmp = &c_jmp;
  }
  else {
    printf("unexpected exception ");
    mrb_p(mrb, mrb_obj_value(mrb->exc));
    exit(0);
    mrbb_raise(mrb, prev_jmp); // TODO ?
  }

  if (!mrb->stack) {
    stack_init(mrb);
  }

  // TODO: patch Proc
  {
    struct RProc *m = mrb_proc_new_cfunc(mrb, mrbb_proc_call);
    mrb_define_method_raw(mrb, mrb->proc_class, mrb_intern(mrb, "call"), m);
    mrb_define_method_raw(mrb, mrb->proc_class, mrb_intern(mrb, "[]"), m);
  }
  // END TODO

  mrb->stack[0] = recv;
  /* prepare stack */
  ci = cipush(mrb);
  //ci->pc = pc + 1;
  ci->acc = -1;
  ci->mid = 0;
  ci->stackidx = mrb->stack - mrb->stbase;
  ci->argc = 0;
  ci->target_class = mrb_class(mrb, recv);

  /* prepare stack */
  mrb->stack += a;

  p = mrb_proc_new_cfunc(mrb, rb_main);
  // p = mrb_proc_new(mrb, mrb->irep[irep->idx+GETARG_Bx(i)]);
  p->target_class = ci->target_class;
  ci->proc = p;

  // if (MRB_PROC_CFUNC_P(p)) {
  // else part removed since it is always CFUNC

  //mrb_gc_protect(mrb, mrb_obj_value(ci->proc)); // TODO just testing...
  //mrb->stack[0] =
  result = p->body.func(mrb, recv);
  mrb_gc_protect(mrb, result);
  mrb->arena_idx = ai;
  mrb->stack = mrb->stbase + mrb->ci->stackidx;
  cipop(mrb);
  mrb->stack[0] = result;
  //if (mrb->exc) mrbb_raise(mrb, prev_jmp); // TODO
  /* pop stackpos */
  //mrb->stack = mrb->stbase + mrb->ci->stackidx;
  //cipop(mrb);
}
