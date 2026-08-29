#include "kernel/types.h"
#include "user/user.h"

int main(void) {
  printf("CPU-bound workload starting...\n");
  volatile int i = 0;
  while (1) {
    i++;
    if (i % 100000000 == 0) {
      printf("CPU: %d iterations\n", i);
    }
  }
  exit(0);
}
