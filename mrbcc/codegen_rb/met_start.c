mrb_value MET_NAME(mrb_state *mrb, mrb_value self) {
  mrb_value *regs = NULL;
  int ai = mrb->arena_idx; // is the same throughout the same compiled program

  // I have to set up my own stack
  {
    mrb_callinfo *ci = mrb->c->ci;
    ci->nregs = FUNC_NREGS + 2;
    if (ci->argc < 0) {
      stack_extend(mrb, (FUNC_NREGS < 3) ? 3 : FUNC_NREGS, 3);
    }
    else {
      stack_extend(mrb, FUNC_NREGS, ci->argc+2);
    }
  }

  regs = mrb->c->stack;
  regs[0] = self;
