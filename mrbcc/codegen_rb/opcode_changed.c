    CASE(OP_RESCUE) { // TODO
      /* A      R(A) := exc; clear(exc) */
      SET_OBJ_VALUE(regs[GETARG_A(i)], mrb->exc);
      mrb->exc = 0;
      NEXT;
    }

  CASE(OP_SEND) {
      int a = GETARG_A(i);
      int n = GETARG_C(i);
      mrb_value ret;

      ret = mrbb_send_r(mrb, syms[GETARG_B(i)], n, &regs, a, 0);
      if (mrb->c->ci->proc == (struct RProc *) -1) {
        //cipush(mrb);
        return ret;
      }
      regs[a] = ret;
      mrb->arena_idx = ai; // TODO do we need (because of break;)?
      NEXT;
  }
  CASE(OP_SENDB) {
      int a = GETARG_A(i);
      int n = GETARG_C(i);
      mrb_value ret;

      ret = mrbb_send_r(mrb, syms[GETARG_B(i)], n, &regs, a, 1);
      if (mrb->c->ci->proc == (struct RProc *) -1) {
        //cipush(mrb);
        return ret;
      }
      regs[a] = ret;
      mrb->arena_idx = ai; // TODO probably can remove
      NEXT;
  }


    CASE(OP_STOP) {
      /*        stop VM */
      {
        int eidx_stop = mrb->c->ci == mrb->c->cibase ? 0 : mrb->c->ci[-1].eidx;
        int eidx = mrb->c->ci->eidx;
        while (eidx > eidx_stop) {
          mrbb_ecall(mrb, mrb->c->ensure[--eidx]);
        }
      }
      if (mrb->exc) {
        return mrb_obj_value(mrb->exc);
      }
      return regs[GETIREP_NLOCALS()];
    }

    CASE(OP_RETURN) {
      {
        mrb_callinfo *ci = mrb->c->ci;
        int eidx = mrb->c->ci->eidx;
        int ridx = mrb->c->ci->ridx;
        mrb_value v = regs[GETARG_A(i)];
        struct RProc *proc = mrb->c->ci->proc;

        if (mrb->exc) {
          mrbb_raise(mrb);
        }

        switch (GETARG_B(i)) {
        case OP_R_RETURN:
          if (proc->env || !MRB_PROC_STRICT_P(proc)) {
            struct REnv *e = top_env(mrb, proc);

            if (e->cioff < 0) {
              localjump_error(mrb, LOCALJUMP_ERROR_RETURN);
              goto L_RAISE;
            }
            mrb->c->ci = mrb->c->cibase + e->cioff;
            if (ci == mrb->c->cibase) {
              localjump_error(mrb, LOCALJUMP_ERROR_RETURN);
              goto L_RAISE;
            }
            break;
          }
        case OP_R_NORMAL:
          if (ci == mrb->c->cibase) {
            localjump_error(mrb, LOCALJUMP_ERROR_RETURN);
            goto L_RAISE;
          }
          break;
        case OP_R_BREAK:
          if (!proc->env || !MRB_ENV_STACK_SHARED_P(proc->env)) {
            localjump_error(mrb, LOCALJUMP_ERROR_BREAK);
            goto L_RAISE;
          }
          ci = mrb->c->ci;
          mrb->c->ci = mrb->c->cibase + proc->env->cioff + 1;
          while (ci > mrb->c->ci) {
            if (ci[-1].acc == CI_ACC_SKIP) {
              mrb->c->ci = ci;
              break;
            }
            ci--;
          }
          break;
        default:
          /* cannot happen */
          break;
        }

        while (eidx > mrb->c->ci[-1].eidx) {
          mrbb_ecall(mrb, mrb->c->ensure[--eidx]);
        }

        if (GETARG_B(i) == OP_R_BREAK) {
          if (mrb->c->ci->acc != CI_ACC_SKIP) {
            ci--;
            regs = mrb->c->stack = ci->stackent;
            regs[ci->proc->body.irep->nlocals] = v;
            mrb->c->ci->stackent = ci->stackent;
            mrb->c->ci->pc = &c_break_code;
            //mrb->c->ci->pc = mrb->c->ci->pc;
            mrb->c->ci->target_class = 0;
            return mrb->c->stack[mrb->c->ci->acc];
          } else {
            mrb->c->ci = mrb->c->cibase + proc->env->cioff + 1;
          }
        }
        return v;
      }
    }
