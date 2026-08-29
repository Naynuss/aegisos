#define SBRK_ERROR ((char *)-1)

struct stat;

// system calls
int fork(void);
int exit(int) __attribute__((noreturn));
int wait(int *);
int pipe(int *);
int write(int, const void *, int);
int read(int, void *, int);
int close(int);
int kill(int);
int exec(const char *, char **);
int open(const char *, int);
int mknod(const char *, short, short);
int unlink(const char *);
int fstat(int fd, struct stat *);
int link(const char *, const char *);
int mkdir(const char *);
int chdir(const char *);
int dup(int);
int getpid(void);
char *sys_sbrk(int, int);
int pause(int);
int uptime(void);
int sync(void);
int set_scheduler(int policy);
int set_quantum(int quantum);

// ulib.c
int stat(const char *, struct stat *);
char *strcpy(char *, const char *);
void *memmove(void *, const void *, int);
char *strchr(const char *, char c);
int strcmp(const char *, const char *);
char *gets(char *, int max);
uint strlen(const char *);
void *memset(void *, int, uint);
int atoi(const char *);
int memcmp(const void *, const void *, uint);
void *memcpy(void *, const void *, uint);
char *sbrk(int);
char *sbrklazy(int);

// printf.c
void fprintf(int, const char *, ...) __attribute__((format(printf, 2, 3)));
void printf(const char *, ...) __attribute__((format(printf, 1, 2)));

// umalloc.c
void *malloc(uint);
void free(void *);

// --- AegisOS: Process Stats ---
struct proc_stat {
  int pid;
  int state;
  char name[16];
  uint64 cpu_time;
  uint64 wait_time;
  uint64 context_switches;
  uint64 last_run;
  uint64 sleep_time; 

};
int get_process_stats(int pid, struct proc_stat *ps);

// --- AegisOS: System Stats ---
struct system_stats {
  int total_processes;
  int running_processes;
  int sleeping_processes;
  int runnable_processes;
  uint64 total_cpu_time;
  uint64 total_sleep_time;
  uint64 total_wait_time;
  uint64 total_context_switches;
  uint64 avg_cpu_ratio;      // Scaled by 1000 for precision
  uint64 avg_sleep_ratio;    // Scaled by 1000 for precision
};

int get_system_stats(struct system_stats *ss);

// --- AegisOS: Scheduler Control ---
int set_scheduler(int policy);
int set_quantum(int quantum);
