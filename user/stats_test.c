#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  int pid;
  struct proc_stat ps;

  if (argc > 1) {
    pid = atoi(argv[1]);      // Use the PID passed as argument
  } else {
    pid = getpid();           // Default: query self
  }

  if (get_process_stats(pid, &ps) == 0) {
    printf("Process ID: %d\n", ps.pid);
    printf("State: %d\n", ps.state);
    printf("Name: %s\n", ps.name);
    printf("CPU Time: %ld\n", ps.cpu_time);
    printf("Wait Time: %ld\n", ps.wait_time);
    printf("Context Switches: %ld\n", ps.context_switches);
    printf("Sleep Time: %ld\n", ps.sleep_time);
    printf("SUCCESS: Full syscall works!\n");
  } else {
    printf("FAIL: Could not get process stats for PID %d\n", pid);
  }

  exit(0);
}
