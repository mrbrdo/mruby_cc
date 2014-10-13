/* Things from vm.c that I need */
/* Only things without modification from vm.c (identical) */
#define CALL_MAXARGS 127

#define ARENA_RESTORE(mrb,ai) (mrb)->arena_idx = (ai)

#define TYPES2(a,b) ((((uint16_t)(a))<<8)|(((uint16_t)(b))&0xff))
#define OP_MATH_BODY(op,v1,v2) do {\
  v1(regs[a]) = v1(regs[a]) op v2(regs[a+1]);\
} while(0)

#define OP_CMP_BODY(op,v1,v2) (v1(regs[a]) op v2(regs[a+1]))

#define STACK_INIT_SIZE 128
#define CALLINFO_INIT_SIZE 32

#define CI_ACC_SKIP    -1
#define CI_ACC_DIRECT  -2

static inline void
stack_copy(mrb_value *dst, const mrb_value *src, size_t size)
{
  while (size-- > 0) {
    *dst++ = *src++;
  }
}

static void
stack_init(mrb_state *mrb)
{
  struct mrb_context *c = mrb->c;

  /* mrb_assert(mrb->stack == NULL); */
  c->stbase = (mrb_value *)mrb_calloc(mrb, STACK_INIT_SIZE, sizeof(mrb_value));
  c->stend = c->stbase + STACK_INIT_SIZE;
  c->stack = c->stbase;

  /* mrb_assert(ci == NULL); */
  c->cibase = (mrb_callinfo *)mrb_calloc(mrb, CALLINFO_INIT_SIZE, sizeof(mrb_callinfo));
  c->ciend = c->cibase + CALLINFO_INIT_SIZE;
  c->ci = c->cibase;
  c->ci->target_class = mrb->object_class;
  c->ci->stackent = c->stack;
}

static void
argnum_error(mrb_state *mrb, mrb_int num)
{
  mrb_value exc;
  mrb_value str;

  if (mrb->c->ci->mid) {
    str = mrb_format(mrb, "'%S': wrong number of arguments (%S for %S)",
                  mrb_sym2str(mrb, mrb->c->ci->mid),
                  mrb_fixnum_value(mrb->c->ci->argc), mrb_fixnum_value(num));
  }
  else {
    str = mrb_format(mrb, "wrong number of arguments (%S for %S)",
                  mrb_fixnum_value(mrb->c->ci->argc), mrb_fixnum_value(num));
  }
  exc = mrb_exc_new_str(mrb, E_ARGUMENT_ERROR, str);
  mrb->exc = mrb_obj_ptr(exc);
}

static inline mrb_bool
is_strict(mrb_state *mrb, struct REnv *e)
{
  int cioff = e->cioff;

  if (MRB_ENV_STACK_SHARED_P(e) && mrb->c->cibase[cioff].proc &&
      MRB_PROC_STRICT_P(mrb->c->cibase[cioff].proc)) {
    return TRUE;
  }
  return FALSE;
}

static mrb_callinfo*
cipush(mrb_state *mrb)
{
  struct mrb_context *c = mrb->c;
  mrb_callinfo *ci = c->ci;

  int eidx = ci->eidx;
  int ridx = ci->ridx;

  if (ci + 1 == c->ciend) {
    size_t size = ci - c->cibase;

    c->cibase = (mrb_callinfo *)mrb_realloc(mrb, c->cibase, sizeof(mrb_callinfo)*size*2);
    c->ci = c->cibase + size;
    c->ciend = c->cibase + size * 2;
  }
  ci = ++c->ci;
  ci->eidx = eidx;
  ci->ridx = ridx;
  ci->env = 0;
  ci->pc = 0;
  ci->err = 0;
  ci->proc = 0;

  return ci;
}

static void
cipop(mrb_state *mrb)
{
  struct mrb_context *c = mrb->c;

  if (c->ci->env) {
    struct REnv *e = c->ci->env;
    size_t len = (size_t)MRB_ENV_STACK_LEN(e);
    mrb_value *p = (mrb_value *)mrb_malloc(mrb, sizeof(mrb_value)*len);

    MRB_ENV_UNSHARE_STACK(e);
    if (len > 0) {
      stack_copy(p, e->stack, len);
    }
    e->stack = p;
    mrb_write_barrier(mrb, (struct RBasic *)e);
  }

  c->ci--;
}

static void
envadjust(mrb_state *mrb, mrb_value *oldbase, mrb_value *newbase)
{
  mrb_callinfo *ci = mrb->c->cibase;

  if (newbase == oldbase) return;
  while (ci <= mrb->c->ci) {
    struct REnv *e = ci->env;
    if (e && MRB_ENV_STACK_SHARED_P(e)) {
      ptrdiff_t off = e->stack - oldbase;

      e->stack = newbase + off;
    }
    ci->stackent = newbase + (ci->stackent - oldbase);
    ci++;
  }
}

typedef enum {
  LOCALJUMP_ERROR_RETURN = 0,
  LOCALJUMP_ERROR_BREAK = 1,
  LOCALJUMP_ERROR_YIELD = 2
} localjump_error_kind;

static void
localjump_error(mrb_state *mrb, localjump_error_kind kind)
{
  char kind_str[3][7] = { "return", "break", "yield" };
  char kind_str_len[] = { 6, 5, 5 };
  static const char lead[] = "unexpected ";
  mrb_value msg;
  mrb_value exc;

  msg = mrb_str_buf_new(mrb, sizeof(lead) + 7);
  mrb_str_cat(mrb, msg, lead, sizeof(lead) - 1);
  mrb_str_cat(mrb, msg, kind_str[kind], kind_str_len[kind]);
  exc = mrb_exc_new_str(mrb, E_LOCALJUMP_ERROR, msg);
  mrb->exc = mrb_obj_ptr(exc);
}

static struct REnv*
uvenv(mrb_state *mrb, int up)
{
  struct REnv *e = mrb->c->ci->proc->env;

  while (up--) {
    if (!e) return NULL;
    e = (struct REnv*)e->c;
  }
  return e;
}

static struct REnv*
top_env(mrb_state *mrb, struct RProc *proc)
{
  struct REnv *e = proc->env;

  if (is_strict(mrb, e)) return e;
  while (e->c) {
    e = (struct REnv*)e->c;
    if (is_strict(mrb, e)) return e;
  }
  return e;
}

static inline void
stack_clear(mrb_value *from, size_t count)
{
#ifndef MRB_NAN_BOXING
  const mrb_value mrb_value_zero = { { 0 } };

  while (count-- > 0) {
    *from++ = mrb_value_zero;
  }
#else
  while (count-- > 0) {
    SET_NIL_VALUE(*from);
    from++;
  }
#endif
}

static void
init_new_stack_space(mrb_state *mrb, int room, int keep)
{
  if (room > keep) {
    /* do not leave uninitialized malloc region */
    stack_clear(&(mrb->c->stack[keep]), room - keep);
  }
}
