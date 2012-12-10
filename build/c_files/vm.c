/* Things from vm.c that I need */
/* Only things without modification from vm.c (identical) */
#define SET_TRUE_VALUE(r) MRB_SET_VALUE(r, MRB_TT_TRUE, value.i, 1)
#define SET_FALSE_VALUE(r) MRB_SET_VALUE(r, MRB_TT_FALSE, value.i, 1)
#define SET_NIL_VALUE(r) MRB_SET_VALUE(r, MRB_TT_FALSE, value.i, 0)
#define SET_INT_VALUE(r,n) MRB_SET_VALUE(r, MRB_TT_FIXNUM, value.i, (n))
#define SET_SYM_VALUE(r,v) MRB_SET_VALUE(r, MRB_TT_SYMBOL, value.sym, (v))
#define SET_OBJ_VALUE(r,v) MRB_SET_VALUE(r, (((struct RObject*)(v))->tt), value.p, (v))
#ifdef MRB_NAN_BOXING
#define SET_FLT_VALUE(r,v) r.f = (v)
#else
#define SET_FLT_VALUE(r,v) MRB_SET_VALUE(r, MRB_TT_FLOAT, value.f, (v))
#endif

#define CALL_MAXARGS 127

#define attr_i value.i
#ifdef MRB_NAN_BOXING
#define attr_f f
#else
#define attr_f value.f
#endif

#define TYPES2(a,b) (((((int)(a))<<8)|((int)(b)))&0xffff)
#define OP_MATH_BODY(op,v1,v2) do {\
  regs[a].v1 = regs[a].v1 op regs[a+1].v2;\
} while(0)

#define OP_CMP_BODY(op,v1,v2) do {\
  if (regs[a].v1 op regs[a+1].v2) {\
    SET_TRUE_VALUE(regs[a]);\
  }\
  else {\
    SET_FALSE_VALUE(regs[a]);\
  }\
} while(0)

#define STACK_INIT_SIZE 128
#define CALLINFO_INIT_SIZE 32

/* Define amount of linear stack growth. */
#ifndef MRB_STACK_GROWTH
#define MRB_STACK_GROWTH 128
#endif

/* Maximum stack depth. Should be set lower on memory constrained systems.
The value below allows about 60000 recursive calls in the simplest case. */
#ifndef MRB_STACK_MAX
#define MRB_STACK_MAX ((1<<18) - MRB_STACK_GROWTH)
#endif

static inline void
stack_copy(mrb_value *dst, const mrb_value *src, size_t size)
{
  int i;

  for (i = 0; i < size; i++) {
    dst[i] = src[i];
  }
}

static void
stack_init(mrb_state *mrb)
{
  /* assert(mrb->stack == NULL); */
  mrb->stbase = (mrb_value *)mrb_calloc(mrb, STACK_INIT_SIZE, sizeof(mrb_value));
  mrb->stend = mrb->stbase + STACK_INIT_SIZE;
  mrb->stack = mrb->stbase;

  /* assert(mrb->ci == NULL); */
  mrb->cibase = (mrb_callinfo *)mrb_calloc(mrb, CALLINFO_INIT_SIZE, sizeof(mrb_callinfo));
  mrb->ciend = mrb->cibase + CALLINFO_INIT_SIZE;
  mrb->ci = mrb->cibase;
  mrb->ci->target_class = mrb->object_class;
}

static void
argnum_error(mrb_state *mrb, int num)
{
  char buf[256];
  int len;
  mrb_value exc;

  if (mrb->ci->mid) {
    len = snprintf(buf, sizeof(buf), "'%s': wrong number of arguments (%d for %d)",
       mrb_sym2name(mrb, mrb->ci->mid),
       mrb->ci->argc, num);
  }
  else {
    len = snprintf(buf, sizeof(buf), "wrong number of arguments (%d for %d)",
       mrb->ci->argc, num);
  }
  exc = mrb_exc_new(mrb, E_ARGUMENT_ERROR, buf, len);
  mrb->exc = (struct RObject*)mrb_object(exc);
}

