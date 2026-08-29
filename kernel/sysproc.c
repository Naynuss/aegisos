#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

// --- AegisOS: Scheduler control variables (from proc.c) ---
extern int scheduler_policy;
extern int time_quantum;

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if (t == SBRK_EAGER || n < 0) {
    if (growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
      return -1;
    if (addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    release(&tickslock);
    sleep();
    acquire(&tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.

uint64
sys_uptime(void)
{
  uint64 xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_get_process_stats(void)
{
  int pid;
  uint64 addr;
  struct proc *p;
  struct proc_stat ps;

  argint(0, &pid);     // Get PID from first argument
  argaddr(1, &addr);   // Get pointer from second argument

  printk("DEBUG: pid from argint = %d, addr from argaddr = %lx\n", pid, addr);
  printk("DEBUG: Looking for PID %d\n", pid);

  for (p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if (p->state != UNUSED) {
      printk("DEBUG: Found process: PID=%d, State=%d, Name=%s\n", p->pid, p->state, p->name);
    }
    if (p->pid == pid && p->state != UNUSED) {
      printk("DEBUG: Found target PID %d!\n", pid);
      ps.pid = p->pid;
      ps.state = p->state;
      safestrcpy(ps.name, p->name, sizeof(ps.name));
      
      ps.cpu_time = p->cpu_time;
      ps.wait_time = p->wait_time;
      ps.context_switches = p->context_switches;
      ps.last_run = p->last_run;
      ps.sleep_time = p->sleep_time;
      
      release(&p->lock);

      if (either_copyout(1, addr, &ps, sizeof(ps)) < 0) {
        printk("DEBUG: copyout failed!\n");
        return -1;
      }
      printk("DEBUG: copyout succeeded!\n");
      return 0;
    }
    release(&p->lock);
  }
  printk("DEBUG: PID %d not found!\n", pid);
  return -1;
}

// --- AegisOS: Scheduler Control System Calls ---

uint64
sys_set_scheduler(void)
{
  int policy;
  argint(0, &policy);
  
  if (policy != SCHED_RR && policy != SCHED_MLFQ) {
    return -1;  // Invalid policy
  }
  
  scheduler_policy = policy;
  printk("AegisOS: Scheduler switched to %s\n", 
         policy == SCHED_RR ? "Round Robin" : "MLFQ");
  
  return 0;
}

uint64
sys_set_quantum(void)
{
  int quantum;
  argint(0, &quantum);
  
  if (quantum < 1 || quantum > 100) {
    return -1;  // Invalid quantum
  }
  
  time_quantum = quantum;
  printk("AegisOS: Time quantum set to %d ticks\n", quantum);
  
  return 0;
}

uint64
sys_get_system_stats(void)
{
  uint64 addr;
  struct proc *p;
  struct system_stats ss;
  
  argaddr(0, &addr);
  
  memset(&ss, 0, sizeof(ss));
  
  uint64 total_cpu = 0;
  uint64 total_sleep = 0;
  uint64 total_wait = 0;
  uint64 total_switches = 0;
  int total = 0;
  int running = 0, sleeping = 0, runnable = 0;
  
  for (p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if (p->state != UNUSED) {
      total++;
      total_cpu += p->cpu_time;
      total_sleep += p->sleep_time;
      total_wait += p->wait_time;
      total_switches += p->context_switches;
      
      if (p->state == RUNNING) running++;
      else if (p->state == SLEEPING) sleeping++;
      else if (p->state == RUNNABLE) runnable++;
    }
    release(&p->lock);
  }
  
  ss.total_processes = total;
  ss.running_processes = running;
  ss.sleeping_processes = sleeping;
  ss.runnable_processes = runnable;
  ss.total_cpu_time = total_cpu;
  ss.total_sleep_time = total_sleep;
  ss.total_wait_time = total_wait;
  ss.total_context_switches = total_switches;
  
  // Calculate ratios (scaled by 1000 for integer precision)
  uint64 total_time = total_cpu + total_sleep + total_wait;
  if (total_time > 0) {
    ss.avg_cpu_ratio = (total_cpu * 1000) / total_time;
    ss.avg_sleep_ratio = (total_sleep * 1000) / total_time;
  } else {
    ss.avg_cpu_ratio = 0;
    ss.avg_sleep_ratio = 0;
  }
  
  if (either_copyout(1, addr, &ss, sizeof(ss)) < 0)
    return -1;
  
  return 0;
}
