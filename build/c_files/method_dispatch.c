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
