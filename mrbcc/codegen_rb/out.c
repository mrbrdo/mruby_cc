mrb_value met_f18972cd527e1d78bd37abb5cb6b081e(mrb_state *mrb, mrb_value self) {
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
  L_MET_F18972CD527E1D78BD37ABB5CB6B081E_0:
  {
      /* A      R(A) := self */
      regs[1] = regs[0];
      NEXT;
    }

  // ["OP_STRING", 2, 0, 0]
  L_MET_F18972CD527E1D78BD37ABB5CB6B081E_1:
  {
      /* A Bx           R(A) := str_new(Lit(Bx)) */
      regs[2] = mrb_str_new_cstr(mrb, "ok");
      mrb->arena_idx = ai;
      NEXT;
    }

  // ["OP_SEND", 1, 0, 1]
  L_MET_F18972CD527E1D78BD37ABB5CB6B081E_2:
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

  // ["OP_RETURN", 1, 0, 0]
  L_MET_F18972CD527E1D78BD37ABB5CB6B081E_3:
  {
      {
        mrb_callinfo *ci = mrb->ci;
        int acc, eidx = mrb->ci->eidx;
        mrb_value v = regs[1];

        if (mrb->exc) {
          mrbb_raise(mrb, 0);
        }

        switch (0) {
        case OP_R_RETURN:
          if (proc->env || !MRB_PROC_STRICT_P(proc)) {
            struct REnv *e = top_env(mrb, proc);

            if (e->cioff < 0) {
              localjump_error(mrb, "return");
              mrbb_raise(mrb, prev_jmp);
            }
            mrb->ci = mrb->cibase + e->cioff;
            break;
          }
        case OP_R_NORMAL:
          if (ci == mrb->cibase) {
            localjump_error(mrb, "return");
            mrbb_raise(mrb, prev_jmp);
          }
          break;
        case OP_R_BREAK:
          if (proc->env->cioff < 0) {
            localjump_error(mrb, "break");
            mrbb_raise(mrb, prev_jmp);
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

}
mrb_value met_a76556a4011695605d078c8391b1a2de(mrb_state *mrb, mrb_value self) {
  mrb_value *regs = NULL;
  int ai = mrb->arena_idx;
  jmp_buf *prev_jmp = (jmp_buf *)mrb->jmp;
  struct RProc *proc = mrb->ci->proc;
  mrb_callinfo *ci = mrb->ci;

  // I have to set up my own stack
  mrb->ci->nregs = 5 + 2;
  if (ci->argc < 0) {
    stack_extend(mrb, (5 < 3) ? 3 : 5, 3);
  }
  else {
    stack_extend(mrb, 5, ci->argc+2);
  }

  //mrb->ci->proc = proc;
  regs = mrb->stack;
  regs[0] = self;

  // ["OP_ENTER", 0, 32, 1]
  L_MET_A76556A4011695605D078C8391B1A2DE_0:
  {
      /* Ax             arg setup according to flags (24=5:5:1:5:5:1:1) */
      /* number of optional arguments times OP_JMP should follow */
      int ax = 4097;
      int m1 = (ax>>18)&0x1f;
      int o  = (ax>>13)&0x1f;
      int r  = (ax>>12)&0x1;
      int m2 = (ax>>7)&0x1f;
      /* unused
      int k  = (ax>>2)&0x1f;
      int kd = (ax>>1)&0x1;
      int b  = (ax>>0)& 0x1;
      */
      int argc = mrb->ci->argc;
      mrb_value *argv = regs+1;
      mrb_value *argv0 = argv;
      int len = m1 + o + r + m2;
      mrb_value *blk = &argv[argc < 0 ? 1 : argc];

      if (argc < 0) {
        struct RArray *ary = mrb_ary_ptr(regs[1]);
        argv = ary->ptr;
        argc = ary->len;
  mrb_gc_protect(mrb, regs[1]);
      }
      if (mrb->ci->proc && MRB_PROC_STRICT_P(mrb->ci->proc)) {
        if (argc >= 0) {
          if (argc < m1 + m2 || (r == 0 && argc > len)) {
      argnum_error(mrb, m1+m2);
      mrbb_raise(mrb, prev_jmp);
          }
        }
      }
      else if (len > 1 && argc == 1 && mrb_array_p(argv[0])) {
        argc = mrb_ary_ptr(argv[0])->len;
        argv = mrb_ary_ptr(argv[0])->ptr;
      }
      mrb->ci->argc = len;
      if (argc < len) {
        regs[len+1] = *blk; /* move block */
        if (argv0 != argv) {
          memmove(&regs[1], argv, sizeof(mrb_value)*(argc-m2)); /* m1 + o */
        }
        if (m2) {
          memmove(&regs[len-m2+1], &argv[argc-m2], sizeof(mrb_value)*m2); /* m2 */
        }
        if (r) {                  /* r */
          regs[m1+o+1] = mrb_ary_new_capa(mrb, 0);
        }
   goto L_MET_A76556A4011695605D078C8391B1A2DE_1;
      }
      else {
        if (argv0 != argv) {
          memmove(&regs[1], argv, sizeof(mrb_value)*(m1+o)); /* m1 + o */
        }
        if (r) {                  /* r */
          regs[m1+o+1] = mrb_ary_new_elts(mrb, argc-m1-o-m2, argv+m1+o);
        }
        if (m2) {
          memmove(&regs[m1+o+r+1], &argv[argc-m2], sizeof(mrb_value)*m2);
        }
        regs[len+1] = *blk; /* move block */
        goto L_MET_A76556A4011695605D078C8391B1A2DE_1;
      }
      
    }

  // ["OP_LOADSELF", 3, 0, 0]
  L_MET_A76556A4011695605D078C8391B1A2DE_1:
  {
      /* A      R(A) := self */
      regs[3] = regs[0];
      NEXT;
    }

  // ["OP_MOVE", 4, 1, 0]
  L_MET_A76556A4011695605D078C8391B1A2DE_2:
  {
      /* A B    R(A) := R(B) */
      regs[4] = regs[1];
      NEXT;
    }

  // ["OP_SEND", 3, 0, 1]
  L_MET_A76556A4011695605D078C8391B1A2DE_3:
  {
      int a = 3;
      int n = 1;
      mrb_callinfo *prev_ci = mrb->ci;

      mrbb_send(mrb, mrb_intern(mrb, "p"), n, regs, a, 0);
      mrb->arena_idx = ai; // TODO probably can remove
      if (mrb->ci != prev_ci) { // special OP_RETURN (e.g. break)
        cipush(mrb);
        return regs[a];
      }
      NEXT;
  }

  // ["OP_LOADSELF", 3, 0, 0]
  L_MET_A76556A4011695605D078C8391B1A2DE_4:
  {
      /* A      R(A) := self */
      regs[3] = regs[0];
      NEXT;
    }

  // ["OP_MOVE", 4, 2, 0]
  L_MET_A76556A4011695605D078C8391B1A2DE_5:
  {
      /* A B    R(A) := R(B) */
      regs[4] = regs[2];
      NEXT;
    }

  // ["OP_SEND", 3, 0, 1]
  L_MET_A76556A4011695605D078C8391B1A2DE_6:
  {
      int a = 3;
      int n = 1;
      mrb_callinfo *prev_ci = mrb->ci;

      mrbb_send(mrb, mrb_intern(mrb, "p"), n, regs, a, 0);
      mrb->arena_idx = ai; // TODO probably can remove
      if (mrb->ci != prev_ci) { // special OP_RETURN (e.g. break)
        cipush(mrb);
        return regs[a];
      }
      NEXT;
  }

  // ["OP_MOVE", 3, 2, 0]
  L_MET_A76556A4011695605D078C8391B1A2DE_7:
  {
      /* A B    R(A) := R(B) */
      regs[3] = regs[2];
      NEXT;
    }

  // ["OP_SEND", 3, 1, 0]
  L_MET_A76556A4011695605D078C8391B1A2DE_8:
  {
      int a = 3;
      int n = 0;
      mrb_callinfo *prev_ci = mrb->ci;

      mrbb_send(mrb, mrb_intern(mrb, "call"), n, regs, a, 0);
      mrb->arena_idx = ai; // TODO probably can remove
      if (mrb->ci != prev_ci) { // special OP_RETURN (e.g. break)
        cipush(mrb);
        return regs[a];
      }
      NEXT;
  }

  // ["OP_RETURN", 3, 0, 0]
  L_MET_A76556A4011695605D078C8391B1A2DE_9:
  {
      {
        mrb_callinfo *ci = mrb->ci;
        int acc, eidx = mrb->ci->eidx;
        mrb_value v = regs[3];

        if (mrb->exc) {
          mrbb_raise(mrb, 0);
        }

        switch (0) {
        case OP_R_RETURN:
          if (proc->env || !MRB_PROC_STRICT_P(proc)) {
            struct REnv *e = top_env(mrb, proc);

            if (e->cioff < 0) {
              localjump_error(mrb, "return");
              mrbb_raise(mrb, prev_jmp);
            }
            mrb->ci = mrb->cibase + e->cioff;
            break;
          }
        case OP_R_NORMAL:
          if (ci == mrb->cibase) {
            localjump_error(mrb, "return");
            mrbb_raise(mrb, prev_jmp);
          }
          break;
        case OP_R_BREAK:
          if (proc->env->cioff < 0) {
            localjump_error(mrb, "break");
            mrbb_raise(mrb, prev_jmp);
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

}
mrb_value rb_main(mrb_state *mrb, mrb_value self) {
  mrb_value *regs = NULL;
  int ai = mrb->arena_idx;
  jmp_buf *prev_jmp = (jmp_buf *)mrb->jmp;
  struct RProc *proc = mrb->ci->proc;
  mrb_callinfo *ci = mrb->ci;

  // I have to set up my own stack
  mrb->ci->nregs = 5 + 2;
  if (ci->argc < 0) {
    stack_extend(mrb, (5 < 3) ? 3 : 5, 3);
  }
  else {
    stack_extend(mrb, 5, ci->argc+2);
  }

  //mrb->ci->proc = proc;
  regs = mrb->stack;
  regs[0] = self;

  // ["OP_TCLASS", 1, 0, 0]
  L_RB_MAIN_0:
  {
      /* A B    R(A) := target_class */
      if (!mrb->ci->target_class) {
        static const char msg[] = "no target class or module";
        mrb_value exc = mrb_exc_new(mrb, E_TYPE_ERROR, msg, sizeof(msg) - 1);
        mrb->exc = (struct RObject*)mrb_object(exc);
        mrbb_raise(mrb, prev_jmp);
      }
      regs[1] = mrb_obj_value(mrb->ci->target_class);
      NEXT;
    }

  // ["OP_LAMBDA", 2, 0, 5]
  L_RB_MAIN_1:
  {
      /* A b c  R(A) := lambda(SEQ[b],c) (b:c = 14:2) */
      struct RProc *p;
      int c = 1;

      if (c & OP_L_CAPTURE) {
        p = mrbb_closure_new(mrb, met_a76556a4011695605d078c8391b1a2de, (unsigned int)1);
      }
      else {
        p = mrbb_proc_new(mrb, met_a76556a4011695605d078c8391b1a2de);
      }
      p->target_class = (mrb->ci) ? mrb->ci->target_class : 0;
      if (c & OP_L_STRICT) p->flags |= MRB_PROC_STRICT;
      regs[2] = mrb_obj_value(p);
      mrb->arena_idx = ai;
      NEXT;
    }

  // ["OP_METHOD", 1, 0, 0]
  L_RB_MAIN_2:
  {
      /* A B            R(A).newmethod(Sym(B),R(A+1)) */
      int a = 1;
      struct RClass *c = mrb_class_ptr(regs[a]);

      mrb_define_method_vm(mrb, c, mrb_intern(mrb, "met"), regs[a+1]);
      mrb->arena_idx = ai;
      NEXT;
    }

  // ["OP_LOADSELF", 1, 0, 0]
  L_RB_MAIN_3:
  {
      /* A      R(A) := self */
      regs[1] = regs[0];
      NEXT;
    }

  // ["OP_LOADI", 2, 256, 0]
  L_RB_MAIN_4:
  {
      /* A Bx   R(A) := sBx */
      SET_INT_VALUE(regs[2], 1);
      NEXT;
    }

  // ["OP_LOADI", 3, 256, 2]
  L_RB_MAIN_5:
  {
      /* A Bx   R(A) := sBx */
      SET_INT_VALUE(regs[3], 3);
      NEXT;
    }

  // ["OP_LAMBDA", 4, 0, 10]
  L_RB_MAIN_6:
  {
      /* A b c  R(A) := lambda(SEQ[b],c) (b:c = 14:2) */
      struct RProc *p;
      int c = 2;

      if (c & OP_L_CAPTURE) {
        p = mrbb_closure_new(mrb, met_f18972cd527e1d78bd37abb5cb6b081e, (unsigned int)1);
      }
      else {
        p = mrbb_proc_new(mrb, met_f18972cd527e1d78bd37abb5cb6b081e);
      }
      p->target_class = (mrb->ci) ? mrb->ci->target_class : 0;
      if (c & OP_L_STRICT) p->flags |= MRB_PROC_STRICT;
      regs[4] = mrb_obj_value(p);
      mrb->arena_idx = ai;
      NEXT;
    }

  // ["OP_SENDB", 1, 0, 2]
  L_RB_MAIN_7:
  {
      int a = 1;
      int n = 2;
      mrb_callinfo *prev_ci = mrb->ci;

      mrbb_send(mrb, mrb_intern(mrb, "met"), n, regs, a, 1);
      mrb->arena_idx = ai; // TODO probably can remove
      if (mrb->ci != prev_ci) { // special OP_RETURN (e.g. break)
        cipush(mrb);
        return regs[a];
      }
      NEXT;
  }

  // ["OP_STOP", 0, 0, 0]
  L_RB_MAIN_8:
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
