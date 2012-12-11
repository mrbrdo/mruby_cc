mrb_value MET_NAME(mrb_state *mrb, mrb_value self) {
  mrb_value *regs = NULL;
  int ai = mrb->arena_idx;
  jmp_buf *prev_jmp = (jmp_buf *)mrb->jmp;
  struct RProc *proc = mrb->ci->proc;
  mrb_callinfo *ci = mrb->ci;
  int cioff = mrb->ci - mrb->cibase;

  // I have to set up my own stack
  mrb->ci->nregs = FUNC_NREGS + 2;
  if (ci->argc < 0) {
    stack_extend(mrb, (FUNC_NREGS < 3) ? 3 : FUNC_NREGS, 3);
  }
  else {
    stack_extend(mrb, FUNC_NREGS, ci->argc+2);
  }

  //mrb->ci->proc = proc;
  regs = mrb->stack;
  regs[0] = self;
