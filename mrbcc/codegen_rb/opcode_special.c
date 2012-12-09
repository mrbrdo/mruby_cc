
    CASE(OP_CALL) {
      /* A      R(A) := self.call(frame.argc, frame.argv) */
      mrb_callinfo *ci;
      mrb_value recv = mrb->stack[0];
      struct RProc *m = mrb_proc_ptr(recv);

      /* replace callinfo */
      ci = mrb->ci;
      ci->target_class = m->target_class;
      ci->proc = m;
      if (m->env) {
  if (m->env->mid) {
    ci->mid = m->env->mid;
  }
        if (!m->env->stack) {
          m->env->stack = mrb->stack;
        }
      }

      /* prepare stack */
      if (MRB_PROC_CFUNC_P(m)) {
  recv = m->body.func(mrb, recv);
        mrb->arena_idx = ai;
        if (mrb->exc) goto L_RAISE;
        /* pop stackpos */
  ci = mrb->ci;
        regs = mrb->stack = mrb->stbase + ci->stackidx;
  regs[ci->acc] = recv;
  pc = ci->pc;
        cipop(mrb);
        irep = mrb->ci->proc->body.irep;
        pool = irep->pool;
        syms = irep->syms;
        JUMP;
      }
      else {
        /* setup environment for calling method */
        proc = m;
        irep = m->body.irep;
  if (!irep) {
    mrb->stack[0] = mrb_nil_value();
    goto L_RETURN;
  }
        pool = irep->pool;
        syms = irep->syms;
        ci->nregs = irep->nregs;
        if (ci->argc < 0) {
          stack_extend(mrb, (irep->nregs < 3) ? 3 : irep->nregs, 3);
        }
        else {
          stack_extend(mrb, irep->nregs,  ci->argc+2);
        }
        regs = mrb->stack;
        regs[0] = m->env->stack[0];
        pc = m->body.irep->iseq;
        JUMP;
      }
    }

    CASE(OP_SUPER) {
      /* A B C  R(A) := super(R(A+1),... ,R(A+C-1)) */
      mrb_value recv;
      mrb_callinfo *ci = mrb->ci;
      struct RProc *m;
      struct RClass *c;
      mrb_sym mid = ci->mid;
      int a = GETARG_A(i);
      int n = GETARG_C(i);

      recv = regs[0];
      c = mrb->ci->target_class->super;
      m = mrb_method_search_vm(mrb, &c, mid);
      if (!m) {
        mid = mrb_intern(mrb, "method_missing");
        m = mrb_method_search_vm(mrb, &c, mid);
        if (n == CALL_MAXARGS) {
          mrb_ary_unshift(mrb, regs[a+1], mrb_symbol_value(ci->mid));
        }
        else {
          memmove(regs+a+2, regs+a+1, sizeof(mrb_value)*(n+1));
    SET_SYM_VALUE(regs[a+1], ci->mid);
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
      ci->target_class = m->target_class;
      //ci->pc = pc + 1;

      /* prepare stack */
      mrb->stack += a;
      mrb->stack[0] = recv;

      if (MRB_PROC_CFUNC_P(m)) {
        mrb->stack[0] = m->body.func(mrb, recv);
        mrb->arena_idx = ai;
        if (mrb->exc) goto L_RAISE;
        /* pop stackpos */
        regs = mrb->stack = mrb->stbase + mrb->ci->stackidx;
        cipop(mrb);
        NEXT;
      }
      else {
        printf("TODO SUPER 2 MRB\n");
        exit(0);
      }
    }
