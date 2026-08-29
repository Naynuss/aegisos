#include "kernel/types.h"
#include "user/user.h"

int main(void) {
  printf("Mixed workload starting...\n");
  int count = 0;
  while (1) {
    // CPU burst
    volatile int i = 0;
    for (int j = 0; j < 100000; j++) {
      i += j;
    }
    // I/O burst
    pause(5);
    count++;
    if (count % 20 == 0) {
      printf("Mixed: %d cycles\n", count);
    }
  }
  exit(0);
}
