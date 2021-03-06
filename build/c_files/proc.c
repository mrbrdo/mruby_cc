#define MRB_PROC_MRBCFUNC 512
#define MRB_PROC_MRBCFUNC_P(p) ((p)->flags & MRB_PROC_MRBCFUNC)

extern struct RProc *interpreted_proc_call;

mrb_value mrbb_proc_call(mrb_state *mrb, mrb_value self)
{
  mrb_callinfo *ci;
  mrb_value recv = mrb->c->stack[0];
  struct RProc *m = mrb_proc_ptr(recv);
  int ai = mrb->arena_idx;
  ci = mrb->c->ci;

  // If interpreted Proc called from interpreted code
  if (mrb->c->ci->pc) {
#ifdef MRBB_COMPAT_INTERPRETER
    // See OP_SEND, we are migrating from MRB_PROC_CFUNC_P if body to else body
    mrb_irep *irep = interpreted_proc_call->body.irep;
    mrb_value *stackent = mrb->c->stack;
    if (ci->argc == -1) {
      stack_extend(mrb, (irep->nregs < 3) ? 3 : irep->nregs, 3);
    }
    else {
      stack_extend(mrb, irep->nregs,  ci->argc+2);
    }

    ci->proc = interpreted_proc_call;
    ci->nregs = irep->nregs;

    ci = cipush(mrb);
    ci->target_class = 0;
    ci->pc = irep->iseq;
    ci->stackent = stackent;

    return mrb->c->stack[0];
#else
    mrb->exc = mrb_obj_ptr(mrb_exc_new_str(mrb, E_RUNTIME_ERROR, mrb_str_new_cstr(mrb, "Attempt to call interpreter but MRBB_COMPAT_INTERPRETER is not enabled. (mrbb_proc_call)")));
    mrbb_raise(mrb);
#endif
  } else {
    /* replace callinfo */
    ci->target_class = m->target_class;
    ci->proc = m;
    if (m->env) {
      if (m->env->mid) {
        ci->mid = m->env->mid;
      }
      if (!m->env->stack) {
        m->env->stack = mrb->c->stack;
      }
    }

    /* prepare stack */
    if (MRB_PROC_CFUNC_P(m)) {
      recv = m->body.func(mrb, m->env->stack[0]);
      mrb->arena_idx = ai;
      //if (mrb->exc) mrbb_raise(mrb);
      /* pop stackpos */
      // already done by funcall
      //ci = mrb->c->ci;
      //mrb->c->stack = ci->stackent;
      //regs[ci->acc] = recv;
      //pc = ci->pc;
      //cipop(mrb);
    } else {
#ifdef MRBB_COMPAT_INTERPRETER
      mrb_irep *irep = m->body.irep;
      if (!irep) {
        mrb->c->stack[0] = mrb_nil_value();
        return mrb_nil_value();
      }
      ci->nregs = irep->nregs;
      if (ci->argc < 0) {
        stack_extend(mrb, (irep->nregs < 3) ? 3 : irep->nregs, 3);
      }
      else {
        stack_extend(mrb, irep->nregs,  ci->argc+2);
      }
      mrb->c->stack[0] = m->env->stack[0];
      recv = mrb_run(mrb, m, recv);
#else
      mrb->exc = mrb_obj_ptr(mrb_exc_new_str(mrb, E_RUNTIME_ERROR, mrb_str_new_cstr(mrb, "Attempt to call interpreter but MRBB_COMPAT_INTERPRETER is not enabled. (mrbb_proc_call)")));
      mrbb_raise(mrb);
#endif
    }
  }

  // TODO: only overwrite this method for Cfunc procs
  // so we let OP_CALL handle interpreted funcs
  return recv;
}

struct RProc *mrbb_proc_new(mrb_state* mrb, mrb_func_t cfunc)
{
  struct RProc *p = mrb_proc_new_cfunc(mrb, cfunc);

  p->flags |= MRB_PROC_MRBCFUNC;

  return p;
}

/* Soon:

struct RProc *mrbb_closure_new(mrb_state* mrb, mrb_func_t cfunc, unsigned int nlocals)
{
  struct RProc *p = mrb_closure_new_cfunc(mrb, cfunc);

  p->flags |= MRB_PROC_MRBCFUNC;

  return p;
}
*/
struct RProc *mrbb_closure_new(mrb_state* mrb, mrb_func_t cfunc, unsigned int nlocals)
{
  struct RProc *p = mrbb_proc_new(mrb, cfunc);

  // stolen from mrb_closure_new()
  struct REnv *e;

  if (!mrb->c->ci->env) {
    e = (struct REnv*)mrb_obj_alloc(mrb, MRB_TT_ENV, (struct RClass*)mrb->c->ci->proc->env);
    e->flags= nlocals;
    e->mid = mrb->c->ci->mid;
    e->cioff = mrb->c->ci - mrb->c->cibase;
    e->stack = mrb->c->stack;
    mrb->c->ci->env = e;
  }
  else {
    e = mrb->c->ci->env;
  }
  p->env = e;

  return p;
}
