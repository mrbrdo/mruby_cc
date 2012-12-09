void
mrbb_send(mrb_state *mrb, mrb_sym mid, int argc, mrb_value *regs, int a, int sendb)
{
  struct RProc *p;
  struct RClass *c;
  mrb_sym undef = 0;
  mrb_callinfo *ci;
  int n;
  mrb_value val;
  mrb_value self = regs[a];
  mrb_value *argv = regs + a + 1;
  mrb_value blk;

  n = mrb->ci->nregs;
  if (sendb) {
    blk = argv[argc];
  } else {
    blk = mrb_nil_value();
  }
  if (argc < 0) { // TODO
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "negative argc for funcall (%d)", argc);
  }
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
  if (ci->argc == CALL_MAXARGS) ci->argc = -1;
  ci->target_class = p->target_class;
  if (MRB_PROC_CFUNC_P(p)) {
    ci->nregs = argc + 2;
  }
  else {
    ci->nregs = p->body.irep->nregs + 2;
  }
  ci->acc = -1;
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

  if (MRB_PROC_CFUNC_P(p)) {
    if (ci->argc < 0) {
      ci->nregs = 3;
    }
    else {
      ci->nregs = n + 2;
    }
    int ai = mrb->arena_idx;
    regs[a] = p->body.func(mrb, self);
    mrb->arena_idx = ai;
    mrb->stack = mrb->stbase + mrb->ci->stackidx;
    cipop(mrb);
  }
  else {
    if (ci->argc < 0) {
      stack_extend(mrb, (p->body.irep->nregs < 3) ? 3 : p->body.irep->nregs, 3);
    }
    else {
      stack_extend(mrb, p->body.irep->nregs,  ci->argc+2);
    }
    regs[a] = mrb_run(mrb, p, self);
  }
}

mrb_value
mrb_funcall_fast_working100p(mrb_state *mrb, mrb_value self, mrb_sym mid, int argc, mrb_value *argv, mrb_value blk)
{
  struct RProc *p;
  struct RClass *c;
  mrb_sym undef = 0;
  mrb_callinfo *ci;
  int n;
  mrb_value val;

  if (!mrb->jmp) {
    jmp_buf c_jmp;

    if (setjmp(c_jmp) != 0) { /* error */
      mrb->jmp = 0;
      return mrb_nil_value();
    }
    mrb->jmp = &c_jmp;
    /* recursive call */
    val = mrb_funcall_with_block(mrb, self, mid, argc, argv, blk);
    mrb->jmp = 0;
    return val;
  }

  if (!mrb->stack) {
    stack_init(mrb);
  }
  n = mrb->ci->nregs;
  if (argc < 0) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "negative argc for funcall (%d)", argc);
  }
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
  if (ci->argc == CALL_MAXARGS) ci->argc = -1;
  ci->target_class = p->target_class;
  if (MRB_PROC_CFUNC_P(p)) {
    ci->nregs = argc + 2;
  }
  else {
    ci->nregs = p->body.irep->nregs + 2;
  }
  ci->acc = -1;
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

  if (MRB_PROC_CFUNC_P(p)) {
    if (ci->argc < 0) {
      ci->nregs = 3;
    }
    else {
      ci->nregs = n + 2;
    }
    int ai = mrb->arena_idx;
    val = p->body.func(mrb, self);
    mrb->arena_idx = ai;
    mrb_gc_protect(mrb, val);
    mrb->stack = mrb->stbase + mrb->ci->stackidx;
    cipop(mrb);
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
  *(argv - 1) = val;
  return val;
}

void
mrb_funcall_fast22(mrb_state *mrb, mrb_value self, mrb_sym mid, int argc, mrb_value *argv, mrb_value blk)
{
  /* A B C  R(A) := call(R(A),Sym(B),R(A+1),... ,R(A+C-1)) */
  int n = argc;
  struct RProc *m;
  struct RClass *c;
  mrb_callinfo *ci;
  mrb_value recv;
  int ai = mrb->arena_idx;
  mrb_value *regs = argv - 1;
  int a = 0;

  recv = regs[a];
  if (mrb_nil_p(blk)) {
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
  mrb_p(mrb, regs[a]);
  mrb_p(mrb, regs[a+1]);
  mrb_p(mrb, regs[a+2]);
  ci = cipush(mrb);
  mrb_p(mrb, regs[a]);
  mrb_p(mrb, regs[a+1]);
  mrb_p(mrb, regs[a+2]);
  ci->mid = mid;
  ci->proc = m;
  ci->stackidx = mrb->stack - mrb->stbase;
  ci->argc = n;
  if (ci->argc == CALL_MAXARGS) ci->argc = -1;
  ci->target_class = c;
  //ci->pc = pc + 1;
  //ci->acc = a;
  ci->acc = -1;

  /* prepare stack */
  mrb->stack = regs;

  if (MRB_PROC_CFUNC_P(m)) {
    printf("hello cfunc %d\n", regs);fflush(stdout);
    *regs = m->body.func(mrb, recv);
    mrb->arena_idx = ai;
    if (mrb->exc) mrbb_raise(mrb->exc, 0);
    /* pop stackpos */
    mrb->stack = mrb->stbase + mrb->ci->stackidx;
    cipop(mrb);
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
    //mrb_run(mrb, m, recv);
    *regs = mrb_run(mrb, m, recv);
  }
}

mrb_value
mrb_funcall_fast2(mrb_state *mrb, mrb_value self, mrb_sym mid, int argc, mrb_value *argv, mrb_value blk, mrb_value *regs, int a)
{
  struct RProc *p;
  struct RClass *c;
  mrb_sym undef = 0;
  mrb_callinfo *ci;
  int n;
  mrb_value val;

  if (!mrb->jmp) {
    jmp_buf c_jmp;

    if (setjmp(c_jmp) != 0) { /* error */
      mrb->jmp = 0;
      return mrb_nil_value();
    }
    mrb->jmp = &c_jmp;
    /* recursive call */
    val = mrb_funcall_with_block(mrb, self, mid, argc, argv, blk);
    mrb->jmp = 0;
    return val;
  }

  if (!mrb->stack) {
    stack_init(mrb);
  }
  n = mrb->ci->nregs;
  if (argc < 0) {
    mrb_raisef(mrb, E_ARGUMENT_ERROR, "negative argc for funcall (%d)", argc);
  }
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
  /*if (MRB_PROC_MRBCFUNC_P(p)) {
    ci->nregs = p->proc_nregs + 2; // !x
  } else if (MRB_PROC_CFUNC_P(p)) {
    ci->nregs = argc + 2;
  } else {
    ci->nregs = p->body.irep->nregs + 2;
  }*/
  ci->acc = -1;
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

  if (MRB_PROC_CFUNC_P(p)) {
    int ai = mrb->arena_idx;
    //printf("Call: %s\n", mrb_sym2name(mrb, mid));
    //printf("Ci: %d\n", mrb->ci - mrb->cibase);
    val = p->body.func(mrb, self);
    mrb->arena_idx = ai;
    mrb_gc_protect(mrb, val);
    mrb->stack = mrb->stbase + mrb->ci->stackidx;
    cipop(mrb);
  }
  else {
    val = mrb_run(mrb, p, self);
  }
  return val;
}
