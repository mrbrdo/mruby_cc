    CASE(OP_LAMBDA) {
      /* A b c  R(A) := lambda(SEQ[b],c) (b:c = 14:2) */
      struct RProc *p;
      int c = GETARG_c(i);

      if (c & OP_L_CAPTURE) {
        p = mrbb_closure_new(mrb, GETARG_b(i), (unsigned int)GETIREP_NLOCALS());
      }
      else {
        p = mrbb_proc_new(mrb, GETARG_b(i));
      }

      // TODO: we need this but why?
      p->target_class = (mrb->c->ci) ? mrb->c->ci->target_class : 0;

      if ((c & OP_L_METHOD) && !(c & OP_L_CAPTURE)) {
        if (p->target_class->tt == MRB_TT_SCLASS) {
          mrb_value klass;
          klass = mrb_obj_iv_get(mrb,
                                 (struct RObject *)p->target_class,
                                 mrb_intern_lit(mrb, "__attached__"));
          p->target_class = mrb_class_ptr(klass);
        }
      }

      if (c & OP_L_STRICT) p->flags |= MRB_PROC_STRICT;
      regs[GETARG_A(i)] = mrb_obj_value(p);
      ARENA_RESTORE(mrb, ai);
      NEXT;
    }

    CASE(OP_EXEC) {
      /* A Bx   R(A) := blockexec(R(A),SEQ[Bx]) */
      int a = GETARG_A(i);
      mrb_callinfo *ci;
      mrb_value recv = regs[a];
      struct RProc *p;

      /* prepare stack */
      ci = cipush(mrb);
      //ci->pc = pc + 1;
      ci->acc = a;
      ci->mid = 0;
      ci->stackent = mrb->c->stack;
      ci->argc = 0;
      ci->target_class = mrb_class_ptr(recv); // TODO: check if we might need mrb_class() instead

      /* prepare stack */
      mrb->c->stack += a;

      p = mrbb_proc_new(mrb, GETARG_Bx(i));
      // p = mrb_proc_new(mrb, mrb->irep[irep->idx+GETARG_Bx(i)]);
      p->target_class = ci->target_class;
      ci->proc = p;

      // if (MRB_PROC_CFUNC_P(p)) {
      // else part removed since it is always CFUNC

      ci->nregs = 0;
      mrb->c->stack[0] = p->body.func(mrb, recv);
      mrb_gc_arena_restore(mrb, ai);
      if (mrb->exc) mrbb_raise(mrb);
      /* pop stackpos */
      regs = mrb->c->stack = mrb->c->ci->stackent;
      cipop(mrb);
      NEXT;
    }
