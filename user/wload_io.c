#include "kernel/types.h"
#include "user/user.h"

int main(void) {
  printf("I/O-bound workload starting...\n");
  int count = 0;
  while (1) {
    pause(10);
    count++;
    if (count % 10 == 0) {
      printf("IO: slept %d times\n", count);
    }
  }
  exit(0);
}
