
// from vm.c
static void
ecall(mrb_state *mrb, int i)
{
  struct RProc *p;
  mrb_callinfo *ci;
  mrb_value *self = mrb->stack;
  struct RObject *exc;

  p = mrb->ensure[i];
  ci = cipush(mrb);
  ci->stackidx = mrb->stack - mrb->stbase;
  ci->mid = ci[-1].mid;
  ci->acc = -1;
  ci->argc = 0;
  ci->proc = p;
  ci->nregs = p->body.irep->nregs;
  ci->target_class = p->target_class;
  mrb->stack = mrb->stack + ci[-1].nregs;
  exc = mrb->exc; mrb->exc = 0;
  mrb_run(mrb, p, *self);
  if (!mrb->exc) mrb->exc = exc;
}

static void
mrbb_ecall(mrb_state *mrb, struct RProc *p)
{
  mrb_callinfo *ci;
  mrb_value *self = mrb->stack;
  struct RObject *exc;
  int ai = mrb->arena_idx;

  ci = cipush(mrb);
  ci->stackidx = mrb->stack - mrb->stbase;
  ci->mid = ci[-1].mid;
  ci->acc = -1;
  ci->argc = 0;
  ci->proc = p;
  ci->target_class = p->target_class;
  mrb->stack = mrb->stack + ci[-1].nregs;
  exc = mrb->exc; mrb->exc = 0;
  p->body.func(mrb, *self);
  mrb->arena_idx = ai;
  mrb->stack = mrb->stbase + mrb->ci->stackidx;
  cipop(mrb);
  if (!mrb->exc) mrb->exc = exc;
}

void mrbb_stop(mrb_state *mrb) {
  printf("goto L_STOP\n");
  exit(0);
}
void mrbb_raise(mrb_state *mrb, jmp_buf *prev_jmp) {
  // stolen from OP_RETURN
  mrb_callinfo *ci;
  int eidx;
  ci = mrb->ci;
  eidx = mrb->ci->eidx;

  if (ci == mrb->cibase) mrbb_stop(mrb);
  while (ci[0].ridx == ci[-1].ridx) {
    cipop(mrb);
    ci = mrb->ci;
    /*if (ci[1].acc < 0 && prev_jmp) {
      mrb->jmp = prev_jmp;
      longjmp(*(jmp_buf*)mrb->jmp, 1);
    }*/
    if (ci[1].acc < 0 && mrb->jmp) {
      longjmp(*(jmp_buf*)mrb->jmp, 1);
    }
    while (eidx > mrb->ci->eidx) {
      ecall(mrb, --eidx);
    }
    if (ci == mrb->cibase) {
      if (ci->ridx == 0) {
        // TODO regs =
        mrb->stack = mrb->stbase;
        mrbb_stop(mrb);
      }
      break;
    }
  }

  longjmp(*(jmp_buf*)mrb->jmp, 1);
 /* irep = ci->proc->body.irep;
  pool = irep->pool;
  syms = irep->syms;
  regs = mrb->stack = mrb->stbase + ci[1].stackidx;
  pc = mrb->rescue[--ci->ridx];*/
}
