/*  Test C function calling vs. goto to label
    Must have -O0
    Lesson: if we have local variables or parameters, the difference gets bigger
*/
#include <time.h>
#include <stdio.h>

void func() {
  return;
}

void evalfunc(int times) {
  int i;
  for (i = 0; i < times; i++) {
    func();
  }
}

void evalfastcall(int times) {
  int i = 0;
  goto L_LOOP;
  L_FUNC: {
    goto L_LOOP;
  }
  L_FILLER:
    i = 100;
  L_LOOP:
  while (i < times) {
    i++;
    goto L_FUNC;
  }
}

// with local variables and params (typical ruby method)
void func2(int param1, int param2) {
  int a = 5, b = 6;
  return;
}

void evalfunc2(int times) {
  int i;
  for (i = 0; i < times; i++) {
    func2(1,2);
  }
}

void evalfastcall2(int times) {
  int i = 0;
  goto L_LOOP;
  L_FUNC: { // no params needed, everything on stack or global mrb state
    int a = 5, b = 6;
    goto L_LOOP;
  }
  L_FILLER:
    i = 100;
  L_LOOP:
  while (i < times) {
    i++;
    goto L_FUNC;
  }
}

int main() {
  int times = 100000000;
  clock_t begin, end;
  double time_spent1, time_spent2;

  begin = clock();
  evalfunc(times);
  end = clock();
  time_spent1 = (double)(end - begin) / CLOCKS_PER_SEC;
  printf("func: %f\n", time_spent1);

  begin = clock();
  evalfastcall(times);
  end = clock();
  time_spent2 = (double)(end - begin) / CLOCKS_PER_SEC;
  printf("fastcall: %f\n", time_spent2);

  printf("percent: %i\n", (int) ((time_spent1 / time_spent2) * 100));

  begin = clock();
  evalfunc2(times);
  end = clock();
  time_spent1 = (double)(end - begin) / CLOCKS_PER_SEC;
  printf("func: %f\n", time_spent1);

  begin = clock();
  evalfastcall2(times);
  end = clock();
  time_spent2 = (double)(end - begin) / CLOCKS_PER_SEC;
  printf("fastcall: %f\n", time_spent2);

  printf("percent: %i\n", (int) ((time_spent1 / time_spent2) * 100));

  return 0;
}
