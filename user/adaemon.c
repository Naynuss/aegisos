#include "kernel/types.h"
#include "user/user.h"

#define SAMPLE_INTERVAL 20  // Ticks between samples
#define SCORE_THRESHOLD 50  // Minimum score difference to switch

// Calculate RR score (higher = better)
// Favors: CPU-bound workloads, low context switch overhead
int calculate_rr_score(struct system_stats *ss) {
  int score = 50;  // Baseline
  
  // CPU-bound workloads do well with RR (fairness)
  if (ss->avg_cpu_ratio > 400) {  // > 40% CPU usage
    score += 20;
  }
  
  // Low sleep ratio means processes are CPU-bound
  if (ss->avg_sleep_ratio < 300) {  // < 30% sleep
    score += 15;
  }
  
  // Low context switches means RR is efficient
  if (ss->total_context_switches < 1000) {
    score += 10;
  }
  
  // Too many processes: RR is simpler
  if (ss->total_processes > 8) {
    score += 10;
  }
  
  return score;
}

// Calculate MLFQ score (higher = better)
// Favors: I/O-bound workloads, interactive processes
int calculate_mlfq_score(struct system_stats *ss) {
  int score = 50;  // Baseline
  
  // I/O-bound workloads benefit from MLFQ
  if (ss->avg_sleep_ratio > 400) {  // > 40% sleep
    score += 25;
  }
  
  // High CPU ratio but also high sleep means mixed workload
  if (ss->avg_cpu_ratio > 300 && ss->avg_sleep_ratio > 300) {
    score += 20;  // MLFQ handles mixed workloads well
  }
  
  // Many sleeping processes = I/O bound
  if (ss->sleeping_processes > ss->running_processes) {
    score += 15;
  }
  
  // High context switches: MLFQ can prioritize
  if (ss->total_context_switches > 2000) {
    score += 10;
  }
  
  return score;
}

// Determine optimal quantum based on workload
int calculate_optimal_quantum(struct system_stats *ss) {
  int quantum = 10;  // Default
  
  // CPU-bound: longer quantum (less overhead)
  if (ss->avg_cpu_ratio > 500) {  // > 50% CPU
    quantum = 20;
  }
  // Mixed: medium quantum
  else if (ss->avg_cpu_ratio > 300 && ss->avg_sleep_ratio > 300) {
    quantum = 10;
  }
  // I/O-bound: shorter quantum (faster response)
  else if (ss->avg_sleep_ratio > 500) {  // > 50% sleep
    quantum = 5;
  }
  
  // Many processes: smaller quantum for fairness
  if (ss->total_processes > 10) {
    quantum = quantum < 8 ? quantum : 8;
  }
  
  // Few processes: larger quantum
  if (ss->total_processes < 4) {
    quantum = quantum > 20 ? quantum : 20;
  }
  
  return quantum;
}

int main(void) {
  struct system_stats ss;
  int current_policy = 0;  // 0=RR, 1=MLFQ
  int rr_score, mlfq_score;
  int decision;
  int quantum;
  
  printf("AegisOS Adaptive Daemon starting...\n");
  printf("Monitoring system workload and optimizing scheduler...\n\n");
  
  while (1) {
    // Collect system stats
    if (get_system_stats(&ss) != 0) {
      printf("Failed to get system stats\n");
      pause(SAMPLE_INTERVAL);
      continue;
    }
    
    // Calculate scores
    rr_score = calculate_rr_score(&ss);
    mlfq_score = calculate_mlfq_score(&ss);
    
    // Log current state
    printf("========================================\n");
    printf("SYSTEM STATE:\n");
    printf("  Processes: %d (R:%d S:%d W:%d)\n", 
           ss.total_processes, ss.running_processes, 
           ss.sleeping_processes, ss.runnable_processes);
    printf("  CPU Ratio: %ld.%ld%%  Sleep Ratio: %ld.%ld%%\n",
           ss.avg_cpu_ratio / 10, ss.avg_cpu_ratio % 10,
           ss.avg_sleep_ratio / 10, ss.avg_sleep_ratio % 10);
    printf("  Context Switches: %ld\n", ss.total_context_switches);
    printf("\n");
    
    printf("SCORES:\n");
    printf("  RR:   %d\n", rr_score);
    printf("  MLFQ: %d\n", mlfq_score);
    
    // Make decision
    if (rr_score > mlfq_score + SCORE_THRESHOLD) {
      decision = 0;  // RR
    } else if (mlfq_score > rr_score + SCORE_THRESHOLD) {
      decision = 1;  // MLFQ
    } else {
      decision = current_policy;  // No change
    }
    
    quantum = calculate_optimal_quantum(&ss);
    
    // Apply decision if changed
    if (decision != current_policy) {
      if (set_scheduler(decision) == 0) {
        printf("\n  ▶ Switching to %s\n", 
               decision == 0 ? "Round Robin" : "MLFQ");
        current_policy = decision;
      }
    }
    
    // Apply quantum change
    set_quantum(quantum);
    printf("  ▶ Quantum: %d ticks\n", quantum);
    printf("========================================\n\n");
    
    pause(SAMPLE_INTERVAL);
  }
  
  exit(0);
}
