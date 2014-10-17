static mrb_code c_break_code = MKOP_A(OP_STOP, 0);

void
mrbb_send_setup_stack_extend(mrb_state *mrb, mrb_value self, mrb_value *argv, int argc)
{
  mrb->c->stack = mrb->c->stack + mrb->c->ci[-1].nregs;

  stack_extend(mrb, argc + 2, 0);
  mrb->c->stack[0] = self;
  if (argc > 0) {
    stack_copy(mrb->c->stack+1, argv, argc);
  }
  mrb->c->stack[argc+1] = argv[argc];
}

mrb_value
mrbb_send_r(mrb_state *mrb, mrb_sym mid, int n, mrb_value **regs_ptr, int a, int sendb)
{
  struct RProc *m;
  struct RClass *c;
  mrb_callinfo *ci;
  mrb_value val;
  mrb_value *regs = *regs_ptr;
  mrb_value recv = regs[a];

  if (!sendb) {
    if (n == CALL_MAXARGS) {
      SET_NIL_VALUE(regs[a+2]);
    }
    else {
      SET_NIL_VALUE(regs[a+n+1]);
    }
  }
  c = mrb_class(mrb, recv);
  m = mrb_method_search_vm(mrb, &c, mid);
  if (!m) {
    mrb_value sym = mrb_symbol_value(mid);

    mid = mrb_intern_lit(mrb, "method_missing");
    m = mrb_method_search_vm(mrb, &c, mid);
    if (n == CALL_MAXARGS) {
      mrb_ary_unshift(mrb, regs[a+1], sym);
    }
    else {
      value_move(regs+a+2, regs+a+1, ++n);
      regs[a+1] = sym;
    }
  }

  /* push callinfo */
  ci = cipush(mrb);
  ci->mid = mid;
  ci->proc = m;
  ci->stackent = mrb->c->stack;
  if (c->tt == MRB_TT_ICLASS) {
    ci->target_class = c->c;
  }
  else {
    ci->target_class = c;
  }
  ci->acc = -1; // TODO ?

  /* prepare stack */
  mrb->c->stack += a;

  mrb_value *stackent = mrb->c->ci->stackent;
  ptrdiff_t cioff = mrb->c->ci - mrb->c->cibase;

  if (MRB_PROC_CFUNC_P(m)) {
    if (n == CALL_MAXARGS) { // TODO this is not necessary for MRBCC func?
      ci->argc = -1;
      ci->nregs = 3;
    }
    else {
      ci->argc = n;
      ci->nregs = n + 2;
    }

    int ai = mrb->arena_idx;
    val = m->body.func(mrb, recv);
    mrb->arena_idx = ai;
  }
  else {
    mrb_irep *irep = m->body.irep;
    ci->nregs = irep->nregs;
    if (n == CALL_MAXARGS) {
      ci->argc = -1;
      stack_extend(mrb, (irep->nregs < 3) ? 3 : irep->nregs, 3);
    }
    else {
      ci->argc = n;
      stack_extend(mrb, irep->nregs,  n+2);
    }
    val = mrb_run(mrb, m, recv);
    if (mrb->exc) {
      printf("TODO: exception raised from mruby code:\n");
      mrb_p(mrb, mrb_obj_value(mrb->exc));fflush(stdout);
    }
    if (mrb->c->ci[1].pc != &c_break_code) {
      // because OP_RETURN will cipop()
      cioff--;
    }
  }

  // BREAK
  if ((mrb->c->ci - mrb->c->cibase) != cioff) {
    mrb->c->stack = stackent; // not needed really? safeguard if somehow stack is accessed before break returns to proper location (shouldn't happen)
    // We NEED to cipop the first time, but not after that
    if (mrb->c->ci->proc != (struct RProc *) -1) {
      cipop(mrb);
      cipush(mrb);
    }
    mrb->c->ci->proc = (struct RProc *)-1;
  } else if (MRB_PROC_CFUNC_P(m)) {
    mrb->c->stack = stackent;
    cipop(mrb);
  }
  if (mrb->exc) mrbb_raise(mrb); // we can do this before cipop... see OP_SEND

  *regs_ptr = mrb->c->stack; // stack_extend might realloc stack
  return val;
}

void
mrbb_send(mrb_state *mrb, mrb_sym mid, int argc, mrb_value **regs_ptr, int a, int sendb)
{
  mrb->c->stack[a] = mrbb_send_r(mrb, mid, argc, regs_ptr, a, sendb);
}
