
// from vm.c
static void
ecall(mrb_state *mrb, int i)
{
  struct RProc *p;
  mrb_callinfo *ci;
  mrb_value *self = mrb->c->stack;
  struct RObject *exc;

  p = mrb->c->ensure[i];
  ci = cipush(mrb);
  ci->stackent = mrb->c->stack;
  ci->mid = ci[-1].mid;
  ci->acc = -1;
  ci->argc = 0;
  ci->proc = p;
  ci->nregs = p->body.irep->nregs;
  ci->target_class = p->target_class;
  mrb->c->stack = mrb->c->stack + ci[-1].nregs;
  exc = mrb->exc; mrb->exc = 0;
  mrb_run(mrb, p, *self);
  if (!mrb->exc) mrb->exc = exc;
}

static void
mrbb_ecall(mrb_state *mrb, struct RProc *p)
{
  mrb_callinfo *ci;
  mrb_value *self = mrb->c->stack;
  struct RObject *exc;
  int ai = mrb->arena_idx;

  ci = cipush(mrb);
  ci->stackent = mrb->c->stack;
  ci->mid = ci[-1].mid;
  ci->acc = -1;
  ci->argc = 0;
  ci->proc = p;
  ci->target_class = p->target_class;
  mrb->c->stack = mrb->c->stack + ci[-1].nregs;
  exc = mrb->exc; mrb->exc = 0;
  p->body.func(mrb, *self);
  mrb->arena_idx = ai;
  mrb->c->stack = mrb->c->ci->stackent;
  cipop(mrb);
  if (!mrb->exc) mrb->exc = exc;
}

void mrbb_stop(mrb_state *mrb) {
  printf("goto L_STOP\n");
  exit(0);
}

/*
  Because c_jmp is a variable that is local to the scope of
  the OP_ONERR code part, it is necessary to copy it, because
  it may otherwise get overwritten. Specifically this happened
  on Linux, but not on OSX.
*/
static mrb_code c_rescue_code = MKOP_A(OP_STOP, 0);

void mrbb_rescue_push(mrb_state *mrb, struct mrb_jmpbuf *c_jmp) {
  struct mrb_jmpbuf *c_jmp_copy = (struct mrb_jmpbuf *)malloc(sizeof(struct mrb_jmpbuf));
  struct mrb_rescue_code *rescue_code = (struct mrb_rescue_code *)malloc(sizeof(*rescue_code));
  if (mrb->c->rsize <= mrb->c->ci->ridx) {
    if (mrb->c->rsize == 0) mrb->c->rsize = 16;
    else mrb->c->rsize *= 2;
    mrb->c->rescue = (mrb_code **)mrb_realloc(mrb, mrb->c->rescue, sizeof(mrb_code*) * mrb->c->rsize);
  }
  memmove(c_jmp_copy, c_jmp, sizeof(struct mrb_jmpbuf));
  rescue_code->code = &c_rescue_code; // TODO: At some point we want to make this an interpreted function that can call our c exception handler function
  rescue_code->jmp = c_jmp_copy;
  mrb->c->rescue[mrb->c->ci->ridx++] = (mrb_code *) rescue_code;
}

void mrbb_raise(mrb_state *mrb) {
  // stolen from OP_RETURN
  mrb_callinfo *ci;
  int eidx;
  ci = mrb->c->ci;
  eidx = ci->eidx;

  if (ci == mrb->c->cibase) {
    mrbb_stop(mrb);
  }
  while (eidx > ci[-1].eidx) {
    ecall(mrb, --eidx);
  }
  while (ci[0].ridx == ci[-1].ridx) {
    cipop(mrb);
    ci = mrb->c->ci;
    mrb->c->stack = ci[1].stackent;
    // TODO: we used mrb->jmp instead of prev_jmp
    if (ci[1].acc == CI_ACC_SKIP && mrb->jmp) {
      MRB_THROW(mrb->jmp);
    }
    if (ci > mrb->c->cibase) {
      while (eidx > ci[-1].eidx) {
        ecall(mrb, --eidx);
      }
    }
    else if (ci == mrb->c->cibase) {
      if (ci->ridx == 0) {
        if (mrb->c == mrb->root_c) {
          // TODO regs =
          mrb->c->stack = mrb->c->stbase;
          mrbb_stop(mrb);
        }
        else {
          struct mrb_context *c = mrb->c;

          mrb->c = c->prev;
          c->prev = NULL;
          mrbb_raise(mrb);
        }
      }
      break;
    }
  }

  // TODO does this even work? ridx 0 is probably entry point
  if (ci->ridx == 0) mrbb_stop(mrb);

  MRB_THROW(mrb->jmp);
 /* irep = ci->proc->body.irep;
  pool = irep->pool;
  syms = irep->syms;
  regs = mrb->c->stack = ci[1].stackent;
  pc = mrb->c->rescue[--ci->ridx];*/
}

int mrbb_is_c_rescue(mrb_code *entry) {
  if (entry == &c_rescue_code)
    return 1;
  else
    return 0;
}

/*
  Must free memory allocated for the mrb_jmpbuf.
*/

void mrbb_rescue_pop(mrb_state *mrb) {
  if (mrb->c->ci->ridx == 0) {
    mrb->exc = mrb_obj_ptr(mrb_exc_new_str(mrb, E_RUNTIME_ERROR, mrb_str_new_cstr(mrb, "mrbb_rescue_pop: reached end of rescue handlers")));
    mrbb_raise(mrb);
  }
  if (mrbb_is_c_rescue(mrb->c->rescue[mrb->c->ci->ridx-1])) {
    struct mrb_rescue_code *rescue_code = (struct mrb_rescue_code *) mrb->c->rescue[mrb->c->ci->ridx-1];
    mrb->c->ci->ridx--;
    free(rescue_code->jmp);
    free(rescue_code);
  } else
    mrb->c->ci->ridx--;
}
