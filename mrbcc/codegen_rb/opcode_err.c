    CASE(OP_ONERR) {
      /* sBx    pc+=sBx on exception */
      struct mrb_jmpbuf buf;
      int stoff = mrb->c->stack - mrb->c->stbase;
      int cioff = mrb->c->ci - mrb->c->cibase;

      MRB_TRY(&buf) {
        mrb->jmp = &buf;
        mrbb_rescue_push(mrb, &buf);
      }
      MRB_CATCH(&buf) {
        // if rescued from method that was called from this method
        // and didn't have its own rescue
        // fix global state, be careful if stbase or cibase changed
        mrb->c->ci = mrb->c->cibase + cioff;
        regs = mrb->c->stack = mrb->c->stbase + stoff;

        // go to rescue
        mrbb_rescue_pop(mrb);
        if (mrbb_is_c_rescue(mrb->c->rescue[mrb->c->ci->ridx-1])) {
          struct mrb_rescue_code *rescue_code = (struct mrb_rescue_code *) mrb->c->rescue[mrb->c->ci->ridx-1];
          mrb->jmp = rescue_code->jmp;
        }
        goto rescue_label(GETARG_sBx(i));
      }
      MRB_END_EXC(&buf);

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
      p->target_class = mrb_class(mrb, self); // TODO check why/if we need
      /* push ensure_stack */
      if (mrb->c->esize <= mrb->c->ci->eidx) {
        if (mrb->c->esize == 0) mrb->c->esize = 16;
        else mrb->c->esize *= 2;
        mrb->c->ensure = (struct RProc **)mrb_realloc(mrb, mrb->c->ensure, sizeof(struct RProc*) * mrb->c->esize);
      }
      mrb->c->ensure[mrb->c->ci->eidx++] = p;
      ARENA_RESTORE(mrb, ai);
      NEXT;
    }

    CASE(OP_EPOP) {
      /* A      A.times{ensure_pop().call} */
      int a = GETARG_A(i);
      mrb_callinfo *ci = mrb->c->ci;
      int n, eidx = ci->eidx;

      for (n=0; n<a && eidx > ci[-1].eidx; n++) {
        mrbb_ecall(mrb, mrb->c->ensure[--mrb->c->ci->eidx]);
        ARENA_RESTORE(mrb, ai);
      }
      NEXT;
    }
