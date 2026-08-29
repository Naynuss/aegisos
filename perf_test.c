#include "kernel/types.h"
#include "user/user.h"

#define DURATION 100  // Ticks to run each test
#define NUM_CPU 2     // Number of CPU hogs
#define NUM_IO 2      // Number of I/O bound processes
#define NUM_PROCS (NUM_CPU + NUM_IO)

struct test_result {
  char scheduler[16];
  int quantum;
  uint64 total_cpu_time;
  uint64 total_wait_time;
  uint64 total_context_switches;
  uint64 total_sleep_time;
  int processes_completed;
};

void run_cpu_workload(int duration, int write_fd) {
  volatile int i = 0;
  uint64 start = uptime();
  while (uptime() - start < duration) {
    for (int j = 0; j < 100000; j++) {
      i += j;
    }
  }

  // Grab our own final stats BEFORE we exit, since once we exit and
  // the parent calls wait(), freeproc() wipes this slot (pid->0,
  // state->UNUSED) and the data is gone for good.
  struct proc_stat ps;
  get_process_stats(getpid(), &ps);
  write(write_fd, &ps, sizeof(ps));
  close(write_fd);
  exit(0);
}

void run_io_workload(int duration, int write_fd) {
  uint64 start = uptime();
  int count = 0;
  while (uptime() - start < duration) {
    pause(2);
    count++;
  }

  struct proc_stat ps;
  get_process_stats(getpid(), &ps);
  write(write_fd, &ps, sizeof(ps));
  close(write_fd);
  exit(0);
}

void run_test(char *scheduler_name, int quantum, struct test_result *result) {
  int pids[NUM_PROCS];
  int pipefds[NUM_PROCS][2];
  int num_processes = 0;
  int status;

  printf("\n========================================\n");
  printf("Testing: %s (Quantum=%d)\n", scheduler_name, quantum);
  printf("========================================\n");

  // Set scheduler
  if (strcmp(scheduler_name, "RR") == 0) {
    set_scheduler(0);
  } else if (strcmp(scheduler_name, "MLFQ") == 0) {
    set_scheduler(1);
  } else {
    // Adaptive - don't change scheduler, let the daemon decide
  }
  if (quantum > 0) {
    set_quantum(quantum);
  }

  strcpy(result->scheduler, scheduler_name);
  result->quantum = quantum;
  result->total_cpu_time = 0;
  result->total_wait_time = 0;
  result->total_context_switches = 0;
  result->total_sleep_time = 0;
  result->processes_completed = 0;

  // Start CPU workloads
  for (int i = 0; i < NUM_CPU; i++) {
    pipe(pipefds[num_processes]);
    int pid = fork();
    if (pid == 0) {
      close(pipefds[num_processes][0]); // child: close read end
      run_cpu_workload(DURATION, pipefds[num_processes][1]);
      // run_cpu_workload calls exit(), never returns
    } else {
      close(pipefds[num_processes][1]); // parent: close write end
      pids[num_processes] = pid;
      num_processes++;
    }
  }

  // Start I/O workloads
  for (int i = 0; i < NUM_IO; i++) {
    pipe(pipefds[num_processes]);
    int pid = fork();
    if (pid == 0) {
      close(pipefds[num_processes][0]);
      run_io_workload(DURATION, pipefds[num_processes][1]);
    } else {
      close(pipefds[num_processes][1]);
      pids[num_processes] = pid;
      num_processes++;
    }
  }

  // Read each child's final stats over its pipe. The read() blocks
  // until that specific child writes and exits, so this naturally
  // waits for each workload to finish while still capturing its
  // numbers before the slot gets recycled.
  for (int i = 0; i < num_processes; i++) {
    struct proc_stat ps;
    int n = read(pipefds[i][0], &ps, sizeof(ps));
    close(pipefds[i][0]);

    if (n == sizeof(ps)) {
      result->total_cpu_time += ps.cpu_time;
      result->total_wait_time += ps.wait_time;
      result->total_context_switches += ps.context_switches;
      result->total_sleep_time += ps.sleep_time;
      result->processes_completed++;
    } else {
      printf("  WARNING: failed to read stats for pid %d\n", pids[i]);
    }
  }

  // Now that we have the data we need, reap the zombies.
  for (int i = 0; i < num_processes; i++) {
    wait(&status);
  }

  printf("  Completed: %d processes\n", result->processes_completed);
  printf("  Total CPU Time: %ld\n", result->total_cpu_time);
  printf("  Total Wait Time: %ld\n", result->total_wait_time);
  printf("  Total Context Switches: %ld\n", result->total_context_switches);
  printf("  Total Sleep Time: %ld\n", result->total_sleep_time);
}

int main(void) {
  struct test_result results[3];
  int num_tests = 0;

  printf("\n========================================\n");
  printf("AEGISOS PERFORMANCE BENCHMARK\n");
  printf("========================================\n");
  printf("Workload: %d CPU + %d I/O processes\n", NUM_CPU, NUM_IO);
  printf("Duration: %d ticks per test\n\n", DURATION);

  run_test("RR", 10, &results[num_tests++]);
  run_test("MLFQ", 10, &results[num_tests++]);

  printf("\nAssuming adaptive daemon is already running...\n");
  run_test("Adaptive", 0, &results[num_tests++]);

  printf("\n========================================\n");
  printf("PERFORMANCE COMPARISON\n");
  printf("========================================\n\n");
  printf("Scheduler      CPU Time    Wait Time   Switches    Sleep Time\n");
  printf("------------------------------------------------------------\n");

  for (int i = 0; i < num_tests; i++) {
    // Print scheduler name
    printf("%s", results[i].scheduler);
    
    // Print numbers with spaces for alignment
    printf("            %d", (int)results[i].total_cpu_time);
    printf("            %d", (int)results[i].total_wait_time);
    printf("            %d", (int)results[i].total_context_switches);
    printf("            %d\n", (int)results[i].total_sleep_time);
}   

  printf("\n========================================\n");
  printf("Benchmark complete!\n");
  printf("========================================\n");

  exit(0);
}
