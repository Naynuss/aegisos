#include "kernel/types.h"
#include "user/user.h"

int main(void) {
  printf("CPU hog starting...\n");
  volatile int i = 0;
  while (1) {
    i++;
    if (i % 100000000 == 0) {
      printf("CPU hog: %d iterations\n", i);
    }
  }
  exit(0);
}
