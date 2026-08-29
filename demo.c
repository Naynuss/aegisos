#include "kernel/types.h"
#include "user/user.h"

int main(void) {
  struct system_stats ss;
  
  printf("\n========================================\n");
  printf("AEGISOS FINAL DEMO\n");
  printf("Adaptive Resource Optimization Framework\n");
  printf("========================================\n\n");
  
  // Start the adaptive daemon if not already running
  printf("Starting adaptive engine...\n");
  // The daemon should already be running
  
  printf("\nCurrent System State:\n");
  printf("========================================\n");
  
  if (get_system_stats(&ss) == 0) {
    printf("Total Processes: %d\n", ss.total_processes);
    printf("Running: %d  Sleeping: %d  Runnable: %d\n",
           ss.running_processes, ss.sleeping_processes, ss.runnable_processes);
    printf("CPU Ratio: %ld.%ld%%\n", ss.avg_cpu_ratio / 10, ss.avg_cpu_ratio % 10);
    printf("Sleep Ratio: %ld.%ld%%\n", ss.avg_sleep_ratio / 10, ss.avg_sleep_ratio % 10);
    printf("Context Switches: %ld\n", ss.total_context_switches);
  }
  
  printf("\nStarting workloads...\n");
  printf("========================================\n");
  
  // Start CPU workload
  if (fork() == 0) {
    while (1) {
      volatile int i = 0;
      for (int j = 0; j < 1000000; j++) i += j;
    }
    exit(0);
  }
  
  // Start I/O workload
  if (fork() == 0) {
    int count = 0;
    while (1) {
      pause(5);
      count++;
    }
    exit(0);
  }
  
  printf("CPU workload and I/O workload running.\n");
  printf("Adaptive engine will optimize scheduling.\n");
  printf("\nPress Ctrl+P to see process list.\n");
  printf("========================================\n");
  
  // Monitor for a while
  for (int i = 0; i < 10; i++) {
    pause(10);
    if (get_system_stats(&ss) == 0) {
      printf("\n[Update %d]\n", i+1);
      printf("Processes: %d (R:%d S:%d W:%d)\n",
             ss.total_processes, ss.running_processes,
             ss.sleeping_processes, ss.runnable_processes);
      printf("Context Switches: %ld\n", ss.total_context_switches);
    }
  }
  
  printf("\n========================================\n");
  printf("Demo complete!\n");
  printf("========================================\n");
  
  exit(0);
}
