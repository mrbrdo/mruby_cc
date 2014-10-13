
    CASE(OP_CALL) {
      /* A      R(A) := self.call(frame.argc, frame.argv) */

      // OP_CALL is used in mruby only in Proc#call and Proc#[]
      // This opcode is not generated in mruby bytecode
      // It is only generated on the fly
      // We overwrite both these methods, so this opcode should never appear

      printf("Error: OP_CALL\n");
      exit(0);
      FAIL_COMPILE_GARBAGE // This will fail compiler
    }

    CASE(OP_SUPER) {
      /* A B C  R(A) := super(R(A+1),... ,R(A+C-1)) */
      mrb_value recv;
      mrb_callinfo *ci = mrb->c->ci;
      struct RProc *m;
      struct RClass *c;
      mrb_sym mid = ci->mid;
      int a = GETARG_A(i);
      int n = GETARG_C(i);

      recv = regs[0];
      c = mrb->c->ci->target_class->super;
      m = mrb_method_search_vm(mrb, &c, mid);
      if (!m) {
        mid = mrb_intern_cstr(mrb, "method_missing");
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
      ci->stackent = mrb->c->stack;
      ci->argc = n;
      if (ci->argc == CALL_MAXARGS) ci->argc = -1;
      ci->target_class = m->target_class;
      //ci->pc = pc + 1;

      /* prepare stack */
      mrb->c->stack += a;
      mrb->c->stack[0] = recv;

      if (MRB_PROC_CFUNC_P(m)) {
        mrb->c->stack[0] = m->body.func(mrb, recv);
        mrb->arena_idx = ai;
        if (mrb->exc) goto L_RAISE;
        /* pop stackpos */
        regs = mrb->c->stack = mrb->c->ci->stackent;
        cipop(mrb);
        NEXT;
      }
      else {
        printf("TODO SUPER 2 MRB\n");
        exit(0);
      }
    }
