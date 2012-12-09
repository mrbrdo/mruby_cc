    CASE(OP_RESCUE) { // TODO
      /* A      R(A) := exc; clear(exc) */
      mrb->ci = ci;
      SET_OBJ_VALUE(regs[GETARG_A(i)], mrb->exc);
      mrb->exc = 0;
      NEXT;
    }

  CASE(OP_SEND) {
      int a = GETARG_A(i);
      int n = GETARG_C(i);
      mrb_callinfo *prev_ci = mrb->ci;

      mrbb_send(mrb, syms[GETARG_B(i)], n, regs, a, 0);
      mrb->arena_idx = ai; // TODO probably can remove
      if (mrb->ci != prev_ci) { // special OP_RETURN (e.g. break)
        cipush(mrb);
        return regs[a];
      }
      NEXT;
  }
  CASE(OP_SENDB) {
      int a = GETARG_A(i);
      int n = GETARG_C(i);
      mrb_callinfo *prev_ci = mrb->ci;

      mrbb_send(mrb, syms[GETARG_B(i)], n, regs, a, 1);
      mrb->arena_idx = ai; // TODO probably can remove
      if (mrb->ci != prev_ci) { // special OP_RETURN (e.g. break)
        cipush(mrb);
        return regs[a];
      }
      NEXT;
  }


    CASE(OP_STOP) {
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

    CASE(OP_RETURN) {
      {
        mrb_callinfo *ci = mrb->ci;
        int acc, eidx = mrb->ci->eidx;
        mrb_value v = regs[GETARG_A(i)];

        if (mrb->exc) {
          mrbb_raise(mrb, 0);
        }

        switch (GETARG_B(i)) {
        case OP_R_RETURN:
          if (proc->env || !MRB_PROC_STRICT_P(proc)) {
            struct REnv *e = top_env(mrb, proc);

            if (e->cioff < 0) {
              localjump_error(mrb, "return");
              goto L_RAISE;
            }
            mrb->ci = mrb->cibase + e->cioff;
            break;
          }
        case OP_R_NORMAL:
          if (ci == mrb->cibase) {
            localjump_error(mrb, "return");
            goto L_RAISE;
          }
          break;
        case OP_R_BREAK:
          if (proc->env->cioff < 0) {
            localjump_error(mrb, "break");
            goto L_RAISE;
          }
          mrb->ci = mrb->cibase + proc->env->cioff + 1;
          break;
        default:
          /* cannot happen */
          break;
        }

        while (eidx > mrb->ci[-1].eidx) {
          mrbb_ecall(mrb, mrb->ensure[--eidx]);
        }
        mrb->jmp = prev_jmp;
        /*
        if (acc < 0) {
          mrb->jmp = prev_jmp;
          return v;
        }
        */
        // TODO optimize (cipop in funcall)
        // important with OP_RETURN break
        return v;
      }
    }
