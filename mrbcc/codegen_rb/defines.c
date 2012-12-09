// my defines
#define NEXT

// copied defines

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

// removed first line from OP_CMP
#define OP_CMP(op) do {\
  /* need to check if - is overridden */\
  switch (TYPES2(mrb_type(regs[a]),mrb_type(regs[a+1]))) {\
  case TYPES2(MRB_TT_FIXNUM,MRB_TT_FIXNUM):\
    OP_CMP_BODY(op,attr_i,attr_i);\
    break;\
  case TYPES2(MRB_TT_FIXNUM,MRB_TT_FLOAT):\
    OP_CMP_BODY(op,attr_i,attr_f);\
    break;\
  case TYPES2(MRB_TT_FLOAT,MRB_TT_FIXNUM):\
    OP_CMP_BODY(op,attr_f,attr_i);\
    break;\
  case TYPES2(MRB_TT_FLOAT,MRB_TT_FLOAT):\
    OP_CMP_BODY(op,attr_f,attr_f);\
    break;\
  default:\
    goto L_SEND;\
  }\
} while (0)
