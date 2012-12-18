#include <stdio.h>
#include <time.h>

void *pc;
int stack[15];
int test_times = 1000000;

void start(int label_idx);

int func1(int val1, int val2) {
  pc = 0;
  start(2);
  return stack[0];
}

void start(int label_idx) {
  static void *ptrs[] = { &&L_MAIN, (void *) func1, &&L_FUNC1 };
  int i;

  goto *ptrs[label_idx];

  L_MAIN:
  printf("start: %lu, %lu\n", start, ptrs[0]);
  for (i = 0; i < test_times; i++) {
    pc = &&L_MAIN2;
    goto L_FUNC1;
    L_MAIN2: {}
  }
  return;

  L_FUNC1:
  stack[0] = 15;
  if (pc)
    goto *pc;
  else
    return;
}

int main() {
  clock_t begin, end;
  double time_spent1, time_spent2;
  int i;

  begin = clock();
  start(0);
  end = clock();
  time_spent1 = (double)(end - begin) / CLOCKS_PER_SEC;
  printf("faster: %f\n", time_spent1);

  begin = clock();
  for (i=0; i<test_times; i++)
    func1(1, 2);
  end = clock();
  time_spent2 = (double)(end - begin) / CLOCKS_PER_SEC;
  printf("slower: %f\n", time_spent2);

  printf("percent: %i\n", (int) ((time_spent1 / time_spent2) * 100));

  return 0;
}
