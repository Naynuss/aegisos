#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Usage:\n");
    printf("  scheduler_test rr        - Switch to Round Robin\n");
    printf("  scheduler_test mlfq      - Switch to MLFQ\n");
    printf("  scheduler_test quantum N - Set quantum to N ticks\n");
    exit(1);
  }
  
  if (strcmp(argv[1], "rr") == 0) {
    if (set_scheduler(0) == 0) {
      printf("Switched to Round Robin scheduler\n");
    } else {
      printf("Failed to switch scheduler\n");
    }
  } else if (strcmp(argv[1], "mlfq") == 0) {
    if (set_scheduler(1) == 0) {
      printf("Switched to MLFQ scheduler\n");
    } else {
      printf("Failed to switch scheduler\n");
    }
  } else if (strcmp(argv[1], "quantum") == 0 && argc > 2) {
    int q = atoi(argv[2]);
    if (set_quantum(q) == 0) {
      printf("Quantum set to %d ticks\n", q);
    } else {
      printf("Failed to set quantum\n");
    }
  } else {
    printf("Unknown command\n");
  }
  
  exit(0);
}
