
    CASE(OP_TAILCALL) {
      /* A B C  return call(R(A),Sym(B),R(A+1),... ,R(A+C-1)) */
      int a = GETARG_A(i);
      int n = GETARG_C(i);
      struct RProc *m;
      struct RClass *c;
      mrb_callinfo *ci;
      mrb_value recv;
      mrb_sym mid = syms[GETARG_B(i)];

      recv = regs[a];
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


      /* replace callinfo */
      ci = mrb->ci;
      ci->mid = mid;
      ci->target_class = m->target_class;
      ci->argc = n;
      if (ci->argc == CALL_MAXARGS) ci->argc = -1;

      /* move stack */
      memmove(mrb->stack, &regs[a], (ci->argc+1)*sizeof(mrb_value));

      if (MRB_PROC_CFUNC_P(m)) {
        mrb->stack[0] = m->body.func(mrb, recv);
        mrb->arena_idx = ai;
        goto L_RETURN;
      }
      else {
        /* setup environment for calling method */
        irep = m->body.irep;
        pool = irep->pool;
        syms = irep->syms;
        if (ci->argc < 0) {
          stack_extend(mrb, (irep->nregs < 3) ? 3 : irep->nregs, 3);
        }
        else {
          stack_extend(mrb, irep->nregs,  ci->argc+2);
        }
        regs = mrb->stack;
        pc = irep->iseq;
      }
      JUMP;
    }
