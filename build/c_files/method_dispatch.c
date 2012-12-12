void
mrbb_send_setup_stack_extend(mrb_state *mrb, mrb_value self, mrb_value *argv, int argc)
{
  mrb->stack = mrb->stack + mrb->ci[-1].nregs;

  stack_extend(mrb, argc + 2, 0);
  mrb->stack[0] = self;
  if (argc > 0) {
    stack_copy(mrb->stack+1, argv, argc);
  }
  mrb->stack[argc+1] = argv[argc];
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

    mid = mrb_intern(mrb, "method_missing");
    m = mrb_method_search_vm(mrb, &c, mid);
    if (n == CALL_MAXARGS) {
      mrb_ary_unshift(mrb, regs[a+1], sym);
    }
    else {
      memmove(regs+a+2, regs+a+1, sizeof(mrb_value)*(n+1));
      regs[a+1] = sym;
      n++;
    }
  }

  /* push callinfo */
  ci = cipush(mrb);
  ci->mid = mid;
  ci->proc = m;
  ci->stackidx = mrb->stack - mrb->stbase;
  ci->argc = n;
  if (ci->argc == CALL_MAXARGS) ci->argc = -1;
  ci->target_class = c; // TODO look this and met_start.c
  ci->acc = -1; // TODO ?

  /* prepare stack */
  mrb->stack += a;

  if (MRB_PROC_CFUNC_P(m)) {
    if (n == CALL_MAXARGS) { // TODO this is not necessary for MRBCC func?
      ci->nregs = 3;
    }
    else {
      ci->nregs = n + 2;
    }
    int ai = mrb->arena_idx;
    int stackidx = mrb->ci->stackidx;
    int cioff = mrb->ci - mrb->cibase;
    val = m->body.func(mrb, recv);
    mrb->arena_idx = ai;
    mrb_gc_protect(mrb, val); // not needed really? safeguard just in case?
    if ((mrb->ci - mrb->cibase) == cioff) {
      mrb->stack = mrb->stbase + stackidx;
      cipop(mrb);
    } else { // break
      mrb->stack = mrb->stbase + stackidx; // not needed really? safeguard if somehow stack is accessed before break returns to proper location (shouldn't happen)
      // We NEED to cipop the first time, but not after that
      if (mrb->ci->proc != (struct RProc *) -1) {
        cipop(mrb);
        cipush(mrb);
      }
      mrb->ci->proc = (struct RProc *)-1;
    }
    if (mrb->exc) mrbb_raise(mrb, 0);
  }
  else {
    mrb_irep *irep = m->body.irep;
    ci->nregs = irep->nregs;
    if (ci->argc < 0) {
      stack_extend(mrb, (irep->nregs < 3) ? 3 : irep->nregs, 3);
    }
    else {
      stack_extend(mrb, irep->nregs,  ci->argc+2);
    }
    val = mrb_run(mrb, m, recv);
  }
  *regs_ptr = mrb->stack; // stack_extend might realloc stack
  return val;
}

void
mrbb_send(mrb_state *mrb, mrb_sym mid, int argc, mrb_value **regs_ptr, int a, int sendb)
{
  mrb->stack[a] = mrbb_send_r(mrb, mid, argc, regs_ptr, a, sendb);
}
