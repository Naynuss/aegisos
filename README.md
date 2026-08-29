AegisOS — Adaptive Scheduling for xv6-RISC-V
A workload-aware scheduling framework built by extending xv6-RISC-V. AegisOS monitors runtime process behavior and dynamically selects between Round Robin (RR) and Multi-Level Feedback Queue (MLFQ) while tuning the scheduling quantum.
Features
Process Telemetry — CPU time, wait time, sleep time, and context switches
Custom System Calls — get_process_stats(), get_system_stats(), set_scheduler(), set_quantum()
Dual Schedulers — Round Robin and MLFQ
Adaptive Engine — Workload-aware scheduler selection using heuristics
Dynamic Quantum — Runtime adjustment of scheduling quantum
Performance Evaluation — Controlled RR, MLFQ, and Adaptive benchmarks
Results
Scheduler
CPU Time
Wait Time
Context Switches
Sleep Time
RR
    200
      34
           569
      169
MLFQ
   152
     107
           480
      146
Adaptive
   138
     123
           468
      142

Compared with RR:
 31% reduction in measured CPU time
 17.75% reduction in context switches
 68 bytes/process telemetry overhead
🎥 Demo : 323_project_demonstration
https://drive.google.com/file/d/14BjQhNb5iOV5dvWNJ3euSK8BC6yTF9Mk/view?usp=sharing 
  
The demo covers telemetry, runtime scheduler control, adaptive scheduling, quantum tuning, and benchmark results.
Build & Run
Prerequisites
RISC-V GNU Toolchain
QEMU
GCC / Make
Build
make clean
make qemu TOOLPREFIX=riscv64-linux-gnu-

Example Commands
# Process telemetry
cpu_hog &
stats_test <pid>

# Scheduler control
scheduler_test mlfq
scheduler_test rr
scheduler_test quantum 5

# Adaptive engine
adaemon &
wload_cpu &
wload_cpu &

# Benchmark
perf_test

Tech Stack
C · xv6-RISC-V · RISC-V · QEMU · Round Robin · MLFQ
Author
Saniat Binte Gulzar 

