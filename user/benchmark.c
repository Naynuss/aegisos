#include "kernel/types.h"
#include "user/user.h"

#define BENCHMARK_DURATION 50  // Ticks to run each test

// Structure to store benchmark results
struct benchmark_result {
  char name[32];
  int scheduler;
  int quantum;
  uint64 cpu_time;
  uint64 wait_time;
  uint64 context_switches;
  uint64 sleep_time;
  int processes_completed;
};

void run_cpu_workload(int duration) {
  volatile int i = 0;
  uint64 start = uptime();
  while (uptime() - start < duration) {
    for (int j = 0; j < 100000; j++) {
      i += j;
    }
  }
}

void run_io_workload(int duration) {
  uint64 start = uptime();
  int count = 0;
  while (uptime() - start < duration) {
    pause(2);
    count++;
  }
}

void run_mixed_workload(int duration) {
  uint64 start = uptime();
  int count = 0;
  while (uptime() - start < duration) {
    // CPU burst
    volatile int i = 0;
    for (int j = 0; j < 50000; j++) {
      i += j;
    }
    // I/O burst
    pause(1);
    count++;
  }
}

void collect_stats(int pid, struct benchmark_result *result) {
  struct proc_stat ps;
  if (get_process_stats(pid, &ps) == 0) {
    result->cpu_time = ps.cpu_time;
    result->wait_time = ps.wait_time;
    result->context_switches = ps.context_switches;
    result->sleep_time = ps.sleep_time;
  }
}

int main(int argc, char *argv[]) {
  struct benchmark_result results[10];
  int num_tests = 0;
  int pid;
  
  printf("========================================\n");
  printf("AEGISOS BENCHMARK SUITE\n");
  printf("========================================\n\n");
  
  // Test 1: Round Robin with quantum 10
  printf("Test 1: Round Robin (Quantum=10)\n");
  set_scheduler(0);
  set_quantum(10);
  
  pid = fork();
  if (pid == 0) {
    run_cpu_workload(BENCHMARK_DURATION);
    exit(0);
  } else {
    wait(0);
    collect_stats(pid, &results[num_tests]);
    strcpy(results[num_tests].name, "RR-10");
    results[num_tests].scheduler = 0;
    results[num_tests].quantum = 10;
    num_tests++;
  }
  
  // Test 2: MLFQ with quantum 10
  printf("Test 2: MLFQ (Quantum=10)\n");
  set_scheduler(1);
  set_quantum(10);
  
  pid = fork();
  if (pid == 0) {
    run_cpu_workload(BENCHMARK_DURATION);
    exit(0);
  } else {
    wait(0);
    collect_stats(pid, &results[num_tests]);
    strcpy(results[num_tests].name, "MLFQ-10");
    results[num_tests].scheduler = 1;
    results[num_tests].quantum = 10;
    num_tests++;
  }
  
  // Test 3: Round Robin with quantum 5
  printf("Test 3: Round Robin (Quantum=5)\n");
  set_scheduler(0);
  set_quantum(5);
  
  pid = fork();
  if (pid == 0) {
    run_cpu_workload(BENCHMARK_DURATION);
    exit(0);
  } else {
    wait(0);
    collect_stats(pid, &results[num_tests]);
    strcpy(results[num_tests].name, "RR-5");
    results[num_tests].scheduler = 0;
    results[num_tests].quantum = 5;
    num_tests++;
  }
  
  // Test 4: MLFQ with quantum 5
  printf("Test 4: MLFQ (Quantum=5)\n");
  set_scheduler(1);
  set_quantum(5);
  
  pid = fork();
  if (pid == 0) {
    run_cpu_workload(BENCHMARK_DURATION);
    exit(0);
  } else {
    wait(0);
    collect_stats(pid, &results[num_tests]);
    strcpy(results[num_tests].name, "MLFQ-5");
    results[num_tests].scheduler = 1;
    results[num_tests].quantum = 5;
    num_tests++;
  }
  
  // Test 5: Round Robin with quantum 20
  printf("Test 5: Round Robin (Quantum=20)\n");
  set_scheduler(0);
  set_quantum(20);
  
  pid = fork();
  if (pid == 0) {
    run_cpu_workload(BENCHMARK_DURATION);
    exit(0);
  } else {
    wait(0);
    collect_stats(pid, &results[num_tests]);
    strcpy(results[num_tests].name, "RR-20");
    results[num_tests].scheduler = 0;
    results[num_tests].quantum = 20;
    num_tests++;
  }
  
  // Test 6: Adaptive (Current scheduler)
  printf("Test 6: Adaptive\n");
  // The daemon is running, so use current policy
  
  pid = fork();
  if (pid == 0) {
    run_cpu_workload(BENCHMARK_DURATION);
    exit(0);
  } else {
    wait(0);
    collect_stats(pid, &results[num_tests]);
    strcpy(results[num_tests].name, "Adaptive");
    results[num_tests].scheduler = -1;  // Adaptive
    results[num_tests].quantum = 0;     // Variable
    num_tests++;
  }
  
  // Print results table
  printf("\n========================================\n");
  printf("BENCHMARK RESULTS\n");
  printf("========================================\n\n");
  printf("%-12s %-10s %-10s %-10s %-10s\n", 
         "Scheduler", "CPU Time", "Wait Time", "Switches", "Sleep Time");
  printf("----------------------------------------\n");
  
  for (int i = 0; i < num_tests; i++) {
    printf("%-12s %-10ld %-10ld %-10ld %-10ld\n",
           results[i].name,
           results[i].cpu_time,
           results[i].wait_time,
           results[i].context_switches,
           results[i].sleep_time);
  }
  
  printf("\n========================================\n");
  printf("Benchmark complete!\n");
  
  exit(0);
}
