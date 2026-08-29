
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	53813103          	ld	sp,1336(sp) # 8000b538 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	03e000ef          	jal	80000054 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000022:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000026:	577d                	li	a4,-1
    80000028:	177e                	slli	a4,a4,0x3f
    8000002a:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002c:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000030:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    80000038:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003c:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000040:	000f4737          	lui	a4,0xf4
    80000044:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000048:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004a:	14d79073          	csrw	stimecmp,a5
}
    8000004e:	6422                	ld	s0,8(sp)
    80000050:	0141                	addi	sp,sp,16
    80000052:	8082                	ret

0000000080000054 <start>:
{
    80000054:	1141                	addi	sp,sp,-16
    80000056:	e406                	sd	ra,8(sp)
    80000058:	e022                	sd	s0,0(sp)
    8000005a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    8000005c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000060:	7779                	lui	a4,0xffffe
    80000062:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd8d4f>
    80000066:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000068:	6705                	lui	a4,0x1
    8000006a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000006e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000074:	00001797          	auipc	a5,0x1
    80000078:	d7a78793          	addi	a5,a5,-646 # 80000dee <main>
    8000007c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000080:	4781                	li	a5,0
    80000082:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    80000086:	67c1                	lui	a5,0x10
    80000088:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    8000008e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000092:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80000096:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009a:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    8000009e:	57fd                	li	a5,-1
    800000a0:	83a9                	srli	a5,a5,0xa
    800000a2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000a6:	47bd                	li	a5,15
    800000a8:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000ac:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b0:	4705                	li	a4,1
    800000b2:	1776                	slli	a4,a4,0x3d
    800000b4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000b6:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000ba:	f63ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000be:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c2:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c6:	30200073          	mret
}
    800000ca:	60a2                	ld	ra,8(sp)
    800000cc:	6402                	ld	s0,0(sp)
    800000ce:	0141                	addi	sp,sp,16
    800000d0:	8082                	ret

00000000800000d2 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d2:	7119                	addi	sp,sp,-128
    800000d4:	fc86                	sd	ra,120(sp)
    800000d6:	f8a2                	sd	s0,112(sp)
    800000d8:	f4a6                	sd	s1,104(sp)
    800000da:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000dc:	06c05a63          	blez	a2,80000150 <consolewrite+0x7e>
    800000e0:	f0ca                	sd	s2,96(sp)
    800000e2:	ecce                	sd	s3,88(sp)
    800000e4:	e8d2                	sd	s4,80(sp)
    800000e6:	e4d6                	sd	s5,72(sp)
    800000e8:	e0da                	sd	s6,64(sp)
    800000ea:	fc5e                	sd	s7,56(sp)
    800000ec:	f862                	sd	s8,48(sp)
    800000ee:	f466                	sd	s9,40(sp)
    800000f0:	8aaa                	mv	s5,a0
    800000f2:	8b2e                	mv	s6,a1
    800000f4:	8a32                	mv	s4,a2
  int i = 0;
    800000f6:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000f8:	02000c13          	li	s8,32
    800000fc:	02000c93          	li	s9,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000100:	5bfd                	li	s7,-1
    80000102:	a035                	j	8000012e <consolewrite+0x5c>
    if (nn > n - i)
    80000104:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000108:	86ce                	mv	a3,s3
    8000010a:	01648633          	add	a2,s1,s6
    8000010e:	85d6                	mv	a1,s5
    80000110:	f8040513          	addi	a0,s0,-128
    80000114:	304020ef          	jal	80002418 <either_copyin>
    80000118:	03750e63          	beq	a0,s7,80000154 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011c:	85ce                	mv	a1,s3
    8000011e:	f8040513          	addi	a0,s0,-128
    80000122:	786000ef          	jal	800008a8 <uartwrite>
    i += nn;
    80000126:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    8000012a:	0144da63          	bge	s1,s4,8000013e <consolewrite+0x6c>
    if (nn > n - i)
    8000012e:	409a093b          	subw	s2,s4,s1
    80000132:	0009079b          	sext.w	a5,s2
    80000136:	fcfc57e3          	bge	s8,a5,80000104 <consolewrite+0x32>
    8000013a:	8966                	mv	s2,s9
    8000013c:	b7e1                	j	80000104 <consolewrite+0x32>
    8000013e:	7906                	ld	s2,96(sp)
    80000140:	69e6                	ld	s3,88(sp)
    80000142:	6a46                	ld	s4,80(sp)
    80000144:	6aa6                	ld	s5,72(sp)
    80000146:	6b06                	ld	s6,64(sp)
    80000148:	7be2                	ld	s7,56(sp)
    8000014a:	7c42                	ld	s8,48(sp)
    8000014c:	7ca2                	ld	s9,40(sp)
    8000014e:	a819                	j	80000164 <consolewrite+0x92>
  int i = 0;
    80000150:	4481                	li	s1,0
    80000152:	a809                	j	80000164 <consolewrite+0x92>
    80000154:	7906                	ld	s2,96(sp)
    80000156:	69e6                	ld	s3,88(sp)
    80000158:	6a46                	ld	s4,80(sp)
    8000015a:	6aa6                	ld	s5,72(sp)
    8000015c:	6b06                	ld	s6,64(sp)
    8000015e:	7be2                	ld	s7,56(sp)
    80000160:	7c42                	ld	s8,48(sp)
    80000162:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000164:	8526                	mv	a0,s1
    80000166:	70e6                	ld	ra,120(sp)
    80000168:	7446                	ld	s0,112(sp)
    8000016a:	74a6                	ld	s1,104(sp)
    8000016c:	6109                	addi	sp,sp,128
    8000016e:	8082                	ret

0000000080000170 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	711d                	addi	sp,sp,-96
    80000172:	ec86                	sd	ra,88(sp)
    80000174:	e8a2                	sd	s0,80(sp)
    80000176:	e4a6                	sd	s1,72(sp)
    80000178:	e0ca                	sd	s2,64(sp)
    8000017a:	fc4e                	sd	s3,56(sp)
    8000017c:	f852                	sd	s4,48(sp)
    8000017e:	f456                	sd	s5,40(sp)
    80000180:	f05a                	sd	s6,32(sp)
    80000182:	1080                	addi	s0,sp,96
    80000184:	8aaa                	mv	s5,a0
    80000186:	8a2e                	mv	s4,a1
    80000188:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000018a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018e:	00013517          	auipc	a0,0x13
    80000192:	40250513          	addi	a0,a0,1026 # 80013590 <cons>
    80000196:	1fb000ef          	jal	80000b90 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    8000019a:	00013497          	auipc	s1,0x13
    8000019e:	3f648493          	addi	s1,s1,1014 # 80013590 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a2:	00013917          	auipc	s2,0x13
    800001a6:	48690913          	addi	s2,s2,1158 # 80013628 <cons+0x98>
  while (n > 0) {
    800001aa:	0d305463          	blez	s3,80000272 <consoleread+0x102>
    while (cons.r == cons.w) {
    800001ae:	0984a783          	lw	a5,152(s1)
    800001b2:	09c4a703          	lw	a4,156(s1)
    800001b6:	0af71963          	bne	a4,a5,80000268 <consoleread+0xf8>
      if (killed(myproc())) {
    800001ba:	6e8010ef          	jal	800018a2 <myproc>
    800001be:	0d4020ef          	jal	80002292 <killed>
    800001c2:	e925                	bnez	a0,80000232 <consoleread+0xc2>
      sleep_prepare(&cons.r);
    800001c4:	854a                	mv	a0,s2
    800001c6:	647010ef          	jal	8000200c <sleep_prepare>
      release(&cons.lock);
    800001ca:	8526                	mv	a0,s1
    800001cc:	251000ef          	jal	80000c1c <release>
      sleep();
    800001d0:	679010ef          	jal	80002048 <sleep>
      acquire(&cons.lock);
    800001d4:	8526                	mv	a0,s1
    800001d6:	1bb000ef          	jal	80000b90 <acquire>
    while (cons.r == cons.w) {
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70ce3          	beq	a4,a5,800001ba <consoleread+0x4a>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	3a870713          	addi	a4,a4,936 # 80013590 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if (c == C('D')) { // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8663          	beq	s7,a3,80000254 <consoleread+0xe4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	1b2020ef          	jal	800023cc <either_copyout>
    8000021e:	57fd                	li	a5,-1
    80000220:	04f50863          	beq	a0,a5,80000270 <consoleread+0x100>
      break;

    dst++;
    80000224:	0a05                	addi	s4,s4,1
    --n;
    80000226:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    80000228:	47a9                	li	a5,10
    8000022a:	04fb8d63          	beq	s7,a5,80000284 <consoleread+0x114>
    8000022e:	6be2                	ld	s7,24(sp)
    80000230:	bfad                	j	800001aa <consoleread+0x3a>
        release(&cons.lock);
    80000232:	00013517          	auipc	a0,0x13
    80000236:	35e50513          	addi	a0,a0,862 # 80013590 <cons>
    8000023a:	1e3000ef          	jal	80000c1c <release>
        return -1;
    8000023e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000240:	60e6                	ld	ra,88(sp)
    80000242:	6446                	ld	s0,80(sp)
    80000244:	64a6                	ld	s1,72(sp)
    80000246:	6906                	ld	s2,64(sp)
    80000248:	79e2                	ld	s3,56(sp)
    8000024a:	7a42                	ld	s4,48(sp)
    8000024c:	7aa2                	ld	s5,40(sp)
    8000024e:	7b02                	ld	s6,32(sp)
    80000250:	6125                	addi	sp,sp,96
    80000252:	8082                	ret
      if (n < target) {
    80000254:	0009871b          	sext.w	a4,s3
    80000258:	01677a63          	bgeu	a4,s6,8000026c <consoleread+0xfc>
        cons.r--;
    8000025c:	00013717          	auipc	a4,0x13
    80000260:	3cf72623          	sw	a5,972(a4) # 80013628 <cons+0x98>
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	a031                	j	80000272 <consoleread+0x102>
    80000268:	ec5e                	sd	s7,24(sp)
    8000026a:	bfbd                	j	800001e8 <consoleread+0x78>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a011                	j	80000272 <consoleread+0x102>
    80000270:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000272:	00013517          	auipc	a0,0x13
    80000276:	31e50513          	addi	a0,a0,798 # 80013590 <cons>
    8000027a:	1a3000ef          	jal	80000c1c <release>
  return target - n;
    8000027e:	413b053b          	subw	a0,s6,s3
    80000282:	bf7d                	j	80000240 <consoleread+0xd0>
    80000284:	6be2                	ld	s7,24(sp)
    80000286:	b7f5                	j	80000272 <consoleread+0x102>

0000000080000288 <consputc>:
{
    80000288:	1141                	addi	sp,sp,-16
    8000028a:	e406                	sd	ra,8(sp)
    8000028c:	e022                	sd	s0,0(sp)
    8000028e:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000290:	10000793          	li	a5,256
    80000294:	00f50863          	beq	a0,a5,800002a4 <consputc+0x1c>
    uartputc_sync(c);
    80000298:	696000ef          	jal	8000092e <uartputc_sync>
}
    8000029c:	60a2                	ld	ra,8(sp)
    8000029e:	6402                	ld	s0,0(sp)
    800002a0:	0141                	addi	sp,sp,16
    800002a2:	8082                	ret
    uartputc_sync('\b');
    800002a4:	4521                	li	a0,8
    800002a6:	688000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync(' ');
    800002aa:	02000513          	li	a0,32
    800002ae:	680000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	67a000ef          	jal	8000092e <uartputc_sync>
    800002b8:	b7d5                	j	8000029c <consputc+0x14>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00013517          	auipc	a0,0x13
    800002ca:	2ca50513          	addi	a0,a0,714 # 80013590 <cons>
    800002ce:	0c3000ef          	jal	80000b90 <acquire>

  switch (c) {
    800002d2:	47d5                	li	a5,21
    800002d4:	08f48f63          	beq	s1,a5,80000372 <consoleintr+0xb8>
    800002d8:	0297c563          	blt	a5,s1,80000302 <consoleintr+0x48>
    800002dc:	47a1                	li	a5,8
    800002de:	0ef48463          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    800002e2:	47c1                	li	a5,16
    800002e4:	10f49563          	bne	s1,a5,800003ee <consoleintr+0x134>
  case C('P'): // Print process list.
    procdump();
    800002e8:	17c020ef          	jal	80002464 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ec:	00013517          	auipc	a0,0x13
    800002f0:	2a450513          	addi	a0,a0,676 # 80013590 <cons>
    800002f4:	129000ef          	jal	80000c1c <release>
}
    800002f8:	60e2                	ld	ra,24(sp)
    800002fa:	6442                	ld	s0,16(sp)
    800002fc:	64a2                	ld	s1,8(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch (c) {
    80000302:	07f00793          	li	a5,127
    80000306:	0cf48063          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030a:	00013717          	auipc	a4,0x13
    8000030e:	28670713          	addi	a4,a4,646 # 80013590 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf766e3          	bltu	a4,a5,800002ec <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x13a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	f5dff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000330:	00013797          	auipc	a5,0x13
    80000334:	26078793          	addi	a5,a5,608 # 80013590 <cons>
    80000338:	0a07a683          	lw	a3,160(a5)
    8000033c:	0016871b          	addiw	a4,a3,1
    80000340:	0007061b          	sext.w	a2,a4
    80000344:	0ae7a023          	sw	a4,160(a5)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	97b6                	add	a5,a5,a3
    8000034e:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	47a9                	li	a5,10
    80000354:	0cf48563          	beq	s1,a5,8000041e <consoleintr+0x164>
    80000358:	4791                	li	a5,4
    8000035a:	0cf48263          	beq	s1,a5,8000041e <consoleintr+0x164>
    8000035e:	00013797          	auipc	a5,0x13
    80000362:	2ca7a783          	lw	a5,714(a5) # 80013628 <cons+0x98>
    80000366:	9f1d                	subw	a4,a4,a5
    80000368:	08000793          	li	a5,128
    8000036c:	f8f710e3          	bne	a4,a5,800002ec <consoleintr+0x32>
    80000370:	a07d                	j	8000041e <consoleintr+0x164>
    80000372:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000374:	00013717          	auipc	a4,0x13
    80000378:	21c70713          	addi	a4,a4,540 # 80013590 <cons>
    8000037c:	0a072783          	lw	a5,160(a4)
    80000380:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000384:	00013497          	auipc	s1,0x13
    80000388:	20c48493          	addi	s1,s1,524 # 80013590 <cons>
    while (cons.e != cons.w &&
    8000038c:	4929                	li	s2,10
    8000038e:	02f70863          	beq	a4,a5,800003be <consoleintr+0x104>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	07f7f713          	andi	a4,a5,127
    80000398:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    8000039a:	01874703          	lbu	a4,24(a4)
    8000039e:	03270263          	beq	a4,s2,800003c2 <consoleintr+0x108>
      cons.e--;
    800003a2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a6:	10000513          	li	a0,256
    800003aa:	edfff0ef          	jal	80000288 <consputc>
    while (cons.e != cons.w &&
    800003ae:	0a04a783          	lw	a5,160(s1)
    800003b2:	09c4a703          	lw	a4,156(s1)
    800003b6:	fcf71ee3          	bne	a4,a5,80000392 <consoleintr+0xd8>
    800003ba:	6902                	ld	s2,0(sp)
    800003bc:	bf05                	j	800002ec <consoleintr+0x32>
    800003be:	6902                	ld	s2,0(sp)
    800003c0:	b735                	j	800002ec <consoleintr+0x32>
    800003c2:	6902                	ld	s2,0(sp)
    800003c4:	b725                	j	800002ec <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c6:	00013717          	auipc	a4,0x13
    800003ca:	1ca70713          	addi	a4,a4,458 # 80013590 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70be3          	beq	a4,a5,800002ec <consoleintr+0x32>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	00013717          	auipc	a4,0x13
    800003e0:	24f72a23          	sw	a5,596(a4) # 80013630 <cons+0xa0>
      consputc(BACKSPACE);
    800003e4:	10000513          	li	a0,256
    800003e8:	ea1ff0ef          	jal	80000288 <consputc>
    800003ec:	b701                	j	800002ec <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ee:	ee048fe3          	beqz	s1,800002ec <consoleintr+0x32>
    800003f2:	bf21                	j	8000030a <consoleintr+0x50>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	e93ff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003fa:	00013797          	auipc	a5,0x13
    800003fe:	19678793          	addi	a5,a5,406 # 80013590 <cons>
    80000402:	0a07a703          	lw	a4,160(a5)
    80000406:	0017069b          	addiw	a3,a4,1
    8000040a:	0006861b          	sext.w	a2,a3
    8000040e:	0ad7a023          	sw	a3,160(a5)
    80000412:	07f77713          	andi	a4,a4,127
    80000416:	97ba                	add	a5,a5,a4
    80000418:	4729                	li	a4,10
    8000041a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041e:	00013797          	auipc	a5,0x13
    80000422:	20c7a723          	sw	a2,526(a5) # 8001362c <cons+0x9c>
        wakeup(&cons.r);
    80000426:	00013517          	auipc	a0,0x13
    8000042a:	20250513          	addi	a0,a0,514 # 80013628 <cons+0x98>
    8000042e:	457010ef          	jal	80002084 <wakeup>
    80000432:	bd6d                	j	800002ec <consoleintr+0x32>

0000000080000434 <consoleinit>:

void
consoleinit(void)
{
    80000434:	1141                	addi	sp,sp,-16
    80000436:	e406                	sd	ra,8(sp)
    80000438:	e022                	sd	s0,0(sp)
    8000043a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000043c:	00008597          	auipc	a1,0x8
    80000440:	bc458593          	addi	a1,a1,-1084 # 80008000 <etext>
    80000444:	00013517          	auipc	a0,0x13
    80000448:	14c50513          	addi	a0,a0,332 # 80013590 <cons>
    8000044c:	6ce000ef          	jal	80000b1a <initlock>

  uartinit();
    80000450:	400000ef          	jal	80000850 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000454:	00024797          	auipc	a5,0x24
    80000458:	4c478793          	addi	a5,a5,1220 # 80024918 <devsw>
    8000045c:	00000717          	auipc	a4,0x0
    80000460:	d1470713          	addi	a4,a4,-748 # 80000170 <consoleread>
    80000464:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000466:	00000717          	auipc	a4,0x0
    8000046a:	c6c70713          	addi	a4,a4,-916 # 800000d2 <consolewrite>
    8000046e:	ef98                	sd	a4,24(a5)
}
    80000470:	60a2                	ld	ra,8(sp)
    80000472:	6402                	ld	s0,0(sp)
    80000474:	0141                	addi	sp,sp,16
    80000476:	8082                	ret

0000000080000478 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000478:	7139                	addi	sp,sp,-64
    8000047a:	fc06                	sd	ra,56(sp)
    8000047c:	f822                	sd	s0,48(sp)
    8000047e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    80000480:	c219                	beqz	a2,80000486 <printint+0xe>
    80000482:	08054063          	bltz	a0,80000502 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000486:	4881                	li	a7,0
    80000488:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000048c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00008617          	auipc	a2,0x8
    80000492:	47260613          	addi	a2,a2,1138 # 80008900 <digits>
    80000496:	883e                	mv	a6,a5
    80000498:	2785                	addiw	a5,a5,1
    8000049a:	02b57733          	remu	a4,a0,a1
    8000049e:	9732                	add	a4,a4,a2
    800004a0:	00074703          	lbu	a4,0(a4)
    800004a4:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
    800004a8:	872a                	mv	a4,a0
    800004aa:	02b55533          	divu	a0,a0,a1
    800004ae:	0685                	addi	a3,a3,1
    800004b0:	feb773e3          	bgeu	a4,a1,80000496 <printint+0x1e>

  if (sign)
    800004b4:	00088a63          	beqz	a7,800004c8 <printint+0x50>
    buf[i++] = '-';
    800004b8:	1781                	addi	a5,a5,-32
    800004ba:	97a2                	add	a5,a5,s0
    800004bc:	02d00713          	li	a4,45
    800004c0:	fee78423          	sb	a4,-24(a5)
    800004c4:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
    800004c8:	02f05963          	blez	a5,800004fa <printint+0x82>
    800004cc:	f426                	sd	s1,40(sp)
    800004ce:	f04a                	sd	s2,32(sp)
    800004d0:	fc840713          	addi	a4,s0,-56
    800004d4:	00f704b3          	add	s1,a4,a5
    800004d8:	fff70913          	addi	s2,a4,-1
    800004dc:	993e                	add	s2,s2,a5
    800004de:	37fd                	addiw	a5,a5,-1
    800004e0:	1782                	slli	a5,a5,0x20
    800004e2:	9381                	srli	a5,a5,0x20
    800004e4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004e8:	fff4c503          	lbu	a0,-1(s1)
    800004ec:	d9dff0ef          	jal	80000288 <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x70>
    800004f6:	74a2                	ld	s1,40(sp)
    800004f8:	7902                	ld	s2,32(sp)
}
    800004fa:	70e2                	ld	ra,56(sp)
    800004fc:	7442                	ld	s0,48(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4885                	li	a7,1
    x = -xx;
    80000508:	b741                	j	80000488 <printint+0x10>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	e8d2                	sd	s4,80(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	8a2a                	mv	s4,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	0000b797          	auipc	a5,0xb
    8000052c:	02c7a783          	lw	a5,44(a5) # 8000b554 <panicking>
    80000530:	c3a1                	beqz	a5,80000570 <printk+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	000a4503          	lbu	a0,0(s4)
    8000053e:	28050763          	beqz	a0,800007cc <printk+0x2c2>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	f0ca                	sd	s2,96(sp)
    80000546:	ecce                	sd	s3,88(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	f862                	sd	s8,48(sp)
    8000054e:	f466                	sd	s9,40(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4981                	li	s3,0
    if (cx != '%') {
    80000556:	02500a93          	li	s5,37
    c1 = c2 = 0;
    if (c0)
      c1 = fmt[i + 1] & 0xff;
    if (c1)
      c2 = fmt[i + 2] & 0xff;
    if (c0 == 'd') {
    8000055a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if (c0 == 'l' && c1 == 'd') {
    8000055e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    80000562:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    80000566:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    8000056a:	07000d93          	li	s11,112
    8000056e:	a01d                	j	80000594 <printk+0x8a>
    acquire(&pr.lock);
    80000570:	00013517          	auipc	a0,0x13
    80000574:	0c850513          	addi	a0,a0,200 # 80013638 <pr>
    80000578:	618000ef          	jal	80000b90 <acquire>
    8000057c:	bf5d                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057e:	d0bff0ef          	jal	80000288 <consputc>
      continue;
    80000582:	84ce                	mv	s1,s3
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000584:	0014899b          	addiw	s3,s1,1
    80000588:	013a07b3          	add	a5,s4,s3
    8000058c:	0007c503          	lbu	a0,0(a5)
    80000590:	20050b63          	beqz	a0,800007a6 <printk+0x29c>
    if (cx != '%') {
    80000594:	ff5515e3          	bne	a0,s5,8000057e <printk+0x74>
    i++;
    80000598:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i + 0] & 0xff;
    8000059c:	009a07b3          	add	a5,s4,s1
    800005a0:	0007c903          	lbu	s2,0(a5)
    if (c0)
    800005a4:	20090b63          	beqz	s2,800007ba <printk+0x2b0>
      c1 = fmt[i + 1] & 0xff;
    800005a8:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800005ac:	86be                	mv	a3,a5
    if (c1)
    800005ae:	c789                	beqz	a5,800005b8 <printk+0xae>
      c2 = fmt[i + 2] & 0xff;
    800005b0:	009a0733          	add	a4,s4,s1
    800005b4:	00274683          	lbu	a3,2(a4)
    if (c0 == 'd') {
    800005b8:	03690963          	beq	s2,s6,800005ea <printk+0xe0>
    } else if (c0 == 'l' && c1 == 'd') {
    800005bc:	05890363          	beq	s2,s8,80000602 <printk+0xf8>
    } else if (c0 == 'u') {
    800005c0:	0d990663          	beq	s2,s9,8000068c <printk+0x182>
    } else if (c0 == 'x') {
    800005c4:	11a90d63          	beq	s2,s10,800006de <printk+0x1d4>
    } else if (c0 == 'p') {
    800005c8:	15b90663          	beq	s2,s11,80000714 <printk+0x20a>
      printptr(va_arg(ap, uint64));
    } else if (c0 == 'c') {
    800005cc:	06300793          	li	a5,99
    800005d0:	18f90563          	beq	s2,a5,8000075a <printk+0x250>
      consputc(va_arg(ap, uint));
    } else if (c0 == 's') {
    800005d4:	07300793          	li	a5,115
    800005d8:	18f90b63          	beq	s2,a5,8000076e <printk+0x264>
      if ((s = va_arg(ap, char *)) == 0)
        s = "(null)";
      for (; *s; s++)
        consputc(*s);
    } else if (c0 == '%') {
    800005dc:	03591b63          	bne	s2,s5,80000612 <printk+0x108>
      consputc('%');
    800005e0:	02500513          	li	a0,37
    800005e4:	ca5ff0ef          	jal	80000288 <consputc>
    800005e8:	bf71                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005ea:	f8843783          	ld	a5,-120(s0)
    800005ee:	00878713          	addi	a4,a5,8
    800005f2:	f8e43423          	sd	a4,-120(s0)
    800005f6:	4605                	li	a2,1
    800005f8:	45a9                	li	a1,10
    800005fa:	4388                	lw	a0,0(a5)
    800005fc:	e7dff0ef          	jal	80000478 <printint>
    80000600:	b751                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'd') {
    80000602:	01678f63          	beq	a5,s6,80000620 <printk+0x116>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    80000606:	03878b63          	beq	a5,s8,8000063c <printk+0x132>
    } else if (c0 == 'l' && c1 == 'u') {
    8000060a:	09978e63          	beq	a5,s9,800006a6 <printk+0x19c>
    } else if (c0 == 'l' && c1 == 'x') {
    8000060e:	0fa78563          	beq	a5,s10,800006f8 <printk+0x1ee>
    } else if (c0 == 0) {
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000612:	8556                	mv	a0,s5
    80000614:	c75ff0ef          	jal	80000288 <consputc>
      consputc(c0);
    80000618:	854a                	mv	a0,s2
    8000061a:	c6fff0ef          	jal	80000288 <consputc>
    8000061e:	b79d                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000620:	f8843783          	ld	a5,-120(s0)
    80000624:	00878713          	addi	a4,a5,8
    80000628:	f8e43423          	sd	a4,-120(s0)
    8000062c:	4605                	li	a2,1
    8000062e:	45a9                	li	a1,10
    80000630:	6388                	ld	a0,0(a5)
    80000632:	e47ff0ef          	jal	80000478 <printint>
      i += 1;
    80000636:	0029849b          	addiw	s1,s3,2
    8000063a:	b7a9                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    8000063c:	06400793          	li	a5,100
    80000640:	02f68863          	beq	a3,a5,80000670 <printk+0x166>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    80000644:	07500793          	li	a5,117
    80000648:	06f68d63          	beq	a3,a5,800006c2 <printk+0x1b8>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    8000064c:	07800793          	li	a5,120
    80000650:	fcf691e3          	bne	a3,a5,80000612 <printk+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4601                	li	a2,0
    80000662:	45c1                	li	a1,16
    80000664:	6388                	ld	a0,0(a5)
    80000666:	e13ff0ef          	jal	80000478 <printint>
      i += 2;
    8000066a:	0039849b          	addiw	s1,s3,3
    8000066e:	bf19                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000670:	f8843783          	ld	a5,-120(s0)
    80000674:	00878713          	addi	a4,a5,8
    80000678:	f8e43423          	sd	a4,-120(s0)
    8000067c:	4605                	li	a2,1
    8000067e:	45a9                	li	a1,10
    80000680:	6388                	ld	a0,0(a5)
    80000682:	df7ff0ef          	jal	80000478 <printint>
      i += 2;
    80000686:	0039849b          	addiw	s1,s3,3
    8000068a:	bded                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4601                	li	a2,0
    8000069a:	45a9                	li	a1,10
    8000069c:	0007e503          	lwu	a0,0(a5)
    800006a0:	dd9ff0ef          	jal	80000478 <printint>
    800006a4:	b5c5                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006a6:	f8843783          	ld	a5,-120(s0)
    800006aa:	00878713          	addi	a4,a5,8
    800006ae:	f8e43423          	sd	a4,-120(s0)
    800006b2:	4601                	li	a2,0
    800006b4:	45a9                	li	a1,10
    800006b6:	6388                	ld	a0,0(a5)
    800006b8:	dc1ff0ef          	jal	80000478 <printint>
      i += 1;
    800006bc:	0029849b          	addiw	s1,s3,2
    800006c0:	b5d1                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006c2:	f8843783          	ld	a5,-120(s0)
    800006c6:	00878713          	addi	a4,a5,8
    800006ca:	f8e43423          	sd	a4,-120(s0)
    800006ce:	4601                	li	a2,0
    800006d0:	45a9                	li	a1,10
    800006d2:	6388                	ld	a0,0(a5)
    800006d4:	da5ff0ef          	jal	80000478 <printint>
      i += 2;
    800006d8:	0039849b          	addiw	s1,s3,3
    800006dc:	b565                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	4601                	li	a2,0
    800006ec:	45c1                	li	a1,16
    800006ee:	0007e503          	lwu	a0,0(a5)
    800006f2:	d87ff0ef          	jal	80000478 <printint>
    800006f6:	b579                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006f8:	f8843783          	ld	a5,-120(s0)
    800006fc:	00878713          	addi	a4,a5,8
    80000700:	f8e43423          	sd	a4,-120(s0)
    80000704:	4601                	li	a2,0
    80000706:	45c1                	li	a1,16
    80000708:	6388                	ld	a0,0(a5)
    8000070a:	d6fff0ef          	jal	80000478 <printint>
      i += 1;
    8000070e:	0029849b          	addiw	s1,s3,2
    80000712:	bd8d                	j	80000584 <printk+0x7a>
    80000714:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000716:	f8843783          	ld	a5,-120(s0)
    8000071a:	00878713          	addi	a4,a5,8
    8000071e:	f8e43423          	sd	a4,-120(s0)
    80000722:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000726:	03000513          	li	a0,48
    8000072a:	b5fff0ef          	jal	80000288 <consputc>
  consputc('x');
    8000072e:	07800513          	li	a0,120
    80000732:	b57ff0ef          	jal	80000288 <consputc>
    80000736:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000738:	00008b97          	auipc	s7,0x8
    8000073c:	1c8b8b93          	addi	s7,s7,456 # 80008900 <digits>
    80000740:	03c9d793          	srli	a5,s3,0x3c
    80000744:	97de                	add	a5,a5,s7
    80000746:	0007c503          	lbu	a0,0(a5)
    8000074a:	b3fff0ef          	jal	80000288 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000074e:	0992                	slli	s3,s3,0x4
    80000750:	397d                	addiw	s2,s2,-1
    80000752:	fe0917e3          	bnez	s2,80000740 <printk+0x236>
    80000756:	7be2                	ld	s7,56(sp)
    80000758:	b535                	j	80000584 <printk+0x7a>
      consputc(va_arg(ap, uint));
    8000075a:	f8843783          	ld	a5,-120(s0)
    8000075e:	00878713          	addi	a4,a5,8
    80000762:	f8e43423          	sd	a4,-120(s0)
    80000766:	4388                	lw	a0,0(a5)
    80000768:	b21ff0ef          	jal	80000288 <consputc>
    8000076c:	bd21                	j	80000584 <printk+0x7a>
      if ((s = va_arg(ap, char *)) == 0)
    8000076e:	f8843783          	ld	a5,-120(s0)
    80000772:	00878713          	addi	a4,a5,8
    80000776:	f8e43423          	sd	a4,-120(s0)
    8000077a:	0007b903          	ld	s2,0(a5)
    8000077e:	00090d63          	beqz	s2,80000798 <printk+0x28e>
      for (; *s; s++)
    80000782:	00094503          	lbu	a0,0(s2)
    80000786:	de050fe3          	beqz	a0,80000584 <printk+0x7a>
        consputc(*s);
    8000078a:	affff0ef          	jal	80000288 <consputc>
      for (; *s; s++)
    8000078e:	0905                	addi	s2,s2,1
    80000790:	00094503          	lbu	a0,0(s2)
    80000794:	f97d                	bnez	a0,8000078a <printk+0x280>
    80000796:	b3fd                	j	80000584 <printk+0x7a>
        s = "(null)";
    80000798:	00008917          	auipc	s2,0x8
    8000079c:	87090913          	addi	s2,s2,-1936 # 80008008 <etext+0x8>
      for (; *s; s++)
    800007a0:	02800513          	li	a0,40
    800007a4:	b7dd                	j	8000078a <printk+0x280>
    800007a6:	74a6                	ld	s1,104(sp)
    800007a8:	7906                	ld	s2,96(sp)
    800007aa:	69e6                	ld	s3,88(sp)
    800007ac:	6aa6                	ld	s5,72(sp)
    800007ae:	6b06                	ld	s6,64(sp)
    800007b0:	7c42                	ld	s8,48(sp)
    800007b2:	7ca2                	ld	s9,40(sp)
    800007b4:	7d02                	ld	s10,32(sp)
    800007b6:	6de2                	ld	s11,24(sp)
    800007b8:	a811                	j	800007cc <printk+0x2c2>
    800007ba:	74a6                	ld	s1,104(sp)
    800007bc:	7906                	ld	s2,96(sp)
    800007be:	69e6                	ld	s3,88(sp)
    800007c0:	6aa6                	ld	s5,72(sp)
    800007c2:	6b06                	ld	s6,64(sp)
    800007c4:	7c42                	ld	s8,48(sp)
    800007c6:	7ca2                	ld	s9,40(sp)
    800007c8:	7d02                	ld	s10,32(sp)
    800007ca:	6de2                	ld	s11,24(sp)
    }
  }
  va_end(ap);

  if (panicking == 0)
    800007cc:	0000b797          	auipc	a5,0xb
    800007d0:	d887a783          	lw	a5,-632(a5) # 8000b554 <panicking>
    800007d4:	c799                	beqz	a5,800007e2 <printk+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007d6:	4501                	li	a0,0
    800007d8:	70e6                	ld	ra,120(sp)
    800007da:	7446                	ld	s0,112(sp)
    800007dc:	6a46                	ld	s4,80(sp)
    800007de:	6129                	addi	sp,sp,192
    800007e0:	8082                	ret
    release(&pr.lock);
    800007e2:	00013517          	auipc	a0,0x13
    800007e6:	e5650513          	addi	a0,a0,-426 # 80013638 <pr>
    800007ea:	432000ef          	jal	80000c1c <release>
  return 0;
    800007ee:	b7e5                	j	800007d6 <printk+0x2cc>

00000000800007f0 <panic>:

void
panic(char *s)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	e04a                	sd	s2,0(sp)
    800007fa:	1000                	addi	s0,sp,32
    800007fc:	84aa                	mv	s1,a0
  panicking = 1;
    800007fe:	4905                	li	s2,1
    80000800:	0000b797          	auipc	a5,0xb
    80000804:	d527aa23          	sw	s2,-684(a5) # 8000b554 <panicking>
  printk("panic: ");
    80000808:	00008517          	auipc	a0,0x8
    8000080c:	81050513          	addi	a0,a0,-2032 # 80008018 <etext+0x18>
    80000810:	cfbff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000814:	85a6                	mv	a1,s1
    80000816:	00008517          	auipc	a0,0x8
    8000081a:	80a50513          	addi	a0,a0,-2038 # 80008020 <etext+0x20>
    8000081e:	cedff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000822:	0000b797          	auipc	a5,0xb
    80000826:	d327a723          	sw	s2,-722(a5) # 8000b550 <panicked>
  for (;;)
    8000082a:	a001                	j	8000082a <panic+0x3a>

000000008000082c <printkinit>:
    ;
}

void
printkinit(void)
{
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e406                	sd	ra,8(sp)
    80000830:	e022                	sd	s0,0(sp)
    80000832:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000834:	00007597          	auipc	a1,0x7
    80000838:	7f458593          	addi	a1,a1,2036 # 80008028 <etext+0x28>
    8000083c:	00013517          	auipc	a0,0x13
    80000840:	dfc50513          	addi	a0,a0,-516 # 80013638 <pr>
    80000844:	2d6000ef          	jal	80000b1a <initlock>
}
    80000848:	60a2                	ld	ra,8(sp)
    8000084a:	6402                	ld	s0,0(sp)
    8000084c:	0141                	addi	sp,sp,16
    8000084e:	8082                	ret

0000000080000850 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000850:	1141                	addi	sp,sp,-16
    80000852:	e406                	sd	ra,8(sp)
    80000854:	e022                	sd	s0,0(sp)
    80000856:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000858:	100007b7          	lui	a5,0x10000
    8000085c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000860:	10000737          	lui	a4,0x10000
    80000864:	f8000693          	li	a3,-128
    80000868:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000086c:	468d                	li	a3,3
    8000086e:	10000637          	lui	a2,0x10000
    80000872:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000876:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000087a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000087e:	10000737          	lui	a4,0x10000
    80000882:	461d                	li	a2,7
    80000884:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000888:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    8000088c:	00007597          	auipc	a1,0x7
    80000890:	7a458593          	addi	a1,a1,1956 # 80008030 <etext+0x30>
    80000894:	00013517          	auipc	a0,0x13
    80000898:	dbc50513          	addi	a0,a0,-580 # 80013650 <tx_lock>
    8000089c:	463030ef          	jal	800044fe <initsleeplock>
}
    800008a0:	60a2                	ld	ra,8(sp)
    800008a2:	6402                	ld	s0,0(sp)
    800008a4:	0141                	addi	sp,sp,16
    800008a6:	8082                	ret

00000000800008a8 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008a8:	7139                	addi	sp,sp,-64
    800008aa:	fc06                	sd	ra,56(sp)
    800008ac:	f822                	sd	s0,48(sp)
    800008ae:	f04a                	sd	s2,32(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	0080                	addi	s0,sp,64
    800008b4:	8aaa                	mv	s5,a0
    800008b6:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008b8:	00013517          	auipc	a0,0x13
    800008bc:	d9850513          	addi	a0,a0,-616 # 80013650 <tx_lock>
    800008c0:	475030ef          	jal	80004534 <acquiresleep>

  int i = 0;
  while (i < n) {
    800008c4:	05205963          	blez	s2,80000916 <uartwrite+0x6e>
    800008c8:	f426                	sd	s1,40(sp)
    800008ca:	ec4e                	sd	s3,24(sp)
    800008cc:	e852                	sd	s4,16(sp)
    800008ce:	e05a                	sd	s6,0(sp)
  int i = 0;
    800008d0:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    800008d2:	0000ba17          	auipc	s4,0xb
    800008d6:	c86a0a13          	addi	s4,s4,-890 # 8000b558 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008da:	100009b7          	lui	s3,0x10000
    800008de:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    800008e0:	10000b37          	lui	s6,0x10000
    800008e4:	a811                	j	800008f8 <uartwrite+0x50>
    800008e6:	009a87b3          	add	a5,s5,s1
    800008ea:	0007c783          	lbu	a5,0(a5)
    800008ee:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    800008f2:	2485                	addiw	s1,s1,1
  while (i < n) {
    800008f4:	0124dd63          	bge	s1,s2,8000090e <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    800008f8:	8552                	mv	a0,s4
    800008fa:	712010ef          	jal	8000200c <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008fe:	0009c783          	lbu	a5,0(s3)
    80000902:	0207f793          	andi	a5,a5,32
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x3e>
    } else {
      sleep();
    80000908:	740010ef          	jal	80002048 <sleep>
    8000090c:	b7e5                	j	800008f4 <uartwrite+0x4c>
    8000090e:	74a2                	ld	s1,40(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000916:	00013517          	auipc	a0,0x13
    8000091a:	d3a50513          	addi	a0,a0,-710 # 80013650 <tx_lock>
    8000091e:	46b030ef          	jal	80004588 <releasesleep>
}
    80000922:	70e2                	ld	ra,56(sp)
    80000924:	7442                	ld	s0,48(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	6aa2                	ld	s5,8(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret

000000008000092e <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092e:	1101                	addi	sp,sp,-32
    80000930:	ec06                	sd	ra,24(sp)
    80000932:	e822                	sd	s0,16(sp)
    80000934:	e426                	sd	s1,8(sp)
    80000936:	1000                	addi	s0,sp,32
    80000938:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000093a:	0000b797          	auipc	a5,0xb
    8000093e:	c1a7a783          	lw	a5,-998(a5) # 8000b554 <panicking>
    80000942:	cf95                	beqz	a5,8000097e <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000944:	0000b797          	auipc	a5,0xb
    80000948:	c0c7a783          	lw	a5,-1012(a5) # 8000b550 <panicked>
    8000094c:	ef85                	bnez	a5,80000984 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094e:	10000737          	lui	a4,0x10000
    80000952:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000954:	00074783          	lbu	a5,0(a4)
    80000958:	0207f793          	andi	a5,a5,32
    8000095c:	dfe5                	beqz	a5,80000954 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095e:	0ff4f513          	zext.b	a0,s1
    80000962:	100007b7          	lui	a5,0x10000
    80000966:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    8000096a:	0000b797          	auipc	a5,0xb
    8000096e:	bea7a783          	lw	a5,-1046(a5) # 8000b554 <panicking>
    80000972:	cb91                	beqz	a5,80000986 <uartputc_sync+0x58>
    pop_off();
}
    80000974:	60e2                	ld	ra,24(sp)
    80000976:	6442                	ld	s0,16(sp)
    80000978:	64a2                	ld	s1,8(sp)
    8000097a:	6105                	addi	sp,sp,32
    8000097c:	8082                	ret
    push_off();
    8000097e:	1dc000ef          	jal	80000b5a <push_off>
    80000982:	b7c9                	j	80000944 <uartputc_sync+0x16>
    for (;;)
    80000984:	a001                	j	80000984 <uartputc_sync+0x56>
    pop_off();
    80000986:	24a000ef          	jal	80000bd0 <pop_off>
}
    8000098a:	b7ed                	j	80000974 <uartputc_sync+0x46>

000000008000098c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000098c:	1101                	addi	sp,sp,-32
    8000098e:	ec06                	sd	ra,24(sp)
    80000990:	e822                	sd	s0,16(sp)
    80000992:	e426                	sd	s1,8(sp)
    80000994:	e04a                	sd	s2,0(sp)
    80000996:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    8000099e:	0007c783          	lbu	a5,0(a5)

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009a8:	0007c783          	lbu	a5,0(a5)
    800009ac:	0207f793          	andi	a5,a5,32
    800009b0:	ef99                	bnez	a5,800009ce <uartintr+0x42>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009b2:	100004b7          	lui	s1,0x10000
    800009b6:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009b8:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009bc:	0004c783          	lbu	a5,0(s1)
    800009c0:	8b85                	andi	a5,a5,1
    800009c2:	cf89                	beqz	a5,800009dc <uartintr+0x50>
    return ReadReg(RHR);
    800009c4:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    800009c8:	8f3ff0ef          	jal	800002ba <consoleintr>
  while (1) {
    800009cc:	bfc5                	j	800009bc <uartintr+0x30>
    wakeup(&tx_chan);
    800009ce:	0000b517          	auipc	a0,0xb
    800009d2:	b8a50513          	addi	a0,a0,-1142 # 8000b558 <tx_chan>
    800009d6:	6ae010ef          	jal	80002084 <wakeup>
    800009da:	bfe1                	j	800009b2 <uartintr+0x26>
  }
}
    800009dc:	60e2                	ld	ra,24(sp)
    800009de:	6442                	ld	s0,16(sp)
    800009e0:	64a2                	ld	s1,8(sp)
    800009e2:	6902                	ld	s2,0(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	e7a9                	bnez	a5,80000a42 <kfree+0x5a>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00025797          	auipc	a5,0x25
    80000a00:	0b478793          	addi	a5,a5,180 # 80025ab0 <end>
    80000a04:	02f56f63          	bltu	a0,a5,80000a42 <kfree+0x5a>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	02f57b63          	bgeu	a0,a5,80000a42 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	240000ef          	jal	80000c54 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a18:	00013917          	auipc	s2,0x13
    80000a1c:	c6890913          	addi	s2,s2,-920 # 80013680 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	16e000ef          	jal	80000b90 <acquire>
  r->next = kmem.freelist;
    80000a26:	01893783          	ld	a5,24(s2)
    80000a2a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a30:	854a                	mv	a0,s2
    80000a32:	1ea000ef          	jal	80000c1c <release>
}
    80000a36:	60e2                	ld	ra,24(sp)
    80000a38:	6442                	ld	s0,16(sp)
    80000a3a:	64a2                	ld	s1,8(sp)
    80000a3c:	6902                	ld	s2,0(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret
    panic("kfree");
    80000a42:	00007517          	auipc	a0,0x7
    80000a46:	5f650513          	addi	a0,a0,1526 # 80008038 <etext+0x38>
    80000a4a:	da7ff0ef          	jal	800007f0 <panic>

0000000080000a4e <freerange>:
{
    80000a4e:	7179                	addi	sp,sp,-48
    80000a50:	f406                	sd	ra,40(sp)
    80000a52:	f022                	sd	s0,32(sp)
    80000a54:	ec26                	sd	s1,24(sp)
    80000a56:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a58:	6785                	lui	a5,0x1
    80000a5a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a5e:	00e504b3          	add	s1,a0,a4
    80000a62:	777d                	lui	a4,0xfffff
    80000a64:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a66:	94be                	add	s1,s1,a5
    80000a68:	0295e263          	bltu	a1,s1,80000a8c <freerange+0x3e>
    80000a6c:	e84a                	sd	s2,16(sp)
    80000a6e:	e44e                	sd	s3,8(sp)
    80000a70:	e052                	sd	s4,0(sp)
    80000a72:	892e                	mv	s2,a1
    kfree(p);
    80000a74:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a76:	6985                	lui	s3,0x1
    kfree(p);
    80000a78:	01448533          	add	a0,s1,s4
    80000a7c:	f6dff0ef          	jal	800009e8 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe997be3          	bgeu	s2,s1,80000a78 <freerange+0x2a>
    80000a86:	6942                	ld	s2,16(sp)
    80000a88:	69a2                	ld	s3,8(sp)
    80000a8a:	6a02                	ld	s4,0(sp)
}
    80000a8c:	70a2                	ld	ra,40(sp)
    80000a8e:	7402                	ld	s0,32(sp)
    80000a90:	64e2                	ld	s1,24(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	5a258593          	addi	a1,a1,1442 # 80008040 <etext+0x40>
    80000aa6:	00013517          	auipc	a0,0x13
    80000aaa:	bda50513          	addi	a0,a0,-1062 # 80013680 <kmem>
    80000aae:	06c000ef          	jal	80000b1a <initlock>
  freerange(end, (void *)PHYSTOP);
    80000ab2:	45c5                	li	a1,17
    80000ab4:	05ee                	slli	a1,a1,0x1b
    80000ab6:	00025517          	auipc	a0,0x25
    80000aba:	ffa50513          	addi	a0,a0,-6 # 80025ab0 <end>
    80000abe:	f91ff0ef          	jal	80000a4e <freerange>
}
    80000ac2:	60a2                	ld	ra,8(sp)
    80000ac4:	6402                	ld	s0,0(sp)
    80000ac6:	0141                	addi	sp,sp,16
    80000ac8:	8082                	ret

0000000080000aca <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000aca:	1101                	addi	sp,sp,-32
    80000acc:	ec06                	sd	ra,24(sp)
    80000ace:	e822                	sd	s0,16(sp)
    80000ad0:	e426                	sd	s1,8(sp)
    80000ad2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ad4:	00013497          	auipc	s1,0x13
    80000ad8:	bac48493          	addi	s1,s1,-1108 # 80013680 <kmem>
    80000adc:	8526                	mv	a0,s1
    80000ade:	0b2000ef          	jal	80000b90 <acquire>
  r = kmem.freelist;
    80000ae2:	6c84                	ld	s1,24(s1)
  if (r)
    80000ae4:	c485                	beqz	s1,80000b0c <kalloc+0x42>
    kmem.freelist = r->next;
    80000ae6:	609c                	ld	a5,0(s1)
    80000ae8:	00013517          	auipc	a0,0x13
    80000aec:	b9850513          	addi	a0,a0,-1128 # 80013680 <kmem>
    80000af0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000af2:	12a000ef          	jal	80000c1c <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000af6:	6605                	lui	a2,0x1
    80000af8:	4595                	li	a1,5
    80000afa:	8526                	mv	a0,s1
    80000afc:	158000ef          	jal	80000c54 <memset>
  return (void *)r;
}
    80000b00:	8526                	mv	a0,s1
    80000b02:	60e2                	ld	ra,24(sp)
    80000b04:	6442                	ld	s0,16(sp)
    80000b06:	64a2                	ld	s1,8(sp)
    80000b08:	6105                	addi	sp,sp,32
    80000b0a:	8082                	ret
  release(&kmem.lock);
    80000b0c:	00013517          	auipc	a0,0x13
    80000b10:	b7450513          	addi	a0,a0,-1164 # 80013680 <kmem>
    80000b14:	108000ef          	jal	80000c1c <release>
  if (r)
    80000b18:	b7e5                	j	80000b00 <kalloc+0x36>

0000000080000b1a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b1a:	1141                	addi	sp,sp,-16
    80000b1c:	e422                	sd	s0,8(sp)
    80000b1e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b20:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b22:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b26:	00053823          	sd	zero,16(a0)
}
    80000b2a:	6422                	ld	s0,8(sp)
    80000b2c:	0141                	addi	sp,sp,16
    80000b2e:	8082                	ret

0000000080000b30 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b30:	411c                	lw	a5,0(a0)
    80000b32:	e399                	bnez	a5,80000b38 <holding+0x8>
    80000b34:	4501                	li	a0,0
  return r;
}
    80000b36:	8082                	ret
{
    80000b38:	1101                	addi	sp,sp,-32
    80000b3a:	ec06                	sd	ra,24(sp)
    80000b3c:	e822                	sd	s0,16(sp)
    80000b3e:	e426                	sd	s1,8(sp)
    80000b40:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b42:	6904                	ld	s1,16(a0)
    80000b44:	543000ef          	jal	80001886 <mycpu>
    80000b48:	40a48533          	sub	a0,s1,a0
    80000b4c:	00153513          	seqz	a0,a0
}
    80000b50:	60e2                	ld	ra,24(sp)
    80000b52:	6442                	ld	s0,16(sp)
    80000b54:	64a2                	ld	s1,8(sp)
    80000b56:	6105                	addi	sp,sp,32
    80000b58:	8082                	ret

0000000080000b5a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b5a:	1101                	addi	sp,sp,-32
    80000b5c:	ec06                	sd	ra,24(sp)
    80000b5e:	e822                	sd	s0,16(sp)
    80000b60:	e426                	sd	s1,8(sp)
    80000b62:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000b64:	100174f3          	csrrci	s1,sstatus,2
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000b68:	51f000ef          	jal	80001886 <mycpu>
    80000b6c:	5d3c                	lw	a5,120(a0)
    80000b6e:	cb99                	beqz	a5,80000b84 <push_off+0x2a>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b70:	517000ef          	jal	80001886 <mycpu>
    80000b74:	5d3c                	lw	a5,120(a0)
    80000b76:	2785                	addiw	a5,a5,1
    80000b78:	dd3c                	sw	a5,120(a0)
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret
    mycpu()->intena = old;
    80000b84:	503000ef          	jal	80001886 <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000b88:	8085                	srli	s1,s1,0x1
    80000b8a:	8885                	andi	s1,s1,1
    mycpu()->intena = old;
    80000b8c:	dd64                	sw	s1,124(a0)
    80000b8e:	b7cd                	j	80000b70 <push_off+0x16>

0000000080000b90 <acquire>:
{
    80000b90:	1101                	addi	sp,sp,-32
    80000b92:	ec06                	sd	ra,24(sp)
    80000b94:	e822                	sd	s0,16(sp)
    80000b96:	e426                	sd	s1,8(sp)
    80000b98:	1000                	addi	s0,sp,32
    80000b9a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b9c:	fbfff0ef          	jal	80000b5a <push_off>
  if (holding(lk))
    80000ba0:	8526                	mv	a0,s1
    80000ba2:	f8fff0ef          	jal	80000b30 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000ba6:	4705                	li	a4,1
  if (holding(lk))
    80000ba8:	ed11                	bnez	a0,80000bc4 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000baa:	87ba                	mv	a5,a4
    80000bac:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bb0:	2781                	sext.w	a5,a5
    80000bb2:	ffe5                	bnez	a5,80000baa <acquire+0x1a>
  lk->cpu = mycpu();
    80000bb4:	4d3000ef          	jal	80001886 <mycpu>
    80000bb8:	e888                	sd	a0,16(s1)
}
    80000bba:	60e2                	ld	ra,24(sp)
    80000bbc:	6442                	ld	s0,16(sp)
    80000bbe:	64a2                	ld	s1,8(sp)
    80000bc0:	6105                	addi	sp,sp,32
    80000bc2:	8082                	ret
    panic("acquire");
    80000bc4:	00007517          	auipc	a0,0x7
    80000bc8:	48450513          	addi	a0,a0,1156 # 80008048 <etext+0x48>
    80000bcc:	c25ff0ef          	jal	800007f0 <panic>

0000000080000bd0 <pop_off>:

void
pop_off(void)
{
    80000bd0:	1141                	addi	sp,sp,-16
    80000bd2:	e406                	sd	ra,8(sp)
    80000bd4:	e022                	sd	s0,0(sp)
    80000bd6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bd8:	4af000ef          	jal	80001886 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000bdc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000be0:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000be2:	e38d                	bnez	a5,80000c04 <pop_off+0x34>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000be4:	5d3c                	lw	a5,120(a0)
    80000be6:	02f05563          	blez	a5,80000c10 <pop_off+0x40>
    panic("pop_off");
  c->noff -= 1;
    80000bea:	37fd                	addiw	a5,a5,-1
    80000bec:	0007871b          	sext.w	a4,a5
    80000bf0:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000bf2:	e709                	bnez	a4,80000bfc <pop_off+0x2c>
    80000bf4:	5d7c                	lw	a5,124(a0)
    80000bf6:	c399                	beqz	a5,80000bfc <pop_off+0x2c>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000bf8:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000bfc:	60a2                	ld	ra,8(sp)
    80000bfe:	6402                	ld	s0,0(sp)
    80000c00:	0141                	addi	sp,sp,16
    80000c02:	8082                	ret
    panic("pop_off - interruptible");
    80000c04:	00007517          	auipc	a0,0x7
    80000c08:	44c50513          	addi	a0,a0,1100 # 80008050 <etext+0x50>
    80000c0c:	be5ff0ef          	jal	800007f0 <panic>
    panic("pop_off");
    80000c10:	00007517          	auipc	a0,0x7
    80000c14:	45850513          	addi	a0,a0,1112 # 80008068 <etext+0x68>
    80000c18:	bd9ff0ef          	jal	800007f0 <panic>

0000000080000c1c <release>:
{
    80000c1c:	1101                	addi	sp,sp,-32
    80000c1e:	ec06                	sd	ra,24(sp)
    80000c20:	e822                	sd	s0,16(sp)
    80000c22:	e426                	sd	s1,8(sp)
    80000c24:	1000                	addi	s0,sp,32
    80000c26:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c28:	f09ff0ef          	jal	80000b30 <holding>
    80000c2c:	cd11                	beqz	a0,80000c48 <release+0x2c>
  lk->cpu = 0;
    80000c2e:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000c32:	0310000f          	fence	rw,w
    80000c36:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c3a:	f97ff0ef          	jal	80000bd0 <pop_off>
}
    80000c3e:	60e2                	ld	ra,24(sp)
    80000c40:	6442                	ld	s0,16(sp)
    80000c42:	64a2                	ld	s1,8(sp)
    80000c44:	6105                	addi	sp,sp,32
    80000c46:	8082                	ret
    panic("release");
    80000c48:	00007517          	auipc	a0,0x7
    80000c4c:	42850513          	addi	a0,a0,1064 # 80008070 <etext+0x70>
    80000c50:	ba1ff0ef          	jal	800007f0 <panic>

0000000080000c54 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000c54:	1141                	addi	sp,sp,-16
    80000c56:	e422                	sd	s0,8(sp)
    80000c58:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000c5a:	ca19                	beqz	a2,80000c70 <memset+0x1c>
    80000c5c:	87aa                	mv	a5,a0
    80000c5e:	1602                	slli	a2,a2,0x20
    80000c60:	9201                	srli	a2,a2,0x20
    80000c62:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c66:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000c6a:	0785                	addi	a5,a5,1
    80000c6c:	fee79de3          	bne	a5,a4,80000c66 <memset+0x12>
  }
  return dst;
}
    80000c70:	6422                	ld	s0,8(sp)
    80000c72:	0141                	addi	sp,sp,16
    80000c74:	8082                	ret

0000000080000c76 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c76:	1141                	addi	sp,sp,-16
    80000c78:	e422                	sd	s0,8(sp)
    80000c7a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000c7c:	ca05                	beqz	a2,80000cac <memcmp+0x36>
    80000c7e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000c82:	1682                	slli	a3,a3,0x20
    80000c84:	9281                	srli	a3,a3,0x20
    80000c86:	0685                	addi	a3,a3,1
    80000c88:	96aa                	add	a3,a3,a0
    if (*s1 != *s2)
    80000c8a:	00054783          	lbu	a5,0(a0)
    80000c8e:	0005c703          	lbu	a4,0(a1)
    80000c92:	00e79863          	bne	a5,a4,80000ca2 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c96:	0505                	addi	a0,a0,1
    80000c98:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000c9a:	fed518e3          	bne	a0,a3,80000c8a <memcmp+0x14>
  }

  return 0;
    80000c9e:	4501                	li	a0,0
    80000ca0:	a019                	j	80000ca6 <memcmp+0x30>
      return *s1 - *s2;
    80000ca2:	40e7853b          	subw	a0,a5,a4
}
    80000ca6:	6422                	ld	s0,8(sp)
    80000ca8:	0141                	addi	sp,sp,16
    80000caa:	8082                	ret
  return 0;
    80000cac:	4501                	li	a0,0
    80000cae:	bfe5                	j	80000ca6 <memcmp+0x30>

0000000080000cb0 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000cb0:	1141                	addi	sp,sp,-16
    80000cb2:	e422                	sd	s0,8(sp)
    80000cb4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000cb6:	c205                	beqz	a2,80000cd6 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000cb8:	02a5e263          	bltu	a1,a0,80000cdc <memmove+0x2c>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000cbc:	1602                	slli	a2,a2,0x20
    80000cbe:	9201                	srli	a2,a2,0x20
    80000cc0:	00c587b3          	add	a5,a1,a2
{
    80000cc4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cc6:	0585                	addi	a1,a1,1
    80000cc8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd9551>
    80000cca:	fff5c683          	lbu	a3,-1(a1)
    80000cce:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000cd2:	feb79ae3          	bne	a5,a1,80000cc6 <memmove+0x16>

  return dst;
}
    80000cd6:	6422                	ld	s0,8(sp)
    80000cd8:	0141                	addi	sp,sp,16
    80000cda:	8082                	ret
  if (s < d && s + n > d) {
    80000cdc:	02061693          	slli	a3,a2,0x20
    80000ce0:	9281                	srli	a3,a3,0x20
    80000ce2:	00d58733          	add	a4,a1,a3
    80000ce6:	fce57be3          	bgeu	a0,a4,80000cbc <memmove+0xc>
    d += n;
    80000cea:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000cec:	fff6079b          	addiw	a5,a2,-1
    80000cf0:	1782                	slli	a5,a5,0x20
    80000cf2:	9381                	srli	a5,a5,0x20
    80000cf4:	fff7c793          	not	a5,a5
    80000cf8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000cfa:	177d                	addi	a4,a4,-1
    80000cfc:	16fd                	addi	a3,a3,-1
    80000cfe:	00074603          	lbu	a2,0(a4)
    80000d02:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d06:	fef71ae3          	bne	a4,a5,80000cfa <memmove+0x4a>
    80000d0a:	b7f1                	j	80000cd6 <memmove+0x26>

0000000080000d0c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e406                	sd	ra,8(sp)
    80000d10:	e022                	sd	s0,0(sp)
    80000d12:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d14:	f9dff0ef          	jal	80000cb0 <memmove>
}
    80000d18:	60a2                	ld	ra,8(sp)
    80000d1a:	6402                	ld	s0,0(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret

0000000080000d20 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d20:	1141                	addi	sp,sp,-16
    80000d22:	e422                	sd	s0,8(sp)
    80000d24:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000d26:	ce11                	beqz	a2,80000d42 <strncmp+0x22>
    80000d28:	00054783          	lbu	a5,0(a0)
    80000d2c:	cf89                	beqz	a5,80000d46 <strncmp+0x26>
    80000d2e:	0005c703          	lbu	a4,0(a1)
    80000d32:	00f71a63          	bne	a4,a5,80000d46 <strncmp+0x26>
    n--, p++, q++;
    80000d36:	367d                	addiw	a2,a2,-1
    80000d38:	0505                	addi	a0,a0,1
    80000d3a:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000d3c:	f675                	bnez	a2,80000d28 <strncmp+0x8>
  if (n == 0)
    return 0;
    80000d3e:	4501                	li	a0,0
    80000d40:	a801                	j	80000d50 <strncmp+0x30>
    80000d42:	4501                	li	a0,0
    80000d44:	a031                	j	80000d50 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d46:	00054503          	lbu	a0,0(a0)
    80000d4a:	0005c783          	lbu	a5,0(a1)
    80000d4e:	9d1d                	subw	a0,a0,a5
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000d5c:	87aa                	mv	a5,a0
    80000d5e:	86b2                	mv	a3,a2
    80000d60:	367d                	addiw	a2,a2,-1
    80000d62:	02d05563          	blez	a3,80000d8c <strncpy+0x36>
    80000d66:	0785                	addi	a5,a5,1
    80000d68:	0005c703          	lbu	a4,0(a1)
    80000d6c:	fee78fa3          	sb	a4,-1(a5)
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	f775                	bnez	a4,80000d5e <strncpy+0x8>
    ;
  while (n-- > 0)
    80000d74:	873e                	mv	a4,a5
    80000d76:	9fb5                	addw	a5,a5,a3
    80000d78:	37fd                	addiw	a5,a5,-1
    80000d7a:	00c05963          	blez	a2,80000d8c <strncpy+0x36>
    *s++ = 0;
    80000d7e:	0705                	addi	a4,a4,1
    80000d80:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000d84:	40e786bb          	subw	a3,a5,a4
    80000d88:	fed04be3          	bgtz	a3,80000d7e <strncpy+0x28>
  return os;
}
    80000d8c:	6422                	ld	s0,8(sp)
    80000d8e:	0141                	addi	sp,sp,16
    80000d90:	8082                	ret

0000000080000d92 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e422                	sd	s0,8(sp)
    80000d96:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000d98:	02c05363          	blez	a2,80000dbe <safestrcpy+0x2c>
    80000d9c:	fff6069b          	addiw	a3,a2,-1
    80000da0:	1682                	slli	a3,a3,0x20
    80000da2:	9281                	srli	a3,a3,0x20
    80000da4:	96ae                	add	a3,a3,a1
    80000da6:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000da8:	00d58963          	beq	a1,a3,80000dba <safestrcpy+0x28>
    80000dac:	0585                	addi	a1,a1,1
    80000dae:	0785                	addi	a5,a5,1
    80000db0:	fff5c703          	lbu	a4,-1(a1)
    80000db4:	fee78fa3          	sb	a4,-1(a5)
    80000db8:	fb65                	bnez	a4,80000da8 <safestrcpy+0x16>
    ;
  *s = 0;
    80000dba:	00078023          	sb	zero,0(a5)
  return os;
}
    80000dbe:	6422                	ld	s0,8(sp)
    80000dc0:	0141                	addi	sp,sp,16
    80000dc2:	8082                	ret

0000000080000dc4 <strlen>:

int
strlen(const char *s)
{
    80000dc4:	1141                	addi	sp,sp,-16
    80000dc6:	e422                	sd	s0,8(sp)
    80000dc8:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000dca:	00054783          	lbu	a5,0(a0)
    80000dce:	cf91                	beqz	a5,80000dea <strlen+0x26>
    80000dd0:	0505                	addi	a0,a0,1
    80000dd2:	87aa                	mv	a5,a0
    80000dd4:	86be                	mv	a3,a5
    80000dd6:	0785                	addi	a5,a5,1
    80000dd8:	fff7c703          	lbu	a4,-1(a5)
    80000ddc:	ff65                	bnez	a4,80000dd4 <strlen+0x10>
    80000dde:	40a6853b          	subw	a0,a3,a0
    80000de2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000de4:	6422                	ld	s0,8(sp)
    80000de6:	0141                	addi	sp,sp,16
    80000de8:	8082                	ret
  for (n = 0; s[n]; n++)
    80000dea:	4501                	li	a0,0
    80000dec:	bfe5                	j	80000de4 <strlen+0x20>

0000000080000dee <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000dee:	1141                	addi	sp,sp,-16
    80000df0:	e406                	sd	ra,8(sp)
    80000df2:	e022                	sd	s0,0(sp)
    80000df4:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000df6:	281000ef          	jal	80001876 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000dfa:	0000a717          	auipc	a4,0xa
    80000dfe:	76270713          	addi	a4,a4,1890 # 8000b55c <started>
  if (cpuid() == 0) {
    80000e02:	c51d                	beqz	a0,80000e30 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e04:	431c                	lw	a5,0(a4)
    80000e06:	0230000f          	fence	r,rw
    80000e0a:	2781                	sext.w	a5,a5
    80000e0c:	dfe5                	beqz	a5,80000e04 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000e0e:	269000ef          	jal	80001876 <cpuid>
    80000e12:	85aa                	mv	a1,a0
    80000e14:	00007517          	auipc	a0,0x7
    80000e18:	28450513          	addi	a0,a0,644 # 80008098 <etext+0x98>
    80000e1c:	eeeff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000e20:	082000ef          	jal	80000ea2 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000e24:	011010ef          	jal	80002634 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e28:	571040ef          	jal	80005b98 <plicinithart>
  }

  scheduler();
    80000e2c:	741000ef          	jal	80001d6c <scheduler>
    consoleinit();
    80000e30:	e04ff0ef          	jal	80000434 <consoleinit>
    printkinit();
    80000e34:	9f9ff0ef          	jal	8000082c <printkinit>
    printk("\n");
    80000e38:	00007517          	auipc	a0,0x7
    80000e3c:	24050513          	addi	a0,a0,576 # 80008078 <etext+0x78>
    80000e40:	ecaff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000e44:	00007517          	auipc	a0,0x7
    80000e48:	23c50513          	addi	a0,a0,572 # 80008080 <etext+0x80>
    80000e4c:	ebeff0ef          	jal	8000050a <printk>
    printk("\n");
    80000e50:	00007517          	auipc	a0,0x7
    80000e54:	22850513          	addi	a0,a0,552 # 80008078 <etext+0x78>
    80000e58:	eb2ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000e5c:	c3bff0ef          	jal	80000a96 <kinit>
    kvminit();          // create kernel page table
    80000e60:	2cc000ef          	jal	8000112c <kvminit>
    kvminithart();      // turn on paging
    80000e64:	03e000ef          	jal	80000ea2 <kvminithart>
    procinit();         // process table
    80000e68:	159000ef          	jal	800017c0 <procinit>
    trapinit();         // trap vectors
    80000e6c:	7a4010ef          	jal	80002610 <trapinit>
    trapinithart();     // install kernel trap vector
    80000e70:	7c4010ef          	jal	80002634 <trapinithart>
    plicinit();         // set up interrupt controller
    80000e74:	50b040ef          	jal	80005b7e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000e78:	521040ef          	jal	80005b98 <plicinithart>
    binit();            // buffer cache
    80000e7c:	210020ef          	jal	8000308c <binit>
    iinit();            // inode table
    80000e80:	796020ef          	jal	80003616 <iinit>
    fileinit();         // file table
    80000e84:	786030ef          	jal	8000460a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e88:	601040ef          	jal	80005c88 <virtio_disk_init>
    userinit();         // first user process
    80000e8c:	535000ef          	jal	80001bc0 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000e90:	0000a797          	auipc	a5,0xa
    80000e94:	6cc78793          	addi	a5,a5,1740 # 8000b55c <started>
    80000e98:	4705                	li	a4,1
    80000e9a:	0310000f          	fence	rw,w
    80000e9e:	c398                	sw	a4,0(a5)
    80000ea0:	b771                	j	80000e2c <main+0x3e>

0000000080000ea2 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000ea2:	1141                	addi	sp,sp,-16
    80000ea4:	e422                	sd	s0,8(sp)
    80000ea6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000ea8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000eac:	0000a797          	auipc	a5,0xa
    80000eb0:	6b47b783          	ld	a5,1716(a5) # 8000b560 <kernel_pagetable>
    80000eb4:	83b1                	srli	a5,a5,0xc
    80000eb6:	577d                	li	a4,-1
    80000eb8:	177e                	slli	a4,a4,0x3f
    80000eba:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000ebc:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000ec0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000ec4:	6422                	ld	s0,8(sp)
    80000ec6:	0141                	addi	sp,sp,16
    80000ec8:	8082                	ret

0000000080000eca <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000eca:	7139                	addi	sp,sp,-64
    80000ecc:	fc06                	sd	ra,56(sp)
    80000ece:	f822                	sd	s0,48(sp)
    80000ed0:	f426                	sd	s1,40(sp)
    80000ed2:	f04a                	sd	s2,32(sp)
    80000ed4:	ec4e                	sd	s3,24(sp)
    80000ed6:	e852                	sd	s4,16(sp)
    80000ed8:	e456                	sd	s5,8(sp)
    80000eda:	e05a                	sd	s6,0(sp)
    80000edc:	0080                	addi	s0,sp,64
    80000ede:	84aa                	mv	s1,a0
    80000ee0:	89ae                	mv	s3,a1
    80000ee2:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000ee4:	57fd                	li	a5,-1
    80000ee6:	83e9                	srli	a5,a5,0x1a
    80000ee8:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000eea:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000eec:	02b7fc63          	bgeu	a5,a1,80000f24 <walk+0x5a>
    panic("walk");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1c050513          	addi	a0,a0,448 # 800080b0 <etext+0xb0>
    80000ef8:	8f9ff0ef          	jal	800007f0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if (*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000efc:	060a8263          	beqz	s5,80000f60 <walk+0x96>
    80000f00:	bcbff0ef          	jal	80000aca <kalloc>
    80000f04:	84aa                	mv	s1,a0
    80000f06:	c139                	beqz	a0,80000f4c <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f08:	6605                	lui	a2,0x1
    80000f0a:	4581                	li	a1,0
    80000f0c:	d49ff0ef          	jal	80000c54 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f10:	00c4d793          	srli	a5,s1,0xc
    80000f14:	07aa                	slli	a5,a5,0xa
    80000f16:	0017e793          	ori	a5,a5,1
    80000f1a:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--) {
    80000f1e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd9547>
    80000f20:	036a0063          	beq	s4,s6,80000f40 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f24:	0149d933          	srl	s2,s3,s4
    80000f28:	1ff97913          	andi	s2,s2,511
    80000f2c:	090e                	slli	s2,s2,0x3
    80000f2e:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f30:	00093483          	ld	s1,0(s2)
    80000f34:	0014f793          	andi	a5,s1,1
    80000f38:	d3f1                	beqz	a5,80000efc <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f3a:	80a9                	srli	s1,s1,0xa
    80000f3c:	04b2                	slli	s1,s1,0xc
    80000f3e:	b7c5                	j	80000f1e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f40:	00c9d513          	srli	a0,s3,0xc
    80000f44:	1ff57513          	andi	a0,a0,511
    80000f48:	050e                	slli	a0,a0,0x3
    80000f4a:	9526                	add	a0,a0,s1
}
    80000f4c:	70e2                	ld	ra,56(sp)
    80000f4e:	7442                	ld	s0,48(sp)
    80000f50:	74a2                	ld	s1,40(sp)
    80000f52:	7902                	ld	s2,32(sp)
    80000f54:	69e2                	ld	s3,24(sp)
    80000f56:	6a42                	ld	s4,16(sp)
    80000f58:	6aa2                	ld	s5,8(sp)
    80000f5a:	6b02                	ld	s6,0(sp)
    80000f5c:	6121                	addi	sp,sp,64
    80000f5e:	8082                	ret
        return 0;
    80000f60:	4501                	li	a0,0
    80000f62:	b7ed                	j	80000f4c <walk+0x82>

0000000080000f64 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000f64:	57fd                	li	a5,-1
    80000f66:	83e9                	srli	a5,a5,0x1a
    80000f68:	00b7f463          	bgeu	a5,a1,80000f70 <walkaddr+0xc>
    return 0;
    80000f6c:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f6e:	8082                	ret
{
    80000f70:	1141                	addi	sp,sp,-16
    80000f72:	e406                	sd	ra,8(sp)
    80000f74:	e022                	sd	s0,0(sp)
    80000f76:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f78:	4601                	li	a2,0
    80000f7a:	f51ff0ef          	jal	80000eca <walk>
  if (pte == 0)
    80000f7e:	c105                	beqz	a0,80000f9e <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    80000f80:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80000f82:	0117f693          	andi	a3,a5,17
    80000f86:	4745                	li	a4,17
    return 0;
    80000f88:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000f8a:	00e68663          	beq	a3,a4,80000f96 <walkaddr+0x32>
}
    80000f8e:	60a2                	ld	ra,8(sp)
    80000f90:	6402                	ld	s0,0(sp)
    80000f92:	0141                	addi	sp,sp,16
    80000f94:	8082                	ret
  pa = PTE2PA(*pte);
    80000f96:	83a9                	srli	a5,a5,0xa
    80000f98:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000f9c:	bfcd                	j	80000f8e <walkaddr+0x2a>
    return 0;
    80000f9e:	4501                	li	a0,0
    80000fa0:	b7fd                	j	80000f8e <walkaddr+0x2a>

0000000080000fa2 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fa2:	715d                	addi	sp,sp,-80
    80000fa4:	e486                	sd	ra,72(sp)
    80000fa6:	e0a2                	sd	s0,64(sp)
    80000fa8:	fc26                	sd	s1,56(sp)
    80000faa:	f84a                	sd	s2,48(sp)
    80000fac:	f44e                	sd	s3,40(sp)
    80000fae:	f052                	sd	s4,32(sp)
    80000fb0:	ec56                	sd	s5,24(sp)
    80000fb2:	e85a                	sd	s6,16(sp)
    80000fb4:	e45e                	sd	s7,8(sp)
    80000fb6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80000fb8:	03459793          	slli	a5,a1,0x34
    80000fbc:	e7a9                	bnez	a5,80001006 <mappages+0x64>
    80000fbe:	8aaa                	mv	s5,a0
    80000fc0:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80000fc2:	03461793          	slli	a5,a2,0x34
    80000fc6:	e7b1                	bnez	a5,80001012 <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    80000fc8:	ca39                	beqz	a2,8000101e <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    80000fca:	77fd                	lui	a5,0xfffff
    80000fcc:	963e                	add	a2,a2,a5
    80000fce:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fd2:	892e                	mv	s2,a1
    80000fd4:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80000fd8:	6b85                	lui	s7,0x1
    80000fda:	014904b3          	add	s1,s2,s4
    if ((pte = walk(pagetable, a, 1)) == 0)
    80000fde:	4605                	li	a2,1
    80000fe0:	85ca                	mv	a1,s2
    80000fe2:	8556                	mv	a0,s5
    80000fe4:	ee7ff0ef          	jal	80000eca <walk>
    80000fe8:	c539                	beqz	a0,80001036 <mappages+0x94>
    if (*pte & PTE_V)
    80000fea:	611c                	ld	a5,0(a0)
    80000fec:	8b85                	andi	a5,a5,1
    80000fee:	ef95                	bnez	a5,8000102a <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000ff0:	80b1                	srli	s1,s1,0xc
    80000ff2:	04aa                	slli	s1,s1,0xa
    80000ff4:	0164e4b3          	or	s1,s1,s6
    80000ff8:	0014e493          	ori	s1,s1,1
    80000ffc:	e104                	sd	s1,0(a0)
    if (a == last)
    80000ffe:	05390863          	beq	s2,s3,8000104e <mappages+0xac>
    a += PGSIZE;
    80001002:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001004:	bfd9                	j	80000fda <mappages+0x38>
    panic("mappages: va not aligned");
    80001006:	00007517          	auipc	a0,0x7
    8000100a:	0b250513          	addi	a0,a0,178 # 800080b8 <etext+0xb8>
    8000100e:	fe2ff0ef          	jal	800007f0 <panic>
    panic("mappages: size not aligned");
    80001012:	00007517          	auipc	a0,0x7
    80001016:	0c650513          	addi	a0,a0,198 # 800080d8 <etext+0xd8>
    8000101a:	fd6ff0ef          	jal	800007f0 <panic>
    panic("mappages: size");
    8000101e:	00007517          	auipc	a0,0x7
    80001022:	0da50513          	addi	a0,a0,218 # 800080f8 <etext+0xf8>
    80001026:	fcaff0ef          	jal	800007f0 <panic>
      panic("mappages: remap");
    8000102a:	00007517          	auipc	a0,0x7
    8000102e:	0de50513          	addi	a0,a0,222 # 80008108 <etext+0x108>
    80001032:	fbeff0ef          	jal	800007f0 <panic>
      return -1;
    80001036:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001038:	60a6                	ld	ra,72(sp)
    8000103a:	6406                	ld	s0,64(sp)
    8000103c:	74e2                	ld	s1,56(sp)
    8000103e:	7942                	ld	s2,48(sp)
    80001040:	79a2                	ld	s3,40(sp)
    80001042:	7a02                	ld	s4,32(sp)
    80001044:	6ae2                	ld	s5,24(sp)
    80001046:	6b42                	ld	s6,16(sp)
    80001048:	6ba2                	ld	s7,8(sp)
    8000104a:	6161                	addi	sp,sp,80
    8000104c:	8082                	ret
  return 0;
    8000104e:	4501                	li	a0,0
    80001050:	b7e5                	j	80001038 <mappages+0x96>

0000000080001052 <kvmmap>:
{
    80001052:	1141                	addi	sp,sp,-16
    80001054:	e406                	sd	ra,8(sp)
    80001056:	e022                	sd	s0,0(sp)
    80001058:	0800                	addi	s0,sp,16
    8000105a:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000105c:	86b2                	mv	a3,a2
    8000105e:	863e                	mv	a2,a5
    80001060:	f43ff0ef          	jal	80000fa2 <mappages>
    80001064:	e509                	bnez	a0,8000106e <kvmmap+0x1c>
}
    80001066:	60a2                	ld	ra,8(sp)
    80001068:	6402                	ld	s0,0(sp)
    8000106a:	0141                	addi	sp,sp,16
    8000106c:	8082                	ret
    panic("kvmmap");
    8000106e:	00007517          	auipc	a0,0x7
    80001072:	0aa50513          	addi	a0,a0,170 # 80008118 <etext+0x118>
    80001076:	f7aff0ef          	jal	800007f0 <panic>

000000008000107a <kvmmake>:
{
    8000107a:	1101                	addi	sp,sp,-32
    8000107c:	ec06                	sd	ra,24(sp)
    8000107e:	e822                	sd	s0,16(sp)
    80001080:	e426                	sd	s1,8(sp)
    80001082:	e04a                	sd	s2,0(sp)
    80001084:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80001086:	a45ff0ef          	jal	80000aca <kalloc>
    8000108a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000108c:	6605                	lui	a2,0x1
    8000108e:	4581                	li	a1,0
    80001090:	bc5ff0ef          	jal	80000c54 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001094:	4719                	li	a4,6
    80001096:	6685                	lui	a3,0x1
    80001098:	10000637          	lui	a2,0x10000
    8000109c:	100005b7          	lui	a1,0x10000
    800010a0:	8526                	mv	a0,s1
    800010a2:	fb1ff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010a6:	4719                	li	a4,6
    800010a8:	6685                	lui	a3,0x1
    800010aa:	10001637          	lui	a2,0x10001
    800010ae:	100015b7          	lui	a1,0x10001
    800010b2:	8526                	mv	a0,s1
    800010b4:	f9fff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010b8:	4719                	li	a4,6
    800010ba:	040006b7          	lui	a3,0x4000
    800010be:	0c000637          	lui	a2,0xc000
    800010c2:	0c0005b7          	lui	a1,0xc000
    800010c6:	8526                	mv	a0,s1
    800010c8:	f8bff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800010cc:	00007917          	auipc	s2,0x7
    800010d0:	f3490913          	addi	s2,s2,-204 # 80008000 <etext>
    800010d4:	4729                	li	a4,10
    800010d6:	80007697          	auipc	a3,0x80007
    800010da:	f2a68693          	addi	a3,a3,-214 # 8000 <_entry-0x7fff8000>
    800010de:	4605                	li	a2,1
    800010e0:	067e                	slli	a2,a2,0x1f
    800010e2:	85b2                	mv	a1,a2
    800010e4:	8526                	mv	a0,s1
    800010e6:	f6dff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    800010ea:	46c5                	li	a3,17
    800010ec:	06ee                	slli	a3,a3,0x1b
    800010ee:	4719                	li	a4,6
    800010f0:	412686b3          	sub	a3,a3,s2
    800010f4:	864a                	mv	a2,s2
    800010f6:	85ca                	mv	a1,s2
    800010f8:	8526                	mv	a0,s1
    800010fa:	f59ff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800010fe:	4729                	li	a4,10
    80001100:	6685                	lui	a3,0x1
    80001102:	00006617          	auipc	a2,0x6
    80001106:	efe60613          	addi	a2,a2,-258 # 80007000 <_trampoline>
    8000110a:	040005b7          	lui	a1,0x4000
    8000110e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001110:	05b2                	slli	a1,a1,0xc
    80001112:	8526                	mv	a0,s1
    80001114:	f3fff0ef          	jal	80001052 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001118:	8526                	mv	a0,s1
    8000111a:	60e000ef          	jal	80001728 <proc_mapstacks>
}
    8000111e:	8526                	mv	a0,s1
    80001120:	60e2                	ld	ra,24(sp)
    80001122:	6442                	ld	s0,16(sp)
    80001124:	64a2                	ld	s1,8(sp)
    80001126:	6902                	ld	s2,0(sp)
    80001128:	6105                	addi	sp,sp,32
    8000112a:	8082                	ret

000000008000112c <kvminit>:
{
    8000112c:	1141                	addi	sp,sp,-16
    8000112e:	e406                	sd	ra,8(sp)
    80001130:	e022                	sd	s0,0(sp)
    80001132:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001134:	f47ff0ef          	jal	8000107a <kvmmake>
    80001138:	0000a797          	auipc	a5,0xa
    8000113c:	42a7b423          	sd	a0,1064(a5) # 8000b560 <kernel_pagetable>
}
    80001140:	60a2                	ld	ra,8(sp)
    80001142:	6402                	ld	s0,0(sp)
    80001144:	0141                	addi	sp,sp,16
    80001146:	8082                	ret

0000000080001148 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001148:	1101                	addi	sp,sp,-32
    8000114a:	ec06                	sd	ra,24(sp)
    8000114c:	e822                	sd	s0,16(sp)
    8000114e:	e426                	sd	s1,8(sp)
    80001150:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001152:	979ff0ef          	jal	80000aca <kalloc>
    80001156:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001158:	c509                	beqz	a0,80001162 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000115a:	6605                	lui	a2,0x1
    8000115c:	4581                	li	a1,0
    8000115e:	af7ff0ef          	jal	80000c54 <memset>
  return pagetable;
}
    80001162:	8526                	mv	a0,s1
    80001164:	60e2                	ld	ra,24(sp)
    80001166:	6442                	ld	s0,16(sp)
    80001168:	64a2                	ld	s1,8(sp)
    8000116a:	6105                	addi	sp,sp,32
    8000116c:	8082                	ret

000000008000116e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000116e:	7139                	addi	sp,sp,-64
    80001170:	fc06                	sd	ra,56(sp)
    80001172:	f822                	sd	s0,48(sp)
    80001174:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001176:	03459793          	slli	a5,a1,0x34
    8000117a:	e38d                	bnez	a5,8000119c <uvmunmap+0x2e>
    8000117c:	f04a                	sd	s2,32(sp)
    8000117e:	ec4e                	sd	s3,24(sp)
    80001180:	e852                	sd	s4,16(sp)
    80001182:	e456                	sd	s5,8(sp)
    80001184:	e05a                	sd	s6,0(sp)
    80001186:	8a2a                	mv	s4,a0
    80001188:	892e                	mv	s2,a1
    8000118a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000118c:	0632                	slli	a2,a2,0xc
    8000118e:	00b609b3          	add	s3,a2,a1
    80001192:	6b05                	lui	s6,0x1
    80001194:	0535f963          	bgeu	a1,s3,800011e6 <uvmunmap+0x78>
    80001198:	f426                	sd	s1,40(sp)
    8000119a:	a015                	j	800011be <uvmunmap+0x50>
    8000119c:	f426                	sd	s1,40(sp)
    8000119e:	f04a                	sd	s2,32(sp)
    800011a0:	ec4e                	sd	s3,24(sp)
    800011a2:	e852                	sd	s4,16(sp)
    800011a4:	e456                	sd	s5,8(sp)
    800011a6:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011a8:	00007517          	auipc	a0,0x7
    800011ac:	f7850513          	addi	a0,a0,-136 # 80008120 <etext+0x120>
    800011b0:	e40ff0ef          	jal	800007f0 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    800011b4:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011b8:	995a                	add	s2,s2,s6
    800011ba:	03397563          	bgeu	s2,s3,800011e4 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011be:	4601                	li	a2,0
    800011c0:	85ca                	mv	a1,s2
    800011c2:	8552                	mv	a0,s4
    800011c4:	d07ff0ef          	jal	80000eca <walk>
    800011c8:	84aa                	mv	s1,a0
    800011ca:	d57d                	beqz	a0,800011b8 <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    800011cc:	611c                	ld	a5,0(a0)
    800011ce:	0017f713          	andi	a4,a5,1
    800011d2:	d37d                	beqz	a4,800011b8 <uvmunmap+0x4a>
    if (do_free) {
    800011d4:	fe0a80e3          	beqz	s5,800011b4 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800011d8:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    800011da:	00c79513          	slli	a0,a5,0xc
    800011de:	80bff0ef          	jal	800009e8 <kfree>
    800011e2:	bfc9                	j	800011b4 <uvmunmap+0x46>
    800011e4:	74a2                	ld	s1,40(sp)
    800011e6:	7902                	ld	s2,32(sp)
    800011e8:	69e2                	ld	s3,24(sp)
    800011ea:	6a42                	ld	s4,16(sp)
    800011ec:	6aa2                	ld	s5,8(sp)
    800011ee:	6b02                	ld	s6,0(sp)
  }
}
    800011f0:	70e2                	ld	ra,56(sp)
    800011f2:	7442                	ld	s0,48(sp)
    800011f4:	6121                	addi	sp,sp,64
    800011f6:	8082                	ret

00000000800011f8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800011f8:	1101                	addi	sp,sp,-32
    800011fa:	ec06                	sd	ra,24(sp)
    800011fc:	e822                	sd	s0,16(sp)
    800011fe:	e426                	sd	s1,8(sp)
    80001200:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001202:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001204:	00b67d63          	bgeu	a2,a1,8000121e <uvmdealloc+0x26>
    80001208:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    8000120a:	6785                	lui	a5,0x1
    8000120c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000120e:	00f60733          	add	a4,a2,a5
    80001212:	76fd                	lui	a3,0xfffff
    80001214:	8f75                	and	a4,a4,a3
    80001216:	97ae                	add	a5,a5,a1
    80001218:	8ff5                	and	a5,a5,a3
    8000121a:	00f76863          	bltu	a4,a5,8000122a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000121e:	8526                	mv	a0,s1
    80001220:	60e2                	ld	ra,24(sp)
    80001222:	6442                	ld	s0,16(sp)
    80001224:	64a2                	ld	s1,8(sp)
    80001226:	6105                	addi	sp,sp,32
    80001228:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000122a:	8f99                	sub	a5,a5,a4
    8000122c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000122e:	4685                	li	a3,1
    80001230:	0007861b          	sext.w	a2,a5
    80001234:	85ba                	mv	a1,a4
    80001236:	f39ff0ef          	jal	8000116e <uvmunmap>
    8000123a:	b7d5                	j	8000121e <uvmdealloc+0x26>

000000008000123c <uvmalloc>:
  if (newsz < oldsz)
    8000123c:	08b66f63          	bltu	a2,a1,800012da <uvmalloc+0x9e>
{
    80001240:	7139                	addi	sp,sp,-64
    80001242:	fc06                	sd	ra,56(sp)
    80001244:	f822                	sd	s0,48(sp)
    80001246:	ec4e                	sd	s3,24(sp)
    80001248:	e852                	sd	s4,16(sp)
    8000124a:	e456                	sd	s5,8(sp)
    8000124c:	0080                	addi	s0,sp,64
    8000124e:	8aaa                	mv	s5,a0
    80001250:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001252:	6785                	lui	a5,0x1
    80001254:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001256:	95be                	add	a1,a1,a5
    80001258:	77fd                	lui	a5,0xfffff
    8000125a:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE) {
    8000125e:	08c9f063          	bgeu	s3,a2,800012de <uvmalloc+0xa2>
    80001262:	f426                	sd	s1,40(sp)
    80001264:	f04a                	sd	s2,32(sp)
    80001266:	e05a                	sd	s6,0(sp)
    80001268:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    8000126a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000126e:	85dff0ef          	jal	80000aca <kalloc>
    80001272:	84aa                	mv	s1,a0
    if (mem == 0) {
    80001274:	c515                	beqz	a0,800012a0 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001276:	6605                	lui	a2,0x1
    80001278:	4581                	li	a1,0
    8000127a:	9dbff0ef          	jal	80000c54 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    8000127e:	875a                	mv	a4,s6
    80001280:	86a6                	mv	a3,s1
    80001282:	6605                	lui	a2,0x1
    80001284:	85ca                	mv	a1,s2
    80001286:	8556                	mv	a0,s5
    80001288:	d1bff0ef          	jal	80000fa2 <mappages>
    8000128c:	e915                	bnez	a0,800012c0 <uvmalloc+0x84>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    8000128e:	6785                	lui	a5,0x1
    80001290:	993e                	add	s2,s2,a5
    80001292:	fd496ee3          	bltu	s2,s4,8000126e <uvmalloc+0x32>
  return newsz;
    80001296:	8552                	mv	a0,s4
    80001298:	74a2                	ld	s1,40(sp)
    8000129a:	7902                	ld	s2,32(sp)
    8000129c:	6b02                	ld	s6,0(sp)
    8000129e:	a811                	j	800012b2 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012a0:	864e                	mv	a2,s3
    800012a2:	85ca                	mv	a1,s2
    800012a4:	8556                	mv	a0,s5
    800012a6:	f53ff0ef          	jal	800011f8 <uvmdealloc>
      return 0;
    800012aa:	4501                	li	a0,0
    800012ac:	74a2                	ld	s1,40(sp)
    800012ae:	7902                	ld	s2,32(sp)
    800012b0:	6b02                	ld	s6,0(sp)
}
    800012b2:	70e2                	ld	ra,56(sp)
    800012b4:	7442                	ld	s0,48(sp)
    800012b6:	69e2                	ld	s3,24(sp)
    800012b8:	6a42                	ld	s4,16(sp)
    800012ba:	6aa2                	ld	s5,8(sp)
    800012bc:	6121                	addi	sp,sp,64
    800012be:	8082                	ret
      kfree(mem);
    800012c0:	8526                	mv	a0,s1
    800012c2:	f26ff0ef          	jal	800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012c6:	864e                	mv	a2,s3
    800012c8:	85ca                	mv	a1,s2
    800012ca:	8556                	mv	a0,s5
    800012cc:	f2dff0ef          	jal	800011f8 <uvmdealloc>
      return 0;
    800012d0:	4501                	li	a0,0
    800012d2:	74a2                	ld	s1,40(sp)
    800012d4:	7902                	ld	s2,32(sp)
    800012d6:	6b02                	ld	s6,0(sp)
    800012d8:	bfe9                	j	800012b2 <uvmalloc+0x76>
    return oldsz;
    800012da:	852e                	mv	a0,a1
}
    800012dc:	8082                	ret
  return newsz;
    800012de:	8532                	mv	a0,a2
    800012e0:	bfc9                	j	800012b2 <uvmalloc+0x76>

00000000800012e2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012e2:	7179                	addi	sp,sp,-48
    800012e4:	f406                	sd	ra,40(sp)
    800012e6:	f022                	sd	s0,32(sp)
    800012e8:	ec26                	sd	s1,24(sp)
    800012ea:	e84a                	sd	s2,16(sp)
    800012ec:	e44e                	sd	s3,8(sp)
    800012ee:	e052                	sd	s4,0(sp)
    800012f0:	1800                	addi	s0,sp,48
    800012f2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    800012f4:	84aa                	mv	s1,a0
    800012f6:	6905                	lui	s2,0x1
    800012f8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800012fa:	4985                	li	s3,1
    800012fc:	a819                	j	80001312 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012fe:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001300:	00c79513          	slli	a0,a5,0xc
    80001304:	fdfff0ef          	jal	800012e2 <freewalk>
      pagetable[i] = 0;
    80001308:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++) {
    8000130c:	04a1                	addi	s1,s1,8
    8000130e:	01248f63          	beq	s1,s2,8000132c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001312:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001314:	00f7f713          	andi	a4,a5,15
    80001318:	ff3703e3          	beq	a4,s3,800012fe <freewalk+0x1c>
    } else if (pte & PTE_V) {
    8000131c:	8b85                	andi	a5,a5,1
    8000131e:	d7fd                	beqz	a5,8000130c <freewalk+0x2a>
      panic("freewalk: leaf");
    80001320:	00007517          	auipc	a0,0x7
    80001324:	e1850513          	addi	a0,a0,-488 # 80008138 <etext+0x138>
    80001328:	cc8ff0ef          	jal	800007f0 <panic>
    }
  }
  kfree((void *)pagetable);
    8000132c:	8552                	mv	a0,s4
    8000132e:	ebaff0ef          	jal	800009e8 <kfree>
}
    80001332:	70a2                	ld	ra,40(sp)
    80001334:	7402                	ld	s0,32(sp)
    80001336:	64e2                	ld	s1,24(sp)
    80001338:	6942                	ld	s2,16(sp)
    8000133a:	69a2                	ld	s3,8(sp)
    8000133c:	6a02                	ld	s4,0(sp)
    8000133e:	6145                	addi	sp,sp,48
    80001340:	8082                	ret

0000000080001342 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001342:	1101                	addi	sp,sp,-32
    80001344:	ec06                	sd	ra,24(sp)
    80001346:	e822                	sd	s0,16(sp)
    80001348:	e426                	sd	s1,8(sp)
    8000134a:	1000                	addi	s0,sp,32
    8000134c:	84aa                	mv	s1,a0
  if (sz > 0)
    8000134e:	e989                	bnez	a1,80001360 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001350:	8526                	mv	a0,s1
    80001352:	f91ff0ef          	jal	800012e2 <freewalk>
}
    80001356:	60e2                	ld	ra,24(sp)
    80001358:	6442                	ld	s0,16(sp)
    8000135a:	64a2                	ld	s1,8(sp)
    8000135c:	6105                	addi	sp,sp,32
    8000135e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001360:	6785                	lui	a5,0x1
    80001362:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001364:	95be                	add	a1,a1,a5
    80001366:	4685                	li	a3,1
    80001368:	00c5d613          	srli	a2,a1,0xc
    8000136c:	4581                	li	a1,0
    8000136e:	e01ff0ef          	jal	8000116e <uvmunmap>
    80001372:	bff9                	j	80001350 <uvmfree+0xe>

0000000080001374 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    80001374:	ce49                	beqz	a2,8000140e <uvmcopy+0x9a>
{
    80001376:	715d                	addi	sp,sp,-80
    80001378:	e486                	sd	ra,72(sp)
    8000137a:	e0a2                	sd	s0,64(sp)
    8000137c:	fc26                	sd	s1,56(sp)
    8000137e:	f84a                	sd	s2,48(sp)
    80001380:	f44e                	sd	s3,40(sp)
    80001382:	f052                	sd	s4,32(sp)
    80001384:	ec56                	sd	s5,24(sp)
    80001386:	e85a                	sd	s6,16(sp)
    80001388:	e45e                	sd	s7,8(sp)
    8000138a:	0880                	addi	s0,sp,80
    8000138c:	8aaa                	mv	s5,a0
    8000138e:	8b2e                	mv	s6,a1
    80001390:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001392:	4481                	li	s1,0
    80001394:	a029                	j	8000139e <uvmcopy+0x2a>
    80001396:	6785                	lui	a5,0x1
    80001398:	94be                	add	s1,s1,a5
    8000139a:	0544fe63          	bgeu	s1,s4,800013f6 <uvmcopy+0x82>
    if ((pte = walk(old, i, 0)) == 0)
    8000139e:	4601                	li	a2,0
    800013a0:	85a6                	mv	a1,s1
    800013a2:	8556                	mv	a0,s5
    800013a4:	b27ff0ef          	jal	80000eca <walk>
    800013a8:	d57d                	beqz	a0,80001396 <uvmcopy+0x22>
      continue; // page table entry hasn't been allocated
    if ((*pte & PTE_V) == 0)
    800013aa:	6118                	ld	a4,0(a0)
    800013ac:	00177793          	andi	a5,a4,1
    800013b0:	d3fd                	beqz	a5,80001396 <uvmcopy+0x22>
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013b2:	00a75593          	srli	a1,a4,0xa
    800013b6:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800013ba:	3ff77913          	andi	s2,a4,1023
    if ((mem = kalloc()) == 0)
    800013be:	f0cff0ef          	jal	80000aca <kalloc>
    800013c2:	89aa                	mv	s3,a0
    800013c4:	c105                	beqz	a0,800013e4 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    800013c6:	6605                	lui	a2,0x1
    800013c8:	85de                	mv	a1,s7
    800013ca:	8e7ff0ef          	jal	80000cb0 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    800013ce:	874a                	mv	a4,s2
    800013d0:	86ce                	mv	a3,s3
    800013d2:	6605                	lui	a2,0x1
    800013d4:	85a6                	mv	a1,s1
    800013d6:	855a                	mv	a0,s6
    800013d8:	bcbff0ef          	jal	80000fa2 <mappages>
    800013dc:	dd4d                	beqz	a0,80001396 <uvmcopy+0x22>
      kfree(mem);
    800013de:	854e                	mv	a0,s3
    800013e0:	e08ff0ef          	jal	800009e8 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800013e4:	4685                	li	a3,1
    800013e6:	00c4d613          	srli	a2,s1,0xc
    800013ea:	4581                	li	a1,0
    800013ec:	855a                	mv	a0,s6
    800013ee:	d81ff0ef          	jal	8000116e <uvmunmap>
  return -1;
    800013f2:	557d                	li	a0,-1
    800013f4:	a011                	j	800013f8 <uvmcopy+0x84>
  return 0;
    800013f6:	4501                	li	a0,0
}
    800013f8:	60a6                	ld	ra,72(sp)
    800013fa:	6406                	ld	s0,64(sp)
    800013fc:	74e2                	ld	s1,56(sp)
    800013fe:	7942                	ld	s2,48(sp)
    80001400:	79a2                	ld	s3,40(sp)
    80001402:	7a02                	ld	s4,32(sp)
    80001404:	6ae2                	ld	s5,24(sp)
    80001406:	6b42                	ld	s6,16(sp)
    80001408:	6ba2                	ld	s7,8(sp)
    8000140a:	6161                	addi	sp,sp,80
    8000140c:	8082                	ret
  return 0;
    8000140e:	4501                	li	a0,0
}
    80001410:	8082                	ret

0000000080001412 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001412:	1141                	addi	sp,sp,-16
    80001414:	e406                	sd	ra,8(sp)
    80001416:	e022                	sd	s0,0(sp)
    80001418:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    8000141a:	4601                	li	a2,0
    8000141c:	aafff0ef          	jal	80000eca <walk>
  if (pte == 0)
    80001420:	c901                	beqz	a0,80001430 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001422:	611c                	ld	a5,0(a0)
    80001424:	9bbd                	andi	a5,a5,-17
    80001426:	e11c                	sd	a5,0(a0)
}
    80001428:	60a2                	ld	ra,8(sp)
    8000142a:	6402                	ld	s0,0(sp)
    8000142c:	0141                	addi	sp,sp,16
    8000142e:	8082                	ret
    panic("uvmclear");
    80001430:	00007517          	auipc	a0,0x7
    80001434:	d1850513          	addi	a0,a0,-744 # 80008148 <etext+0x148>
    80001438:	bb8ff0ef          	jal	800007f0 <panic>

000000008000143c <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000143c:	1141                	addi	sp,sp,-16
    8000143e:	e406                	sd	ra,8(sp)
    80001440:	e022                	sd	s0,0(sp)
    80001442:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001444:	4601                	li	a2,0
    80001446:	a85ff0ef          	jal	80000eca <walk>
  if (pte == 0) {
    8000144a:	c519                	beqz	a0,80001458 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V) {
    8000144c:	6108                	ld	a0,0(a0)
    8000144e:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001450:	60a2                	ld	ra,8(sp)
    80001452:	6402                	ld	s0,0(sp)
    80001454:	0141                	addi	sp,sp,16
    80001456:	8082                	ret
    return 0;
    80001458:	4501                	li	a0,0
    8000145a:	bfdd                	j	80001450 <ismapped+0x14>

000000008000145c <vmfault>:
{
    8000145c:	7179                	addi	sp,sp,-48
    8000145e:	f406                	sd	ra,40(sp)
    80001460:	f022                	sd	s0,32(sp)
    80001462:	e44e                	sd	s3,8(sp)
    80001464:	1800                	addi	s0,sp,48
    return 0;
    80001466:	4981                	li	s3,0
  if (va >= psz)
    80001468:	00b66863          	bltu	a2,a1,80001478 <vmfault+0x1c>
}
    8000146c:	854e                	mv	a0,s3
    8000146e:	70a2                	ld	ra,40(sp)
    80001470:	7402                	ld	s0,32(sp)
    80001472:	69a2                	ld	s3,8(sp)
    80001474:	6145                	addi	sp,sp,48
    80001476:	8082                	ret
    80001478:	ec26                	sd	s1,24(sp)
    8000147a:	e84a                	sd	s2,16(sp)
    8000147c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000147e:	77fd                	lui	a5,0xfffff
    80001480:	00f674b3          	and	s1,a2,a5
  if (ismapped(pagetable, va)) {
    80001484:	85a6                	mv	a1,s1
    80001486:	fb7ff0ef          	jal	8000143c <ismapped>
    return 0;
    8000148a:	4981                	li	s3,0
  if (ismapped(pagetable, va)) {
    8000148c:	c501                	beqz	a0,80001494 <vmfault+0x38>
    8000148e:	64e2                	ld	s1,24(sp)
    80001490:	6942                	ld	s2,16(sp)
    80001492:	bfe9                	j	8000146c <vmfault+0x10>
    80001494:	e052                	sd	s4,0(sp)
  mem = (uint64)kalloc();
    80001496:	e34ff0ef          	jal	80000aca <kalloc>
    8000149a:	8a2a                	mv	s4,a0
  if (mem == 0)
    8000149c:	c915                	beqz	a0,800014d0 <vmfault+0x74>
  mem = (uint64)kalloc();
    8000149e:	89aa                	mv	s3,a0
  memset((void *)mem, 0, PGSIZE);
    800014a0:	6605                	lui	a2,0x1
    800014a2:	4581                	li	a1,0
    800014a4:	fb0ff0ef          	jal	80000c54 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    800014a8:	4759                	li	a4,22
    800014aa:	86d2                	mv	a3,s4
    800014ac:	6605                	lui	a2,0x1
    800014ae:	85a6                	mv	a1,s1
    800014b0:	854a                	mv	a0,s2
    800014b2:	af1ff0ef          	jal	80000fa2 <mappages>
    800014b6:	e509                	bnez	a0,800014c0 <vmfault+0x64>
    800014b8:	64e2                	ld	s1,24(sp)
    800014ba:	6942                	ld	s2,16(sp)
    800014bc:	6a02                	ld	s4,0(sp)
    800014be:	b77d                	j	8000146c <vmfault+0x10>
    kfree((void *)mem);
    800014c0:	8552                	mv	a0,s4
    800014c2:	d26ff0ef          	jal	800009e8 <kfree>
    return 0;
    800014c6:	4981                	li	s3,0
    800014c8:	64e2                	ld	s1,24(sp)
    800014ca:	6942                	ld	s2,16(sp)
    800014cc:	6a02                	ld	s4,0(sp)
    800014ce:	bf79                	j	8000146c <vmfault+0x10>
    800014d0:	64e2                	ld	s1,24(sp)
    800014d2:	6942                	ld	s2,16(sp)
    800014d4:	6a02                	ld	s4,0(sp)
    800014d6:	bf59                	j	8000146c <vmfault+0x10>

00000000800014d8 <copyout>:
  while (len > 0) {
    800014d8:	c745                	beqz	a4,80001580 <copyout+0xa8>
{
    800014da:	7159                	addi	sp,sp,-112
    800014dc:	f486                	sd	ra,104(sp)
    800014de:	f0a2                	sd	s0,96(sp)
    800014e0:	eca6                	sd	s1,88(sp)
    800014e2:	e0d2                	sd	s4,64(sp)
    800014e4:	f85a                	sd	s6,48(sp)
    800014e6:	f45e                	sd	s7,40(sp)
    800014e8:	f062                	sd	s8,32(sp)
    800014ea:	e46e                	sd	s11,8(sp)
    800014ec:	1880                	addi	s0,sp,112
    800014ee:	8c2a                	mv	s8,a0
    800014f0:	8dae                	mv	s11,a1
    800014f2:	8b32                	mv	s6,a2
    800014f4:	8bb6                	mv	s7,a3
    800014f6:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(dstva);
    800014f8:	74fd                	lui	s1,0xfffff
    800014fa:	8cf1                	and	s1,s1,a2
    if (va0 >= MAXVA)
    800014fc:	57fd                	li	a5,-1
    800014fe:	83e9                	srli	a5,a5,0x1a
    80001500:	0897e263          	bltu	a5,s1,80001584 <copyout+0xac>
    80001504:	e8ca                	sd	s2,80(sp)
    80001506:	e4ce                	sd	s3,72(sp)
    80001508:	fc56                	sd	s5,56(sp)
    8000150a:	ec66                	sd	s9,24(sp)
    8000150c:	e86a                	sd	s10,16(sp)
    8000150e:	6d05                	lui	s10,0x1
    80001510:	8cbe                	mv	s9,a5
    80001512:	a015                	j	80001536 <copyout+0x5e>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001514:	409b0533          	sub	a0,s6,s1
    80001518:	0009861b          	sext.w	a2,s3
    8000151c:	85de                	mv	a1,s7
    8000151e:	954a                	add	a0,a0,s2
    80001520:	f90ff0ef          	jal	80000cb0 <memmove>
    len -= n;
    80001524:	413a0a33          	sub	s4,s4,s3
    src += n;
    80001528:	9bce                	add	s7,s7,s3
  while (len > 0) {
    8000152a:	040a0463          	beqz	s4,80001572 <copyout+0x9a>
    if (va0 >= MAXVA)
    8000152e:	055ced63          	bltu	s9,s5,80001588 <copyout+0xb0>
    80001532:	84d6                	mv	s1,s5
    80001534:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001536:	85a6                	mv	a1,s1
    80001538:	8562                	mv	a0,s8
    8000153a:	a2bff0ef          	jal	80000f64 <walkaddr>
    8000153e:	892a                	mv	s2,a0
    if (pa0 == 0) {
    80001540:	e909                	bnez	a0,80001552 <copyout+0x7a>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    80001542:	4681                	li	a3,0
    80001544:	8626                	mv	a2,s1
    80001546:	85ee                	mv	a1,s11
    80001548:	8562                	mv	a0,s8
    8000154a:	f13ff0ef          	jal	8000145c <vmfault>
    8000154e:	892a                	mv	s2,a0
    80001550:	c139                	beqz	a0,80001596 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    80001552:	4601                	li	a2,0
    80001554:	85a6                	mv	a1,s1
    80001556:	8562                	mv	a0,s8
    80001558:	973ff0ef          	jal	80000eca <walk>
    if ((*pte & PTE_W) == 0)
    8000155c:	611c                	ld	a5,0(a0)
    8000155e:	8b91                	andi	a5,a5,4
    80001560:	c3b1                	beqz	a5,800015a4 <copyout+0xcc>
    n = PGSIZE - (dstva - va0);
    80001562:	01a48ab3          	add	s5,s1,s10
    80001566:	416a89b3          	sub	s3,s5,s6
    if (n > len)
    8000156a:	fb3a75e3          	bgeu	s4,s3,80001514 <copyout+0x3c>
    8000156e:	89d2                	mv	s3,s4
    80001570:	b755                	j	80001514 <copyout+0x3c>
  return 0;
    80001572:	4501                	li	a0,0
    80001574:	6946                	ld	s2,80(sp)
    80001576:	69a6                	ld	s3,72(sp)
    80001578:	7ae2                	ld	s5,56(sp)
    8000157a:	6ce2                	ld	s9,24(sp)
    8000157c:	6d42                	ld	s10,16(sp)
    8000157e:	a80d                	j	800015b0 <copyout+0xd8>
    80001580:	4501                	li	a0,0
}
    80001582:	8082                	ret
      return -1;
    80001584:	557d                	li	a0,-1
    80001586:	a02d                	j	800015b0 <copyout+0xd8>
    80001588:	557d                	li	a0,-1
    8000158a:	6946                	ld	s2,80(sp)
    8000158c:	69a6                	ld	s3,72(sp)
    8000158e:	7ae2                	ld	s5,56(sp)
    80001590:	6ce2                	ld	s9,24(sp)
    80001592:	6d42                	ld	s10,16(sp)
    80001594:	a831                	j	800015b0 <copyout+0xd8>
        return -1;
    80001596:	557d                	li	a0,-1
    80001598:	6946                	ld	s2,80(sp)
    8000159a:	69a6                	ld	s3,72(sp)
    8000159c:	7ae2                	ld	s5,56(sp)
    8000159e:	6ce2                	ld	s9,24(sp)
    800015a0:	6d42                	ld	s10,16(sp)
    800015a2:	a039                	j	800015b0 <copyout+0xd8>
      return -1;
    800015a4:	557d                	li	a0,-1
    800015a6:	6946                	ld	s2,80(sp)
    800015a8:	69a6                	ld	s3,72(sp)
    800015aa:	7ae2                	ld	s5,56(sp)
    800015ac:	6ce2                	ld	s9,24(sp)
    800015ae:	6d42                	ld	s10,16(sp)
}
    800015b0:	70a6                	ld	ra,104(sp)
    800015b2:	7406                	ld	s0,96(sp)
    800015b4:	64e6                	ld	s1,88(sp)
    800015b6:	6a06                	ld	s4,64(sp)
    800015b8:	7b42                	ld	s6,48(sp)
    800015ba:	7ba2                	ld	s7,40(sp)
    800015bc:	7c02                	ld	s8,32(sp)
    800015be:	6da2                	ld	s11,8(sp)
    800015c0:	6165                	addi	sp,sp,112
    800015c2:	8082                	ret

00000000800015c4 <copyin>:
  while (len > 0) {
    800015c4:	cb49                	beqz	a4,80001656 <copyin+0x92>
{
    800015c6:	711d                	addi	sp,sp,-96
    800015c8:	ec86                	sd	ra,88(sp)
    800015ca:	e8a2                	sd	s0,80(sp)
    800015cc:	e4a6                	sd	s1,72(sp)
    800015ce:	e0ca                	sd	s2,64(sp)
    800015d0:	fc4e                	sd	s3,56(sp)
    800015d2:	f852                	sd	s4,48(sp)
    800015d4:	f456                	sd	s5,40(sp)
    800015d6:	f05a                	sd	s6,32(sp)
    800015d8:	ec5e                	sd	s7,24(sp)
    800015da:	e862                	sd	s8,16(sp)
    800015dc:	e466                	sd	s9,8(sp)
    800015de:	1080                	addi	s0,sp,96
    800015e0:	8baa                	mv	s7,a0
    800015e2:	8cae                	mv	s9,a1
    800015e4:	8ab2                	mv	s5,a2
    800015e6:	8936                	mv	s2,a3
    800015e8:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    800015ea:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800015ec:	6b05                	lui	s6,0x1
    800015ee:	a035                	j	8000161a <copyin+0x56>
    800015f0:	412984b3          	sub	s1,s3,s2
    800015f4:	94da                	add	s1,s1,s6
    if (n > len)
    800015f6:	009a7363          	bgeu	s4,s1,800015fc <copyin+0x38>
    800015fa:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800015fc:	413905b3          	sub	a1,s2,s3
    80001600:	0004861b          	sext.w	a2,s1
    80001604:	95aa                	add	a1,a1,a0
    80001606:	8556                	mv	a0,s5
    80001608:	ea8ff0ef          	jal	80000cb0 <memmove>
    len -= n;
    8000160c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001610:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001612:	01698933          	add	s2,s3,s6
  while (len > 0) {
    80001616:	020a0263          	beqz	s4,8000163a <copyin+0x76>
    va0 = PGROUNDDOWN(srcva);
    8000161a:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000161e:	85ce                	mv	a1,s3
    80001620:	855e                	mv	a0,s7
    80001622:	943ff0ef          	jal	80000f64 <walkaddr>
    if (pa0 == 0) {
    80001626:	f569                	bnez	a0,800015f0 <copyin+0x2c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001628:	4685                	li	a3,1
    8000162a:	864e                	mv	a2,s3
    8000162c:	85e6                	mv	a1,s9
    8000162e:	855e                	mv	a0,s7
    80001630:	e2dff0ef          	jal	8000145c <vmfault>
    80001634:	fd55                	bnez	a0,800015f0 <copyin+0x2c>
        return -1;
    80001636:	557d                	li	a0,-1
    80001638:	a011                	j	8000163c <copyin+0x78>
  return 0;
    8000163a:	4501                	li	a0,0
}
    8000163c:	60e6                	ld	ra,88(sp)
    8000163e:	6446                	ld	s0,80(sp)
    80001640:	64a6                	ld	s1,72(sp)
    80001642:	6906                	ld	s2,64(sp)
    80001644:	79e2                	ld	s3,56(sp)
    80001646:	7a42                	ld	s4,48(sp)
    80001648:	7aa2                	ld	s5,40(sp)
    8000164a:	7b02                	ld	s6,32(sp)
    8000164c:	6be2                	ld	s7,24(sp)
    8000164e:	6c42                	ld	s8,16(sp)
    80001650:	6ca2                	ld	s9,8(sp)
    80001652:	6125                	addi	sp,sp,96
    80001654:	8082                	ret
  return 0;
    80001656:	4501                	li	a0,0
}
    80001658:	8082                	ret

000000008000165a <copyinstr>:
  while (got_null == 0 && max > 0) {
    8000165a:	c371                	beqz	a4,8000171e <copyinstr+0xc4>
{
    8000165c:	715d                	addi	sp,sp,-80
    8000165e:	e486                	sd	ra,72(sp)
    80001660:	e0a2                	sd	s0,64(sp)
    80001662:	fc26                	sd	s1,56(sp)
    80001664:	f84a                	sd	s2,48(sp)
    80001666:	f44e                	sd	s3,40(sp)
    80001668:	f052                	sd	s4,32(sp)
    8000166a:	ec56                	sd	s5,24(sp)
    8000166c:	e85a                	sd	s6,16(sp)
    8000166e:	e45e                	sd	s7,8(sp)
    80001670:	e062                	sd	s8,0(sp)
    80001672:	0880                	addi	s0,sp,80
    80001674:	8a2a                	mv	s4,a0
    80001676:	8b2e                	mv	s6,a1
    80001678:	8bb2                	mv	s7,a2
    8000167a:	8c36                	mv	s8,a3
    8000167c:	893a                	mv	s2,a4
    va0 = PGROUNDDOWN(srcva);
    8000167e:	7afd                	lui	s5,0xfffff
    n = PGSIZE - (srcva - va0);
    80001680:	6985                	lui	s3,0x1
    80001682:	a0b1                	j	800016ce <copyinstr+0x74>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001684:	4685                	li	a3,1
    80001686:	8626                	mv	a2,s1
    80001688:	85da                	mv	a1,s6
    8000168a:	8552                	mv	a0,s4
    8000168c:	dd1ff0ef          	jal	8000145c <vmfault>
    80001690:	e531                	bnez	a0,800016dc <copyinstr+0x82>
        return -1;
    80001692:	557d                	li	a0,-1
    80001694:	a039                	j	800016a2 <copyinstr+0x48>
        *dst = '\0';
    80001696:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffd9550>
    8000169a:	4785                	li	a5,1
  if (got_null) {
    8000169c:	37fd                	addiw	a5,a5,-1
    8000169e:	0007851b          	sext.w	a0,a5
}
    800016a2:	60a6                	ld	ra,72(sp)
    800016a4:	6406                	ld	s0,64(sp)
    800016a6:	74e2                	ld	s1,56(sp)
    800016a8:	7942                	ld	s2,48(sp)
    800016aa:	79a2                	ld	s3,40(sp)
    800016ac:	7a02                	ld	s4,32(sp)
    800016ae:	6ae2                	ld	s5,24(sp)
    800016b0:	6b42                	ld	s6,16(sp)
    800016b2:	6ba2                	ld	s7,8(sp)
    800016b4:	6c02                	ld	s8,0(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret
    800016ba:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016be:	972a                	add	a4,a4,a0
      --max;
    800016c0:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800016c4:	01348c33          	add	s8,s1,s3
  while (got_null == 0 && max > 0) {
    800016c8:	04e58563          	beq	a1,a4,80001712 <copyinstr+0xb8>
{
    800016cc:	8bbe                	mv	s7,a5
    va0 = PGROUNDDOWN(srcva);
    800016ce:	015c74b3          	and	s1,s8,s5
    pa0 = walkaddr(pagetable, va0);
    800016d2:	85a6                	mv	a1,s1
    800016d4:	8552                	mv	a0,s4
    800016d6:	88fff0ef          	jal	80000f64 <walkaddr>
    if (pa0 == 0) {
    800016da:	d54d                	beqz	a0,80001684 <copyinstr+0x2a>
    n = PGSIZE - (srcva - va0);
    800016dc:	41848633          	sub	a2,s1,s8
    800016e0:	964e                	add	a2,a2,s3
    if (n > max)
    800016e2:	00c97363          	bgeu	s2,a2,800016e8 <copyinstr+0x8e>
    800016e6:	864a                	mv	a2,s2
    char *p = (char *)(pa0 + (srcva - va0));
    800016e8:	409c0c33          	sub	s8,s8,s1
    800016ec:	9c2a                	add	s8,s8,a0
    while (n > 0) {
    800016ee:	c605                	beqz	a2,80001716 <copyinstr+0xbc>
    800016f0:	87de                	mv	a5,s7
    800016f2:	855e                	mv	a0,s7
      if (*p == '\0') {
    800016f4:	417c0733          	sub	a4,s8,s7
    while (n > 0) {
    800016f8:	965e                	add	a2,a2,s7
    800016fa:	85be                	mv	a1,a5
      if (*p == '\0') {
    800016fc:	00f706b3          	add	a3,a4,a5
    80001700:	0006c683          	lbu	a3,0(a3) # fffffffffffff000 <end+0xffffffff7ffd9550>
    80001704:	dac9                	beqz	a3,80001696 <copyinstr+0x3c>
        *dst = *p;
    80001706:	00d78023          	sb	a3,0(a5)
      dst++;
    8000170a:	0785                	addi	a5,a5,1
    while (n > 0) {
    8000170c:	fec797e3          	bne	a5,a2,800016fa <copyinstr+0xa0>
    80001710:	b76d                	j	800016ba <copyinstr+0x60>
    80001712:	4781                	li	a5,0
    80001714:	b761                	j	8000169c <copyinstr+0x42>
    srcva = va0 + PGSIZE;
    80001716:	6c05                	lui	s8,0x1
    80001718:	9c26                	add	s8,s8,s1
    8000171a:	87de                	mv	a5,s7
    8000171c:	bf45                	j	800016cc <copyinstr+0x72>
  int got_null = 0;
    8000171e:	4781                	li	a5,0
  if (got_null) {
    80001720:	37fd                	addiw	a5,a5,-1
    80001722:	0007851b          	sext.w	a0,a5
}
    80001726:	8082                	ret

0000000080001728 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001728:	7139                	addi	sp,sp,-64
    8000172a:	fc06                	sd	ra,56(sp)
    8000172c:	f822                	sd	s0,48(sp)
    8000172e:	f426                	sd	s1,40(sp)
    80001730:	f04a                	sd	s2,32(sp)
    80001732:	ec4e                	sd	s3,24(sp)
    80001734:	e852                	sd	s4,16(sp)
    80001736:	e456                	sd	s5,8(sp)
    80001738:	e05a                	sd	s6,0(sp)
    8000173a:	0080                	addi	s0,sp,64
    8000173c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000173e:	00012497          	auipc	s1,0x12
    80001742:	39248493          	addi	s1,s1,914 # 80013ad0 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001746:	8b26                	mv	s6,s1
    80001748:	ff84c937          	lui	s2,0xff84c
    8000174c:	da190913          	addi	s2,s2,-607 # ffffffffff84bda1 <end+0xffffffff7f8262f1>
    80001750:	0936                	slli	s2,s2,0xd
    80001752:	5ed90913          	addi	s2,s2,1517
    80001756:	093a                	slli	s2,s2,0xe
    80001758:	25f90913          	addi	s2,s2,607
    8000175c:	0936                	slli	s2,s2,0xd
    8000175e:	a1390913          	addi	s2,s2,-1517
    80001762:	040009b7          	lui	s3,0x4000
    80001766:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001768:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000176a:	00019a97          	auipc	s5,0x19
    8000176e:	f66a8a93          	addi	s5,s5,-154 # 8001a6d0 <tickslock>
    char *pa = kalloc();
    80001772:	b58ff0ef          	jal	80000aca <kalloc>
    80001776:	862a                	mv	a2,a0
    if (pa == 0)
    80001778:	cd15                	beqz	a0,800017b4 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    8000177a:	416485b3          	sub	a1,s1,s6
    8000177e:	8591                	srai	a1,a1,0x4
    80001780:	032585b3          	mul	a1,a1,s2
    80001784:	2585                	addiw	a1,a1,1
    80001786:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000178a:	4719                	li	a4,6
    8000178c:	6685                	lui	a3,0x1
    8000178e:	40b985b3          	sub	a1,s3,a1
    80001792:	8552                	mv	a0,s4
    80001794:	8bfff0ef          	jal	80001052 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001798:	1b048493          	addi	s1,s1,432
    8000179c:	fd549be3          	bne	s1,s5,80001772 <proc_mapstacks+0x4a>
  }
}
    800017a0:	70e2                	ld	ra,56(sp)
    800017a2:	7442                	ld	s0,48(sp)
    800017a4:	74a2                	ld	s1,40(sp)
    800017a6:	7902                	ld	s2,32(sp)
    800017a8:	69e2                	ld	s3,24(sp)
    800017aa:	6a42                	ld	s4,16(sp)
    800017ac:	6aa2                	ld	s5,8(sp)
    800017ae:	6b02                	ld	s6,0(sp)
    800017b0:	6121                	addi	sp,sp,64
    800017b2:	8082                	ret
      panic("kalloc");
    800017b4:	00007517          	auipc	a0,0x7
    800017b8:	9a450513          	addi	a0,a0,-1628 # 80008158 <etext+0x158>
    800017bc:	834ff0ef          	jal	800007f0 <panic>

00000000800017c0 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017c0:	7139                	addi	sp,sp,-64
    800017c2:	fc06                	sd	ra,56(sp)
    800017c4:	f822                	sd	s0,48(sp)
    800017c6:	f426                	sd	s1,40(sp)
    800017c8:	f04a                	sd	s2,32(sp)
    800017ca:	ec4e                	sd	s3,24(sp)
    800017cc:	e852                	sd	s4,16(sp)
    800017ce:	e456                	sd	s5,8(sp)
    800017d0:	e05a                	sd	s6,0(sp)
    800017d2:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800017d4:	00007597          	auipc	a1,0x7
    800017d8:	98c58593          	addi	a1,a1,-1652 # 80008160 <etext+0x160>
    800017dc:	00012517          	auipc	a0,0x12
    800017e0:	ec450513          	addi	a0,a0,-316 # 800136a0 <pid_lock>
    800017e4:	b36ff0ef          	jal	80000b1a <initlock>
  initlock(&wait_lock, "wait_lock");
    800017e8:	00007597          	auipc	a1,0x7
    800017ec:	98058593          	addi	a1,a1,-1664 # 80008168 <etext+0x168>
    800017f0:	00012517          	auipc	a0,0x12
    800017f4:	ec850513          	addi	a0,a0,-312 # 800136b8 <wait_lock>
    800017f8:	b22ff0ef          	jal	80000b1a <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017fc:	00012497          	auipc	s1,0x12
    80001800:	2d448493          	addi	s1,s1,724 # 80013ad0 <proc>
    initlock(&p->lock, "proc");
    80001804:	00007b17          	auipc	s6,0x7
    80001808:	974b0b13          	addi	s6,s6,-1676 # 80008178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000180c:	8aa6                	mv	s5,s1
    8000180e:	ff84c937          	lui	s2,0xff84c
    80001812:	da190913          	addi	s2,s2,-607 # ffffffffff84bda1 <end+0xffffffff7f8262f1>
    80001816:	0936                	slli	s2,s2,0xd
    80001818:	5ed90913          	addi	s2,s2,1517
    8000181c:	093a                	slli	s2,s2,0xe
    8000181e:	25f90913          	addi	s2,s2,607
    80001822:	0936                	slli	s2,s2,0xd
    80001824:	a1390913          	addi	s2,s2,-1517
    80001828:	040009b7          	lui	s3,0x4000
    8000182c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000182e:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001830:	00019a17          	auipc	s4,0x19
    80001834:	ea0a0a13          	addi	s4,s4,-352 # 8001a6d0 <tickslock>
    initlock(&p->lock, "proc");
    80001838:	85da                	mv	a1,s6
    8000183a:	8526                	mv	a0,s1
    8000183c:	adeff0ef          	jal	80000b1a <initlock>
    p->state = UNUSED;
    80001840:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001844:	415487b3          	sub	a5,s1,s5
    80001848:	8791                	srai	a5,a5,0x4
    8000184a:	032787b3          	mul	a5,a5,s2
    8000184e:	2785                	addiw	a5,a5,1
    80001850:	00d7979b          	slliw	a5,a5,0xd
    80001854:	40f987b3          	sub	a5,s3,a5
    80001858:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000185a:	1b048493          	addi	s1,s1,432
    8000185e:	fd449de3          	bne	s1,s4,80001838 <procinit+0x78>
  }
}
    80001862:	70e2                	ld	ra,56(sp)
    80001864:	7442                	ld	s0,48(sp)
    80001866:	74a2                	ld	s1,40(sp)
    80001868:	7902                	ld	s2,32(sp)
    8000186a:	69e2                	ld	s3,24(sp)
    8000186c:	6a42                	ld	s4,16(sp)
    8000186e:	6aa2                	ld	s5,8(sp)
    80001870:	6b02                	ld	s6,0(sp)
    80001872:	6121                	addi	sp,sp,64
    80001874:	8082                	ret

0000000080001876 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001876:	1141                	addi	sp,sp,-16
    80001878:	e422                	sd	s0,8(sp)
    8000187a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    8000187c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000187e:	2501                	sext.w	a0,a0
    80001880:	6422                	ld	s0,8(sp)
    80001882:	0141                	addi	sp,sp,16
    80001884:	8082                	ret

0000000080001886 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001886:	1141                	addi	sp,sp,-16
    80001888:	e422                	sd	s0,8(sp)
    8000188a:	0800                	addi	s0,sp,16
    8000188c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000188e:	2781                	sext.w	a5,a5
    80001890:	079e                	slli	a5,a5,0x7
  return c;
}
    80001892:	00012517          	auipc	a0,0x12
    80001896:	e3e50513          	addi	a0,a0,-450 # 800136d0 <cpus>
    8000189a:	953e                	add	a0,a0,a5
    8000189c:	6422                	ld	s0,8(sp)
    8000189e:	0141                	addi	sp,sp,16
    800018a0:	8082                	ret

00000000800018a2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800018a2:	1101                	addi	sp,sp,-32
    800018a4:	ec06                	sd	ra,24(sp)
    800018a6:	e822                	sd	s0,16(sp)
    800018a8:	e426                	sd	s1,8(sp)
    800018aa:	1000                	addi	s0,sp,32
  push_off();
    800018ac:	aaeff0ef          	jal	80000b5a <push_off>
    800018b0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018b2:	2781                	sext.w	a5,a5
    800018b4:	079e                	slli	a5,a5,0x7
    800018b6:	00012717          	auipc	a4,0x12
    800018ba:	dea70713          	addi	a4,a4,-534 # 800136a0 <pid_lock>
    800018be:	97ba                	add	a5,a5,a4
    800018c0:	7b84                	ld	s1,48(a5)
  pop_off();
    800018c2:	b0eff0ef          	jal	80000bd0 <pop_off>
  return p;
}
    800018c6:	8526                	mv	a0,s1
    800018c8:	60e2                	ld	ra,24(sp)
    800018ca:	6442                	ld	s0,16(sp)
    800018cc:	64a2                	ld	s1,8(sp)
    800018ce:	6105                	addi	sp,sp,32
    800018d0:	8082                	ret

00000000800018d2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018d2:	7179                	addi	sp,sp,-48
    800018d4:	f406                	sd	ra,40(sp)
    800018d6:	f022                	sd	s0,32(sp)
    800018d8:	ec26                	sd	s1,24(sp)
    800018da:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800018dc:	fc7ff0ef          	jal	800018a2 <myproc>
    800018e0:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800018e2:	b3aff0ef          	jal	80000c1c <release>

  if (__atomic_load_n(&first, __ATOMIC_ACQUIRE)) {
    800018e6:	0000a797          	auipc	a5,0xa
    800018ea:	c3a78793          	addi	a5,a5,-966 # 8000b520 <first.1>
    800018ee:	439c                	lw	a5,0(a5)
    800018f0:	0230000f          	fence	r,rw
    800018f4:	2781                	sext.w	a5,a5
    800018f6:	cf9d                	beqz	a5,80001934 <forkret+0x62>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800018f8:	4505                	li	a0,1
    800018fa:	220020ef          	jal	80003b1a <fsinit>

    // ensure other cores see first=0.
    __atomic_store_n(&first, 0, __ATOMIC_RELEASE);
    800018fe:	0000a797          	auipc	a5,0xa
    80001902:	c2278793          	addi	a5,a5,-990 # 8000b520 <first.1>
    80001906:	0310000f          	fence	rw,w
    8000190a:	0007a023          	sw	zero,0(a5)

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    8000190e:	00007517          	auipc	a0,0x7
    80001912:	87250513          	addi	a0,a0,-1934 # 80008180 <etext+0x180>
    80001916:	fca43823          	sd	a0,-48(s0)
    8000191a:	fc043c23          	sd	zero,-40(s0)
    8000191e:	fd040593          	addi	a1,s0,-48
    80001922:	400030ef          	jal	80004d22 <kexec>
    80001926:	6cbc                	ld	a5,88(s1)
    80001928:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000192a:	6cbc                	ld	a5,88(s1)
    8000192c:	7bb8                	ld	a4,112(a5)
    8000192e:	57fd                	li	a5,-1
    80001930:	02f70d63          	beq	a4,a5,8000196a <forkret+0x98>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001934:	519000ef          	jal	8000264c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001938:	68a8                	ld	a0,80(s1)
    8000193a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000193c:	04000737          	lui	a4,0x4000
    80001940:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001942:	0732                	slli	a4,a4,0xc
    80001944:	00005797          	auipc	a5,0x5
    80001948:	75878793          	addi	a5,a5,1880 # 8000709c <userret>
    8000194c:	00005697          	auipc	a3,0x5
    80001950:	6b468693          	addi	a3,a3,1716 # 80007000 <_trampoline>
    80001954:	8f95                	sub	a5,a5,a3
    80001956:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001958:	577d                	li	a4,-1
    8000195a:	177e                	slli	a4,a4,0x3f
    8000195c:	8d59                	or	a0,a0,a4
    8000195e:	9782                	jalr	a5
}
    80001960:	70a2                	ld	ra,40(sp)
    80001962:	7402                	ld	s0,32(sp)
    80001964:	64e2                	ld	s1,24(sp)
    80001966:	6145                	addi	sp,sp,48
    80001968:	8082                	ret
      panic("exec");
    8000196a:	00007517          	auipc	a0,0x7
    8000196e:	81e50513          	addi	a0,a0,-2018 # 80008188 <etext+0x188>
    80001972:	e7ffe0ef          	jal	800007f0 <panic>

0000000080001976 <allocpid>:
{
    80001976:	1101                	addi	sp,sp,-32
    80001978:	ec06                	sd	ra,24(sp)
    8000197a:	e822                	sd	s0,16(sp)
    8000197c:	e426                	sd	s1,8(sp)
    8000197e:	e04a                	sd	s2,0(sp)
    80001980:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001982:	00012917          	auipc	s2,0x12
    80001986:	d1e90913          	addi	s2,s2,-738 # 800136a0 <pid_lock>
    8000198a:	854a                	mv	a0,s2
    8000198c:	a04ff0ef          	jal	80000b90 <acquire>
  pid = nextpid;
    80001990:	0000a797          	auipc	a5,0xa
    80001994:	b9478793          	addi	a5,a5,-1132 # 8000b524 <nextpid>
    80001998:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000199a:	0014871b          	addiw	a4,s1,1
    8000199e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019a0:	854a                	mv	a0,s2
    800019a2:	a7aff0ef          	jal	80000c1c <release>
}
    800019a6:	8526                	mv	a0,s1
    800019a8:	60e2                	ld	ra,24(sp)
    800019aa:	6442                	ld	s0,16(sp)
    800019ac:	64a2                	ld	s1,8(sp)
    800019ae:	6902                	ld	s2,0(sp)
    800019b0:	6105                	addi	sp,sp,32
    800019b2:	8082                	ret

00000000800019b4 <proc_pagetable>:
{
    800019b4:	1101                	addi	sp,sp,-32
    800019b6:	ec06                	sd	ra,24(sp)
    800019b8:	e822                	sd	s0,16(sp)
    800019ba:	e426                	sd	s1,8(sp)
    800019bc:	e04a                	sd	s2,0(sp)
    800019be:	1000                	addi	s0,sp,32
    800019c0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019c2:	f86ff0ef          	jal	80001148 <uvmcreate>
    800019c6:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800019c8:	cd05                	beqz	a0,80001a00 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    800019ca:	4729                	li	a4,10
    800019cc:	00005697          	auipc	a3,0x5
    800019d0:	63468693          	addi	a3,a3,1588 # 80007000 <_trampoline>
    800019d4:	6605                	lui	a2,0x1
    800019d6:	040005b7          	lui	a1,0x4000
    800019da:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019dc:	05b2                	slli	a1,a1,0xc
    800019de:	dc4ff0ef          	jal	80000fa2 <mappages>
    800019e2:	02054663          	bltz	a0,80001a0e <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    800019e6:	4719                	li	a4,6
    800019e8:	05893683          	ld	a3,88(s2)
    800019ec:	6605                	lui	a2,0x1
    800019ee:	020005b7          	lui	a1,0x2000
    800019f2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019f4:	05b6                	slli	a1,a1,0xd
    800019f6:	8526                	mv	a0,s1
    800019f8:	daaff0ef          	jal	80000fa2 <mappages>
    800019fc:	00054f63          	bltz	a0,80001a1a <proc_pagetable+0x66>
}
    80001a00:	8526                	mv	a0,s1
    80001a02:	60e2                	ld	ra,24(sp)
    80001a04:	6442                	ld	s0,16(sp)
    80001a06:	64a2                	ld	s1,8(sp)
    80001a08:	6902                	ld	s2,0(sp)
    80001a0a:	6105                	addi	sp,sp,32
    80001a0c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a0e:	4581                	li	a1,0
    80001a10:	8526                	mv	a0,s1
    80001a12:	931ff0ef          	jal	80001342 <uvmfree>
    return 0;
    80001a16:	4481                	li	s1,0
    80001a18:	b7e5                	j	80001a00 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1a:	4681                	li	a3,0
    80001a1c:	4605                	li	a2,1
    80001a1e:	040005b7          	lui	a1,0x4000
    80001a22:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a24:	05b2                	slli	a1,a1,0xc
    80001a26:	8526                	mv	a0,s1
    80001a28:	f46ff0ef          	jal	8000116e <uvmunmap>
    uvmfree(pagetable, 0);
    80001a2c:	4581                	li	a1,0
    80001a2e:	8526                	mv	a0,s1
    80001a30:	913ff0ef          	jal	80001342 <uvmfree>
    return 0;
    80001a34:	4481                	li	s1,0
    80001a36:	b7e9                	j	80001a00 <proc_pagetable+0x4c>

0000000080001a38 <proc_freepagetable>:
{
    80001a38:	1101                	addi	sp,sp,-32
    80001a3a:	ec06                	sd	ra,24(sp)
    80001a3c:	e822                	sd	s0,16(sp)
    80001a3e:	e426                	sd	s1,8(sp)
    80001a40:	e04a                	sd	s2,0(sp)
    80001a42:	1000                	addi	s0,sp,32
    80001a44:	84aa                	mv	s1,a0
    80001a46:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a48:	4681                	li	a3,0
    80001a4a:	4605                	li	a2,1
    80001a4c:	040005b7          	lui	a1,0x4000
    80001a50:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a52:	05b2                	slli	a1,a1,0xc
    80001a54:	f1aff0ef          	jal	8000116e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a58:	4681                	li	a3,0
    80001a5a:	4605                	li	a2,1
    80001a5c:	020005b7          	lui	a1,0x2000
    80001a60:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a62:	05b6                	slli	a1,a1,0xd
    80001a64:	8526                	mv	a0,s1
    80001a66:	f08ff0ef          	jal	8000116e <uvmunmap>
  uvmfree(pagetable, sz);
    80001a6a:	85ca                	mv	a1,s2
    80001a6c:	8526                	mv	a0,s1
    80001a6e:	8d5ff0ef          	jal	80001342 <uvmfree>
}
    80001a72:	60e2                	ld	ra,24(sp)
    80001a74:	6442                	ld	s0,16(sp)
    80001a76:	64a2                	ld	s1,8(sp)
    80001a78:	6902                	ld	s2,0(sp)
    80001a7a:	6105                	addi	sp,sp,32
    80001a7c:	8082                	ret

0000000080001a7e <freeproc>:
{
    80001a7e:	1101                	addi	sp,sp,-32
    80001a80:	ec06                	sd	ra,24(sp)
    80001a82:	e822                	sd	s0,16(sp)
    80001a84:	e426                	sd	s1,8(sp)
    80001a86:	1000                	addi	s0,sp,32
    80001a88:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001a8a:	6d28                	ld	a0,88(a0)
    80001a8c:	c119                	beqz	a0,80001a92 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001a8e:	f5bfe0ef          	jal	800009e8 <kfree>
  p->trapframe = 0;
    80001a92:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001a96:	68a8                	ld	a0,80(s1)
    80001a98:	c501                	beqz	a0,80001aa0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a9a:	64ac                	ld	a1,72(s1)
    80001a9c:	f9dff0ef          	jal	80001a38 <proc_freepagetable>
  p->pagetable = 0;
    80001aa0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001aa4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001aa8:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001aac:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ab0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ab4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ab8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001abc:	0004ac23          	sw	zero,24(s1)
  p->cpu_time = 0;
    80001ac0:	1604b423          	sd	zero,360(s1)
  p->wait_time = 0;
    80001ac4:	1604b823          	sd	zero,368(s1)
  p->context_switches = 0;
    80001ac8:	1604bc23          	sd	zero,376(s1)
  p->last_run = 0;
    80001acc:	1804b023          	sd	zero,384(s1)
  p->ready_time = 0;
    80001ad0:	1804b423          	sd	zero,392(s1)
  p->sleep_time = 0; 
    80001ad4:	1804b823          	sd	zero,400(s1)
  p->last_sleep_start = 0;
    80001ad8:	1804bc23          	sd	zero,408(s1)
  p->mlfq_level = 0;
    80001adc:	1a04a023          	sw	zero,416(s1)
  p->mlfq_ticks = 0;
    80001ae0:	1a04a223          	sw	zero,420(s1)
  p->mlfq_priority = 0;
    80001ae4:	1a04a423          	sw	zero,424(s1)
}
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6105                	addi	sp,sp,32
    80001af0:	8082                	ret

0000000080001af2 <allocproc>:
{
    80001af2:	1101                	addi	sp,sp,-32
    80001af4:	ec06                	sd	ra,24(sp)
    80001af6:	e822                	sd	s0,16(sp)
    80001af8:	e426                	sd	s1,8(sp)
    80001afa:	e04a                	sd	s2,0(sp)
    80001afc:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001afe:	00012497          	auipc	s1,0x12
    80001b02:	fd248493          	addi	s1,s1,-46 # 80013ad0 <proc>
    80001b06:	00019917          	auipc	s2,0x19
    80001b0a:	bca90913          	addi	s2,s2,-1078 # 8001a6d0 <tickslock>
    acquire(&p->lock);
    80001b0e:	8526                	mv	a0,s1
    80001b10:	880ff0ef          	jal	80000b90 <acquire>
    if (p->state == UNUSED) {
    80001b14:	4c9c                	lw	a5,24(s1)
    80001b16:	cb91                	beqz	a5,80001b2a <allocproc+0x38>
      release(&p->lock);
    80001b18:	8526                	mv	a0,s1
    80001b1a:	902ff0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b1e:	1b048493          	addi	s1,s1,432
    80001b22:	ff2496e3          	bne	s1,s2,80001b0e <allocproc+0x1c>
  return 0;
    80001b26:	4481                	li	s1,0
    80001b28:	a0ad                	j	80001b92 <allocproc+0xa0>
  p->pid = allocpid();
    80001b2a:	e4dff0ef          	jal	80001976 <allocpid>
    80001b2e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b30:	4785                	li	a5,1
    80001b32:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b34:	f97fe0ef          	jal	80000aca <kalloc>
    80001b38:	892a                	mv	s2,a0
    80001b3a:	eca8                	sd	a0,88(s1)
    80001b3c:	c135                	beqz	a0,80001ba0 <allocproc+0xae>
  p->pagetable = proc_pagetable(p);
    80001b3e:	8526                	mv	a0,s1
    80001b40:	e75ff0ef          	jal	800019b4 <proc_pagetable>
    80001b44:	892a                	mv	s2,a0
    80001b46:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b48:	c525                	beqz	a0,80001bb0 <allocproc+0xbe>
  memset(&p->context, 0, sizeof(p->context));
    80001b4a:	07000613          	li	a2,112
    80001b4e:	4581                	li	a1,0
    80001b50:	06048513          	addi	a0,s1,96
    80001b54:	900ff0ef          	jal	80000c54 <memset>
  p->context.ra = (uint64)forkret;
    80001b58:	00000797          	auipc	a5,0x0
    80001b5c:	d7a78793          	addi	a5,a5,-646 # 800018d2 <forkret>
    80001b60:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b62:	60bc                	ld	a5,64(s1)
    80001b64:	6705                	lui	a4,0x1
    80001b66:	97ba                	add	a5,a5,a4
    80001b68:	f4bc                	sd	a5,104(s1)
  p->cpu_time = 0;
    80001b6a:	1604b423          	sd	zero,360(s1)
  p->wait_time = 0;
    80001b6e:	1604b823          	sd	zero,368(s1)
  p->context_switches = 0;
    80001b72:	1604bc23          	sd	zero,376(s1)
  p->last_run = 0;
    80001b76:	1804b023          	sd	zero,384(s1)
  p->ready_time = 0;
    80001b7a:	1804b423          	sd	zero,392(s1)
  p->sleep_time = 0;
    80001b7e:	1804b823          	sd	zero,400(s1)
  p->last_sleep_start = 0;
    80001b82:	1804bc23          	sd	zero,408(s1)
  p->mlfq_level = MLFQ_HIGH;    // Start at highest priority
    80001b86:	1a04a023          	sw	zero,416(s1)
  p->mlfq_ticks = 0;
    80001b8a:	1a04a223          	sw	zero,420(s1)
  p->mlfq_priority = 0;
    80001b8e:	1a04a423          	sw	zero,424(s1)
}
    80001b92:	8526                	mv	a0,s1
    80001b94:	60e2                	ld	ra,24(sp)
    80001b96:	6442                	ld	s0,16(sp)
    80001b98:	64a2                	ld	s1,8(sp)
    80001b9a:	6902                	ld	s2,0(sp)
    80001b9c:	6105                	addi	sp,sp,32
    80001b9e:	8082                	ret
    freeproc(p);
    80001ba0:	8526                	mv	a0,s1
    80001ba2:	eddff0ef          	jal	80001a7e <freeproc>
    release(&p->lock);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	874ff0ef          	jal	80000c1c <release>
    return 0;
    80001bac:	84ca                	mv	s1,s2
    80001bae:	b7d5                	j	80001b92 <allocproc+0xa0>
    freeproc(p);
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	ecdff0ef          	jal	80001a7e <freeproc>
    release(&p->lock);
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	864ff0ef          	jal	80000c1c <release>
    return 0;
    80001bbc:	84ca                	mv	s1,s2
    80001bbe:	bfd1                	j	80001b92 <allocproc+0xa0>

0000000080001bc0 <userinit>:
{
    80001bc0:	1101                	addi	sp,sp,-32
    80001bc2:	ec06                	sd	ra,24(sp)
    80001bc4:	e822                	sd	s0,16(sp)
    80001bc6:	e426                	sd	s1,8(sp)
    80001bc8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bca:	f29ff0ef          	jal	80001af2 <allocproc>
    80001bce:	84aa                	mv	s1,a0
  initproc = p;
    80001bd0:	0000a797          	auipc	a5,0xa
    80001bd4:	98a7bc23          	sd	a0,-1640(a5) # 8000b568 <initproc>
  p->cwd = namei("/");
    80001bd8:	00006517          	auipc	a0,0x6
    80001bdc:	5b850513          	addi	a0,a0,1464 # 80008190 <etext+0x190>
    80001be0:	472020ef          	jal	80004052 <namei>
    80001be4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001be8:	478d                	li	a5,3
    80001bea:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	82eff0ef          	jal	80000c1c <release>
}
    80001bf2:	60e2                	ld	ra,24(sp)
    80001bf4:	6442                	ld	s0,16(sp)
    80001bf6:	64a2                	ld	s1,8(sp)
    80001bf8:	6105                	addi	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <growproc>:
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	e04a                	sd	s2,0(sp)
    80001c06:	1000                	addi	s0,sp,32
    80001c08:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c0a:	c99ff0ef          	jal	800018a2 <myproc>
    80001c0e:	892a                	mv	s2,a0
  sz = p->sz;
    80001c10:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c12:	02905963          	blez	s1,80001c44 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c16:	00b48633          	add	a2,s1,a1
    80001c1a:	020007b7          	lui	a5,0x2000
    80001c1e:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c20:	07b6                	slli	a5,a5,0xd
    80001c22:	02c7ea63          	bltu	a5,a2,80001c56 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c26:	4691                	li	a3,4
    80001c28:	6928                	ld	a0,80(a0)
    80001c2a:	e12ff0ef          	jal	8000123c <uvmalloc>
    80001c2e:	85aa                	mv	a1,a0
    80001c30:	c50d                	beqz	a0,80001c5a <growproc+0x5e>
  p->sz = sz;
    80001c32:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c36:	4501                	li	a0,0
}
    80001c38:	60e2                	ld	ra,24(sp)
    80001c3a:	6442                	ld	s0,16(sp)
    80001c3c:	64a2                	ld	s1,8(sp)
    80001c3e:	6902                	ld	s2,0(sp)
    80001c40:	6105                	addi	sp,sp,32
    80001c42:	8082                	ret
  } else if (n < 0) {
    80001c44:	fe04d7e3          	bgez	s1,80001c32 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c48:	00b48633          	add	a2,s1,a1
    80001c4c:	6928                	ld	a0,80(a0)
    80001c4e:	daaff0ef          	jal	800011f8 <uvmdealloc>
    80001c52:	85aa                	mv	a1,a0
    80001c54:	bff9                	j	80001c32 <growproc+0x36>
      return -1;
    80001c56:	557d                	li	a0,-1
    80001c58:	b7c5                	j	80001c38 <growproc+0x3c>
      return -1;
    80001c5a:	557d                	li	a0,-1
    80001c5c:	bff1                	j	80001c38 <growproc+0x3c>

0000000080001c5e <kfork>:
{
    80001c5e:	7139                	addi	sp,sp,-64
    80001c60:	fc06                	sd	ra,56(sp)
    80001c62:	f822                	sd	s0,48(sp)
    80001c64:	f04a                	sd	s2,32(sp)
    80001c66:	e456                	sd	s5,8(sp)
    80001c68:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c6a:	c39ff0ef          	jal	800018a2 <myproc>
    80001c6e:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c70:	e83ff0ef          	jal	80001af2 <allocproc>
    80001c74:	0e050a63          	beqz	a0,80001d68 <kfork+0x10a>
    80001c78:	e852                	sd	s4,16(sp)
    80001c7a:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c7c:	048ab603          	ld	a2,72(s5)
    80001c80:	692c                	ld	a1,80(a0)
    80001c82:	050ab503          	ld	a0,80(s5)
    80001c86:	eeeff0ef          	jal	80001374 <uvmcopy>
    80001c8a:	04054a63          	bltz	a0,80001cde <kfork+0x80>
    80001c8e:	f426                	sd	s1,40(sp)
    80001c90:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c92:	048ab783          	ld	a5,72(s5)
    80001c96:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c9a:	058ab683          	ld	a3,88(s5)
    80001c9e:	87b6                	mv	a5,a3
    80001ca0:	058a3703          	ld	a4,88(s4)
    80001ca4:	12068693          	addi	a3,a3,288
    80001ca8:	0007b803          	ld	a6,0(a5)
    80001cac:	6788                	ld	a0,8(a5)
    80001cae:	6b8c                	ld	a1,16(a5)
    80001cb0:	6f90                	ld	a2,24(a5)
    80001cb2:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001cb6:	e708                	sd	a0,8(a4)
    80001cb8:	eb0c                	sd	a1,16(a4)
    80001cba:	ef10                	sd	a2,24(a4)
    80001cbc:	02078793          	addi	a5,a5,32
    80001cc0:	02070713          	addi	a4,a4,32
    80001cc4:	fed792e3          	bne	a5,a3,80001ca8 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001cc8:	058a3783          	ld	a5,88(s4)
    80001ccc:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001cd0:	0d0a8493          	addi	s1,s5,208
    80001cd4:	0d0a0913          	addi	s2,s4,208
    80001cd8:	150a8993          	addi	s3,s5,336
    80001cdc:	a831                	j	80001cf8 <kfork+0x9a>
    freeproc(np);
    80001cde:	8552                	mv	a0,s4
    80001ce0:	d9fff0ef          	jal	80001a7e <freeproc>
    release(&np->lock);
    80001ce4:	8552                	mv	a0,s4
    80001ce6:	f37fe0ef          	jal	80000c1c <release>
    return -1;
    80001cea:	597d                	li	s2,-1
    80001cec:	6a42                	ld	s4,16(sp)
    80001cee:	a0b5                	j	80001d5a <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001cf0:	04a1                	addi	s1,s1,8
    80001cf2:	0921                	addi	s2,s2,8
    80001cf4:	01348963          	beq	s1,s3,80001d06 <kfork+0xa8>
    if (p->ofile[i])
    80001cf8:	6088                	ld	a0,0(s1)
    80001cfa:	d97d                	beqz	a0,80001cf0 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cfc:	191020ef          	jal	8000468c <filedup>
    80001d00:	00a93023          	sd	a0,0(s2)
    80001d04:	b7f5                	j	80001cf0 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001d06:	150ab503          	ld	a0,336(s5)
    80001d0a:	29f010ef          	jal	800037a8 <idup>
    80001d0e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d12:	4641                	li	a2,16
    80001d14:	158a8593          	addi	a1,s5,344
    80001d18:	158a0513          	addi	a0,s4,344
    80001d1c:	876ff0ef          	jal	80000d92 <safestrcpy>
  pid = np->pid;
    80001d20:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d24:	8552                	mv	a0,s4
    80001d26:	ef7fe0ef          	jal	80000c1c <release>
  acquire(&wait_lock);
    80001d2a:	00012497          	auipc	s1,0x12
    80001d2e:	98e48493          	addi	s1,s1,-1650 # 800136b8 <wait_lock>
    80001d32:	8526                	mv	a0,s1
    80001d34:	e5dfe0ef          	jal	80000b90 <acquire>
  np->parent = p;
    80001d38:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d3c:	8526                	mv	a0,s1
    80001d3e:	edffe0ef          	jal	80000c1c <release>
  acquire(&np->lock);
    80001d42:	8552                	mv	a0,s4
    80001d44:	e4dfe0ef          	jal	80000b90 <acquire>
  np->state = RUNNABLE;
    80001d48:	478d                	li	a5,3
    80001d4a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d4e:	8552                	mv	a0,s4
    80001d50:	ecdfe0ef          	jal	80000c1c <release>
  return pid;
    80001d54:	74a2                	ld	s1,40(sp)
    80001d56:	69e2                	ld	s3,24(sp)
    80001d58:	6a42                	ld	s4,16(sp)
}
    80001d5a:	854a                	mv	a0,s2
    80001d5c:	70e2                	ld	ra,56(sp)
    80001d5e:	7442                	ld	s0,48(sp)
    80001d60:	7902                	ld	s2,32(sp)
    80001d62:	6aa2                	ld	s5,8(sp)
    80001d64:	6121                	addi	sp,sp,64
    80001d66:	8082                	ret
    return -1;
    80001d68:	597d                	li	s2,-1
    80001d6a:	bfc5                	j	80001d5a <kfork+0xfc>

0000000080001d6c <scheduler>:
{
    80001d6c:	7159                	addi	sp,sp,-112
    80001d6e:	f486                	sd	ra,104(sp)
    80001d70:	f0a2                	sd	s0,96(sp)
    80001d72:	eca6                	sd	s1,88(sp)
    80001d74:	e8ca                	sd	s2,80(sp)
    80001d76:	e4ce                	sd	s3,72(sp)
    80001d78:	e0d2                	sd	s4,64(sp)
    80001d7a:	fc56                	sd	s5,56(sp)
    80001d7c:	f85a                	sd	s6,48(sp)
    80001d7e:	f45e                	sd	s7,40(sp)
    80001d80:	f062                	sd	s8,32(sp)
    80001d82:	ec66                	sd	s9,24(sp)
    80001d84:	e86a                	sd	s10,16(sp)
    80001d86:	e46e                	sd	s11,8(sp)
    80001d88:	1880                	addi	s0,sp,112
    80001d8a:	8792                	mv	a5,tp
  int id = r_tp();
    80001d8c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d8e:	00779d13          	slli	s10,a5,0x7
    80001d92:	00012717          	auipc	a4,0x12
    80001d96:	90e70713          	addi	a4,a4,-1778 # 800136a0 <pid_lock>
    80001d9a:	976a                	add	a4,a4,s10
    80001d9c:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001da0:	00012717          	auipc	a4,0x12
    80001da4:	93870713          	addi	a4,a4,-1736 # 800136d8 <cpus+0x8>
    80001da8:	9d3a                	add	s10,s10,a4
    if (scheduler_policy == SCHED_MLFQ) {
    80001daa:	00009c97          	auipc	s9,0x9
    80001dae:	7c6c8c93          	addi	s9,s9,1990 # 8000b570 <scheduler_policy>
    80001db2:	4c05                	li	s8,1
      for (p = proc; p < &proc[NPROC]; p++) {
    80001db4:	00019917          	auipc	s2,0x19
    80001db8:	91c90913          	addi	s2,s2,-1764 # 8001a6d0 <tickslock>
          now = ticks;
    80001dbc:	00009b97          	auipc	s7,0x9
    80001dc0:	7c4b8b93          	addi	s7,s7,1988 # 8000b580 <ticks>
          c->proc = p;
    80001dc4:	079e                	slli	a5,a5,0x7
    80001dc6:	00012b17          	auipc	s6,0x12
    80001dca:	8dab0b13          	addi	s6,s6,-1830 # 800136a0 <pid_lock>
    80001dce:	9b3e                	add	s6,s6,a5
    80001dd0:	a8a9                	j	80001e2a <scheduler+0xbe>
    int best_level = 3;  // MLFQ_LOW + 1
    80001dd2:	4a0d                	li	s4,3
    struct proc *best = 0;
    80001dd4:	4d81                	li	s11,0
    80001dd6:	a801                	j	80001de6 <scheduler+0x7a>
        release(&p->lock);
    80001dd8:	8526                	mv	a0,s1
    80001dda:	e43fe0ef          	jal	80000c1c <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dde:	1b048493          	addi	s1,s1,432
    80001de2:	01248f63          	beq	s1,s2,80001e00 <scheduler+0x94>
        acquire(&p->lock);
    80001de6:	8526                	mv	a0,s1
    80001de8:	da9fe0ef          	jal	80000b90 <acquire>
        if (p->state == RUNNABLE && p->mlfq_level < best_level) {
    80001dec:	4c9c                	lw	a5,24(s1)
    80001dee:	ff3795e3          	bne	a5,s3,80001dd8 <scheduler+0x6c>
    80001df2:	1a04a783          	lw	a5,416(s1)
    80001df6:	ff47d1e3          	bge	a5,s4,80001dd8 <scheduler+0x6c>
            best_level = p->mlfq_level;
    80001dfa:	8a3e                	mv	s4,a5
            best = p;
    80001dfc:	8da6                	mv	s11,s1
    80001dfe:	bfe9                	j	80001dd8 <scheduler+0x6c>
    if (p) {
    80001e00:	020d8363          	beqz	s11,80001e26 <scheduler+0xba>
        acquire(&p->lock);
    80001e04:	84ee                	mv	s1,s11
    80001e06:	856e                	mv	a0,s11
    80001e08:	d89fe0ef          	jal	80000b90 <acquire>
        if (p->state == RUNNABLE) {
    80001e0c:	018da703          	lw	a4,24(s11)
    80001e10:	478d                	li	a5,3
    80001e12:	04f70763          	beq	a4,a5,80001e60 <scheduler+0xf4>
    found = 0;
    80001e16:	4a81                	li	s5,0
        release(&p->lock);
    80001e18:	8526                	mv	a0,s1
    80001e1a:	e03fe0ef          	jal	80000c1c <release>
        c->proc = 0;
    80001e1e:	020b3823          	sd	zero,48(s6)
    if (found == 0) {
    80001e22:	000a9463          	bnez	s5,80001e2a <scheduler+0xbe>
      asm volatile("wfi");
    80001e26:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001e2a:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001e2e:	10017073          	csrci	sstatus,2
    if (scheduler_policy == SCHED_MLFQ) {
    80001e32:	000caa83          	lw	s5,0(s9)
      for (p = proc; p < &proc[NPROC]; p++) {
    80001e36:	00012497          	auipc	s1,0x12
    80001e3a:	c9a48493          	addi	s1,s1,-870 # 80013ad0 <proc>
        if (p->state == RUNNABLE) {
    80001e3e:	498d                	li	s3,3
    if (scheduler_policy == SCHED_MLFQ) {
    80001e40:	f98a89e3          	beq	s5,s8,80001dd2 <scheduler+0x66>
        acquire(&p->lock);
    80001e44:	8526                	mv	a0,s1
    80001e46:	d4bfe0ef          	jal	80000b90 <acquire>
        if (p->state == RUNNABLE) {
    80001e4a:	4c9c                	lw	a5,24(s1)
    80001e4c:	07378463          	beq	a5,s3,80001eb4 <scheduler+0x148>
        release(&p->lock);
    80001e50:	8526                	mv	a0,s1
    80001e52:	dcbfe0ef          	jal	80000c1c <release>
      for (p = proc; p < &proc[NPROC]; p++) {
    80001e56:	1b048493          	addi	s1,s1,432
    80001e5a:	ff2495e3          	bne	s1,s2,80001e44 <scheduler+0xd8>
    80001e5e:	b7e1                	j	80001e26 <scheduler+0xba>
            now = ticks;
    80001e60:	000be783          	lwu	a5,0(s7)
            p->last_run = now;
    80001e64:	18fdb023          	sd	a5,384(s11)
            if (p->ready_time > 0) {
    80001e68:	188db703          	ld	a4,392(s11)
    80001e6c:	c719                	beqz	a4,80001e7a <scheduler+0x10e>
                p->wait_time += (now - p->ready_time);
    80001e6e:	170db683          	ld	a3,368(s11)
    80001e72:	97b6                	add	a5,a5,a3
    80001e74:	8f99                	sub	a5,a5,a4
    80001e76:	16fdb823          	sd	a5,368(s11)
            p->state = RUNNING;
    80001e7a:	4791                	li	a5,4
    80001e7c:	00fdac23          	sw	a5,24(s11)
            c->proc = p;
    80001e80:	03bb3823          	sd	s11,48(s6)
            swtch(&c->context, &p->context);
    80001e84:	060d8593          	addi	a1,s11,96
    80001e88:	856a                	mv	a0,s10
    80001e8a:	71c000ef          	jal	800025a6 <swtch>
            now = ticks;
    80001e8e:	000ba783          	lw	a5,0(s7)
            p->context_switches++;
    80001e92:	178db703          	ld	a4,376(s11)
    80001e96:	0705                	addi	a4,a4,1
    80001e98:	16edbc23          	sd	a4,376(s11)
            if (p->last_run > 0) {
    80001e9c:	180db703          	ld	a4,384(s11)
    80001ea0:	df25                	beqz	a4,80001e18 <scheduler+0xac>
            now = ticks;
    80001ea2:	1782                	slli	a5,a5,0x20
    80001ea4:	9381                	srli	a5,a5,0x20
                p->cpu_time += (now - p->last_run);
    80001ea6:	168db683          	ld	a3,360(s11)
    80001eaa:	97b6                	add	a5,a5,a3
    80001eac:	8f99                	sub	a5,a5,a4
    80001eae:	16fdb423          	sd	a5,360(s11)
    80001eb2:	b79d                	j	80001e18 <scheduler+0xac>
          now = ticks;
    80001eb4:	000be783          	lwu	a5,0(s7)
          p->last_run = now;
    80001eb8:	18f4b023          	sd	a5,384(s1)
          if (p->ready_time > 0) {
    80001ebc:	1884b703          	ld	a4,392(s1)
    80001ec0:	c719                	beqz	a4,80001ece <scheduler+0x162>
            p->wait_time += (now - p->ready_time);
    80001ec2:	1704b683          	ld	a3,368(s1)
    80001ec6:	97b6                	add	a5,a5,a3
    80001ec8:	8f99                	sub	a5,a5,a4
    80001eca:	16f4b823          	sd	a5,368(s1)
          p->state = RUNNING;
    80001ece:	4791                	li	a5,4
    80001ed0:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    80001ed2:	029b3823          	sd	s1,48(s6)
          swtch(&c->context, &p->context);
    80001ed6:	06048593          	addi	a1,s1,96
    80001eda:	856a                	mv	a0,s10
    80001edc:	6ca000ef          	jal	800025a6 <swtch>
          now = ticks;
    80001ee0:	000ba783          	lw	a5,0(s7)
          p->context_switches++;
    80001ee4:	1784b703          	ld	a4,376(s1)
    80001ee8:	0705                	addi	a4,a4,1
    80001eea:	16e4bc23          	sd	a4,376(s1)
          if (p->last_run > 0) {
    80001eee:	1804b703          	ld	a4,384(s1)
    80001ef2:	cb09                	beqz	a4,80001f04 <scheduler+0x198>
          now = ticks;
    80001ef4:	1782                	slli	a5,a5,0x20
    80001ef6:	9381                	srli	a5,a5,0x20
            p->cpu_time += (now - p->last_run);
    80001ef8:	1684b683          	ld	a3,360(s1)
    80001efc:	97b6                	add	a5,a5,a3
    80001efe:	8f99                	sub	a5,a5,a4
    80001f00:	16f4b423          	sd	a5,360(s1)
          c->proc = 0;
    80001f04:	020b3823          	sd	zero,48(s6)
          release(&p->lock);
    80001f08:	8526                	mv	a0,s1
    80001f0a:	d13fe0ef          	jal	80000c1c <release>
    if (found == 0) {
    80001f0e:	bf31                	j	80001e2a <scheduler+0xbe>

0000000080001f10 <sched>:
{
    80001f10:	7179                	addi	sp,sp,-48
    80001f12:	f406                	sd	ra,40(sp)
    80001f14:	f022                	sd	s0,32(sp)
    80001f16:	ec26                	sd	s1,24(sp)
    80001f18:	e84a                	sd	s2,16(sp)
    80001f1a:	e44e                	sd	s3,8(sp)
    80001f1c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f1e:	985ff0ef          	jal	800018a2 <myproc>
    80001f22:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f24:	c0dfe0ef          	jal	80000b30 <holding>
    80001f28:	c92d                	beqz	a0,80001f9a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f2a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f2c:	2781                	sext.w	a5,a5
    80001f2e:	079e                	slli	a5,a5,0x7
    80001f30:	00011717          	auipc	a4,0x11
    80001f34:	77070713          	addi	a4,a4,1904 # 800136a0 <pid_lock>
    80001f38:	97ba                	add	a5,a5,a4
    80001f3a:	0a87a703          	lw	a4,168(a5)
    80001f3e:	4785                	li	a5,1
    80001f40:	06f71363          	bne	a4,a5,80001fa6 <sched+0x96>
  if (p->state == RUNNING)
    80001f44:	4c98                	lw	a4,24(s1)
    80001f46:	4791                	li	a5,4
    80001f48:	06f70563          	beq	a4,a5,80001fb2 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f4c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f50:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f52:	e7b5                	bnez	a5,80001fbe <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f54:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f56:	00011917          	auipc	s2,0x11
    80001f5a:	74a90913          	addi	s2,s2,1866 # 800136a0 <pid_lock>
    80001f5e:	2781                	sext.w	a5,a5
    80001f60:	079e                	slli	a5,a5,0x7
    80001f62:	97ca                	add	a5,a5,s2
    80001f64:	0ac7a983          	lw	s3,172(a5)
    80001f68:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f6a:	2781                	sext.w	a5,a5
    80001f6c:	079e                	slli	a5,a5,0x7
    80001f6e:	00011597          	auipc	a1,0x11
    80001f72:	76a58593          	addi	a1,a1,1898 # 800136d8 <cpus+0x8>
    80001f76:	95be                	add	a1,a1,a5
    80001f78:	06048513          	addi	a0,s1,96
    80001f7c:	62a000ef          	jal	800025a6 <swtch>
    80001f80:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f82:	2781                	sext.w	a5,a5
    80001f84:	079e                	slli	a5,a5,0x7
    80001f86:	993e                	add	s2,s2,a5
    80001f88:	0b392623          	sw	s3,172(s2)
}
    80001f8c:	70a2                	ld	ra,40(sp)
    80001f8e:	7402                	ld	s0,32(sp)
    80001f90:	64e2                	ld	s1,24(sp)
    80001f92:	6942                	ld	s2,16(sp)
    80001f94:	69a2                	ld	s3,8(sp)
    80001f96:	6145                	addi	sp,sp,48
    80001f98:	8082                	ret
    panic("sched p->lock");
    80001f9a:	00006517          	auipc	a0,0x6
    80001f9e:	1fe50513          	addi	a0,a0,510 # 80008198 <etext+0x198>
    80001fa2:	84ffe0ef          	jal	800007f0 <panic>
    panic("sched locks");
    80001fa6:	00006517          	auipc	a0,0x6
    80001faa:	20250513          	addi	a0,a0,514 # 800081a8 <etext+0x1a8>
    80001fae:	843fe0ef          	jal	800007f0 <panic>
    panic("sched RUNNING");
    80001fb2:	00006517          	auipc	a0,0x6
    80001fb6:	20650513          	addi	a0,a0,518 # 800081b8 <etext+0x1b8>
    80001fba:	837fe0ef          	jal	800007f0 <panic>
    panic("sched interruptible");
    80001fbe:	00006517          	auipc	a0,0x6
    80001fc2:	20a50513          	addi	a0,a0,522 # 800081c8 <etext+0x1c8>
    80001fc6:	82bfe0ef          	jal	800007f0 <panic>

0000000080001fca <yield>:
{
    80001fca:	1101                	addi	sp,sp,-32
    80001fcc:	ec06                	sd	ra,24(sp)
    80001fce:	e822                	sd	s0,16(sp)
    80001fd0:	e426                	sd	s1,8(sp)
    80001fd2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fd4:	8cfff0ef          	jal	800018a2 <myproc>
    80001fd8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fda:	bb7fe0ef          	jal	80000b90 <acquire>
  p->state = RUNNABLE;
    80001fde:	478d                	li	a5,3
    80001fe0:	cc9c                	sw	a5,24(s1)
  p->ready_time = ticks;  // --- AegisOS: Record when it became ready
    80001fe2:	00009797          	auipc	a5,0x9
    80001fe6:	59e7e783          	lwu	a5,1438(a5) # 8000b580 <ticks>
    80001fea:	18f4b423          	sd	a5,392(s1)
  p->context_switches++;  // --- AegisOS: Count context switch 
    80001fee:	1784b783          	ld	a5,376(s1)
    80001ff2:	0785                	addi	a5,a5,1
    80001ff4:	16f4bc23          	sd	a5,376(s1)
  sched();
    80001ff8:	f19ff0ef          	jal	80001f10 <sched>
  release(&p->lock);
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	c1ffe0ef          	jal	80000c1c <release>
}
    80002002:	60e2                	ld	ra,24(sp)
    80002004:	6442                	ld	s0,16(sp)
    80002006:	64a2                	ld	s1,8(sp)
    80002008:	6105                	addi	sp,sp,32
    8000200a:	8082                	ret

000000008000200c <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    8000200c:	1101                	addi	sp,sp,-32
    8000200e:	ec06                	sd	ra,24(sp)
    80002010:	e822                	sd	s0,16(sp)
    80002012:	e426                	sd	s1,8(sp)
    80002014:	e04a                	sd	s2,0(sp)
    80002016:	1000                	addi	s0,sp,32
    80002018:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000201a:	889ff0ef          	jal	800018a2 <myproc>
    8000201e:	892a                	mv	s2,a0

  acquire(&p->lock);
    80002020:	b71fe0ef          	jal	80000b90 <acquire>
  if (chan == 0)
    80002024:	cc81                	beqz	s1,8000203c <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80002026:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    8000202a:	854a                	mv	a0,s2
    8000202c:	bf1fe0ef          	jal	80000c1c <release>
}
    80002030:	60e2                	ld	ra,24(sp)
    80002032:	6442                	ld	s0,16(sp)
    80002034:	64a2                	ld	s1,8(sp)
    80002036:	6902                	ld	s2,0(sp)
    80002038:	6105                	addi	sp,sp,32
    8000203a:	8082                	ret
    panic("sleep_prepare: zero chan");
    8000203c:	00006517          	auipc	a0,0x6
    80002040:	1a450513          	addi	a0,a0,420 # 800081e0 <etext+0x1e0>
    80002044:	facfe0ef          	jal	800007f0 <panic>

0000000080002048 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80002048:	1101                	addi	sp,sp,-32
    8000204a:	ec06                	sd	ra,24(sp)
    8000204c:	e822                	sd	s0,16(sp)
    8000204e:	e426                	sd	s1,8(sp)
    80002050:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002052:	851ff0ef          	jal	800018a2 <myproc>
    80002056:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002058:	b39fe0ef          	jal	80000b90 <acquire>
  if (p->chan != 0) {
    8000205c:	709c                	ld	a5,32(s1)
    8000205e:	cb99                	beqz	a5,80002074 <sleep+0x2c>
  // --- AegisOS: Track time before sleeping ---
    uint64 now = ticks;
    80002060:	00009797          	auipc	a5,0x9
    80002064:	5207e783          	lwu	a5,1312(a5) # 8000b580 <ticks>

    p->state = SLEEPING;
    80002068:	4709                	li	a4,2
    8000206a:	cc98                	sw	a4,24(s1)
    p->last_sleep_start = now;
    8000206c:	18f4bc23          	sd	a5,408(s1)
    sched();
    80002070:	ea1ff0ef          	jal	80001f10 <sched>
  }
  release(&p->lock);
    80002074:	8526                	mv	a0,s1
    80002076:	ba7fe0ef          	jal	80000c1c <release>
}
    8000207a:	60e2                	ld	ra,24(sp)
    8000207c:	6442                	ld	s0,16(sp)
    8000207e:	64a2                	ld	s1,8(sp)
    80002080:	6105                	addi	sp,sp,32
    80002082:	8082                	ret

0000000080002084 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80002084:	7139                	addi	sp,sp,-64
    80002086:	fc06                	sd	ra,56(sp)
    80002088:	f822                	sd	s0,48(sp)
    8000208a:	f426                	sd	s1,40(sp)
    8000208c:	f04a                	sd	s2,32(sp)
    8000208e:	ec4e                	sd	s3,24(sp)
    80002090:	e852                	sd	s4,16(sp)
    80002092:	e456                	sd	s5,8(sp)
    80002094:	e05a                	sd	s6,0(sp)
    80002096:	0080                	addi	s0,sp,64
    80002098:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000209a:	00012497          	auipc	s1,0x12
    8000209e:	a3648493          	addi	s1,s1,-1482 # 80013ad0 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    800020a2:	4a09                	li	s4,2
      // --- AegisOS: Track time spent sleeping ---
        uint64 now = ticks;
    800020a4:	00009b17          	auipc	s6,0x9
    800020a8:	4dcb0b13          	addi	s6,s6,1244 # 8000b580 <ticks>
        if (p->last_sleep_start > 0) {
          p->sleep_time += (now - p->last_sleep_start);
        }
 
        p->state = RUNNABLE;
    800020ac:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800020ae:	00018997          	auipc	s3,0x18
    800020b2:	62298993          	addi	s3,s3,1570 # 8001a6d0 <tickslock>
    800020b6:	a821                	j	800020ce <wakeup+0x4a>
        p->state = RUNNABLE;
    800020b8:	0154ac23          	sw	s5,24(s1)
        p->ready_time = ticks;  // --- AegisOS: Record when it became ready
    800020bc:	18e4b423          	sd	a4,392(s1)
      }
    }
    release(&p->lock);
    800020c0:	8526                	mv	a0,s1
    800020c2:	b5bfe0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020c6:	1b048493          	addi	s1,s1,432
    800020ca:	03348963          	beq	s1,s3,800020fc <wakeup+0x78>
    acquire(&p->lock);
    800020ce:	8526                	mv	a0,s1
    800020d0:	ac1fe0ef          	jal	80000b90 <acquire>
    if (p->chan == chan) {
    800020d4:	709c                	ld	a5,32(s1)
    800020d6:	ff2795e3          	bne	a5,s2,800020c0 <wakeup+0x3c>
      p->chan = 0;
    800020da:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800020de:	4c9c                	lw	a5,24(s1)
    800020e0:	ff4790e3          	bne	a5,s4,800020c0 <wakeup+0x3c>
        uint64 now = ticks;
    800020e4:	000b6703          	lwu	a4,0(s6)
        if (p->last_sleep_start > 0) {
    800020e8:	1984b683          	ld	a3,408(s1)
    800020ec:	d6f1                	beqz	a3,800020b8 <wakeup+0x34>
          p->sleep_time += (now - p->last_sleep_start);
    800020ee:	1904b783          	ld	a5,400(s1)
    800020f2:	97ba                	add	a5,a5,a4
    800020f4:	8f95                	sub	a5,a5,a3
    800020f6:	18f4b823          	sd	a5,400(s1)
    800020fa:	bf7d                	j	800020b8 <wakeup+0x34>
  }
}
    800020fc:	70e2                	ld	ra,56(sp)
    800020fe:	7442                	ld	s0,48(sp)
    80002100:	74a2                	ld	s1,40(sp)
    80002102:	7902                	ld	s2,32(sp)
    80002104:	69e2                	ld	s3,24(sp)
    80002106:	6a42                	ld	s4,16(sp)
    80002108:	6aa2                	ld	s5,8(sp)
    8000210a:	6b02                	ld	s6,0(sp)
    8000210c:	6121                	addi	sp,sp,64
    8000210e:	8082                	ret

0000000080002110 <reparent>:
{
    80002110:	7179                	addi	sp,sp,-48
    80002112:	f406                	sd	ra,40(sp)
    80002114:	f022                	sd	s0,32(sp)
    80002116:	ec26                	sd	s1,24(sp)
    80002118:	e84a                	sd	s2,16(sp)
    8000211a:	e44e                	sd	s3,8(sp)
    8000211c:	e052                	sd	s4,0(sp)
    8000211e:	1800                	addi	s0,sp,48
    80002120:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002122:	00012497          	auipc	s1,0x12
    80002126:	9ae48493          	addi	s1,s1,-1618 # 80013ad0 <proc>
      pp->parent = initproc;
    8000212a:	00009a17          	auipc	s4,0x9
    8000212e:	43ea0a13          	addi	s4,s4,1086 # 8000b568 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002132:	00018997          	auipc	s3,0x18
    80002136:	59e98993          	addi	s3,s3,1438 # 8001a6d0 <tickslock>
    8000213a:	a029                	j	80002144 <reparent+0x34>
    8000213c:	1b048493          	addi	s1,s1,432
    80002140:	01348b63          	beq	s1,s3,80002156 <reparent+0x46>
    if (pp->parent == p) {
    80002144:	7c9c                	ld	a5,56(s1)
    80002146:	ff279be3          	bne	a5,s2,8000213c <reparent+0x2c>
      pp->parent = initproc;
    8000214a:	000a3503          	ld	a0,0(s4)
    8000214e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002150:	f35ff0ef          	jal	80002084 <wakeup>
    80002154:	b7e5                	j	8000213c <reparent+0x2c>
}
    80002156:	70a2                	ld	ra,40(sp)
    80002158:	7402                	ld	s0,32(sp)
    8000215a:	64e2                	ld	s1,24(sp)
    8000215c:	6942                	ld	s2,16(sp)
    8000215e:	69a2                	ld	s3,8(sp)
    80002160:	6a02                	ld	s4,0(sp)
    80002162:	6145                	addi	sp,sp,48
    80002164:	8082                	ret

0000000080002166 <kexit>:
{
    80002166:	7179                	addi	sp,sp,-48
    80002168:	f406                	sd	ra,40(sp)
    8000216a:	f022                	sd	s0,32(sp)
    8000216c:	ec26                	sd	s1,24(sp)
    8000216e:	e84a                	sd	s2,16(sp)
    80002170:	e44e                	sd	s3,8(sp)
    80002172:	e052                	sd	s4,0(sp)
    80002174:	1800                	addi	s0,sp,48
    80002176:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002178:	f2aff0ef          	jal	800018a2 <myproc>
    8000217c:	89aa                	mv	s3,a0
  if (p == initproc)
    8000217e:	00009797          	auipc	a5,0x9
    80002182:	3ea7b783          	ld	a5,1002(a5) # 8000b568 <initproc>
    80002186:	0d050493          	addi	s1,a0,208
    8000218a:	15050913          	addi	s2,a0,336
    8000218e:	00a79f63          	bne	a5,a0,800021ac <kexit+0x46>
    panic("init exiting");
    80002192:	00006517          	auipc	a0,0x6
    80002196:	06e50513          	addi	a0,a0,110 # 80008200 <etext+0x200>
    8000219a:	e56fe0ef          	jal	800007f0 <panic>
      fileclose(f);
    8000219e:	534020ef          	jal	800046d2 <fileclose>
      p->ofile[fd] = 0;
    800021a2:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    800021a6:	04a1                	addi	s1,s1,8
    800021a8:	01248563          	beq	s1,s2,800021b2 <kexit+0x4c>
    if (p->ofile[fd]) {
    800021ac:	6088                	ld	a0,0(s1)
    800021ae:	f965                	bnez	a0,8000219e <kexit+0x38>
    800021b0:	bfdd                	j	800021a6 <kexit+0x40>
  begin_op();
    800021b2:	074020ef          	jal	80004226 <begin_op>
  iput(p->cwd);
    800021b6:	1509b503          	ld	a0,336(s3)
    800021ba:	7a6010ef          	jal	80003960 <iput>
  end_op();
    800021be:	0ee020ef          	jal	800042ac <end_op>
  p->cwd = 0;
    800021c2:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021c6:	00011497          	auipc	s1,0x11
    800021ca:	4f248493          	addi	s1,s1,1266 # 800136b8 <wait_lock>
    800021ce:	8526                	mv	a0,s1
    800021d0:	9c1fe0ef          	jal	80000b90 <acquire>
  reparent(p);
    800021d4:	854e                	mv	a0,s3
    800021d6:	f3bff0ef          	jal	80002110 <reparent>
  wakeup(p->parent);
    800021da:	0389b503          	ld	a0,56(s3)
    800021de:	ea7ff0ef          	jal	80002084 <wakeup>
  acquire(&p->lock);
    800021e2:	854e                	mv	a0,s3
    800021e4:	9adfe0ef          	jal	80000b90 <acquire>
  p->xstate = status;
    800021e8:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800021ec:	4795                	li	a5,5
    800021ee:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	a29fe0ef          	jal	80000c1c <release>
  sched();
    800021f8:	d19ff0ef          	jal	80001f10 <sched>
  panic("zombie exit");
    800021fc:	00006517          	auipc	a0,0x6
    80002200:	01450513          	addi	a0,a0,20 # 80008210 <etext+0x210>
    80002204:	decfe0ef          	jal	800007f0 <panic>

0000000080002208 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002208:	7179                	addi	sp,sp,-48
    8000220a:	f406                	sd	ra,40(sp)
    8000220c:	f022                	sd	s0,32(sp)
    8000220e:	ec26                	sd	s1,24(sp)
    80002210:	e84a                	sd	s2,16(sp)
    80002212:	e44e                	sd	s3,8(sp)
    80002214:	1800                	addi	s0,sp,48
    80002216:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002218:	00012497          	auipc	s1,0x12
    8000221c:	8b848493          	addi	s1,s1,-1864 # 80013ad0 <proc>
    80002220:	00018997          	auipc	s3,0x18
    80002224:	4b098993          	addi	s3,s3,1200 # 8001a6d0 <tickslock>
    acquire(&p->lock);
    80002228:	8526                	mv	a0,s1
    8000222a:	967fe0ef          	jal	80000b90 <acquire>
    if (p->pid == pid) {
    8000222e:	589c                	lw	a5,48(s1)
    80002230:	01278b63          	beq	a5,s2,80002246 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002234:	8526                	mv	a0,s1
    80002236:	9e7fe0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000223a:	1b048493          	addi	s1,s1,432
    8000223e:	ff3495e3          	bne	s1,s3,80002228 <kkill+0x20>
  }
  return -1;
    80002242:	557d                	li	a0,-1
    80002244:	a819                	j	8000225a <kkill+0x52>
      p->killed = 1;
    80002246:	4785                	li	a5,1
    80002248:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    8000224a:	4c98                	lw	a4,24(s1)
    8000224c:	4789                	li	a5,2
    8000224e:	00f70d63          	beq	a4,a5,80002268 <kkill+0x60>
      release(&p->lock);
    80002252:	8526                	mv	a0,s1
    80002254:	9c9fe0ef          	jal	80000c1c <release>
      return 0;
    80002258:	4501                	li	a0,0
}
    8000225a:	70a2                	ld	ra,40(sp)
    8000225c:	7402                	ld	s0,32(sp)
    8000225e:	64e2                	ld	s1,24(sp)
    80002260:	6942                	ld	s2,16(sp)
    80002262:	69a2                	ld	s3,8(sp)
    80002264:	6145                	addi	sp,sp,48
    80002266:	8082                	ret
        p->state = RUNNABLE;
    80002268:	478d                	li	a5,3
    8000226a:	cc9c                	sw	a5,24(s1)
    8000226c:	b7dd                	j	80002252 <kkill+0x4a>

000000008000226e <setkilled>:

void
setkilled(struct proc *p)
{
    8000226e:	1101                	addi	sp,sp,-32
    80002270:	ec06                	sd	ra,24(sp)
    80002272:	e822                	sd	s0,16(sp)
    80002274:	e426                	sd	s1,8(sp)
    80002276:	1000                	addi	s0,sp,32
    80002278:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000227a:	917fe0ef          	jal	80000b90 <acquire>
  p->killed = 1;
    8000227e:	4785                	li	a5,1
    80002280:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002282:	8526                	mv	a0,s1
    80002284:	999fe0ef          	jal	80000c1c <release>
}
    80002288:	60e2                	ld	ra,24(sp)
    8000228a:	6442                	ld	s0,16(sp)
    8000228c:	64a2                	ld	s1,8(sp)
    8000228e:	6105                	addi	sp,sp,32
    80002290:	8082                	ret

0000000080002292 <killed>:

int
killed(struct proc *p)
{
    80002292:	1101                	addi	sp,sp,-32
    80002294:	ec06                	sd	ra,24(sp)
    80002296:	e822                	sd	s0,16(sp)
    80002298:	e426                	sd	s1,8(sp)
    8000229a:	e04a                	sd	s2,0(sp)
    8000229c:	1000                	addi	s0,sp,32
    8000229e:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800022a0:	8f1fe0ef          	jal	80000b90 <acquire>
  k = p->killed;
    800022a4:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	973fe0ef          	jal	80000c1c <release>
  return k;
}
    800022ae:	854a                	mv	a0,s2
    800022b0:	60e2                	ld	ra,24(sp)
    800022b2:	6442                	ld	s0,16(sp)
    800022b4:	64a2                	ld	s1,8(sp)
    800022b6:	6902                	ld	s2,0(sp)
    800022b8:	6105                	addi	sp,sp,32
    800022ba:	8082                	ret

00000000800022bc <kwait>:
{
    800022bc:	715d                	addi	sp,sp,-80
    800022be:	e486                	sd	ra,72(sp)
    800022c0:	e0a2                	sd	s0,64(sp)
    800022c2:	fc26                	sd	s1,56(sp)
    800022c4:	f84a                	sd	s2,48(sp)
    800022c6:	f44e                	sd	s3,40(sp)
    800022c8:	f052                	sd	s4,32(sp)
    800022ca:	ec56                	sd	s5,24(sp)
    800022cc:	e85a                	sd	s6,16(sp)
    800022ce:	e45e                	sd	s7,8(sp)
    800022d0:	e062                	sd	s8,0(sp)
    800022d2:	0880                	addi	s0,sp,80
    800022d4:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022d6:	dccff0ef          	jal	800018a2 <myproc>
    800022da:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022dc:	00011517          	auipc	a0,0x11
    800022e0:	3dc50513          	addi	a0,a0,988 # 800136b8 <wait_lock>
    800022e4:	8adfe0ef          	jal	80000b90 <acquire>
    havekids = 0;
    800022e8:	4c01                	li	s8,0
        if (pp->state == ZOMBIE) {
    800022ea:	4a15                	li	s4,5
        havekids = 1;
    800022ec:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022ee:	00018997          	auipc	s3,0x18
    800022f2:	3e298993          	addi	s3,s3,994 # 8001a6d0 <tickslock>
    release(&wait_lock);
    800022f6:	00011b97          	auipc	s7,0x11
    800022fa:	3c2b8b93          	addi	s7,s7,962 # 800136b8 <wait_lock>
    800022fe:	a84d                	j	800023b0 <kwait+0xf4>
          pid = pp->pid;
    80002300:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    80002304:	000b0e63          	beqz	s6,80002320 <kwait+0x64>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002308:	4711                	li	a4,4
    8000230a:	02c48693          	addi	a3,s1,44
    8000230e:	865a                	mv	a2,s6
    80002310:	04893583          	ld	a1,72(s2)
    80002314:	05093503          	ld	a0,80(s2)
    80002318:	9c0ff0ef          	jal	800014d8 <copyout>
          if (addr != 0 &&
    8000231c:	02054d63          	bltz	a0,80002356 <kwait+0x9a>
          pp->parent = 0;
    80002320:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    80002324:	8526                	mv	a0,s1
    80002326:	f58ff0ef          	jal	80001a7e <freeproc>
          release(&pp->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	8f1fe0ef          	jal	80000c1c <release>
          release(&wait_lock);
    80002330:	00011517          	auipc	a0,0x11
    80002334:	38850513          	addi	a0,a0,904 # 800136b8 <wait_lock>
    80002338:	8e5fe0ef          	jal	80000c1c <release>
}
    8000233c:	854e                	mv	a0,s3
    8000233e:	60a6                	ld	ra,72(sp)
    80002340:	6406                	ld	s0,64(sp)
    80002342:	74e2                	ld	s1,56(sp)
    80002344:	7942                	ld	s2,48(sp)
    80002346:	79a2                	ld	s3,40(sp)
    80002348:	7a02                	ld	s4,32(sp)
    8000234a:	6ae2                	ld	s5,24(sp)
    8000234c:	6b42                	ld	s6,16(sp)
    8000234e:	6ba2                	ld	s7,8(sp)
    80002350:	6c02                	ld	s8,0(sp)
    80002352:	6161                	addi	sp,sp,80
    80002354:	8082                	ret
            release(&pp->lock);
    80002356:	8526                	mv	a0,s1
    80002358:	8c5fe0ef          	jal	80000c1c <release>
            release(&wait_lock);
    8000235c:	00011517          	auipc	a0,0x11
    80002360:	35c50513          	addi	a0,a0,860 # 800136b8 <wait_lock>
    80002364:	8b9fe0ef          	jal	80000c1c <release>
            return -1;
    80002368:	59fd                	li	s3,-1
    8000236a:	bfc9                	j	8000233c <kwait+0x80>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000236c:	1b048493          	addi	s1,s1,432
    80002370:	03348063          	beq	s1,s3,80002390 <kwait+0xd4>
      if (pp->parent == p) {
    80002374:	7c9c                	ld	a5,56(s1)
    80002376:	ff279be3          	bne	a5,s2,8000236c <kwait+0xb0>
        acquire(&pp->lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	815fe0ef          	jal	80000b90 <acquire>
        if (pp->state == ZOMBIE) {
    80002380:	4c9c                	lw	a5,24(s1)
    80002382:	f7478fe3          	beq	a5,s4,80002300 <kwait+0x44>
        release(&pp->lock);
    80002386:	8526                	mv	a0,s1
    80002388:	895fe0ef          	jal	80000c1c <release>
        havekids = 1;
    8000238c:	8756                	mv	a4,s5
    8000238e:	bff9                	j	8000236c <kwait+0xb0>
    if (!havekids || killed(p)) {
    80002390:	c715                	beqz	a4,800023bc <kwait+0x100>
    80002392:	854a                	mv	a0,s2
    80002394:	effff0ef          	jal	80002292 <killed>
    80002398:	e115                	bnez	a0,800023bc <kwait+0x100>
    sleep_prepare(p); //DOC: wait-sleep
    8000239a:	854a                	mv	a0,s2
    8000239c:	c71ff0ef          	jal	8000200c <sleep_prepare>
    release(&wait_lock);
    800023a0:	855e                	mv	a0,s7
    800023a2:	87bfe0ef          	jal	80000c1c <release>
    sleep();
    800023a6:	ca3ff0ef          	jal	80002048 <sleep>
    acquire(&wait_lock);
    800023aa:	855e                	mv	a0,s7
    800023ac:	fe4fe0ef          	jal	80000b90 <acquire>
    havekids = 0;
    800023b0:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023b2:	00011497          	auipc	s1,0x11
    800023b6:	71e48493          	addi	s1,s1,1822 # 80013ad0 <proc>
    800023ba:	bf6d                	j	80002374 <kwait+0xb8>
      release(&wait_lock);
    800023bc:	00011517          	auipc	a0,0x11
    800023c0:	2fc50513          	addi	a0,a0,764 # 800136b8 <wait_lock>
    800023c4:	859fe0ef          	jal	80000c1c <release>
      return -1;
    800023c8:	59fd                	li	s3,-1
    800023ca:	bf8d                	j	8000233c <kwait+0x80>

00000000800023cc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800023cc:	7179                	addi	sp,sp,-48
    800023ce:	f406                	sd	ra,40(sp)
    800023d0:	f022                	sd	s0,32(sp)
    800023d2:	ec26                	sd	s1,24(sp)
    800023d4:	e84a                	sd	s2,16(sp)
    800023d6:	e44e                	sd	s3,8(sp)
    800023d8:	e052                	sd	s4,0(sp)
    800023da:	1800                	addi	s0,sp,48
    800023dc:	84aa                	mv	s1,a0
    800023de:	892e                	mv	s2,a1
    800023e0:	89b2                	mv	s3,a2
    800023e2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800023e4:	cbeff0ef          	jal	800018a2 <myproc>
  if (user_dst) {
    800023e8:	c085                	beqz	s1,80002408 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800023ea:	8752                	mv	a4,s4
    800023ec:	86ce                	mv	a3,s3
    800023ee:	864a                	mv	a2,s2
    800023f0:	652c                	ld	a1,72(a0)
    800023f2:	6928                	ld	a0,80(a0)
    800023f4:	8e4ff0ef          	jal	800014d8 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800023f8:	70a2                	ld	ra,40(sp)
    800023fa:	7402                	ld	s0,32(sp)
    800023fc:	64e2                	ld	s1,24(sp)
    800023fe:	6942                	ld	s2,16(sp)
    80002400:	69a2                	ld	s3,8(sp)
    80002402:	6a02                	ld	s4,0(sp)
    80002404:	6145                	addi	sp,sp,48
    80002406:	8082                	ret
    memmove((char *)dst, src, len);
    80002408:	000a061b          	sext.w	a2,s4
    8000240c:	85ce                	mv	a1,s3
    8000240e:	854a                	mv	a0,s2
    80002410:	8a1fe0ef          	jal	80000cb0 <memmove>
    return 0;
    80002414:	8526                	mv	a0,s1
    80002416:	b7cd                	j	800023f8 <either_copyout+0x2c>

0000000080002418 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002418:	7179                	addi	sp,sp,-48
    8000241a:	f406                	sd	ra,40(sp)
    8000241c:	f022                	sd	s0,32(sp)
    8000241e:	ec26                	sd	s1,24(sp)
    80002420:	e84a                	sd	s2,16(sp)
    80002422:	e44e                	sd	s3,8(sp)
    80002424:	e052                	sd	s4,0(sp)
    80002426:	1800                	addi	s0,sp,48
    80002428:	892a                	mv	s2,a0
    8000242a:	84ae                	mv	s1,a1
    8000242c:	89b2                	mv	s3,a2
    8000242e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002430:	c72ff0ef          	jal	800018a2 <myproc>
  if (user_src) {
    80002434:	c085                	beqz	s1,80002454 <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    80002436:	8752                	mv	a4,s4
    80002438:	86ce                	mv	a3,s3
    8000243a:	864a                	mv	a2,s2
    8000243c:	652c                	ld	a1,72(a0)
    8000243e:	6928                	ld	a0,80(a0)
    80002440:	984ff0ef          	jal	800015c4 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002444:	70a2                	ld	ra,40(sp)
    80002446:	7402                	ld	s0,32(sp)
    80002448:	64e2                	ld	s1,24(sp)
    8000244a:	6942                	ld	s2,16(sp)
    8000244c:	69a2                	ld	s3,8(sp)
    8000244e:	6a02                	ld	s4,0(sp)
    80002450:	6145                	addi	sp,sp,48
    80002452:	8082                	ret
    memmove(dst, (char *)src, len);
    80002454:	000a061b          	sext.w	a2,s4
    80002458:	85ce                	mv	a1,s3
    8000245a:	854a                	mv	a0,s2
    8000245c:	855fe0ef          	jal	80000cb0 <memmove>
    return 0;
    80002460:	8526                	mv	a0,s1
    80002462:	b7cd                	j	80002444 <either_copyin+0x2c>

0000000080002464 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002464:	715d                	addi	sp,sp,-80
    80002466:	e486                	sd	ra,72(sp)
    80002468:	e0a2                	sd	s0,64(sp)
    8000246a:	fc26                	sd	s1,56(sp)
    8000246c:	f84a                	sd	s2,48(sp)
    8000246e:	f44e                	sd	s3,40(sp)
    80002470:	f052                	sd	s4,32(sp)
    80002472:	ec56                	sd	s5,24(sp)
    80002474:	e85a                	sd	s6,16(sp)
    80002476:	e45e                	sd	s7,8(sp)
    80002478:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    8000247a:	00006517          	auipc	a0,0x6
    8000247e:	bfe50513          	addi	a0,a0,-1026 # 80008078 <etext+0x78>
    80002482:	888fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002486:	00011497          	auipc	s1,0x11
    8000248a:	7a248493          	addi	s1,s1,1954 # 80013c28 <proc+0x158>
    8000248e:	00018917          	auipc	s2,0x18
    80002492:	39a90913          	addi	s2,s2,922 # 8001a828 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002496:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002498:	00006997          	auipc	s3,0x6
    8000249c:	d8898993          	addi	s3,s3,-632 # 80008220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    800024a0:	00006a97          	auipc	s5,0x6
    800024a4:	d88a8a93          	addi	s5,s5,-632 # 80008228 <etext+0x228>
    printk("\n");
    800024a8:	00006a17          	auipc	s4,0x6
    800024ac:	bd0a0a13          	addi	s4,s4,-1072 # 80008078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024b0:	00006b97          	auipc	s7,0x6
    800024b4:	468b8b93          	addi	s7,s7,1128 # 80008918 <states.0>
    800024b8:	a829                	j	800024d2 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    800024ba:	ed86a583          	lw	a1,-296(a3)
    800024be:	8556                	mv	a0,s5
    800024c0:	84afe0ef          	jal	8000050a <printk>
    printk("\n");
    800024c4:	8552                	mv	a0,s4
    800024c6:	844fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024ca:	1b048493          	addi	s1,s1,432
    800024ce:	03248263          	beq	s1,s2,800024f2 <procdump+0x8e>
    if (p->state == UNUSED)
    800024d2:	86a6                	mv	a3,s1
    800024d4:	ec04a783          	lw	a5,-320(s1)
    800024d8:	dbed                	beqz	a5,800024ca <procdump+0x66>
      state = "???";
    800024da:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024dc:	fcfb6fe3          	bltu	s6,a5,800024ba <procdump+0x56>
    800024e0:	02079713          	slli	a4,a5,0x20
    800024e4:	01d75793          	srli	a5,a4,0x1d
    800024e8:	97de                	add	a5,a5,s7
    800024ea:	6390                	ld	a2,0(a5)
    800024ec:	f679                	bnez	a2,800024ba <procdump+0x56>
      state = "???";
    800024ee:	864e                	mv	a2,s3
    800024f0:	b7e9                	j	800024ba <procdump+0x56>
  }
}
    800024f2:	60a6                	ld	ra,72(sp)
    800024f4:	6406                	ld	s0,64(sp)
    800024f6:	74e2                	ld	s1,56(sp)
    800024f8:	7942                	ld	s2,48(sp)
    800024fa:	79a2                	ld	s3,40(sp)
    800024fc:	7a02                	ld	s4,32(sp)
    800024fe:	6ae2                	ld	s5,24(sp)
    80002500:	6b42                	ld	s6,16(sp)
    80002502:	6ba2                	ld	s7,8(sp)
    80002504:	6161                	addi	sp,sp,80
    80002506:	8082                	ret

0000000080002508 <mlfq_boost>:
}
*/   
// Boost all processes to highest priority (aging)
static void __attribute__((used))
mlfq_boost(void)
{
    80002508:	1101                	addi	sp,sp,-32
    8000250a:	ec06                	sd	ra,24(sp)
    8000250c:	e822                	sd	s0,16(sp)
    8000250e:	e426                	sd	s1,8(sp)
    80002510:	e04a                	sd	s2,0(sp)
    80002512:	1000                	addi	s0,sp,32
  struct proc *p;
  
  for (p = proc; p < &proc[NPROC]; p++) {
    80002514:	00011497          	auipc	s1,0x11
    80002518:	5bc48493          	addi	s1,s1,1468 # 80013ad0 <proc>
    8000251c:	00018917          	auipc	s2,0x18
    80002520:	1b490913          	addi	s2,s2,436 # 8001a6d0 <tickslock>
    80002524:	a801                	j	80002534 <mlfq_boost+0x2c>
    acquire(&p->lock);
    if (p->state != UNUSED) {
      p->mlfq_level = MLFQ_HIGH;
      p->mlfq_ticks = 0;
    }
    release(&p->lock);
    80002526:	8526                	mv	a0,s1
    80002528:	ef4fe0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000252c:	1b048493          	addi	s1,s1,432
    80002530:	01248c63          	beq	s1,s2,80002548 <mlfq_boost+0x40>
    acquire(&p->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	e5afe0ef          	jal	80000b90 <acquire>
    if (p->state != UNUSED) {
    8000253a:	4c9c                	lw	a5,24(s1)
    8000253c:	d7ed                	beqz	a5,80002526 <mlfq_boost+0x1e>
      p->mlfq_level = MLFQ_HIGH;
    8000253e:	1a04a023          	sw	zero,416(s1)
      p->mlfq_ticks = 0;
    80002542:	1a04a223          	sw	zero,420(s1)
    80002546:	b7c5                	j	80002526 <mlfq_boost+0x1e>
  }
  printk("MLFQ: All processes boosted to highest priority\n");
    80002548:	00006517          	auipc	a0,0x6
    8000254c:	cf050513          	addi	a0,a0,-784 # 80008238 <etext+0x238>
    80002550:	fbbfd0ef          	jal	8000050a <printk>
}
    80002554:	60e2                	ld	ra,24(sp)
    80002556:	6442                	ld	s0,16(sp)
    80002558:	64a2                	ld	s1,8(sp)
    8000255a:	6902                	ld	s2,0(sp)
    8000255c:	6105                	addi	sp,sp,32
    8000255e:	8082                	ret

0000000080002560 <mlfq_update_priority>:
// Update process priority based on behavior
static void __attribute__((used))
mlfq_update_priority(struct proc *p)
{
  // If process used its full quantum, demote it
  if (p->mlfq_ticks >= time_quantum) {
    80002560:	1a452703          	lw	a4,420(a0)
    80002564:	00009797          	auipc	a5,0x9
    80002568:	fc47a783          	lw	a5,-60(a5) # 8000b528 <time_quantum>
    8000256c:	00f74763          	blt	a4,a5,8000257a <mlfq_update_priority+0x1a>
    if (p->mlfq_level < MLFQ_LOW) {
    80002570:	1a052603          	lw	a2,416(a0)
    80002574:	4785                	li	a5,1
    80002576:	00c7d363          	bge	a5,a2,8000257c <mlfq_update_priority+0x1c>
    8000257a:	8082                	ret
{
    8000257c:	1141                	addi	sp,sp,-16
    8000257e:	e406                	sd	ra,8(sp)
    80002580:	e022                	sd	s0,0(sp)
    80002582:	0800                	addi	s0,sp,16
      p->mlfq_level++;
    80002584:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80002586:	1ac52023          	sw	a2,416(a0)
      p->mlfq_ticks = 0;
    8000258a:	1a052223          	sw	zero,420(a0)
      printk("MLFQ: Process %d demoted to level %d\n", p->pid, p->mlfq_level);
    8000258e:	2601                	sext.w	a2,a2
    80002590:	590c                	lw	a1,48(a0)
    80002592:	00006517          	auipc	a0,0x6
    80002596:	cde50513          	addi	a0,a0,-802 # 80008270 <etext+0x270>
    8000259a:	f71fd0ef          	jal	8000050a <printk>
    }
  }
}
    8000259e:	60a2                	ld	ra,8(sp)
    800025a0:	6402                	ld	s0,0(sp)
    800025a2:	0141                	addi	sp,sp,16
    800025a4:	8082                	ret

00000000800025a6 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025a6:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025aa:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025ae:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025b0:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025b2:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025b6:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025ba:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025be:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025c2:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025c6:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025ca:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025ce:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800025d2:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800025d6:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800025da:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800025de:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800025e2:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800025e4:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800025e6:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800025ea:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800025ee:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800025f2:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800025f6:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800025fa:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800025fe:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002602:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002606:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000260a:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000260e:	8082                	ret

0000000080002610 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002610:	1141                	addi	sp,sp,-16
    80002612:	e406                	sd	ra,8(sp)
    80002614:	e022                	sd	s0,0(sp)
    80002616:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002618:	00006597          	auipc	a1,0x6
    8000261c:	cb058593          	addi	a1,a1,-848 # 800082c8 <etext+0x2c8>
    80002620:	00018517          	auipc	a0,0x18
    80002624:	0b050513          	addi	a0,a0,176 # 8001a6d0 <tickslock>
    80002628:	cf2fe0ef          	jal	80000b1a <initlock>
}
    8000262c:	60a2                	ld	ra,8(sp)
    8000262e:	6402                	ld	s0,0(sp)
    80002630:	0141                	addi	sp,sp,16
    80002632:	8082                	ret

0000000080002634 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002634:	1141                	addi	sp,sp,-16
    80002636:	e422                	sd	s0,8(sp)
    80002638:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000263a:	00003797          	auipc	a5,0x3
    8000263e:	4e678793          	addi	a5,a5,1254 # 80005b20 <kernelvec>
    80002642:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002646:	6422                	ld	s0,8(sp)
    80002648:	0141                	addi	sp,sp,16
    8000264a:	8082                	ret

000000008000264c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000264c:	1141                	addi	sp,sp,-16
    8000264e:	e406                	sd	ra,8(sp)
    80002650:	e022                	sd	s0,0(sp)
    80002652:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002654:	a4eff0ef          	jal	800018a2 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002658:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000265c:	04000737          	lui	a4,0x4000
    80002660:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002662:	0732                	slli	a4,a4,0xc
    80002664:	00005797          	auipc	a5,0x5
    80002668:	99c78793          	addi	a5,a5,-1636 # 80007000 <_trampoline>
    8000266c:	00005697          	auipc	a3,0x5
    80002670:	99468693          	addi	a3,a3,-1644 # 80007000 <_trampoline>
    80002674:	8f95                	sub	a5,a5,a3
    80002676:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002678:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000267c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    8000267e:	18002773          	csrr	a4,satp
    80002682:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002684:	6d38                	ld	a4,88(a0)
    80002686:	613c                	ld	a5,64(a0)
    80002688:	6685                	lui	a3,0x1
    8000268a:	97b6                	add	a5,a5,a3
    8000268c:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000268e:	6d3c                	ld	a5,88(a0)
    80002690:	00000717          	auipc	a4,0x0
    80002694:	1bc70713          	addi	a4,a4,444 # 8000284c <usertrap>
    80002698:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000269a:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000269c:	8712                	mv	a4,tp
    8000269e:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026a0:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026a4:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026a8:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800026ac:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026b0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800026b2:	6f9c                	ld	a5,24(a5)
    800026b4:	14179073          	csrw	sepc,a5
}
    800026b8:	60a2                	ld	ra,8(sp)
    800026ba:	6402                	ld	s0,0(sp)
    800026bc:	0141                	addi	sp,sp,16
    800026be:	8082                	ret

00000000800026c0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026c0:	1101                	addi	sp,sp,-32
    800026c2:	ec06                	sd	ra,24(sp)
    800026c4:	e822                	sd	s0,16(sp)
    800026c6:	1000                	addi	s0,sp,32
  // Only CPU 0 handles ticks
  if (cpuid() == 0) {
    800026c8:	9aeff0ef          	jal	80001876 <cpuid>
    800026cc:	cd11                	beqz	a0,800026e8 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800026ce:	c01027f3          	rdtime	a5
  }
  
  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026d2:	000f4737          	lui	a4,0xf4
    800026d6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026da:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800026dc:	14d79073          	csrw	stimecmp,a5
}
    800026e0:	60e2                	ld	ra,24(sp)
    800026e2:	6442                	ld	s0,16(sp)
    800026e4:	6105                	addi	sp,sp,32
    800026e6:	8082                	ret
    800026e8:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800026ea:	00018497          	auipc	s1,0x18
    800026ee:	fe648493          	addi	s1,s1,-26 # 8001a6d0 <tickslock>
    800026f2:	8526                	mv	a0,s1
    800026f4:	c9cfe0ef          	jal	80000b90 <acquire>
    ticks++;
    800026f8:	00009517          	auipc	a0,0x9
    800026fc:	e8850513          	addi	a0,a0,-376 # 8000b580 <ticks>
    80002700:	411c                	lw	a5,0(a0)
    80002702:	2785                	addiw	a5,a5,1
    80002704:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002706:	97fff0ef          	jal	80002084 <wakeup>
    release(&tickslock);
    8000270a:	8526                	mv	a0,s1
    8000270c:	d10fe0ef          	jal	80000c1c <release>
    if (scheduler_policy == 1) {  // SCHED_MLFQ = 1
    80002710:	00009717          	auipc	a4,0x9
    80002714:	e6072703          	lw	a4,-416(a4) # 8000b570 <scheduler_policy>
    80002718:	4785                	li	a5,1
    8000271a:	02f70963          	beq	a4,a5,8000274c <clockintr+0x8c>
    if (ticks - last_boost > 100) {
    8000271e:	00009797          	auipc	a5,0x9
    80002722:	e627e783          	lwu	a5,-414(a5) # 8000b580 <ticks>
    80002726:	00009717          	auipc	a4,0x9
    8000272a:	e5273703          	ld	a4,-430(a4) # 8000b578 <last_boost.0>
    8000272e:	8f99                	sub	a5,a5,a4
    80002730:	06400713          	li	a4,100
    80002734:	0af77063          	bgeu	a4,a5,800027d4 <clockintr+0x114>
    80002738:	e04a                	sd	s2,0(sp)
      for (p = proc; p < &proc[NPROC]; p++) {
    8000273a:	00011497          	auipc	s1,0x11
    8000273e:	39648493          	addi	s1,s1,918 # 80013ad0 <proc>
    80002742:	00018917          	auipc	s2,0x18
    80002746:	f8e90913          	addi	s2,s2,-114 # 8001a6d0 <tickslock>
    8000274a:	a085                	j	800027aa <clockintr+0xea>
      struct proc *p = myproc();
    8000274c:	956ff0ef          	jal	800018a2 <myproc>
    80002750:	84aa                	mv	s1,a0
      if (p && p->state == RUNNING) {
    80002752:	d571                	beqz	a0,8000271e <clockintr+0x5e>
    80002754:	4d18                	lw	a4,24(a0)
    80002756:	4791                	li	a5,4
    80002758:	fcf713e3          	bne	a4,a5,8000271e <clockintr+0x5e>
        acquire(&p->lock);
    8000275c:	c34fe0ef          	jal	80000b90 <acquire>
        p->mlfq_ticks++;
    80002760:	1a44a783          	lw	a5,420(s1)
    80002764:	2785                	addiw	a5,a5,1
    80002766:	0007871b          	sext.w	a4,a5
    8000276a:	1af4a223          	sw	a5,420(s1)
        if (p->mlfq_ticks >= time_quantum) {
    8000276e:	00009797          	auipc	a5,0x9
    80002772:	dba7a783          	lw	a5,-582(a5) # 8000b528 <time_quantum>
    80002776:	00f74b63          	blt	a4,a5,8000278c <clockintr+0xcc>
          p->mlfq_ticks = 0;
    8000277a:	1a04a223          	sw	zero,420(s1)
          if (p->mlfq_level < 2) {  // MLFQ_LOW = 2
    8000277e:	1a04a783          	lw	a5,416(s1)
    80002782:	4705                	li	a4,1
    80002784:	00f75863          	bge	a4,a5,80002794 <clockintr+0xd4>
          p->state = RUNNABLE;
    80002788:	478d                	li	a5,3
    8000278a:	cc9c                	sw	a5,24(s1)
        release(&p->lock);
    8000278c:	8526                	mv	a0,s1
    8000278e:	c8efe0ef          	jal	80000c1c <release>
    80002792:	b771                	j	8000271e <clockintr+0x5e>
            p->mlfq_level++;
    80002794:	2785                	addiw	a5,a5,1
    80002796:	1af4a023          	sw	a5,416(s1)
    8000279a:	b7fd                	j	80002788 <clockintr+0xc8>
        release(&p->lock);
    8000279c:	8526                	mv	a0,s1
    8000279e:	c7efe0ef          	jal	80000c1c <release>
      for (p = proc; p < &proc[NPROC]; p++) {
    800027a2:	1b048493          	addi	s1,s1,432
    800027a6:	01248c63          	beq	s1,s2,800027be <clockintr+0xfe>
        acquire(&p->lock);
    800027aa:	8526                	mv	a0,s1
    800027ac:	be4fe0ef          	jal	80000b90 <acquire>
        if (p->state != UNUSED) {
    800027b0:	4c9c                	lw	a5,24(s1)
    800027b2:	d7ed                	beqz	a5,8000279c <clockintr+0xdc>
          p->mlfq_level = 0;  // MLFQ_HIGH = 0
    800027b4:	1a04a023          	sw	zero,416(s1)
          p->mlfq_ticks = 0;
    800027b8:	1a04a223          	sw	zero,420(s1)
    800027bc:	b7c5                	j	8000279c <clockintr+0xdc>
      last_boost = ticks;
    800027be:	00009797          	auipc	a5,0x9
    800027c2:	dc27e783          	lwu	a5,-574(a5) # 8000b580 <ticks>
    800027c6:	00009717          	auipc	a4,0x9
    800027ca:	daf73923          	sd	a5,-590(a4) # 8000b578 <last_boost.0>
    800027ce:	64a2                	ld	s1,8(sp)
    800027d0:	6902                	ld	s2,0(sp)
    800027d2:	bdf5                	j	800026ce <clockintr+0xe>
    800027d4:	64a2                	ld	s1,8(sp)
    800027d6:	bde5                	j	800026ce <clockintr+0xe>

00000000800027d8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027d8:	1101                	addi	sp,sp,-32
    800027da:	ec06                	sd	ra,24(sp)
    800027dc:	e822                	sd	s0,16(sp)
    800027de:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800027e0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800027e4:	57fd                	li	a5,-1
    800027e6:	17fe                	slli	a5,a5,0x3f
    800027e8:	07a5                	addi	a5,a5,9
    800027ea:	00f70c63          	beq	a4,a5,80002802 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    800027ee:	57fd                	li	a5,-1
    800027f0:	17fe                	slli	a5,a5,0x3f
    800027f2:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800027f4:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    800027f6:	04f70763          	beq	a4,a5,80002844 <devintr+0x6c>
  }
}
    800027fa:	60e2                	ld	ra,24(sp)
    800027fc:	6442                	ld	s0,16(sp)
    800027fe:	6105                	addi	sp,sp,32
    80002800:	8082                	ret
    80002802:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002804:	3c8030ef          	jal	80005bcc <plic_claim>
    80002808:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    8000280a:	47a9                	li	a5,10
    8000280c:	00f50963          	beq	a0,a5,8000281e <devintr+0x46>
    } else if (irq == VIRTIO0_IRQ) {
    80002810:	4785                	li	a5,1
    80002812:	00f50963          	beq	a0,a5,80002824 <devintr+0x4c>
    return 1;
    80002816:	4505                	li	a0,1
    } else if (irq) {
    80002818:	e889                	bnez	s1,8000282a <devintr+0x52>
    8000281a:	64a2                	ld	s1,8(sp)
    8000281c:	bff9                	j	800027fa <devintr+0x22>
      uartintr();
    8000281e:	96efe0ef          	jal	8000098c <uartintr>
    if (irq)
    80002822:	a819                	j	80002838 <devintr+0x60>
      virtio_disk_intr();
    80002824:	08d030ef          	jal	800060b0 <virtio_disk_intr>
    if (irq)
    80002828:	a801                	j	80002838 <devintr+0x60>
      printk("unexpected interrupt irq=%d\n", irq);
    8000282a:	85a6                	mv	a1,s1
    8000282c:	00006517          	auipc	a0,0x6
    80002830:	aa450513          	addi	a0,a0,-1372 # 800082d0 <etext+0x2d0>
    80002834:	cd7fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    80002838:	8526                	mv	a0,s1
    8000283a:	3b2030ef          	jal	80005bec <plic_complete>
    return 1;
    8000283e:	4505                	li	a0,1
    80002840:	64a2                	ld	s1,8(sp)
    80002842:	bf65                	j	800027fa <devintr+0x22>
    clockintr();
    80002844:	e7dff0ef          	jal	800026c0 <clockintr>
    return 2;
    80002848:	4509                	li	a0,2
    8000284a:	bf45                	j	800027fa <devintr+0x22>

000000008000284c <usertrap>:
{
    8000284c:	1101                	addi	sp,sp,-32
    8000284e:	ec06                	sd	ra,24(sp)
    80002850:	e822                	sd	s0,16(sp)
    80002852:	e426                	sd	s1,8(sp)
    80002854:	e04a                	sd	s2,0(sp)
    80002856:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002858:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000285c:	1007f793          	andi	a5,a5,256
    80002860:	eba5                	bnez	a5,800028d0 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002862:	00003797          	auipc	a5,0x3
    80002866:	2be78793          	addi	a5,a5,702 # 80005b20 <kernelvec>
    8000286a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000286e:	834ff0ef          	jal	800018a2 <myproc>
    80002872:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002874:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002876:	14102773          	csrr	a4,sepc
    8000287a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000287c:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002880:	47a1                	li	a5,8
    80002882:	04f70d63          	beq	a4,a5,800028dc <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002886:	f53ff0ef          	jal	800027d8 <devintr>
    8000288a:	892a                	mv	s2,a0
    8000288c:	e54d                	bnez	a0,80002936 <usertrap+0xea>
    8000288e:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002892:	47bd                	li	a5,15
    80002894:	08f70463          	beq	a4,a5,8000291c <usertrap+0xd0>
    80002898:	14202773          	csrr	a4,scause
    8000289c:	47b5                	li	a5,13
    8000289e:	06f70f63          	beq	a4,a5,8000291c <usertrap+0xd0>
    800028a2:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800028a6:	5890                	lw	a2,48(s1)
    800028a8:	00006517          	auipc	a0,0x6
    800028ac:	a6850513          	addi	a0,a0,-1432 # 80008310 <etext+0x310>
    800028b0:	c5bfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800028b4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800028b8:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800028bc:	00006517          	auipc	a0,0x6
    800028c0:	a8450513          	addi	a0,a0,-1404 # 80008340 <etext+0x340>
    800028c4:	c47fd0ef          	jal	8000050a <printk>
    setkilled(p);
    800028c8:	8526                	mv	a0,s1
    800028ca:	9a5ff0ef          	jal	8000226e <setkilled>
    800028ce:	a015                	j	800028f2 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    800028d0:	00006517          	auipc	a0,0x6
    800028d4:	a2050513          	addi	a0,a0,-1504 # 800082f0 <etext+0x2f0>
    800028d8:	f19fd0ef          	jal	800007f0 <panic>
    if (killed(p))
    800028dc:	9b7ff0ef          	jal	80002292 <killed>
    800028e0:	e915                	bnez	a0,80002914 <usertrap+0xc8>
    p->trapframe->epc += 4;
    800028e2:	6cb8                	ld	a4,88(s1)
    800028e4:	6f1c                	ld	a5,24(a4)
    800028e6:	0791                	addi	a5,a5,4
    800028e8:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    800028ea:	10016073          	csrsi	sstatus,2
    syscall();
    800028ee:	24a000ef          	jal	80002b38 <syscall>
  if (killed(p))
    800028f2:	8526                	mv	a0,s1
    800028f4:	99fff0ef          	jal	80002292 <killed>
    800028f8:	e521                	bnez	a0,80002940 <usertrap+0xf4>
  prepare_return();
    800028fa:	d53ff0ef          	jal	8000264c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800028fe:	68a8                	ld	a0,80(s1)
    80002900:	8131                	srli	a0,a0,0xc
    80002902:	57fd                	li	a5,-1
    80002904:	17fe                	slli	a5,a5,0x3f
    80002906:	8d5d                	or	a0,a0,a5
}
    80002908:	60e2                	ld	ra,24(sp)
    8000290a:	6442                	ld	s0,16(sp)
    8000290c:	64a2                	ld	s1,8(sp)
    8000290e:	6902                	ld	s2,0(sp)
    80002910:	6105                	addi	sp,sp,32
    80002912:	8082                	ret
      kexit(-1);
    80002914:	557d                	li	a0,-1
    80002916:	851ff0ef          	jal	80002166 <kexit>
    8000291a:	b7e1                	j	800028e2 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000291c:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002920:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002924:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002926:	0016b693          	seqz	a3,a3
    8000292a:	64ac                	ld	a1,72(s1)
    8000292c:	68a8                	ld	a0,80(s1)
    8000292e:	b2ffe0ef          	jal	8000145c <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002932:	f161                	bnez	a0,800028f2 <usertrap+0xa6>
    80002934:	b7bd                	j	800028a2 <usertrap+0x56>
  if (killed(p))
    80002936:	8526                	mv	a0,s1
    80002938:	95bff0ef          	jal	80002292 <killed>
    8000293c:	c511                	beqz	a0,80002948 <usertrap+0xfc>
    8000293e:	a011                	j	80002942 <usertrap+0xf6>
    80002940:	4901                	li	s2,0
    kexit(-1);
    80002942:	557d                	li	a0,-1
    80002944:	823ff0ef          	jal	80002166 <kexit>
  if (which_dev == 2)
    80002948:	4789                	li	a5,2
    8000294a:	faf918e3          	bne	s2,a5,800028fa <usertrap+0xae>
    yield();
    8000294e:	e7cff0ef          	jal	80001fca <yield>
    80002952:	b765                	j	800028fa <usertrap+0xae>

0000000080002954 <kerneltrap>:
{
    80002954:	7179                	addi	sp,sp,-48
    80002956:	f406                	sd	ra,40(sp)
    80002958:	f022                	sd	s0,32(sp)
    8000295a:	ec26                	sd	s1,24(sp)
    8000295c:	e84a                	sd	s2,16(sp)
    8000295e:	e44e                	sd	s3,8(sp)
    80002960:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002962:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002966:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    8000296a:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    8000296e:	1004f793          	andi	a5,s1,256
    80002972:	c795                	beqz	a5,8000299e <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002974:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002978:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000297a:	eb85                	bnez	a5,800029aa <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0) {
    8000297c:	e5dff0ef          	jal	800027d8 <devintr>
    80002980:	c91d                	beqz	a0,800029b6 <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0)
    80002982:	4789                	li	a5,2
    80002984:	04f50a63          	beq	a0,a5,800029d8 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002988:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000298c:	10049073          	csrw	sstatus,s1
}
    80002990:	70a2                	ld	ra,40(sp)
    80002992:	7402                	ld	s0,32(sp)
    80002994:	64e2                	ld	s1,24(sp)
    80002996:	6942                	ld	s2,16(sp)
    80002998:	69a2                	ld	s3,8(sp)
    8000299a:	6145                	addi	sp,sp,48
    8000299c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000299e:	00006517          	auipc	a0,0x6
    800029a2:	9ca50513          	addi	a0,a0,-1590 # 80008368 <etext+0x368>
    800029a6:	e4bfd0ef          	jal	800007f0 <panic>
    panic("kerneltrap: interrupts enabled");
    800029aa:	00006517          	auipc	a0,0x6
    800029ae:	9e650513          	addi	a0,a0,-1562 # 80008390 <etext+0x390>
    800029b2:	e3ffd0ef          	jal	800007f0 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800029b6:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800029ba:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800029be:	85ce                	mv	a1,s3
    800029c0:	00006517          	auipc	a0,0x6
    800029c4:	9f050513          	addi	a0,a0,-1552 # 800083b0 <etext+0x3b0>
    800029c8:	b43fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800029cc:	00006517          	auipc	a0,0x6
    800029d0:	a0c50513          	addi	a0,a0,-1524 # 800083d8 <etext+0x3d8>
    800029d4:	e1dfd0ef          	jal	800007f0 <panic>
  if (which_dev == 2 && myproc() != 0)
    800029d8:	ecbfe0ef          	jal	800018a2 <myproc>
    800029dc:	d555                	beqz	a0,80002988 <kerneltrap+0x34>
    yield();
    800029de:	decff0ef          	jal	80001fca <yield>
    800029e2:	b75d                	j	80002988 <kerneltrap+0x34>

00000000800029e4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029e4:	1101                	addi	sp,sp,-32
    800029e6:	ec06                	sd	ra,24(sp)
    800029e8:	e822                	sd	s0,16(sp)
    800029ea:	e426                	sd	s1,8(sp)
    800029ec:	1000                	addi	s0,sp,32
    800029ee:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029f0:	eb3fe0ef          	jal	800018a2 <myproc>
  switch (n) {
    800029f4:	4795                	li	a5,5
    800029f6:	0497e163          	bltu	a5,s1,80002a38 <argraw+0x54>
    800029fa:	048a                	slli	s1,s1,0x2
    800029fc:	00006717          	auipc	a4,0x6
    80002a00:	f4c70713          	addi	a4,a4,-180 # 80008948 <states.0+0x30>
    80002a04:	94ba                	add	s1,s1,a4
    80002a06:	409c                	lw	a5,0(s1)
    80002a08:	97ba                	add	a5,a5,a4
    80002a0a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a0c:	6d3c                	ld	a5,88(a0)
    80002a0e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a10:	60e2                	ld	ra,24(sp)
    80002a12:	6442                	ld	s0,16(sp)
    80002a14:	64a2                	ld	s1,8(sp)
    80002a16:	6105                	addi	sp,sp,32
    80002a18:	8082                	ret
    return p->trapframe->a1;
    80002a1a:	6d3c                	ld	a5,88(a0)
    80002a1c:	7fa8                	ld	a0,120(a5)
    80002a1e:	bfcd                	j	80002a10 <argraw+0x2c>
    return p->trapframe->a2;
    80002a20:	6d3c                	ld	a5,88(a0)
    80002a22:	63c8                	ld	a0,128(a5)
    80002a24:	b7f5                	j	80002a10 <argraw+0x2c>
    return p->trapframe->a3;
    80002a26:	6d3c                	ld	a5,88(a0)
    80002a28:	67c8                	ld	a0,136(a5)
    80002a2a:	b7dd                	j	80002a10 <argraw+0x2c>
    return p->trapframe->a4;
    80002a2c:	6d3c                	ld	a5,88(a0)
    80002a2e:	6bc8                	ld	a0,144(a5)
    80002a30:	b7c5                	j	80002a10 <argraw+0x2c>
    return p->trapframe->a5;
    80002a32:	6d3c                	ld	a5,88(a0)
    80002a34:	6fc8                	ld	a0,152(a5)
    80002a36:	bfe9                	j	80002a10 <argraw+0x2c>
  panic("argraw");
    80002a38:	00006517          	auipc	a0,0x6
    80002a3c:	9b050513          	addi	a0,a0,-1616 # 800083e8 <etext+0x3e8>
    80002a40:	db1fd0ef          	jal	800007f0 <panic>

0000000080002a44 <fetchaddr>:
{
    80002a44:	1101                	addi	sp,sp,-32
    80002a46:	ec06                	sd	ra,24(sp)
    80002a48:	e822                	sd	s0,16(sp)
    80002a4a:	e426                	sd	s1,8(sp)
    80002a4c:	e04a                	sd	s2,0(sp)
    80002a4e:	1000                	addi	s0,sp,32
    80002a50:	84aa                	mv	s1,a0
    80002a52:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a54:	e4ffe0ef          	jal	800018a2 <myproc>
  if (addr >= p->sz ||
    80002a58:	652c                	ld	a1,72(a0)
    80002a5a:	02b4f663          	bgeu	s1,a1,80002a86 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a5e:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002a62:	02f5e463          	bltu	a1,a5,80002a8a <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a66:	4721                	li	a4,8
    80002a68:	86a6                	mv	a3,s1
    80002a6a:	864a                	mv	a2,s2
    80002a6c:	6928                	ld	a0,80(a0)
    80002a6e:	b57fe0ef          	jal	800015c4 <copyin>
    80002a72:	00a03533          	snez	a0,a0
    80002a76:	40a00533          	neg	a0,a0
}
    80002a7a:	60e2                	ld	ra,24(sp)
    80002a7c:	6442                	ld	s0,16(sp)
    80002a7e:	64a2                	ld	s1,8(sp)
    80002a80:	6902                	ld	s2,0(sp)
    80002a82:	6105                	addi	sp,sp,32
    80002a84:	8082                	ret
    return -1;
    80002a86:	557d                	li	a0,-1
    80002a88:	bfcd                	j	80002a7a <fetchaddr+0x36>
    80002a8a:	557d                	li	a0,-1
    80002a8c:	b7fd                	j	80002a7a <fetchaddr+0x36>

0000000080002a8e <fetchstr>:
{
    80002a8e:	7179                	addi	sp,sp,-48
    80002a90:	f406                	sd	ra,40(sp)
    80002a92:	f022                	sd	s0,32(sp)
    80002a94:	ec26                	sd	s1,24(sp)
    80002a96:	e84a                	sd	s2,16(sp)
    80002a98:	e44e                	sd	s3,8(sp)
    80002a9a:	1800                	addi	s0,sp,48
    80002a9c:	892a                	mv	s2,a0
    80002a9e:	84ae                	mv	s1,a1
    80002aa0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002aa2:	e01fe0ef          	jal	800018a2 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002aa6:	874e                	mv	a4,s3
    80002aa8:	86ca                	mv	a3,s2
    80002aaa:	8626                	mv	a2,s1
    80002aac:	652c                	ld	a1,72(a0)
    80002aae:	6928                	ld	a0,80(a0)
    80002ab0:	babfe0ef          	jal	8000165a <copyinstr>
    80002ab4:	00054c63          	bltz	a0,80002acc <fetchstr+0x3e>
  return strlen(buf);
    80002ab8:	8526                	mv	a0,s1
    80002aba:	b0afe0ef          	jal	80000dc4 <strlen>
}
    80002abe:	70a2                	ld	ra,40(sp)
    80002ac0:	7402                	ld	s0,32(sp)
    80002ac2:	64e2                	ld	s1,24(sp)
    80002ac4:	6942                	ld	s2,16(sp)
    80002ac6:	69a2                	ld	s3,8(sp)
    80002ac8:	6145                	addi	sp,sp,48
    80002aca:	8082                	ret
    return -1;
    80002acc:	557d                	li	a0,-1
    80002ace:	bfc5                	j	80002abe <fetchstr+0x30>

0000000080002ad0 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ad0:	1101                	addi	sp,sp,-32
    80002ad2:	ec06                	sd	ra,24(sp)
    80002ad4:	e822                	sd	s0,16(sp)
    80002ad6:	e426                	sd	s1,8(sp)
    80002ad8:	1000                	addi	s0,sp,32
    80002ada:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002adc:	f09ff0ef          	jal	800029e4 <argraw>
    80002ae0:	c088                	sw	a0,0(s1)
}
    80002ae2:	60e2                	ld	ra,24(sp)
    80002ae4:	6442                	ld	s0,16(sp)
    80002ae6:	64a2                	ld	s1,8(sp)
    80002ae8:	6105                	addi	sp,sp,32
    80002aea:	8082                	ret

0000000080002aec <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002aec:	1101                	addi	sp,sp,-32
    80002aee:	ec06                	sd	ra,24(sp)
    80002af0:	e822                	sd	s0,16(sp)
    80002af2:	e426                	sd	s1,8(sp)
    80002af4:	1000                	addi	s0,sp,32
    80002af6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002af8:	eedff0ef          	jal	800029e4 <argraw>
    80002afc:	e088                	sd	a0,0(s1)
}
    80002afe:	60e2                	ld	ra,24(sp)
    80002b00:	6442                	ld	s0,16(sp)
    80002b02:	64a2                	ld	s1,8(sp)
    80002b04:	6105                	addi	sp,sp,32
    80002b06:	8082                	ret

0000000080002b08 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b08:	7179                	addi	sp,sp,-48
    80002b0a:	f406                	sd	ra,40(sp)
    80002b0c:	f022                	sd	s0,32(sp)
    80002b0e:	ec26                	sd	s1,24(sp)
    80002b10:	e84a                	sd	s2,16(sp)
    80002b12:	1800                	addi	s0,sp,48
    80002b14:	84ae                	mv	s1,a1
    80002b16:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b18:	fd840593          	addi	a1,s0,-40
    80002b1c:	fd1ff0ef          	jal	80002aec <argaddr>
  return fetchstr(addr, buf, max);
    80002b20:	864a                	mv	a2,s2
    80002b22:	85a6                	mv	a1,s1
    80002b24:	fd843503          	ld	a0,-40(s0)
    80002b28:	f67ff0ef          	jal	80002a8e <fetchstr>
}
    80002b2c:	70a2                	ld	ra,40(sp)
    80002b2e:	7402                	ld	s0,32(sp)
    80002b30:	64e2                	ld	s1,24(sp)
    80002b32:	6942                	ld	s2,16(sp)
    80002b34:	6145                	addi	sp,sp,48
    80002b36:	8082                	ret

0000000080002b38 <syscall>:
  // clang-format on
};

void
syscall(void)
{
    80002b38:	1101                	addi	sp,sp,-32
    80002b3a:	ec06                	sd	ra,24(sp)
    80002b3c:	e822                	sd	s0,16(sp)
    80002b3e:	e426                	sd	s1,8(sp)
    80002b40:	e04a                	sd	s2,0(sp)
    80002b42:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b44:	d5ffe0ef          	jal	800018a2 <myproc>
    80002b48:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b4a:	05853903          	ld	s2,88(a0)
    80002b4e:	0a893783          	ld	a5,168(s2)
    80002b52:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b56:	37fd                	addiw	a5,a5,-1
    80002b58:	4765                	li	a4,25
    80002b5a:	00f76f63          	bltu	a4,a5,80002b78 <syscall+0x40>
    80002b5e:	00369713          	slli	a4,a3,0x3
    80002b62:	00006797          	auipc	a5,0x6
    80002b66:	dfe78793          	addi	a5,a5,-514 # 80008960 <syscalls>
    80002b6a:	97ba                	add	a5,a5,a4
    80002b6c:	639c                	ld	a5,0(a5)
    80002b6e:	c789                	beqz	a5,80002b78 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b70:	9782                	jalr	a5
    80002b72:	06a93823          	sd	a0,112(s2)
    80002b76:	a829                	j	80002b90 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002b78:	15848613          	addi	a2,s1,344
    80002b7c:	588c                	lw	a1,48(s1)
    80002b7e:	00006517          	auipc	a0,0x6
    80002b82:	87250513          	addi	a0,a0,-1934 # 800083f0 <etext+0x3f0>
    80002b86:	985fd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002b8a:	6cbc                	ld	a5,88(s1)
    80002b8c:	577d                	li	a4,-1
    80002b8e:	fbb8                	sd	a4,112(a5)
  }
}
    80002b90:	60e2                	ld	ra,24(sp)
    80002b92:	6442                	ld	s0,16(sp)
    80002b94:	64a2                	ld	s1,8(sp)
    80002b96:	6902                	ld	s2,0(sp)
    80002b98:	6105                	addi	sp,sp,32
    80002b9a:	8082                	ret

0000000080002b9c <sys_exit>:
extern int scheduler_policy;
extern int time_quantum;

uint64
sys_exit(void)
{
    80002b9c:	1101                	addi	sp,sp,-32
    80002b9e:	ec06                	sd	ra,24(sp)
    80002ba0:	e822                	sd	s0,16(sp)
    80002ba2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ba4:	fec40593          	addi	a1,s0,-20
    80002ba8:	4501                	li	a0,0
    80002baa:	f27ff0ef          	jal	80002ad0 <argint>
  kexit(n);
    80002bae:	fec42503          	lw	a0,-20(s0)
    80002bb2:	db4ff0ef          	jal	80002166 <kexit>
  return 0; // not reached
}
    80002bb6:	4501                	li	a0,0
    80002bb8:	60e2                	ld	ra,24(sp)
    80002bba:	6442                	ld	s0,16(sp)
    80002bbc:	6105                	addi	sp,sp,32
    80002bbe:	8082                	ret

0000000080002bc0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bc0:	1141                	addi	sp,sp,-16
    80002bc2:	e406                	sd	ra,8(sp)
    80002bc4:	e022                	sd	s0,0(sp)
    80002bc6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bc8:	cdbfe0ef          	jal	800018a2 <myproc>
}
    80002bcc:	5908                	lw	a0,48(a0)
    80002bce:	60a2                	ld	ra,8(sp)
    80002bd0:	6402                	ld	s0,0(sp)
    80002bd2:	0141                	addi	sp,sp,16
    80002bd4:	8082                	ret

0000000080002bd6 <sys_fork>:

uint64
sys_fork(void)
{
    80002bd6:	1141                	addi	sp,sp,-16
    80002bd8:	e406                	sd	ra,8(sp)
    80002bda:	e022                	sd	s0,0(sp)
    80002bdc:	0800                	addi	s0,sp,16
  return kfork();
    80002bde:	880ff0ef          	jal	80001c5e <kfork>
}
    80002be2:	60a2                	ld	ra,8(sp)
    80002be4:	6402                	ld	s0,0(sp)
    80002be6:	0141                	addi	sp,sp,16
    80002be8:	8082                	ret

0000000080002bea <sys_wait>:

uint64
sys_wait(void)
{
    80002bea:	1101                	addi	sp,sp,-32
    80002bec:	ec06                	sd	ra,24(sp)
    80002bee:	e822                	sd	s0,16(sp)
    80002bf0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002bf2:	fe840593          	addi	a1,s0,-24
    80002bf6:	4501                	li	a0,0
    80002bf8:	ef5ff0ef          	jal	80002aec <argaddr>
  return kwait(p);
    80002bfc:	fe843503          	ld	a0,-24(s0)
    80002c00:	ebcff0ef          	jal	800022bc <kwait>
}
    80002c04:	60e2                	ld	ra,24(sp)
    80002c06:	6442                	ld	s0,16(sp)
    80002c08:	6105                	addi	sp,sp,32
    80002c0a:	8082                	ret

0000000080002c0c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c0c:	7179                	addi	sp,sp,-48
    80002c0e:	f406                	sd	ra,40(sp)
    80002c10:	f022                	sd	s0,32(sp)
    80002c12:	ec26                	sd	s1,24(sp)
    80002c14:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002c16:	fd840593          	addi	a1,s0,-40
    80002c1a:	4501                	li	a0,0
    80002c1c:	eb5ff0ef          	jal	80002ad0 <argint>
  argint(1, &t);
    80002c20:	fdc40593          	addi	a1,s0,-36
    80002c24:	4505                	li	a0,1
    80002c26:	eabff0ef          	jal	80002ad0 <argint>
  addr = myproc()->sz;
    80002c2a:	c79fe0ef          	jal	800018a2 <myproc>
    80002c2e:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002c30:	fdc42703          	lw	a4,-36(s0)
    80002c34:	4785                	li	a5,1
    80002c36:	02f70763          	beq	a4,a5,80002c64 <sys_sbrk+0x58>
    80002c3a:	fd842783          	lw	a5,-40(s0)
    80002c3e:	0207c363          	bltz	a5,80002c64 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002c42:	97a6                	add	a5,a5,s1
    80002c44:	0297ee63          	bltu	a5,s1,80002c80 <sys_sbrk+0x74>
      return -1;
    if (addr + n > TRAPFRAME)
    80002c48:	02000737          	lui	a4,0x2000
    80002c4c:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002c4e:	0736                	slli	a4,a4,0xd
    80002c50:	02f76a63          	bltu	a4,a5,80002c84 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002c54:	c4ffe0ef          	jal	800018a2 <myproc>
    80002c58:	fd842703          	lw	a4,-40(s0)
    80002c5c:	653c                	ld	a5,72(a0)
    80002c5e:	97ba                	add	a5,a5,a4
    80002c60:	e53c                	sd	a5,72(a0)
    80002c62:	a039                	j	80002c70 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002c64:	fd842503          	lw	a0,-40(s0)
    80002c68:	f95fe0ef          	jal	80001bfc <growproc>
    80002c6c:	00054863          	bltz	a0,80002c7c <sys_sbrk+0x70>
  }
  return addr;
}
    80002c70:	8526                	mv	a0,s1
    80002c72:	70a2                	ld	ra,40(sp)
    80002c74:	7402                	ld	s0,32(sp)
    80002c76:	64e2                	ld	s1,24(sp)
    80002c78:	6145                	addi	sp,sp,48
    80002c7a:	8082                	ret
      return -1;
    80002c7c:	54fd                	li	s1,-1
    80002c7e:	bfcd                	j	80002c70 <sys_sbrk+0x64>
      return -1;
    80002c80:	54fd                	li	s1,-1
    80002c82:	b7fd                	j	80002c70 <sys_sbrk+0x64>
      return -1;
    80002c84:	54fd                	li	s1,-1
    80002c86:	b7ed                	j	80002c70 <sys_sbrk+0x64>

0000000080002c88 <sys_pause>:

uint64
sys_pause(void)
{
    80002c88:	7139                	addi	sp,sp,-64
    80002c8a:	fc06                	sd	ra,56(sp)
    80002c8c:	f822                	sd	s0,48(sp)
    80002c8e:	ec4e                	sd	s3,24(sp)
    80002c90:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c92:	fcc40593          	addi	a1,s0,-52
    80002c96:	4501                	li	a0,0
    80002c98:	e39ff0ef          	jal	80002ad0 <argint>
  if (n < 0)
    80002c9c:	fcc42783          	lw	a5,-52(s0)
    80002ca0:	0607cf63          	bltz	a5,80002d1e <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002ca4:	00018517          	auipc	a0,0x18
    80002ca8:	a2c50513          	addi	a0,a0,-1492 # 8001a6d0 <tickslock>
    80002cac:	ee5fd0ef          	jal	80000b90 <acquire>
  ticks0 = ticks;
    80002cb0:	00009997          	auipc	s3,0x9
    80002cb4:	8d09a983          	lw	s3,-1840(s3) # 8000b580 <ticks>
  while (ticks - ticks0 < n) {
    80002cb8:	fcc42783          	lw	a5,-52(s0)
    80002cbc:	c7a9                	beqz	a5,80002d06 <sys_pause+0x7e>
    80002cbe:	f426                	sd	s1,40(sp)
    80002cc0:	f04a                	sd	s2,32(sp)
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002cc2:	00009917          	auipc	s2,0x9
    80002cc6:	8be90913          	addi	s2,s2,-1858 # 8000b580 <ticks>
    release(&tickslock);
    80002cca:	00018497          	auipc	s1,0x18
    80002cce:	a0648493          	addi	s1,s1,-1530 # 8001a6d0 <tickslock>
    if (killed(myproc())) {
    80002cd2:	bd1fe0ef          	jal	800018a2 <myproc>
    80002cd6:	dbcff0ef          	jal	80002292 <killed>
    80002cda:	e529                	bnez	a0,80002d24 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002cdc:	854a                	mv	a0,s2
    80002cde:	b2eff0ef          	jal	8000200c <sleep_prepare>
    release(&tickslock);
    80002ce2:	8526                	mv	a0,s1
    80002ce4:	f39fd0ef          	jal	80000c1c <release>
    sleep();
    80002ce8:	b60ff0ef          	jal	80002048 <sleep>
    acquire(&tickslock);
    80002cec:	8526                	mv	a0,s1
    80002cee:	ea3fd0ef          	jal	80000b90 <acquire>
  while (ticks - ticks0 < n) {
    80002cf2:	00092783          	lw	a5,0(s2)
    80002cf6:	413787bb          	subw	a5,a5,s3
    80002cfa:	fcc42703          	lw	a4,-52(s0)
    80002cfe:	fce7eae3          	bltu	a5,a4,80002cd2 <sys_pause+0x4a>
    80002d02:	74a2                	ld	s1,40(sp)
    80002d04:	7902                	ld	s2,32(sp)
  }
  release(&tickslock);
    80002d06:	00018517          	auipc	a0,0x18
    80002d0a:	9ca50513          	addi	a0,a0,-1590 # 8001a6d0 <tickslock>
    80002d0e:	f0ffd0ef          	jal	80000c1c <release>
  return 0;
    80002d12:	4501                	li	a0,0
}
    80002d14:	70e2                	ld	ra,56(sp)
    80002d16:	7442                	ld	s0,48(sp)
    80002d18:	69e2                	ld	s3,24(sp)
    80002d1a:	6121                	addi	sp,sp,64
    80002d1c:	8082                	ret
    n = 0;
    80002d1e:	fc042623          	sw	zero,-52(s0)
    80002d22:	b749                	j	80002ca4 <sys_pause+0x1c>
      release(&tickslock);
    80002d24:	00018517          	auipc	a0,0x18
    80002d28:	9ac50513          	addi	a0,a0,-1620 # 8001a6d0 <tickslock>
    80002d2c:	ef1fd0ef          	jal	80000c1c <release>
      return -1;
    80002d30:	557d                	li	a0,-1
    80002d32:	74a2                	ld	s1,40(sp)
    80002d34:	7902                	ld	s2,32(sp)
    80002d36:	bff9                	j	80002d14 <sys_pause+0x8c>

0000000080002d38 <sys_kill>:

uint64
sys_kill(void)
{
    80002d38:	1101                	addi	sp,sp,-32
    80002d3a:	ec06                	sd	ra,24(sp)
    80002d3c:	e822                	sd	s0,16(sp)
    80002d3e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d40:	fec40593          	addi	a1,s0,-20
    80002d44:	4501                	li	a0,0
    80002d46:	d8bff0ef          	jal	80002ad0 <argint>
  return kkill(pid);
    80002d4a:	fec42503          	lw	a0,-20(s0)
    80002d4e:	cbaff0ef          	jal	80002208 <kkill>
}
    80002d52:	60e2                	ld	ra,24(sp)
    80002d54:	6442                	ld	s0,16(sp)
    80002d56:	6105                	addi	sp,sp,32
    80002d58:	8082                	ret

0000000080002d5a <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.

uint64
sys_uptime(void)
{
    80002d5a:	1101                	addi	sp,sp,-32
    80002d5c:	ec06                	sd	ra,24(sp)
    80002d5e:	e822                	sd	s0,16(sp)
    80002d60:	e426                	sd	s1,8(sp)
    80002d62:	1000                	addi	s0,sp,32
  uint64 xticks;

  acquire(&tickslock);
    80002d64:	00018517          	auipc	a0,0x18
    80002d68:	96c50513          	addi	a0,a0,-1684 # 8001a6d0 <tickslock>
    80002d6c:	e25fd0ef          	jal	80000b90 <acquire>
  xticks = ticks;
    80002d70:	00009497          	auipc	s1,0x9
    80002d74:	8104e483          	lwu	s1,-2032(s1) # 8000b580 <ticks>
  release(&tickslock);
    80002d78:	00018517          	auipc	a0,0x18
    80002d7c:	95850513          	addi	a0,a0,-1704 # 8001a6d0 <tickslock>
    80002d80:	e9dfd0ef          	jal	80000c1c <release>
  return xticks;
}
    80002d84:	8526                	mv	a0,s1
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	64a2                	ld	s1,8(sp)
    80002d8c:	6105                	addi	sp,sp,32
    80002d8e:	8082                	ret

0000000080002d90 <sys_get_process_stats>:

uint64
sys_get_process_stats(void)
{
    80002d90:	7119                	addi	sp,sp,-128
    80002d92:	fc86                	sd	ra,120(sp)
    80002d94:	f8a2                	sd	s0,112(sp)
    80002d96:	f4a6                	sd	s1,104(sp)
    80002d98:	f0ca                	sd	s2,96(sp)
    80002d9a:	ecce                	sd	s3,88(sp)
    80002d9c:	0100                	addi	s0,sp,128
  int pid;
  uint64 addr;
  struct proc *p;
  struct proc_stat ps;

  argint(0, &pid);     // Get PID from first argument
    80002d9e:	fcc40593          	addi	a1,s0,-52
    80002da2:	4501                	li	a0,0
    80002da4:	d2dff0ef          	jal	80002ad0 <argint>
  argaddr(1, &addr);   // Get pointer from second argument
    80002da8:	fc040593          	addi	a1,s0,-64
    80002dac:	4505                	li	a0,1
    80002dae:	d3fff0ef          	jal	80002aec <argaddr>

  printk("DEBUG: pid from argint = %d, addr from argaddr = %lx\n", pid, addr);
    80002db2:	fc043603          	ld	a2,-64(s0)
    80002db6:	fcc42583          	lw	a1,-52(s0)
    80002dba:	00005517          	auipc	a0,0x5
    80002dbe:	65650513          	addi	a0,a0,1622 # 80008410 <etext+0x410>
    80002dc2:	f48fd0ef          	jal	8000050a <printk>
  printk("DEBUG: Looking for PID %d\n", pid);
    80002dc6:	fcc42583          	lw	a1,-52(s0)
    80002dca:	00005517          	auipc	a0,0x5
    80002dce:	67e50513          	addi	a0,a0,1662 # 80008448 <etext+0x448>
    80002dd2:	f38fd0ef          	jal	8000050a <printk>

  for (p = proc; p < &proc[NPROC]; p++) {
    80002dd6:	00011497          	auipc	s1,0x11
    80002dda:	cfa48493          	addi	s1,s1,-774 # 80013ad0 <proc>
    acquire(&p->lock);
    if (p->state != UNUSED) {
      printk("DEBUG: Found process: PID=%d, State=%d, Name=%s\n", p->pid, p->state, p->name);
    80002dde:	00005997          	auipc	s3,0x5
    80002de2:	68a98993          	addi	s3,s3,1674 # 80008468 <etext+0x468>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002de6:	00018917          	auipc	s2,0x18
    80002dea:	8ea90913          	addi	s2,s2,-1814 # 8001a6d0 <tickslock>
    80002dee:	a005                	j	80002e0e <sys_get_process_stats+0x7e>
      ps.sleep_time = p->sleep_time;
      
      release(&p->lock);

      if (either_copyout(1, addr, &ps, sizeof(ps)) < 0) {
        printk("DEBUG: copyout failed!\n");
    80002df0:	00005517          	auipc	a0,0x5
    80002df4:	6d050513          	addi	a0,a0,1744 # 800084c0 <etext+0x4c0>
    80002df8:	f12fd0ef          	jal	8000050a <printk>
        return -1;
    80002dfc:	557d                	li	a0,-1
    80002dfe:	a075                	j	80002eaa <sys_get_process_stats+0x11a>
      }
      printk("DEBUG: copyout succeeded!\n");
      return 0;
    }
    release(&p->lock);
    80002e00:	8526                	mv	a0,s1
    80002e02:	e1bfd0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002e06:	1b048493          	addi	s1,s1,432
    80002e0a:	0b248763          	beq	s1,s2,80002eb8 <sys_get_process_stats+0x128>
    acquire(&p->lock);
    80002e0e:	8526                	mv	a0,s1
    80002e10:	d81fd0ef          	jal	80000b90 <acquire>
    if (p->state != UNUSED) {
    80002e14:	4c90                	lw	a2,24(s1)
    80002e16:	d66d                	beqz	a2,80002e00 <sys_get_process_stats+0x70>
      printk("DEBUG: Found process: PID=%d, State=%d, Name=%s\n", p->pid, p->state, p->name);
    80002e18:	15848693          	addi	a3,s1,344
    80002e1c:	588c                	lw	a1,48(s1)
    80002e1e:	854e                	mv	a0,s3
    80002e20:	eeafd0ef          	jal	8000050a <printk>
    if (p->pid == pid && p->state != UNUSED) {
    80002e24:	fcc42583          	lw	a1,-52(s0)
    80002e28:	589c                	lw	a5,48(s1)
    80002e2a:	fcb79be3          	bne	a5,a1,80002e00 <sys_get_process_stats+0x70>
    80002e2e:	4c9c                	lw	a5,24(s1)
    80002e30:	dbe1                	beqz	a5,80002e00 <sys_get_process_stats+0x70>
      printk("DEBUG: Found target PID %d!\n", pid);
    80002e32:	00005517          	auipc	a0,0x5
    80002e36:	66e50513          	addi	a0,a0,1646 # 800084a0 <etext+0x4a0>
    80002e3a:	ed0fd0ef          	jal	8000050a <printk>
      ps.pid = p->pid;
    80002e3e:	589c                	lw	a5,48(s1)
    80002e40:	f8f42023          	sw	a5,-128(s0)
      ps.state = p->state;
    80002e44:	4c9c                	lw	a5,24(s1)
    80002e46:	f8f42223          	sw	a5,-124(s0)
      safestrcpy(ps.name, p->name, sizeof(ps.name));
    80002e4a:	4641                	li	a2,16
    80002e4c:	15848593          	addi	a1,s1,344
    80002e50:	f8840513          	addi	a0,s0,-120
    80002e54:	f3ffd0ef          	jal	80000d92 <safestrcpy>
      ps.cpu_time = p->cpu_time;
    80002e58:	1684b783          	ld	a5,360(s1)
    80002e5c:	f8f43c23          	sd	a5,-104(s0)
      ps.wait_time = p->wait_time;
    80002e60:	1704b783          	ld	a5,368(s1)
    80002e64:	faf43023          	sd	a5,-96(s0)
      ps.context_switches = p->context_switches;
    80002e68:	1784b783          	ld	a5,376(s1)
    80002e6c:	faf43423          	sd	a5,-88(s0)
      ps.last_run = p->last_run;
    80002e70:	1804b783          	ld	a5,384(s1)
    80002e74:	faf43823          	sd	a5,-80(s0)
      ps.sleep_time = p->sleep_time;
    80002e78:	1904b783          	ld	a5,400(s1)
    80002e7c:	faf43c23          	sd	a5,-72(s0)
      release(&p->lock);
    80002e80:	8526                	mv	a0,s1
    80002e82:	d9bfd0ef          	jal	80000c1c <release>
      if (either_copyout(1, addr, &ps, sizeof(ps)) < 0) {
    80002e86:	04000693          	li	a3,64
    80002e8a:	f8040613          	addi	a2,s0,-128
    80002e8e:	fc043583          	ld	a1,-64(s0)
    80002e92:	4505                	li	a0,1
    80002e94:	d38ff0ef          	jal	800023cc <either_copyout>
    80002e98:	f4054ce3          	bltz	a0,80002df0 <sys_get_process_stats+0x60>
      printk("DEBUG: copyout succeeded!\n");
    80002e9c:	00005517          	auipc	a0,0x5
    80002ea0:	63c50513          	addi	a0,a0,1596 # 800084d8 <etext+0x4d8>
    80002ea4:	e66fd0ef          	jal	8000050a <printk>
      return 0;
    80002ea8:	4501                	li	a0,0
  }
  printk("DEBUG: PID %d not found!\n", pid);
  return -1;
}
    80002eaa:	70e6                	ld	ra,120(sp)
    80002eac:	7446                	ld	s0,112(sp)
    80002eae:	74a6                	ld	s1,104(sp)
    80002eb0:	7906                	ld	s2,96(sp)
    80002eb2:	69e6                	ld	s3,88(sp)
    80002eb4:	6109                	addi	sp,sp,128
    80002eb6:	8082                	ret
  printk("DEBUG: PID %d not found!\n", pid);
    80002eb8:	fcc42583          	lw	a1,-52(s0)
    80002ebc:	00005517          	auipc	a0,0x5
    80002ec0:	63c50513          	addi	a0,a0,1596 # 800084f8 <etext+0x4f8>
    80002ec4:	e46fd0ef          	jal	8000050a <printk>
  return -1;
    80002ec8:	557d                	li	a0,-1
    80002eca:	b7c5                	j	80002eaa <sys_get_process_stats+0x11a>

0000000080002ecc <sys_set_scheduler>:

// --- AegisOS: Scheduler Control System Calls ---

uint64
sys_set_scheduler(void)
{
    80002ecc:	1101                	addi	sp,sp,-32
    80002ece:	ec06                	sd	ra,24(sp)
    80002ed0:	e822                	sd	s0,16(sp)
    80002ed2:	1000                	addi	s0,sp,32
  int policy;
  argint(0, &policy);
    80002ed4:	fec40593          	addi	a1,s0,-20
    80002ed8:	4501                	li	a0,0
    80002eda:	bf7ff0ef          	jal	80002ad0 <argint>
  
  if (policy != SCHED_RR && policy != SCHED_MLFQ) {
    80002ede:	fec42783          	lw	a5,-20(s0)
    80002ee2:	0007869b          	sext.w	a3,a5
    80002ee6:	4705                	li	a4,1
    return -1;  // Invalid policy
    80002ee8:	557d                	li	a0,-1
  if (policy != SCHED_RR && policy != SCHED_MLFQ) {
    80002eea:	02d76663          	bltu	a4,a3,80002f16 <sys_set_scheduler+0x4a>
  }
  
  scheduler_policy = policy;
    80002eee:	00008717          	auipc	a4,0x8
    80002ef2:	68f72123          	sw	a5,1666(a4) # 8000b570 <scheduler_policy>
  printk("AegisOS: Scheduler switched to %s\n", 
    80002ef6:	00005597          	auipc	a1,0x5
    80002efa:	63258593          	addi	a1,a1,1586 # 80008528 <etext+0x528>
    80002efe:	e789                	bnez	a5,80002f08 <sys_set_scheduler+0x3c>
    80002f00:	00005597          	auipc	a1,0x5
    80002f04:	61858593          	addi	a1,a1,1560 # 80008518 <etext+0x518>
    80002f08:	00005517          	auipc	a0,0x5
    80002f0c:	62850513          	addi	a0,a0,1576 # 80008530 <etext+0x530>
    80002f10:	dfafd0ef          	jal	8000050a <printk>
         policy == SCHED_RR ? "Round Robin" : "MLFQ");
  
  return 0;
    80002f14:	4501                	li	a0,0
}
    80002f16:	60e2                	ld	ra,24(sp)
    80002f18:	6442                	ld	s0,16(sp)
    80002f1a:	6105                	addi	sp,sp,32
    80002f1c:	8082                	ret

0000000080002f1e <sys_set_quantum>:

uint64
sys_set_quantum(void)
{
    80002f1e:	1101                	addi	sp,sp,-32
    80002f20:	ec06                	sd	ra,24(sp)
    80002f22:	e822                	sd	s0,16(sp)
    80002f24:	1000                	addi	s0,sp,32
  int quantum;
  argint(0, &quantum);
    80002f26:	fec40593          	addi	a1,s0,-20
    80002f2a:	4501                	li	a0,0
    80002f2c:	ba5ff0ef          	jal	80002ad0 <argint>
  
  if (quantum < 1 || quantum > 100) {
    80002f30:	fec42583          	lw	a1,-20(s0)
    80002f34:	fff5871b          	addiw	a4,a1,-1
    80002f38:	06300793          	li	a5,99
    return -1;  // Invalid quantum
    80002f3c:	557d                	li	a0,-1
  if (quantum < 1 || quantum > 100) {
    80002f3e:	00e7ed63          	bltu	a5,a4,80002f58 <sys_set_quantum+0x3a>
  }
  
  time_quantum = quantum;
    80002f42:	00008797          	auipc	a5,0x8
    80002f46:	5eb7a323          	sw	a1,1510(a5) # 8000b528 <time_quantum>
  printk("AegisOS: Time quantum set to %d ticks\n", quantum);
    80002f4a:	00005517          	auipc	a0,0x5
    80002f4e:	60e50513          	addi	a0,a0,1550 # 80008558 <etext+0x558>
    80002f52:	db8fd0ef          	jal	8000050a <printk>
  
  return 0;
    80002f56:	4501                	li	a0,0
}
    80002f58:	60e2                	ld	ra,24(sp)
    80002f5a:	6442                	ld	s0,16(sp)
    80002f5c:	6105                	addi	sp,sp,32
    80002f5e:	8082                	ret

0000000080002f60 <sys_get_system_stats>:

uint64
sys_get_system_stats(void)
{
    80002f60:	7155                	addi	sp,sp,-208
    80002f62:	e586                	sd	ra,200(sp)
    80002f64:	e1a2                	sd	s0,192(sp)
    80002f66:	fd26                	sd	s1,184(sp)
    80002f68:	f94a                	sd	s2,176(sp)
    80002f6a:	f54e                	sd	s3,168(sp)
    80002f6c:	f152                	sd	s4,160(sp)
    80002f6e:	ed56                	sd	s5,152(sp)
    80002f70:	e95a                	sd	s6,144(sp)
    80002f72:	e55e                	sd	s7,136(sp)
    80002f74:	e162                	sd	s8,128(sp)
    80002f76:	fce6                	sd	s9,120(sp)
    80002f78:	f8ea                	sd	s10,112(sp)
    80002f7a:	f4ee                	sd	s11,104(sp)
    80002f7c:	0980                	addi	s0,sp,208
  uint64 addr;
  struct proc *p;
  struct system_stats ss;
  
  argaddr(0, &addr);
    80002f7e:	f8840593          	addi	a1,s0,-120
    80002f82:	4501                	li	a0,0
    80002f84:	b69ff0ef          	jal	80002aec <argaddr>
  
  memset(&ss, 0, sizeof(ss));
    80002f88:	04000613          	li	a2,64
    80002f8c:	4581                	li	a1,0
    80002f8e:	f4840513          	addi	a0,s0,-184
    80002f92:	cc3fd0ef          	jal	80000c54 <memset>
  uint64 total_cpu = 0;
  uint64 total_sleep = 0;
  uint64 total_wait = 0;
  uint64 total_switches = 0;
  int total = 0;
  int running = 0, sleeping = 0, runnable = 0;
    80002f96:	f2043c23          	sd	zero,-200(s0)
    80002f9a:	4d81                	li	s11,0
    80002f9c:	4c81                	li	s9,0
  int total = 0;
    80002f9e:	4b01                	li	s6,0
  uint64 total_switches = 0;
    80002fa0:	4a81                	li	s5,0
  uint64 total_wait = 0;
    80002fa2:	4a01                	li	s4,0
  uint64 total_sleep = 0;
    80002fa4:	4901                	li	s2,0
  uint64 total_cpu = 0;
    80002fa6:	4981                	li	s3,0
  
  for (p = proc; p < &proc[NPROC]; p++) {
    80002fa8:	00011497          	auipc	s1,0x11
    80002fac:	b2848493          	addi	s1,s1,-1240 # 80013ad0 <proc>
      total_cpu += p->cpu_time;
      total_sleep += p->sleep_time;
      total_wait += p->wait_time;
      total_switches += p->context_switches;
      
      if (p->state == RUNNING) running++;
    80002fb0:	4c11                	li	s8,4
      else if (p->state == SLEEPING) sleeping++;
    80002fb2:	4d09                	li	s10,2
  for (p = proc; p < &proc[NPROC]; p++) {
    80002fb4:	00017b97          	auipc	s7,0x17
    80002fb8:	71cb8b93          	addi	s7,s7,1820 # 8001a6d0 <tickslock>
    80002fbc:	a809                	j	80002fce <sys_get_system_stats+0x6e>
      if (p->state == RUNNING) running++;
    80002fbe:	2c85                	addiw	s9,s9,1
      else if (p->state == RUNNABLE) runnable++;
    }
    release(&p->lock);
    80002fc0:	8526                	mv	a0,s1
    80002fc2:	c5bfd0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002fc6:	1b048493          	addi	s1,s1,432
    80002fca:	05748363          	beq	s1,s7,80003010 <sys_get_system_stats+0xb0>
    acquire(&p->lock);
    80002fce:	8526                	mv	a0,s1
    80002fd0:	bc1fd0ef          	jal	80000b90 <acquire>
    if (p->state != UNUSED) {
    80002fd4:	4c9c                	lw	a5,24(s1)
    80002fd6:	d7ed                	beqz	a5,80002fc0 <sys_get_system_stats+0x60>
      total++;
    80002fd8:	2b05                	addiw	s6,s6,1
      total_cpu += p->cpu_time;
    80002fda:	1684b703          	ld	a4,360(s1)
    80002fde:	99ba                	add	s3,s3,a4
      total_sleep += p->sleep_time;
    80002fe0:	1904b703          	ld	a4,400(s1)
    80002fe4:	993a                	add	s2,s2,a4
      total_wait += p->wait_time;
    80002fe6:	1704b703          	ld	a4,368(s1)
    80002fea:	9a3a                	add	s4,s4,a4
      total_switches += p->context_switches;
    80002fec:	1784b703          	ld	a4,376(s1)
    80002ff0:	9aba                	add	s5,s5,a4
      if (p->state == RUNNING) running++;
    80002ff2:	fd8786e3          	beq	a5,s8,80002fbe <sys_get_system_stats+0x5e>
      else if (p->state == SLEEPING) sleeping++;
    80002ff6:	01a78b63          	beq	a5,s10,8000300c <sys_get_system_stats+0xac>
      else if (p->state == RUNNABLE) runnable++;
    80002ffa:	470d                	li	a4,3
    80002ffc:	fce792e3          	bne	a5,a4,80002fc0 <sys_get_system_stats+0x60>
    80003000:	f3843783          	ld	a5,-200(s0)
    80003004:	2785                	addiw	a5,a5,1
    80003006:	f2f43c23          	sd	a5,-200(s0)
    8000300a:	bf5d                	j	80002fc0 <sys_get_system_stats+0x60>
      else if (p->state == SLEEPING) sleeping++;
    8000300c:	2d85                	addiw	s11,s11,1
    8000300e:	bf4d                	j	80002fc0 <sys_get_system_stats+0x60>
  ss.total_sleep_time = total_sleep;
  ss.total_wait_time = total_wait;
  ss.total_context_switches = total_switches;
  
  // Calculate ratios (scaled by 1000 for integer precision)
  uint64 total_time = total_cpu + total_sleep + total_wait;
    80003010:	012987b3          	add	a5,s3,s2
    80003014:	97d2                	add	a5,a5,s4
  if (total_time > 0) {
    80003016:	873e                	mv	a4,a5
    80003018:	cb99                	beqz	a5,8000302e <sys_get_system_stats+0xce>
    ss.avg_cpu_ratio = (total_cpu * 1000) / total_time;
    8000301a:	3e800693          	li	a3,1000
    8000301e:	02d98733          	mul	a4,s3,a3
    80003022:	02f75733          	divu	a4,a4,a5
    ss.avg_sleep_ratio = (total_sleep * 1000) / total_time;
    80003026:	02d906b3          	mul	a3,s2,a3
    8000302a:	02f6d7b3          	divu	a5,a3,a5
  ss.total_processes = total;
    8000302e:	f5642423          	sw	s6,-184(s0)
  ss.running_processes = running;
    80003032:	f5942623          	sw	s9,-180(s0)
  ss.sleeping_processes = sleeping;
    80003036:	f5b42823          	sw	s11,-176(s0)
  ss.runnable_processes = runnable;
    8000303a:	f3843683          	ld	a3,-200(s0)
    8000303e:	f4d42a23          	sw	a3,-172(s0)
  ss.total_cpu_time = total_cpu;
    80003042:	f5343c23          	sd	s3,-168(s0)
  ss.total_sleep_time = total_sleep;
    80003046:	f7243023          	sd	s2,-160(s0)
  ss.total_wait_time = total_wait;
    8000304a:	f7443423          	sd	s4,-152(s0)
  ss.total_context_switches = total_switches;
    8000304e:	f7543823          	sd	s5,-144(s0)
    ss.avg_cpu_ratio = (total_cpu * 1000) / total_time;
    80003052:	f6e43c23          	sd	a4,-136(s0)
    ss.avg_sleep_ratio = (total_sleep * 1000) / total_time;
    80003056:	f8f43023          	sd	a5,-128(s0)
  } else {
    ss.avg_cpu_ratio = 0;
    ss.avg_sleep_ratio = 0;
  }
  
  if (either_copyout(1, addr, &ss, sizeof(ss)) < 0)
    8000305a:	04000693          	li	a3,64
    8000305e:	f4840613          	addi	a2,s0,-184
    80003062:	f8843583          	ld	a1,-120(s0)
    80003066:	4505                	li	a0,1
    80003068:	b64ff0ef          	jal	800023cc <either_copyout>
    return -1;
  
  return 0;
}
    8000306c:	957d                	srai	a0,a0,0x3f
    8000306e:	60ae                	ld	ra,200(sp)
    80003070:	640e                	ld	s0,192(sp)
    80003072:	74ea                	ld	s1,184(sp)
    80003074:	794a                	ld	s2,176(sp)
    80003076:	79aa                	ld	s3,168(sp)
    80003078:	7a0a                	ld	s4,160(sp)
    8000307a:	6aea                	ld	s5,152(sp)
    8000307c:	6b4a                	ld	s6,144(sp)
    8000307e:	6baa                	ld	s7,136(sp)
    80003080:	6c0a                	ld	s8,128(sp)
    80003082:	7ce6                	ld	s9,120(sp)
    80003084:	7d46                	ld	s10,112(sp)
    80003086:	7da6                	ld	s11,104(sp)
    80003088:	6169                	addi	sp,sp,208
    8000308a:	8082                	ret

000000008000308c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000308c:	7179                	addi	sp,sp,-48
    8000308e:	f406                	sd	ra,40(sp)
    80003090:	f022                	sd	s0,32(sp)
    80003092:	ec26                	sd	s1,24(sp)
    80003094:	e84a                	sd	s2,16(sp)
    80003096:	e44e                	sd	s3,8(sp)
    80003098:	e052                	sd	s4,0(sp)
    8000309a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000309c:	00005597          	auipc	a1,0x5
    800030a0:	4e458593          	addi	a1,a1,1252 # 80008580 <etext+0x580>
    800030a4:	00017517          	auipc	a0,0x17
    800030a8:	64450513          	addi	a0,a0,1604 # 8001a6e8 <bcache>
    800030ac:	a6ffd0ef          	jal	80000b1a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030b0:	0001f797          	auipc	a5,0x1f
    800030b4:	63878793          	addi	a5,a5,1592 # 800226e8 <bcache+0x8000>
    800030b8:	00020717          	auipc	a4,0x20
    800030bc:	89870713          	addi	a4,a4,-1896 # 80022950 <bcache+0x8268>
    800030c0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030c4:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    800030c8:	00017497          	auipc	s1,0x17
    800030cc:	63848493          	addi	s1,s1,1592 # 8001a700 <bcache+0x18>
    b->next = bcache.head.next;
    800030d0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030d2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030d4:	00005a17          	auipc	s4,0x5
    800030d8:	4b4a0a13          	addi	s4,s4,1204 # 80008588 <etext+0x588>
    b->next = bcache.head.next;
    800030dc:	2b893783          	ld	a5,696(s2)
    800030e0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030e2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030e6:	85d2                	mv	a1,s4
    800030e8:	01048513          	addi	a0,s1,16
    800030ec:	412010ef          	jal	800044fe <initsleeplock>
    bcache.head.next->prev = b;
    800030f0:	2b893783          	ld	a5,696(s2)
    800030f4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030f6:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    800030fa:	45848493          	addi	s1,s1,1112
    800030fe:	fd349fe3          	bne	s1,s3,800030dc <binit+0x50>
  }
}
    80003102:	70a2                	ld	ra,40(sp)
    80003104:	7402                	ld	s0,32(sp)
    80003106:	64e2                	ld	s1,24(sp)
    80003108:	6942                	ld	s2,16(sp)
    8000310a:	69a2                	ld	s3,8(sp)
    8000310c:	6a02                	ld	s4,0(sp)
    8000310e:	6145                	addi	sp,sp,48
    80003110:	8082                	ret

0000000080003112 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80003112:	7179                	addi	sp,sp,-48
    80003114:	f406                	sd	ra,40(sp)
    80003116:	f022                	sd	s0,32(sp)
    80003118:	ec26                	sd	s1,24(sp)
    8000311a:	e84a                	sd	s2,16(sp)
    8000311c:	e44e                	sd	s3,8(sp)
    8000311e:	1800                	addi	s0,sp,48
    80003120:	892a                	mv	s2,a0
    80003122:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003124:	00017517          	auipc	a0,0x17
    80003128:	5c450513          	addi	a0,a0,1476 # 8001a6e8 <bcache>
    8000312c:	a65fd0ef          	jal	80000b90 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80003130:	00020497          	auipc	s1,0x20
    80003134:	8704b483          	ld	s1,-1936(s1) # 800229a0 <bcache+0x82b8>
    80003138:	00020797          	auipc	a5,0x20
    8000313c:	81878793          	addi	a5,a5,-2024 # 80022950 <bcache+0x8268>
    80003140:	02f48b63          	beq	s1,a5,80003176 <bread+0x64>
    80003144:	873e                	mv	a4,a5
    80003146:	a021                	j	8000314e <bread+0x3c>
    80003148:	68a4                	ld	s1,80(s1)
    8000314a:	02e48663          	beq	s1,a4,80003176 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    8000314e:	449c                	lw	a5,8(s1)
    80003150:	ff279ce3          	bne	a5,s2,80003148 <bread+0x36>
    80003154:	44dc                	lw	a5,12(s1)
    80003156:	ff3799e3          	bne	a5,s3,80003148 <bread+0x36>
      b->refcnt++;
    8000315a:	40bc                	lw	a5,64(s1)
    8000315c:	2785                	addiw	a5,a5,1
    8000315e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003160:	00017517          	auipc	a0,0x17
    80003164:	58850513          	addi	a0,a0,1416 # 8001a6e8 <bcache>
    80003168:	ab5fd0ef          	jal	80000c1c <release>
      acquiresleep(&b->lock);
    8000316c:	01048513          	addi	a0,s1,16
    80003170:	3c4010ef          	jal	80004534 <acquiresleep>
      return b;
    80003174:	a889                	j	800031c6 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80003176:	00020497          	auipc	s1,0x20
    8000317a:	8224b483          	ld	s1,-2014(s1) # 80022998 <bcache+0x82b0>
    8000317e:	0001f797          	auipc	a5,0x1f
    80003182:	7d278793          	addi	a5,a5,2002 # 80022950 <bcache+0x8268>
    80003186:	00f48863          	beq	s1,a5,80003196 <bread+0x84>
    8000318a:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    8000318c:	40bc                	lw	a5,64(s1)
    8000318e:	cb91                	beqz	a5,800031a2 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80003190:	64a4                	ld	s1,72(s1)
    80003192:	fee49de3          	bne	s1,a4,8000318c <bread+0x7a>
  panic("bget: no buffers");
    80003196:	00005517          	auipc	a0,0x5
    8000319a:	3fa50513          	addi	a0,a0,1018 # 80008590 <etext+0x590>
    8000319e:	e52fd0ef          	jal	800007f0 <panic>
      b->dev = dev;
    800031a2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031a6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031aa:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031ae:	4785                	li	a5,1
    800031b0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031b2:	00017517          	auipc	a0,0x17
    800031b6:	53650513          	addi	a0,a0,1334 # 8001a6e8 <bcache>
    800031ba:	a63fd0ef          	jal	80000c1c <release>
      acquiresleep(&b->lock);
    800031be:	01048513          	addi	a0,s1,16
    800031c2:	372010ef          	jal	80004534 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    800031c6:	409c                	lw	a5,0(s1)
    800031c8:	cb89                	beqz	a5,800031da <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031ca:	8526                	mv	a0,s1
    800031cc:	70a2                	ld	ra,40(sp)
    800031ce:	7402                	ld	s0,32(sp)
    800031d0:	64e2                	ld	s1,24(sp)
    800031d2:	6942                	ld	s2,16(sp)
    800031d4:	69a2                	ld	s3,8(sp)
    800031d6:	6145                	addi	sp,sp,48
    800031d8:	8082                	ret
    virtio_disk_rw(b, 0);
    800031da:	4581                	li	a1,0
    800031dc:	8526                	mv	a0,s1
    800031de:	4a3020ef          	jal	80005e80 <virtio_disk_rw>
    b->valid = 1;
    800031e2:	4785                	li	a5,1
    800031e4:	c09c                	sw	a5,0(s1)
  return b;
    800031e6:	b7d5                	j	800031ca <bread+0xb8>

00000000800031e8 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    800031e8:	1101                	addi	sp,sp,-32
    800031ea:	ec06                	sd	ra,24(sp)
    800031ec:	e822                	sd	s0,16(sp)
    800031ee:	e426                	sd	s1,8(sp)
    800031f0:	1000                	addi	s0,sp,32
    800031f2:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800031f4:	0541                	addi	a0,a0,16
    800031f6:	3ca010ef          	jal	800045c0 <holdingsleep>
    800031fa:	c911                	beqz	a0,8000320e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031fc:	4585                	li	a1,1
    800031fe:	8526                	mv	a0,s1
    80003200:	481020ef          	jal	80005e80 <virtio_disk_rw>
}
    80003204:	60e2                	ld	ra,24(sp)
    80003206:	6442                	ld	s0,16(sp)
    80003208:	64a2                	ld	s1,8(sp)
    8000320a:	6105                	addi	sp,sp,32
    8000320c:	8082                	ret
    panic("bwrite");
    8000320e:	00005517          	auipc	a0,0x5
    80003212:	39a50513          	addi	a0,a0,922 # 800085a8 <etext+0x5a8>
    80003216:	ddafd0ef          	jal	800007f0 <panic>

000000008000321a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000321a:	1101                	addi	sp,sp,-32
    8000321c:	ec06                	sd	ra,24(sp)
    8000321e:	e822                	sd	s0,16(sp)
    80003220:	e426                	sd	s1,8(sp)
    80003222:	e04a                	sd	s2,0(sp)
    80003224:	1000                	addi	s0,sp,32
    80003226:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80003228:	01050913          	addi	s2,a0,16
    8000322c:	854a                	mv	a0,s2
    8000322e:	392010ef          	jal	800045c0 <holdingsleep>
    80003232:	c135                	beqz	a0,80003296 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80003234:	854a                	mv	a0,s2
    80003236:	352010ef          	jal	80004588 <releasesleep>

  acquire(&bcache.lock);
    8000323a:	00017517          	auipc	a0,0x17
    8000323e:	4ae50513          	addi	a0,a0,1198 # 8001a6e8 <bcache>
    80003242:	94ffd0ef          	jal	80000b90 <acquire>
  b->refcnt--;
    80003246:	40bc                	lw	a5,64(s1)
    80003248:	37fd                	addiw	a5,a5,-1
    8000324a:	0007871b          	sext.w	a4,a5
    8000324e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003250:	e71d                	bnez	a4,8000327e <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003252:	68b8                	ld	a4,80(s1)
    80003254:	64bc                	ld	a5,72(s1)
    80003256:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003258:	68b8                	ld	a4,80(s1)
    8000325a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000325c:	0001f797          	auipc	a5,0x1f
    80003260:	48c78793          	addi	a5,a5,1164 # 800226e8 <bcache+0x8000>
    80003264:	2b87b703          	ld	a4,696(a5)
    80003268:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000326a:	0001f717          	auipc	a4,0x1f
    8000326e:	6e670713          	addi	a4,a4,1766 # 80022950 <bcache+0x8268>
    80003272:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003274:	2b87b703          	ld	a4,696(a5)
    80003278:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000327a:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    8000327e:	00017517          	auipc	a0,0x17
    80003282:	46a50513          	addi	a0,a0,1130 # 8001a6e8 <bcache>
    80003286:	997fd0ef          	jal	80000c1c <release>
}
    8000328a:	60e2                	ld	ra,24(sp)
    8000328c:	6442                	ld	s0,16(sp)
    8000328e:	64a2                	ld	s1,8(sp)
    80003290:	6902                	ld	s2,0(sp)
    80003292:	6105                	addi	sp,sp,32
    80003294:	8082                	ret
    panic("brelse");
    80003296:	00005517          	auipc	a0,0x5
    8000329a:	31a50513          	addi	a0,a0,794 # 800085b0 <etext+0x5b0>
    8000329e:	d52fd0ef          	jal	800007f0 <panic>

00000000800032a2 <bpin>:

void
bpin(struct buf *b)
{
    800032a2:	1101                	addi	sp,sp,-32
    800032a4:	ec06                	sd	ra,24(sp)
    800032a6:	e822                	sd	s0,16(sp)
    800032a8:	e426                	sd	s1,8(sp)
    800032aa:	1000                	addi	s0,sp,32
    800032ac:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032ae:	00017517          	auipc	a0,0x17
    800032b2:	43a50513          	addi	a0,a0,1082 # 8001a6e8 <bcache>
    800032b6:	8dbfd0ef          	jal	80000b90 <acquire>
  b->refcnt++;
    800032ba:	40bc                	lw	a5,64(s1)
    800032bc:	2785                	addiw	a5,a5,1
    800032be:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032c0:	00017517          	auipc	a0,0x17
    800032c4:	42850513          	addi	a0,a0,1064 # 8001a6e8 <bcache>
    800032c8:	955fd0ef          	jal	80000c1c <release>
}
    800032cc:	60e2                	ld	ra,24(sp)
    800032ce:	6442                	ld	s0,16(sp)
    800032d0:	64a2                	ld	s1,8(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret

00000000800032d6 <bunpin>:

void
bunpin(struct buf *b)
{
    800032d6:	1101                	addi	sp,sp,-32
    800032d8:	ec06                	sd	ra,24(sp)
    800032da:	e822                	sd	s0,16(sp)
    800032dc:	e426                	sd	s1,8(sp)
    800032de:	1000                	addi	s0,sp,32
    800032e0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032e2:	00017517          	auipc	a0,0x17
    800032e6:	40650513          	addi	a0,a0,1030 # 8001a6e8 <bcache>
    800032ea:	8a7fd0ef          	jal	80000b90 <acquire>
  b->refcnt--;
    800032ee:	40bc                	lw	a5,64(s1)
    800032f0:	37fd                	addiw	a5,a5,-1
    800032f2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032f4:	00017517          	auipc	a0,0x17
    800032f8:	3f450513          	addi	a0,a0,1012 # 8001a6e8 <bcache>
    800032fc:	921fd0ef          	jal	80000c1c <release>
}
    80003300:	60e2                	ld	ra,24(sp)
    80003302:	6442                	ld	s0,16(sp)
    80003304:	64a2                	ld	s1,8(sp)
    80003306:	6105                	addi	sp,sp,32
    80003308:	8082                	ret

000000008000330a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000330a:	1101                	addi	sp,sp,-32
    8000330c:	ec06                	sd	ra,24(sp)
    8000330e:	e822                	sd	s0,16(sp)
    80003310:	e426                	sd	s1,8(sp)
    80003312:	e04a                	sd	s2,0(sp)
    80003314:	1000                	addi	s0,sp,32
    80003316:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003318:	00d5d59b          	srliw	a1,a1,0xd
    8000331c:	00020797          	auipc	a5,0x20
    80003320:	aa87a783          	lw	a5,-1368(a5) # 80022dc4 <sb+0x1c>
    80003324:	9dbd                	addw	a1,a1,a5
    80003326:	dedff0ef          	jal	80003112 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000332a:	0074f713          	andi	a4,s1,7
    8000332e:	4785                	li	a5,1
    80003330:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80003334:	14ce                	slli	s1,s1,0x33
    80003336:	90d9                	srli	s1,s1,0x36
    80003338:	00950733          	add	a4,a0,s1
    8000333c:	05874703          	lbu	a4,88(a4)
    80003340:	00e7f6b3          	and	a3,a5,a4
    80003344:	c29d                	beqz	a3,8000336a <bfree+0x60>
    80003346:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80003348:	94aa                	add	s1,s1,a0
    8000334a:	fff7c793          	not	a5,a5
    8000334e:	8f7d                	and	a4,a4,a5
    80003350:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003354:	078010ef          	jal	800043cc <log_write>
  brelse(bp);
    80003358:	854a                	mv	a0,s2
    8000335a:	ec1ff0ef          	jal	8000321a <brelse>
}
    8000335e:	60e2                	ld	ra,24(sp)
    80003360:	6442                	ld	s0,16(sp)
    80003362:	64a2                	ld	s1,8(sp)
    80003364:	6902                	ld	s2,0(sp)
    80003366:	6105                	addi	sp,sp,32
    80003368:	8082                	ret
    panic("freeing free block");
    8000336a:	00005517          	auipc	a0,0x5
    8000336e:	24e50513          	addi	a0,a0,590 # 800085b8 <etext+0x5b8>
    80003372:	c7efd0ef          	jal	800007f0 <panic>

0000000080003376 <balloc>:
{
    80003376:	711d                	addi	sp,sp,-96
    80003378:	ec86                	sd	ra,88(sp)
    8000337a:	e8a2                	sd	s0,80(sp)
    8000337c:	e4a6                	sd	s1,72(sp)
    8000337e:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB) {
    80003380:	00020797          	auipc	a5,0x20
    80003384:	a2c7a783          	lw	a5,-1492(a5) # 80022dac <sb+0x4>
    80003388:	0e078f63          	beqz	a5,80003486 <balloc+0x110>
    8000338c:	e0ca                	sd	s2,64(sp)
    8000338e:	fc4e                	sd	s3,56(sp)
    80003390:	f852                	sd	s4,48(sp)
    80003392:	f456                	sd	s5,40(sp)
    80003394:	f05a                	sd	s6,32(sp)
    80003396:	ec5e                	sd	s7,24(sp)
    80003398:	e862                	sd	s8,16(sp)
    8000339a:	e466                	sd	s9,8(sp)
    8000339c:	8baa                	mv	s7,a0
    8000339e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033a0:	00020b17          	auipc	s6,0x20
    800033a4:	a08b0b13          	addi	s6,s6,-1528 # 80022da8 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800033a8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033aa:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    800033ac:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    800033ae:	6c89                	lui	s9,0x2
    800033b0:	a0b5                	j	8000341c <balloc+0xa6>
        bp->data[bi / 8] |= m;           // Mark block in use.
    800033b2:	97ca                	add	a5,a5,s2
    800033b4:	8e55                	or	a2,a2,a3
    800033b6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800033ba:	854a                	mv	a0,s2
    800033bc:	010010ef          	jal	800043cc <log_write>
        brelse(bp);
    800033c0:	854a                	mv	a0,s2
    800033c2:	e59ff0ef          	jal	8000321a <brelse>
  bp = bread(dev, bno);
    800033c6:	85a6                	mv	a1,s1
    800033c8:	855e                	mv	a0,s7
    800033ca:	d49ff0ef          	jal	80003112 <bread>
    800033ce:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033d0:	40000613          	li	a2,1024
    800033d4:	4581                	li	a1,0
    800033d6:	05850513          	addi	a0,a0,88
    800033da:	87bfd0ef          	jal	80000c54 <memset>
  log_write(bp);
    800033de:	854a                	mv	a0,s2
    800033e0:	7ed000ef          	jal	800043cc <log_write>
  brelse(bp);
    800033e4:	854a                	mv	a0,s2
    800033e6:	e35ff0ef          	jal	8000321a <brelse>
}
    800033ea:	6906                	ld	s2,64(sp)
    800033ec:	79e2                	ld	s3,56(sp)
    800033ee:	7a42                	ld	s4,48(sp)
    800033f0:	7aa2                	ld	s5,40(sp)
    800033f2:	7b02                	ld	s6,32(sp)
    800033f4:	6be2                	ld	s7,24(sp)
    800033f6:	6c42                	ld	s8,16(sp)
    800033f8:	6ca2                	ld	s9,8(sp)
}
    800033fa:	8526                	mv	a0,s1
    800033fc:	60e6                	ld	ra,88(sp)
    800033fe:	6446                	ld	s0,80(sp)
    80003400:	64a6                	ld	s1,72(sp)
    80003402:	6125                	addi	sp,sp,96
    80003404:	8082                	ret
    brelse(bp);
    80003406:	854a                	mv	a0,s2
    80003408:	e13ff0ef          	jal	8000321a <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    8000340c:	015c87bb          	addw	a5,s9,s5
    80003410:	00078a9b          	sext.w	s5,a5
    80003414:	004b2703          	lw	a4,4(s6)
    80003418:	04eaff63          	bgeu	s5,a4,80003476 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    8000341c:	41fad79b          	sraiw	a5,s5,0x1f
    80003420:	0137d79b          	srliw	a5,a5,0x13
    80003424:	015787bb          	addw	a5,a5,s5
    80003428:	40d7d79b          	sraiw	a5,a5,0xd
    8000342c:	01cb2583          	lw	a1,28(s6)
    80003430:	9dbd                	addw	a1,a1,a5
    80003432:	855e                	mv	a0,s7
    80003434:	cdfff0ef          	jal	80003112 <bread>
    80003438:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000343a:	004b2503          	lw	a0,4(s6)
    8000343e:	000a849b          	sext.w	s1,s5
    80003442:	8762                	mv	a4,s8
    80003444:	fca4f1e3          	bgeu	s1,a0,80003406 <balloc+0x90>
      m = 1 << (bi % 8);
    80003448:	00777693          	andi	a3,a4,7
    8000344c:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003450:	41f7579b          	sraiw	a5,a4,0x1f
    80003454:	01d7d79b          	srliw	a5,a5,0x1d
    80003458:	9fb9                	addw	a5,a5,a4
    8000345a:	4037d79b          	sraiw	a5,a5,0x3
    8000345e:	00f90633          	add	a2,s2,a5
    80003462:	05864603          	lbu	a2,88(a2)
    80003466:	00c6f5b3          	and	a1,a3,a2
    8000346a:	d5a1                	beqz	a1,800033b2 <balloc+0x3c>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000346c:	2705                	addiw	a4,a4,1
    8000346e:	2485                	addiw	s1,s1,1
    80003470:	fd471ae3          	bne	a4,s4,80003444 <balloc+0xce>
    80003474:	bf49                	j	80003406 <balloc+0x90>
    80003476:	6906                	ld	s2,64(sp)
    80003478:	79e2                	ld	s3,56(sp)
    8000347a:	7a42                	ld	s4,48(sp)
    8000347c:	7aa2                	ld	s5,40(sp)
    8000347e:	7b02                	ld	s6,32(sp)
    80003480:	6be2                	ld	s7,24(sp)
    80003482:	6c42                	ld	s8,16(sp)
    80003484:	6ca2                	ld	s9,8(sp)
  printk("balloc: out of blocks\n");
    80003486:	00005517          	auipc	a0,0x5
    8000348a:	14a50513          	addi	a0,a0,330 # 800085d0 <etext+0x5d0>
    8000348e:	87cfd0ef          	jal	8000050a <printk>
  return 0;
    80003492:	4481                	li	s1,0
    80003494:	b79d                	j	800033fa <balloc+0x84>

0000000080003496 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003496:	7179                	addi	sp,sp,-48
    80003498:	f406                	sd	ra,40(sp)
    8000349a:	f022                	sd	s0,32(sp)
    8000349c:	ec26                	sd	s1,24(sp)
    8000349e:	e84a                	sd	s2,16(sp)
    800034a0:	e44e                	sd	s3,8(sp)
    800034a2:	1800                	addi	s0,sp,48
    800034a4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    800034a6:	47ad                	li	a5,11
    800034a8:	02b7e663          	bltu	a5,a1,800034d4 <bmap+0x3e>
    if ((addr = ip->addrs[bn]) == 0) {
    800034ac:	02059793          	slli	a5,a1,0x20
    800034b0:	01e7d593          	srli	a1,a5,0x1e
    800034b4:	00b504b3          	add	s1,a0,a1
    800034b8:	0504a903          	lw	s2,80(s1)
    800034bc:	06091a63          	bnez	s2,80003530 <bmap+0x9a>
      addr = balloc(ip->dev);
    800034c0:	4108                	lw	a0,0(a0)
    800034c2:	eb5ff0ef          	jal	80003376 <balloc>
    800034c6:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    800034ca:	06090363          	beqz	s2,80003530 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800034ce:	0524a823          	sw	s2,80(s1)
    800034d2:	a8b9                	j	80003530 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800034d4:	ff45849b          	addiw	s1,a1,-12
    800034d8:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT) {
    800034dc:	0ff00793          	li	a5,255
    800034e0:	06e7ee63          	bltu	a5,a4,8000355c <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    800034e4:	08052903          	lw	s2,128(a0)
    800034e8:	00091d63          	bnez	s2,80003502 <bmap+0x6c>
      addr = balloc(ip->dev);
    800034ec:	4108                	lw	a0,0(a0)
    800034ee:	e89ff0ef          	jal	80003376 <balloc>
    800034f2:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    800034f6:	02090d63          	beqz	s2,80003530 <bmap+0x9a>
    800034fa:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034fc:	0929a023          	sw	s2,128(s3)
    80003500:	a011                	j	80003504 <bmap+0x6e>
    80003502:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003504:	85ca                	mv	a1,s2
    80003506:	0009a503          	lw	a0,0(s3)
    8000350a:	c09ff0ef          	jal	80003112 <bread>
    8000350e:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80003510:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80003514:	02049713          	slli	a4,s1,0x20
    80003518:	01e75593          	srli	a1,a4,0x1e
    8000351c:	00b784b3          	add	s1,a5,a1
    80003520:	0004a903          	lw	s2,0(s1)
    80003524:	00090e63          	beqz	s2,80003540 <bmap+0xaa>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003528:	8552                	mv	a0,s4
    8000352a:	cf1ff0ef          	jal	8000321a <brelse>
    return addr;
    8000352e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003530:	854a                	mv	a0,s2
    80003532:	70a2                	ld	ra,40(sp)
    80003534:	7402                	ld	s0,32(sp)
    80003536:	64e2                	ld	s1,24(sp)
    80003538:	6942                	ld	s2,16(sp)
    8000353a:	69a2                	ld	s3,8(sp)
    8000353c:	6145                	addi	sp,sp,48
    8000353e:	8082                	ret
      addr = balloc(ip->dev);
    80003540:	0009a503          	lw	a0,0(s3)
    80003544:	e33ff0ef          	jal	80003376 <balloc>
    80003548:	0005091b          	sext.w	s2,a0
      if (addr) {
    8000354c:	fc090ee3          	beqz	s2,80003528 <bmap+0x92>
        a[bn] = addr;
    80003550:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003554:	8552                	mv	a0,s4
    80003556:	677000ef          	jal	800043cc <log_write>
    8000355a:	b7f9                	j	80003528 <bmap+0x92>
    8000355c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000355e:	00005517          	auipc	a0,0x5
    80003562:	08a50513          	addi	a0,a0,138 # 800085e8 <etext+0x5e8>
    80003566:	a8afd0ef          	jal	800007f0 <panic>

000000008000356a <iget>:
{
    8000356a:	7179                	addi	sp,sp,-48
    8000356c:	f406                	sd	ra,40(sp)
    8000356e:	f022                	sd	s0,32(sp)
    80003570:	ec26                	sd	s1,24(sp)
    80003572:	e84a                	sd	s2,16(sp)
    80003574:	e44e                	sd	s3,8(sp)
    80003576:	e052                	sd	s4,0(sp)
    80003578:	1800                	addi	s0,sp,48
    8000357a:	89aa                	mv	s3,a0
    8000357c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000357e:	00020517          	auipc	a0,0x20
    80003582:	84a50513          	addi	a0,a0,-1974 # 80022dc8 <itable>
    80003586:	e0afd0ef          	jal	80000b90 <acquire>
  empty = 0;
    8000358a:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000358c:	00020497          	auipc	s1,0x20
    80003590:	85448493          	addi	s1,s1,-1964 # 80022de0 <itable+0x18>
    80003594:	00021697          	auipc	a3,0x21
    80003598:	2dc68693          	addi	a3,a3,732 # 80024870 <log>
    8000359c:	a039                	j	800035aa <iget+0x40>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    8000359e:	02090963          	beqz	s2,800035d0 <iget+0x66>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    800035a2:	08848493          	addi	s1,s1,136
    800035a6:	02d48863          	beq	s1,a3,800035d6 <iget+0x6c>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    800035aa:	449c                	lw	a5,8(s1)
    800035ac:	fef059e3          	blez	a5,8000359e <iget+0x34>
    800035b0:	4098                	lw	a4,0(s1)
    800035b2:	ff3716e3          	bne	a4,s3,8000359e <iget+0x34>
    800035b6:	40d8                	lw	a4,4(s1)
    800035b8:	ff4713e3          	bne	a4,s4,8000359e <iget+0x34>
      ip->ref++;
    800035bc:	2785                	addiw	a5,a5,1
    800035be:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035c0:	00020517          	auipc	a0,0x20
    800035c4:	80850513          	addi	a0,a0,-2040 # 80022dc8 <itable>
    800035c8:	e54fd0ef          	jal	80000c1c <release>
      return ip;
    800035cc:	8926                	mv	s2,s1
    800035ce:	a02d                	j	800035f8 <iget+0x8e>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    800035d0:	fbe9                	bnez	a5,800035a2 <iget+0x38>
      empty = ip;
    800035d2:	8926                	mv	s2,s1
    800035d4:	b7f9                	j	800035a2 <iget+0x38>
  if (empty == 0)
    800035d6:	02090a63          	beqz	s2,8000360a <iget+0xa0>
  ip->dev = dev;
    800035da:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035de:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035e2:	4785                	li	a5,1
    800035e4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035e8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800035ec:	0001f517          	auipc	a0,0x1f
    800035f0:	7dc50513          	addi	a0,a0,2012 # 80022dc8 <itable>
    800035f4:	e28fd0ef          	jal	80000c1c <release>
}
    800035f8:	854a                	mv	a0,s2
    800035fa:	70a2                	ld	ra,40(sp)
    800035fc:	7402                	ld	s0,32(sp)
    800035fe:	64e2                	ld	s1,24(sp)
    80003600:	6942                	ld	s2,16(sp)
    80003602:	69a2                	ld	s3,8(sp)
    80003604:	6a02                	ld	s4,0(sp)
    80003606:	6145                	addi	sp,sp,48
    80003608:	8082                	ret
    panic("iget: no inodes");
    8000360a:	00005517          	auipc	a0,0x5
    8000360e:	ff650513          	addi	a0,a0,-10 # 80008600 <etext+0x600>
    80003612:	9defd0ef          	jal	800007f0 <panic>

0000000080003616 <iinit>:
{
    80003616:	7179                	addi	sp,sp,-48
    80003618:	f406                	sd	ra,40(sp)
    8000361a:	f022                	sd	s0,32(sp)
    8000361c:	ec26                	sd	s1,24(sp)
    8000361e:	e84a                	sd	s2,16(sp)
    80003620:	e44e                	sd	s3,8(sp)
    80003622:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003624:	00005597          	auipc	a1,0x5
    80003628:	fec58593          	addi	a1,a1,-20 # 80008610 <etext+0x610>
    8000362c:	0001f517          	auipc	a0,0x1f
    80003630:	79c50513          	addi	a0,a0,1948 # 80022dc8 <itable>
    80003634:	ce6fd0ef          	jal	80000b1a <initlock>
  for (i = 0; i < NINODE; i++) {
    80003638:	0001f497          	auipc	s1,0x1f
    8000363c:	7b848493          	addi	s1,s1,1976 # 80022df0 <itable+0x28>
    80003640:	00021997          	auipc	s3,0x21
    80003644:	24098993          	addi	s3,s3,576 # 80024880 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003648:	00005917          	auipc	s2,0x5
    8000364c:	fd090913          	addi	s2,s2,-48 # 80008618 <etext+0x618>
    80003650:	85ca                	mv	a1,s2
    80003652:	8526                	mv	a0,s1
    80003654:	6ab000ef          	jal	800044fe <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003658:	08848493          	addi	s1,s1,136
    8000365c:	ff349ae3          	bne	s1,s3,80003650 <iinit+0x3a>
}
    80003660:	70a2                	ld	ra,40(sp)
    80003662:	7402                	ld	s0,32(sp)
    80003664:	64e2                	ld	s1,24(sp)
    80003666:	6942                	ld	s2,16(sp)
    80003668:	69a2                	ld	s3,8(sp)
    8000366a:	6145                	addi	sp,sp,48
    8000366c:	8082                	ret

000000008000366e <ialloc>:
{
    8000366e:	7139                	addi	sp,sp,-64
    80003670:	fc06                	sd	ra,56(sp)
    80003672:	f822                	sd	s0,48(sp)
    80003674:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003676:	0001f717          	auipc	a4,0x1f
    8000367a:	73e72703          	lw	a4,1854(a4) # 80022db4 <sb+0xc>
    8000367e:	4785                	li	a5,1
    80003680:	06e7f063          	bgeu	a5,a4,800036e0 <ialloc+0x72>
    80003684:	f426                	sd	s1,40(sp)
    80003686:	f04a                	sd	s2,32(sp)
    80003688:	ec4e                	sd	s3,24(sp)
    8000368a:	e852                	sd	s4,16(sp)
    8000368c:	e456                	sd	s5,8(sp)
    8000368e:	e05a                	sd	s6,0(sp)
    80003690:	8aaa                	mv	s5,a0
    80003692:	8b2e                	mv	s6,a1
    80003694:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003696:	0001fa17          	auipc	s4,0x1f
    8000369a:	712a0a13          	addi	s4,s4,1810 # 80022da8 <sb>
    8000369e:	00495593          	srli	a1,s2,0x4
    800036a2:	018a2783          	lw	a5,24(s4)
    800036a6:	9dbd                	addw	a1,a1,a5
    800036a8:	8556                	mv	a0,s5
    800036aa:	a69ff0ef          	jal	80003112 <bread>
    800036ae:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800036b0:	05850993          	addi	s3,a0,88
    800036b4:	00f97793          	andi	a5,s2,15
    800036b8:	079a                	slli	a5,a5,0x6
    800036ba:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800036bc:	00099783          	lh	a5,0(s3)
    800036c0:	cb9d                	beqz	a5,800036f6 <ialloc+0x88>
    brelse(bp);
    800036c2:	b59ff0ef          	jal	8000321a <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800036c6:	0905                	addi	s2,s2,1
    800036c8:	00ca2703          	lw	a4,12(s4)
    800036cc:	0009079b          	sext.w	a5,s2
    800036d0:	fce7e7e3          	bltu	a5,a4,8000369e <ialloc+0x30>
    800036d4:	74a2                	ld	s1,40(sp)
    800036d6:	7902                	ld	s2,32(sp)
    800036d8:	69e2                	ld	s3,24(sp)
    800036da:	6a42                	ld	s4,16(sp)
    800036dc:	6aa2                	ld	s5,8(sp)
    800036de:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800036e0:	00005517          	auipc	a0,0x5
    800036e4:	f4050513          	addi	a0,a0,-192 # 80008620 <etext+0x620>
    800036e8:	e23fc0ef          	jal	8000050a <printk>
  return 0;
    800036ec:	4501                	li	a0,0
}
    800036ee:	70e2                	ld	ra,56(sp)
    800036f0:	7442                	ld	s0,48(sp)
    800036f2:	6121                	addi	sp,sp,64
    800036f4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036f6:	04000613          	li	a2,64
    800036fa:	4581                	li	a1,0
    800036fc:	854e                	mv	a0,s3
    800036fe:	d56fd0ef          	jal	80000c54 <memset>
      dip->type = type;
    80003702:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003706:	8526                	mv	a0,s1
    80003708:	4c5000ef          	jal	800043cc <log_write>
      brelse(bp);
    8000370c:	8526                	mv	a0,s1
    8000370e:	b0dff0ef          	jal	8000321a <brelse>
      return iget(dev, inum);
    80003712:	0009059b          	sext.w	a1,s2
    80003716:	8556                	mv	a0,s5
    80003718:	e53ff0ef          	jal	8000356a <iget>
    8000371c:	74a2                	ld	s1,40(sp)
    8000371e:	7902                	ld	s2,32(sp)
    80003720:	69e2                	ld	s3,24(sp)
    80003722:	6a42                	ld	s4,16(sp)
    80003724:	6aa2                	ld	s5,8(sp)
    80003726:	6b02                	ld	s6,0(sp)
    80003728:	b7d9                	j	800036ee <ialloc+0x80>

000000008000372a <iupdate>:
{
    8000372a:	1101                	addi	sp,sp,-32
    8000372c:	ec06                	sd	ra,24(sp)
    8000372e:	e822                	sd	s0,16(sp)
    80003730:	e426                	sd	s1,8(sp)
    80003732:	e04a                	sd	s2,0(sp)
    80003734:	1000                	addi	s0,sp,32
    80003736:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003738:	415c                	lw	a5,4(a0)
    8000373a:	0047d79b          	srliw	a5,a5,0x4
    8000373e:	0001f597          	auipc	a1,0x1f
    80003742:	6825a583          	lw	a1,1666(a1) # 80022dc0 <sb+0x18>
    80003746:	9dbd                	addw	a1,a1,a5
    80003748:	4108                	lw	a0,0(a0)
    8000374a:	9c9ff0ef          	jal	80003112 <bread>
    8000374e:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003750:	05850793          	addi	a5,a0,88
    80003754:	40d8                	lw	a4,4(s1)
    80003756:	8b3d                	andi	a4,a4,15
    80003758:	071a                	slli	a4,a4,0x6
    8000375a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000375c:	04449703          	lh	a4,68(s1)
    80003760:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003764:	04649703          	lh	a4,70(s1)
    80003768:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000376c:	04849703          	lh	a4,72(s1)
    80003770:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003774:	04a49703          	lh	a4,74(s1)
    80003778:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000377c:	44f8                	lw	a4,76(s1)
    8000377e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003780:	03400613          	li	a2,52
    80003784:	05048593          	addi	a1,s1,80
    80003788:	00c78513          	addi	a0,a5,12
    8000378c:	d24fd0ef          	jal	80000cb0 <memmove>
  log_write(bp);
    80003790:	854a                	mv	a0,s2
    80003792:	43b000ef          	jal	800043cc <log_write>
  brelse(bp);
    80003796:	854a                	mv	a0,s2
    80003798:	a83ff0ef          	jal	8000321a <brelse>
}
    8000379c:	60e2                	ld	ra,24(sp)
    8000379e:	6442                	ld	s0,16(sp)
    800037a0:	64a2                	ld	s1,8(sp)
    800037a2:	6902                	ld	s2,0(sp)
    800037a4:	6105                	addi	sp,sp,32
    800037a6:	8082                	ret

00000000800037a8 <idup>:
{
    800037a8:	1101                	addi	sp,sp,-32
    800037aa:	ec06                	sd	ra,24(sp)
    800037ac:	e822                	sd	s0,16(sp)
    800037ae:	e426                	sd	s1,8(sp)
    800037b0:	1000                	addi	s0,sp,32
    800037b2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037b4:	0001f517          	auipc	a0,0x1f
    800037b8:	61450513          	addi	a0,a0,1556 # 80022dc8 <itable>
    800037bc:	bd4fd0ef          	jal	80000b90 <acquire>
  ip->ref++;
    800037c0:	449c                	lw	a5,8(s1)
    800037c2:	2785                	addiw	a5,a5,1
    800037c4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037c6:	0001f517          	auipc	a0,0x1f
    800037ca:	60250513          	addi	a0,a0,1538 # 80022dc8 <itable>
    800037ce:	c4efd0ef          	jal	80000c1c <release>
}
    800037d2:	8526                	mv	a0,s1
    800037d4:	60e2                	ld	ra,24(sp)
    800037d6:	6442                	ld	s0,16(sp)
    800037d8:	64a2                	ld	s1,8(sp)
    800037da:	6105                	addi	sp,sp,32
    800037dc:	8082                	ret

00000000800037de <ilock>:
{
    800037de:	1101                	addi	sp,sp,-32
    800037e0:	ec06                	sd	ra,24(sp)
    800037e2:	e822                	sd	s0,16(sp)
    800037e4:	e426                	sd	s1,8(sp)
    800037e6:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800037e8:	cd19                	beqz	a0,80003806 <ilock+0x28>
    800037ea:	84aa                	mv	s1,a0
    800037ec:	451c                	lw	a5,8(a0)
    800037ee:	00f05c63          	blez	a5,80003806 <ilock+0x28>
  acquiresleep(&ip->lock);
    800037f2:	0541                	addi	a0,a0,16
    800037f4:	541000ef          	jal	80004534 <acquiresleep>
  if (ip->valid == 0) {
    800037f8:	40bc                	lw	a5,64(s1)
    800037fa:	cf89                	beqz	a5,80003814 <ilock+0x36>
}
    800037fc:	60e2                	ld	ra,24(sp)
    800037fe:	6442                	ld	s0,16(sp)
    80003800:	64a2                	ld	s1,8(sp)
    80003802:	6105                	addi	sp,sp,32
    80003804:	8082                	ret
    80003806:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003808:	00005517          	auipc	a0,0x5
    8000380c:	e3050513          	addi	a0,a0,-464 # 80008638 <etext+0x638>
    80003810:	fe1fc0ef          	jal	800007f0 <panic>
    80003814:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003816:	40dc                	lw	a5,4(s1)
    80003818:	0047d79b          	srliw	a5,a5,0x4
    8000381c:	0001f597          	auipc	a1,0x1f
    80003820:	5a45a583          	lw	a1,1444(a1) # 80022dc0 <sb+0x18>
    80003824:	9dbd                	addw	a1,a1,a5
    80003826:	4088                	lw	a0,0(s1)
    80003828:	8ebff0ef          	jal	80003112 <bread>
    8000382c:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000382e:	05850593          	addi	a1,a0,88
    80003832:	40dc                	lw	a5,4(s1)
    80003834:	8bbd                	andi	a5,a5,15
    80003836:	079a                	slli	a5,a5,0x6
    80003838:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000383a:	00059783          	lh	a5,0(a1)
    8000383e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003842:	00259783          	lh	a5,2(a1)
    80003846:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000384a:	00459783          	lh	a5,4(a1)
    8000384e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003852:	00659783          	lh	a5,6(a1)
    80003856:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000385a:	459c                	lw	a5,8(a1)
    8000385c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000385e:	03400613          	li	a2,52
    80003862:	05b1                	addi	a1,a1,12
    80003864:	05048513          	addi	a0,s1,80
    80003868:	c48fd0ef          	jal	80000cb0 <memmove>
    brelse(bp);
    8000386c:	854a                	mv	a0,s2
    8000386e:	9adff0ef          	jal	8000321a <brelse>
    ip->valid = 1;
    80003872:	4785                	li	a5,1
    80003874:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003876:	04449783          	lh	a5,68(s1)
    8000387a:	c399                	beqz	a5,80003880 <ilock+0xa2>
    8000387c:	6902                	ld	s2,0(sp)
    8000387e:	bfbd                	j	800037fc <ilock+0x1e>
      panic("ilock: no type");
    80003880:	00005517          	auipc	a0,0x5
    80003884:	dc050513          	addi	a0,a0,-576 # 80008640 <etext+0x640>
    80003888:	f69fc0ef          	jal	800007f0 <panic>

000000008000388c <iunlock>:
{
    8000388c:	1101                	addi	sp,sp,-32
    8000388e:	ec06                	sd	ra,24(sp)
    80003890:	e822                	sd	s0,16(sp)
    80003892:	e426                	sd	s1,8(sp)
    80003894:	e04a                	sd	s2,0(sp)
    80003896:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003898:	c505                	beqz	a0,800038c0 <iunlock+0x34>
    8000389a:	84aa                	mv	s1,a0
    8000389c:	01050913          	addi	s2,a0,16
    800038a0:	854a                	mv	a0,s2
    800038a2:	51f000ef          	jal	800045c0 <holdingsleep>
    800038a6:	cd09                	beqz	a0,800038c0 <iunlock+0x34>
    800038a8:	449c                	lw	a5,8(s1)
    800038aa:	00f05b63          	blez	a5,800038c0 <iunlock+0x34>
  releasesleep(&ip->lock);
    800038ae:	854a                	mv	a0,s2
    800038b0:	4d9000ef          	jal	80004588 <releasesleep>
}
    800038b4:	60e2                	ld	ra,24(sp)
    800038b6:	6442                	ld	s0,16(sp)
    800038b8:	64a2                	ld	s1,8(sp)
    800038ba:	6902                	ld	s2,0(sp)
    800038bc:	6105                	addi	sp,sp,32
    800038be:	8082                	ret
    panic("iunlock");
    800038c0:	00005517          	auipc	a0,0x5
    800038c4:	d9050513          	addi	a0,a0,-624 # 80008650 <etext+0x650>
    800038c8:	f29fc0ef          	jal	800007f0 <panic>

00000000800038cc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038cc:	7179                	addi	sp,sp,-48
    800038ce:	f406                	sd	ra,40(sp)
    800038d0:	f022                	sd	s0,32(sp)
    800038d2:	ec26                	sd	s1,24(sp)
    800038d4:	e84a                	sd	s2,16(sp)
    800038d6:	e44e                	sd	s3,8(sp)
    800038d8:	1800                	addi	s0,sp,48
    800038da:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800038dc:	05050493          	addi	s1,a0,80
    800038e0:	08050913          	addi	s2,a0,128
    800038e4:	a021                	j	800038ec <itrunc+0x20>
    800038e6:	0491                	addi	s1,s1,4
    800038e8:	01248b63          	beq	s1,s2,800038fe <itrunc+0x32>
    if (ip->addrs[i]) {
    800038ec:	408c                	lw	a1,0(s1)
    800038ee:	dde5                	beqz	a1,800038e6 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800038f0:	0009a503          	lw	a0,0(s3)
    800038f4:	a17ff0ef          	jal	8000330a <bfree>
      ip->addrs[i] = 0;
    800038f8:	0004a023          	sw	zero,0(s1)
    800038fc:	b7ed                	j	800038e6 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800038fe:	0809a583          	lw	a1,128(s3)
    80003902:	ed89                	bnez	a1,8000391c <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003904:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003908:	854e                	mv	a0,s3
    8000390a:	e21ff0ef          	jal	8000372a <iupdate>
}
    8000390e:	70a2                	ld	ra,40(sp)
    80003910:	7402                	ld	s0,32(sp)
    80003912:	64e2                	ld	s1,24(sp)
    80003914:	6942                	ld	s2,16(sp)
    80003916:	69a2                	ld	s3,8(sp)
    80003918:	6145                	addi	sp,sp,48
    8000391a:	8082                	ret
    8000391c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000391e:	0009a503          	lw	a0,0(s3)
    80003922:	ff0ff0ef          	jal	80003112 <bread>
    80003926:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003928:	05850493          	addi	s1,a0,88
    8000392c:	45850913          	addi	s2,a0,1112
    80003930:	a021                	j	80003938 <itrunc+0x6c>
    80003932:	0491                	addi	s1,s1,4
    80003934:	01248963          	beq	s1,s2,80003946 <itrunc+0x7a>
      if (a[j])
    80003938:	408c                	lw	a1,0(s1)
    8000393a:	dde5                	beqz	a1,80003932 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000393c:	0009a503          	lw	a0,0(s3)
    80003940:	9cbff0ef          	jal	8000330a <bfree>
    80003944:	b7fd                	j	80003932 <itrunc+0x66>
    brelse(bp);
    80003946:	8552                	mv	a0,s4
    80003948:	8d3ff0ef          	jal	8000321a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000394c:	0809a583          	lw	a1,128(s3)
    80003950:	0009a503          	lw	a0,0(s3)
    80003954:	9b7ff0ef          	jal	8000330a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003958:	0809a023          	sw	zero,128(s3)
    8000395c:	6a02                	ld	s4,0(sp)
    8000395e:	b75d                	j	80003904 <itrunc+0x38>

0000000080003960 <iput>:
{
    80003960:	7179                	addi	sp,sp,-48
    80003962:	f406                	sd	ra,40(sp)
    80003964:	f022                	sd	s0,32(sp)
    80003966:	ec26                	sd	s1,24(sp)
    80003968:	1800                	addi	s0,sp,48
    8000396a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000396c:	0001f517          	auipc	a0,0x1f
    80003970:	45c50513          	addi	a0,a0,1116 # 80022dc8 <itable>
    80003974:	a1cfd0ef          	jal	80000b90 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003978:	449c                	lw	a5,8(s1)
    8000397a:	4705                	li	a4,1
    8000397c:	00e78f63          	beq	a5,a4,8000399a <iput+0x3a>
  ip->ref--;
    80003980:	37fd                	addiw	a5,a5,-1
    80003982:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003984:	0001f517          	auipc	a0,0x1f
    80003988:	44450513          	addi	a0,a0,1092 # 80022dc8 <itable>
    8000398c:	a90fd0ef          	jal	80000c1c <release>
}
    80003990:	70a2                	ld	ra,40(sp)
    80003992:	7402                	ld	s0,32(sp)
    80003994:	64e2                	ld	s1,24(sp)
    80003996:	6145                	addi	sp,sp,48
    80003998:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    8000399a:	40b8                	lw	a4,64(s1)
    8000399c:	d375                	beqz	a4,80003980 <iput+0x20>
    8000399e:	e84a                	sd	s2,16(sp)
    800039a0:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800039a2:	0004aa03          	lw	s4,0(s1)
    800039a6:	0044a903          	lw	s2,4(s1)
  if (last) {
    800039aa:	04a49703          	lh	a4,74(s1)
    800039ae:	ef35                	bnez	a4,80003a2a <iput+0xca>
    800039b0:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800039b2:	01048993          	addi	s3,s1,16
    800039b6:	854e                	mv	a0,s3
    800039b8:	37d000ef          	jal	80004534 <acquiresleep>
    release(&itable.lock);
    800039bc:	0001f517          	auipc	a0,0x1f
    800039c0:	40c50513          	addi	a0,a0,1036 # 80022dc8 <itable>
    800039c4:	a58fd0ef          	jal	80000c1c <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800039c8:	8526                	mv	a0,s1
    800039ca:	f03ff0ef          	jal	800038cc <itrunc>
    ip->valid = 0;
    800039ce:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039d2:	854e                	mv	a0,s3
    800039d4:	3b5000ef          	jal	80004588 <releasesleep>
    acquire(&itable.lock);
    800039d8:	0001f517          	auipc	a0,0x1f
    800039dc:	3f050513          	addi	a0,a0,1008 # 80022dc8 <itable>
    800039e0:	9b0fd0ef          	jal	80000b90 <acquire>
  ip->ref--;
    800039e4:	449c                	lw	a5,8(s1)
    800039e6:	37fd                	addiw	a5,a5,-1
    800039e8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039ea:	0001f517          	auipc	a0,0x1f
    800039ee:	3de50513          	addi	a0,a0,990 # 80022dc8 <itable>
    800039f2:	a2afd0ef          	jal	80000c1c <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800039f6:	0049559b          	srliw	a1,s2,0x4
    800039fa:	0001f797          	auipc	a5,0x1f
    800039fe:	3c67a783          	lw	a5,966(a5) # 80022dc0 <sb+0x18>
    80003a02:	9dbd                	addw	a1,a1,a5
    80003a04:	8552                	mv	a0,s4
    80003a06:	f0cff0ef          	jal	80003112 <bread>
    80003a0a:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003a0c:	00f97913          	andi	s2,s2,15
  dip->type = 0;
    80003a10:	091a                	slli	s2,s2,0x6
    80003a12:	992a                	add	s2,s2,a0
    80003a14:	04091c23          	sh	zero,88(s2)
  log_write(bp);
    80003a18:	1b5000ef          	jal	800043cc <log_write>
  brelse(bp);
    80003a1c:	8526                	mv	a0,s1
    80003a1e:	ffcff0ef          	jal	8000321a <brelse>
}
    80003a22:	6942                	ld	s2,16(sp)
    80003a24:	69a2                	ld	s3,8(sp)
    80003a26:	6a02                	ld	s4,0(sp)
    80003a28:	b7a5                	j	80003990 <iput+0x30>
    80003a2a:	6942                	ld	s2,16(sp)
    80003a2c:	6a02                	ld	s4,0(sp)
    80003a2e:	bf89                	j	80003980 <iput+0x20>

0000000080003a30 <iunlockput>:
{
    80003a30:	1101                	addi	sp,sp,-32
    80003a32:	ec06                	sd	ra,24(sp)
    80003a34:	e822                	sd	s0,16(sp)
    80003a36:	e426                	sd	s1,8(sp)
    80003a38:	1000                	addi	s0,sp,32
    80003a3a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a3c:	e51ff0ef          	jal	8000388c <iunlock>
  iput(ip);
    80003a40:	8526                	mv	a0,s1
    80003a42:	f1fff0ef          	jal	80003960 <iput>
}
    80003a46:	60e2                	ld	ra,24(sp)
    80003a48:	6442                	ld	s0,16(sp)
    80003a4a:	64a2                	ld	s1,8(sp)
    80003a4c:	6105                	addi	sp,sp,32
    80003a4e:	8082                	ret

0000000080003a50 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a50:	0001f717          	auipc	a4,0x1f
    80003a54:	36472703          	lw	a4,868(a4) # 80022db4 <sb+0xc>
    80003a58:	4785                	li	a5,1
    80003a5a:	0ae7ff63          	bgeu	a5,a4,80003b18 <ireclaim+0xc8>
{
    80003a5e:	7139                	addi	sp,sp,-64
    80003a60:	fc06                	sd	ra,56(sp)
    80003a62:	f822                	sd	s0,48(sp)
    80003a64:	f426                	sd	s1,40(sp)
    80003a66:	f04a                	sd	s2,32(sp)
    80003a68:	ec4e                	sd	s3,24(sp)
    80003a6a:	e852                	sd	s4,16(sp)
    80003a6c:	e456                	sd	s5,8(sp)
    80003a6e:	e05a                	sd	s6,0(sp)
    80003a70:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a72:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a74:	00050a1b          	sext.w	s4,a0
    80003a78:	0001fa97          	auipc	s5,0x1f
    80003a7c:	330a8a93          	addi	s5,s5,816 # 80022da8 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003a80:	00005b17          	auipc	s6,0x5
    80003a84:	bd8b0b13          	addi	s6,s6,-1064 # 80008658 <etext+0x658>
    80003a88:	a099                	j	80003ace <ireclaim+0x7e>
    80003a8a:	85ce                	mv	a1,s3
    80003a8c:	855a                	mv	a0,s6
    80003a8e:	a7dfc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003a92:	85ce                	mv	a1,s3
    80003a94:	8552                	mv	a0,s4
    80003a96:	ad5ff0ef          	jal	8000356a <iget>
    80003a9a:	89aa                	mv	s3,a0
    brelse(bp);
    80003a9c:	854a                	mv	a0,s2
    80003a9e:	f7cff0ef          	jal	8000321a <brelse>
    if (ip) {
    80003aa2:	00098f63          	beqz	s3,80003ac0 <ireclaim+0x70>
      begin_op();
    80003aa6:	780000ef          	jal	80004226 <begin_op>
      ilock(ip);
    80003aaa:	854e                	mv	a0,s3
    80003aac:	d33ff0ef          	jal	800037de <ilock>
      iunlock(ip);
    80003ab0:	854e                	mv	a0,s3
    80003ab2:	ddbff0ef          	jal	8000388c <iunlock>
      iput(ip);
    80003ab6:	854e                	mv	a0,s3
    80003ab8:	ea9ff0ef          	jal	80003960 <iput>
      end_op();
    80003abc:	7f0000ef          	jal	800042ac <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003ac0:	0485                	addi	s1,s1,1
    80003ac2:	00caa703          	lw	a4,12(s5)
    80003ac6:	0004879b          	sext.w	a5,s1
    80003aca:	02e7fd63          	bgeu	a5,a4,80003b04 <ireclaim+0xb4>
    80003ace:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003ad2:	0044d593          	srli	a1,s1,0x4
    80003ad6:	018aa783          	lw	a5,24(s5)
    80003ada:	9dbd                	addw	a1,a1,a5
    80003adc:	8552                	mv	a0,s4
    80003ade:	e34ff0ef          	jal	80003112 <bread>
    80003ae2:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003ae4:	05850793          	addi	a5,a0,88
    80003ae8:	00f9f713          	andi	a4,s3,15
    80003aec:	071a                	slli	a4,a4,0x6
    80003aee:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003af0:	00079703          	lh	a4,0(a5)
    80003af4:	c701                	beqz	a4,80003afc <ireclaim+0xac>
    80003af6:	00679783          	lh	a5,6(a5)
    80003afa:	dbc1                	beqz	a5,80003a8a <ireclaim+0x3a>
    brelse(bp);
    80003afc:	854a                	mv	a0,s2
    80003afe:	f1cff0ef          	jal	8000321a <brelse>
    if (ip) {
    80003b02:	bf7d                	j	80003ac0 <ireclaim+0x70>
}
    80003b04:	70e2                	ld	ra,56(sp)
    80003b06:	7442                	ld	s0,48(sp)
    80003b08:	74a2                	ld	s1,40(sp)
    80003b0a:	7902                	ld	s2,32(sp)
    80003b0c:	69e2                	ld	s3,24(sp)
    80003b0e:	6a42                	ld	s4,16(sp)
    80003b10:	6aa2                	ld	s5,8(sp)
    80003b12:	6b02                	ld	s6,0(sp)
    80003b14:	6121                	addi	sp,sp,64
    80003b16:	8082                	ret
    80003b18:	8082                	ret

0000000080003b1a <fsinit>:
{
    80003b1a:	7179                	addi	sp,sp,-48
    80003b1c:	f406                	sd	ra,40(sp)
    80003b1e:	f022                	sd	s0,32(sp)
    80003b20:	ec26                	sd	s1,24(sp)
    80003b22:	e84a                	sd	s2,16(sp)
    80003b24:	e44e                	sd	s3,8(sp)
    80003b26:	1800                	addi	s0,sp,48
    80003b28:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003b2a:	4585                	li	a1,1
    80003b2c:	de6ff0ef          	jal	80003112 <bread>
    80003b30:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b32:	0001f997          	auipc	s3,0x1f
    80003b36:	27698993          	addi	s3,s3,630 # 80022da8 <sb>
    80003b3a:	02000613          	li	a2,32
    80003b3e:	05850593          	addi	a1,a0,88
    80003b42:	854e                	mv	a0,s3
    80003b44:	96cfd0ef          	jal	80000cb0 <memmove>
  brelse(bp);
    80003b48:	854a                	mv	a0,s2
    80003b4a:	ed0ff0ef          	jal	8000321a <brelse>
  if (sb.magic != FSMAGIC)
    80003b4e:	0009a703          	lw	a4,0(s3)
    80003b52:	102037b7          	lui	a5,0x10203
    80003b56:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b5a:	02f71363          	bne	a4,a5,80003b80 <fsinit+0x66>
  initlog(dev, &sb);
    80003b5e:	0001f597          	auipc	a1,0x1f
    80003b62:	24a58593          	addi	a1,a1,586 # 80022da8 <sb>
    80003b66:	8526                	mv	a0,s1
    80003b68:	640000ef          	jal	800041a8 <initlog>
  ireclaim(dev);
    80003b6c:	8526                	mv	a0,s1
    80003b6e:	ee3ff0ef          	jal	80003a50 <ireclaim>
}
    80003b72:	70a2                	ld	ra,40(sp)
    80003b74:	7402                	ld	s0,32(sp)
    80003b76:	64e2                	ld	s1,24(sp)
    80003b78:	6942                	ld	s2,16(sp)
    80003b7a:	69a2                	ld	s3,8(sp)
    80003b7c:	6145                	addi	sp,sp,48
    80003b7e:	8082                	ret
    panic("invalid file system");
    80003b80:	00005517          	auipc	a0,0x5
    80003b84:	af850513          	addi	a0,a0,-1288 # 80008678 <etext+0x678>
    80003b88:	c69fc0ef          	jal	800007f0 <panic>

0000000080003b8c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b8c:	1141                	addi	sp,sp,-16
    80003b8e:	e422                	sd	s0,8(sp)
    80003b90:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b92:	411c                	lw	a5,0(a0)
    80003b94:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b96:	415c                	lw	a5,4(a0)
    80003b98:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b9a:	04451783          	lh	a5,68(a0)
    80003b9e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ba2:	04a51783          	lh	a5,74(a0)
    80003ba6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003baa:	04c56783          	lwu	a5,76(a0)
    80003bae:	e99c                	sd	a5,16(a1)
}
    80003bb0:	6422                	ld	s0,8(sp)
    80003bb2:	0141                	addi	sp,sp,16
    80003bb4:	8082                	ret

0000000080003bb6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003bb6:	457c                	lw	a5,76(a0)
    80003bb8:	0ed7eb63          	bltu	a5,a3,80003cae <readi+0xf8>
{
    80003bbc:	7159                	addi	sp,sp,-112
    80003bbe:	f486                	sd	ra,104(sp)
    80003bc0:	f0a2                	sd	s0,96(sp)
    80003bc2:	eca6                	sd	s1,88(sp)
    80003bc4:	e0d2                	sd	s4,64(sp)
    80003bc6:	fc56                	sd	s5,56(sp)
    80003bc8:	f85a                	sd	s6,48(sp)
    80003bca:	f45e                	sd	s7,40(sp)
    80003bcc:	1880                	addi	s0,sp,112
    80003bce:	8b2a                	mv	s6,a0
    80003bd0:	8bae                	mv	s7,a1
    80003bd2:	8a32                	mv	s4,a2
    80003bd4:	84b6                	mv	s1,a3
    80003bd6:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003bd8:	9f35                	addw	a4,a4,a3
    return 0;
    80003bda:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003bdc:	0cd76063          	bltu	a4,a3,80003c9c <readi+0xe6>
    80003be0:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003be2:	00e7f463          	bgeu	a5,a4,80003bea <readi+0x34>
    n = ip->size - off;
    80003be6:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003bea:	080a8f63          	beqz	s5,80003c88 <readi+0xd2>
    80003bee:	e8ca                	sd	s2,80(sp)
    80003bf0:	f062                	sd	s8,32(sp)
    80003bf2:	ec66                	sd	s9,24(sp)
    80003bf4:	e86a                	sd	s10,16(sp)
    80003bf6:	e46e                	sd	s11,8(sp)
    80003bf8:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003bfa:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bfe:	5c7d                	li	s8,-1
    80003c00:	a80d                	j	80003c32 <readi+0x7c>
    80003c02:	020d1d93          	slli	s11,s10,0x20
    80003c06:	020ddd93          	srli	s11,s11,0x20
    80003c0a:	05890613          	addi	a2,s2,88
    80003c0e:	86ee                	mv	a3,s11
    80003c10:	963a                	add	a2,a2,a4
    80003c12:	85d2                	mv	a1,s4
    80003c14:	855e                	mv	a0,s7
    80003c16:	fb6fe0ef          	jal	800023cc <either_copyout>
    80003c1a:	05850763          	beq	a0,s8,80003c68 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c1e:	854a                	mv	a0,s2
    80003c20:	dfaff0ef          	jal	8000321a <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003c24:	013d09bb          	addw	s3,s10,s3
    80003c28:	009d04bb          	addw	s1,s10,s1
    80003c2c:	9a6e                	add	s4,s4,s11
    80003c2e:	0559f763          	bgeu	s3,s5,80003c7c <readi+0xc6>
    uint addr = bmap(ip, off / BSIZE);
    80003c32:	00a4d59b          	srliw	a1,s1,0xa
    80003c36:	855a                	mv	a0,s6
    80003c38:	85fff0ef          	jal	80003496 <bmap>
    80003c3c:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003c40:	c5b1                	beqz	a1,80003c8c <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003c42:	000b2503          	lw	a0,0(s6)
    80003c46:	cccff0ef          	jal	80003112 <bread>
    80003c4a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003c4c:	3ff4f713          	andi	a4,s1,1023
    80003c50:	40ec87bb          	subw	a5,s9,a4
    80003c54:	413a86bb          	subw	a3,s5,s3
    80003c58:	8d3e                	mv	s10,a5
    80003c5a:	2781                	sext.w	a5,a5
    80003c5c:	0006861b          	sext.w	a2,a3
    80003c60:	faf671e3          	bgeu	a2,a5,80003c02 <readi+0x4c>
    80003c64:	8d36                	mv	s10,a3
    80003c66:	bf71                	j	80003c02 <readi+0x4c>
      brelse(bp);
    80003c68:	854a                	mv	a0,s2
    80003c6a:	db0ff0ef          	jal	8000321a <brelse>
      tot = -1;
    80003c6e:	59fd                	li	s3,-1
      break;
    80003c70:	6946                	ld	s2,80(sp)
    80003c72:	7c02                	ld	s8,32(sp)
    80003c74:	6ce2                	ld	s9,24(sp)
    80003c76:	6d42                	ld	s10,16(sp)
    80003c78:	6da2                	ld	s11,8(sp)
    80003c7a:	a831                	j	80003c96 <readi+0xe0>
    80003c7c:	6946                	ld	s2,80(sp)
    80003c7e:	7c02                	ld	s8,32(sp)
    80003c80:	6ce2                	ld	s9,24(sp)
    80003c82:	6d42                	ld	s10,16(sp)
    80003c84:	6da2                	ld	s11,8(sp)
    80003c86:	a801                	j	80003c96 <readi+0xe0>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003c88:	89d6                	mv	s3,s5
    80003c8a:	a031                	j	80003c96 <readi+0xe0>
    80003c8c:	6946                	ld	s2,80(sp)
    80003c8e:	7c02                	ld	s8,32(sp)
    80003c90:	6ce2                	ld	s9,24(sp)
    80003c92:	6d42                	ld	s10,16(sp)
    80003c94:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c96:	0009851b          	sext.w	a0,s3
    80003c9a:	69a6                	ld	s3,72(sp)
}
    80003c9c:	70a6                	ld	ra,104(sp)
    80003c9e:	7406                	ld	s0,96(sp)
    80003ca0:	64e6                	ld	s1,88(sp)
    80003ca2:	6a06                	ld	s4,64(sp)
    80003ca4:	7ae2                	ld	s5,56(sp)
    80003ca6:	7b42                	ld	s6,48(sp)
    80003ca8:	7ba2                	ld	s7,40(sp)
    80003caa:	6165                	addi	sp,sp,112
    80003cac:	8082                	ret
    return 0;
    80003cae:	4501                	li	a0,0
}
    80003cb0:	8082                	ret

0000000080003cb2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003cb2:	457c                	lw	a5,76(a0)
    80003cb4:	10d7e363          	bltu	a5,a3,80003dba <writei+0x108>
{
    80003cb8:	7159                	addi	sp,sp,-112
    80003cba:	f486                	sd	ra,104(sp)
    80003cbc:	f0a2                	sd	s0,96(sp)
    80003cbe:	e8ca                	sd	s2,80(sp)
    80003cc0:	e0d2                	sd	s4,64(sp)
    80003cc2:	fc56                	sd	s5,56(sp)
    80003cc4:	f85a                	sd	s6,48(sp)
    80003cc6:	f45e                	sd	s7,40(sp)
    80003cc8:	1880                	addi	s0,sp,112
    80003cca:	8aaa                	mv	s5,a0
    80003ccc:	8bae                	mv	s7,a1
    80003cce:	8a32                	mv	s4,a2
    80003cd0:	8936                	mv	s2,a3
    80003cd2:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003cd4:	00e687bb          	addw	a5,a3,a4
    80003cd8:	0ed7e363          	bltu	a5,a3,80003dbe <writei+0x10c>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003cdc:	00043737          	lui	a4,0x43
    80003ce0:	0ef76163          	bltu	a4,a5,80003dc2 <writei+0x110>
    80003ce4:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003ce6:	0c0b0263          	beqz	s6,80003daa <writei+0xf8>
    80003cea:	eca6                	sd	s1,88(sp)
    80003cec:	f062                	sd	s8,32(sp)
    80003cee:	ec66                	sd	s9,24(sp)
    80003cf0:	e86a                	sd	s10,16(sp)
    80003cf2:	e46e                	sd	s11,8(sp)
    80003cf4:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003cf6:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cfa:	5c7d                	li	s8,-1
    80003cfc:	a825                	j	80003d34 <writei+0x82>
    80003cfe:	020d1d93          	slli	s11,s10,0x20
    80003d02:	020ddd93          	srli	s11,s11,0x20
    80003d06:	05848513          	addi	a0,s1,88
    80003d0a:	86ee                	mv	a3,s11
    80003d0c:	8652                	mv	a2,s4
    80003d0e:	85de                	mv	a1,s7
    80003d10:	953a                	add	a0,a0,a4
    80003d12:	f06fe0ef          	jal	80002418 <either_copyin>
    80003d16:	05850a63          	beq	a0,s8,80003d6a <writei+0xb8>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d1a:	8526                	mv	a0,s1
    80003d1c:	6b0000ef          	jal	800043cc <log_write>
    brelse(bp);
    80003d20:	8526                	mv	a0,s1
    80003d22:	cf8ff0ef          	jal	8000321a <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003d26:	013d09bb          	addw	s3,s10,s3
    80003d2a:	012d093b          	addw	s2,s10,s2
    80003d2e:	9a6e                	add	s4,s4,s11
    80003d30:	0569f363          	bgeu	s3,s6,80003d76 <writei+0xc4>
    uint addr = bmap(ip, off / BSIZE);
    80003d34:	00a9559b          	srliw	a1,s2,0xa
    80003d38:	8556                	mv	a0,s5
    80003d3a:	f5cff0ef          	jal	80003496 <bmap>
    80003d3e:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003d42:	c995                	beqz	a1,80003d76 <writei+0xc4>
    bp = bread(ip->dev, addr);
    80003d44:	000aa503          	lw	a0,0(s5)
    80003d48:	bcaff0ef          	jal	80003112 <bread>
    80003d4c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003d4e:	3ff97713          	andi	a4,s2,1023
    80003d52:	40ec87bb          	subw	a5,s9,a4
    80003d56:	413b06bb          	subw	a3,s6,s3
    80003d5a:	8d3e                	mv	s10,a5
    80003d5c:	2781                	sext.w	a5,a5
    80003d5e:	0006861b          	sext.w	a2,a3
    80003d62:	f8f67ee3          	bgeu	a2,a5,80003cfe <writei+0x4c>
    80003d66:	8d36                	mv	s10,a3
    80003d68:	bf59                	j	80003cfe <writei+0x4c>
      log_write(bp);
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	660000ef          	jal	800043cc <log_write>
      brelse(bp);
    80003d70:	8526                	mv	a0,s1
    80003d72:	ca8ff0ef          	jal	8000321a <brelse>
  }

  if (off > ip->size)
    80003d76:	04caa783          	lw	a5,76(s5)
    80003d7a:	0327fa63          	bgeu	a5,s2,80003dae <writei+0xfc>
    ip->size = off;
    80003d7e:	052aa623          	sw	s2,76(s5)
    80003d82:	64e6                	ld	s1,88(sp)
    80003d84:	7c02                	ld	s8,32(sp)
    80003d86:	6ce2                	ld	s9,24(sp)
    80003d88:	6d42                	ld	s10,16(sp)
    80003d8a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d8c:	8556                	mv	a0,s5
    80003d8e:	99dff0ef          	jal	8000372a <iupdate>

  return tot;
    80003d92:	0009851b          	sext.w	a0,s3
    80003d96:	69a6                	ld	s3,72(sp)
}
    80003d98:	70a6                	ld	ra,104(sp)
    80003d9a:	7406                	ld	s0,96(sp)
    80003d9c:	6946                	ld	s2,80(sp)
    80003d9e:	6a06                	ld	s4,64(sp)
    80003da0:	7ae2                	ld	s5,56(sp)
    80003da2:	7b42                	ld	s6,48(sp)
    80003da4:	7ba2                	ld	s7,40(sp)
    80003da6:	6165                	addi	sp,sp,112
    80003da8:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003daa:	89da                	mv	s3,s6
    80003dac:	b7c5                	j	80003d8c <writei+0xda>
    80003dae:	64e6                	ld	s1,88(sp)
    80003db0:	7c02                	ld	s8,32(sp)
    80003db2:	6ce2                	ld	s9,24(sp)
    80003db4:	6d42                	ld	s10,16(sp)
    80003db6:	6da2                	ld	s11,8(sp)
    80003db8:	bfd1                	j	80003d8c <writei+0xda>
    return -1;
    80003dba:	557d                	li	a0,-1
}
    80003dbc:	8082                	ret
    return -1;
    80003dbe:	557d                	li	a0,-1
    80003dc0:	bfe1                	j	80003d98 <writei+0xe6>
    return -1;
    80003dc2:	557d                	li	a0,-1
    80003dc4:	bfd1                	j	80003d98 <writei+0xe6>

0000000080003dc6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dc6:	1141                	addi	sp,sp,-16
    80003dc8:	e406                	sd	ra,8(sp)
    80003dca:	e022                	sd	s0,0(sp)
    80003dcc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dce:	4639                	li	a2,14
    80003dd0:	f51fc0ef          	jal	80000d20 <strncmp>
}
    80003dd4:	60a2                	ld	ra,8(sp)
    80003dd6:	6402                	ld	s0,0(sp)
    80003dd8:	0141                	addi	sp,sp,16
    80003dda:	8082                	ret

0000000080003ddc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ddc:	7139                	addi	sp,sp,-64
    80003dde:	fc06                	sd	ra,56(sp)
    80003de0:	f822                	sd	s0,48(sp)
    80003de2:	f426                	sd	s1,40(sp)
    80003de4:	f04a                	sd	s2,32(sp)
    80003de6:	ec4e                	sd	s3,24(sp)
    80003de8:	e852                	sd	s4,16(sp)
    80003dea:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003dec:	04451703          	lh	a4,68(a0)
    80003df0:	4785                	li	a5,1
    80003df2:	00f71a63          	bne	a4,a5,80003e06 <dirlookup+0x2a>
    80003df6:	892a                	mv	s2,a0
    80003df8:	89ae                	mv	s3,a1
    80003dfa:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003dfc:	457c                	lw	a5,76(a0)
    80003dfe:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e00:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003e02:	e39d                	bnez	a5,80003e28 <dirlookup+0x4c>
    80003e04:	a095                	j	80003e68 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003e06:	00005517          	auipc	a0,0x5
    80003e0a:	88a50513          	addi	a0,a0,-1910 # 80008690 <etext+0x690>
    80003e0e:	9e3fc0ef          	jal	800007f0 <panic>
      panic("dirlookup read");
    80003e12:	00005517          	auipc	a0,0x5
    80003e16:	89650513          	addi	a0,a0,-1898 # 800086a8 <etext+0x6a8>
    80003e1a:	9d7fc0ef          	jal	800007f0 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003e1e:	24c1                	addiw	s1,s1,16
    80003e20:	04c92783          	lw	a5,76(s2)
    80003e24:	04f4f163          	bgeu	s1,a5,80003e66 <dirlookup+0x8a>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e28:	4741                	li	a4,16
    80003e2a:	86a6                	mv	a3,s1
    80003e2c:	fc040613          	addi	a2,s0,-64
    80003e30:	4581                	li	a1,0
    80003e32:	854a                	mv	a0,s2
    80003e34:	d83ff0ef          	jal	80003bb6 <readi>
    80003e38:	47c1                	li	a5,16
    80003e3a:	fcf51ce3          	bne	a0,a5,80003e12 <dirlookup+0x36>
    if (de.inum == 0)
    80003e3e:	fc045783          	lhu	a5,-64(s0)
    80003e42:	dff1                	beqz	a5,80003e1e <dirlookup+0x42>
    if (namecmp(name, de.name) == 0) {
    80003e44:	fc240593          	addi	a1,s0,-62
    80003e48:	854e                	mv	a0,s3
    80003e4a:	f7dff0ef          	jal	80003dc6 <namecmp>
    80003e4e:	f961                	bnez	a0,80003e1e <dirlookup+0x42>
      if (poff)
    80003e50:	000a0463          	beqz	s4,80003e58 <dirlookup+0x7c>
        *poff = off;
    80003e54:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e58:	fc045583          	lhu	a1,-64(s0)
    80003e5c:	00092503          	lw	a0,0(s2)
    80003e60:	f0aff0ef          	jal	8000356a <iget>
    80003e64:	a011                	j	80003e68 <dirlookup+0x8c>
  return 0;
    80003e66:	4501                	li	a0,0
}
    80003e68:	70e2                	ld	ra,56(sp)
    80003e6a:	7442                	ld	s0,48(sp)
    80003e6c:	74a2                	ld	s1,40(sp)
    80003e6e:	7902                	ld	s2,32(sp)
    80003e70:	69e2                	ld	s3,24(sp)
    80003e72:	6a42                	ld	s4,16(sp)
    80003e74:	6121                	addi	sp,sp,64
    80003e76:	8082                	ret

0000000080003e78 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003e78:	711d                	addi	sp,sp,-96
    80003e7a:	ec86                	sd	ra,88(sp)
    80003e7c:	e8a2                	sd	s0,80(sp)
    80003e7e:	e4a6                	sd	s1,72(sp)
    80003e80:	e0ca                	sd	s2,64(sp)
    80003e82:	fc4e                	sd	s3,56(sp)
    80003e84:	f852                	sd	s4,48(sp)
    80003e86:	f456                	sd	s5,40(sp)
    80003e88:	f05a                	sd	s6,32(sp)
    80003e8a:	ec5e                	sd	s7,24(sp)
    80003e8c:	e862                	sd	s8,16(sp)
    80003e8e:	e466                	sd	s9,8(sp)
    80003e90:	1080                	addi	s0,sp,96
    80003e92:	84aa                	mv	s1,a0
    80003e94:	8b2e                	mv	s6,a1
    80003e96:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003e98:	00054703          	lbu	a4,0(a0)
    80003e9c:	02f00793          	li	a5,47
    80003ea0:	00f70e63          	beq	a4,a5,80003ebc <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ea4:	9fffd0ef          	jal	800018a2 <myproc>
    80003ea8:	15053503          	ld	a0,336(a0)
    80003eac:	8fdff0ef          	jal	800037a8 <idup>
    80003eb0:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003eb2:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80003eb6:	4c35                	li	s8,13

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003eb8:	4b85                	li	s7,1
    80003eba:	a075                	j	80003f66 <namex+0xee>
    ip = iget(ROOTDEV, ROOTINO);
    80003ebc:	4585                	li	a1,1
    80003ebe:	4505                	li	a0,1
    80003ec0:	eaaff0ef          	jal	8000356a <iget>
    80003ec4:	8a2a                	mv	s4,a0
    80003ec6:	b7f5                	j	80003eb2 <namex+0x3a>
      iunlockput(ip);
    80003ec8:	8552                	mv	a0,s4
    80003eca:	b67ff0ef          	jal	80003a30 <iunlockput>
      return 0;
    80003ece:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ed0:	8552                	mv	a0,s4
    80003ed2:	60e6                	ld	ra,88(sp)
    80003ed4:	6446                	ld	s0,80(sp)
    80003ed6:	64a6                	ld	s1,72(sp)
    80003ed8:	6906                	ld	s2,64(sp)
    80003eda:	79e2                	ld	s3,56(sp)
    80003edc:	7a42                	ld	s4,48(sp)
    80003ede:	7aa2                	ld	s5,40(sp)
    80003ee0:	7b02                	ld	s6,32(sp)
    80003ee2:	6be2                	ld	s7,24(sp)
    80003ee4:	6c42                	ld	s8,16(sp)
    80003ee6:	6ca2                	ld	s9,8(sp)
    80003ee8:	6125                	addi	sp,sp,96
    80003eea:	8082                	ret
      iunlockput(ip);
    80003eec:	8552                	mv	a0,s4
    80003eee:	b43ff0ef          	jal	80003a30 <iunlockput>
      return 0;
    80003ef2:	4a01                	li	s4,0
    80003ef4:	bff1                	j	80003ed0 <namex+0x58>
      iunlock(ip);
    80003ef6:	8552                	mv	a0,s4
    80003ef8:	995ff0ef          	jal	8000388c <iunlock>
      return ip;
    80003efc:	bfd1                	j	80003ed0 <namex+0x58>
      iunlockput(ip);
    80003efe:	8552                	mv	a0,s4
    80003f00:	b31ff0ef          	jal	80003a30 <iunlockput>
      return 0;
    80003f04:	8a4e                	mv	s4,s3
    80003f06:	b7e9                	j	80003ed0 <namex+0x58>
  len = path - s;
    80003f08:	40998633          	sub	a2,s3,s1
    80003f0c:	00060c9b          	sext.w	s9,a2
  if (len >= DIRSIZ)
    80003f10:	099c5363          	bge	s8,s9,80003f96 <namex+0x11e>
    memmove(name, s, DIRSIZ);
    80003f14:	4639                	li	a2,14
    80003f16:	85a6                	mv	a1,s1
    80003f18:	8556                	mv	a0,s5
    80003f1a:	d97fc0ef          	jal	80000cb0 <memmove>
    80003f1e:	84ce                	mv	s1,s3
  while (*path == '/')
    80003f20:	0004c783          	lbu	a5,0(s1)
    80003f24:	01279763          	bne	a5,s2,80003f32 <namex+0xba>
    path++;
    80003f28:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003f2a:	0004c783          	lbu	a5,0(s1)
    80003f2e:	ff278de3          	beq	a5,s2,80003f28 <namex+0xb0>
    ilock(ip);
    80003f32:	8552                	mv	a0,s4
    80003f34:	8abff0ef          	jal	800037de <ilock>
    if (ip->type != T_DIR) {
    80003f38:	044a1783          	lh	a5,68(s4)
    80003f3c:	f97796e3          	bne	a5,s7,80003ec8 <namex+0x50>
    if (ip->nlink == 0) {
    80003f40:	04aa1783          	lh	a5,74(s4)
    80003f44:	d7c5                	beqz	a5,80003eec <namex+0x74>
    if (nameiparent && *path == '\0') {
    80003f46:	000b0563          	beqz	s6,80003f50 <namex+0xd8>
    80003f4a:	0004c783          	lbu	a5,0(s1)
    80003f4e:	d7c5                	beqz	a5,80003ef6 <namex+0x7e>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003f50:	4601                	li	a2,0
    80003f52:	85d6                	mv	a1,s5
    80003f54:	8552                	mv	a0,s4
    80003f56:	e87ff0ef          	jal	80003ddc <dirlookup>
    80003f5a:	89aa                	mv	s3,a0
    80003f5c:	d14d                	beqz	a0,80003efe <namex+0x86>
    iunlockput(ip);
    80003f5e:	8552                	mv	a0,s4
    80003f60:	ad1ff0ef          	jal	80003a30 <iunlockput>
    ip = next;
    80003f64:	8a4e                	mv	s4,s3
  while (*path == '/')
    80003f66:	0004c783          	lbu	a5,0(s1)
    80003f6a:	01279763          	bne	a5,s2,80003f78 <namex+0x100>
    path++;
    80003f6e:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003f70:	0004c783          	lbu	a5,0(s1)
    80003f74:	ff278de3          	beq	a5,s2,80003f6e <namex+0xf6>
  if (*path == 0)
    80003f78:	cb8d                	beqz	a5,80003faa <namex+0x132>
  while (*path != '/' && *path != 0)
    80003f7a:	0004c783          	lbu	a5,0(s1)
    80003f7e:	89a6                	mv	s3,s1
  len = path - s;
    80003f80:	4c81                	li	s9,0
    80003f82:	4601                	li	a2,0
  while (*path != '/' && *path != 0)
    80003f84:	01278963          	beq	a5,s2,80003f96 <namex+0x11e>
    80003f88:	d3c1                	beqz	a5,80003f08 <namex+0x90>
    path++;
    80003f8a:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80003f8c:	0009c783          	lbu	a5,0(s3)
    80003f90:	ff279ce3          	bne	a5,s2,80003f88 <namex+0x110>
    80003f94:	bf95                	j	80003f08 <namex+0x90>
    memmove(name, s, len);
    80003f96:	2601                	sext.w	a2,a2
    80003f98:	85a6                	mv	a1,s1
    80003f9a:	8556                	mv	a0,s5
    80003f9c:	d15fc0ef          	jal	80000cb0 <memmove>
    name[len] = 0;
    80003fa0:	9cd6                	add	s9,s9,s5
    80003fa2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003fa6:	84ce                	mv	s1,s3
    80003fa8:	bfa5                	j	80003f20 <namex+0xa8>
  if (nameiparent) {
    80003faa:	f20b03e3          	beqz	s6,80003ed0 <namex+0x58>
    iput(ip);
    80003fae:	8552                	mv	a0,s4
    80003fb0:	9b1ff0ef          	jal	80003960 <iput>
    return 0;
    80003fb4:	4a01                	li	s4,0
    80003fb6:	bf29                	j	80003ed0 <namex+0x58>

0000000080003fb8 <dirlink>:
{
    80003fb8:	7139                	addi	sp,sp,-64
    80003fba:	fc06                	sd	ra,56(sp)
    80003fbc:	f822                	sd	s0,48(sp)
    80003fbe:	f04a                	sd	s2,32(sp)
    80003fc0:	ec4e                	sd	s3,24(sp)
    80003fc2:	e852                	sd	s4,16(sp)
    80003fc4:	0080                	addi	s0,sp,64
    80003fc6:	892a                	mv	s2,a0
    80003fc8:	8a2e                	mv	s4,a1
    80003fca:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003fcc:	4601                	li	a2,0
    80003fce:	e0fff0ef          	jal	80003ddc <dirlookup>
    80003fd2:	e535                	bnez	a0,8000403e <dirlink+0x86>
    80003fd4:	f426                	sd	s1,40(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003fd6:	04c92483          	lw	s1,76(s2)
    80003fda:	c48d                	beqz	s1,80004004 <dirlink+0x4c>
    80003fdc:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fde:	4741                	li	a4,16
    80003fe0:	86a6                	mv	a3,s1
    80003fe2:	fc040613          	addi	a2,s0,-64
    80003fe6:	4581                	li	a1,0
    80003fe8:	854a                	mv	a0,s2
    80003fea:	bcdff0ef          	jal	80003bb6 <readi>
    80003fee:	47c1                	li	a5,16
    80003ff0:	04f51b63          	bne	a0,a5,80004046 <dirlink+0x8e>
    if (de.inum == 0)
    80003ff4:	fc045783          	lhu	a5,-64(s0)
    80003ff8:	c791                	beqz	a5,80004004 <dirlink+0x4c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003ffa:	24c1                	addiw	s1,s1,16
    80003ffc:	04c92783          	lw	a5,76(s2)
    80004000:	fcf4efe3          	bltu	s1,a5,80003fde <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004004:	4639                	li	a2,14
    80004006:	85d2                	mv	a1,s4
    80004008:	fc240513          	addi	a0,s0,-62
    8000400c:	d4bfc0ef          	jal	80000d56 <strncpy>
  de.inum = inum;
    80004010:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004014:	4741                	li	a4,16
    80004016:	86a6                	mv	a3,s1
    80004018:	fc040613          	addi	a2,s0,-64
    8000401c:	4581                	li	a1,0
    8000401e:	854a                	mv	a0,s2
    80004020:	c93ff0ef          	jal	80003cb2 <writei>
    80004024:	1541                	addi	a0,a0,-16
    80004026:	00a03533          	snez	a0,a0
    8000402a:	40a00533          	neg	a0,a0
    8000402e:	74a2                	ld	s1,40(sp)
}
    80004030:	70e2                	ld	ra,56(sp)
    80004032:	7442                	ld	s0,48(sp)
    80004034:	7902                	ld	s2,32(sp)
    80004036:	69e2                	ld	s3,24(sp)
    80004038:	6a42                	ld	s4,16(sp)
    8000403a:	6121                	addi	sp,sp,64
    8000403c:	8082                	ret
    iput(ip);
    8000403e:	923ff0ef          	jal	80003960 <iput>
    return -1;
    80004042:	557d                	li	a0,-1
    80004044:	b7f5                	j	80004030 <dirlink+0x78>
      panic("dirlink read");
    80004046:	00004517          	auipc	a0,0x4
    8000404a:	67250513          	addi	a0,a0,1650 # 800086b8 <etext+0x6b8>
    8000404e:	fa2fc0ef          	jal	800007f0 <panic>

0000000080004052 <namei>:

struct inode *
namei(char *path)
{
    80004052:	1101                	addi	sp,sp,-32
    80004054:	ec06                	sd	ra,24(sp)
    80004056:	e822                	sd	s0,16(sp)
    80004058:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000405a:	fe040613          	addi	a2,s0,-32
    8000405e:	4581                	li	a1,0
    80004060:	e19ff0ef          	jal	80003e78 <namex>
}
    80004064:	60e2                	ld	ra,24(sp)
    80004066:	6442                	ld	s0,16(sp)
    80004068:	6105                	addi	sp,sp,32
    8000406a:	8082                	ret

000000008000406c <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    8000406c:	1141                	addi	sp,sp,-16
    8000406e:	e406                	sd	ra,8(sp)
    80004070:	e022                	sd	s0,0(sp)
    80004072:	0800                	addi	s0,sp,16
    80004074:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004076:	4585                	li	a1,1
    80004078:	e01ff0ef          	jal	80003e78 <namex>
}
    8000407c:	60a2                	ld	ra,8(sp)
    8000407e:	6402                	ld	s0,0(sp)
    80004080:	0141                	addi	sp,sp,16
    80004082:	8082                	ret

0000000080004084 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004084:	1101                	addi	sp,sp,-32
    80004086:	ec06                	sd	ra,24(sp)
    80004088:	e822                	sd	s0,16(sp)
    8000408a:	e426                	sd	s1,8(sp)
    8000408c:	e04a                	sd	s2,0(sp)
    8000408e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004090:	00020917          	auipc	s2,0x20
    80004094:	7e090913          	addi	s2,s2,2016 # 80024870 <log>
    80004098:	01892583          	lw	a1,24(s2)
    8000409c:	02492503          	lw	a0,36(s2)
    800040a0:	872ff0ef          	jal	80003112 <bread>
    800040a4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    800040a6:	02c92603          	lw	a2,44(s2)
    800040aa:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040ac:	00c05f63          	blez	a2,800040ca <write_head+0x46>
    800040b0:	00020717          	auipc	a4,0x20
    800040b4:	7f070713          	addi	a4,a4,2032 # 800248a0 <log+0x30>
    800040b8:	87aa                	mv	a5,a0
    800040ba:	060a                	slli	a2,a2,0x2
    800040bc:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040be:	4314                	lw	a3,0(a4)
    800040c0:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040c2:	0711                	addi	a4,a4,4
    800040c4:	0791                	addi	a5,a5,4
    800040c6:	fec79ce3          	bne	a5,a2,800040be <write_head+0x3a>
  }
  bwrite(buf);
    800040ca:	8526                	mv	a0,s1
    800040cc:	91cff0ef          	jal	800031e8 <bwrite>
  brelse(buf);
    800040d0:	8526                	mv	a0,s1
    800040d2:	948ff0ef          	jal	8000321a <brelse>
}
    800040d6:	60e2                	ld	ra,24(sp)
    800040d8:	6442                	ld	s0,16(sp)
    800040da:	64a2                	ld	s1,8(sp)
    800040dc:	6902                	ld	s2,0(sp)
    800040de:	6105                	addi	sp,sp,32
    800040e0:	8082                	ret

00000000800040e2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e2:	00020797          	auipc	a5,0x20
    800040e6:	7ba7a783          	lw	a5,1978(a5) # 8002489c <log+0x2c>
    800040ea:	0af05e63          	blez	a5,800041a6 <install_trans+0xc4>
{
    800040ee:	715d                	addi	sp,sp,-80
    800040f0:	e486                	sd	ra,72(sp)
    800040f2:	e0a2                	sd	s0,64(sp)
    800040f4:	fc26                	sd	s1,56(sp)
    800040f6:	f84a                	sd	s2,48(sp)
    800040f8:	f44e                	sd	s3,40(sp)
    800040fa:	f052                	sd	s4,32(sp)
    800040fc:	ec56                	sd	s5,24(sp)
    800040fe:	e85a                	sd	s6,16(sp)
    80004100:	e45e                	sd	s7,8(sp)
    80004102:	0880                	addi	s0,sp,80
    80004104:	8b2a                	mv	s6,a0
    80004106:	00020a97          	auipc	s5,0x20
    8000410a:	79aa8a93          	addi	s5,s5,1946 # 800248a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000410e:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004110:	00004b97          	auipc	s7,0x4
    80004114:	5b8b8b93          	addi	s7,s7,1464 # 800086c8 <etext+0x6c8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80004118:	00020a17          	auipc	s4,0x20
    8000411c:	758a0a13          	addi	s4,s4,1880 # 80024870 <log>
    80004120:	a025                	j	80004148 <install_trans+0x66>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004122:	000aa603          	lw	a2,0(s5)
    80004126:	85ce                	mv	a1,s3
    80004128:	855e                	mv	a0,s7
    8000412a:	be0fc0ef          	jal	8000050a <printk>
    8000412e:	a839                	j	8000414c <install_trans+0x6a>
    brelse(lbuf);
    80004130:	854a                	mv	a0,s2
    80004132:	8e8ff0ef          	jal	8000321a <brelse>
    brelse(dbuf);
    80004136:	8526                	mv	a0,s1
    80004138:	8e2ff0ef          	jal	8000321a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000413c:	2985                	addiw	s3,s3,1
    8000413e:	0a91                	addi	s5,s5,4
    80004140:	02ca2783          	lw	a5,44(s4)
    80004144:	04f9d663          	bge	s3,a5,80004190 <install_trans+0xae>
    if (recovering) {
    80004148:	fc0b1de3          	bnez	s6,80004122 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    8000414c:	018a2583          	lw	a1,24(s4)
    80004150:	013585bb          	addw	a1,a1,s3
    80004154:	2585                	addiw	a1,a1,1
    80004156:	024a2503          	lw	a0,36(s4)
    8000415a:	fb9fe0ef          	jal	80003112 <bread>
    8000415e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80004160:	000aa583          	lw	a1,0(s5)
    80004164:	024a2503          	lw	a0,36(s4)
    80004168:	fabfe0ef          	jal	80003112 <bread>
    8000416c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    8000416e:	40000613          	li	a2,1024
    80004172:	05890593          	addi	a1,s2,88
    80004176:	05850513          	addi	a0,a0,88
    8000417a:	b37fc0ef          	jal	80000cb0 <memmove>
    bwrite(dbuf);                           // write dst to disk
    8000417e:	8526                	mv	a0,s1
    80004180:	868ff0ef          	jal	800031e8 <bwrite>
    if (recovering == 0)
    80004184:	fa0b16e3          	bnez	s6,80004130 <install_trans+0x4e>
      bunpin(dbuf);
    80004188:	8526                	mv	a0,s1
    8000418a:	94cff0ef          	jal	800032d6 <bunpin>
    8000418e:	b74d                	j	80004130 <install_trans+0x4e>
}
    80004190:	60a6                	ld	ra,72(sp)
    80004192:	6406                	ld	s0,64(sp)
    80004194:	74e2                	ld	s1,56(sp)
    80004196:	7942                	ld	s2,48(sp)
    80004198:	79a2                	ld	s3,40(sp)
    8000419a:	7a02                	ld	s4,32(sp)
    8000419c:	6ae2                	ld	s5,24(sp)
    8000419e:	6b42                	ld	s6,16(sp)
    800041a0:	6ba2                	ld	s7,8(sp)
    800041a2:	6161                	addi	sp,sp,80
    800041a4:	8082                	ret
    800041a6:	8082                	ret

00000000800041a8 <initlog>:
{
    800041a8:	7179                	addi	sp,sp,-48
    800041aa:	f406                	sd	ra,40(sp)
    800041ac:	f022                	sd	s0,32(sp)
    800041ae:	ec26                	sd	s1,24(sp)
    800041b0:	e84a                	sd	s2,16(sp)
    800041b2:	e44e                	sd	s3,8(sp)
    800041b4:	1800                	addi	s0,sp,48
    800041b6:	892a                	mv	s2,a0
    800041b8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041ba:	00020497          	auipc	s1,0x20
    800041be:	6b648493          	addi	s1,s1,1718 # 80024870 <log>
    800041c2:	00004597          	auipc	a1,0x4
    800041c6:	52658593          	addi	a1,a1,1318 # 800086e8 <etext+0x6e8>
    800041ca:	8526                	mv	a0,s1
    800041cc:	94ffc0ef          	jal	80000b1a <initlock>
  log.start = sb->logstart;
    800041d0:	0149a583          	lw	a1,20(s3)
    800041d4:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    800041d6:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041da:	854a                	mv	a0,s2
    800041dc:	f37fe0ef          	jal	80003112 <bread>
  log.lh.n = lh->n;
    800041e0:	4d30                	lw	a2,88(a0)
    800041e2:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041e4:	00c05f63          	blez	a2,80004202 <initlog+0x5a>
    800041e8:	87aa                	mv	a5,a0
    800041ea:	00020717          	auipc	a4,0x20
    800041ee:	6b670713          	addi	a4,a4,1718 # 800248a0 <log+0x30>
    800041f2:	060a                	slli	a2,a2,0x2
    800041f4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800041f6:	4ff4                	lw	a3,92(a5)
    800041f8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041fa:	0791                	addi	a5,a5,4
    800041fc:	0711                	addi	a4,a4,4
    800041fe:	fec79ce3          	bne	a5,a2,800041f6 <initlog+0x4e>
  brelse(buf);
    80004202:	818ff0ef          	jal	8000321a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004206:	4505                	li	a0,1
    80004208:	edbff0ef          	jal	800040e2 <install_trans>
  log.lh.n = 0;
    8000420c:	00020797          	auipc	a5,0x20
    80004210:	6807a823          	sw	zero,1680(a5) # 8002489c <log+0x2c>
  write_head(); // clear the log
    80004214:	e71ff0ef          	jal	80004084 <write_head>
}
    80004218:	70a2                	ld	ra,40(sp)
    8000421a:	7402                	ld	s0,32(sp)
    8000421c:	64e2                	ld	s1,24(sp)
    8000421e:	6942                	ld	s2,16(sp)
    80004220:	69a2                	ld	s3,8(sp)
    80004222:	6145                	addi	sp,sp,48
    80004224:	8082                	ret

0000000080004226 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004226:	1101                	addi	sp,sp,-32
    80004228:	ec06                	sd	ra,24(sp)
    8000422a:	e822                	sd	s0,16(sp)
    8000422c:	e426                	sd	s1,8(sp)
    8000422e:	e04a                	sd	s2,0(sp)
    80004230:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004232:	00020517          	auipc	a0,0x20
    80004236:	63e50513          	addi	a0,a0,1598 # 80024870 <log>
    8000423a:	957fc0ef          	jal	80000b90 <acquire>
  while (1) {
    if (log.committing) {
    8000423e:	00020497          	auipc	s1,0x20
    80004242:	63248493          	addi	s1,s1,1586 # 80024870 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80004246:	4979                	li	s2,30
    80004248:	a821                	j	80004260 <begin_op+0x3a>
      sleep_prepare(&log);
    8000424a:	8526                	mv	a0,s1
    8000424c:	dc1fd0ef          	jal	8000200c <sleep_prepare>
      release(&log.lock);
    80004250:	8526                	mv	a0,s1
    80004252:	9cbfc0ef          	jal	80000c1c <release>
      sleep();
    80004256:	df3fd0ef          	jal	80002048 <sleep>
      acquire(&log.lock);
    8000425a:	8526                	mv	a0,s1
    8000425c:	935fc0ef          	jal	80000b90 <acquire>
    if (log.committing) {
    80004260:	509c                	lw	a5,32(s1)
    80004262:	f7e5                	bnez	a5,8000424a <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80004264:	4cd8                	lw	a4,28(s1)
    80004266:	2705                	addiw	a4,a4,1
    80004268:	0027179b          	slliw	a5,a4,0x2
    8000426c:	9fb9                	addw	a5,a5,a4
    8000426e:	0017979b          	slliw	a5,a5,0x1
    80004272:	54d4                	lw	a3,44(s1)
    80004274:	9fb5                	addw	a5,a5,a3
    80004276:	00f95e63          	bge	s2,a5,80004292 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    8000427a:	8526                	mv	a0,s1
    8000427c:	d91fd0ef          	jal	8000200c <sleep_prepare>
      release(&log.lock);
    80004280:	8526                	mv	a0,s1
    80004282:	99bfc0ef          	jal	80000c1c <release>
      sleep();
    80004286:	dc3fd0ef          	jal	80002048 <sleep>
      acquire(&log.lock);
    8000428a:	8526                	mv	a0,s1
    8000428c:	905fc0ef          	jal	80000b90 <acquire>
    80004290:	bfc1                	j	80004260 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80004292:	00020517          	auipc	a0,0x20
    80004296:	5de50513          	addi	a0,a0,1502 # 80024870 <log>
    8000429a:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    8000429c:	981fc0ef          	jal	80000c1c <release>
      break;
    }
  }
}
    800042a0:	60e2                	ld	ra,24(sp)
    800042a2:	6442                	ld	s0,16(sp)
    800042a4:	64a2                	ld	s1,8(sp)
    800042a6:	6902                	ld	s2,0(sp)
    800042a8:	6105                	addi	sp,sp,32
    800042aa:	8082                	ret

00000000800042ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042ac:	7139                	addi	sp,sp,-64
    800042ae:	fc06                	sd	ra,56(sp)
    800042b0:	f822                	sd	s0,48(sp)
    800042b2:	f426                	sd	s1,40(sp)
    800042b4:	f04a                	sd	s2,32(sp)
    800042b6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042b8:	00020497          	auipc	s1,0x20
    800042bc:	5b848493          	addi	s1,s1,1464 # 80024870 <log>
    800042c0:	8526                	mv	a0,s1
    800042c2:	8cffc0ef          	jal	80000b90 <acquire>
  log.outstanding -= 1;
    800042c6:	4cdc                	lw	a5,28(s1)
    800042c8:	37fd                	addiw	a5,a5,-1
    800042ca:	0007891b          	sext.w	s2,a5
    800042ce:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    800042d0:	509c                	lw	a5,32(s1)
    800042d2:	e3b1                	bnez	a5,80004316 <end_op+0x6a>
    panic("log.committing");
  if (log.outstanding == 0) {
    800042d4:	04091a63          	bnez	s2,80004328 <end_op+0x7c>
    do_commit = 1;
    log.committing = 1;
    800042d8:	00020497          	auipc	s1,0x20
    800042dc:	59848493          	addi	s1,s1,1432 # 80024870 <log>
    800042e0:	4785                	li	a5,1
    800042e2:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042e4:	8526                	mv	a0,s1
    800042e6:	937fc0ef          	jal	80000c1c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042ea:	54dc                	lw	a5,44(s1)
    800042ec:	04f04e63          	bgtz	a5,80004348 <end_op+0x9c>
    acquire(&log.lock);
    800042f0:	00020497          	auipc	s1,0x20
    800042f4:	58048493          	addi	s1,s1,1408 # 80024870 <log>
    800042f8:	8526                	mv	a0,s1
    800042fa:	897fc0ef          	jal	80000b90 <acquire>
    log.committing = 0;
    800042fe:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80004302:	549c                	lw	a5,40(s1)
    80004304:	2785                	addiw	a5,a5,1
    80004306:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80004308:	8526                	mv	a0,s1
    8000430a:	d7bfd0ef          	jal	80002084 <wakeup>
    release(&log.lock);
    8000430e:	8526                	mv	a0,s1
    80004310:	90dfc0ef          	jal	80000c1c <release>
}
    80004314:	a025                	j	8000433c <end_op+0x90>
    80004316:	ec4e                	sd	s3,24(sp)
    80004318:	e852                	sd	s4,16(sp)
    8000431a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000431c:	00004517          	auipc	a0,0x4
    80004320:	3d450513          	addi	a0,a0,980 # 800086f0 <etext+0x6f0>
    80004324:	cccfc0ef          	jal	800007f0 <panic>
    wakeup(&log);
    80004328:	00020497          	auipc	s1,0x20
    8000432c:	54848493          	addi	s1,s1,1352 # 80024870 <log>
    80004330:	8526                	mv	a0,s1
    80004332:	d53fd0ef          	jal	80002084 <wakeup>
  release(&log.lock);
    80004336:	8526                	mv	a0,s1
    80004338:	8e5fc0ef          	jal	80000c1c <release>
}
    8000433c:	70e2                	ld	ra,56(sp)
    8000433e:	7442                	ld	s0,48(sp)
    80004340:	74a2                	ld	s1,40(sp)
    80004342:	7902                	ld	s2,32(sp)
    80004344:	6121                	addi	sp,sp,64
    80004346:	8082                	ret
    80004348:	ec4e                	sd	s3,24(sp)
    8000434a:	e852                	sd	s4,16(sp)
    8000434c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000434e:	00020a97          	auipc	s5,0x20
    80004352:	552a8a93          	addi	s5,s5,1362 # 800248a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80004356:	00020a17          	auipc	s4,0x20
    8000435a:	51aa0a13          	addi	s4,s4,1306 # 80024870 <log>
    8000435e:	018a2583          	lw	a1,24(s4)
    80004362:	012585bb          	addw	a1,a1,s2
    80004366:	2585                	addiw	a1,a1,1
    80004368:	024a2503          	lw	a0,36(s4)
    8000436c:	da7fe0ef          	jal	80003112 <bread>
    80004370:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004372:	000aa583          	lw	a1,0(s5)
    80004376:	024a2503          	lw	a0,36(s4)
    8000437a:	d99fe0ef          	jal	80003112 <bread>
    8000437e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004380:	40000613          	li	a2,1024
    80004384:	05850593          	addi	a1,a0,88
    80004388:	05848513          	addi	a0,s1,88
    8000438c:	925fc0ef          	jal	80000cb0 <memmove>
    bwrite(to); // write the log
    80004390:	8526                	mv	a0,s1
    80004392:	e57fe0ef          	jal	800031e8 <bwrite>
    brelse(from);
    80004396:	854e                	mv	a0,s3
    80004398:	e83fe0ef          	jal	8000321a <brelse>
    brelse(to);
    8000439c:	8526                	mv	a0,s1
    8000439e:	e7dfe0ef          	jal	8000321a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043a2:	2905                	addiw	s2,s2,1
    800043a4:	0a91                	addi	s5,s5,4
    800043a6:	02ca2783          	lw	a5,44(s4)
    800043aa:	faf94ae3          	blt	s2,a5,8000435e <end_op+0xb2>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    800043ae:	cd7ff0ef          	jal	80004084 <write_head>
    install_trans(0); // Now install writes to home locations
    800043b2:	4501                	li	a0,0
    800043b4:	d2fff0ef          	jal	800040e2 <install_trans>
    log.lh.n = 0;
    800043b8:	00020797          	auipc	a5,0x20
    800043bc:	4e07a223          	sw	zero,1252(a5) # 8002489c <log+0x2c>
    write_head(); // Erase the transaction from the log
    800043c0:	cc5ff0ef          	jal	80004084 <write_head>
    800043c4:	69e2                	ld	s3,24(sp)
    800043c6:	6a42                	ld	s4,16(sp)
    800043c8:	6aa2                	ld	s5,8(sp)
    800043ca:	b71d                	j	800042f0 <end_op+0x44>

00000000800043cc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043cc:	1101                	addi	sp,sp,-32
    800043ce:	ec06                	sd	ra,24(sp)
    800043d0:	e822                	sd	s0,16(sp)
    800043d2:	e426                	sd	s1,8(sp)
    800043d4:	e04a                	sd	s2,0(sp)
    800043d6:	1000                	addi	s0,sp,32
    800043d8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800043da:	00020917          	auipc	s2,0x20
    800043de:	49690913          	addi	s2,s2,1174 # 80024870 <log>
    800043e2:	854a                	mv	a0,s2
    800043e4:	facfc0ef          	jal	80000b90 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800043e8:	02c92603          	lw	a2,44(s2)
    800043ec:	47f5                	li	a5,29
    800043ee:	04c7cc63          	blt	a5,a2,80004446 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043f2:	00020797          	auipc	a5,0x20
    800043f6:	49a7a783          	lw	a5,1178(a5) # 8002488c <log+0x1c>
    800043fa:	04f05c63          	blez	a5,80004452 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043fe:	4781                	li	a5,0
    80004400:	04c05f63          	blez	a2,8000445e <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    80004404:	44cc                	lw	a1,12(s1)
    80004406:	00020717          	auipc	a4,0x20
    8000440a:	49a70713          	addi	a4,a4,1178 # 800248a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000440e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80004410:	4314                	lw	a3,0(a4)
    80004412:	04b68663          	beq	a3,a1,8000445e <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004416:	2785                	addiw	a5,a5,1
    80004418:	0711                	addi	a4,a4,4
    8000441a:	fef61be3          	bne	a2,a5,80004410 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000441e:	0621                	addi	a2,a2,8
    80004420:	060a                	slli	a2,a2,0x2
    80004422:	00020797          	auipc	a5,0x20
    80004426:	44e78793          	addi	a5,a5,1102 # 80024870 <log>
    8000442a:	97b2                	add	a5,a5,a2
    8000442c:	44d8                	lw	a4,12(s1)
    8000442e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004430:	8526                	mv	a0,s1
    80004432:	e71fe0ef          	jal	800032a2 <bpin>
    log.lh.n++;
    80004436:	00020717          	auipc	a4,0x20
    8000443a:	43a70713          	addi	a4,a4,1082 # 80024870 <log>
    8000443e:	575c                	lw	a5,44(a4)
    80004440:	2785                	addiw	a5,a5,1
    80004442:	d75c                	sw	a5,44(a4)
    80004444:	a80d                	j	80004476 <log_write+0xaa>
    panic("too big a transaction");
    80004446:	00004517          	auipc	a0,0x4
    8000444a:	2ba50513          	addi	a0,a0,698 # 80008700 <etext+0x700>
    8000444e:	ba2fc0ef          	jal	800007f0 <panic>
    panic("log_write outside of trans");
    80004452:	00004517          	auipc	a0,0x4
    80004456:	2c650513          	addi	a0,a0,710 # 80008718 <etext+0x718>
    8000445a:	b96fc0ef          	jal	800007f0 <panic>
  log.lh.block[i] = b->blockno;
    8000445e:	00878693          	addi	a3,a5,8
    80004462:	068a                	slli	a3,a3,0x2
    80004464:	00020717          	auipc	a4,0x20
    80004468:	40c70713          	addi	a4,a4,1036 # 80024870 <log>
    8000446c:	9736                	add	a4,a4,a3
    8000446e:	44d4                	lw	a3,12(s1)
    80004470:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80004472:	faf60fe3          	beq	a2,a5,80004430 <log_write+0x64>
  }
  release(&log.lock);
    80004476:	00020517          	auipc	a0,0x20
    8000447a:	3fa50513          	addi	a0,a0,1018 # 80024870 <log>
    8000447e:	f9efc0ef          	jal	80000c1c <release>
}
    80004482:	60e2                	ld	ra,24(sp)
    80004484:	6442                	ld	s0,16(sp)
    80004486:	64a2                	ld	s1,8(sp)
    80004488:	6902                	ld	s2,0(sp)
    8000448a:	6105                	addi	sp,sp,32
    8000448c:	8082                	ret

000000008000448e <sys_sync>:

uint64
sys_sync(void)
{
    8000448e:	1101                	addi	sp,sp,-32
    80004490:	ec06                	sd	ra,24(sp)
    80004492:	e822                	sd	s0,16(sp)
    80004494:	e426                	sd	s1,8(sp)
    80004496:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004498:	00020497          	auipc	s1,0x20
    8000449c:	3d848493          	addi	s1,s1,984 # 80024870 <log>
    800044a0:	8526                	mv	a0,s1
    800044a2:	eeefc0ef          	jal	80000b90 <acquire>
  if (log.committing || log.outstanding > 0) {
    800044a6:	509c                	lw	a5,32(s1)
    800044a8:	e799                	bnez	a5,800044b6 <sys_sync+0x28>
    800044aa:	00020797          	auipc	a5,0x20
    800044ae:	3e27a783          	lw	a5,994(a5) # 8002488c <log+0x1c>
    800044b2:	02f05a63          	blez	a5,800044e6 <sys_sync+0x58>
    800044b6:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    800044b8:	00020917          	auipc	s2,0x20
    800044bc:	3e092903          	lw	s2,992(s2) # 80024898 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    800044c0:	00020497          	auipc	s1,0x20
    800044c4:	3b048493          	addi	s1,s1,944 # 80024870 <log>
    800044c8:	8526                	mv	a0,s1
    800044ca:	b43fd0ef          	jal	8000200c <sleep_prepare>
      release(&log.lock);
    800044ce:	8526                	mv	a0,s1
    800044d0:	f4cfc0ef          	jal	80000c1c <release>
      sleep();
    800044d4:	b75fd0ef          	jal	80002048 <sleep>
      acquire(&log.lock);
    800044d8:	8526                	mv	a0,s1
    800044da:	eb6fc0ef          	jal	80000b90 <acquire>
    while (log.ncommit < n) {
    800044de:	549c                	lw	a5,40(s1)
    800044e0:	fef954e3          	bge	s2,a5,800044c8 <sys_sync+0x3a>
    800044e4:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    800044e6:	00020517          	auipc	a0,0x20
    800044ea:	38a50513          	addi	a0,a0,906 # 80024870 <log>
    800044ee:	f2efc0ef          	jal	80000c1c <release>
  return 0;
}
    800044f2:	4501                	li	a0,0
    800044f4:	60e2                	ld	ra,24(sp)
    800044f6:	6442                	ld	s0,16(sp)
    800044f8:	64a2                	ld	s1,8(sp)
    800044fa:	6105                	addi	sp,sp,32
    800044fc:	8082                	ret

00000000800044fe <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044fe:	1101                	addi	sp,sp,-32
    80004500:	ec06                	sd	ra,24(sp)
    80004502:	e822                	sd	s0,16(sp)
    80004504:	e426                	sd	s1,8(sp)
    80004506:	e04a                	sd	s2,0(sp)
    80004508:	1000                	addi	s0,sp,32
    8000450a:	84aa                	mv	s1,a0
    8000450c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000450e:	00004597          	auipc	a1,0x4
    80004512:	22a58593          	addi	a1,a1,554 # 80008738 <etext+0x738>
    80004516:	0521                	addi	a0,a0,8
    80004518:	e02fc0ef          	jal	80000b1a <initlock>
  lk->name = name;
    8000451c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004520:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004524:	0204a423          	sw	zero,40(s1)
}
    80004528:	60e2                	ld	ra,24(sp)
    8000452a:	6442                	ld	s0,16(sp)
    8000452c:	64a2                	ld	s1,8(sp)
    8000452e:	6902                	ld	s2,0(sp)
    80004530:	6105                	addi	sp,sp,32
    80004532:	8082                	ret

0000000080004534 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004534:	1101                	addi	sp,sp,-32
    80004536:	ec06                	sd	ra,24(sp)
    80004538:	e822                	sd	s0,16(sp)
    8000453a:	e426                	sd	s1,8(sp)
    8000453c:	e04a                	sd	s2,0(sp)
    8000453e:	1000                	addi	s0,sp,32
    80004540:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004542:	00850913          	addi	s2,a0,8
    80004546:	854a                	mv	a0,s2
    80004548:	e48fc0ef          	jal	80000b90 <acquire>
  while (lk->locked) {
    8000454c:	409c                	lw	a5,0(s1)
    8000454e:	cf91                	beqz	a5,8000456a <acquiresleep+0x36>
    sleep_prepare(lk);
    80004550:	8526                	mv	a0,s1
    80004552:	abbfd0ef          	jal	8000200c <sleep_prepare>
    release(&lk->lk);
    80004556:	854a                	mv	a0,s2
    80004558:	ec4fc0ef          	jal	80000c1c <release>
    sleep();
    8000455c:	aedfd0ef          	jal	80002048 <sleep>
    acquire(&lk->lk);
    80004560:	854a                	mv	a0,s2
    80004562:	e2efc0ef          	jal	80000b90 <acquire>
  while (lk->locked) {
    80004566:	409c                	lw	a5,0(s1)
    80004568:	f7e5                	bnez	a5,80004550 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000456a:	4785                	li	a5,1
    8000456c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000456e:	b34fd0ef          	jal	800018a2 <myproc>
    80004572:	591c                	lw	a5,48(a0)
    80004574:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004576:	854a                	mv	a0,s2
    80004578:	ea4fc0ef          	jal	80000c1c <release>
}
    8000457c:	60e2                	ld	ra,24(sp)
    8000457e:	6442                	ld	s0,16(sp)
    80004580:	64a2                	ld	s1,8(sp)
    80004582:	6902                	ld	s2,0(sp)
    80004584:	6105                	addi	sp,sp,32
    80004586:	8082                	ret

0000000080004588 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004588:	1101                	addi	sp,sp,-32
    8000458a:	ec06                	sd	ra,24(sp)
    8000458c:	e822                	sd	s0,16(sp)
    8000458e:	e426                	sd	s1,8(sp)
    80004590:	e04a                	sd	s2,0(sp)
    80004592:	1000                	addi	s0,sp,32
    80004594:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004596:	00850913          	addi	s2,a0,8
    8000459a:	854a                	mv	a0,s2
    8000459c:	df4fc0ef          	jal	80000b90 <acquire>
  lk->locked = 0;
    800045a0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045a4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045a8:	8526                	mv	a0,s1
    800045aa:	adbfd0ef          	jal	80002084 <wakeup>
  release(&lk->lk);
    800045ae:	854a                	mv	a0,s2
    800045b0:	e6cfc0ef          	jal	80000c1c <release>
}
    800045b4:	60e2                	ld	ra,24(sp)
    800045b6:	6442                	ld	s0,16(sp)
    800045b8:	64a2                	ld	s1,8(sp)
    800045ba:	6902                	ld	s2,0(sp)
    800045bc:	6105                	addi	sp,sp,32
    800045be:	8082                	ret

00000000800045c0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045c0:	7179                	addi	sp,sp,-48
    800045c2:	f406                	sd	ra,40(sp)
    800045c4:	f022                	sd	s0,32(sp)
    800045c6:	ec26                	sd	s1,24(sp)
    800045c8:	e84a                	sd	s2,16(sp)
    800045ca:	1800                	addi	s0,sp,48
    800045cc:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800045ce:	00850913          	addi	s2,a0,8
    800045d2:	854a                	mv	a0,s2
    800045d4:	dbcfc0ef          	jal	80000b90 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045d8:	409c                	lw	a5,0(s1)
    800045da:	ef81                	bnez	a5,800045f2 <holdingsleep+0x32>
    800045dc:	4481                	li	s1,0
  release(&lk->lk);
    800045de:	854a                	mv	a0,s2
    800045e0:	e3cfc0ef          	jal	80000c1c <release>
  return r;
}
    800045e4:	8526                	mv	a0,s1
    800045e6:	70a2                	ld	ra,40(sp)
    800045e8:	7402                	ld	s0,32(sp)
    800045ea:	64e2                	ld	s1,24(sp)
    800045ec:	6942                	ld	s2,16(sp)
    800045ee:	6145                	addi	sp,sp,48
    800045f0:	8082                	ret
    800045f2:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800045f4:	0284a983          	lw	s3,40(s1)
    800045f8:	aaafd0ef          	jal	800018a2 <myproc>
    800045fc:	5904                	lw	s1,48(a0)
    800045fe:	413484b3          	sub	s1,s1,s3
    80004602:	0014b493          	seqz	s1,s1
    80004606:	69a2                	ld	s3,8(sp)
    80004608:	bfd9                	j	800045de <holdingsleep+0x1e>

000000008000460a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000460a:	1141                	addi	sp,sp,-16
    8000460c:	e406                	sd	ra,8(sp)
    8000460e:	e022                	sd	s0,0(sp)
    80004610:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004612:	00004597          	auipc	a1,0x4
    80004616:	13658593          	addi	a1,a1,310 # 80008748 <etext+0x748>
    8000461a:	00020517          	auipc	a0,0x20
    8000461e:	39e50513          	addi	a0,a0,926 # 800249b8 <ftable>
    80004622:	cf8fc0ef          	jal	80000b1a <initlock>
}
    80004626:	60a2                	ld	ra,8(sp)
    80004628:	6402                	ld	s0,0(sp)
    8000462a:	0141                	addi	sp,sp,16
    8000462c:	8082                	ret

000000008000462e <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000462e:	1101                	addi	sp,sp,-32
    80004630:	ec06                	sd	ra,24(sp)
    80004632:	e822                	sd	s0,16(sp)
    80004634:	e426                	sd	s1,8(sp)
    80004636:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004638:	00020517          	auipc	a0,0x20
    8000463c:	38050513          	addi	a0,a0,896 # 800249b8 <ftable>
    80004640:	d50fc0ef          	jal	80000b90 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004644:	00020497          	auipc	s1,0x20
    80004648:	38c48493          	addi	s1,s1,908 # 800249d0 <ftable+0x18>
    8000464c:	00021717          	auipc	a4,0x21
    80004650:	32470713          	addi	a4,a4,804 # 80025970 <disk>
    if (f->ref == 0) {
    80004654:	40dc                	lw	a5,4(s1)
    80004656:	cf89                	beqz	a5,80004670 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004658:	02848493          	addi	s1,s1,40
    8000465c:	fee49ce3          	bne	s1,a4,80004654 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004660:	00020517          	auipc	a0,0x20
    80004664:	35850513          	addi	a0,a0,856 # 800249b8 <ftable>
    80004668:	db4fc0ef          	jal	80000c1c <release>
  return 0;
    8000466c:	4481                	li	s1,0
    8000466e:	a809                	j	80004680 <filealloc+0x52>
      f->ref = 1;
    80004670:	4785                	li	a5,1
    80004672:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004674:	00020517          	auipc	a0,0x20
    80004678:	34450513          	addi	a0,a0,836 # 800249b8 <ftable>
    8000467c:	da0fc0ef          	jal	80000c1c <release>
}
    80004680:	8526                	mv	a0,s1
    80004682:	60e2                	ld	ra,24(sp)
    80004684:	6442                	ld	s0,16(sp)
    80004686:	64a2                	ld	s1,8(sp)
    80004688:	6105                	addi	sp,sp,32
    8000468a:	8082                	ret

000000008000468c <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000468c:	1101                	addi	sp,sp,-32
    8000468e:	ec06                	sd	ra,24(sp)
    80004690:	e822                	sd	s0,16(sp)
    80004692:	e426                	sd	s1,8(sp)
    80004694:	1000                	addi	s0,sp,32
    80004696:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004698:	00020517          	auipc	a0,0x20
    8000469c:	32050513          	addi	a0,a0,800 # 800249b8 <ftable>
    800046a0:	cf0fc0ef          	jal	80000b90 <acquire>
  if (f->ref < 1)
    800046a4:	40dc                	lw	a5,4(s1)
    800046a6:	02f05063          	blez	a5,800046c6 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800046aa:	2785                	addiw	a5,a5,1
    800046ac:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046ae:	00020517          	auipc	a0,0x20
    800046b2:	30a50513          	addi	a0,a0,778 # 800249b8 <ftable>
    800046b6:	d66fc0ef          	jal	80000c1c <release>
  return f;
}
    800046ba:	8526                	mv	a0,s1
    800046bc:	60e2                	ld	ra,24(sp)
    800046be:	6442                	ld	s0,16(sp)
    800046c0:	64a2                	ld	s1,8(sp)
    800046c2:	6105                	addi	sp,sp,32
    800046c4:	8082                	ret
    panic("filedup");
    800046c6:	00004517          	auipc	a0,0x4
    800046ca:	08a50513          	addi	a0,a0,138 # 80008750 <etext+0x750>
    800046ce:	922fc0ef          	jal	800007f0 <panic>

00000000800046d2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046d2:	7139                	addi	sp,sp,-64
    800046d4:	fc06                	sd	ra,56(sp)
    800046d6:	f822                	sd	s0,48(sp)
    800046d8:	f426                	sd	s1,40(sp)
    800046da:	0080                	addi	s0,sp,64
    800046dc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046de:	00020517          	auipc	a0,0x20
    800046e2:	2da50513          	addi	a0,a0,730 # 800249b8 <ftable>
    800046e6:	caafc0ef          	jal	80000b90 <acquire>
  if (f->ref < 1)
    800046ea:	40dc                	lw	a5,4(s1)
    800046ec:	04f05a63          	blez	a5,80004740 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800046f0:	37fd                	addiw	a5,a5,-1
    800046f2:	0007871b          	sext.w	a4,a5
    800046f6:	c0dc                	sw	a5,4(s1)
    800046f8:	04e04e63          	bgtz	a4,80004754 <fileclose+0x82>
    800046fc:	f04a                	sd	s2,32(sp)
    800046fe:	ec4e                	sd	s3,24(sp)
    80004700:	e852                	sd	s4,16(sp)
    80004702:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004704:	0004a903          	lw	s2,0(s1)
    80004708:	0094ca83          	lbu	s5,9(s1)
    8000470c:	0104ba03          	ld	s4,16(s1)
    80004710:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004714:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004718:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000471c:	00020517          	auipc	a0,0x20
    80004720:	29c50513          	addi	a0,a0,668 # 800249b8 <ftable>
    80004724:	cf8fc0ef          	jal	80000c1c <release>

  if (ff.type == FD_PIPE) {
    80004728:	4785                	li	a5,1
    8000472a:	04f90063          	beq	s2,a5,8000476a <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000472e:	3979                	addiw	s2,s2,-2
    80004730:	4785                	li	a5,1
    80004732:	0527f563          	bgeu	a5,s2,8000477c <fileclose+0xaa>
    80004736:	7902                	ld	s2,32(sp)
    80004738:	69e2                	ld	s3,24(sp)
    8000473a:	6a42                	ld	s4,16(sp)
    8000473c:	6aa2                	ld	s5,8(sp)
    8000473e:	a00d                	j	80004760 <fileclose+0x8e>
    80004740:	f04a                	sd	s2,32(sp)
    80004742:	ec4e                	sd	s3,24(sp)
    80004744:	e852                	sd	s4,16(sp)
    80004746:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004748:	00004517          	auipc	a0,0x4
    8000474c:	01050513          	addi	a0,a0,16 # 80008758 <etext+0x758>
    80004750:	8a0fc0ef          	jal	800007f0 <panic>
    release(&ftable.lock);
    80004754:	00020517          	auipc	a0,0x20
    80004758:	26450513          	addi	a0,a0,612 # 800249b8 <ftable>
    8000475c:	cc0fc0ef          	jal	80000c1c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004760:	70e2                	ld	ra,56(sp)
    80004762:	7442                	ld	s0,48(sp)
    80004764:	74a2                	ld	s1,40(sp)
    80004766:	6121                	addi	sp,sp,64
    80004768:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000476a:	85d6                	mv	a1,s5
    8000476c:	8552                	mv	a0,s4
    8000476e:	34c000ef          	jal	80004aba <pipeclose>
    80004772:	7902                	ld	s2,32(sp)
    80004774:	69e2                	ld	s3,24(sp)
    80004776:	6a42                	ld	s4,16(sp)
    80004778:	6aa2                	ld	s5,8(sp)
    8000477a:	b7dd                	j	80004760 <fileclose+0x8e>
    begin_op();
    8000477c:	aabff0ef          	jal	80004226 <begin_op>
    iput(ff.ip);
    80004780:	854e                	mv	a0,s3
    80004782:	9deff0ef          	jal	80003960 <iput>
    end_op();
    80004786:	b27ff0ef          	jal	800042ac <end_op>
    8000478a:	7902                	ld	s2,32(sp)
    8000478c:	69e2                	ld	s3,24(sp)
    8000478e:	6a42                	ld	s4,16(sp)
    80004790:	6aa2                	ld	s5,8(sp)
    80004792:	b7f9                	j	80004760 <fileclose+0x8e>

0000000080004794 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004794:	715d                	addi	sp,sp,-80
    80004796:	e486                	sd	ra,72(sp)
    80004798:	e0a2                	sd	s0,64(sp)
    8000479a:	fc26                	sd	s1,56(sp)
    8000479c:	f44e                	sd	s3,40(sp)
    8000479e:	0880                	addi	s0,sp,80
    800047a0:	84aa                	mv	s1,a0
    800047a2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047a4:	8fefd0ef          	jal	800018a2 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800047a8:	409c                	lw	a5,0(s1)
    800047aa:	37f9                	addiw	a5,a5,-2
    800047ac:	4705                	li	a4,1
    800047ae:	04f76263          	bltu	a4,a5,800047f2 <filestat+0x5e>
    800047b2:	f84a                	sd	s2,48(sp)
    800047b4:	892a                	mv	s2,a0
    ilock(f->ip);
    800047b6:	6c88                	ld	a0,24(s1)
    800047b8:	826ff0ef          	jal	800037de <ilock>
    stati(f->ip, &st);
    800047bc:	fb840593          	addi	a1,s0,-72
    800047c0:	6c88                	ld	a0,24(s1)
    800047c2:	bcaff0ef          	jal	80003b8c <stati>
    iunlock(f->ip);
    800047c6:	6c88                	ld	a0,24(s1)
    800047c8:	8c4ff0ef          	jal	8000388c <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800047cc:	4761                	li	a4,24
    800047ce:	fb840693          	addi	a3,s0,-72
    800047d2:	864e                	mv	a2,s3
    800047d4:	04893583          	ld	a1,72(s2)
    800047d8:	05093503          	ld	a0,80(s2)
    800047dc:	cfdfc0ef          	jal	800014d8 <copyout>
    800047e0:	41f5551b          	sraiw	a0,a0,0x1f
    800047e4:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800047e6:	60a6                	ld	ra,72(sp)
    800047e8:	6406                	ld	s0,64(sp)
    800047ea:	74e2                	ld	s1,56(sp)
    800047ec:	79a2                	ld	s3,40(sp)
    800047ee:	6161                	addi	sp,sp,80
    800047f0:	8082                	ret
  return -1;
    800047f2:	557d                	li	a0,-1
    800047f4:	bfcd                	j	800047e6 <filestat+0x52>

00000000800047f6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047f6:	7179                	addi	sp,sp,-48
    800047f8:	f406                	sd	ra,40(sp)
    800047fa:	f022                	sd	s0,32(sp)
    800047fc:	e84a                	sd	s2,16(sp)
    800047fe:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    80004800:	00854783          	lbu	a5,8(a0)
    80004804:	c3c5                	beqz	a5,800048a4 <fileread+0xae>
    80004806:	ec26                	sd	s1,24(sp)
    80004808:	e44e                	sd	s3,8(sp)
    8000480a:	84aa                	mv	s1,a0
    8000480c:	89ae                	mv	s3,a1
    8000480e:	8932                	mv	s2,a2
    80004810:	08064c63          	bltz	a2,800048a8 <fileread+0xb2>
    return -1;

  if (f->type == FD_PIPE) {
    80004814:	411c                	lw	a5,0(a0)
    80004816:	4705                	li	a4,1
    80004818:	04e78363          	beq	a5,a4,8000485e <fileread+0x68>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000481c:	470d                	li	a4,3
    8000481e:	04e78763          	beq	a5,a4,8000486c <fileread+0x76>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004822:	4709                	li	a4,2
    80004824:	06e79a63          	bne	a5,a4,80004898 <fileread+0xa2>
    ilock(f->ip);
    80004828:	6d08                	ld	a0,24(a0)
    8000482a:	fb5fe0ef          	jal	800037de <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000482e:	874a                	mv	a4,s2
    80004830:	5094                	lw	a3,32(s1)
    80004832:	864e                	mv	a2,s3
    80004834:	4585                	li	a1,1
    80004836:	6c88                	ld	a0,24(s1)
    80004838:	b7eff0ef          	jal	80003bb6 <readi>
    8000483c:	892a                	mv	s2,a0
    8000483e:	00a05563          	blez	a0,80004848 <fileread+0x52>
      f->off += r;
    80004842:	509c                	lw	a5,32(s1)
    80004844:	9fa9                	addw	a5,a5,a0
    80004846:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004848:	6c88                	ld	a0,24(s1)
    8000484a:	842ff0ef          	jal	8000388c <iunlock>
    8000484e:	64e2                	ld	s1,24(sp)
    80004850:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004852:	854a                	mv	a0,s2
    80004854:	70a2                	ld	ra,40(sp)
    80004856:	7402                	ld	s0,32(sp)
    80004858:	6942                	ld	s2,16(sp)
    8000485a:	6145                	addi	sp,sp,48
    8000485c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000485e:	6908                	ld	a0,16(a0)
    80004860:	3b6000ef          	jal	80004c16 <piperead>
    80004864:	892a                	mv	s2,a0
    80004866:	64e2                	ld	s1,24(sp)
    80004868:	69a2                	ld	s3,8(sp)
    8000486a:	b7e5                	j	80004852 <fileread+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000486c:	02451783          	lh	a5,36(a0)
    80004870:	03079693          	slli	a3,a5,0x30
    80004874:	92c1                	srli	a3,a3,0x30
    80004876:	4725                	li	a4,9
    80004878:	02d76c63          	bltu	a4,a3,800048b0 <fileread+0xba>
    8000487c:	0792                	slli	a5,a5,0x4
    8000487e:	00020717          	auipc	a4,0x20
    80004882:	09a70713          	addi	a4,a4,154 # 80024918 <devsw>
    80004886:	97ba                	add	a5,a5,a4
    80004888:	639c                	ld	a5,0(a5)
    8000488a:	c79d                	beqz	a5,800048b8 <fileread+0xc2>
    r = devsw[f->major].read(1, addr, n);
    8000488c:	4505                	li	a0,1
    8000488e:	9782                	jalr	a5
    80004890:	892a                	mv	s2,a0
    80004892:	64e2                	ld	s1,24(sp)
    80004894:	69a2                	ld	s3,8(sp)
    80004896:	bf75                	j	80004852 <fileread+0x5c>
    panic("fileread");
    80004898:	00004517          	auipc	a0,0x4
    8000489c:	ed050513          	addi	a0,a0,-304 # 80008768 <etext+0x768>
    800048a0:	f51fb0ef          	jal	800007f0 <panic>
    return -1;
    800048a4:	597d                	li	s2,-1
    800048a6:	b775                	j	80004852 <fileread+0x5c>
    800048a8:	597d                	li	s2,-1
    800048aa:	64e2                	ld	s1,24(sp)
    800048ac:	69a2                	ld	s3,8(sp)
    800048ae:	b755                	j	80004852 <fileread+0x5c>
      return -1;
    800048b0:	597d                	li	s2,-1
    800048b2:	64e2                	ld	s1,24(sp)
    800048b4:	69a2                	ld	s3,8(sp)
    800048b6:	bf71                	j	80004852 <fileread+0x5c>
    800048b8:	597d                	li	s2,-1
    800048ba:	64e2                	ld	s1,24(sp)
    800048bc:	69a2                	ld	s3,8(sp)
    800048be:	bf51                	j	80004852 <fileread+0x5c>

00000000800048c0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800048c0:	00954783          	lbu	a5,9(a0)
    800048c4:	10078663          	beqz	a5,800049d0 <filewrite+0x110>
{
    800048c8:	715d                	addi	sp,sp,-80
    800048ca:	e486                	sd	ra,72(sp)
    800048cc:	e0a2                	sd	s0,64(sp)
    800048ce:	f84a                	sd	s2,48(sp)
    800048d0:	f052                	sd	s4,32(sp)
    800048d2:	e85a                	sd	s6,16(sp)
    800048d4:	0880                	addi	s0,sp,80
    800048d6:	892a                	mv	s2,a0
    800048d8:	8b2e                	mv	s6,a1
    800048da:	8a32                	mv	s4,a2
  if (f->writable == 0 || n < 0)
    800048dc:	0e064c63          	bltz	a2,800049d4 <filewrite+0x114>
    return -1;

  if (f->type == FD_PIPE) {
    800048e0:	411c                	lw	a5,0(a0)
    800048e2:	4705                	li	a4,1
    800048e4:	02e78763          	beq	a5,a4,80004912 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800048e8:	470d                	li	a4,3
    800048ea:	02e78863          	beq	a5,a4,8000491a <filewrite+0x5a>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800048ee:	4709                	li	a4,2
    800048f0:	0ce79563          	bne	a5,a4,800049ba <filewrite+0xfa>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800048f4:	0ec05663          	blez	a2,800049e0 <filewrite+0x120>
    800048f8:	fc26                	sd	s1,56(sp)
    800048fa:	f44e                	sd	s3,40(sp)
    800048fc:	ec56                	sd	s5,24(sp)
    800048fe:	e45e                	sd	s7,8(sp)
    80004900:	e062                	sd	s8,0(sp)
    int i = 0;
    80004902:	4981                	li	s3,0
      int n1 = n - i;
      if (n1 > max)
    80004904:	6b85                	lui	s7,0x1
    80004906:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000490a:	6c05                	lui	s8,0x1
    8000490c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004910:	a8b5                	j	8000498c <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004912:	6908                	ld	a0,16(a0)
    80004914:	1fe000ef          	jal	80004b12 <pipewrite>
    80004918:	a851                	j	800049ac <filewrite+0xec>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000491a:	02451783          	lh	a5,36(a0)
    8000491e:	03079693          	slli	a3,a5,0x30
    80004922:	92c1                	srli	a3,a3,0x30
    80004924:	4725                	li	a4,9
    80004926:	0ad76963          	bltu	a4,a3,800049d8 <filewrite+0x118>
    8000492a:	0792                	slli	a5,a5,0x4
    8000492c:	00020717          	auipc	a4,0x20
    80004930:	fec70713          	addi	a4,a4,-20 # 80024918 <devsw>
    80004934:	97ba                	add	a5,a5,a4
    80004936:	679c                	ld	a5,8(a5)
    80004938:	c3d5                	beqz	a5,800049dc <filewrite+0x11c>
    ret = devsw[f->major].write(1, addr, n);
    8000493a:	4505                	li	a0,1
    8000493c:	9782                	jalr	a5
    8000493e:	a0bd                	j	800049ac <filewrite+0xec>
      if (n1 > max)
    80004940:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004944:	8e3ff0ef          	jal	80004226 <begin_op>
      ilock(f->ip);
    80004948:	01893503          	ld	a0,24(s2)
    8000494c:	e93fe0ef          	jal	800037de <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004950:	8756                	mv	a4,s5
    80004952:	02092683          	lw	a3,32(s2)
    80004956:	01698633          	add	a2,s3,s6
    8000495a:	4585                	li	a1,1
    8000495c:	01893503          	ld	a0,24(s2)
    80004960:	b52ff0ef          	jal	80003cb2 <writei>
    80004964:	84aa                	mv	s1,a0
    80004966:	00a05763          	blez	a0,80004974 <filewrite+0xb4>
        f->off += r;
    8000496a:	02092783          	lw	a5,32(s2)
    8000496e:	9fa9                	addw	a5,a5,a0
    80004970:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004974:	01893503          	ld	a0,24(s2)
    80004978:	f15fe0ef          	jal	8000388c <iunlock>
      end_op();
    8000497c:	931ff0ef          	jal	800042ac <end_op>

      if (r != n1) {
    80004980:	009a9e63          	bne	s5,s1,8000499c <filewrite+0xdc>
        // error from writei
        break;
      }
      i += r;
    80004984:	013489bb          	addw	s3,s1,s3
    while (i < n) {
    80004988:	0149da63          	bge	s3,s4,8000499c <filewrite+0xdc>
      int n1 = n - i;
    8000498c:	413a04bb          	subw	s1,s4,s3
      if (n1 > max)
    80004990:	0004879b          	sext.w	a5,s1
    80004994:	fafbd6e3          	bge	s7,a5,80004940 <filewrite+0x80>
    80004998:	84e2                	mv	s1,s8
    8000499a:	b75d                	j	80004940 <filewrite+0x80>
    }
    ret = (i == n ? n : -1);
    8000499c:	053a1463          	bne	s4,s3,800049e4 <filewrite+0x124>
    800049a0:	8552                	mv	a0,s4
    800049a2:	74e2                	ld	s1,56(sp)
    800049a4:	79a2                	ld	s3,40(sp)
    800049a6:	6ae2                	ld	s5,24(sp)
    800049a8:	6ba2                	ld	s7,8(sp)
    800049aa:	6c02                	ld	s8,0(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049ac:	60a6                	ld	ra,72(sp)
    800049ae:	6406                	ld	s0,64(sp)
    800049b0:	7942                	ld	s2,48(sp)
    800049b2:	7a02                	ld	s4,32(sp)
    800049b4:	6b42                	ld	s6,16(sp)
    800049b6:	6161                	addi	sp,sp,80
    800049b8:	8082                	ret
    800049ba:	fc26                	sd	s1,56(sp)
    800049bc:	f44e                	sd	s3,40(sp)
    800049be:	ec56                	sd	s5,24(sp)
    800049c0:	e45e                	sd	s7,8(sp)
    800049c2:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800049c4:	00004517          	auipc	a0,0x4
    800049c8:	db450513          	addi	a0,a0,-588 # 80008778 <etext+0x778>
    800049cc:	e25fb0ef          	jal	800007f0 <panic>
    return -1;
    800049d0:	557d                	li	a0,-1
}
    800049d2:	8082                	ret
    return -1;
    800049d4:	557d                	li	a0,-1
    800049d6:	bfd9                	j	800049ac <filewrite+0xec>
      return -1;
    800049d8:	557d                	li	a0,-1
    800049da:	bfc9                	j	800049ac <filewrite+0xec>
    800049dc:	557d                	li	a0,-1
    800049de:	b7f9                	j	800049ac <filewrite+0xec>
    ret = (i == n ? n : -1);
    800049e0:	8532                	mv	a0,a2
    800049e2:	b7e9                	j	800049ac <filewrite+0xec>
    800049e4:	557d                	li	a0,-1
    800049e6:	74e2                	ld	s1,56(sp)
    800049e8:	79a2                	ld	s3,40(sp)
    800049ea:	6ae2                	ld	s5,24(sp)
    800049ec:	6ba2                	ld	s7,8(sp)
    800049ee:	6c02                	ld	s8,0(sp)
    800049f0:	bf75                	j	800049ac <filewrite+0xec>

00000000800049f2 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049f2:	7179                	addi	sp,sp,-48
    800049f4:	f406                	sd	ra,40(sp)
    800049f6:	f022                	sd	s0,32(sp)
    800049f8:	ec26                	sd	s1,24(sp)
    800049fa:	e052                	sd	s4,0(sp)
    800049fc:	1800                	addi	s0,sp,48
    800049fe:	84aa                	mv	s1,a0
    80004a00:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a02:	0005b023          	sd	zero,0(a1)
    80004a06:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a0a:	c25ff0ef          	jal	8000462e <filealloc>
    80004a0e:	e088                	sd	a0,0(s1)
    80004a10:	c549                	beqz	a0,80004a9a <pipealloc+0xa8>
    80004a12:	c1dff0ef          	jal	8000462e <filealloc>
    80004a16:	00aa3023          	sd	a0,0(s4)
    80004a1a:	cd25                	beqz	a0,80004a92 <pipealloc+0xa0>
    80004a1c:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004a1e:	8acfc0ef          	jal	80000aca <kalloc>
    80004a22:	892a                	mv	s2,a0
    80004a24:	c12d                	beqz	a0,80004a86 <pipealloc+0x94>
    80004a26:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004a28:	4985                	li	s3,1
    80004a2a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a2e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a32:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a36:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a3a:	00004597          	auipc	a1,0x4
    80004a3e:	d4e58593          	addi	a1,a1,-690 # 80008788 <etext+0x788>
    80004a42:	8d8fc0ef          	jal	80000b1a <initlock>
  (*f0)->type = FD_PIPE;
    80004a46:	609c                	ld	a5,0(s1)
    80004a48:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a4c:	609c                	ld	a5,0(s1)
    80004a4e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a52:	609c                	ld	a5,0(s1)
    80004a54:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a58:	609c                	ld	a5,0(s1)
    80004a5a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a5e:	000a3783          	ld	a5,0(s4)
    80004a62:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a66:	000a3783          	ld	a5,0(s4)
    80004a6a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a6e:	000a3783          	ld	a5,0(s4)
    80004a72:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a76:	000a3783          	ld	a5,0(s4)
    80004a7a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a7e:	4501                	li	a0,0
    80004a80:	6942                	ld	s2,16(sp)
    80004a82:	69a2                	ld	s3,8(sp)
    80004a84:	a01d                	j	80004aaa <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004a86:	6088                	ld	a0,0(s1)
    80004a88:	c119                	beqz	a0,80004a8e <pipealloc+0x9c>
    80004a8a:	6942                	ld	s2,16(sp)
    80004a8c:	a029                	j	80004a96 <pipealloc+0xa4>
    80004a8e:	6942                	ld	s2,16(sp)
    80004a90:	a029                	j	80004a9a <pipealloc+0xa8>
    80004a92:	6088                	ld	a0,0(s1)
    80004a94:	c10d                	beqz	a0,80004ab6 <pipealloc+0xc4>
    fileclose(*f0);
    80004a96:	c3dff0ef          	jal	800046d2 <fileclose>
  if (*f1)
    80004a9a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a9e:	557d                	li	a0,-1
  if (*f1)
    80004aa0:	c789                	beqz	a5,80004aaa <pipealloc+0xb8>
    fileclose(*f1);
    80004aa2:	853e                	mv	a0,a5
    80004aa4:	c2fff0ef          	jal	800046d2 <fileclose>
  return -1;
    80004aa8:	557d                	li	a0,-1
}
    80004aaa:	70a2                	ld	ra,40(sp)
    80004aac:	7402                	ld	s0,32(sp)
    80004aae:	64e2                	ld	s1,24(sp)
    80004ab0:	6a02                	ld	s4,0(sp)
    80004ab2:	6145                	addi	sp,sp,48
    80004ab4:	8082                	ret
  return -1;
    80004ab6:	557d                	li	a0,-1
    80004ab8:	bfcd                	j	80004aaa <pipealloc+0xb8>

0000000080004aba <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004aba:	1101                	addi	sp,sp,-32
    80004abc:	ec06                	sd	ra,24(sp)
    80004abe:	e822                	sd	s0,16(sp)
    80004ac0:	e426                	sd	s1,8(sp)
    80004ac2:	e04a                	sd	s2,0(sp)
    80004ac4:	1000                	addi	s0,sp,32
    80004ac6:	84aa                	mv	s1,a0
    80004ac8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004aca:	8c6fc0ef          	jal	80000b90 <acquire>
  if (writable) {
    80004ace:	02090763          	beqz	s2,80004afc <pipeclose+0x42>
    pi->writeopen = 0;
    80004ad2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ad6:	21848513          	addi	a0,s1,536
    80004ada:	daafd0ef          	jal	80002084 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004ade:	2204b783          	ld	a5,544(s1)
    80004ae2:	e785                	bnez	a5,80004b0a <pipeclose+0x50>
    release(&pi->lock);
    80004ae4:	8526                	mv	a0,s1
    80004ae6:	936fc0ef          	jal	80000c1c <release>
    kfree((char *)pi);
    80004aea:	8526                	mv	a0,s1
    80004aec:	efdfb0ef          	jal	800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004af0:	60e2                	ld	ra,24(sp)
    80004af2:	6442                	ld	s0,16(sp)
    80004af4:	64a2                	ld	s1,8(sp)
    80004af6:	6902                	ld	s2,0(sp)
    80004af8:	6105                	addi	sp,sp,32
    80004afa:	8082                	ret
    pi->readopen = 0;
    80004afc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b00:	21c48513          	addi	a0,s1,540
    80004b04:	d80fd0ef          	jal	80002084 <wakeup>
    80004b08:	bfd9                	j	80004ade <pipeclose+0x24>
    release(&pi->lock);
    80004b0a:	8526                	mv	a0,s1
    80004b0c:	910fc0ef          	jal	80000c1c <release>
}
    80004b10:	b7c5                	j	80004af0 <pipeclose+0x36>

0000000080004b12 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b12:	711d                	addi	sp,sp,-96
    80004b14:	ec86                	sd	ra,88(sp)
    80004b16:	e8a2                	sd	s0,80(sp)
    80004b18:	e4a6                	sd	s1,72(sp)
    80004b1a:	e0ca                	sd	s2,64(sp)
    80004b1c:	fc4e                	sd	s3,56(sp)
    80004b1e:	f852                	sd	s4,48(sp)
    80004b20:	f456                	sd	s5,40(sp)
    80004b22:	1080                	addi	s0,sp,96
    80004b24:	84aa                	mv	s1,a0
    80004b26:	8aae                	mv	s5,a1
    80004b28:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b2a:	d79fc0ef          	jal	800018a2 <myproc>
    80004b2e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004b30:	8526                	mv	a0,s1
    80004b32:	85efc0ef          	jal	80000b90 <acquire>
  while (i < n) {
    80004b36:	0d405e63          	blez	s4,80004c12 <pipewrite+0x100>
    80004b3a:	f05a                	sd	s6,32(sp)
    80004b3c:	ec5e                	sd	s7,24(sp)
    80004b3e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004b40:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004b42:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004b44:	21848c13          	addi	s8,s1,536
      sleep_prepare(&pi->nwrite);
    80004b48:	21c48b93          	addi	s7,s1,540
    80004b4c:	a091                	j	80004b90 <pipewrite+0x7e>
      release(&pi->lock);
    80004b4e:	8526                	mv	a0,s1
    80004b50:	8ccfc0ef          	jal	80000c1c <release>
      return -1;
    80004b54:	597d                	li	s2,-1
    80004b56:	7b02                	ld	s6,32(sp)
    80004b58:	6be2                	ld	s7,24(sp)
    80004b5a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b5c:	854a                	mv	a0,s2
    80004b5e:	60e6                	ld	ra,88(sp)
    80004b60:	6446                	ld	s0,80(sp)
    80004b62:	64a6                	ld	s1,72(sp)
    80004b64:	6906                	ld	s2,64(sp)
    80004b66:	79e2                	ld	s3,56(sp)
    80004b68:	7a42                	ld	s4,48(sp)
    80004b6a:	7aa2                	ld	s5,40(sp)
    80004b6c:	6125                	addi	sp,sp,96
    80004b6e:	8082                	ret
      wakeup(&pi->nread);
    80004b70:	8562                	mv	a0,s8
    80004b72:	d12fd0ef          	jal	80002084 <wakeup>
      sleep_prepare(&pi->nwrite);
    80004b76:	855e                	mv	a0,s7
    80004b78:	c94fd0ef          	jal	8000200c <sleep_prepare>
      release(&pi->lock);
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	89efc0ef          	jal	80000c1c <release>
      sleep();
    80004b82:	cc6fd0ef          	jal	80002048 <sleep>
      acquire(&pi->lock);
    80004b86:	8526                	mv	a0,s1
    80004b88:	808fc0ef          	jal	80000b90 <acquire>
  while (i < n) {
    80004b8c:	07495863          	bge	s2,s4,80004bfc <pipewrite+0xea>
    if (pi->readopen == 0 || killed(pr)) {
    80004b90:	2204a783          	lw	a5,544(s1)
    80004b94:	dfcd                	beqz	a5,80004b4e <pipewrite+0x3c>
    80004b96:	854e                	mv	a0,s3
    80004b98:	efafd0ef          	jal	80002292 <killed>
    80004b9c:	f94d                	bnez	a0,80004b4e <pipewrite+0x3c>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004b9e:	2184a783          	lw	a5,536(s1)
    80004ba2:	21c4a703          	lw	a4,540(s1)
    80004ba6:	2007879b          	addiw	a5,a5,512
    80004baa:	fcf703e3          	beq	a4,a5,80004b70 <pipewrite+0x5e>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004bae:	4705                	li	a4,1
    80004bb0:	015906b3          	add	a3,s2,s5
    80004bb4:	faf40613          	addi	a2,s0,-81
    80004bb8:	0489b583          	ld	a1,72(s3)
    80004bbc:	0509b503          	ld	a0,80(s3)
    80004bc0:	a05fc0ef          	jal	800015c4 <copyin>
    80004bc4:	03650163          	beq	a0,s6,80004be6 <pipewrite+0xd4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bc8:	21c4a783          	lw	a5,540(s1)
    80004bcc:	0017871b          	addiw	a4,a5,1
    80004bd0:	20e4ae23          	sw	a4,540(s1)
    80004bd4:	1ff7f793          	andi	a5,a5,511
    80004bd8:	97a6                	add	a5,a5,s1
    80004bda:	faf44703          	lbu	a4,-81(s0)
    80004bde:	00e78c23          	sb	a4,24(a5)
      i++;
    80004be2:	2905                	addiw	s2,s2,1
    80004be4:	b765                	j	80004b8c <pipewrite+0x7a>
        if (i == 0)
    80004be6:	00090663          	beqz	s2,80004bf2 <pipewrite+0xe0>
    80004bea:	7b02                	ld	s6,32(sp)
    80004bec:	6be2                	ld	s7,24(sp)
    80004bee:	6c42                	ld	s8,16(sp)
    80004bf0:	a809                	j	80004c02 <pipewrite+0xf0>
          i = -1;
    80004bf2:	892a                	mv	s2,a0
        break;
    80004bf4:	7b02                	ld	s6,32(sp)
    80004bf6:	6be2                	ld	s7,24(sp)
    80004bf8:	6c42                	ld	s8,16(sp)
    80004bfa:	a021                	j	80004c02 <pipewrite+0xf0>
    80004bfc:	7b02                	ld	s6,32(sp)
    80004bfe:	6be2                	ld	s7,24(sp)
    80004c00:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004c02:	21848513          	addi	a0,s1,536
    80004c06:	c7efd0ef          	jal	80002084 <wakeup>
  release(&pi->lock);
    80004c0a:	8526                	mv	a0,s1
    80004c0c:	810fc0ef          	jal	80000c1c <release>
  return i;
    80004c10:	b7b1                	j	80004b5c <pipewrite+0x4a>
  int i = 0;
    80004c12:	4901                	li	s2,0
    80004c14:	b7fd                	j	80004c02 <pipewrite+0xf0>

0000000080004c16 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c16:	715d                	addi	sp,sp,-80
    80004c18:	e486                	sd	ra,72(sp)
    80004c1a:	e0a2                	sd	s0,64(sp)
    80004c1c:	fc26                	sd	s1,56(sp)
    80004c1e:	f84a                	sd	s2,48(sp)
    80004c20:	f44e                	sd	s3,40(sp)
    80004c22:	f052                	sd	s4,32(sp)
    80004c24:	ec56                	sd	s5,24(sp)
    80004c26:	0880                	addi	s0,sp,80
    80004c28:	84aa                	mv	s1,a0
    80004c2a:	89ae                	mv	s3,a1
    80004c2c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c2e:	c75fc0ef          	jal	800018a2 <myproc>
    80004c32:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004c34:	8526                	mv	a0,s1
    80004c36:	f5bfb0ef          	jal	80000b90 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004c3a:	2184a703          	lw	a4,536(s1)
    80004c3e:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004c42:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004c46:	02f71c63          	bne	a4,a5,80004c7e <piperead+0x68>
    80004c4a:	2244a783          	lw	a5,548(s1)
    80004c4e:	cf9d                	beqz	a5,80004c8c <piperead+0x76>
    if (killed(pr)) {
    80004c50:	854a                	mv	a0,s2
    80004c52:	e40fd0ef          	jal	80002292 <killed>
    80004c56:	e515                	bnez	a0,80004c82 <piperead+0x6c>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004c58:	8552                	mv	a0,s4
    80004c5a:	bb2fd0ef          	jal	8000200c <sleep_prepare>
    release(&pi->lock);
    80004c5e:	8526                	mv	a0,s1
    80004c60:	fbdfb0ef          	jal	80000c1c <release>
    sleep();
    80004c64:	be4fd0ef          	jal	80002048 <sleep>
    acquire(&pi->lock);
    80004c68:	8526                	mv	a0,s1
    80004c6a:	f27fb0ef          	jal	80000b90 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004c6e:	2184a703          	lw	a4,536(s1)
    80004c72:	21c4a783          	lw	a5,540(s1)
    80004c76:	fcf70ae3          	beq	a4,a5,80004c4a <piperead+0x34>
    80004c7a:	e85a                	sd	s6,16(sp)
    80004c7c:	a809                	j	80004c8e <piperead+0x78>
    80004c7e:	e85a                	sd	s6,16(sp)
    80004c80:	a039                	j	80004c8e <piperead+0x78>
      release(&pi->lock);
    80004c82:	8526                	mv	a0,s1
    80004c84:	f99fb0ef          	jal	80000c1c <release>
      return -1;
    80004c88:	5a7d                	li	s4,-1
    80004c8a:	a08d                	j	80004cec <piperead+0xd6>
    80004c8c:	e85a                	sd	s6,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004c8e:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004c90:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004c92:	05505563          	blez	s5,80004cdc <piperead+0xc6>
    if (pi->nread == pi->nwrite)
    80004c96:	2184a783          	lw	a5,536(s1)
    80004c9a:	21c4a703          	lw	a4,540(s1)
    80004c9e:	02f70f63          	beq	a4,a5,80004cdc <piperead+0xc6>
    ch = pi->data[pi->nread % PIPESIZE];
    80004ca2:	1ff7f793          	andi	a5,a5,511
    80004ca6:	97a6                	add	a5,a5,s1
    80004ca8:	0187c783          	lbu	a5,24(a5)
    80004cac:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004cb0:	4705                	li	a4,1
    80004cb2:	fbf40693          	addi	a3,s0,-65
    80004cb6:	864e                	mv	a2,s3
    80004cb8:	04893583          	ld	a1,72(s2)
    80004cbc:	05093503          	ld	a0,80(s2)
    80004cc0:	819fc0ef          	jal	800014d8 <copyout>
    80004cc4:	03650e63          	beq	a0,s6,80004d00 <piperead+0xea>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004cc8:	2184a783          	lw	a5,536(s1)
    80004ccc:	2785                	addiw	a5,a5,1
    80004cce:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004cd2:	2a05                	addiw	s4,s4,1
    80004cd4:	0985                	addi	s3,s3,1
    80004cd6:	fd4a90e3          	bne	s5,s4,80004c96 <piperead+0x80>
    80004cda:	8a56                	mv	s4,s5
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004cdc:	21c48513          	addi	a0,s1,540
    80004ce0:	ba4fd0ef          	jal	80002084 <wakeup>
  release(&pi->lock);
    80004ce4:	8526                	mv	a0,s1
    80004ce6:	f37fb0ef          	jal	80000c1c <release>
    80004cea:	6b42                	ld	s6,16(sp)
  return i;
}
    80004cec:	8552                	mv	a0,s4
    80004cee:	60a6                	ld	ra,72(sp)
    80004cf0:	6406                	ld	s0,64(sp)
    80004cf2:	74e2                	ld	s1,56(sp)
    80004cf4:	7942                	ld	s2,48(sp)
    80004cf6:	79a2                	ld	s3,40(sp)
    80004cf8:	7a02                	ld	s4,32(sp)
    80004cfa:	6ae2                	ld	s5,24(sp)
    80004cfc:	6161                	addi	sp,sp,80
    80004cfe:	8082                	ret
      if (i == 0)
    80004d00:	fc0a1ee3          	bnez	s4,80004cdc <piperead+0xc6>
        i = -1;
    80004d04:	8a2a                	mv	s4,a0
    80004d06:	bfd9                	j	80004cdc <piperead+0xc6>

0000000080004d08 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004d08:	1141                	addi	sp,sp,-16
    80004d0a:	e422                	sd	s0,8(sp)
    80004d0c:	0800                	addi	s0,sp,16
    80004d0e:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004d10:	8905                	andi	a0,a0,1
    80004d12:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80004d14:	8b89                	andi	a5,a5,2
    80004d16:	c399                	beqz	a5,80004d1c <flags2perm+0x14>
    perm |= PTE_W;
    80004d18:	00456513          	ori	a0,a0,4
  return perm;
}
    80004d1c:	6422                	ld	s0,8(sp)
    80004d1e:	0141                	addi	sp,sp,16
    80004d20:	8082                	ret

0000000080004d22 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004d22:	df010113          	addi	sp,sp,-528
    80004d26:	20113423          	sd	ra,520(sp)
    80004d2a:	20813023          	sd	s0,512(sp)
    80004d2e:	ffa6                	sd	s1,504(sp)
    80004d30:	fbca                	sd	s2,496(sp)
    80004d32:	0c00                	addi	s0,sp,528
    80004d34:	892a                	mv	s2,a0
    80004d36:	dea43c23          	sd	a0,-520(s0)
    80004d3a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d3e:	b65fc0ef          	jal	800018a2 <myproc>
    80004d42:	84aa                	mv	s1,a0

  begin_op();
    80004d44:	ce2ff0ef          	jal	80004226 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004d48:	854a                	mv	a0,s2
    80004d4a:	b08ff0ef          	jal	80004052 <namei>
    80004d4e:	c931                	beqz	a0,80004da2 <kexec+0x80>
    80004d50:	f3d2                	sd	s4,480(sp)
    80004d52:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d54:	a8bfe0ef          	jal	800037de <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d58:	04000713          	li	a4,64
    80004d5c:	4681                	li	a3,0
    80004d5e:	e5040613          	addi	a2,s0,-432
    80004d62:	4581                	li	a1,0
    80004d64:	8552                	mv	a0,s4
    80004d66:	e51fe0ef          	jal	80003bb6 <readi>
    80004d6a:	04000793          	li	a5,64
    80004d6e:	00f51a63          	bne	a0,a5,80004d82 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004d72:	e5042703          	lw	a4,-432(s0)
    80004d76:	464c47b7          	lui	a5,0x464c4
    80004d7a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d7e:	02f70663          	beq	a4,a5,80004daa <kexec+0x88>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004d82:	8552                	mv	a0,s4
    80004d84:	cadfe0ef          	jal	80003a30 <iunlockput>
    end_op();
    80004d88:	d24ff0ef          	jal	800042ac <end_op>
  }
  return -1;
    80004d8c:	557d                	li	a0,-1
    80004d8e:	7a1e                	ld	s4,480(sp)
}
    80004d90:	20813083          	ld	ra,520(sp)
    80004d94:	20013403          	ld	s0,512(sp)
    80004d98:	74fe                	ld	s1,504(sp)
    80004d9a:	795e                	ld	s2,496(sp)
    80004d9c:	21010113          	addi	sp,sp,528
    80004da0:	8082                	ret
    end_op();
    80004da2:	d0aff0ef          	jal	800042ac <end_op>
    return -1;
    80004da6:	557d                	li	a0,-1
    80004da8:	b7e5                	j	80004d90 <kexec+0x6e>
    80004daa:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004dac:	8526                	mv	a0,s1
    80004dae:	c07fc0ef          	jal	800019b4 <proc_pagetable>
    80004db2:	8b2a                	mv	s6,a0
    80004db4:	2c050963          	beqz	a0,80005086 <kexec+0x364>
    80004db8:	f7ce                	sd	s3,488(sp)
    80004dba:	efd6                	sd	s5,472(sp)
    80004dbc:	e7de                	sd	s7,456(sp)
    80004dbe:	e3e2                	sd	s8,448(sp)
    80004dc0:	ff66                	sd	s9,440(sp)
    80004dc2:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004dc4:	e7042d03          	lw	s10,-400(s0)
    80004dc8:	e8845783          	lhu	a5,-376(s0)
    80004dcc:	12078863          	beqz	a5,80004efc <kexec+0x1da>
    80004dd0:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dd2:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004dd4:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    80004dd6:	6c85                	lui	s9,0x1
    80004dd8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ddc:	def43823          	sd	a5,-528(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004de0:	6a85                	lui	s5,0x1
    80004de2:	a085                	j	80004e42 <kexec+0x120>
      panic("loadseg: address should exist");
    80004de4:	00004517          	auipc	a0,0x4
    80004de8:	9ac50513          	addi	a0,a0,-1620 # 80008790 <etext+0x790>
    80004dec:	a05fb0ef          	jal	800007f0 <panic>
    if (sz - i < PGSIZE)
    80004df0:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004df2:	8726                	mv	a4,s1
    80004df4:	012c06bb          	addw	a3,s8,s2
    80004df8:	4581                	li	a1,0
    80004dfa:	8552                	mv	a0,s4
    80004dfc:	dbbfe0ef          	jal	80003bb6 <readi>
    80004e00:	2501                	sext.w	a0,a0
    80004e02:	24a49863          	bne	s1,a0,80005052 <kexec+0x330>
  for (i = 0; i < sz; i += PGSIZE) {
    80004e06:	012a893b          	addw	s2,s5,s2
    80004e0a:	03397363          	bgeu	s2,s3,80004e30 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004e0e:	02091593          	slli	a1,s2,0x20
    80004e12:	9181                	srli	a1,a1,0x20
    80004e14:	95de                	add	a1,a1,s7
    80004e16:	855a                	mv	a0,s6
    80004e18:	94cfc0ef          	jal	80000f64 <walkaddr>
    80004e1c:	862a                	mv	a2,a0
    if (pa == 0)
    80004e1e:	d179                	beqz	a0,80004de4 <kexec+0xc2>
    if (sz - i < PGSIZE)
    80004e20:	412984bb          	subw	s1,s3,s2
    80004e24:	0004879b          	sext.w	a5,s1
    80004e28:	fcfcf4e3          	bgeu	s9,a5,80004df0 <kexec+0xce>
    80004e2c:	84d6                	mv	s1,s5
    80004e2e:	b7c9                	j	80004df0 <kexec+0xce>
    sz = sz1;
    80004e30:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004e34:	2d85                	addiw	s11,s11,1
    80004e36:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004e3a:	e8845783          	lhu	a5,-376(s0)
    80004e3e:	08fdd063          	bge	s11,a5,80004ebe <kexec+0x19c>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e42:	2d01                	sext.w	s10,s10
    80004e44:	03800713          	li	a4,56
    80004e48:	86ea                	mv	a3,s10
    80004e4a:	e1840613          	addi	a2,s0,-488
    80004e4e:	4581                	li	a1,0
    80004e50:	8552                	mv	a0,s4
    80004e52:	d65fe0ef          	jal	80003bb6 <readi>
    80004e56:	03800793          	li	a5,56
    80004e5a:	1cf51463          	bne	a0,a5,80005022 <kexec+0x300>
    if (ph.type != ELF_PROG_LOAD)
    80004e5e:	e1842783          	lw	a5,-488(s0)
    80004e62:	4705                	li	a4,1
    80004e64:	fce798e3          	bne	a5,a4,80004e34 <kexec+0x112>
    if (ph.memsz < ph.filesz)
    80004e68:	e4043483          	ld	s1,-448(s0)
    80004e6c:	e3843783          	ld	a5,-456(s0)
    80004e70:	1af4ed63          	bltu	s1,a5,8000502a <kexec+0x308>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004e74:	e2843783          	ld	a5,-472(s0)
    80004e78:	94be                	add	s1,s1,a5
    80004e7a:	1af4ec63          	bltu	s1,a5,80005032 <kexec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    80004e7e:	df043703          	ld	a4,-528(s0)
    80004e82:	8ff9                	and	a5,a5,a4
    80004e84:	1a079b63          	bnez	a5,8000503a <kexec+0x318>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004e88:	e1c42503          	lw	a0,-484(s0)
    80004e8c:	e7dff0ef          	jal	80004d08 <flags2perm>
    80004e90:	86aa                	mv	a3,a0
    80004e92:	8626                	mv	a2,s1
    80004e94:	85ca                	mv	a1,s2
    80004e96:	855a                	mv	a0,s6
    80004e98:	ba4fc0ef          	jal	8000123c <uvmalloc>
    80004e9c:	e0a43423          	sd	a0,-504(s0)
    80004ea0:	1a050163          	beqz	a0,80005042 <kexec+0x320>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ea4:	e2843b83          	ld	s7,-472(s0)
    80004ea8:	e2042c03          	lw	s8,-480(s0)
    80004eac:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004eb0:	00098463          	beqz	s3,80004eb8 <kexec+0x196>
    80004eb4:	4901                	li	s2,0
    80004eb6:	bfa1                	j	80004e0e <kexec+0xec>
    sz = sz1;
    80004eb8:	e0843903          	ld	s2,-504(s0)
    80004ebc:	bfa5                	j	80004e34 <kexec+0x112>
    80004ebe:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004ec0:	8552                	mv	a0,s4
    80004ec2:	b6ffe0ef          	jal	80003a30 <iunlockput>
  end_op();
    80004ec6:	be6ff0ef          	jal	800042ac <end_op>
  p = myproc();
    80004eca:	9d9fc0ef          	jal	800018a2 <myproc>
    80004ece:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004ed0:	04853a03          	ld	s4,72(a0)
  sz = PGROUNDUP(sz);
    80004ed4:	6b85                	lui	s7,0x1
    80004ed6:	1bfd                	addi	s7,s7,-1 # fff <_entry-0x7ffff001>
    80004ed8:	9bca                	add	s7,s7,s2
    80004eda:	77fd                	lui	a5,0xfffff
    80004edc:	00fbfbb3          	and	s7,s7,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004ee0:	4691                	li	a3,4
    80004ee2:	6609                	lui	a2,0x2
    80004ee4:	965e                	add	a2,a2,s7
    80004ee6:	85de                	mv	a1,s7
    80004ee8:	855a                	mv	a0,s6
    80004eea:	b52fc0ef          	jal	8000123c <uvmalloc>
    80004eee:	e0a43423          	sd	a0,-504(s0)
    80004ef2:	e519                	bnez	a0,80004f00 <kexec+0x1de>
  if (pagetable)
    80004ef4:	e1743423          	sd	s7,-504(s0)
    80004ef8:	4a01                	li	s4,0
    80004efa:	aaa9                	j	80005054 <kexec+0x332>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004efc:	4901                	li	s2,0
    80004efe:	b7c9                	j	80004ec0 <kexec+0x19e>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004f00:	75f9                	lui	a1,0xffffe
    80004f02:	8baa                	mv	s7,a0
    80004f04:	95aa                	add	a1,a1,a0
    80004f06:	855a                	mv	a0,s6
    80004f08:	d0afc0ef          	jal	80001412 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004f0c:	7afd                	lui	s5,0xfffff
    80004f0e:	9ade                	add	s5,s5,s7
  for (argc = 0; argv[argc]; argc++) {
    80004f10:	e0043783          	ld	a5,-512(s0)
    80004f14:	6388                	ld	a0,0(a5)
    80004f16:	c15d                	beqz	a0,80004fbc <kexec+0x29a>
    80004f18:	e9040913          	addi	s2,s0,-368
    80004f1c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f1e:	ea7fb0ef          	jal	80000dc4 <strlen>
    80004f22:	0015079b          	addiw	a5,a0,1
    80004f26:	40fb87b3          	sub	a5,s7,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f2a:	ff07fb93          	andi	s7,a5,-16
    if (sp < stackbase)
    80004f2e:	115bee63          	bltu	s7,s5,8000504a <kexec+0x328>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f32:	e0043c83          	ld	s9,-512(s0)
    80004f36:	000cbc03          	ld	s8,0(s9)
    80004f3a:	8562                	mv	a0,s8
    80004f3c:	e89fb0ef          	jal	80000dc4 <strlen>
    80004f40:	0015071b          	addiw	a4,a0,1
    80004f44:	86e2                	mv	a3,s8
    80004f46:	865e                	mv	a2,s7
    80004f48:	e0843583          	ld	a1,-504(s0)
    80004f4c:	855a                	mv	a0,s6
    80004f4e:	d8afc0ef          	jal	800014d8 <copyout>
    80004f52:	0e054e63          	bltz	a0,8000504e <kexec+0x32c>
    ustack[argc] = sp;
    80004f56:	01793023          	sd	s7,0(s2)
  for (argc = 0; argv[argc]; argc++) {
    80004f5a:	0485                	addi	s1,s1,1
    80004f5c:	008c8793          	addi	a5,s9,8
    80004f60:	e0f43023          	sd	a5,-512(s0)
    80004f64:	008cb503          	ld	a0,8(s9)
    80004f68:	0921                	addi	s2,s2,8
    80004f6a:	f955                	bnez	a0,80004f1e <kexec+0x1fc>
  ustack[argc] = 0;
    80004f6c:	00349793          	slli	a5,s1,0x3
    80004f70:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd94e0>
    80004f74:	97a2                	add	a5,a5,s0
    80004f76:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004f7a:	00148713          	addi	a4,s1,1
    80004f7e:	070e                	slli	a4,a4,0x3
    80004f80:	40eb8933          	sub	s2,s7,a4
  sp -= sp % 16;
    80004f84:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f88:	e0843583          	ld	a1,-504(s0)
    80004f8c:	8bae                	mv	s7,a1
  if (sp < stackbase)
    80004f8e:	f75963e3          	bltu	s2,s5,80004ef4 <kexec+0x1d2>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004f92:	e9040693          	addi	a3,s0,-368
    80004f96:	864a                	mv	a2,s2
    80004f98:	855a                	mv	a0,s6
    80004f9a:	d3efc0ef          	jal	800014d8 <copyout>
    80004f9e:	0e054663          	bltz	a0,8000508a <kexec+0x368>
  p->trapframe->a1 = sp;
    80004fa2:	0589b783          	ld	a5,88(s3)
    80004fa6:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80004faa:	df843783          	ld	a5,-520(s0)
    80004fae:	0007c703          	lbu	a4,0(a5)
    80004fb2:	c315                	beqz	a4,80004fd6 <kexec+0x2b4>
    80004fb4:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004fb6:	02f00693          	li	a3,47
    80004fba:	a809                	j	80004fcc <kexec+0x2aa>
  sp = sz;
    80004fbc:	e0843b83          	ld	s7,-504(s0)
  for (argc = 0; argv[argc]; argc++) {
    80004fc0:	4481                	li	s1,0
    80004fc2:	b76d                	j	80004f6c <kexec+0x24a>
  for (last = s = path; *s; s++)
    80004fc4:	0785                	addi	a5,a5,1
    80004fc6:	fff7c703          	lbu	a4,-1(a5)
    80004fca:	c711                	beqz	a4,80004fd6 <kexec+0x2b4>
    if (*s == '/')
    80004fcc:	fed71ce3          	bne	a4,a3,80004fc4 <kexec+0x2a2>
      last = s + 1;
    80004fd0:	def43c23          	sd	a5,-520(s0)
    80004fd4:	bfc5                	j	80004fc4 <kexec+0x2a2>
  safestrcpy(p->name, last, sizeof(p->name));
    80004fd6:	4641                	li	a2,16
    80004fd8:	df843583          	ld	a1,-520(s0)
    80004fdc:	15898513          	addi	a0,s3,344
    80004fe0:	db3fb0ef          	jal	80000d92 <safestrcpy>
  oldpagetable = p->pagetable;
    80004fe4:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004fe8:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004fec:	e0843783          	ld	a5,-504(s0)
    80004ff0:	04f9b423          	sd	a5,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004ff4:	0589b783          	ld	a5,88(s3)
    80004ff8:	e6843703          	ld	a4,-408(s0)
    80004ffc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004ffe:	0589b783          	ld	a5,88(s3)
    80005002:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005006:	85d2                	mv	a1,s4
    80005008:	a31fc0ef          	jal	80001a38 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000500c:	0004851b          	sext.w	a0,s1
    80005010:	79be                	ld	s3,488(sp)
    80005012:	7a1e                	ld	s4,480(sp)
    80005014:	6afe                	ld	s5,472(sp)
    80005016:	6b5e                	ld	s6,464(sp)
    80005018:	6bbe                	ld	s7,456(sp)
    8000501a:	6c1e                	ld	s8,448(sp)
    8000501c:	7cfa                	ld	s9,440(sp)
    8000501e:	7d5a                	ld	s10,432(sp)
    80005020:	bb85                	j	80004d90 <kexec+0x6e>
    80005022:	e1243423          	sd	s2,-504(s0)
    80005026:	7dba                	ld	s11,424(sp)
    80005028:	a035                	j	80005054 <kexec+0x332>
    8000502a:	e1243423          	sd	s2,-504(s0)
    8000502e:	7dba                	ld	s11,424(sp)
    80005030:	a015                	j	80005054 <kexec+0x332>
    80005032:	e1243423          	sd	s2,-504(s0)
    80005036:	7dba                	ld	s11,424(sp)
    80005038:	a831                	j	80005054 <kexec+0x332>
    8000503a:	e1243423          	sd	s2,-504(s0)
    8000503e:	7dba                	ld	s11,424(sp)
    80005040:	a811                	j	80005054 <kexec+0x332>
    80005042:	e1243423          	sd	s2,-504(s0)
    80005046:	7dba                	ld	s11,424(sp)
    80005048:	a031                	j	80005054 <kexec+0x332>
  ip = 0;
    8000504a:	4a01                	li	s4,0
    8000504c:	a021                	j	80005054 <kexec+0x332>
    8000504e:	4a01                	li	s4,0
  if (pagetable)
    80005050:	a011                	j	80005054 <kexec+0x332>
    80005052:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005054:	e0843583          	ld	a1,-504(s0)
    80005058:	855a                	mv	a0,s6
    8000505a:	9dffc0ef          	jal	80001a38 <proc_freepagetable>
  return -1;
    8000505e:	557d                	li	a0,-1
  if (ip) {
    80005060:	000a1b63          	bnez	s4,80005076 <kexec+0x354>
    80005064:	79be                	ld	s3,488(sp)
    80005066:	7a1e                	ld	s4,480(sp)
    80005068:	6afe                	ld	s5,472(sp)
    8000506a:	6b5e                	ld	s6,464(sp)
    8000506c:	6bbe                	ld	s7,456(sp)
    8000506e:	6c1e                	ld	s8,448(sp)
    80005070:	7cfa                	ld	s9,440(sp)
    80005072:	7d5a                	ld	s10,432(sp)
    80005074:	bb31                	j	80004d90 <kexec+0x6e>
    80005076:	79be                	ld	s3,488(sp)
    80005078:	6afe                	ld	s5,472(sp)
    8000507a:	6b5e                	ld	s6,464(sp)
    8000507c:	6bbe                	ld	s7,456(sp)
    8000507e:	6c1e                	ld	s8,448(sp)
    80005080:	7cfa                	ld	s9,440(sp)
    80005082:	7d5a                	ld	s10,432(sp)
    80005084:	b9fd                	j	80004d82 <kexec+0x60>
    80005086:	6b5e                	ld	s6,464(sp)
    80005088:	b9ed                	j	80004d82 <kexec+0x60>
  sz = sz1;
    8000508a:	e0843b83          	ld	s7,-504(s0)
    8000508e:	b59d                	j	80004ef4 <kexec+0x1d2>

0000000080005090 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005090:	7179                	addi	sp,sp,-48
    80005092:	f406                	sd	ra,40(sp)
    80005094:	f022                	sd	s0,32(sp)
    80005096:	ec26                	sd	s1,24(sp)
    80005098:	e84a                	sd	s2,16(sp)
    8000509a:	1800                	addi	s0,sp,48
    8000509c:	892e                	mv	s2,a1
    8000509e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800050a0:	fdc40593          	addi	a1,s0,-36
    800050a4:	a2dfd0ef          	jal	80002ad0 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    800050a8:	fdc42703          	lw	a4,-36(s0)
    800050ac:	47bd                	li	a5,15
    800050ae:	02e7e963          	bltu	a5,a4,800050e0 <argfd+0x50>
    800050b2:	ff0fc0ef          	jal	800018a2 <myproc>
    800050b6:	fdc42703          	lw	a4,-36(s0)
    800050ba:	01a70793          	addi	a5,a4,26
    800050be:	078e                	slli	a5,a5,0x3
    800050c0:	953e                	add	a0,a0,a5
    800050c2:	611c                	ld	a5,0(a0)
    800050c4:	c385                	beqz	a5,800050e4 <argfd+0x54>
    return -1;
  if (pfd)
    800050c6:	00090463          	beqz	s2,800050ce <argfd+0x3e>
    *pfd = fd;
    800050ca:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    800050ce:	4501                	li	a0,0
  if (pf)
    800050d0:	c091                	beqz	s1,800050d4 <argfd+0x44>
    *pf = f;
    800050d2:	e09c                	sd	a5,0(s1)
}
    800050d4:	70a2                	ld	ra,40(sp)
    800050d6:	7402                	ld	s0,32(sp)
    800050d8:	64e2                	ld	s1,24(sp)
    800050da:	6942                	ld	s2,16(sp)
    800050dc:	6145                	addi	sp,sp,48
    800050de:	8082                	ret
    return -1;
    800050e0:	557d                	li	a0,-1
    800050e2:	bfcd                	j	800050d4 <argfd+0x44>
    800050e4:	557d                	li	a0,-1
    800050e6:	b7fd                	j	800050d4 <argfd+0x44>

00000000800050e8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050e8:	1101                	addi	sp,sp,-32
    800050ea:	ec06                	sd	ra,24(sp)
    800050ec:	e822                	sd	s0,16(sp)
    800050ee:	e426                	sd	s1,8(sp)
    800050f0:	1000                	addi	s0,sp,32
    800050f2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050f4:	faefc0ef          	jal	800018a2 <myproc>
    800050f8:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    800050fa:	0d050793          	addi	a5,a0,208
    800050fe:	4501                	li	a0,0
    80005100:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80005102:	6398                	ld	a4,0(a5)
    80005104:	cb19                	beqz	a4,8000511a <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80005106:	2505                	addiw	a0,a0,1
    80005108:	07a1                	addi	a5,a5,8
    8000510a:	fed51ce3          	bne	a0,a3,80005102 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000510e:	557d                	li	a0,-1
}
    80005110:	60e2                	ld	ra,24(sp)
    80005112:	6442                	ld	s0,16(sp)
    80005114:	64a2                	ld	s1,8(sp)
    80005116:	6105                	addi	sp,sp,32
    80005118:	8082                	ret
      p->ofile[fd] = f;
    8000511a:	01a50793          	addi	a5,a0,26
    8000511e:	078e                	slli	a5,a5,0x3
    80005120:	963e                	add	a2,a2,a5
    80005122:	e204                	sd	s1,0(a2)
      return fd;
    80005124:	b7f5                	j	80005110 <fdalloc+0x28>

0000000080005126 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80005126:	715d                	addi	sp,sp,-80
    80005128:	e486                	sd	ra,72(sp)
    8000512a:	e0a2                	sd	s0,64(sp)
    8000512c:	fc26                	sd	s1,56(sp)
    8000512e:	f84a                	sd	s2,48(sp)
    80005130:	f44e                	sd	s3,40(sp)
    80005132:	f052                	sd	s4,32(sp)
    80005134:	ec56                	sd	s5,24(sp)
    80005136:	0880                	addi	s0,sp,80
    80005138:	892e                	mv	s2,a1
    8000513a:	89b2                	mv	s3,a2
    8000513c:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    8000513e:	fb040593          	addi	a1,s0,-80
    80005142:	f2bfe0ef          	jal	8000406c <nameiparent>
    80005146:	8aaa                	mv	s5,a0
    80005148:	cd45                	beqz	a0,80005200 <create+0xda>
    return 0;

  ilock(dp);
    8000514a:	e94fe0ef          	jal	800037de <ilock>

  if (dp->nlink == 0) {
    8000514e:	04aa9783          	lh	a5,74(s5) # fffffffffffff04a <end+0xffffffff7ffd959a>
    80005152:	cf8d                	beqz	a5,8000518c <create+0x66>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80005154:	4705                	li	a4,1
    80005156:	04e91563          	bne	s2,a4,800051a0 <create+0x7a>
    8000515a:	6721                	lui	a4,0x8
    8000515c:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    8000515e:	02e78c63          	beq	a5,a4,80005196 <create+0x70>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80005162:	4601                	li	a2,0
    80005164:	fb040593          	addi	a1,s0,-80
    80005168:	8556                	mv	a0,s5
    8000516a:	c73fe0ef          	jal	80003ddc <dirlookup>
    8000516e:	84aa                	mv	s1,a0
    80005170:	e951                	bnez	a0,80005204 <create+0xde>
      return ip;
    iunlockput(ip);
    return 0;
  }

  if ((ip = ialloc(dp->dev, type)) == 0) {
    80005172:	85ca                	mv	a1,s2
    80005174:	000aa503          	lw	a0,0(s5)
    80005178:	cf6fe0ef          	jal	8000366e <ialloc>
    8000517c:	84aa                	mv	s1,a0
    8000517e:	0c051e63          	bnez	a0,8000525a <create+0x134>
    iunlockput(dp);
    80005182:	8556                	mv	a0,s5
    80005184:	8adfe0ef          	jal	80003a30 <iunlockput>
    return 0;
    80005188:	4481                	li	s1,0
    8000518a:	a0a1                	j	800051d2 <create+0xac>
    iunlockput(dp);
    8000518c:	8556                	mv	a0,s5
    8000518e:	8a3fe0ef          	jal	80003a30 <iunlockput>
    return 0;
    80005192:	4481                	li	s1,0
    80005194:	a83d                	j	800051d2 <create+0xac>
    iunlockput(dp);
    80005196:	8556                	mv	a0,s5
    80005198:	899fe0ef          	jal	80003a30 <iunlockput>
    return 0;
    8000519c:	4481                	li	s1,0
    8000519e:	a815                	j	800051d2 <create+0xac>
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    800051a0:	4601                	li	a2,0
    800051a2:	fb040593          	addi	a1,s0,-80
    800051a6:	8556                	mv	a0,s5
    800051a8:	c35fe0ef          	jal	80003ddc <dirlookup>
    800051ac:	84aa                	mv	s1,a0
    800051ae:	c535                	beqz	a0,8000521a <create+0xf4>
    iunlockput(dp);
    800051b0:	8556                	mv	a0,s5
    800051b2:	87ffe0ef          	jal	80003a30 <iunlockput>
    ilock(ip);
    800051b6:	8526                	mv	a0,s1
    800051b8:	e26fe0ef          	jal	800037de <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051bc:	4789                	li	a5,2
    800051be:	04f91963          	bne	s2,a5,80005210 <create+0xea>
    800051c2:	0444d783          	lhu	a5,68(s1)
    800051c6:	37f9                	addiw	a5,a5,-2
    800051c8:	17c2                	slli	a5,a5,0x30
    800051ca:	93c1                	srli	a5,a5,0x30
    800051cc:	4705                	li	a4,1
    800051ce:	04f76163          	bltu	a4,a5,80005210 <create+0xea>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800051d2:	8526                	mv	a0,s1
    800051d4:	60a6                	ld	ra,72(sp)
    800051d6:	6406                	ld	s0,64(sp)
    800051d8:	74e2                	ld	s1,56(sp)
    800051da:	7942                	ld	s2,48(sp)
    800051dc:	79a2                	ld	s3,40(sp)
    800051de:	7a02                	ld	s4,32(sp)
    800051e0:	6ae2                	ld	s5,24(sp)
    800051e2:	6161                	addi	sp,sp,80
    800051e4:	8082                	ret
  ip->nlink = 0;
    800051e6:	04049523          	sh	zero,74(s1)
  iupdate(ip);
    800051ea:	8526                	mv	a0,s1
    800051ec:	d3efe0ef          	jal	8000372a <iupdate>
  iunlockput(ip);
    800051f0:	8526                	mv	a0,s1
    800051f2:	83ffe0ef          	jal	80003a30 <iunlockput>
  iunlockput(dp);
    800051f6:	8556                	mv	a0,s5
    800051f8:	839fe0ef          	jal	80003a30 <iunlockput>
  return 0;
    800051fc:	4481                	li	s1,0
    800051fe:	bfd1                	j	800051d2 <create+0xac>
    return 0;
    80005200:	84aa                	mv	s1,a0
    80005202:	bfc1                	j	800051d2 <create+0xac>
    iunlockput(dp);
    80005204:	8556                	mv	a0,s5
    80005206:	82bfe0ef          	jal	80003a30 <iunlockput>
    ilock(ip);
    8000520a:	8526                	mv	a0,s1
    8000520c:	dd2fe0ef          	jal	800037de <ilock>
    iunlockput(ip);
    80005210:	8526                	mv	a0,s1
    80005212:	81ffe0ef          	jal	80003a30 <iunlockput>
    return 0;
    80005216:	4481                	li	s1,0
    80005218:	bf6d                	j	800051d2 <create+0xac>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    8000521a:	85ca                	mv	a1,s2
    8000521c:	000aa503          	lw	a0,0(s5)
    80005220:	c4efe0ef          	jal	8000366e <ialloc>
    80005224:	84aa                	mv	s1,a0
    80005226:	dd31                	beqz	a0,80005182 <create+0x5c>
  ilock(ip);
    80005228:	8526                	mv	a0,s1
    8000522a:	db4fe0ef          	jal	800037de <ilock>
  ip->major = major;
    8000522e:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80005232:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005236:	4785                	li	a5,1
    80005238:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000523c:	8526                	mv	a0,s1
    8000523e:	cecfe0ef          	jal	8000372a <iupdate>
  if (dirlink(dp, name, ip->inum) < 0)
    80005242:	40d0                	lw	a2,4(s1)
    80005244:	fb040593          	addi	a1,s0,-80
    80005248:	8556                	mv	a0,s5
    8000524a:	d6ffe0ef          	jal	80003fb8 <dirlink>
    8000524e:	f8054ce3          	bltz	a0,800051e6 <create+0xc0>
  iunlockput(dp);
    80005252:	8556                	mv	a0,s5
    80005254:	fdcfe0ef          	jal	80003a30 <iunlockput>
  return ip;
    80005258:	bfad                	j	800051d2 <create+0xac>
  ilock(ip);
    8000525a:	8526                	mv	a0,s1
    8000525c:	d82fe0ef          	jal	800037de <ilock>
  ip->major = major;
    80005260:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80005264:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005268:	4785                	li	a5,1
    8000526a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000526e:	8526                	mv	a0,s1
    80005270:	cbafe0ef          	jal	8000372a <iupdate>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005274:	40d0                	lw	a2,4(s1)
    80005276:	00003597          	auipc	a1,0x3
    8000527a:	54258593          	addi	a1,a1,1346 # 800087b8 <etext+0x7b8>
    8000527e:	8526                	mv	a0,s1
    80005280:	d39fe0ef          	jal	80003fb8 <dirlink>
    80005284:	f60541e3          	bltz	a0,800051e6 <create+0xc0>
    80005288:	004aa603          	lw	a2,4(s5)
    8000528c:	00003597          	auipc	a1,0x3
    80005290:	52458593          	addi	a1,a1,1316 # 800087b0 <etext+0x7b0>
    80005294:	8526                	mv	a0,s1
    80005296:	d23fe0ef          	jal	80003fb8 <dirlink>
    8000529a:	f40546e3          	bltz	a0,800051e6 <create+0xc0>
  if (dirlink(dp, name, ip->inum) < 0)
    8000529e:	40d0                	lw	a2,4(s1)
    800052a0:	fb040593          	addi	a1,s0,-80
    800052a4:	8556                	mv	a0,s5
    800052a6:	d13fe0ef          	jal	80003fb8 <dirlink>
    800052aa:	f2054ee3          	bltz	a0,800051e6 <create+0xc0>
    dp->nlink++; // for ".."
    800052ae:	04aad783          	lhu	a5,74(s5)
    800052b2:	2785                	addiw	a5,a5,1
    800052b4:	04fa9523          	sh	a5,74(s5)
    iupdate(dp);
    800052b8:	8556                	mv	a0,s5
    800052ba:	c70fe0ef          	jal	8000372a <iupdate>
    800052be:	bf51                	j	80005252 <create+0x12c>

00000000800052c0 <sys_dup>:
{
    800052c0:	7179                	addi	sp,sp,-48
    800052c2:	f406                	sd	ra,40(sp)
    800052c4:	f022                	sd	s0,32(sp)
    800052c6:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    800052c8:	fd840613          	addi	a2,s0,-40
    800052cc:	4581                	li	a1,0
    800052ce:	4501                	li	a0,0
    800052d0:	dc1ff0ef          	jal	80005090 <argfd>
    return -1;
    800052d4:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    800052d6:	02054363          	bltz	a0,800052fc <sys_dup+0x3c>
    800052da:	ec26                	sd	s1,24(sp)
    800052dc:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    800052de:	fd843903          	ld	s2,-40(s0)
    800052e2:	854a                	mv	a0,s2
    800052e4:	e05ff0ef          	jal	800050e8 <fdalloc>
    800052e8:	84aa                	mv	s1,a0
    return -1;
    800052ea:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    800052ec:	00054d63          	bltz	a0,80005306 <sys_dup+0x46>
  filedup(f);
    800052f0:	854a                	mv	a0,s2
    800052f2:	b9aff0ef          	jal	8000468c <filedup>
  return fd;
    800052f6:	87a6                	mv	a5,s1
    800052f8:	64e2                	ld	s1,24(sp)
    800052fa:	6942                	ld	s2,16(sp)
}
    800052fc:	853e                	mv	a0,a5
    800052fe:	70a2                	ld	ra,40(sp)
    80005300:	7402                	ld	s0,32(sp)
    80005302:	6145                	addi	sp,sp,48
    80005304:	8082                	ret
    80005306:	64e2                	ld	s1,24(sp)
    80005308:	6942                	ld	s2,16(sp)
    8000530a:	bfcd                	j	800052fc <sys_dup+0x3c>

000000008000530c <sys_read>:
{
    8000530c:	7179                	addi	sp,sp,-48
    8000530e:	f406                	sd	ra,40(sp)
    80005310:	f022                	sd	s0,32(sp)
    80005312:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005314:	fd840593          	addi	a1,s0,-40
    80005318:	4505                	li	a0,1
    8000531a:	fd2fd0ef          	jal	80002aec <argaddr>
  argint(2, &n);
    8000531e:	fe440593          	addi	a1,s0,-28
    80005322:	4509                	li	a0,2
    80005324:	facfd0ef          	jal	80002ad0 <argint>
  if (argfd(0, 0, &f) < 0)
    80005328:	fe840613          	addi	a2,s0,-24
    8000532c:	4581                	li	a1,0
    8000532e:	4501                	li	a0,0
    80005330:	d61ff0ef          	jal	80005090 <argfd>
    80005334:	87aa                	mv	a5,a0
    return -1;
    80005336:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005338:	0007ca63          	bltz	a5,8000534c <sys_read+0x40>
  return fileread(f, p, n);
    8000533c:	fe442603          	lw	a2,-28(s0)
    80005340:	fd843583          	ld	a1,-40(s0)
    80005344:	fe843503          	ld	a0,-24(s0)
    80005348:	caeff0ef          	jal	800047f6 <fileread>
}
    8000534c:	70a2                	ld	ra,40(sp)
    8000534e:	7402                	ld	s0,32(sp)
    80005350:	6145                	addi	sp,sp,48
    80005352:	8082                	ret

0000000080005354 <sys_write>:
{
    80005354:	7179                	addi	sp,sp,-48
    80005356:	f406                	sd	ra,40(sp)
    80005358:	f022                	sd	s0,32(sp)
    8000535a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000535c:	fd840593          	addi	a1,s0,-40
    80005360:	4505                	li	a0,1
    80005362:	f8afd0ef          	jal	80002aec <argaddr>
  argint(2, &n);
    80005366:	fe440593          	addi	a1,s0,-28
    8000536a:	4509                	li	a0,2
    8000536c:	f64fd0ef          	jal	80002ad0 <argint>
  if (argfd(0, 0, &f) < 0)
    80005370:	fe840613          	addi	a2,s0,-24
    80005374:	4581                	li	a1,0
    80005376:	4501                	li	a0,0
    80005378:	d19ff0ef          	jal	80005090 <argfd>
    8000537c:	87aa                	mv	a5,a0
    return -1;
    8000537e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005380:	0007ca63          	bltz	a5,80005394 <sys_write+0x40>
  return filewrite(f, p, n);
    80005384:	fe442603          	lw	a2,-28(s0)
    80005388:	fd843583          	ld	a1,-40(s0)
    8000538c:	fe843503          	ld	a0,-24(s0)
    80005390:	d30ff0ef          	jal	800048c0 <filewrite>
}
    80005394:	70a2                	ld	ra,40(sp)
    80005396:	7402                	ld	s0,32(sp)
    80005398:	6145                	addi	sp,sp,48
    8000539a:	8082                	ret

000000008000539c <sys_close>:
{
    8000539c:	1101                	addi	sp,sp,-32
    8000539e:	ec06                	sd	ra,24(sp)
    800053a0:	e822                	sd	s0,16(sp)
    800053a2:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800053a4:	fe040613          	addi	a2,s0,-32
    800053a8:	fec40593          	addi	a1,s0,-20
    800053ac:	4501                	li	a0,0
    800053ae:	ce3ff0ef          	jal	80005090 <argfd>
    return -1;
    800053b2:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    800053b4:	02054063          	bltz	a0,800053d4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800053b8:	ceafc0ef          	jal	800018a2 <myproc>
    800053bc:	fec42783          	lw	a5,-20(s0)
    800053c0:	07e9                	addi	a5,a5,26
    800053c2:	078e                	slli	a5,a5,0x3
    800053c4:	953e                	add	a0,a0,a5
    800053c6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800053ca:	fe043503          	ld	a0,-32(s0)
    800053ce:	b04ff0ef          	jal	800046d2 <fileclose>
  return 0;
    800053d2:	4781                	li	a5,0
}
    800053d4:	853e                	mv	a0,a5
    800053d6:	60e2                	ld	ra,24(sp)
    800053d8:	6442                	ld	s0,16(sp)
    800053da:	6105                	addi	sp,sp,32
    800053dc:	8082                	ret

00000000800053de <sys_fstat>:
{
    800053de:	1101                	addi	sp,sp,-32
    800053e0:	ec06                	sd	ra,24(sp)
    800053e2:	e822                	sd	s0,16(sp)
    800053e4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800053e6:	fe040593          	addi	a1,s0,-32
    800053ea:	4505                	li	a0,1
    800053ec:	f00fd0ef          	jal	80002aec <argaddr>
  if (argfd(0, 0, &f) < 0)
    800053f0:	fe840613          	addi	a2,s0,-24
    800053f4:	4581                	li	a1,0
    800053f6:	4501                	li	a0,0
    800053f8:	c99ff0ef          	jal	80005090 <argfd>
    800053fc:	87aa                	mv	a5,a0
    return -1;
    800053fe:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005400:	0007c863          	bltz	a5,80005410 <sys_fstat+0x32>
  return filestat(f, st);
    80005404:	fe043583          	ld	a1,-32(s0)
    80005408:	fe843503          	ld	a0,-24(s0)
    8000540c:	b88ff0ef          	jal	80004794 <filestat>
}
    80005410:	60e2                	ld	ra,24(sp)
    80005412:	6442                	ld	s0,16(sp)
    80005414:	6105                	addi	sp,sp,32
    80005416:	8082                	ret

0000000080005418 <sys_link>:
{
    80005418:	7169                	addi	sp,sp,-304
    8000541a:	f606                	sd	ra,296(sp)
    8000541c:	f222                	sd	s0,288(sp)
    8000541e:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005420:	08000613          	li	a2,128
    80005424:	ed040593          	addi	a1,s0,-304
    80005428:	4501                	li	a0,0
    8000542a:	edefd0ef          	jal	80002b08 <argstr>
    return -1;
    8000542e:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005430:	10054163          	bltz	a0,80005532 <sys_link+0x11a>
    80005434:	08000613          	li	a2,128
    80005438:	f5040593          	addi	a1,s0,-176
    8000543c:	4505                	li	a0,1
    8000543e:	ecafd0ef          	jal	80002b08 <argstr>
    return -1;
    80005442:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005444:	0e054763          	bltz	a0,80005532 <sys_link+0x11a>
    80005448:	ee26                	sd	s1,280(sp)
  begin_op();
    8000544a:	dddfe0ef          	jal	80004226 <begin_op>
  if ((ip = namei(old)) == 0) {
    8000544e:	ed040513          	addi	a0,s0,-304
    80005452:	c01fe0ef          	jal	80004052 <namei>
    80005456:	84aa                	mv	s1,a0
    80005458:	cd35                	beqz	a0,800054d4 <sys_link+0xbc>
  ilock(ip);
    8000545a:	b84fe0ef          	jal	800037de <ilock>
  if (ip->type == T_DIR) {
    8000545e:	04449703          	lh	a4,68(s1)
    80005462:	4785                	li	a5,1
    80005464:	06f70d63          	beq	a4,a5,800054de <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80005468:	04a49783          	lh	a5,74(s1)
    8000546c:	6721                	lui	a4,0x8
    8000546e:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005470:	06e78f63          	beq	a5,a4,800054ee <sys_link+0xd6>
    80005474:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005476:	2785                	addiw	a5,a5,1
    80005478:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000547c:	8526                	mv	a0,s1
    8000547e:	aacfe0ef          	jal	8000372a <iupdate>
  iunlock(ip);
    80005482:	8526                	mv	a0,s1
    80005484:	c08fe0ef          	jal	8000388c <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005488:	fd040593          	addi	a1,s0,-48
    8000548c:	f5040513          	addi	a0,s0,-176
    80005490:	bddfe0ef          	jal	8000406c <nameiparent>
    80005494:	892a                	mv	s2,a0
    80005496:	c93d                	beqz	a0,8000550c <sys_link+0xf4>
  ilock(dp);
    80005498:	b46fe0ef          	jal	800037de <ilock>
  if (dp->nlink == 0) {
    8000549c:	04a91783          	lh	a5,74(s2)
    800054a0:	cfb9                	beqz	a5,800054fe <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800054a2:	00092703          	lw	a4,0(s2)
    800054a6:	409c                	lw	a5,0(s1)
    800054a8:	04f71f63          	bne	a4,a5,80005506 <sys_link+0xee>
    800054ac:	40d0                	lw	a2,4(s1)
    800054ae:	fd040593          	addi	a1,s0,-48
    800054b2:	854a                	mv	a0,s2
    800054b4:	b05fe0ef          	jal	80003fb8 <dirlink>
    800054b8:	04054763          	bltz	a0,80005506 <sys_link+0xee>
  iunlockput(dp);
    800054bc:	854a                	mv	a0,s2
    800054be:	d72fe0ef          	jal	80003a30 <iunlockput>
  iput(ip);
    800054c2:	8526                	mv	a0,s1
    800054c4:	c9cfe0ef          	jal	80003960 <iput>
  end_op();
    800054c8:	de5fe0ef          	jal	800042ac <end_op>
  return 0;
    800054cc:	4781                	li	a5,0
    800054ce:	64f2                	ld	s1,280(sp)
    800054d0:	6952                	ld	s2,272(sp)
    800054d2:	a085                	j	80005532 <sys_link+0x11a>
    end_op();
    800054d4:	dd9fe0ef          	jal	800042ac <end_op>
    return -1;
    800054d8:	57fd                	li	a5,-1
    800054da:	64f2                	ld	s1,280(sp)
    800054dc:	a899                	j	80005532 <sys_link+0x11a>
    iunlockput(ip);
    800054de:	8526                	mv	a0,s1
    800054e0:	d50fe0ef          	jal	80003a30 <iunlockput>
    end_op();
    800054e4:	dc9fe0ef          	jal	800042ac <end_op>
    return -1;
    800054e8:	57fd                	li	a5,-1
    800054ea:	64f2                	ld	s1,280(sp)
    800054ec:	a099                	j	80005532 <sys_link+0x11a>
    iunlockput(ip);
    800054ee:	8526                	mv	a0,s1
    800054f0:	d40fe0ef          	jal	80003a30 <iunlockput>
    end_op();
    800054f4:	db9fe0ef          	jal	800042ac <end_op>
    return -1;
    800054f8:	57fd                	li	a5,-1
    800054fa:	64f2                	ld	s1,280(sp)
    800054fc:	a81d                	j	80005532 <sys_link+0x11a>
    iunlockput(dp);
    800054fe:	854a                	mv	a0,s2
    80005500:	d30fe0ef          	jal	80003a30 <iunlockput>
    goto bad;
    80005504:	a021                	j	8000550c <sys_link+0xf4>
    iunlockput(dp);
    80005506:	854a                	mv	a0,s2
    80005508:	d28fe0ef          	jal	80003a30 <iunlockput>
  ilock(ip);
    8000550c:	8526                	mv	a0,s1
    8000550e:	ad0fe0ef          	jal	800037de <ilock>
  ip->nlink--;
    80005512:	04a4d783          	lhu	a5,74(s1)
    80005516:	37fd                	addiw	a5,a5,-1
    80005518:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000551c:	8526                	mv	a0,s1
    8000551e:	a0cfe0ef          	jal	8000372a <iupdate>
  iunlockput(ip);
    80005522:	8526                	mv	a0,s1
    80005524:	d0cfe0ef          	jal	80003a30 <iunlockput>
  end_op();
    80005528:	d85fe0ef          	jal	800042ac <end_op>
  return -1;
    8000552c:	57fd                	li	a5,-1
    8000552e:	64f2                	ld	s1,280(sp)
    80005530:	6952                	ld	s2,272(sp)
}
    80005532:	853e                	mv	a0,a5
    80005534:	70b2                	ld	ra,296(sp)
    80005536:	7412                	ld	s0,288(sp)
    80005538:	6155                	addi	sp,sp,304
    8000553a:	8082                	ret

000000008000553c <sys_unlink>:
{
    8000553c:	7151                	addi	sp,sp,-240
    8000553e:	f586                	sd	ra,232(sp)
    80005540:	f1a2                	sd	s0,224(sp)
    80005542:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005544:	08000613          	li	a2,128
    80005548:	f3040593          	addi	a1,s0,-208
    8000554c:	4501                	li	a0,0
    8000554e:	dbafd0ef          	jal	80002b08 <argstr>
    80005552:	16054063          	bltz	a0,800056b2 <sys_unlink+0x176>
    80005556:	eda6                	sd	s1,216(sp)
  begin_op();
    80005558:	ccffe0ef          	jal	80004226 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    8000555c:	fb040593          	addi	a1,s0,-80
    80005560:	f3040513          	addi	a0,s0,-208
    80005564:	b09fe0ef          	jal	8000406c <nameiparent>
    80005568:	84aa                	mv	s1,a0
    8000556a:	c945                	beqz	a0,8000561a <sys_unlink+0xde>
  ilock(dp);
    8000556c:	a72fe0ef          	jal	800037de <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005570:	00003597          	auipc	a1,0x3
    80005574:	24858593          	addi	a1,a1,584 # 800087b8 <etext+0x7b8>
    80005578:	fb040513          	addi	a0,s0,-80
    8000557c:	84bfe0ef          	jal	80003dc6 <namecmp>
    80005580:	10050e63          	beqz	a0,8000569c <sys_unlink+0x160>
    80005584:	00003597          	auipc	a1,0x3
    80005588:	22c58593          	addi	a1,a1,556 # 800087b0 <etext+0x7b0>
    8000558c:	fb040513          	addi	a0,s0,-80
    80005590:	837fe0ef          	jal	80003dc6 <namecmp>
    80005594:	10050463          	beqz	a0,8000569c <sys_unlink+0x160>
    80005598:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    8000559a:	f2c40613          	addi	a2,s0,-212
    8000559e:	fb040593          	addi	a1,s0,-80
    800055a2:	8526                	mv	a0,s1
    800055a4:	839fe0ef          	jal	80003ddc <dirlookup>
    800055a8:	892a                	mv	s2,a0
    800055aa:	0e050863          	beqz	a0,8000569a <sys_unlink+0x15e>
  ilock(ip);
    800055ae:	a30fe0ef          	jal	800037de <ilock>
  if (ip->nlink < 1)
    800055b2:	04a91783          	lh	a5,74(s2)
    800055b6:	06f05763          	blez	a5,80005624 <sys_unlink+0xe8>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800055ba:	04491703          	lh	a4,68(s2)
    800055be:	4785                	li	a5,1
    800055c0:	06f70963          	beq	a4,a5,80005632 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800055c4:	4641                	li	a2,16
    800055c6:	4581                	li	a1,0
    800055c8:	fc040513          	addi	a0,s0,-64
    800055cc:	e88fb0ef          	jal	80000c54 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055d0:	4741                	li	a4,16
    800055d2:	f2c42683          	lw	a3,-212(s0)
    800055d6:	fc040613          	addi	a2,s0,-64
    800055da:	4581                	li	a1,0
    800055dc:	8526                	mv	a0,s1
    800055de:	ed4fe0ef          	jal	80003cb2 <writei>
    800055e2:	47c1                	li	a5,16
    800055e4:	08f51b63          	bne	a0,a5,8000567a <sys_unlink+0x13e>
  if (ip->type == T_DIR) {
    800055e8:	04491703          	lh	a4,68(s2)
    800055ec:	4785                	li	a5,1
    800055ee:	08f70d63          	beq	a4,a5,80005688 <sys_unlink+0x14c>
  iunlockput(dp);
    800055f2:	8526                	mv	a0,s1
    800055f4:	c3cfe0ef          	jal	80003a30 <iunlockput>
  ip->nlink--;
    800055f8:	04a95783          	lhu	a5,74(s2)
    800055fc:	37fd                	addiw	a5,a5,-1
    800055fe:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005602:	854a                	mv	a0,s2
    80005604:	926fe0ef          	jal	8000372a <iupdate>
  iunlockput(ip);
    80005608:	854a                	mv	a0,s2
    8000560a:	c26fe0ef          	jal	80003a30 <iunlockput>
  end_op();
    8000560e:	c9ffe0ef          	jal	800042ac <end_op>
  return 0;
    80005612:	4501                	li	a0,0
    80005614:	64ee                	ld	s1,216(sp)
    80005616:	694e                	ld	s2,208(sp)
    80005618:	a849                	j	800056aa <sys_unlink+0x16e>
    end_op();
    8000561a:	c93fe0ef          	jal	800042ac <end_op>
    return -1;
    8000561e:	557d                	li	a0,-1
    80005620:	64ee                	ld	s1,216(sp)
    80005622:	a061                	j	800056aa <sys_unlink+0x16e>
    80005624:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005626:	00003517          	auipc	a0,0x3
    8000562a:	19a50513          	addi	a0,a0,410 # 800087c0 <etext+0x7c0>
    8000562e:	9c2fb0ef          	jal	800007f0 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005632:	04c92703          	lw	a4,76(s2)
    80005636:	02000793          	li	a5,32
    8000563a:	f8e7f5e3          	bgeu	a5,a4,800055c4 <sys_unlink+0x88>
    8000563e:	e5ce                	sd	s3,200(sp)
    80005640:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005644:	4741                	li	a4,16
    80005646:	86ce                	mv	a3,s3
    80005648:	f1840613          	addi	a2,s0,-232
    8000564c:	4581                	li	a1,0
    8000564e:	854a                	mv	a0,s2
    80005650:	d66fe0ef          	jal	80003bb6 <readi>
    80005654:	47c1                	li	a5,16
    80005656:	00f51c63          	bne	a0,a5,8000566e <sys_unlink+0x132>
    if (de.inum != 0)
    8000565a:	f1845783          	lhu	a5,-232(s0)
    8000565e:	efa1                	bnez	a5,800056b6 <sys_unlink+0x17a>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005660:	29c1                	addiw	s3,s3,16
    80005662:	04c92783          	lw	a5,76(s2)
    80005666:	fcf9efe3          	bltu	s3,a5,80005644 <sys_unlink+0x108>
    8000566a:	69ae                	ld	s3,200(sp)
    8000566c:	bfa1                	j	800055c4 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000566e:	00003517          	auipc	a0,0x3
    80005672:	16a50513          	addi	a0,a0,362 # 800087d8 <etext+0x7d8>
    80005676:	97afb0ef          	jal	800007f0 <panic>
    8000567a:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000567c:	00003517          	auipc	a0,0x3
    80005680:	17450513          	addi	a0,a0,372 # 800087f0 <etext+0x7f0>
    80005684:	96cfb0ef          	jal	800007f0 <panic>
    dp->nlink--;
    80005688:	04a4d783          	lhu	a5,74(s1)
    8000568c:	37fd                	addiw	a5,a5,-1
    8000568e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005692:	8526                	mv	a0,s1
    80005694:	896fe0ef          	jal	8000372a <iupdate>
    80005698:	bfa9                	j	800055f2 <sys_unlink+0xb6>
    8000569a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000569c:	8526                	mv	a0,s1
    8000569e:	b92fe0ef          	jal	80003a30 <iunlockput>
  end_op();
    800056a2:	c0bfe0ef          	jal	800042ac <end_op>
  return -1;
    800056a6:	557d                	li	a0,-1
    800056a8:	64ee                	ld	s1,216(sp)
}
    800056aa:	70ae                	ld	ra,232(sp)
    800056ac:	740e                	ld	s0,224(sp)
    800056ae:	616d                	addi	sp,sp,240
    800056b0:	8082                	ret
    return -1;
    800056b2:	557d                	li	a0,-1
    800056b4:	bfdd                	j	800056aa <sys_unlink+0x16e>
    iunlockput(ip);
    800056b6:	854a                	mv	a0,s2
    800056b8:	b78fe0ef          	jal	80003a30 <iunlockput>
    goto bad;
    800056bc:	694e                	ld	s2,208(sp)
    800056be:	69ae                	ld	s3,200(sp)
    800056c0:	bff1                	j	8000569c <sys_unlink+0x160>

00000000800056c2 <sys_open>:

uint64
sys_open(void)
{
    800056c2:	7131                	addi	sp,sp,-192
    800056c4:	fd06                	sd	ra,184(sp)
    800056c6:	f922                	sd	s0,176(sp)
    800056c8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800056ca:	f4c40593          	addi	a1,s0,-180
    800056ce:	4505                	li	a0,1
    800056d0:	c00fd0ef          	jal	80002ad0 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800056d4:	08000613          	li	a2,128
    800056d8:	f5040593          	addi	a1,s0,-176
    800056dc:	4501                	li	a0,0
    800056de:	c2afd0ef          	jal	80002b08 <argstr>
    800056e2:	87aa                	mv	a5,a0
    return -1;
    800056e4:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800056e6:	0a07c263          	bltz	a5,8000578a <sys_open+0xc8>
    800056ea:	f526                	sd	s1,168(sp)

  begin_op();
    800056ec:	b3bfe0ef          	jal	80004226 <begin_op>

  if (omode & O_CREATE) {
    800056f0:	f4c42783          	lw	a5,-180(s0)
    800056f4:	2007f793          	andi	a5,a5,512
    800056f8:	c3d5                	beqz	a5,8000579c <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800056fa:	4681                	li	a3,0
    800056fc:	4601                	li	a2,0
    800056fe:	4589                	li	a1,2
    80005700:	f5040513          	addi	a0,s0,-176
    80005704:	a23ff0ef          	jal	80005126 <create>
    80005708:	84aa                	mv	s1,a0
    if (ip == 0) {
    8000570a:	c541                	beqz	a0,80005792 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    8000570c:	04449703          	lh	a4,68(s1)
    80005710:	478d                	li	a5,3
    80005712:	00f71763          	bne	a4,a5,80005720 <sys_open+0x5e>
    80005716:	0464d703          	lhu	a4,70(s1)
    8000571a:	47a5                	li	a5,9
    8000571c:	0ae7ed63          	bltu	a5,a4,800057d6 <sys_open+0x114>
    80005720:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005722:	f0dfe0ef          	jal	8000462e <filealloc>
    80005726:	892a                	mv	s2,a0
    80005728:	c179                	beqz	a0,800057ee <sys_open+0x12c>
    8000572a:	ed4e                	sd	s3,152(sp)
    8000572c:	9bdff0ef          	jal	800050e8 <fdalloc>
    80005730:	89aa                	mv	s3,a0
    80005732:	0a054a63          	bltz	a0,800057e6 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005736:	04449703          	lh	a4,68(s1)
    8000573a:	478d                	li	a5,3
    8000573c:	0cf70263          	beq	a4,a5,80005800 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005740:	4789                	li	a5,2
    80005742:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005746:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000574a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000574e:	f4c42783          	lw	a5,-180(s0)
    80005752:	0017c713          	xori	a4,a5,1
    80005756:	8b05                	andi	a4,a4,1
    80005758:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000575c:	0037f713          	andi	a4,a5,3
    80005760:	00e03733          	snez	a4,a4
    80005764:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005768:	4007f793          	andi	a5,a5,1024
    8000576c:	c791                	beqz	a5,80005778 <sys_open+0xb6>
    8000576e:	04449703          	lh	a4,68(s1)
    80005772:	4789                	li	a5,2
    80005774:	08f70d63          	beq	a4,a5,8000580e <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005778:	8526                	mv	a0,s1
    8000577a:	912fe0ef          	jal	8000388c <iunlock>
  end_op();
    8000577e:	b2ffe0ef          	jal	800042ac <end_op>

  return fd;
    80005782:	854e                	mv	a0,s3
    80005784:	74aa                	ld	s1,168(sp)
    80005786:	790a                	ld	s2,160(sp)
    80005788:	69ea                	ld	s3,152(sp)
}
    8000578a:	70ea                	ld	ra,184(sp)
    8000578c:	744a                	ld	s0,176(sp)
    8000578e:	6129                	addi	sp,sp,192
    80005790:	8082                	ret
      end_op();
    80005792:	b1bfe0ef          	jal	800042ac <end_op>
      return -1;
    80005796:	557d                	li	a0,-1
    80005798:	74aa                	ld	s1,168(sp)
    8000579a:	bfc5                	j	8000578a <sys_open+0xc8>
    if ((ip = namei(path)) == 0) {
    8000579c:	f5040513          	addi	a0,s0,-176
    800057a0:	8b3fe0ef          	jal	80004052 <namei>
    800057a4:	84aa                	mv	s1,a0
    800057a6:	c11d                	beqz	a0,800057cc <sys_open+0x10a>
    ilock(ip);
    800057a8:	836fe0ef          	jal	800037de <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800057ac:	04449703          	lh	a4,68(s1)
    800057b0:	4785                	li	a5,1
    800057b2:	f4f71de3          	bne	a4,a5,8000570c <sys_open+0x4a>
    800057b6:	f4c42783          	lw	a5,-180(s0)
    800057ba:	d3bd                	beqz	a5,80005720 <sys_open+0x5e>
      iunlockput(ip);
    800057bc:	8526                	mv	a0,s1
    800057be:	a72fe0ef          	jal	80003a30 <iunlockput>
      end_op();
    800057c2:	aebfe0ef          	jal	800042ac <end_op>
      return -1;
    800057c6:	557d                	li	a0,-1
    800057c8:	74aa                	ld	s1,168(sp)
    800057ca:	b7c1                	j	8000578a <sys_open+0xc8>
      end_op();
    800057cc:	ae1fe0ef          	jal	800042ac <end_op>
      return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	74aa                	ld	s1,168(sp)
    800057d4:	bf5d                	j	8000578a <sys_open+0xc8>
    iunlockput(ip);
    800057d6:	8526                	mv	a0,s1
    800057d8:	a58fe0ef          	jal	80003a30 <iunlockput>
    end_op();
    800057dc:	ad1fe0ef          	jal	800042ac <end_op>
    return -1;
    800057e0:	557d                	li	a0,-1
    800057e2:	74aa                	ld	s1,168(sp)
    800057e4:	b75d                	j	8000578a <sys_open+0xc8>
      fileclose(f);
    800057e6:	854a                	mv	a0,s2
    800057e8:	eebfe0ef          	jal	800046d2 <fileclose>
    800057ec:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800057ee:	8526                	mv	a0,s1
    800057f0:	a40fe0ef          	jal	80003a30 <iunlockput>
    end_op();
    800057f4:	ab9fe0ef          	jal	800042ac <end_op>
    return -1;
    800057f8:	557d                	li	a0,-1
    800057fa:	74aa                	ld	s1,168(sp)
    800057fc:	790a                	ld	s2,160(sp)
    800057fe:	b771                	j	8000578a <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005800:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005804:	04649783          	lh	a5,70(s1)
    80005808:	02f91223          	sh	a5,36(s2)
    8000580c:	bf3d                	j	8000574a <sys_open+0x88>
    itrunc(ip);
    8000580e:	8526                	mv	a0,s1
    80005810:	8bcfe0ef          	jal	800038cc <itrunc>
    80005814:	b795                	j	80005778 <sys_open+0xb6>

0000000080005816 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005816:	7175                	addi	sp,sp,-144
    80005818:	e506                	sd	ra,136(sp)
    8000581a:	e122                	sd	s0,128(sp)
    8000581c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000581e:	a09fe0ef          	jal	80004226 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005822:	08000613          	li	a2,128
    80005826:	f7040593          	addi	a1,s0,-144
    8000582a:	4501                	li	a0,0
    8000582c:	adcfd0ef          	jal	80002b08 <argstr>
    80005830:	02054363          	bltz	a0,80005856 <sys_mkdir+0x40>
    80005834:	4681                	li	a3,0
    80005836:	4601                	li	a2,0
    80005838:	4585                	li	a1,1
    8000583a:	f7040513          	addi	a0,s0,-144
    8000583e:	8e9ff0ef          	jal	80005126 <create>
    80005842:	c911                	beqz	a0,80005856 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005844:	9ecfe0ef          	jal	80003a30 <iunlockput>
  end_op();
    80005848:	a65fe0ef          	jal	800042ac <end_op>
  return 0;
    8000584c:	4501                	li	a0,0
}
    8000584e:	60aa                	ld	ra,136(sp)
    80005850:	640a                	ld	s0,128(sp)
    80005852:	6149                	addi	sp,sp,144
    80005854:	8082                	ret
    end_op();
    80005856:	a57fe0ef          	jal	800042ac <end_op>
    return -1;
    8000585a:	557d                	li	a0,-1
    8000585c:	bfcd                	j	8000584e <sys_mkdir+0x38>

000000008000585e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000585e:	7135                	addi	sp,sp,-160
    80005860:	ed06                	sd	ra,152(sp)
    80005862:	e922                	sd	s0,144(sp)
    80005864:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005866:	9c1fe0ef          	jal	80004226 <begin_op>
  argint(1, &major);
    8000586a:	f6c40593          	addi	a1,s0,-148
    8000586e:	4505                	li	a0,1
    80005870:	a60fd0ef          	jal	80002ad0 <argint>
  argint(2, &minor);
    80005874:	f6840593          	addi	a1,s0,-152
    80005878:	4509                	li	a0,2
    8000587a:	a56fd0ef          	jal	80002ad0 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000587e:	08000613          	li	a2,128
    80005882:	f7040593          	addi	a1,s0,-144
    80005886:	4501                	li	a0,0
    80005888:	a80fd0ef          	jal	80002b08 <argstr>
    8000588c:	02054563          	bltz	a0,800058b6 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    80005890:	f6841683          	lh	a3,-152(s0)
    80005894:	f6c41603          	lh	a2,-148(s0)
    80005898:	458d                	li	a1,3
    8000589a:	f7040513          	addi	a0,s0,-144
    8000589e:	889ff0ef          	jal	80005126 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800058a2:	c911                	beqz	a0,800058b6 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058a4:	98cfe0ef          	jal	80003a30 <iunlockput>
  end_op();
    800058a8:	a05fe0ef          	jal	800042ac <end_op>
  return 0;
    800058ac:	4501                	li	a0,0
}
    800058ae:	60ea                	ld	ra,152(sp)
    800058b0:	644a                	ld	s0,144(sp)
    800058b2:	610d                	addi	sp,sp,160
    800058b4:	8082                	ret
    end_op();
    800058b6:	9f7fe0ef          	jal	800042ac <end_op>
    return -1;
    800058ba:	557d                	li	a0,-1
    800058bc:	bfcd                	j	800058ae <sys_mknod+0x50>

00000000800058be <sys_chdir>:

uint64
sys_chdir(void)
{
    800058be:	7135                	addi	sp,sp,-160
    800058c0:	ed06                	sd	ra,152(sp)
    800058c2:	e922                	sd	s0,144(sp)
    800058c4:	e14a                	sd	s2,128(sp)
    800058c6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058c8:	fdbfb0ef          	jal	800018a2 <myproc>
    800058cc:	892a                	mv	s2,a0

  begin_op();
    800058ce:	959fe0ef          	jal	80004226 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800058d2:	08000613          	li	a2,128
    800058d6:	f6040593          	addi	a1,s0,-160
    800058da:	4501                	li	a0,0
    800058dc:	a2cfd0ef          	jal	80002b08 <argstr>
    800058e0:	04054363          	bltz	a0,80005926 <sys_chdir+0x68>
    800058e4:	e526                	sd	s1,136(sp)
    800058e6:	f6040513          	addi	a0,s0,-160
    800058ea:	f68fe0ef          	jal	80004052 <namei>
    800058ee:	84aa                	mv	s1,a0
    800058f0:	c915                	beqz	a0,80005924 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800058f2:	eedfd0ef          	jal	800037de <ilock>
  if (ip->type != T_DIR) {
    800058f6:	04449703          	lh	a4,68(s1)
    800058fa:	4785                	li	a5,1
    800058fc:	02f71963          	bne	a4,a5,8000592e <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005900:	8526                	mv	a0,s1
    80005902:	f8bfd0ef          	jal	8000388c <iunlock>
  iput(p->cwd);
    80005906:	15093503          	ld	a0,336(s2)
    8000590a:	856fe0ef          	jal	80003960 <iput>
  end_op();
    8000590e:	99ffe0ef          	jal	800042ac <end_op>
  p->cwd = ip;
    80005912:	14993823          	sd	s1,336(s2)
  return 0;
    80005916:	4501                	li	a0,0
    80005918:	64aa                	ld	s1,136(sp)
}
    8000591a:	60ea                	ld	ra,152(sp)
    8000591c:	644a                	ld	s0,144(sp)
    8000591e:	690a                	ld	s2,128(sp)
    80005920:	610d                	addi	sp,sp,160
    80005922:	8082                	ret
    80005924:	64aa                	ld	s1,136(sp)
    end_op();
    80005926:	987fe0ef          	jal	800042ac <end_op>
    return -1;
    8000592a:	557d                	li	a0,-1
    8000592c:	b7fd                	j	8000591a <sys_chdir+0x5c>
    iunlockput(ip);
    8000592e:	8526                	mv	a0,s1
    80005930:	900fe0ef          	jal	80003a30 <iunlockput>
    end_op();
    80005934:	979fe0ef          	jal	800042ac <end_op>
    return -1;
    80005938:	557d                	li	a0,-1
    8000593a:	64aa                	ld	s1,136(sp)
    8000593c:	bff9                	j	8000591a <sys_chdir+0x5c>

000000008000593e <sys_exec>:

uint64
sys_exec(void)
{
    8000593e:	7121                	addi	sp,sp,-448
    80005940:	ff06                	sd	ra,440(sp)
    80005942:	fb22                	sd	s0,432(sp)
    80005944:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005946:	e4840593          	addi	a1,s0,-440
    8000594a:	4505                	li	a0,1
    8000594c:	9a0fd0ef          	jal	80002aec <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005950:	08000613          	li	a2,128
    80005954:	f5040593          	addi	a1,s0,-176
    80005958:	4501                	li	a0,0
    8000595a:	9aefd0ef          	jal	80002b08 <argstr>
    8000595e:	87aa                	mv	a5,a0
    return -1;
    80005960:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005962:	0c07c463          	bltz	a5,80005a2a <sys_exec+0xec>
    80005966:	f726                	sd	s1,424(sp)
    80005968:	f34a                	sd	s2,416(sp)
    8000596a:	ef4e                	sd	s3,408(sp)
    8000596c:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000596e:	10000613          	li	a2,256
    80005972:	4581                	li	a1,0
    80005974:	e5040513          	addi	a0,s0,-432
    80005978:	adcfb0ef          	jal	80000c54 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    8000597c:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005980:	89a6                	mv	s3,s1
    80005982:	4901                	li	s2,0
    if (i >= NELEM(argv)) {
    80005984:	02000a13          	li	s4,32
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005988:	00391513          	slli	a0,s2,0x3
    8000598c:	e4040593          	addi	a1,s0,-448
    80005990:	e4843783          	ld	a5,-440(s0)
    80005994:	953e                	add	a0,a0,a5
    80005996:	8aefd0ef          	jal	80002a44 <fetchaddr>
    8000599a:	02054663          	bltz	a0,800059c6 <sys_exec+0x88>
      goto bad;
    }
    if (uarg == 0) {
    8000599e:	e4043783          	ld	a5,-448(s0)
    800059a2:	c3a9                	beqz	a5,800059e4 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800059a4:	926fb0ef          	jal	80000aca <kalloc>
    800059a8:	85aa                	mv	a1,a0
    800059aa:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800059ae:	cd01                	beqz	a0,800059c6 <sys_exec+0x88>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800059b0:	6605                	lui	a2,0x1
    800059b2:	e4043503          	ld	a0,-448(s0)
    800059b6:	8d8fd0ef          	jal	80002a8e <fetchstr>
    800059ba:	00054663          	bltz	a0,800059c6 <sys_exec+0x88>
    if (i >= NELEM(argv)) {
    800059be:	0905                	addi	s2,s2,1
    800059c0:	09a1                	addi	s3,s3,8
    800059c2:	fd4913e3          	bne	s2,s4,80005988 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059c6:	f5040913          	addi	s2,s0,-176
    800059ca:	6088                	ld	a0,0(s1)
    800059cc:	c931                	beqz	a0,80005a20 <sys_exec+0xe2>
    kfree(argv[i]);
    800059ce:	81afb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059d2:	04a1                	addi	s1,s1,8
    800059d4:	ff249be3          	bne	s1,s2,800059ca <sys_exec+0x8c>
  return -1;
    800059d8:	557d                	li	a0,-1
    800059da:	74ba                	ld	s1,424(sp)
    800059dc:	791a                	ld	s2,416(sp)
    800059de:	69fa                	ld	s3,408(sp)
    800059e0:	6a5a                	ld	s4,400(sp)
    800059e2:	a0a1                	j	80005a2a <sys_exec+0xec>
      argv[i] = 0;
    800059e4:	0009079b          	sext.w	a5,s2
    800059e8:	078e                	slli	a5,a5,0x3
    800059ea:	fd078793          	addi	a5,a5,-48
    800059ee:	97a2                	add	a5,a5,s0
    800059f0:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800059f4:	e5040593          	addi	a1,s0,-432
    800059f8:	f5040513          	addi	a0,s0,-176
    800059fc:	b26ff0ef          	jal	80004d22 <kexec>
    80005a00:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a02:	f5040993          	addi	s3,s0,-176
    80005a06:	6088                	ld	a0,0(s1)
    80005a08:	c511                	beqz	a0,80005a14 <sys_exec+0xd6>
    kfree(argv[i]);
    80005a0a:	fdffa0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a0e:	04a1                	addi	s1,s1,8
    80005a10:	ff349be3          	bne	s1,s3,80005a06 <sys_exec+0xc8>
  return ret;
    80005a14:	854a                	mv	a0,s2
    80005a16:	74ba                	ld	s1,424(sp)
    80005a18:	791a                	ld	s2,416(sp)
    80005a1a:	69fa                	ld	s3,408(sp)
    80005a1c:	6a5a                	ld	s4,400(sp)
    80005a1e:	a031                	j	80005a2a <sys_exec+0xec>
  return -1;
    80005a20:	557d                	li	a0,-1
    80005a22:	74ba                	ld	s1,424(sp)
    80005a24:	791a                	ld	s2,416(sp)
    80005a26:	69fa                	ld	s3,408(sp)
    80005a28:	6a5a                	ld	s4,400(sp)
}
    80005a2a:	70fa                	ld	ra,440(sp)
    80005a2c:	745a                	ld	s0,432(sp)
    80005a2e:	6139                	addi	sp,sp,448
    80005a30:	8082                	ret

0000000080005a32 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a32:	7139                	addi	sp,sp,-64
    80005a34:	fc06                	sd	ra,56(sp)
    80005a36:	f822                	sd	s0,48(sp)
    80005a38:	f426                	sd	s1,40(sp)
    80005a3a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a3c:	e67fb0ef          	jal	800018a2 <myproc>
    80005a40:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a42:	fd840593          	addi	a1,s0,-40
    80005a46:	4501                	li	a0,0
    80005a48:	8a4fd0ef          	jal	80002aec <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005a4c:	fc840593          	addi	a1,s0,-56
    80005a50:	fd040513          	addi	a0,s0,-48
    80005a54:	f9ffe0ef          	jal	800049f2 <pipealloc>
    return -1;
    80005a58:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005a5a:	0a054663          	bltz	a0,80005b06 <sys_pipe+0xd4>
  fd0 = -1;
    80005a5e:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005a62:	fd043503          	ld	a0,-48(s0)
    80005a66:	e82ff0ef          	jal	800050e8 <fdalloc>
    80005a6a:	fca42223          	sw	a0,-60(s0)
    80005a6e:	08054363          	bltz	a0,80005af4 <sys_pipe+0xc2>
    80005a72:	fc843503          	ld	a0,-56(s0)
    80005a76:	e72ff0ef          	jal	800050e8 <fdalloc>
    80005a7a:	fca42023          	sw	a0,-64(s0)
    80005a7e:	06054263          	bltz	a0,80005ae2 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005a82:	4711                	li	a4,4
    80005a84:	fc440693          	addi	a3,s0,-60
    80005a88:	fd843603          	ld	a2,-40(s0)
    80005a8c:	64ac                	ld	a1,72(s1)
    80005a8e:	68a8                	ld	a0,80(s1)
    80005a90:	a49fb0ef          	jal	800014d8 <copyout>
    80005a94:	00054f63          	bltz	a0,80005ab2 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005a98:	4711                	li	a4,4
    80005a9a:	fc040693          	addi	a3,s0,-64
    80005a9e:	fd843603          	ld	a2,-40(s0)
    80005aa2:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005aa4:	64ac                	ld	a1,72(s1)
    80005aa6:	68a8                	ld	a0,80(s1)
    80005aa8:	a31fb0ef          	jal	800014d8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005aac:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005aae:	04055c63          	bgez	a0,80005b06 <sys_pipe+0xd4>
    p->ofile[fd0] = 0;
    80005ab2:	fc442783          	lw	a5,-60(s0)
    80005ab6:	07e9                	addi	a5,a5,26
    80005ab8:	078e                	slli	a5,a5,0x3
    80005aba:	97a6                	add	a5,a5,s1
    80005abc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ac0:	fc042783          	lw	a5,-64(s0)
    80005ac4:	07e9                	addi	a5,a5,26
    80005ac6:	078e                	slli	a5,a5,0x3
    80005ac8:	94be                	add	s1,s1,a5
    80005aca:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ace:	fd043503          	ld	a0,-48(s0)
    80005ad2:	c01fe0ef          	jal	800046d2 <fileclose>
    fileclose(wf);
    80005ad6:	fc843503          	ld	a0,-56(s0)
    80005ada:	bf9fe0ef          	jal	800046d2 <fileclose>
    return -1;
    80005ade:	57fd                	li	a5,-1
    80005ae0:	a01d                	j	80005b06 <sys_pipe+0xd4>
    if (fd0 >= 0)
    80005ae2:	fc442783          	lw	a5,-60(s0)
    80005ae6:	0007c763          	bltz	a5,80005af4 <sys_pipe+0xc2>
      p->ofile[fd0] = 0;
    80005aea:	07e9                	addi	a5,a5,26
    80005aec:	078e                	slli	a5,a5,0x3
    80005aee:	97a6                	add	a5,a5,s1
    80005af0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005af4:	fd043503          	ld	a0,-48(s0)
    80005af8:	bdbfe0ef          	jal	800046d2 <fileclose>
    fileclose(wf);
    80005afc:	fc843503          	ld	a0,-56(s0)
    80005b00:	bd3fe0ef          	jal	800046d2 <fileclose>
    return -1;
    80005b04:	57fd                	li	a5,-1
}
    80005b06:	853e                	mv	a0,a5
    80005b08:	70e2                	ld	ra,56(sp)
    80005b0a:	7442                	ld	s0,48(sp)
    80005b0c:	74a2                	ld	s1,40(sp)
    80005b0e:	6121                	addi	sp,sp,64
    80005b10:	8082                	ret
	...

0000000080005b20 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005b20:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005b22:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005b24:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005b26:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005b28:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005b2a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005b2c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005b2e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005b30:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005b32:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005b34:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005b36:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005b38:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005b3a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005b3c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005b3e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005b40:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005b42:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005b44:	e11fc0ef          	jal	80002954 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005b48:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005b4a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005b4c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005b4e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005b50:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005b52:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005b54:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005b56:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005b58:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005b5a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005b5c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005b5e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005b60:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005b62:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005b64:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005b66:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005b68:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005b6a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005b6c:	10200073          	sret
	...

0000000080005b7e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b7e:	1141                	addi	sp,sp,-16
    80005b80:	e422                	sd	s0,8(sp)
    80005b82:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005b84:	0c0007b7          	lui	a5,0xc000
    80005b88:	4705                	li	a4,1
    80005b8a:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80005b8c:	0c0007b7          	lui	a5,0xc000
    80005b90:	c3d8                	sw	a4,4(a5)
}
    80005b92:	6422                	ld	s0,8(sp)
    80005b94:	0141                	addi	sp,sp,16
    80005b96:	8082                	ret

0000000080005b98 <plicinithart>:

void
plicinithart(void)
{
    80005b98:	1141                	addi	sp,sp,-16
    80005b9a:	e406                	sd	ra,8(sp)
    80005b9c:	e022                	sd	s0,0(sp)
    80005b9e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ba0:	cd7fb0ef          	jal	80001876 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ba4:	0085171b          	slliw	a4,a0,0x8
    80005ba8:	0c0027b7          	lui	a5,0xc002
    80005bac:	97ba                	add	a5,a5,a4
    80005bae:	40200713          	li	a4,1026
    80005bb2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005bb6:	00d5151b          	slliw	a0,a0,0xd
    80005bba:	0c2017b7          	lui	a5,0xc201
    80005bbe:	97aa                	add	a5,a5,a0
    80005bc0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005bc4:	60a2                	ld	ra,8(sp)
    80005bc6:	6402                	ld	s0,0(sp)
    80005bc8:	0141                	addi	sp,sp,16
    80005bca:	8082                	ret

0000000080005bcc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005bcc:	1141                	addi	sp,sp,-16
    80005bce:	e406                	sd	ra,8(sp)
    80005bd0:	e022                	sd	s0,0(sp)
    80005bd2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bd4:	ca3fb0ef          	jal	80001876 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005bd8:	00d5151b          	slliw	a0,a0,0xd
    80005bdc:	0c2017b7          	lui	a5,0xc201
    80005be0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005be2:	43c8                	lw	a0,4(a5)
    80005be4:	60a2                	ld	ra,8(sp)
    80005be6:	6402                	ld	s0,0(sp)
    80005be8:	0141                	addi	sp,sp,16
    80005bea:	8082                	ret

0000000080005bec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005bec:	1101                	addi	sp,sp,-32
    80005bee:	ec06                	sd	ra,24(sp)
    80005bf0:	e822                	sd	s0,16(sp)
    80005bf2:	e426                	sd	s1,8(sp)
    80005bf4:	1000                	addi	s0,sp,32
    80005bf6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005bf8:	c7ffb0ef          	jal	80001876 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80005bfc:	00d5151b          	slliw	a0,a0,0xd
    80005c00:	0c2017b7          	lui	a5,0xc201
    80005c04:	97aa                	add	a5,a5,a0
    80005c06:	c3c4                	sw	s1,4(a5)
}
    80005c08:	60e2                	ld	ra,24(sp)
    80005c0a:	6442                	ld	s0,16(sp)
    80005c0c:	64a2                	ld	s1,8(sp)
    80005c0e:	6105                	addi	sp,sp,32
    80005c10:	8082                	ret

0000000080005c12 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c12:	1141                	addi	sp,sp,-16
    80005c14:	e406                	sd	ra,8(sp)
    80005c16:	e022                	sd	s0,0(sp)
    80005c18:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005c1a:	479d                	li	a5,7
    80005c1c:	04a7ca63          	blt	a5,a0,80005c70 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005c20:	00020797          	auipc	a5,0x20
    80005c24:	d5078793          	addi	a5,a5,-688 # 80025970 <disk>
    80005c28:	97aa                	add	a5,a5,a0
    80005c2a:	0187c783          	lbu	a5,24(a5)
    80005c2e:	e7b9                	bnez	a5,80005c7c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005c30:	00451693          	slli	a3,a0,0x4
    80005c34:	00020797          	auipc	a5,0x20
    80005c38:	d3c78793          	addi	a5,a5,-708 # 80025970 <disk>
    80005c3c:	6398                	ld	a4,0(a5)
    80005c3e:	9736                	add	a4,a4,a3
    80005c40:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005c44:	6398                	ld	a4,0(a5)
    80005c46:	9736                	add	a4,a4,a3
    80005c48:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005c4c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005c50:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005c54:	97aa                	add	a5,a5,a0
    80005c56:	4705                	li	a4,1
    80005c58:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005c5c:	00020517          	auipc	a0,0x20
    80005c60:	d2c50513          	addi	a0,a0,-724 # 80025988 <disk+0x18>
    80005c64:	c20fc0ef          	jal	80002084 <wakeup>
}
    80005c68:	60a2                	ld	ra,8(sp)
    80005c6a:	6402                	ld	s0,0(sp)
    80005c6c:	0141                	addi	sp,sp,16
    80005c6e:	8082                	ret
    panic("free_desc 1");
    80005c70:	00003517          	auipc	a0,0x3
    80005c74:	b9050513          	addi	a0,a0,-1136 # 80008800 <etext+0x800>
    80005c78:	b79fa0ef          	jal	800007f0 <panic>
    panic("free_desc 2");
    80005c7c:	00003517          	auipc	a0,0x3
    80005c80:	b9450513          	addi	a0,a0,-1132 # 80008810 <etext+0x810>
    80005c84:	b6dfa0ef          	jal	800007f0 <panic>

0000000080005c88 <virtio_disk_init>:
{
    80005c88:	1101                	addi	sp,sp,-32
    80005c8a:	ec06                	sd	ra,24(sp)
    80005c8c:	e822                	sd	s0,16(sp)
    80005c8e:	e426                	sd	s1,8(sp)
    80005c90:	e04a                	sd	s2,0(sp)
    80005c92:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005c94:	00003597          	auipc	a1,0x3
    80005c98:	b8c58593          	addi	a1,a1,-1140 # 80008820 <etext+0x820>
    80005c9c:	00020517          	auipc	a0,0x20
    80005ca0:	dfc50513          	addi	a0,a0,-516 # 80025a98 <disk+0x128>
    80005ca4:	e77fa0ef          	jal	80000b1a <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ca8:	100017b7          	lui	a5,0x10001
    80005cac:	4398                	lw	a4,0(a5)
    80005cae:	2701                	sext.w	a4,a4
    80005cb0:	747277b7          	lui	a5,0x74727
    80005cb4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005cb8:	18f71063          	bne	a4,a5,80005e38 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cbc:	100017b7          	lui	a5,0x10001
    80005cc0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005cc2:	439c                	lw	a5,0(a5)
    80005cc4:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cc6:	4709                	li	a4,2
    80005cc8:	16e79863          	bne	a5,a4,80005e38 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ccc:	100017b7          	lui	a5,0x10001
    80005cd0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005cd2:	439c                	lw	a5,0(a5)
    80005cd4:	2781                	sext.w	a5,a5
    80005cd6:	16e79163          	bne	a5,a4,80005e38 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005cda:	100017b7          	lui	a5,0x10001
    80005cde:	47d8                	lw	a4,12(a5)
    80005ce0:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ce2:	554d47b7          	lui	a5,0x554d4
    80005ce6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005cea:	14f71763          	bne	a4,a5,80005e38 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cee:	100017b7          	lui	a5,0x10001
    80005cf2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cf6:	4705                	li	a4,1
    80005cf8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cfa:	470d                	li	a4,3
    80005cfc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005cfe:	10001737          	lui	a4,0x10001
    80005d02:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005d04:	c7ffe737          	lui	a4,0xc7ffe
    80005d08:	55f70713          	addi	a4,a4,1375 # ffffffffc7ffe55f <end+0xffffffff47fd8aaf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d0c:	8ef9                	and	a3,a3,a4
    80005d0e:	10001737          	lui	a4,0x10001
    80005d12:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d14:	472d                	li	a4,11
    80005d16:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d18:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005d1c:	439c                	lw	a5,0(a5)
    80005d1e:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005d22:	8ba1                	andi	a5,a5,8
    80005d24:	12078063          	beqz	a5,80005e44 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d28:	100017b7          	lui	a5,0x10001
    80005d2c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005d30:	100017b7          	lui	a5,0x10001
    80005d34:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005d38:	439c                	lw	a5,0(a5)
    80005d3a:	2781                	sext.w	a5,a5
    80005d3c:	10079a63          	bnez	a5,80005e50 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d40:	100017b7          	lui	a5,0x10001
    80005d44:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005d48:	439c                	lw	a5,0(a5)
    80005d4a:	2781                	sext.w	a5,a5
  if (max == 0)
    80005d4c:	10078863          	beqz	a5,80005e5c <virtio_disk_init+0x1d4>
  if (max < NUM)
    80005d50:	471d                	li	a4,7
    80005d52:	10f77b63          	bgeu	a4,a5,80005e68 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005d56:	d75fa0ef          	jal	80000aca <kalloc>
    80005d5a:	00020497          	auipc	s1,0x20
    80005d5e:	c1648493          	addi	s1,s1,-1002 # 80025970 <disk>
    80005d62:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005d64:	d67fa0ef          	jal	80000aca <kalloc>
    80005d68:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005d6a:	d61fa0ef          	jal	80000aca <kalloc>
    80005d6e:	87aa                	mv	a5,a0
    80005d70:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005d72:	6088                	ld	a0,0(s1)
    80005d74:	10050063          	beqz	a0,80005e74 <virtio_disk_init+0x1ec>
    80005d78:	00020717          	auipc	a4,0x20
    80005d7c:	c0073703          	ld	a4,-1024(a4) # 80025978 <disk+0x8>
    80005d80:	0e070a63          	beqz	a4,80005e74 <virtio_disk_init+0x1ec>
    80005d84:	0e078863          	beqz	a5,80005e74 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005d88:	6605                	lui	a2,0x1
    80005d8a:	4581                	li	a1,0
    80005d8c:	ec9fa0ef          	jal	80000c54 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005d90:	00020497          	auipc	s1,0x20
    80005d94:	be048493          	addi	s1,s1,-1056 # 80025970 <disk>
    80005d98:	6605                	lui	a2,0x1
    80005d9a:	4581                	li	a1,0
    80005d9c:	6488                	ld	a0,8(s1)
    80005d9e:	eb7fa0ef          	jal	80000c54 <memset>
  memset(disk.used, 0, PGSIZE);
    80005da2:	6605                	lui	a2,0x1
    80005da4:	4581                	li	a1,0
    80005da6:	6888                	ld	a0,16(s1)
    80005da8:	eadfa0ef          	jal	80000c54 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005dac:	100017b7          	lui	a5,0x10001
    80005db0:	4721                	li	a4,8
    80005db2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005db4:	4098                	lw	a4,0(s1)
    80005db6:	100017b7          	lui	a5,0x10001
    80005dba:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005dbe:	40d8                	lw	a4,4(s1)
    80005dc0:	100017b7          	lui	a5,0x10001
    80005dc4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005dc8:	649c                	ld	a5,8(s1)
    80005dca:	0007869b          	sext.w	a3,a5
    80005dce:	10001737          	lui	a4,0x10001
    80005dd2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005dd6:	9781                	srai	a5,a5,0x20
    80005dd8:	10001737          	lui	a4,0x10001
    80005ddc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005de0:	689c                	ld	a5,16(s1)
    80005de2:	0007869b          	sext.w	a3,a5
    80005de6:	10001737          	lui	a4,0x10001
    80005dea:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005dee:	9781                	srai	a5,a5,0x20
    80005df0:	10001737          	lui	a4,0x10001
    80005df4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005df8:	10001737          	lui	a4,0x10001
    80005dfc:	4785                	li	a5,1
    80005dfe:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005e00:	00f48c23          	sb	a5,24(s1)
    80005e04:	00f48ca3          	sb	a5,25(s1)
    80005e08:	00f48d23          	sb	a5,26(s1)
    80005e0c:	00f48da3          	sb	a5,27(s1)
    80005e10:	00f48e23          	sb	a5,28(s1)
    80005e14:	00f48ea3          	sb	a5,29(s1)
    80005e18:	00f48f23          	sb	a5,30(s1)
    80005e1c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005e20:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e24:	100017b7          	lui	a5,0x10001
    80005e28:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005e2c:	60e2                	ld	ra,24(sp)
    80005e2e:	6442                	ld	s0,16(sp)
    80005e30:	64a2                	ld	s1,8(sp)
    80005e32:	6902                	ld	s2,0(sp)
    80005e34:	6105                	addi	sp,sp,32
    80005e36:	8082                	ret
    panic("could not find virtio disk");
    80005e38:	00003517          	auipc	a0,0x3
    80005e3c:	9f850513          	addi	a0,a0,-1544 # 80008830 <etext+0x830>
    80005e40:	9b1fa0ef          	jal	800007f0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005e44:	00003517          	auipc	a0,0x3
    80005e48:	a0c50513          	addi	a0,a0,-1524 # 80008850 <etext+0x850>
    80005e4c:	9a5fa0ef          	jal	800007f0 <panic>
    panic("virtio disk should not be ready");
    80005e50:	00003517          	auipc	a0,0x3
    80005e54:	a2050513          	addi	a0,a0,-1504 # 80008870 <etext+0x870>
    80005e58:	999fa0ef          	jal	800007f0 <panic>
    panic("virtio disk has no queue 0");
    80005e5c:	00003517          	auipc	a0,0x3
    80005e60:	a3450513          	addi	a0,a0,-1484 # 80008890 <etext+0x890>
    80005e64:	98dfa0ef          	jal	800007f0 <panic>
    panic("virtio disk max queue too short");
    80005e68:	00003517          	auipc	a0,0x3
    80005e6c:	a4850513          	addi	a0,a0,-1464 # 800088b0 <etext+0x8b0>
    80005e70:	981fa0ef          	jal	800007f0 <panic>
    panic("virtio disk kalloc");
    80005e74:	00003517          	auipc	a0,0x3
    80005e78:	a5c50513          	addi	a0,a0,-1444 # 800088d0 <etext+0x8d0>
    80005e7c:	975fa0ef          	jal	800007f0 <panic>

0000000080005e80 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005e80:	7159                	addi	sp,sp,-112
    80005e82:	f486                	sd	ra,104(sp)
    80005e84:	f0a2                	sd	s0,96(sp)
    80005e86:	eca6                	sd	s1,88(sp)
    80005e88:	e8ca                	sd	s2,80(sp)
    80005e8a:	e4ce                	sd	s3,72(sp)
    80005e8c:	e0d2                	sd	s4,64(sp)
    80005e8e:	fc56                	sd	s5,56(sp)
    80005e90:	f85a                	sd	s6,48(sp)
    80005e92:	f45e                	sd	s7,40(sp)
    80005e94:	f062                	sd	s8,32(sp)
    80005e96:	ec66                	sd	s9,24(sp)
    80005e98:	1880                	addi	s0,sp,112
    80005e9a:	8a2a                	mv	s4,a0
    80005e9c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e9e:	00c52c83          	lw	s9,12(a0)
    80005ea2:	001c9c9b          	slliw	s9,s9,0x1
    80005ea6:	1c82                	slli	s9,s9,0x20
    80005ea8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005eac:	00020517          	auipc	a0,0x20
    80005eb0:	bec50513          	addi	a0,a0,-1044 # 80025a98 <disk+0x128>
    80005eb4:	cddfa0ef          	jal	80000b90 <acquire>
  for (int i = 0; i < 3; i++) {
    80005eb8:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++) {
    80005eba:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005ebc:	00020b17          	auipc	s6,0x20
    80005ec0:	ab4b0b13          	addi	s6,s6,-1356 # 80025970 <disk>
  for (int i = 0; i < 3; i++) {
    80005ec4:	4a8d                	li	s5,3
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005ec6:	00020c17          	auipc	s8,0x20
    80005eca:	ac2c0c13          	addi	s8,s8,-1342 # 80025988 <disk+0x18>
    80005ece:	a0bd                	j	80005f3c <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005ed0:	00fb0733          	add	a4,s6,a5
    80005ed4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005ed8:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005eda:	0207c563          	bltz	a5,80005f04 <virtio_disk_rw+0x84>
  for (int i = 0; i < 3; i++) {
    80005ede:	2905                	addiw	s2,s2,1
    80005ee0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005ee2:	07590163          	beq	s2,s5,80005f44 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005ee6:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005ee8:	00020717          	auipc	a4,0x20
    80005eec:	a8870713          	addi	a4,a4,-1400 # 80025970 <disk>
    80005ef0:	87ce                	mv	a5,s3
    if (disk.free[i]) {
    80005ef2:	01874683          	lbu	a3,24(a4)
    80005ef6:	fee9                	bnez	a3,80005ed0 <virtio_disk_rw+0x50>
  for (int i = 0; i < NUM; i++) {
    80005ef8:	2785                	addiw	a5,a5,1
    80005efa:	0705                	addi	a4,a4,1
    80005efc:	fe979be3          	bne	a5,s1,80005ef2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005f00:	57fd                	li	a5,-1
    80005f02:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80005f04:	01205d63          	blez	s2,80005f1e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005f08:	f9042503          	lw	a0,-112(s0)
    80005f0c:	d07ff0ef          	jal	80005c12 <free_desc>
      for (int j = 0; j < i; j++)
    80005f10:	4785                	li	a5,1
    80005f12:	0127d663          	bge	a5,s2,80005f1e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005f16:	f9442503          	lw	a0,-108(s0)
    80005f1a:	cf9ff0ef          	jal	80005c12 <free_desc>
    sleep_prepare(&disk.free[0]);
    80005f1e:	8562                	mv	a0,s8
    80005f20:	8ecfc0ef          	jal	8000200c <sleep_prepare>
    release(&disk.vdisk_lock);
    80005f24:	00020917          	auipc	s2,0x20
    80005f28:	b7490913          	addi	s2,s2,-1164 # 80025a98 <disk+0x128>
    80005f2c:	854a                	mv	a0,s2
    80005f2e:	ceffa0ef          	jal	80000c1c <release>
    sleep();
    80005f32:	916fc0ef          	jal	80002048 <sleep>
    acquire(&disk.vdisk_lock);
    80005f36:	854a                	mv	a0,s2
    80005f38:	c59fa0ef          	jal	80000b90 <acquire>
  for (int i = 0; i < 3; i++) {
    80005f3c:	f9040613          	addi	a2,s0,-112
    80005f40:	894e                	mv	s2,s3
    80005f42:	b755                	j	80005ee6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005f44:	f9042503          	lw	a0,-112(s0)
    80005f48:	00451693          	slli	a3,a0,0x4

  if (write)
    80005f4c:	00020797          	auipc	a5,0x20
    80005f50:	a2478793          	addi	a5,a5,-1500 # 80025970 <disk>
    80005f54:	00a50713          	addi	a4,a0,10
    80005f58:	0712                	slli	a4,a4,0x4
    80005f5a:	973e                	add	a4,a4,a5
    80005f5c:	01703633          	snez	a2,s7
    80005f60:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005f62:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005f66:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005f6a:	6398                	ld	a4,0(a5)
    80005f6c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005f6e:	0a868613          	addi	a2,a3,168
    80005f72:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005f74:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005f76:	6390                	ld	a2,0(a5)
    80005f78:	00d605b3          	add	a1,a2,a3
    80005f7c:	4741                	li	a4,16
    80005f7e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005f80:	4805                	li	a6,1
    80005f82:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005f86:	f9442703          	lw	a4,-108(s0)
    80005f8a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005f8e:	0712                	slli	a4,a4,0x4
    80005f90:	963a                	add	a2,a2,a4
    80005f92:	058a0593          	addi	a1,s4,88
    80005f96:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005f98:	0007b883          	ld	a7,0(a5)
    80005f9c:	9746                	add	a4,a4,a7
    80005f9e:	40000613          	li	a2,1024
    80005fa2:	c710                	sw	a2,8(a4)
  if (write)
    80005fa4:	001bb613          	seqz	a2,s7
    80005fa8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005fac:	00166613          	ori	a2,a2,1
    80005fb0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005fb4:	f9842583          	lw	a1,-104(s0)
    80005fb8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005fbc:	00250613          	addi	a2,a0,2
    80005fc0:	0612                	slli	a2,a2,0x4
    80005fc2:	963e                	add	a2,a2,a5
    80005fc4:	577d                	li	a4,-1
    80005fc6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005fca:	0592                	slli	a1,a1,0x4
    80005fcc:	98ae                	add	a7,a7,a1
    80005fce:	03068713          	addi	a4,a3,48
    80005fd2:	973e                	add	a4,a4,a5
    80005fd4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005fd8:	6398                	ld	a4,0(a5)
    80005fda:	972e                	add	a4,a4,a1
    80005fdc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005fe0:	4689                	li	a3,2
    80005fe2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005fe6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005fea:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005fee:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005ff2:	6794                	ld	a3,8(a5)
    80005ff4:	0026d703          	lhu	a4,2(a3)
    80005ff8:	8b1d                	andi	a4,a4,7
    80005ffa:	0706                	slli	a4,a4,0x1
    80005ffc:	96ba                	add	a3,a3,a4
    80005ffe:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80006002:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006006:	6798                	ld	a4,8(a5)
    80006008:	00275783          	lhu	a5,2(a4)
    8000600c:	2785                	addiw	a5,a5,1
    8000600e:	00f71123          	sh	a5,2(a4)
    80006012:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006016:	100017b7          	lui	a5,0x10001
    8000601a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    8000601e:	004a2783          	lw	a5,4(s4)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80006022:	00020497          	auipc	s1,0x20
    80006026:	a7648493          	addi	s1,s1,-1418 # 80025a98 <disk+0x128>
  while (b->disk == 1) {
    8000602a:	4905                	li	s2,1
    8000602c:	03079163          	bne	a5,a6,8000604e <virtio_disk_rw+0x1ce>
    sleep_prepare(b);
    80006030:	8552                	mv	a0,s4
    80006032:	fdbfb0ef          	jal	8000200c <sleep_prepare>
    release(&disk.vdisk_lock);
    80006036:	8526                	mv	a0,s1
    80006038:	be5fa0ef          	jal	80000c1c <release>
    sleep();
    8000603c:	80cfc0ef          	jal	80002048 <sleep>
    acquire(&disk.vdisk_lock);
    80006040:	8526                	mv	a0,s1
    80006042:	b4ffa0ef          	jal	80000b90 <acquire>
  while (b->disk == 1) {
    80006046:	004a2783          	lw	a5,4(s4)
    8000604a:	ff2783e3          	beq	a5,s2,80006030 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000604e:	f9042903          	lw	s2,-112(s0)
    80006052:	00290713          	addi	a4,s2,2
    80006056:	0712                	slli	a4,a4,0x4
    80006058:	00020797          	auipc	a5,0x20
    8000605c:	91878793          	addi	a5,a5,-1768 # 80025970 <disk>
    80006060:	97ba                	add	a5,a5,a4
    80006062:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006066:	00020997          	auipc	s3,0x20
    8000606a:	90a98993          	addi	s3,s3,-1782 # 80025970 <disk>
    8000606e:	00491713          	slli	a4,s2,0x4
    80006072:	0009b783          	ld	a5,0(s3)
    80006076:	97ba                	add	a5,a5,a4
    80006078:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000607c:	854a                	mv	a0,s2
    8000607e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006082:	b91ff0ef          	jal	80005c12 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80006086:	8885                	andi	s1,s1,1
    80006088:	f0fd                	bnez	s1,8000606e <virtio_disk_rw+0x1ee>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000608a:	00020517          	auipc	a0,0x20
    8000608e:	a0e50513          	addi	a0,a0,-1522 # 80025a98 <disk+0x128>
    80006092:	b8bfa0ef          	jal	80000c1c <release>
}
    80006096:	70a6                	ld	ra,104(sp)
    80006098:	7406                	ld	s0,96(sp)
    8000609a:	64e6                	ld	s1,88(sp)
    8000609c:	6946                	ld	s2,80(sp)
    8000609e:	69a6                	ld	s3,72(sp)
    800060a0:	6a06                	ld	s4,64(sp)
    800060a2:	7ae2                	ld	s5,56(sp)
    800060a4:	7b42                	ld	s6,48(sp)
    800060a6:	7ba2                	ld	s7,40(sp)
    800060a8:	7c02                	ld	s8,32(sp)
    800060aa:	6ce2                	ld	s9,24(sp)
    800060ac:	6165                	addi	sp,sp,112
    800060ae:	8082                	ret

00000000800060b0 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800060b0:	1101                	addi	sp,sp,-32
    800060b2:	ec06                	sd	ra,24(sp)
    800060b4:	e822                	sd	s0,16(sp)
    800060b6:	e426                	sd	s1,8(sp)
    800060b8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800060ba:	00020497          	auipc	s1,0x20
    800060be:	8b648493          	addi	s1,s1,-1866 # 80025970 <disk>
    800060c2:	00020517          	auipc	a0,0x20
    800060c6:	9d650513          	addi	a0,a0,-1578 # 80025a98 <disk+0x128>
    800060ca:	ac7fa0ef          	jal	80000b90 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800060ce:	100017b7          	lui	a5,0x10001
    800060d2:	53b8                	lw	a4,96(a5)
    800060d4:	8b0d                	andi	a4,a4,3
    800060d6:	100017b7          	lui	a5,0x10001
    800060da:	d3f8                	sw	a4,100(a5)
    800060dc:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    800060e0:	689c                	ld	a5,16(s1)
    800060e2:	0204d703          	lhu	a4,32(s1)
    800060e6:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800060ea:	04f70663          	beq	a4,a5,80006136 <virtio_disk_intr+0x86>
    800060ee:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800060f2:	6898                	ld	a4,16(s1)
    800060f4:	0204d783          	lhu	a5,32(s1)
    800060f8:	8b9d                	andi	a5,a5,7
    800060fa:	078e                	slli	a5,a5,0x3
    800060fc:	97ba                	add	a5,a5,a4
    800060fe:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80006100:	00278713          	addi	a4,a5,2
    80006104:	0712                	slli	a4,a4,0x4
    80006106:	9726                	add	a4,a4,s1
    80006108:	01074703          	lbu	a4,16(a4)
    8000610c:	e321                	bnez	a4,8000614c <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000610e:	0789                	addi	a5,a5,2
    80006110:	0792                	slli	a5,a5,0x4
    80006112:	97a6                	add	a5,a5,s1
    80006114:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80006116:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000611a:	f6bfb0ef          	jal	80002084 <wakeup>

    disk.used_idx += 1;
    8000611e:	0204d783          	lhu	a5,32(s1)
    80006122:	2785                	addiw	a5,a5,1
    80006124:	17c2                	slli	a5,a5,0x30
    80006126:	93c1                	srli	a5,a5,0x30
    80006128:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    8000612c:	6898                	ld	a4,16(s1)
    8000612e:	00275703          	lhu	a4,2(a4)
    80006132:	faf71ee3          	bne	a4,a5,800060ee <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006136:	00020517          	auipc	a0,0x20
    8000613a:	96250513          	addi	a0,a0,-1694 # 80025a98 <disk+0x128>
    8000613e:	adffa0ef          	jal	80000c1c <release>
}
    80006142:	60e2                	ld	ra,24(sp)
    80006144:	6442                	ld	s0,16(sp)
    80006146:	64a2                	ld	s1,8(sp)
    80006148:	6105                	addi	sp,sp,32
    8000614a:	8082                	ret
      panic("virtio_disk_intr status");
    8000614c:	00002517          	auipc	a0,0x2
    80006150:	79c50513          	addi	a0,a0,1948 # 800088e8 <etext+0x8e8>
    80006154:	e9cfa0ef          	jal	800007f0 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	0000100f          	fence.i
    800070a0:	12000073          	sfence.vma
    800070a4:	18051073          	csrw	satp,a0
    800070a8:	12000073          	sfence.vma
    800070ac:	02000537          	lui	a0,0x2000
    800070b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070b2:	0536                	slli	a0,a0,0xd
    800070b4:	02853083          	ld	ra,40(a0)
    800070b8:	03053103          	ld	sp,48(a0)
    800070bc:	03853183          	ld	gp,56(a0)
    800070c0:	04053203          	ld	tp,64(a0)
    800070c4:	04853283          	ld	t0,72(a0)
    800070c8:	05053303          	ld	t1,80(a0)
    800070cc:	05853383          	ld	t2,88(a0)
    800070d0:	7120                	ld	s0,96(a0)
    800070d2:	7524                	ld	s1,104(a0)
    800070d4:	7d2c                	ld	a1,120(a0)
    800070d6:	6150                	ld	a2,128(a0)
    800070d8:	6554                	ld	a3,136(a0)
    800070da:	6958                	ld	a4,144(a0)
    800070dc:	6d5c                	ld	a5,152(a0)
    800070de:	0a053803          	ld	a6,160(a0)
    800070e2:	0a853883          	ld	a7,168(a0)
    800070e6:	0b053903          	ld	s2,176(a0)
    800070ea:	0b853983          	ld	s3,184(a0)
    800070ee:	0c053a03          	ld	s4,192(a0)
    800070f2:	0c853a83          	ld	s5,200(a0)
    800070f6:	0d053b03          	ld	s6,208(a0)
    800070fa:	0d853b83          	ld	s7,216(a0)
    800070fe:	0e053c03          	ld	s8,224(a0)
    80007102:	0e853c83          	ld	s9,232(a0)
    80007106:	0f053d03          	ld	s10,240(a0)
    8000710a:	0f853d83          	ld	s11,248(a0)
    8000710e:	10053e03          	ld	t3,256(a0)
    80007112:	10853e83          	ld	t4,264(a0)
    80007116:	11053f03          	ld	t5,272(a0)
    8000711a:	11853f83          	ld	t6,280(a0)
    8000711e:	7928                	ld	a0,112(a0)
    80007120:	10200073          	sret
	...
