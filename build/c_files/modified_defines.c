#define NEXT

// removed first line from OP_CMP, also goto L_SEND in default (TODO)
#define OP_CMP(op) do {\
 int result, skip = 0;\
 /* need to check if - is overridden */\
 switch (TYPES2(mrb_type(regs[a]),mrb_type(regs[a+1]))) {\
 case TYPES2(MRB_TT_FIXNUM,MRB_TT_FIXNUM):\
   result = OP_CMP_BODY(op,mrb_fixnum,mrb_fixnum);\
   break;\
 case TYPES2(MRB_TT_FIXNUM,MRB_TT_FLOAT):\
   result = OP_CMP_BODY(op,mrb_fixnum,mrb_float);\
   break;\
 case TYPES2(MRB_TT_FLOAT,MRB_TT_FIXNUM):\
   result = OP_CMP_BODY(op,mrb_float,mrb_fixnum);\
   break;\
 case TYPES2(MRB_TT_FLOAT,MRB_TT_FLOAT):\
   result = OP_CMP_BODY(op,mrb_float,mrb_float);\
   break;\
 default:\
   mrbb_send(mrb, mrb_intern_cstr(mrb, #op ), 1, &regs, a, 0);\
   skip = 1;\
 }\
 if (!skip) {\
    if (result) {\
      SET_TRUE_VALUE(regs[a]);\
    }\
    else {\
      SET_FALSE_VALUE(regs[a]);\
    }\
 }\
} while(0)
