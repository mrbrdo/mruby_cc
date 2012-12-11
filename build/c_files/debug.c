#define dpf printf


void stackdump(mrb_state *mrb, int n)
{
  int i = 0;
  printf("Stackdump: \n");
  for (; i<n; i++) {
    printf("%d: ", i);
    mrb_p(mrb, mrb->stack[i]);
  }
}
