#include "kernel/types.h"
#include "user/user.h"

int main(void) {
  printf("I/O bound process starting...\n");
  int count = 0;
  while (1) {
    pause(1);  // Sleep for 1 tick
    count++;
    if (count % 10 == 0) {
      printf("I/O bound: slept %d times\n", count);
    }
  }
  exit(0);
}
