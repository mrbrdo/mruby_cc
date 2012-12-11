mrb_value
mrbb_send_r2(mrb_state *mrb, mrb_sym mid, int n, mrb_value **regs_ptr, int a, int sendb)
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
    mrb_gc_protect(mrb, val); // TODO necessary?
    if ((mrb->ci - mrb->cibase) == cioff) {
      mrb->stack = mrb->stbase + stackidx;
      cipop(mrb);
    } else { // break
      mrb->stack = mrb->stbase + stackidx; // not needed really? safeguard if somehow stack is accessed before break returns to proper location (shouldn't happen)
      cipop(mrb);
      cipush(mrb);
      mrb->ci->proc = -1;
      // TODO i think i cant pop every time, only the first time? but i do push too...
    }
    //if (mrb->exc) goto L_RAISE; // TODO
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

mrb_value
mrbb_send_r(mrb_state *mrb, mrb_sym mid, int argc, mrb_value **regs_ptr, int a, int sendb)
{
  struct RProc *p;
  struct RClass *c;
  mrb_sym undef = 0;
  mrb_callinfo *ci;
  int n;
  mrb_value val;
  mrb_value *regs = *regs_ptr;
  mrb_value self = regs[a];
  mrb_value *argv = regs + a + 1;
  mrb_value blk;
  int stack_offset_for_return_value = regs - mrb->stbase + a;

  n = mrb->ci->nregs;
  if (sendb) {
    blk = argv[argc];
  } else {
    blk = mrb_nil_value();
  }
  // TODO figure out exactly how to handle -1 argc
  if (argc == CALL_MAXARGS) argc = -1;
  c = mrb_class(mrb, self);
  p = mrb_method_search_vm(mrb, &c, mid);
  if (!p) {
    undef = mid;
    mid = mrb_intern(mrb, "method_missing");
    p = mrb_method_search_vm(mrb, &c, mid);
    n++; argc++;
  }
  ci = cipush(mrb);
  ci->mid = mid;
  ci->proc = p;
  ci->stackidx = mrb->stack - mrb->stbase;
  ci->argc = argc;
  ci->target_class = p->target_class;

  if (argc == -1) {// TODO temp fix, must fix for method_missing
    argc = 1;
  }

  if (MRB_PROC_CFUNC_P(p)) {
    ci->nregs = argc + 2;
  }
  else {
    ci->nregs = p->body.irep->nregs + 2;
  }
  ci->acc = -1;

  if (0 && MRB_PROC_MRBCFUNC_P(p)) { // TODO figure this out
    if (!sendb) {
      if (argc == -1) {
        SET_NIL_VALUE(regs[a+2]);
      }
      else {
        SET_NIL_VALUE(regs[a+argc+1]);
      }
    }
    mrb->stack += a;
  } else {
    mrb->stack = mrb->stack + n;

    stack_extend(mrb, ci->nregs, 0);
    mrb->stack[0] = self;
    if (undef) {
      mrb->stack[1] = mrb_symbol_value(undef);
      stack_copy(mrb->stack+2, argv, argc-1);
    }
    else if (argc > 0) {
      stack_copy(mrb->stack+1, argv, argc);
    }
    mrb->stack[argc+1] = blk;
  }


  if (MRB_PROC_CFUNC_P(p)) {
    if (ci->argc < 0) {
      ci->nregs = 3;
    }
    else {
      ci->nregs = n + 2;
    }
    int ai = mrb->arena_idx;
    int stackidx = mrb->ci->stackidx;
    int cioff = mrb->ci - mrb->cibase;
    val = p->body.func(mrb, self);
    mrb->arena_idx = ai;
    mrb_gc_protect(mrb, val);
    if ((mrb->ci - mrb->cibase) == cioff) {
      mrb->stack = mrb->stbase + stackidx;
      cipop(mrb);
    } else { // break
      mrb->stack = mrb->stbase + stackidx; // not needed really? safeguard if somehow stack is accessed before break returns to proper location (shouldn't happen)
      cipop(mrb);
      cipush(mrb);
      mrb->ci->proc = -1;
      // TODO i think i cant pop every time, only the first time? but i do push too...
    }
  }
  else {
    if (ci->argc < 0) {
      stack_extend(mrb, (p->body.irep->nregs < 3) ? 3 : p->body.irep->nregs, 3);
    }
    else {
      stack_extend(mrb, p->body.irep->nregs,  ci->argc+2);
    }
    val = mrb_run(mrb, p, self);
  }
  *regs_ptr = mrb->stack; // stack_extend might realloc stack
  return val;
}

void
mrbb_send(mrb_state *mrb, mrb_sym mid, int argc, mrb_value **regs_ptr, int a, int sendb)
{
  mrb->stack[a] = mrbb_send_r(mrb, mid, argc, regs_ptr, a, sendb);
}
