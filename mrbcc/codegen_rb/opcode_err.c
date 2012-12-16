    CASE(OP_ONERR) {
      /* sBx    pc+=sBx on exception */
      jmp_buf c_jmp;
      int stoff = mrb->stack - mrb->stbase;
      int cioff = mrb->ci - mrb->cibase;

      if (setjmp(c_jmp) == 0) {
        mrb->jmp = &c_jmp;
        mrbb_rescue_push(mrb, &c_jmp);
      }
      else {
        // if rescued from method that was called from this method
        // and didn't have its own rescue
        // fix global state, be careful if stbase or cibase changed
        mrb->ci = mrb->cibase + cioff;
        regs = mrb->stack = mrb->stbase + stoff;

        // go to rescue
        mrbb_rescue_pop(mrb);
        mrb->jmp = (jmp_buf *)mrb->rescue[mrb->ci->ridx-1];
        goto rescue_label(GETARG_sBx(i));
      }

      NEXT;
    }

    CASE(OP_POPERR) {
      int a = GETARG_A(i);

      while (a--) {
        mrbb_rescue_pop(mrb);
      }
      NEXT;
    }

    CASE(OP_EPUSH) {
      /* Bx     ensure_push(SEQ[Bx]) */
      struct RProc *p;

      p = mrbb_closure_new(mrb, GETARG_Bx(i), (unsigned int)GETIREP_NLOCALS());
      /* push ensure_stack */
      if (mrb->esize <= mrb->ci->eidx) {
        if (mrb->esize == 0) mrb->esize = 16;
        else mrb->esize *= 2;
        mrb->ensure = (struct RProc **)mrb_realloc(mrb, mrb->ensure, sizeof(struct RProc*) * mrb->esize);
      }
      mrb->ensure[mrb->ci->eidx++] = p;
      mrb->arena_idx = ai;

      NEXT;
    }

    CASE(OP_EPOP) {
      /* A      A.times{ensure_pop().call} */
      int n;
      int a = GETARG_A(i);

      for (n=0; n<a; n++) {
        mrbb_ecall(mrb, mrb->ensure[--mrb->ci->eidx]);
      }
      mrb->arena_idx = ai;

      NEXT;
    }
