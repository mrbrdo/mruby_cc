mrb_value rb_main(mrb_state *mrb, mrb_value self) {
  mrb_value *regs = NULL;
  int ai = mrb->arena_idx;
  jmp_buf *prev_jmp = (jmp_buf *)mrb->jmp;
  struct RProc *proc = mrb->ci->proc;
  mrb_callinfo *ci = mrb->ci;

  // I have to set up my own stack
  mrb->ci->nregs = 3 + 2;
  if (ci->argc < 0) {
    stack_extend(mrb, (3 < 3) ? 3 : 3, 3);
  }
  else {
    stack_extend(mrb, 3, ci->argc+2);
  }

  //mrb->ci->proc = proc;
  regs = mrb->stack;
  regs[0] = self;

  // ["OP_LOADSELF", 1, 0, 0]
  L_RB_MAIN_0:
  {
      /* A      R(A) := self */
      regs[1] = regs[0];
      NEXT;
    }

  // ["OP_STRING", 2, 0, 0]
  L_RB_MAIN_1:
  {
      /* A Bx           R(A) := str_new(Lit(Bx)) */
      regs[2] = mrb_str_new_cstr(mrb, "hello world");
      mrb->arena_idx = ai;
      NEXT;
    }

  // ["OP_SEND", 1, 0, 1]
  L_RB_MAIN_2:
  {
      int a = 1;
      int n = 1;
      mrb_callinfo *prev_ci = mrb->ci;

      mrbb_send(mrb, mrb_intern(mrb, "puts"), n, regs, a, 0);
      mrb->arena_idx = ai; // TODO probably can remove
      if (mrb->ci != prev_ci) { // special OP_RETURN (e.g. break)
        cipush(mrb);
        return regs[a];
      }
      NEXT;
  }

  // ["OP_STOP", 0, 0, 0]
  L_RB_MAIN_3:
  {
      /*        stop VM */
/*    L_STOP:
      {
  int n = mrb->ci->eidx;

  while (n--) {
    ecall(mrb, n);
  }
      }
      mrb->jmp = prev_jmp;
      if (mrb->exc) {
  return mrb_obj_value(mrb->exc);
      }
      return regs[irep->nlocals];*/
    }

}