static inline int
is_strict(mrb_state *mrb, struct REnv *e)
{
  int cioff = e->cioff;

  if (cioff >= 0 && mrb->cibase[cioff].proc &&
      MRB_PROC_STRICT_P(mrb->cibase[cioff].proc)) {
    return 1;
  }
  return 0;
}

static mrb_callinfo*
cipush(mrb_state *mrb)
{
  int eidx = mrb->ci->eidx;
  int ridx = mrb->ci->ridx;

  if (mrb->ci + 1 == mrb->ciend) {
    size_t size = mrb->ci - mrb->cibase;

    mrb->cibase = (mrb_callinfo *)mrb_realloc(mrb, mrb->cibase, sizeof(mrb_callinfo)*size*2);
    mrb->ci = mrb->cibase + size;
    mrb->ciend = mrb->cibase + size * 2;
  }
  mrb->ci++;
  mrb->ci->nregs = 2;
  mrb->ci->eidx = eidx;
  mrb->ci->ridx = ridx;
  mrb->ci->env = 0;
  return mrb->ci;
}

static void
cipop(mrb_state *mrb)
{
  if (mrb->ci->env) {
    struct REnv *e = mrb->ci->env;
    int len = (int)e->flags;
    mrb_value *p = (mrb_value *)mrb_malloc(mrb, sizeof(mrb_value)*len);

    e->cioff = -1;
    stack_copy(p, e->stack, len);
    e->stack = p;
  }

  mrb->ci--;
}

static void
envadjust(mrb_state *mrb, mrb_value *oldbase, mrb_value *newbase)
{
  mrb_callinfo *ci = mrb->cibase;

  while (ci <= mrb->ci) {
    struct REnv *e = ci->env;
    if (e && e->cioff >= 0) {
      int off = e->stack - oldbase;

      e->stack = newbase + off;
    }
    ci++;
  }
}

static void
stack_extend(mrb_state *mrb, int room, int keep)
{
  int size, off;
  if (mrb->stack + room >= mrb->stend) {
    mrb_value *oldbase = mrb->stbase;

    size = mrb->stend - mrb->stbase;
    off = mrb->stack - mrb->stbase;

    /* Use linear stack growth.
       It is slightly slower than doubling thestack space,
       but it saves memory on small devices. */
    if (room <= size)
      size += MRB_STACK_GROWTH;
    else
      size += room;

    mrb->stbase = (mrb_value *)mrb_realloc(mrb, mrb->stbase, sizeof(mrb_value) * size);
    mrb->stack = mrb->stbase + off;
    mrb->stend = mrb->stbase + size;
    envadjust(mrb, oldbase, mrb->stbase);
    /* Raise an exception if the new stack size will be too large,
    to prevent infinite recursion. However, do this only after resizing the stack, so mrb_raisef has stack space to work with. */
    if(size > MRB_STACK_MAX) {
      mrb_raisef(mrb, E_RUNTIME_ERROR, "stack level too deep. (limit=%d)", MRB_STACK_MAX);
    }
  }

  if (room > keep) {
    int i;
    for (i=keep; i<room; i++) {
#ifndef MRB_NAN_BOXING
      static const mrb_value mrb_value_zero = { { 0 } };
      mrb->stack[i] = mrb_value_zero;
#else
      SET_NIL_VALUE(mrb->stack[i]);
#endif
    }
  }
}

static void
localjump_error(mrb_state *mrb, const char *kind)
{
  char buf[256];
  int len;
  mrb_value exc;

  len = snprintf(buf, sizeof(buf), "unexpected %s", kind);
  exc = mrb_exc_new(mrb, E_LOCALJUMP_ERROR, buf, len);
  mrb->exc = (struct RObject*)mrb_object(exc);
}

static mrb_value
uvget(mrb_state *mrb, int up, int idx)
{
  struct REnv *e = uvenv(mrb, up);

  if (!e) return mrb_nil_value();
  return e->stack[idx];
}

static void
uvset(mrb_state *mrb, int up, int idx, mrb_value v)
{
  struct REnv *e = uvenv(mrb, up);

  if (!e) return;
  e->stack[idx] = v;
  mrb_write_barrier(mrb, (struct RBasic*)e);
}
