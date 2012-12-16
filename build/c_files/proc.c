#define MRB_PROC_MRBCFUNC 512
#define MRB_PROC_MRBCFUNC_P(p) ((p)->flags & MRB_PROC_MRBCFUNC)

mrb_value mrbb_proc_call(mrb_state *mrb, mrb_value self)
{
  mrb_callinfo *ci;
  mrb_value recv = mrb->stack[0];
  struct RProc *m = mrb_proc_ptr(recv);
  int ai = mrb->arena_idx;

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
    recv = m->body.func(mrb, m->env->stack[0]);
    mrb->arena_idx = ai;
    if (mrb->exc) mrbb_raise(mrb);
    /* pop stackpos */
    // already done by funcall
//ci = mrb->ci;
    //mrb->stack = mrb->stbase + ci->stackidx;
//regs[ci->acc] = recv;
//pc = ci->pc;
    //cipop(mrb);
  } else {
    mrb_irep *irep = m->body.irep;
    if (!irep) {
      mrb->stack[0] = mrb_nil_value();
      return mrb_nil_value();
    }
    ci->nregs = irep->nregs;
    if (ci->argc < 0) {
      stack_extend(mrb, (irep->nregs < 3) ? 3 : irep->nregs, 3);
    }
    else {
      stack_extend(mrb, irep->nregs,  ci->argc+2);
    }
    mrb->stack[0] = m->env->stack[0];
    recv = mrb_run(mrb, m, recv);
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

  if (!mrb->ci->env) {
    e = (struct REnv*)mrb_obj_alloc(mrb, MRB_TT_ENV, (struct RClass*)mrb->ci->proc->env);
    e->flags= nlocals;
    e->mid = mrb->ci->mid;
    e->cioff = mrb->ci - mrb->cibase;
    e->stack = mrb->stack;
    mrb->ci->env = e;
  }
  else {
    e = mrb->ci->env;
  }
  p->env = e;

  return p;
}
