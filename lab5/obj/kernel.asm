
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	2fe50513          	addi	a0,a0,766 # ffffffffc02a7330 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	85260613          	addi	a2,a2,-1966 # ffffffffc02b288c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	1a6060ef          	jal	ra,ffffffffc02061f0 <memset>
    cons_init();                // init the console
ffffffffc020004e:	580000ef          	jal	ra,ffffffffc02005ce <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	5ce58593          	addi	a1,a1,1486 # ffffffffc0206620 <etext+0x2>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	5e650513          	addi	a0,a0,1510 # ffffffffc0206640 <etext+0x22>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	6d4010ef          	jal	ra,ffffffffc020173e <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d2000ef          	jal	ra,ffffffffc0200640 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	4fd020ef          	jal	ra,ffffffffc0202d72 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	55d050ef          	jal	ra,ffffffffc0205dd6 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	79c030ef          	jal	ra,ffffffffc020381e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4f6000ef          	jal	ra,ffffffffc020057c <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b8000ef          	jal	ra,ffffffffc0200642 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	6e1050ef          	jal	ra,ffffffffc0205f6e <cpu_idle>

ffffffffc0200092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200092:	1141                	addi	sp,sp,-16
ffffffffc0200094:	e022                	sd	s0,0(sp)
ffffffffc0200096:	e406                	sd	ra,8(sp)
ffffffffc0200098:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009a:	536000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
    (*cnt) ++;
ffffffffc020009e:	401c                	lw	a5,0(s0)
}
ffffffffc02000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a2:	2785                	addiw	a5,a5,1
ffffffffc02000a4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a6:	6402                	ld	s0,0(sp)
ffffffffc02000a8:	0141                	addi	sp,sp,16
ffffffffc02000aa:	8082                	ret

ffffffffc02000ac <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	1101                	addi	sp,sp,-32
ffffffffc02000ae:	862a                	mv	a2,a0
ffffffffc02000b0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	00000517          	auipc	a0,0x0
ffffffffc02000b6:	fe050513          	addi	a0,a0,-32 # ffffffffc0200092 <cputch>
ffffffffc02000ba:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000be:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	1c6060ef          	jal	ra,ffffffffc0206286 <vprintfmt>
    return cnt;
}
ffffffffc02000c4:	60e2                	ld	ra,24(sp)
ffffffffc02000c6:	4532                	lw	a0,12(sp)
ffffffffc02000c8:	6105                	addi	sp,sp,32
ffffffffc02000ca:	8082                	ret

ffffffffc02000cc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d2:	8e2a                	mv	t3,a0
ffffffffc02000d4:	f42e                	sd	a1,40(sp)
ffffffffc02000d6:	f832                	sd	a2,48(sp)
ffffffffc02000d8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	00000517          	auipc	a0,0x0
ffffffffc02000de:	fb850513          	addi	a0,a0,-72 # ffffffffc0200092 <cputch>
ffffffffc02000e2:	004c                	addi	a1,sp,4
ffffffffc02000e4:	869a                	mv	a3,t1
ffffffffc02000e6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000e8:	ec06                	sd	ra,24(sp)
ffffffffc02000ea:	e0ba                	sd	a4,64(sp)
ffffffffc02000ec:	e4be                	sd	a5,72(sp)
ffffffffc02000ee:	e8c2                	sd	a6,80(sp)
ffffffffc02000f0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f6:	190060ef          	jal	ra,ffffffffc0206286 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fa:	60e2                	ld	ra,24(sp)
ffffffffc02000fc:	4512                	lw	a0,4(sp)
ffffffffc02000fe:	6125                	addi	sp,sp,96
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200102:	a1f9                	j	ffffffffc02005d0 <cons_putc>

ffffffffc0200104 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200104:	1101                	addi	sp,sp,-32
ffffffffc0200106:	e822                	sd	s0,16(sp)
ffffffffc0200108:	ec06                	sd	ra,24(sp)
ffffffffc020010a:	e426                	sd	s1,8(sp)
ffffffffc020010c:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020010e:	00054503          	lbu	a0,0(a0)
ffffffffc0200112:	c51d                	beqz	a0,ffffffffc0200140 <cputs+0x3c>
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	4485                	li	s1,1
ffffffffc0200118:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011a:	4b6000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00044503          	lbu	a0,0(s0)
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	f96d                	bnez	a0,ffffffffc020011a <cputs+0x16>
    (*cnt) ++;
ffffffffc020012a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020012e:	4529                	li	a0,10
ffffffffc0200130:	4a0000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200134:	60e2                	ld	ra,24(sp)
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	6442                	ld	s0,16(sp)
ffffffffc020013a:	64a2                	ld	s1,8(sp)
ffffffffc020013c:	6105                	addi	sp,sp,32
ffffffffc020013e:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200140:	4405                	li	s0,1
ffffffffc0200142:	b7f5                	j	ffffffffc020012e <cputs+0x2a>

ffffffffc0200144 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200144:	1141                	addi	sp,sp,-16
ffffffffc0200146:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200148:	4bc000ef          	jal	ra,ffffffffc0200604 <cons_getc>
ffffffffc020014c:	dd75                	beqz	a0,ffffffffc0200148 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020014e:	60a2                	ld	ra,8(sp)
ffffffffc0200150:	0141                	addi	sp,sp,16
ffffffffc0200152:	8082                	ret

ffffffffc0200154 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200154:	715d                	addi	sp,sp,-80
ffffffffc0200156:	e486                	sd	ra,72(sp)
ffffffffc0200158:	e0a6                	sd	s1,64(sp)
ffffffffc020015a:	fc4a                	sd	s2,56(sp)
ffffffffc020015c:	f84e                	sd	s3,48(sp)
ffffffffc020015e:	f452                	sd	s4,40(sp)
ffffffffc0200160:	f056                	sd	s5,32(sp)
ffffffffc0200162:	ec5a                	sd	s6,24(sp)
ffffffffc0200164:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200166:	c901                	beqz	a0,ffffffffc0200176 <readline+0x22>
ffffffffc0200168:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020016a:	00006517          	auipc	a0,0x6
ffffffffc020016e:	4de50513          	addi	a0,a0,1246 # ffffffffc0206648 <etext+0x2a>
ffffffffc0200172:	f5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200176:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200178:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020017a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020017c:	4aa9                	li	s5,10
ffffffffc020017e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200180:	000a7b97          	auipc	s7,0xa7
ffffffffc0200184:	1b0b8b93          	addi	s7,s7,432 # ffffffffc02a7330 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200188:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020018c:	fb9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc0200190:	00054a63          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200194:	00a95a63          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc0200198:	029a5263          	bge	s4,s1,ffffffffc02001bc <readline+0x68>
        c = getchar();
ffffffffc020019c:	fa9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001a0:	fe055ae3          	bgez	a0,ffffffffc0200194 <readline+0x40>
            return NULL;
ffffffffc02001a4:	4501                	li	a0,0
ffffffffc02001a6:	a091                	j	ffffffffc02001ea <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001a8:	03351463          	bne	a0,s3,ffffffffc02001d0 <readline+0x7c>
ffffffffc02001ac:	e8a9                	bnez	s1,ffffffffc02001fe <readline+0xaa>
        c = getchar();
ffffffffc02001ae:	f97ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001b2:	fe0549e3          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001b6:	fea959e3          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc02001ba:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001bc:	e42a                	sd	a0,8(sp)
ffffffffc02001be:	f45ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc02001c2:	6522                	ld	a0,8(sp)
ffffffffc02001c4:	009b87b3          	add	a5,s7,s1
ffffffffc02001c8:	2485                	addiw	s1,s1,1
ffffffffc02001ca:	00a78023          	sb	a0,0(a5)
ffffffffc02001ce:	bf7d                	j	ffffffffc020018c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001d0:	01550463          	beq	a0,s5,ffffffffc02001d8 <readline+0x84>
ffffffffc02001d4:	fb651ce3          	bne	a0,s6,ffffffffc020018c <readline+0x38>
            cputchar(c);
ffffffffc02001d8:	f2bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc02001dc:	000a7517          	auipc	a0,0xa7
ffffffffc02001e0:	15450513          	addi	a0,a0,340 # ffffffffc02a7330 <buf>
ffffffffc02001e4:	94aa                	add	s1,s1,a0
ffffffffc02001e6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001ea:	60a6                	ld	ra,72(sp)
ffffffffc02001ec:	6486                	ld	s1,64(sp)
ffffffffc02001ee:	7962                	ld	s2,56(sp)
ffffffffc02001f0:	79c2                	ld	s3,48(sp)
ffffffffc02001f2:	7a22                	ld	s4,40(sp)
ffffffffc02001f4:	7a82                	ld	s5,32(sp)
ffffffffc02001f6:	6b62                	ld	s6,24(sp)
ffffffffc02001f8:	6bc2                	ld	s7,16(sp)
ffffffffc02001fa:	6161                	addi	sp,sp,80
ffffffffc02001fc:	8082                	ret
            cputchar(c);
ffffffffc02001fe:	4521                	li	a0,8
ffffffffc0200200:	f03ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc0200204:	34fd                	addiw	s1,s1,-1
ffffffffc0200206:	b759                	j	ffffffffc020018c <readline+0x38>

ffffffffc0200208 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200208:	000b2317          	auipc	t1,0xb2
ffffffffc020020c:	5f030313          	addi	t1,t1,1520 # ffffffffc02b27f8 <is_panic>
ffffffffc0200210:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200214:	715d                	addi	sp,sp,-80
ffffffffc0200216:	ec06                	sd	ra,24(sp)
ffffffffc0200218:	e822                	sd	s0,16(sp)
ffffffffc020021a:	f436                	sd	a3,40(sp)
ffffffffc020021c:	f83a                	sd	a4,48(sp)
ffffffffc020021e:	fc3e                	sd	a5,56(sp)
ffffffffc0200220:	e0c2                	sd	a6,64(sp)
ffffffffc0200222:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200224:	020e1a63          	bnez	t3,ffffffffc0200258 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200228:	4785                	li	a5,1
ffffffffc020022a:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020022e:	8432                	mv	s0,a2
ffffffffc0200230:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200232:	862e                	mv	a2,a1
ffffffffc0200234:	85aa                	mv	a1,a0
ffffffffc0200236:	00006517          	auipc	a0,0x6
ffffffffc020023a:	41a50513          	addi	a0,a0,1050 # ffffffffc0206650 <etext+0x32>
    va_start(ap, fmt);
ffffffffc020023e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200240:	e8dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200244:	65a2                	ld	a1,8(sp)
ffffffffc0200246:	8522                	mv	a0,s0
ffffffffc0200248:	e65ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020024c:	00007517          	auipc	a0,0x7
ffffffffc0200250:	c7c50513          	addi	a0,a0,-900 # ffffffffc0206ec8 <commands+0x600>
ffffffffc0200254:	e79ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200258:	4501                	li	a0,0
ffffffffc020025a:	4581                	li	a1,0
ffffffffc020025c:	4601                	li	a2,0
ffffffffc020025e:	48a1                	li	a7,8
ffffffffc0200260:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200264:	3e4000ef          	jal	ra,ffffffffc0200648 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	174000ef          	jal	ra,ffffffffc02003de <kmonitor>
    while (1) {
ffffffffc020026e:	bfed                	j	ffffffffc0200268 <__panic+0x60>

ffffffffc0200270 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200270:	715d                	addi	sp,sp,-80
ffffffffc0200272:	832e                	mv	t1,a1
ffffffffc0200274:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200276:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200278:	8432                	mv	s0,a2
ffffffffc020027a:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020027c:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc020027e:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200280:	00006517          	auipc	a0,0x6
ffffffffc0200284:	3f050513          	addi	a0,a0,1008 # ffffffffc0206670 <etext+0x52>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200288:	ec06                	sd	ra,24(sp)
ffffffffc020028a:	f436                	sd	a3,40(sp)
ffffffffc020028c:	f83a                	sd	a4,48(sp)
ffffffffc020028e:	e0c2                	sd	a6,64(sp)
ffffffffc0200290:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200292:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200294:	e39ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200298:	65a2                	ld	a1,8(sp)
ffffffffc020029a:	8522                	mv	a0,s0
ffffffffc020029c:	e11ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc02002a0:	00007517          	auipc	a0,0x7
ffffffffc02002a4:	c2850513          	addi	a0,a0,-984 # ffffffffc0206ec8 <commands+0x600>
ffffffffc02002a8:	e25ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);
}
ffffffffc02002ac:	60e2                	ld	ra,24(sp)
ffffffffc02002ae:	6442                	ld	s0,16(sp)
ffffffffc02002b0:	6161                	addi	sp,sp,80
ffffffffc02002b2:	8082                	ret

ffffffffc02002b4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002b4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002b6:	00006517          	auipc	a0,0x6
ffffffffc02002ba:	3da50513          	addi	a0,a0,986 # ffffffffc0206690 <etext+0x72>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	3e450513          	addi	a0,a0,996 # ffffffffc02066b0 <etext+0x92>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	34658593          	addi	a1,a1,838 # ffffffffc020661e <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	3f050513          	addi	a0,a0,1008 # ffffffffc02066d0 <etext+0xb2>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	04458593          	addi	a1,a1,68 # ffffffffc02a7330 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	3fc50513          	addi	a0,a0,1020 # ffffffffc02066f0 <etext+0xd2>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	58c58593          	addi	a1,a1,1420 # ffffffffc02b288c <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	40850513          	addi	a0,a0,1032 # ffffffffc0206710 <etext+0xf2>
ffffffffc0200310:	dbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200314:	000b3597          	auipc	a1,0xb3
ffffffffc0200318:	97758593          	addi	a1,a1,-1673 # ffffffffc02b2c8b <end+0x3ff>
ffffffffc020031c:	00000797          	auipc	a5,0x0
ffffffffc0200320:	d1678793          	addi	a5,a5,-746 # ffffffffc0200032 <kern_init>
ffffffffc0200324:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200328:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020032c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020032e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200332:	95be                	add	a1,a1,a5
ffffffffc0200334:	85a9                	srai	a1,a1,0xa
ffffffffc0200336:	00006517          	auipc	a0,0x6
ffffffffc020033a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206730 <etext+0x112>
}
ffffffffc020033e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200340:	b371                	j	ffffffffc02000cc <cprintf>

ffffffffc0200342 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200344:	00006617          	auipc	a2,0x6
ffffffffc0200348:	41c60613          	addi	a2,a2,1052 # ffffffffc0206760 <etext+0x142>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	42850513          	addi	a0,a0,1064 # ffffffffc0206778 <etext+0x15a>
void print_stackframe(void) {
ffffffffc0200358:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020035a:	eafff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020035e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020035e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200360:	00006617          	auipc	a2,0x6
ffffffffc0200364:	43060613          	addi	a2,a2,1072 # ffffffffc0206790 <etext+0x172>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	44858593          	addi	a1,a1,1096 # ffffffffc02067b0 <etext+0x192>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	44850513          	addi	a0,a0,1096 # ffffffffc02067b8 <etext+0x19a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	44a60613          	addi	a2,a2,1098 # ffffffffc02067c8 <etext+0x1aa>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	46a58593          	addi	a1,a1,1130 # ffffffffc02067f0 <etext+0x1d2>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	42a50513          	addi	a0,a0,1066 # ffffffffc02067b8 <etext+0x19a>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	46660613          	addi	a2,a2,1126 # ffffffffc0206800 <etext+0x1e2>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	47e58593          	addi	a1,a1,1150 # ffffffffc0206820 <etext+0x202>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	40e50513          	addi	a0,a0,1038 # ffffffffc02067b8 <etext+0x19a>
ffffffffc02003b2:	d1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc02003b6:	60a2                	ld	ra,8(sp)
ffffffffc02003b8:	4501                	li	a0,0
ffffffffc02003ba:	0141                	addi	sp,sp,16
ffffffffc02003bc:	8082                	ret

ffffffffc02003be <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003be:	1141                	addi	sp,sp,-16
ffffffffc02003c0:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003c2:	ef3ff0ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>
    return 0;
}
ffffffffc02003c6:	60a2                	ld	ra,8(sp)
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	0141                	addi	sp,sp,16
ffffffffc02003cc:	8082                	ret

ffffffffc02003ce <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003ce:	1141                	addi	sp,sp,-16
ffffffffc02003d0:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003d2:	f71ff0ef          	jal	ra,ffffffffc0200342 <print_stackframe>
    return 0;
}
ffffffffc02003d6:	60a2                	ld	ra,8(sp)
ffffffffc02003d8:	4501                	li	a0,0
ffffffffc02003da:	0141                	addi	sp,sp,16
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003de:	7115                	addi	sp,sp,-224
ffffffffc02003e0:	ed5e                	sd	s7,152(sp)
ffffffffc02003e2:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003e4:	00006517          	auipc	a0,0x6
ffffffffc02003e8:	44c50513          	addi	a0,a0,1100 # ffffffffc0206830 <etext+0x212>
kmonitor(struct trapframe *tf) {
ffffffffc02003ec:	ed86                	sd	ra,216(sp)
ffffffffc02003ee:	e9a2                	sd	s0,208(sp)
ffffffffc02003f0:	e5a6                	sd	s1,200(sp)
ffffffffc02003f2:	e1ca                	sd	s2,192(sp)
ffffffffc02003f4:	fd4e                	sd	s3,184(sp)
ffffffffc02003f6:	f952                	sd	s4,176(sp)
ffffffffc02003f8:	f556                	sd	s5,168(sp)
ffffffffc02003fa:	f15a                	sd	s6,160(sp)
ffffffffc02003fc:	e962                	sd	s8,144(sp)
ffffffffc02003fe:	e566                	sd	s9,136(sp)
ffffffffc0200400:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200402:	ccbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200406:	00006517          	auipc	a0,0x6
ffffffffc020040a:	45250513          	addi	a0,a0,1106 # ffffffffc0206858 <etext+0x23a>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	41e000ef          	jal	ra,ffffffffc0200836 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	4acc0c13          	addi	s8,s8,1196 # ffffffffc02068c8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	45c90913          	addi	s2,s2,1116 # ffffffffc0206880 <etext+0x262>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	45c48493          	addi	s1,s1,1116 # ffffffffc0206888 <etext+0x26a>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	45ab0b13          	addi	s6,s6,1114 # ffffffffc0206890 <etext+0x272>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	372a0a13          	addi	s4,s4,882 # ffffffffc02067b0 <etext+0x192>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200446:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200448:	854a                	mv	a0,s2
ffffffffc020044a:	d0bff0ef          	jal	ra,ffffffffc0200154 <readline>
ffffffffc020044e:	842a                	mv	s0,a0
ffffffffc0200450:	dd65                	beqz	a0,ffffffffc0200448 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200452:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200456:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	e1bd                	bnez	a1,ffffffffc02004be <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020045a:	fe0c87e3          	beqz	s9,ffffffffc0200448 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020045e:	6582                	ld	a1,0(sp)
ffffffffc0200460:	00006d17          	auipc	s10,0x6
ffffffffc0200464:	468d0d13          	addi	s10,s10,1128 # ffffffffc02068c8 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	54f050ef          	jal	ra,ffffffffc02061bc <strcmp>
ffffffffc0200472:	c919                	beqz	a0,ffffffffc0200488 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200474:	2405                	addiw	s0,s0,1
ffffffffc0200476:	0b540063          	beq	s0,s5,ffffffffc0200516 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020047a:	000d3503          	ld	a0,0(s10)
ffffffffc020047e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200480:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	53b050ef          	jal	ra,ffffffffc02061bc <strcmp>
ffffffffc0200486:	f57d                	bnez	a0,ffffffffc0200474 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200488:	00141793          	slli	a5,s0,0x1
ffffffffc020048c:	97a2                	add	a5,a5,s0
ffffffffc020048e:	078e                	slli	a5,a5,0x3
ffffffffc0200490:	97e2                	add	a5,a5,s8
ffffffffc0200492:	6b9c                	ld	a5,16(a5)
ffffffffc0200494:	865e                	mv	a2,s7
ffffffffc0200496:	002c                	addi	a1,sp,8
ffffffffc0200498:	fffc851b          	addiw	a0,s9,-1
ffffffffc020049c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020049e:	fa0555e3          	bgez	a0,ffffffffc0200448 <kmonitor+0x6a>
}
ffffffffc02004a2:	60ee                	ld	ra,216(sp)
ffffffffc02004a4:	644e                	ld	s0,208(sp)
ffffffffc02004a6:	64ae                	ld	s1,200(sp)
ffffffffc02004a8:	690e                	ld	s2,192(sp)
ffffffffc02004aa:	79ea                	ld	s3,184(sp)
ffffffffc02004ac:	7a4a                	ld	s4,176(sp)
ffffffffc02004ae:	7aaa                	ld	s5,168(sp)
ffffffffc02004b0:	7b0a                	ld	s6,160(sp)
ffffffffc02004b2:	6bea                	ld	s7,152(sp)
ffffffffc02004b4:	6c4a                	ld	s8,144(sp)
ffffffffc02004b6:	6caa                	ld	s9,136(sp)
ffffffffc02004b8:	6d0a                	ld	s10,128(sp)
ffffffffc02004ba:	612d                	addi	sp,sp,224
ffffffffc02004bc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004be:	8526                	mv	a0,s1
ffffffffc02004c0:	51b050ef          	jal	ra,ffffffffc02061da <strchr>
ffffffffc02004c4:	c901                	beqz	a0,ffffffffc02004d4 <kmonitor+0xf6>
ffffffffc02004c6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02004ca:	00040023          	sb	zero,0(s0)
ffffffffc02004ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004d0:	d5c9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004d2:	b7f5                	j	ffffffffc02004be <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02004d4:	00044783          	lbu	a5,0(s0)
ffffffffc02004d8:	d3c9                	beqz	a5,ffffffffc020045a <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02004da:	033c8963          	beq	s9,s3,ffffffffc020050c <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02004de:	003c9793          	slli	a5,s9,0x3
ffffffffc02004e2:	0118                	addi	a4,sp,128
ffffffffc02004e4:	97ba                	add	a5,a5,a4
ffffffffc02004e6:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004ea:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004ee:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f0:	e591                	bnez	a1,ffffffffc02004fc <kmonitor+0x11e>
ffffffffc02004f2:	b7b5                	j	ffffffffc020045e <kmonitor+0x80>
ffffffffc02004f4:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02004f8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fa:	d1a5                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004fc:	8526                	mv	a0,s1
ffffffffc02004fe:	4dd050ef          	jal	ra,ffffffffc02061da <strchr>
ffffffffc0200502:	d96d                	beqz	a0,ffffffffc02004f4 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	d9a9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc020050a:	bf55                	j	ffffffffc02004be <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020050c:	45c1                	li	a1,16
ffffffffc020050e:	855a                	mv	a0,s6
ffffffffc0200510:	bbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200514:	b7e9                	j	ffffffffc02004de <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200516:	6582                	ld	a1,0(sp)
ffffffffc0200518:	00006517          	auipc	a0,0x6
ffffffffc020051c:	39850513          	addi	a0,a0,920 # ffffffffc02068b0 <etext+0x292>
ffffffffc0200520:	badff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc0200524:	b715                	j	ffffffffc0200448 <kmonitor+0x6a>

ffffffffc0200526 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200526:	8082                	ret

ffffffffc0200528 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200528:	00253513          	sltiu	a0,a0,2
ffffffffc020052c:	8082                	ret

ffffffffc020052e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020052e:	03800513          	li	a0,56
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200534:	000a7797          	auipc	a5,0xa7
ffffffffc0200538:	1fc78793          	addi	a5,a5,508 # ffffffffc02a7730 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020053c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200540:	1141                	addi	sp,sp,-16
ffffffffc0200542:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200544:	95be                	add	a1,a1,a5
ffffffffc0200546:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020054a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020054c:	4b7050ef          	jal	ra,ffffffffc0206202 <memcpy>
    return 0;
}
ffffffffc0200550:	60a2                	ld	ra,8(sp)
ffffffffc0200552:	4501                	li	a0,0
ffffffffc0200554:	0141                	addi	sp,sp,16
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200558:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020055c:	000a7517          	auipc	a0,0xa7
ffffffffc0200560:	1d450513          	addi	a0,a0,468 # ffffffffc02a7730 <ide>
                   size_t nsecs) {
ffffffffc0200564:	1141                	addi	sp,sp,-16
ffffffffc0200566:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200568:	953e                	add	a0,a0,a5
ffffffffc020056a:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200570:	493050ef          	jal	ra,ffffffffc0206202 <memcpy>
    return 0;
}
ffffffffc0200574:	60a2                	ld	ra,8(sp)
ffffffffc0200576:	4501                	li	a0,0
ffffffffc0200578:	0141                	addi	sp,sp,16
ffffffffc020057a:	8082                	ret

ffffffffc020057c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020057c:	67e1                	lui	a5,0x18
ffffffffc020057e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd578>
ffffffffc0200582:	000b2717          	auipc	a4,0xb2
ffffffffc0200586:	28f73323          	sd	a5,646(a4) # ffffffffc02b2808 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020058a:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020058e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200590:	953e                	add	a0,a0,a5
ffffffffc0200592:	4601                	li	a2,0
ffffffffc0200594:	4881                	li	a7,0
ffffffffc0200596:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020059a:	02000793          	li	a5,32
ffffffffc020059e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005a2:	00006517          	auipc	a0,0x6
ffffffffc02005a6:	36e50513          	addi	a0,a0,878 # ffffffffc0206910 <commands+0x48>
    ticks = 0;
ffffffffc02005aa:	000b2797          	auipc	a5,0xb2
ffffffffc02005ae:	2407bb23          	sd	zero,598(a5) # ffffffffc02b2800 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b2:	be29                	j	ffffffffc02000cc <cprintf>

ffffffffc02005b4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005b4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005b8:	000b2797          	auipc	a5,0xb2
ffffffffc02005bc:	2507b783          	ld	a5,592(a5) # ffffffffc02b2808 <timebase>
ffffffffc02005c0:	953e                	add	a0,a0,a5
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4881                	li	a7,0
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	8082                	ret

ffffffffc02005ce <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005d0:	100027f3          	csrr	a5,sstatus
ffffffffc02005d4:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005d6:	0ff57513          	zext.b	a0,a0
ffffffffc02005da:	e799                	bnez	a5,ffffffffc02005e8 <cons_putc+0x18>
ffffffffc02005dc:	4581                	li	a1,0
ffffffffc02005de:	4601                	li	a2,0
ffffffffc02005e0:	4885                	li	a7,1
ffffffffc02005e2:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005e6:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005e8:	1101                	addi	sp,sp,-32
ffffffffc02005ea:	ec06                	sd	ra,24(sp)
ffffffffc02005ec:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ee:	05a000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02005f2:	6522                	ld	a0,8(sp)
ffffffffc02005f4:	4581                	li	a1,0
ffffffffc02005f6:	4601                	li	a2,0
ffffffffc02005f8:	4885                	li	a7,1
ffffffffc02005fa:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005fe:	60e2                	ld	ra,24(sp)
ffffffffc0200600:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200602:	a081                	j	ffffffffc0200642 <intr_enable>

ffffffffc0200604 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200604:	100027f3          	csrr	a5,sstatus
ffffffffc0200608:	8b89                	andi	a5,a5,2
ffffffffc020060a:	eb89                	bnez	a5,ffffffffc020061c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020060c:	4501                	li	a0,0
ffffffffc020060e:	4581                	li	a1,0
ffffffffc0200610:	4601                	li	a2,0
ffffffffc0200612:	4889                	li	a7,2
ffffffffc0200614:	00000073          	ecall
ffffffffc0200618:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020061a:	8082                	ret
int cons_getc(void) {
ffffffffc020061c:	1101                	addi	sp,sp,-32
ffffffffc020061e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200620:	028000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0200624:	4501                	li	a0,0
ffffffffc0200626:	4581                	li	a1,0
ffffffffc0200628:	4601                	li	a2,0
ffffffffc020062a:	4889                	li	a7,2
ffffffffc020062c:	00000073          	ecall
ffffffffc0200630:	2501                	sext.w	a0,a0
ffffffffc0200632:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200634:	00e000ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0200638:	60e2                	ld	ra,24(sp)
ffffffffc020063a:	6522                	ld	a0,8(sp)
ffffffffc020063c:	6105                	addi	sp,sp,32
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200640:	8082                	ret

ffffffffc0200642 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200642:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200648:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	6a278793          	addi	a5,a5,1698 # ffffffffc0200cf4 <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	2c050513          	addi	a0,a0,704 # ffffffffc0206930 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	a53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	2c850513          	addi	a0,a0,712 # ffffffffc0206948 <commands+0x80>
ffffffffc0200688:	a45ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	2d250513          	addi	a0,a0,722 # ffffffffc0206960 <commands+0x98>
ffffffffc0200696:	a37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	2dc50513          	addi	a0,a0,732 # ffffffffc0206978 <commands+0xb0>
ffffffffc02006a4:	a29ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	2e650513          	addi	a0,a0,742 # ffffffffc0206990 <commands+0xc8>
ffffffffc02006b2:	a1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	2f050513          	addi	a0,a0,752 # ffffffffc02069a8 <commands+0xe0>
ffffffffc02006c0:	a0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	2fa50513          	addi	a0,a0,762 # ffffffffc02069c0 <commands+0xf8>
ffffffffc02006ce:	9ffff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	30450513          	addi	a0,a0,772 # ffffffffc02069d8 <commands+0x110>
ffffffffc02006dc:	9f1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	30e50513          	addi	a0,a0,782 # ffffffffc02069f0 <commands+0x128>
ffffffffc02006ea:	9e3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	31850513          	addi	a0,a0,792 # ffffffffc0206a08 <commands+0x140>
ffffffffc02006f8:	9d5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	32250513          	addi	a0,a0,802 # ffffffffc0206a20 <commands+0x158>
ffffffffc0200706:	9c7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	32c50513          	addi	a0,a0,812 # ffffffffc0206a38 <commands+0x170>
ffffffffc0200714:	9b9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	33650513          	addi	a0,a0,822 # ffffffffc0206a50 <commands+0x188>
ffffffffc0200722:	9abff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	34050513          	addi	a0,a0,832 # ffffffffc0206a68 <commands+0x1a0>
ffffffffc0200730:	99dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	34a50513          	addi	a0,a0,842 # ffffffffc0206a80 <commands+0x1b8>
ffffffffc020073e:	98fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	35450513          	addi	a0,a0,852 # ffffffffc0206a98 <commands+0x1d0>
ffffffffc020074c:	981ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	35e50513          	addi	a0,a0,862 # ffffffffc0206ab0 <commands+0x1e8>
ffffffffc020075a:	973ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	36850513          	addi	a0,a0,872 # ffffffffc0206ac8 <commands+0x200>
ffffffffc0200768:	965ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	37250513          	addi	a0,a0,882 # ffffffffc0206ae0 <commands+0x218>
ffffffffc0200776:	957ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	37c50513          	addi	a0,a0,892 # ffffffffc0206af8 <commands+0x230>
ffffffffc0200784:	949ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	38650513          	addi	a0,a0,902 # ffffffffc0206b10 <commands+0x248>
ffffffffc0200792:	93bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	39050513          	addi	a0,a0,912 # ffffffffc0206b28 <commands+0x260>
ffffffffc02007a0:	92dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	39a50513          	addi	a0,a0,922 # ffffffffc0206b40 <commands+0x278>
ffffffffc02007ae:	91fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	3a450513          	addi	a0,a0,932 # ffffffffc0206b58 <commands+0x290>
ffffffffc02007bc:	911ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	3ae50513          	addi	a0,a0,942 # ffffffffc0206b70 <commands+0x2a8>
ffffffffc02007ca:	903ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	3b850513          	addi	a0,a0,952 # ffffffffc0206b88 <commands+0x2c0>
ffffffffc02007d8:	8f5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	3c250513          	addi	a0,a0,962 # ffffffffc0206ba0 <commands+0x2d8>
ffffffffc02007e6:	8e7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	3cc50513          	addi	a0,a0,972 # ffffffffc0206bb8 <commands+0x2f0>
ffffffffc02007f4:	8d9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	3d650513          	addi	a0,a0,982 # ffffffffc0206bd0 <commands+0x308>
ffffffffc0200802:	8cbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	3e050513          	addi	a0,a0,992 # ffffffffc0206be8 <commands+0x320>
ffffffffc0200810:	8bdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206c00 <commands+0x338>
ffffffffc020081e:	8afff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	3f050513          	addi	a0,a0,1008 # ffffffffc0206c18 <commands+0x350>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	89bff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200836 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	1141                	addi	sp,sp,-16
ffffffffc0200838:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083a:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	00006517          	auipc	a0,0x6
ffffffffc0200842:	3f250513          	addi	a0,a0,1010 # ffffffffc0206c30 <commands+0x368>
print_trapframe(struct trapframe *tf) {
ffffffffc0200846:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200848:	885ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084c:	8522                	mv	a0,s0
ffffffffc020084e:	e1bff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200852:	10043583          	ld	a1,256(s0)
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	3f250513          	addi	a0,a0,1010 # ffffffffc0206c48 <commands+0x380>
ffffffffc020085e:	86fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200862:	10843583          	ld	a1,264(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206c60 <commands+0x398>
ffffffffc020086e:	85fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200872:	11043583          	ld	a1,272(s0)
ffffffffc0200876:	00006517          	auipc	a0,0x6
ffffffffc020087a:	40250513          	addi	a0,a0,1026 # ffffffffc0206c78 <commands+0x3b0>
ffffffffc020087e:	84fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	11843583          	ld	a1,280(s0)
}
ffffffffc0200886:	6402                	ld	s0,0(sp)
ffffffffc0200888:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206c88 <commands+0x3c0>
}
ffffffffc0200892:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200894:	839ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200898 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200898:	1101                	addi	sp,sp,-32
ffffffffc020089a:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089c:	000b2497          	auipc	s1,0xb2
ffffffffc02008a0:	fa448493          	addi	s1,s1,-92 # ffffffffc02b2840 <check_mm_struct>
ffffffffc02008a4:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a6:	e822                	sd	s0,16(sp)
ffffffffc02008a8:	ec06                	sd	ra,24(sp)
ffffffffc02008aa:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008ac:	cbad                	beqz	a5,ffffffffc020091e <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ae:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b2:	11053583          	ld	a1,272(a0)
ffffffffc02008b6:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	c7b1                	beqz	a5,ffffffffc020090a <pgfault_handler+0x72>
ffffffffc02008c0:	11843703          	ld	a4,280(s0)
ffffffffc02008c4:	47bd                	li	a5,15
ffffffffc02008c6:	05700693          	li	a3,87
ffffffffc02008ca:	00f70463          	beq	a4,a5,ffffffffc02008d2 <pgfault_handler+0x3a>
ffffffffc02008ce:	05200693          	li	a3,82
ffffffffc02008d2:	00006517          	auipc	a0,0x6
ffffffffc02008d6:	3ce50513          	addi	a0,a0,974 # ffffffffc0206ca0 <commands+0x3d8>
ffffffffc02008da:	ff2ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008de:	6088                	ld	a0,0(s1)
ffffffffc02008e0:	cd1d                	beqz	a0,ffffffffc020091e <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e2:	000b2717          	auipc	a4,0xb2
ffffffffc02008e6:	f8e73703          	ld	a4,-114(a4) # ffffffffc02b2870 <current>
ffffffffc02008ea:	000b2797          	auipc	a5,0xb2
ffffffffc02008ee:	f8e7b783          	ld	a5,-114(a5) # ffffffffc02b2878 <idleproc>
ffffffffc02008f2:	04f71663          	bne	a4,a5,ffffffffc020093e <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f6:	11043603          	ld	a2,272(s0)
ffffffffc02008fa:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fe:	6442                	ld	s0,16(sp)
ffffffffc0200900:	60e2                	ld	ra,24(sp)
ffffffffc0200902:	64a2                	ld	s1,8(sp)
ffffffffc0200904:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	1ad0206f          	j	ffffffffc02032b2 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020090a:	11843703          	ld	a4,280(s0)
ffffffffc020090e:	47bd                	li	a5,15
ffffffffc0200910:	05500613          	li	a2,85
ffffffffc0200914:	05700693          	li	a3,87
ffffffffc0200918:	faf71be3          	bne	a4,a5,ffffffffc02008ce <pgfault_handler+0x36>
ffffffffc020091c:	bf5d                	j	ffffffffc02008d2 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091e:	000b2797          	auipc	a5,0xb2
ffffffffc0200922:	f527b783          	ld	a5,-174(a5) # ffffffffc02b2870 <current>
ffffffffc0200926:	cf85                	beqz	a5,ffffffffc020095e <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200928:	11043603          	ld	a2,272(s0)
ffffffffc020092c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200930:	6442                	ld	s0,16(sp)
ffffffffc0200932:	60e2                	ld	ra,24(sp)
ffffffffc0200934:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200936:	7788                	ld	a0,40(a5)
}
ffffffffc0200938:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	1790206f          	j	ffffffffc02032b2 <do_pgfault>
        assert(current == idleproc);
ffffffffc020093e:	00006697          	auipc	a3,0x6
ffffffffc0200942:	38268693          	addi	a3,a3,898 # ffffffffc0206cc0 <commands+0x3f8>
ffffffffc0200946:	00006617          	auipc	a2,0x6
ffffffffc020094a:	39260613          	addi	a2,a2,914 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020094e:	06b00593          	li	a1,107
ffffffffc0200952:	00006517          	auipc	a0,0x6
ffffffffc0200956:	39e50513          	addi	a0,a0,926 # ffffffffc0206cf0 <commands+0x428>
ffffffffc020095a:	8afff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc020095e:	8522                	mv	a0,s0
ffffffffc0200960:	ed7ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200964:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200968:	11043583          	ld	a1,272(s0)
ffffffffc020096c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200970:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200974:	e399                	bnez	a5,ffffffffc020097a <pgfault_handler+0xe2>
ffffffffc0200976:	05500613          	li	a2,85
ffffffffc020097a:	11843703          	ld	a4,280(s0)
ffffffffc020097e:	47bd                	li	a5,15
ffffffffc0200980:	02f70663          	beq	a4,a5,ffffffffc02009ac <pgfault_handler+0x114>
ffffffffc0200984:	05200693          	li	a3,82
ffffffffc0200988:	00006517          	auipc	a0,0x6
ffffffffc020098c:	31850513          	addi	a0,a0,792 # ffffffffc0206ca0 <commands+0x3d8>
ffffffffc0200990:	f3cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200994:	00006617          	auipc	a2,0x6
ffffffffc0200998:	37460613          	addi	a2,a2,884 # ffffffffc0206d08 <commands+0x440>
ffffffffc020099c:	07200593          	li	a1,114
ffffffffc02009a0:	00006517          	auipc	a0,0x6
ffffffffc02009a4:	35050513          	addi	a0,a0,848 # ffffffffc0206cf0 <commands+0x428>
ffffffffc02009a8:	861ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009ac:	05700693          	li	a3,87
ffffffffc02009b0:	bfe1                	j	ffffffffc0200988 <pgfault_handler+0xf0>

ffffffffc02009b2 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b2:	11853783          	ld	a5,280(a0)
ffffffffc02009b6:	472d                	li	a4,11
ffffffffc02009b8:	0786                	slli	a5,a5,0x1
ffffffffc02009ba:	8385                	srli	a5,a5,0x1
ffffffffc02009bc:	08f76363          	bltu	a4,a5,ffffffffc0200a42 <interrupt_handler+0x90>
ffffffffc02009c0:	00006717          	auipc	a4,0x6
ffffffffc02009c4:	40070713          	addi	a4,a4,1024 # ffffffffc0206dc0 <commands+0x4f8>
ffffffffc02009c8:	078a                	slli	a5,a5,0x2
ffffffffc02009ca:	97ba                	add	a5,a5,a4
ffffffffc02009cc:	439c                	lw	a5,0(a5)
ffffffffc02009ce:	97ba                	add	a5,a5,a4
ffffffffc02009d0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	3ae50513          	addi	a0,a0,942 # ffffffffc0206d80 <commands+0x4b8>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009de:	00006517          	auipc	a0,0x6
ffffffffc02009e2:	38250513          	addi	a0,a0,898 # ffffffffc0206d60 <commands+0x498>
ffffffffc02009e6:	ee6ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009ea:	00006517          	auipc	a0,0x6
ffffffffc02009ee:	33650513          	addi	a0,a0,822 # ffffffffc0206d20 <commands+0x458>
ffffffffc02009f2:	edaff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f6:	00006517          	auipc	a0,0x6
ffffffffc02009fa:	34a50513          	addi	a0,a0,842 # ffffffffc0206d40 <commands+0x478>
ffffffffc02009fe:	eceff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a02:	1141                	addi	sp,sp,-16
ffffffffc0200a04:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a06:	bafff0ef          	jal	ra,ffffffffc02005b4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a0a:	000b2697          	auipc	a3,0xb2
ffffffffc0200a0e:	df668693          	addi	a3,a3,-522 # ffffffffc02b2800 <ticks>
ffffffffc0200a12:	629c                	ld	a5,0(a3)
ffffffffc0200a14:	06400713          	li	a4,100
ffffffffc0200a18:	0785                	addi	a5,a5,1
ffffffffc0200a1a:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1e:	e29c                	sd	a5,0(a3)
ffffffffc0200a20:	eb01                	bnez	a4,ffffffffc0200a30 <interrupt_handler+0x7e>
ffffffffc0200a22:	000b2797          	auipc	a5,0xb2
ffffffffc0200a26:	e4e7b783          	ld	a5,-434(a5) # ffffffffc02b2870 <current>
ffffffffc0200a2a:	c399                	beqz	a5,ffffffffc0200a30 <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2c:	4705                	li	a4,1
ffffffffc0200a2e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a30:	60a2                	ld	ra,8(sp)
ffffffffc0200a32:	0141                	addi	sp,sp,16
ffffffffc0200a34:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a36:	00006517          	auipc	a0,0x6
ffffffffc0200a3a:	36a50513          	addi	a0,a0,874 # ffffffffc0206da0 <commands+0x4d8>
ffffffffc0200a3e:	e8eff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200a42:	bbd5                	j	ffffffffc0200836 <print_trapframe>

ffffffffc0200a44 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a44:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a48:	1101                	addi	sp,sp,-32
ffffffffc0200a4a:	e822                	sd	s0,16(sp)
ffffffffc0200a4c:	ec06                	sd	ra,24(sp)
ffffffffc0200a4e:	e426                	sd	s1,8(sp)
ffffffffc0200a50:	473d                	li	a4,15
ffffffffc0200a52:	842a                	mv	s0,a0
ffffffffc0200a54:	1af76563          	bltu	a4,a5,ffffffffc0200bfe <exception_handler+0x1ba>
ffffffffc0200a58:	00006717          	auipc	a4,0x6
ffffffffc0200a5c:	5a870713          	addi	a4,a4,1448 # ffffffffc0207000 <commands+0x738>
ffffffffc0200a60:	078a                	slli	a5,a5,0x2
ffffffffc0200a62:	97ba                	add	a5,a5,a4
ffffffffc0200a64:	439c                	lw	a5,0(a5)
ffffffffc0200a66:	97ba                	add	a5,a5,a4
ffffffffc0200a68:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a6a:	00006517          	auipc	a0,0x6
ffffffffc0200a6e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206f58 <commands+0x690>
ffffffffc0200a72:	e5aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc += 4;
ffffffffc0200a76:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a7a:	60e2                	ld	ra,24(sp)
ffffffffc0200a7c:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7e:	0791                	addi	a5,a5,4
ffffffffc0200a80:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a84:	6442                	ld	s0,16(sp)
ffffffffc0200a86:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a88:	66c0506f          	j	ffffffffc02060f4 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8c:	00006517          	auipc	a0,0x6
ffffffffc0200a90:	4ec50513          	addi	a0,a0,1260 # ffffffffc0206f78 <commands+0x6b0>
}
ffffffffc0200a94:	6442                	ld	s0,16(sp)
ffffffffc0200a96:	60e2                	ld	ra,24(sp)
ffffffffc0200a98:	64a2                	ld	s1,8(sp)
ffffffffc0200a9a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9c:	e30ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa0:	00006517          	auipc	a0,0x6
ffffffffc0200aa4:	4f850513          	addi	a0,a0,1272 # ffffffffc0206f98 <commands+0x6d0>
ffffffffc0200aa8:	b7f5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aaa:	00006517          	auipc	a0,0x6
ffffffffc0200aae:	50e50513          	addi	a0,a0,1294 # ffffffffc0206fb8 <commands+0x6f0>
ffffffffc0200ab2:	b7cd                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	51c50513          	addi	a0,a0,1308 # ffffffffc0206fd0 <commands+0x708>
ffffffffc0200abc:	e10ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac0:	8522                	mv	a0,s0
ffffffffc0200ac2:	dd7ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ac6:	84aa                	mv	s1,a0
ffffffffc0200ac8:	18051163          	bnez	a0,ffffffffc0200c4a <exception_handler+0x206>
}
ffffffffc0200acc:	60e2                	ld	ra,24(sp)
ffffffffc0200ace:	6442                	ld	s0,16(sp)
ffffffffc0200ad0:	64a2                	ld	s1,8(sp)
ffffffffc0200ad2:	6105                	addi	sp,sp,32
ffffffffc0200ad4:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad6:	00006517          	auipc	a0,0x6
ffffffffc0200ada:	51250513          	addi	a0,a0,1298 # ffffffffc0206fe8 <commands+0x720>
ffffffffc0200ade:	deeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae2:	8522                	mv	a0,s0
ffffffffc0200ae4:	db5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ae8:	84aa                	mv	s1,a0
ffffffffc0200aea:	d16d                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aec:	8522                	mv	a0,s0
ffffffffc0200aee:	d49ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af2:	86a6                	mv	a3,s1
ffffffffc0200af4:	00006617          	auipc	a2,0x6
ffffffffc0200af8:	41460613          	addi	a2,a2,1044 # ffffffffc0206f08 <commands+0x640>
ffffffffc0200afc:	0fe00593          	li	a1,254
ffffffffc0200b00:	00006517          	auipc	a0,0x6
ffffffffc0200b04:	1f050513          	addi	a0,a0,496 # ffffffffc0206cf0 <commands+0x428>
ffffffffc0200b08:	f00ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0c:	00006517          	auipc	a0,0x6
ffffffffc0200b10:	2e450513          	addi	a0,a0,740 # ffffffffc0206df0 <commands+0x528>
ffffffffc0200b14:	b741                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b16:	00006517          	auipc	a0,0x6
ffffffffc0200b1a:	2fa50513          	addi	a0,a0,762 # ffffffffc0206e10 <commands+0x548>
ffffffffc0200b1e:	bf9d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Exception type: Illegal instruction\n");
ffffffffc0200b20:	00006517          	auipc	a0,0x6
ffffffffc0200b24:	31050513          	addi	a0,a0,784 # ffffffffc0206e30 <commands+0x568>
ffffffffc0200b28:	da4ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n\n",tf->epc);
ffffffffc0200b2c:	10843583          	ld	a1,264(s0)
ffffffffc0200b30:	00006517          	auipc	a0,0x6
ffffffffc0200b34:	32850513          	addi	a0,a0,808 # ffffffffc0206e58 <commands+0x590>
ffffffffc0200b38:	d94ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc = tf->epc + 4 ;
ffffffffc0200b3c:	10843783          	ld	a5,264(s0)
ffffffffc0200b40:	0791                	addi	a5,a5,4
ffffffffc0200b42:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200b46:	b759                	j	ffffffffc0200acc <exception_handler+0x88>
            cprintf("Breakpoint\n");
ffffffffc0200b48:	00006517          	auipc	a0,0x6
ffffffffc0200b4c:	33850513          	addi	a0,a0,824 # ffffffffc0206e80 <commands+0x5b8>
ffffffffc0200b50:	d7cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b54:	6458                	ld	a4,136(s0)
ffffffffc0200b56:	47a9                	li	a5,10
ffffffffc0200b58:	0cf70563          	beq	a4,a5,ffffffffc0200c22 <exception_handler+0x1de>
                cprintf("Exception type: breakpoint\n");
ffffffffc0200b5c:	00006517          	auipc	a0,0x6
ffffffffc0200b60:	33450513          	addi	a0,a0,820 # ffffffffc0206e90 <commands+0x5c8>
ffffffffc0200b64:	d68ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
                cprintf("ebreak caught at 0x%08x\n\n",tf->epc);
ffffffffc0200b68:	10843583          	ld	a1,264(s0)
ffffffffc0200b6c:	00006517          	auipc	a0,0x6
ffffffffc0200b70:	34450513          	addi	a0,a0,836 # ffffffffc0206eb0 <commands+0x5e8>
ffffffffc0200b74:	d58ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
                tf->epc = tf->epc + 2;
ffffffffc0200b78:	10843783          	ld	a5,264(s0)
ffffffffc0200b7c:	0789                	addi	a5,a5,2
ffffffffc0200b7e:	10f43423          	sd	a5,264(s0)
ffffffffc0200b82:	b7a9                	j	ffffffffc0200acc <exception_handler+0x88>
            cprintf("Load address misaligned\n");
ffffffffc0200b84:	00006517          	auipc	a0,0x6
ffffffffc0200b88:	34c50513          	addi	a0,a0,844 # ffffffffc0206ed0 <commands+0x608>
ffffffffc0200b8c:	b721                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b8e:	00006517          	auipc	a0,0x6
ffffffffc0200b92:	36250513          	addi	a0,a0,866 # ffffffffc0206ef0 <commands+0x628>
ffffffffc0200b96:	d36ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b9a:	8522                	mv	a0,s0
ffffffffc0200b9c:	cfdff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ba0:	84aa                	mv	s1,a0
ffffffffc0200ba2:	f20505e3          	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	c8fff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bac:	86a6                	mv	a3,s1
ffffffffc0200bae:	00006617          	auipc	a2,0x6
ffffffffc0200bb2:	35a60613          	addi	a2,a2,858 # ffffffffc0206f08 <commands+0x640>
ffffffffc0200bb6:	0d300593          	li	a1,211
ffffffffc0200bba:	00006517          	auipc	a0,0x6
ffffffffc0200bbe:	13650513          	addi	a0,a0,310 # ffffffffc0206cf0 <commands+0x428>
ffffffffc0200bc2:	e46ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bc6:	00006517          	auipc	a0,0x6
ffffffffc0200bca:	37a50513          	addi	a0,a0,890 # ffffffffc0206f40 <commands+0x678>
ffffffffc0200bce:	cfeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bd2:	8522                	mv	a0,s0
ffffffffc0200bd4:	cc5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200bd8:	84aa                	mv	s1,a0
ffffffffc0200bda:	ee0509e3          	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bde:	8522                	mv	a0,s0
ffffffffc0200be0:	c57ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be4:	86a6                	mv	a3,s1
ffffffffc0200be6:	00006617          	auipc	a2,0x6
ffffffffc0200bea:	32260613          	addi	a2,a2,802 # ffffffffc0206f08 <commands+0x640>
ffffffffc0200bee:	0dd00593          	li	a1,221
ffffffffc0200bf2:	00006517          	auipc	a0,0x6
ffffffffc0200bf6:	0fe50513          	addi	a0,a0,254 # ffffffffc0206cf0 <commands+0x428>
ffffffffc0200bfa:	e0eff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200bfe:	8522                	mv	a0,s0
}
ffffffffc0200c00:	6442                	ld	s0,16(sp)
ffffffffc0200c02:	60e2                	ld	ra,24(sp)
ffffffffc0200c04:	64a2                	ld	s1,8(sp)
ffffffffc0200c06:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c08:	b13d                	j	ffffffffc0200836 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c0a:	00006617          	auipc	a2,0x6
ffffffffc0200c0e:	31e60613          	addi	a2,a2,798 # ffffffffc0206f28 <commands+0x660>
ffffffffc0200c12:	0d700593          	li	a1,215
ffffffffc0200c16:	00006517          	auipc	a0,0x6
ffffffffc0200c1a:	0da50513          	addi	a0,a0,218 # ffffffffc0206cf0 <commands+0x428>
ffffffffc0200c1e:	deaff0ef          	jal	ra,ffffffffc0200208 <__panic>
                tf->epc += 4;
ffffffffc0200c22:	10843783          	ld	a5,264(s0)
ffffffffc0200c26:	0791                	addi	a5,a5,4
ffffffffc0200c28:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200c2c:	4c8050ef          	jal	ra,ffffffffc02060f4 <syscall>
                kernel_execve_ret(tf, current->kstack+KSTACKSIZE); 
ffffffffc0200c30:	000b2797          	auipc	a5,0xb2
ffffffffc0200c34:	c407b783          	ld	a5,-960(a5) # ffffffffc02b2870 <current>
ffffffffc0200c38:	6b9c                	ld	a5,16(a5)
ffffffffc0200c3a:	8522                	mv	a0,s0
}
ffffffffc0200c3c:	6442                	ld	s0,16(sp)
ffffffffc0200c3e:	60e2                	ld	ra,24(sp)
ffffffffc0200c40:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf, current->kstack+KSTACKSIZE); 
ffffffffc0200c42:	6589                	lui	a1,0x2
ffffffffc0200c44:	95be                	add	a1,a1,a5
}
ffffffffc0200c46:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf, current->kstack+KSTACKSIZE); 
ffffffffc0200c48:	aaad                	j	ffffffffc0200dc2 <kernel_execve_ret>
                print_trapframe(tf);
ffffffffc0200c4a:	8522                	mv	a0,s0
ffffffffc0200c4c:	bebff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c50:	86a6                	mv	a3,s1
ffffffffc0200c52:	00006617          	auipc	a2,0x6
ffffffffc0200c56:	2b660613          	addi	a2,a2,694 # ffffffffc0206f08 <commands+0x640>
ffffffffc0200c5a:	0f700593          	li	a1,247
ffffffffc0200c5e:	00006517          	auipc	a0,0x6
ffffffffc0200c62:	09250513          	addi	a0,a0,146 # ffffffffc0206cf0 <commands+0x428>
ffffffffc0200c66:	da2ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200c6a <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c6a:	1101                	addi	sp,sp,-32
ffffffffc0200c6c:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c6e:	000b2417          	auipc	s0,0xb2
ffffffffc0200c72:	c0240413          	addi	s0,s0,-1022 # ffffffffc02b2870 <current>
ffffffffc0200c76:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c78:	ec06                	sd	ra,24(sp)
ffffffffc0200c7a:	e426                	sd	s1,8(sp)
ffffffffc0200c7c:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c7e:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c82:	cf1d                	beqz	a4,ffffffffc0200cc0 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c84:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c88:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c8c:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c8e:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c92:	0206c463          	bltz	a3,ffffffffc0200cba <trap+0x50>
        exception_handler(tf);
ffffffffc0200c96:	dafff0ef          	jal	ra,ffffffffc0200a44 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c9a:	601c                	ld	a5,0(s0)
ffffffffc0200c9c:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200ca0:	e499                	bnez	s1,ffffffffc0200cae <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200ca2:	0b07a703          	lw	a4,176(a5)
ffffffffc0200ca6:	8b05                	andi	a4,a4,1
ffffffffc0200ca8:	e329                	bnez	a4,ffffffffc0200cea <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200caa:	6f9c                	ld	a5,24(a5)
ffffffffc0200cac:	eb85                	bnez	a5,ffffffffc0200cdc <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200cae:	60e2                	ld	ra,24(sp)
ffffffffc0200cb0:	6442                	ld	s0,16(sp)
ffffffffc0200cb2:	64a2                	ld	s1,8(sp)
ffffffffc0200cb4:	6902                	ld	s2,0(sp)
ffffffffc0200cb6:	6105                	addi	sp,sp,32
ffffffffc0200cb8:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200cba:	cf9ff0ef          	jal	ra,ffffffffc02009b2 <interrupt_handler>
ffffffffc0200cbe:	bff1                	j	ffffffffc0200c9a <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200cc0:	0006c863          	bltz	a3,ffffffffc0200cd0 <trap+0x66>
}
ffffffffc0200cc4:	6442                	ld	s0,16(sp)
ffffffffc0200cc6:	60e2                	ld	ra,24(sp)
ffffffffc0200cc8:	64a2                	ld	s1,8(sp)
ffffffffc0200cca:	6902                	ld	s2,0(sp)
ffffffffc0200ccc:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cce:	bb9d                	j	ffffffffc0200a44 <exception_handler>
}
ffffffffc0200cd0:	6442                	ld	s0,16(sp)
ffffffffc0200cd2:	60e2                	ld	ra,24(sp)
ffffffffc0200cd4:	64a2                	ld	s1,8(sp)
ffffffffc0200cd6:	6902                	ld	s2,0(sp)
ffffffffc0200cd8:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cda:	b9e1                	j	ffffffffc02009b2 <interrupt_handler>
}
ffffffffc0200cdc:	6442                	ld	s0,16(sp)
ffffffffc0200cde:	60e2                	ld	ra,24(sp)
ffffffffc0200ce0:	64a2                	ld	s1,8(sp)
ffffffffc0200ce2:	6902                	ld	s2,0(sp)
ffffffffc0200ce4:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200ce6:	3220506f          	j	ffffffffc0206008 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cea:	555d                	li	a0,-9
ffffffffc0200cec:	6d0040ef          	jal	ra,ffffffffc02053bc <do_exit>
            if (current->need_resched) {
ffffffffc0200cf0:	601c                	ld	a5,0(s0)
ffffffffc0200cf2:	bf65                	j	ffffffffc0200caa <trap+0x40>

ffffffffc0200cf4 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cf4:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cf8:	00011463          	bnez	sp,ffffffffc0200d00 <__alltraps+0xc>
ffffffffc0200cfc:	14002173          	csrr	sp,sscratch
ffffffffc0200d00:	712d                	addi	sp,sp,-288
ffffffffc0200d02:	e002                	sd	zero,0(sp)
ffffffffc0200d04:	e406                	sd	ra,8(sp)
ffffffffc0200d06:	ec0e                	sd	gp,24(sp)
ffffffffc0200d08:	f012                	sd	tp,32(sp)
ffffffffc0200d0a:	f416                	sd	t0,40(sp)
ffffffffc0200d0c:	f81a                	sd	t1,48(sp)
ffffffffc0200d0e:	fc1e                	sd	t2,56(sp)
ffffffffc0200d10:	e0a2                	sd	s0,64(sp)
ffffffffc0200d12:	e4a6                	sd	s1,72(sp)
ffffffffc0200d14:	e8aa                	sd	a0,80(sp)
ffffffffc0200d16:	ecae                	sd	a1,88(sp)
ffffffffc0200d18:	f0b2                	sd	a2,96(sp)
ffffffffc0200d1a:	f4b6                	sd	a3,104(sp)
ffffffffc0200d1c:	f8ba                	sd	a4,112(sp)
ffffffffc0200d1e:	fcbe                	sd	a5,120(sp)
ffffffffc0200d20:	e142                	sd	a6,128(sp)
ffffffffc0200d22:	e546                	sd	a7,136(sp)
ffffffffc0200d24:	e94a                	sd	s2,144(sp)
ffffffffc0200d26:	ed4e                	sd	s3,152(sp)
ffffffffc0200d28:	f152                	sd	s4,160(sp)
ffffffffc0200d2a:	f556                	sd	s5,168(sp)
ffffffffc0200d2c:	f95a                	sd	s6,176(sp)
ffffffffc0200d2e:	fd5e                	sd	s7,184(sp)
ffffffffc0200d30:	e1e2                	sd	s8,192(sp)
ffffffffc0200d32:	e5e6                	sd	s9,200(sp)
ffffffffc0200d34:	e9ea                	sd	s10,208(sp)
ffffffffc0200d36:	edee                	sd	s11,216(sp)
ffffffffc0200d38:	f1f2                	sd	t3,224(sp)
ffffffffc0200d3a:	f5f6                	sd	t4,232(sp)
ffffffffc0200d3c:	f9fa                	sd	t5,240(sp)
ffffffffc0200d3e:	fdfe                	sd	t6,248(sp)
ffffffffc0200d40:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d44:	100024f3          	csrr	s1,sstatus
ffffffffc0200d48:	14102973          	csrr	s2,sepc
ffffffffc0200d4c:	143029f3          	csrr	s3,stval
ffffffffc0200d50:	14202a73          	csrr	s4,scause
ffffffffc0200d54:	e822                	sd	s0,16(sp)
ffffffffc0200d56:	e226                	sd	s1,256(sp)
ffffffffc0200d58:	e64a                	sd	s2,264(sp)
ffffffffc0200d5a:	ea4e                	sd	s3,272(sp)
ffffffffc0200d5c:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d5e:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d60:	f0bff0ef          	jal	ra,ffffffffc0200c6a <trap>

ffffffffc0200d64 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d64:	6492                	ld	s1,256(sp)
ffffffffc0200d66:	6932                	ld	s2,264(sp)
ffffffffc0200d68:	1004f413          	andi	s0,s1,256
ffffffffc0200d6c:	e401                	bnez	s0,ffffffffc0200d74 <__trapret+0x10>
ffffffffc0200d6e:	1200                	addi	s0,sp,288
ffffffffc0200d70:	14041073          	csrw	sscratch,s0
ffffffffc0200d74:	10049073          	csrw	sstatus,s1
ffffffffc0200d78:	14191073          	csrw	sepc,s2
ffffffffc0200d7c:	60a2                	ld	ra,8(sp)
ffffffffc0200d7e:	61e2                	ld	gp,24(sp)
ffffffffc0200d80:	7202                	ld	tp,32(sp)
ffffffffc0200d82:	72a2                	ld	t0,40(sp)
ffffffffc0200d84:	7342                	ld	t1,48(sp)
ffffffffc0200d86:	73e2                	ld	t2,56(sp)
ffffffffc0200d88:	6406                	ld	s0,64(sp)
ffffffffc0200d8a:	64a6                	ld	s1,72(sp)
ffffffffc0200d8c:	6546                	ld	a0,80(sp)
ffffffffc0200d8e:	65e6                	ld	a1,88(sp)
ffffffffc0200d90:	7606                	ld	a2,96(sp)
ffffffffc0200d92:	76a6                	ld	a3,104(sp)
ffffffffc0200d94:	7746                	ld	a4,112(sp)
ffffffffc0200d96:	77e6                	ld	a5,120(sp)
ffffffffc0200d98:	680a                	ld	a6,128(sp)
ffffffffc0200d9a:	68aa                	ld	a7,136(sp)
ffffffffc0200d9c:	694a                	ld	s2,144(sp)
ffffffffc0200d9e:	69ea                	ld	s3,152(sp)
ffffffffc0200da0:	7a0a                	ld	s4,160(sp)
ffffffffc0200da2:	7aaa                	ld	s5,168(sp)
ffffffffc0200da4:	7b4a                	ld	s6,176(sp)
ffffffffc0200da6:	7bea                	ld	s7,184(sp)
ffffffffc0200da8:	6c0e                	ld	s8,192(sp)
ffffffffc0200daa:	6cae                	ld	s9,200(sp)
ffffffffc0200dac:	6d4e                	ld	s10,208(sp)
ffffffffc0200dae:	6dee                	ld	s11,216(sp)
ffffffffc0200db0:	7e0e                	ld	t3,224(sp)
ffffffffc0200db2:	7eae                	ld	t4,232(sp)
ffffffffc0200db4:	7f4e                	ld	t5,240(sp)
ffffffffc0200db6:	7fee                	ld	t6,248(sp)
ffffffffc0200db8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret // 返回epc地址，initproc线程执行时此处为kernel_thread_entry
ffffffffc0200dba:	10200073          	sret

ffffffffc0200dbe <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200dbe:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dc0:	b755                	j	ffffffffc0200d64 <__trapret>

ffffffffc0200dc2 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dc2:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200dc6:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200dca:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dce:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dd2:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dd6:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dda:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dde:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200de2:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200de6:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200de8:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dea:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dec:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dee:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200df0:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200df2:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200df4:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200df6:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200df8:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dfa:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dfc:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dfe:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200e00:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200e02:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200e04:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200e06:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200e08:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200e0a:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200e0c:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200e0e:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200e10:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200e12:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e14:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e16:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e18:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e1a:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e1c:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e1e:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e20:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e22:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e24:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e26:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e28:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e2a:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e2c:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e2e:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e30:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e32:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e34:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e36:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e38:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e3a:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e3c:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e3e:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e40:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e42:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e44:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e46:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e48:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e4a:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e4c:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e4e:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e50:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e52:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e54:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e56:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e58:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e5a:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e5c:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e5e:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e60:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e62:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e64:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e66:	812e                	mv	sp,a1
ffffffffc0200e68:	bdf5                	j	ffffffffc0200d64 <__trapret>

ffffffffc0200e6a <pa2page.part.0>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e6a:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e6c:	00006617          	auipc	a2,0x6
ffffffffc0200e70:	1d460613          	addi	a2,a2,468 # ffffffffc0207040 <commands+0x778>
ffffffffc0200e74:	06200593          	li	a1,98
ffffffffc0200e78:	00006517          	auipc	a0,0x6
ffffffffc0200e7c:	1e850513          	addi	a0,a0,488 # ffffffffc0207060 <commands+0x798>
pa2page(uintptr_t pa) {
ffffffffc0200e80:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e82:	b86ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e86 <pte2page.part.0>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
ffffffffc0200e86:	1141                	addi	sp,sp,-16
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
ffffffffc0200e88:	00006617          	auipc	a2,0x6
ffffffffc0200e8c:	1e860613          	addi	a2,a2,488 # ffffffffc0207070 <commands+0x7a8>
ffffffffc0200e90:	07400593          	li	a1,116
ffffffffc0200e94:	00006517          	auipc	a0,0x6
ffffffffc0200e98:	1cc50513          	addi	a0,a0,460 # ffffffffc0207060 <commands+0x798>
pte2page(pte_t pte) {
ffffffffc0200e9c:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0200e9e:	b6aff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200ea2 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200ea2:	7139                	addi	sp,sp,-64
ffffffffc0200ea4:	f426                	sd	s1,40(sp)
ffffffffc0200ea6:	f04a                	sd	s2,32(sp)
ffffffffc0200ea8:	ec4e                	sd	s3,24(sp)
ffffffffc0200eaa:	e852                	sd	s4,16(sp)
ffffffffc0200eac:	e456                	sd	s5,8(sp)
ffffffffc0200eae:	e05a                	sd	s6,0(sp)
ffffffffc0200eb0:	fc06                	sd	ra,56(sp)
ffffffffc0200eb2:	f822                	sd	s0,48(sp)
ffffffffc0200eb4:	84aa                	mv	s1,a0
ffffffffc0200eb6:	000b2917          	auipc	s2,0xb2
ffffffffc0200eba:	97a90913          	addi	s2,s2,-1670 # ffffffffc02b2830 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ebe:	4a05                	li	s4,1
ffffffffc0200ec0:	000b2a97          	auipc	s5,0xb2
ffffffffc0200ec4:	9a8a8a93          	addi	s5,s5,-1624 # ffffffffc02b2868 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ec8:	0005099b          	sext.w	s3,a0
ffffffffc0200ecc:	000b2b17          	auipc	s6,0xb2
ffffffffc0200ed0:	974b0b13          	addi	s6,s6,-1676 # ffffffffc02b2840 <check_mm_struct>
ffffffffc0200ed4:	a01d                	j	ffffffffc0200efa <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200ed6:	00093783          	ld	a5,0(s2)
ffffffffc0200eda:	6f9c                	ld	a5,24(a5)
ffffffffc0200edc:	9782                	jalr	a5
ffffffffc0200ede:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ee0:	4601                	li	a2,0
ffffffffc0200ee2:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ee4:	ec0d                	bnez	s0,ffffffffc0200f1e <alloc_pages+0x7c>
ffffffffc0200ee6:	029a6c63          	bltu	s4,s1,ffffffffc0200f1e <alloc_pages+0x7c>
ffffffffc0200eea:	000aa783          	lw	a5,0(s5)
ffffffffc0200eee:	2781                	sext.w	a5,a5
ffffffffc0200ef0:	c79d                	beqz	a5,ffffffffc0200f1e <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ef2:	000b3503          	ld	a0,0(s6)
ffffffffc0200ef6:	086030ef          	jal	ra,ffffffffc0203f7c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200efa:	100027f3          	csrr	a5,sstatus
ffffffffc0200efe:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200f00:	8526                	mv	a0,s1
ffffffffc0200f02:	dbf1                	beqz	a5,ffffffffc0200ed6 <alloc_pages+0x34>
        intr_disable();
ffffffffc0200f04:	f44ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0200f08:	00093783          	ld	a5,0(s2)
ffffffffc0200f0c:	8526                	mv	a0,s1
ffffffffc0200f0e:	6f9c                	ld	a5,24(a5)
ffffffffc0200f10:	9782                	jalr	a5
ffffffffc0200f12:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f14:	f2eff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200f18:	4601                	li	a2,0
ffffffffc0200f1a:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200f1c:	d469                	beqz	s0,ffffffffc0200ee6 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200f1e:	70e2                	ld	ra,56(sp)
ffffffffc0200f20:	8522                	mv	a0,s0
ffffffffc0200f22:	7442                	ld	s0,48(sp)
ffffffffc0200f24:	74a2                	ld	s1,40(sp)
ffffffffc0200f26:	7902                	ld	s2,32(sp)
ffffffffc0200f28:	69e2                	ld	s3,24(sp)
ffffffffc0200f2a:	6a42                	ld	s4,16(sp)
ffffffffc0200f2c:	6aa2                	ld	s5,8(sp)
ffffffffc0200f2e:	6b02                	ld	s6,0(sp)
ffffffffc0200f30:	6121                	addi	sp,sp,64
ffffffffc0200f32:	8082                	ret

ffffffffc0200f34 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f34:	100027f3          	csrr	a5,sstatus
ffffffffc0200f38:	8b89                	andi	a5,a5,2
ffffffffc0200f3a:	e799                	bnez	a5,ffffffffc0200f48 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200f3c:	000b2797          	auipc	a5,0xb2
ffffffffc0200f40:	8f47b783          	ld	a5,-1804(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0200f44:	739c                	ld	a5,32(a5)
ffffffffc0200f46:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f48:	1101                	addi	sp,sp,-32
ffffffffc0200f4a:	ec06                	sd	ra,24(sp)
ffffffffc0200f4c:	e822                	sd	s0,16(sp)
ffffffffc0200f4e:	e426                	sd	s1,8(sp)
ffffffffc0200f50:	842a                	mv	s0,a0
ffffffffc0200f52:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f54:	ef4ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f58:	000b2797          	auipc	a5,0xb2
ffffffffc0200f5c:	8d87b783          	ld	a5,-1832(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0200f60:	739c                	ld	a5,32(a5)
ffffffffc0200f62:	85a6                	mv	a1,s1
ffffffffc0200f64:	8522                	mv	a0,s0
ffffffffc0200f66:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f68:	6442                	ld	s0,16(sp)
ffffffffc0200f6a:	60e2                	ld	ra,24(sp)
ffffffffc0200f6c:	64a2                	ld	s1,8(sp)
ffffffffc0200f6e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f70:	ed2ff06f          	j	ffffffffc0200642 <intr_enable>

ffffffffc0200f74 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f74:	100027f3          	csrr	a5,sstatus
ffffffffc0200f78:	8b89                	andi	a5,a5,2
ffffffffc0200f7a:	e799                	bnez	a5,ffffffffc0200f88 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f7c:	000b2797          	auipc	a5,0xb2
ffffffffc0200f80:	8b47b783          	ld	a5,-1868(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0200f84:	779c                	ld	a5,40(a5)
ffffffffc0200f86:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200f88:	1141                	addi	sp,sp,-16
ffffffffc0200f8a:	e406                	sd	ra,8(sp)
ffffffffc0200f8c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f8e:	ebaff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f92:	000b2797          	auipc	a5,0xb2
ffffffffc0200f96:	89e7b783          	ld	a5,-1890(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0200f9a:	779c                	ld	a5,40(a5)
ffffffffc0200f9c:	9782                	jalr	a5
ffffffffc0200f9e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200fa0:	ea2ff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200fa4:	60a2                	ld	ra,8(sp)
ffffffffc0200fa6:	8522                	mv	a0,s0
ffffffffc0200fa8:	6402                	ld	s0,0(sp)
ffffffffc0200faa:	0141                	addi	sp,sp,16
ffffffffc0200fac:	8082                	ret

ffffffffc0200fae <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200fae:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200fb2:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200fb6:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200fb8:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200fba:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200fbc:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200fc0:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200fc2:	f04a                	sd	s2,32(sp)
ffffffffc0200fc4:	ec4e                	sd	s3,24(sp)
ffffffffc0200fc6:	e852                	sd	s4,16(sp)
ffffffffc0200fc8:	fc06                	sd	ra,56(sp)
ffffffffc0200fca:	f822                	sd	s0,48(sp)
ffffffffc0200fcc:	e456                	sd	s5,8(sp)
ffffffffc0200fce:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200fd0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200fd4:	892e                	mv	s2,a1
ffffffffc0200fd6:	89b2                	mv	s3,a2
ffffffffc0200fd8:	000b2a17          	auipc	s4,0xb2
ffffffffc0200fdc:	848a0a13          	addi	s4,s4,-1976 # ffffffffc02b2820 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200fe0:	e7b5                	bnez	a5,ffffffffc020104c <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200fe2:	12060b63          	beqz	a2,ffffffffc0201118 <get_pte+0x16a>
ffffffffc0200fe6:	4505                	li	a0,1
ffffffffc0200fe8:	ebbff0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0200fec:	842a                	mv	s0,a0
ffffffffc0200fee:	12050563          	beqz	a0,ffffffffc0201118 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200ff2:	000b2b17          	auipc	s6,0xb2
ffffffffc0200ff6:	836b0b13          	addi	s6,s6,-1994 # ffffffffc02b2828 <pages>
ffffffffc0200ffa:	000b3503          	ld	a0,0(s6)
ffffffffc0200ffe:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201002:	000b2a17          	auipc	s4,0xb2
ffffffffc0201006:	81ea0a13          	addi	s4,s4,-2018 # ffffffffc02b2820 <npage>
ffffffffc020100a:	40a40533          	sub	a0,s0,a0
ffffffffc020100e:	8519                	srai	a0,a0,0x6
ffffffffc0201010:	9556                	add	a0,a0,s5
ffffffffc0201012:	000a3703          	ld	a4,0(s4)
ffffffffc0201016:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc020101a:	4685                	li	a3,1
ffffffffc020101c:	c014                	sw	a3,0(s0)
ffffffffc020101e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201020:	0532                	slli	a0,a0,0xc
ffffffffc0201022:	14e7f263          	bgeu	a5,a4,ffffffffc0201166 <get_pte+0x1b8>
ffffffffc0201026:	000b2797          	auipc	a5,0xb2
ffffffffc020102a:	8127b783          	ld	a5,-2030(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc020102e:	6605                	lui	a2,0x1
ffffffffc0201030:	4581                	li	a1,0
ffffffffc0201032:	953e                	add	a0,a0,a5
ffffffffc0201034:	1bc050ef          	jal	ra,ffffffffc02061f0 <memset>
    return page - pages + nbase;
ffffffffc0201038:	000b3683          	ld	a3,0(s6)
ffffffffc020103c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201040:	8699                	srai	a3,a3,0x6
ffffffffc0201042:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201044:	06aa                	slli	a3,a3,0xa
ffffffffc0201046:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020104a:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020104c:	77fd                	lui	a5,0xfffff
ffffffffc020104e:	068a                	slli	a3,a3,0x2
ffffffffc0201050:	000a3703          	ld	a4,0(s4)
ffffffffc0201054:	8efd                	and	a3,a3,a5
ffffffffc0201056:	00c6d793          	srli	a5,a3,0xc
ffffffffc020105a:	0ce7f163          	bgeu	a5,a4,ffffffffc020111c <get_pte+0x16e>
ffffffffc020105e:	000b1a97          	auipc	s5,0xb1
ffffffffc0201062:	7daa8a93          	addi	s5,s5,2010 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0201066:	000ab403          	ld	s0,0(s5)
ffffffffc020106a:	01595793          	srli	a5,s2,0x15
ffffffffc020106e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201072:	96a2                	add	a3,a3,s0
ffffffffc0201074:	00379413          	slli	s0,a5,0x3
ffffffffc0201078:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020107a:	6014                	ld	a3,0(s0)
ffffffffc020107c:	0016f793          	andi	a5,a3,1
ffffffffc0201080:	e3ad                	bnez	a5,ffffffffc02010e2 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201082:	08098b63          	beqz	s3,ffffffffc0201118 <get_pte+0x16a>
ffffffffc0201086:	4505                	li	a0,1
ffffffffc0201088:	e1bff0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc020108c:	84aa                	mv	s1,a0
ffffffffc020108e:	c549                	beqz	a0,ffffffffc0201118 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201090:	000b1b17          	auipc	s6,0xb1
ffffffffc0201094:	798b0b13          	addi	s6,s6,1944 # ffffffffc02b2828 <pages>
ffffffffc0201098:	000b3503          	ld	a0,0(s6)
ffffffffc020109c:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02010a0:	000a3703          	ld	a4,0(s4)
ffffffffc02010a4:	40a48533          	sub	a0,s1,a0
ffffffffc02010a8:	8519                	srai	a0,a0,0x6
ffffffffc02010aa:	954e                	add	a0,a0,s3
ffffffffc02010ac:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02010b0:	4685                	li	a3,1
ffffffffc02010b2:	c094                	sw	a3,0(s1)
ffffffffc02010b4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02010b6:	0532                	slli	a0,a0,0xc
ffffffffc02010b8:	08e7fa63          	bgeu	a5,a4,ffffffffc020114c <get_pte+0x19e>
ffffffffc02010bc:	000ab783          	ld	a5,0(s5)
ffffffffc02010c0:	6605                	lui	a2,0x1
ffffffffc02010c2:	4581                	li	a1,0
ffffffffc02010c4:	953e                	add	a0,a0,a5
ffffffffc02010c6:	12a050ef          	jal	ra,ffffffffc02061f0 <memset>
    return page - pages + nbase;
ffffffffc02010ca:	000b3683          	ld	a3,0(s6)
ffffffffc02010ce:	40d486b3          	sub	a3,s1,a3
ffffffffc02010d2:	8699                	srai	a3,a3,0x6
ffffffffc02010d4:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02010d6:	06aa                	slli	a3,a3,0xa
ffffffffc02010d8:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02010dc:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010de:	000a3703          	ld	a4,0(s4)
ffffffffc02010e2:	068a                	slli	a3,a3,0x2
ffffffffc02010e4:	757d                	lui	a0,0xfffff
ffffffffc02010e6:	8ee9                	and	a3,a3,a0
ffffffffc02010e8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010ec:	04e7f463          	bgeu	a5,a4,ffffffffc0201134 <get_pte+0x186>
ffffffffc02010f0:	000ab503          	ld	a0,0(s5)
ffffffffc02010f4:	00c95913          	srli	s2,s2,0xc
ffffffffc02010f8:	1ff97913          	andi	s2,s2,511
ffffffffc02010fc:	96aa                	add	a3,a3,a0
ffffffffc02010fe:	00391513          	slli	a0,s2,0x3
ffffffffc0201102:	9536                	add	a0,a0,a3
}
ffffffffc0201104:	70e2                	ld	ra,56(sp)
ffffffffc0201106:	7442                	ld	s0,48(sp)
ffffffffc0201108:	74a2                	ld	s1,40(sp)
ffffffffc020110a:	7902                	ld	s2,32(sp)
ffffffffc020110c:	69e2                	ld	s3,24(sp)
ffffffffc020110e:	6a42                	ld	s4,16(sp)
ffffffffc0201110:	6aa2                	ld	s5,8(sp)
ffffffffc0201112:	6b02                	ld	s6,0(sp)
ffffffffc0201114:	6121                	addi	sp,sp,64
ffffffffc0201116:	8082                	ret
            return NULL;
ffffffffc0201118:	4501                	li	a0,0
ffffffffc020111a:	b7ed                	j	ffffffffc0201104 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020111c:	00006617          	auipc	a2,0x6
ffffffffc0201120:	f7c60613          	addi	a2,a2,-132 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0201124:	0e300593          	li	a1,227
ffffffffc0201128:	00006517          	auipc	a0,0x6
ffffffffc020112c:	f9850513          	addi	a0,a0,-104 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201130:	8d8ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201134:	00006617          	auipc	a2,0x6
ffffffffc0201138:	f6460613          	addi	a2,a2,-156 # ffffffffc0207098 <commands+0x7d0>
ffffffffc020113c:	0ee00593          	li	a1,238
ffffffffc0201140:	00006517          	auipc	a0,0x6
ffffffffc0201144:	f8050513          	addi	a0,a0,-128 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201148:	8c0ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020114c:	86aa                	mv	a3,a0
ffffffffc020114e:	00006617          	auipc	a2,0x6
ffffffffc0201152:	f4a60613          	addi	a2,a2,-182 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0201156:	0eb00593          	li	a1,235
ffffffffc020115a:	00006517          	auipc	a0,0x6
ffffffffc020115e:	f6650513          	addi	a0,a0,-154 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201162:	8a6ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201166:	86aa                	mv	a3,a0
ffffffffc0201168:	00006617          	auipc	a2,0x6
ffffffffc020116c:	f3060613          	addi	a2,a2,-208 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0201170:	0df00593          	li	a1,223
ffffffffc0201174:	00006517          	auipc	a0,0x6
ffffffffc0201178:	f4c50513          	addi	a0,a0,-180 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc020117c:	88cff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201180 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201180:	1141                	addi	sp,sp,-16
ffffffffc0201182:	e022                	sd	s0,0(sp)
ffffffffc0201184:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201186:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201188:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020118a:	e25ff0ef          	jal	ra,ffffffffc0200fae <get_pte>
    if (ptep_store != NULL) {
ffffffffc020118e:	c011                	beqz	s0,ffffffffc0201192 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201190:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201192:	c511                	beqz	a0,ffffffffc020119e <get_page+0x1e>
ffffffffc0201194:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201196:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201198:	0017f713          	andi	a4,a5,1
ffffffffc020119c:	e709                	bnez	a4,ffffffffc02011a6 <get_page+0x26>
}
ffffffffc020119e:	60a2                	ld	ra,8(sp)
ffffffffc02011a0:	6402                	ld	s0,0(sp)
ffffffffc02011a2:	0141                	addi	sp,sp,16
ffffffffc02011a4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02011a6:	078a                	slli	a5,a5,0x2
ffffffffc02011a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02011aa:	000b1717          	auipc	a4,0xb1
ffffffffc02011ae:	67673703          	ld	a4,1654(a4) # ffffffffc02b2820 <npage>
ffffffffc02011b2:	00e7ff63          	bgeu	a5,a4,ffffffffc02011d0 <get_page+0x50>
ffffffffc02011b6:	60a2                	ld	ra,8(sp)
ffffffffc02011b8:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02011ba:	fff80537          	lui	a0,0xfff80
ffffffffc02011be:	97aa                	add	a5,a5,a0
ffffffffc02011c0:	079a                	slli	a5,a5,0x6
ffffffffc02011c2:	000b1517          	auipc	a0,0xb1
ffffffffc02011c6:	66653503          	ld	a0,1638(a0) # ffffffffc02b2828 <pages>
ffffffffc02011ca:	953e                	add	a0,a0,a5
ffffffffc02011cc:	0141                	addi	sp,sp,16
ffffffffc02011ce:	8082                	ret
ffffffffc02011d0:	c9bff0ef          	jal	ra,ffffffffc0200e6a <pa2page.part.0>

ffffffffc02011d4 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02011d4:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011d6:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02011da:	f486                	sd	ra,104(sp)
ffffffffc02011dc:	f0a2                	sd	s0,96(sp)
ffffffffc02011de:	eca6                	sd	s1,88(sp)
ffffffffc02011e0:	e8ca                	sd	s2,80(sp)
ffffffffc02011e2:	e4ce                	sd	s3,72(sp)
ffffffffc02011e4:	e0d2                	sd	s4,64(sp)
ffffffffc02011e6:	fc56                	sd	s5,56(sp)
ffffffffc02011e8:	f85a                	sd	s6,48(sp)
ffffffffc02011ea:	f45e                	sd	s7,40(sp)
ffffffffc02011ec:	f062                	sd	s8,32(sp)
ffffffffc02011ee:	ec66                	sd	s9,24(sp)
ffffffffc02011f0:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011f2:	17d2                	slli	a5,a5,0x34
ffffffffc02011f4:	e3ed                	bnez	a5,ffffffffc02012d6 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc02011f6:	002007b7          	lui	a5,0x200
ffffffffc02011fa:	842e                	mv	s0,a1
ffffffffc02011fc:	0ef5ed63          	bltu	a1,a5,ffffffffc02012f6 <unmap_range+0x122>
ffffffffc0201200:	8932                	mv	s2,a2
ffffffffc0201202:	0ec5fa63          	bgeu	a1,a2,ffffffffc02012f6 <unmap_range+0x122>
ffffffffc0201206:	4785                	li	a5,1
ffffffffc0201208:	07fe                	slli	a5,a5,0x1f
ffffffffc020120a:	0ec7e663          	bltu	a5,a2,ffffffffc02012f6 <unmap_range+0x122>
ffffffffc020120e:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0201210:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201212:	000b1c97          	auipc	s9,0xb1
ffffffffc0201216:	60ec8c93          	addi	s9,s9,1550 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020121a:	000b1c17          	auipc	s8,0xb1
ffffffffc020121e:	60ec0c13          	addi	s8,s8,1550 # ffffffffc02b2828 <pages>
ffffffffc0201222:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0201226:	000b1d17          	auipc	s10,0xb1
ffffffffc020122a:	60ad0d13          	addi	s10,s10,1546 # ffffffffc02b2830 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020122e:	00200b37          	lui	s6,0x200
ffffffffc0201232:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0201236:	4601                	li	a2,0
ffffffffc0201238:	85a2                	mv	a1,s0
ffffffffc020123a:	854e                	mv	a0,s3
ffffffffc020123c:	d73ff0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc0201240:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0201242:	cd29                	beqz	a0,ffffffffc020129c <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc0201244:	611c                	ld	a5,0(a0)
ffffffffc0201246:	e395                	bnez	a5,ffffffffc020126a <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0201248:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020124a:	ff2466e3          	bltu	s0,s2,ffffffffc0201236 <unmap_range+0x62>
}
ffffffffc020124e:	70a6                	ld	ra,104(sp)
ffffffffc0201250:	7406                	ld	s0,96(sp)
ffffffffc0201252:	64e6                	ld	s1,88(sp)
ffffffffc0201254:	6946                	ld	s2,80(sp)
ffffffffc0201256:	69a6                	ld	s3,72(sp)
ffffffffc0201258:	6a06                	ld	s4,64(sp)
ffffffffc020125a:	7ae2                	ld	s5,56(sp)
ffffffffc020125c:	7b42                	ld	s6,48(sp)
ffffffffc020125e:	7ba2                	ld	s7,40(sp)
ffffffffc0201260:	7c02                	ld	s8,32(sp)
ffffffffc0201262:	6ce2                	ld	s9,24(sp)
ffffffffc0201264:	6d42                	ld	s10,16(sp)
ffffffffc0201266:	6165                	addi	sp,sp,112
ffffffffc0201268:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020126a:	0017f713          	andi	a4,a5,1
ffffffffc020126e:	df69                	beqz	a4,ffffffffc0201248 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0201270:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201274:	078a                	slli	a5,a5,0x2
ffffffffc0201276:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201278:	08e7ff63          	bgeu	a5,a4,ffffffffc0201316 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc020127c:	000c3503          	ld	a0,0(s8)
ffffffffc0201280:	97de                	add	a5,a5,s7
ffffffffc0201282:	079a                	slli	a5,a5,0x6
ffffffffc0201284:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201286:	411c                	lw	a5,0(a0)
ffffffffc0201288:	fff7871b          	addiw	a4,a5,-1
ffffffffc020128c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020128e:	cf11                	beqz	a4,ffffffffc02012aa <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201290:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201294:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0201298:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020129a:	bf45                	j	ffffffffc020124a <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020129c:	945a                	add	s0,s0,s6
ffffffffc020129e:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02012a2:	d455                	beqz	s0,ffffffffc020124e <unmap_range+0x7a>
ffffffffc02012a4:	f92469e3          	bltu	s0,s2,ffffffffc0201236 <unmap_range+0x62>
ffffffffc02012a8:	b75d                	j	ffffffffc020124e <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012aa:	100027f3          	csrr	a5,sstatus
ffffffffc02012ae:	8b89                	andi	a5,a5,2
ffffffffc02012b0:	e799                	bnez	a5,ffffffffc02012be <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02012b2:	000d3783          	ld	a5,0(s10)
ffffffffc02012b6:	4585                	li	a1,1
ffffffffc02012b8:	739c                	ld	a5,32(a5)
ffffffffc02012ba:	9782                	jalr	a5
    if (flag) {
ffffffffc02012bc:	bfd1                	j	ffffffffc0201290 <unmap_range+0xbc>
ffffffffc02012be:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02012c0:	b88ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02012c4:	000d3783          	ld	a5,0(s10)
ffffffffc02012c8:	6522                	ld	a0,8(sp)
ffffffffc02012ca:	4585                	li	a1,1
ffffffffc02012cc:	739c                	ld	a5,32(a5)
ffffffffc02012ce:	9782                	jalr	a5
        intr_enable();
ffffffffc02012d0:	b72ff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02012d4:	bf75                	j	ffffffffc0201290 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012d6:	00006697          	auipc	a3,0x6
ffffffffc02012da:	dfa68693          	addi	a3,a3,-518 # ffffffffc02070d0 <commands+0x808>
ffffffffc02012de:	00006617          	auipc	a2,0x6
ffffffffc02012e2:	9fa60613          	addi	a2,a2,-1542 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02012e6:	10f00593          	li	a1,271
ffffffffc02012ea:	00006517          	auipc	a0,0x6
ffffffffc02012ee:	dd650513          	addi	a0,a0,-554 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02012f2:	f17fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02012f6:	00006697          	auipc	a3,0x6
ffffffffc02012fa:	e0a68693          	addi	a3,a3,-502 # ffffffffc0207100 <commands+0x838>
ffffffffc02012fe:	00006617          	auipc	a2,0x6
ffffffffc0201302:	9da60613          	addi	a2,a2,-1574 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201306:	11000593          	li	a1,272
ffffffffc020130a:	00006517          	auipc	a0,0x6
ffffffffc020130e:	db650513          	addi	a0,a0,-586 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201312:	ef7fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201316:	b55ff0ef          	jal	ra,ffffffffc0200e6a <pa2page.part.0>

ffffffffc020131a <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020131a:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020131c:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201320:	fc86                	sd	ra,120(sp)
ffffffffc0201322:	f8a2                	sd	s0,112(sp)
ffffffffc0201324:	f4a6                	sd	s1,104(sp)
ffffffffc0201326:	f0ca                	sd	s2,96(sp)
ffffffffc0201328:	ecce                	sd	s3,88(sp)
ffffffffc020132a:	e8d2                	sd	s4,80(sp)
ffffffffc020132c:	e4d6                	sd	s5,72(sp)
ffffffffc020132e:	e0da                	sd	s6,64(sp)
ffffffffc0201330:	fc5e                	sd	s7,56(sp)
ffffffffc0201332:	f862                	sd	s8,48(sp)
ffffffffc0201334:	f466                	sd	s9,40(sp)
ffffffffc0201336:	f06a                	sd	s10,32(sp)
ffffffffc0201338:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020133a:	17d2                	slli	a5,a5,0x34
ffffffffc020133c:	20079a63          	bnez	a5,ffffffffc0201550 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0201340:	002007b7          	lui	a5,0x200
ffffffffc0201344:	24f5e463          	bltu	a1,a5,ffffffffc020158c <exit_range+0x272>
ffffffffc0201348:	8ab2                	mv	s5,a2
ffffffffc020134a:	24c5f163          	bgeu	a1,a2,ffffffffc020158c <exit_range+0x272>
ffffffffc020134e:	4785                	li	a5,1
ffffffffc0201350:	07fe                	slli	a5,a5,0x1f
ffffffffc0201352:	22c7ed63          	bltu	a5,a2,ffffffffc020158c <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0201356:	c00009b7          	lui	s3,0xc0000
ffffffffc020135a:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020135e:	ffe00937          	lui	s2,0xffe00
ffffffffc0201362:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0201366:	5cfd                	li	s9,-1
ffffffffc0201368:	8c2a                	mv	s8,a0
ffffffffc020136a:	0125f933          	and	s2,a1,s2
ffffffffc020136e:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0201370:	000b1d17          	auipc	s10,0xb1
ffffffffc0201374:	4b0d0d13          	addi	s10,s10,1200 # ffffffffc02b2820 <npage>
    return KADDR(page2pa(page));
ffffffffc0201378:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc020137c:	000b1717          	auipc	a4,0xb1
ffffffffc0201380:	4ac70713          	addi	a4,a4,1196 # ffffffffc02b2828 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0201384:	000b1d97          	auipc	s11,0xb1
ffffffffc0201388:	4acd8d93          	addi	s11,s11,1196 # ffffffffc02b2830 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020138c:	c0000437          	lui	s0,0xc0000
ffffffffc0201390:	944e                	add	s0,s0,s3
ffffffffc0201392:	8079                	srli	s0,s0,0x1e
ffffffffc0201394:	1ff47413          	andi	s0,s0,511
ffffffffc0201398:	040e                	slli	s0,s0,0x3
ffffffffc020139a:	9462                	add	s0,s0,s8
ffffffffc020139c:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
        if (pde1&PTE_V){
ffffffffc02013a0:	001a7793          	andi	a5,s4,1
ffffffffc02013a4:	eb99                	bnez	a5,ffffffffc02013ba <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02013a6:	12098463          	beqz	s3,ffffffffc02014ce <exit_range+0x1b4>
ffffffffc02013aa:	400007b7          	lui	a5,0x40000
ffffffffc02013ae:	97ce                	add	a5,a5,s3
ffffffffc02013b0:	894e                	mv	s2,s3
ffffffffc02013b2:	1159fe63          	bgeu	s3,s5,ffffffffc02014ce <exit_range+0x1b4>
ffffffffc02013b6:	89be                	mv	s3,a5
ffffffffc02013b8:	bfd1                	j	ffffffffc020138c <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc02013ba:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013be:	0a0a                	slli	s4,s4,0x2
ffffffffc02013c0:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013c4:	1cfa7263          	bgeu	s4,a5,ffffffffc0201588 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013c8:	fff80637          	lui	a2,0xfff80
ffffffffc02013cc:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02013ce:	000806b7          	lui	a3,0x80
ffffffffc02013d2:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02013d4:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02013d8:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02013da:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013dc:	18f5fa63          	bgeu	a1,a5,ffffffffc0201570 <exit_range+0x256>
ffffffffc02013e0:	000b1817          	auipc	a6,0xb1
ffffffffc02013e4:	45880813          	addi	a6,a6,1112 # ffffffffc02b2838 <va_pa_offset>
ffffffffc02013e8:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc02013ec:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc02013ee:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc02013f2:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc02013f4:	00080337          	lui	t1,0x80
ffffffffc02013f8:	6885                	lui	a7,0x1
ffffffffc02013fa:	a819                	j	ffffffffc0201410 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02013fc:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02013fe:	002007b7          	lui	a5,0x200
ffffffffc0201402:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201404:	08090c63          	beqz	s2,ffffffffc020149c <exit_range+0x182>
ffffffffc0201408:	09397a63          	bgeu	s2,s3,ffffffffc020149c <exit_range+0x182>
ffffffffc020140c:	0f597063          	bgeu	s2,s5,ffffffffc02014ec <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0201410:	01595493          	srli	s1,s2,0x15
ffffffffc0201414:	1ff4f493          	andi	s1,s1,511
ffffffffc0201418:	048e                	slli	s1,s1,0x3
ffffffffc020141a:	94da                	add	s1,s1,s6
ffffffffc020141c:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc020141e:	0017f693          	andi	a3,a5,1
ffffffffc0201422:	dee9                	beqz	a3,ffffffffc02013fc <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc0201424:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201428:	078a                	slli	a5,a5,0x2
ffffffffc020142a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020142c:	14b7fe63          	bgeu	a5,a1,ffffffffc0201588 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201430:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0201432:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0201436:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020143a:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020143e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201440:	12bef863          	bgeu	t4,a1,ffffffffc0201570 <exit_range+0x256>
ffffffffc0201444:	00083783          	ld	a5,0(a6)
ffffffffc0201448:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020144a:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc020144e:	629c                	ld	a5,0(a3)
ffffffffc0201450:	8b85                	andi	a5,a5,1
ffffffffc0201452:	f7d5                	bnez	a5,ffffffffc02013fe <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0201454:	06a1                	addi	a3,a3,8
ffffffffc0201456:	fed59ce3          	bne	a1,a3,ffffffffc020144e <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc020145a:	631c                	ld	a5,0(a4)
ffffffffc020145c:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020145e:	100027f3          	csrr	a5,sstatus
ffffffffc0201462:	8b89                	andi	a5,a5,2
ffffffffc0201464:	e7d9                	bnez	a5,ffffffffc02014f2 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0201466:	000db783          	ld	a5,0(s11)
ffffffffc020146a:	4585                	li	a1,1
ffffffffc020146c:	e032                	sd	a2,0(sp)
ffffffffc020146e:	739c                	ld	a5,32(a5)
ffffffffc0201470:	9782                	jalr	a5
    if (flag) {
ffffffffc0201472:	6602                	ld	a2,0(sp)
ffffffffc0201474:	000b1817          	auipc	a6,0xb1
ffffffffc0201478:	3c480813          	addi	a6,a6,964 # ffffffffc02b2838 <va_pa_offset>
ffffffffc020147c:	fff80e37          	lui	t3,0xfff80
ffffffffc0201480:	00080337          	lui	t1,0x80
ffffffffc0201484:	6885                	lui	a7,0x1
ffffffffc0201486:	000b1717          	auipc	a4,0xb1
ffffffffc020148a:	3a270713          	addi	a4,a4,930 # ffffffffc02b2828 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc020148e:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0201492:	002007b7          	lui	a5,0x200
ffffffffc0201496:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201498:	f60918e3          	bnez	s2,ffffffffc0201408 <exit_range+0xee>
            if (free_pd0) {
ffffffffc020149c:	f00b85e3          	beqz	s7,ffffffffc02013a6 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc02014a0:	000d3783          	ld	a5,0(s10)
ffffffffc02014a4:	0efa7263          	bgeu	s4,a5,ffffffffc0201588 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02014a8:	6308                	ld	a0,0(a4)
ffffffffc02014aa:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014ac:	100027f3          	csrr	a5,sstatus
ffffffffc02014b0:	8b89                	andi	a5,a5,2
ffffffffc02014b2:	efad                	bnez	a5,ffffffffc020152c <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02014b4:	000db783          	ld	a5,0(s11)
ffffffffc02014b8:	4585                	li	a1,1
ffffffffc02014ba:	739c                	ld	a5,32(a5)
ffffffffc02014bc:	9782                	jalr	a5
ffffffffc02014be:	000b1717          	auipc	a4,0xb1
ffffffffc02014c2:	36a70713          	addi	a4,a4,874 # ffffffffc02b2828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02014c6:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02014ca:	ee0990e3          	bnez	s3,ffffffffc02013aa <exit_range+0x90>
}
ffffffffc02014ce:	70e6                	ld	ra,120(sp)
ffffffffc02014d0:	7446                	ld	s0,112(sp)
ffffffffc02014d2:	74a6                	ld	s1,104(sp)
ffffffffc02014d4:	7906                	ld	s2,96(sp)
ffffffffc02014d6:	69e6                	ld	s3,88(sp)
ffffffffc02014d8:	6a46                	ld	s4,80(sp)
ffffffffc02014da:	6aa6                	ld	s5,72(sp)
ffffffffc02014dc:	6b06                	ld	s6,64(sp)
ffffffffc02014de:	7be2                	ld	s7,56(sp)
ffffffffc02014e0:	7c42                	ld	s8,48(sp)
ffffffffc02014e2:	7ca2                	ld	s9,40(sp)
ffffffffc02014e4:	7d02                	ld	s10,32(sp)
ffffffffc02014e6:	6de2                	ld	s11,24(sp)
ffffffffc02014e8:	6109                	addi	sp,sp,128
ffffffffc02014ea:	8082                	ret
            if (free_pd0) {
ffffffffc02014ec:	ea0b8fe3          	beqz	s7,ffffffffc02013aa <exit_range+0x90>
ffffffffc02014f0:	bf45                	j	ffffffffc02014a0 <exit_range+0x186>
ffffffffc02014f2:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc02014f4:	e42a                	sd	a0,8(sp)
ffffffffc02014f6:	952ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02014fa:	000db783          	ld	a5,0(s11)
ffffffffc02014fe:	6522                	ld	a0,8(sp)
ffffffffc0201500:	4585                	li	a1,1
ffffffffc0201502:	739c                	ld	a5,32(a5)
ffffffffc0201504:	9782                	jalr	a5
        intr_enable();
ffffffffc0201506:	93cff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020150a:	6602                	ld	a2,0(sp)
ffffffffc020150c:	000b1717          	auipc	a4,0xb1
ffffffffc0201510:	31c70713          	addi	a4,a4,796 # ffffffffc02b2828 <pages>
ffffffffc0201514:	6885                	lui	a7,0x1
ffffffffc0201516:	00080337          	lui	t1,0x80
ffffffffc020151a:	fff80e37          	lui	t3,0xfff80
ffffffffc020151e:	000b1817          	auipc	a6,0xb1
ffffffffc0201522:	31a80813          	addi	a6,a6,794 # ffffffffc02b2838 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201526:	0004b023          	sd	zero,0(s1)
ffffffffc020152a:	b7a5                	j	ffffffffc0201492 <exit_range+0x178>
ffffffffc020152c:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc020152e:	91aff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201532:	000db783          	ld	a5,0(s11)
ffffffffc0201536:	6502                	ld	a0,0(sp)
ffffffffc0201538:	4585                	li	a1,1
ffffffffc020153a:	739c                	ld	a5,32(a5)
ffffffffc020153c:	9782                	jalr	a5
        intr_enable();
ffffffffc020153e:	904ff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201542:	000b1717          	auipc	a4,0xb1
ffffffffc0201546:	2e670713          	addi	a4,a4,742 # ffffffffc02b2828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020154a:	00043023          	sd	zero,0(s0)
ffffffffc020154e:	bfb5                	j	ffffffffc02014ca <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201550:	00006697          	auipc	a3,0x6
ffffffffc0201554:	b8068693          	addi	a3,a3,-1152 # ffffffffc02070d0 <commands+0x808>
ffffffffc0201558:	00005617          	auipc	a2,0x5
ffffffffc020155c:	78060613          	addi	a2,a2,1920 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201560:	12000593          	li	a1,288
ffffffffc0201564:	00006517          	auipc	a0,0x6
ffffffffc0201568:	b5c50513          	addi	a0,a0,-1188 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc020156c:	c9dfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201570:	00006617          	auipc	a2,0x6
ffffffffc0201574:	b2860613          	addi	a2,a2,-1240 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0201578:	06900593          	li	a1,105
ffffffffc020157c:	00006517          	auipc	a0,0x6
ffffffffc0201580:	ae450513          	addi	a0,a0,-1308 # ffffffffc0207060 <commands+0x798>
ffffffffc0201584:	c85fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201588:	8e3ff0ef          	jal	ra,ffffffffc0200e6a <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc020158c:	00006697          	auipc	a3,0x6
ffffffffc0201590:	b7468693          	addi	a3,a3,-1164 # ffffffffc0207100 <commands+0x838>
ffffffffc0201594:	00005617          	auipc	a2,0x5
ffffffffc0201598:	74460613          	addi	a2,a2,1860 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020159c:	12100593          	li	a1,289
ffffffffc02015a0:	00006517          	auipc	a0,0x6
ffffffffc02015a4:	b2050513          	addi	a0,a0,-1248 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02015a8:	c61fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02015ac <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02015ac:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02015ae:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02015b0:	ec26                	sd	s1,24(sp)
ffffffffc02015b2:	f406                	sd	ra,40(sp)
ffffffffc02015b4:	f022                	sd	s0,32(sp)
ffffffffc02015b6:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02015b8:	9f7ff0ef          	jal	ra,ffffffffc0200fae <get_pte>
    if (ptep != NULL) {
ffffffffc02015bc:	c511                	beqz	a0,ffffffffc02015c8 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02015be:	611c                	ld	a5,0(a0)
ffffffffc02015c0:	842a                	mv	s0,a0
ffffffffc02015c2:	0017f713          	andi	a4,a5,1
ffffffffc02015c6:	e711                	bnez	a4,ffffffffc02015d2 <page_remove+0x26>
}
ffffffffc02015c8:	70a2                	ld	ra,40(sp)
ffffffffc02015ca:	7402                	ld	s0,32(sp)
ffffffffc02015cc:	64e2                	ld	s1,24(sp)
ffffffffc02015ce:	6145                	addi	sp,sp,48
ffffffffc02015d0:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02015d2:	078a                	slli	a5,a5,0x2
ffffffffc02015d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015d6:	000b1717          	auipc	a4,0xb1
ffffffffc02015da:	24a73703          	ld	a4,586(a4) # ffffffffc02b2820 <npage>
ffffffffc02015de:	06e7f363          	bgeu	a5,a4,ffffffffc0201644 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02015e2:	fff80537          	lui	a0,0xfff80
ffffffffc02015e6:	97aa                	add	a5,a5,a0
ffffffffc02015e8:	079a                	slli	a5,a5,0x6
ffffffffc02015ea:	000b1517          	auipc	a0,0xb1
ffffffffc02015ee:	23e53503          	ld	a0,574(a0) # ffffffffc02b2828 <pages>
ffffffffc02015f2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02015f4:	411c                	lw	a5,0(a0)
ffffffffc02015f6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02015fa:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02015fc:	cb11                	beqz	a4,ffffffffc0201610 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02015fe:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201602:	12048073          	sfence.vma	s1
}
ffffffffc0201606:	70a2                	ld	ra,40(sp)
ffffffffc0201608:	7402                	ld	s0,32(sp)
ffffffffc020160a:	64e2                	ld	s1,24(sp)
ffffffffc020160c:	6145                	addi	sp,sp,48
ffffffffc020160e:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201610:	100027f3          	csrr	a5,sstatus
ffffffffc0201614:	8b89                	andi	a5,a5,2
ffffffffc0201616:	eb89                	bnez	a5,ffffffffc0201628 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0201618:	000b1797          	auipc	a5,0xb1
ffffffffc020161c:	2187b783          	ld	a5,536(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0201620:	739c                	ld	a5,32(a5)
ffffffffc0201622:	4585                	li	a1,1
ffffffffc0201624:	9782                	jalr	a5
    if (flag) {
ffffffffc0201626:	bfe1                	j	ffffffffc02015fe <page_remove+0x52>
        intr_disable();
ffffffffc0201628:	e42a                	sd	a0,8(sp)
ffffffffc020162a:	81eff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020162e:	000b1797          	auipc	a5,0xb1
ffffffffc0201632:	2027b783          	ld	a5,514(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0201636:	739c                	ld	a5,32(a5)
ffffffffc0201638:	6522                	ld	a0,8(sp)
ffffffffc020163a:	4585                	li	a1,1
ffffffffc020163c:	9782                	jalr	a5
        intr_enable();
ffffffffc020163e:	804ff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201642:	bf75                	j	ffffffffc02015fe <page_remove+0x52>
ffffffffc0201644:	827ff0ef          	jal	ra,ffffffffc0200e6a <pa2page.part.0>

ffffffffc0201648 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201648:	7139                	addi	sp,sp,-64
ffffffffc020164a:	e852                	sd	s4,16(sp)
ffffffffc020164c:	8a32                	mv	s4,a2
ffffffffc020164e:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201650:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201652:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201654:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201656:	f426                	sd	s1,40(sp)
ffffffffc0201658:	fc06                	sd	ra,56(sp)
ffffffffc020165a:	f04a                	sd	s2,32(sp)
ffffffffc020165c:	ec4e                	sd	s3,24(sp)
ffffffffc020165e:	e456                	sd	s5,8(sp)
ffffffffc0201660:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201662:	94dff0ef          	jal	ra,ffffffffc0200fae <get_pte>
    if (ptep == NULL) {
ffffffffc0201666:	c961                	beqz	a0,ffffffffc0201736 <page_insert+0xee>
    page->ref += 1;
ffffffffc0201668:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc020166a:	611c                	ld	a5,0(a0)
ffffffffc020166c:	89aa                	mv	s3,a0
ffffffffc020166e:	0016871b          	addiw	a4,a3,1
ffffffffc0201672:	c018                	sw	a4,0(s0)
ffffffffc0201674:	0017f713          	andi	a4,a5,1
ffffffffc0201678:	ef05                	bnez	a4,ffffffffc02016b0 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc020167a:	000b1717          	auipc	a4,0xb1
ffffffffc020167e:	1ae73703          	ld	a4,430(a4) # ffffffffc02b2828 <pages>
ffffffffc0201682:	8c19                	sub	s0,s0,a4
ffffffffc0201684:	000807b7          	lui	a5,0x80
ffffffffc0201688:	8419                	srai	s0,s0,0x6
ffffffffc020168a:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020168c:	042a                	slli	s0,s0,0xa
ffffffffc020168e:	8cc1                	or	s1,s1,s0
ffffffffc0201690:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201694:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201698:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc020169c:	4501                	li	a0,0
}
ffffffffc020169e:	70e2                	ld	ra,56(sp)
ffffffffc02016a0:	7442                	ld	s0,48(sp)
ffffffffc02016a2:	74a2                	ld	s1,40(sp)
ffffffffc02016a4:	7902                	ld	s2,32(sp)
ffffffffc02016a6:	69e2                	ld	s3,24(sp)
ffffffffc02016a8:	6a42                	ld	s4,16(sp)
ffffffffc02016aa:	6aa2                	ld	s5,8(sp)
ffffffffc02016ac:	6121                	addi	sp,sp,64
ffffffffc02016ae:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02016b0:	078a                	slli	a5,a5,0x2
ffffffffc02016b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02016b4:	000b1717          	auipc	a4,0xb1
ffffffffc02016b8:	16c73703          	ld	a4,364(a4) # ffffffffc02b2820 <npage>
ffffffffc02016bc:	06e7ff63          	bgeu	a5,a4,ffffffffc020173a <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02016c0:	000b1a97          	auipc	s5,0xb1
ffffffffc02016c4:	168a8a93          	addi	s5,s5,360 # ffffffffc02b2828 <pages>
ffffffffc02016c8:	000ab703          	ld	a4,0(s5)
ffffffffc02016cc:	fff80937          	lui	s2,0xfff80
ffffffffc02016d0:	993e                	add	s2,s2,a5
ffffffffc02016d2:	091a                	slli	s2,s2,0x6
ffffffffc02016d4:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc02016d6:	01240c63          	beq	s0,s2,ffffffffc02016ee <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02016da:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd774>
ffffffffc02016de:	fff7869b          	addiw	a3,a5,-1
ffffffffc02016e2:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc02016e6:	c691                	beqz	a3,ffffffffc02016f2 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016e8:	120a0073          	sfence.vma	s4
}
ffffffffc02016ec:	bf59                	j	ffffffffc0201682 <page_insert+0x3a>
ffffffffc02016ee:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02016f0:	bf49                	j	ffffffffc0201682 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f2:	100027f3          	csrr	a5,sstatus
ffffffffc02016f6:	8b89                	andi	a5,a5,2
ffffffffc02016f8:	ef91                	bnez	a5,ffffffffc0201714 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02016fa:	000b1797          	auipc	a5,0xb1
ffffffffc02016fe:	1367b783          	ld	a5,310(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0201702:	739c                	ld	a5,32(a5)
ffffffffc0201704:	4585                	li	a1,1
ffffffffc0201706:	854a                	mv	a0,s2
ffffffffc0201708:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020170a:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020170e:	120a0073          	sfence.vma	s4
ffffffffc0201712:	bf85                	j	ffffffffc0201682 <page_insert+0x3a>
        intr_disable();
ffffffffc0201714:	f35fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201718:	000b1797          	auipc	a5,0xb1
ffffffffc020171c:	1187b783          	ld	a5,280(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0201720:	739c                	ld	a5,32(a5)
ffffffffc0201722:	4585                	li	a1,1
ffffffffc0201724:	854a                	mv	a0,s2
ffffffffc0201726:	9782                	jalr	a5
        intr_enable();
ffffffffc0201728:	f1bfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020172c:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201730:	120a0073          	sfence.vma	s4
ffffffffc0201734:	b7b9                	j	ffffffffc0201682 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201736:	5571                	li	a0,-4
ffffffffc0201738:	b79d                	j	ffffffffc020169e <page_insert+0x56>
ffffffffc020173a:	f30ff0ef          	jal	ra,ffffffffc0200e6a <pa2page.part.0>

ffffffffc020173e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020173e:	00007797          	auipc	a5,0x7
ffffffffc0201742:	c8278793          	addi	a5,a5,-894 # ffffffffc02083c0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201746:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201748:	711d                	addi	sp,sp,-96
ffffffffc020174a:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020174c:	00006517          	auipc	a0,0x6
ffffffffc0201750:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0207118 <commands+0x850>
    pmm_manager = &default_pmm_manager;
ffffffffc0201754:	000b1b97          	auipc	s7,0xb1
ffffffffc0201758:	0dcb8b93          	addi	s7,s7,220 # ffffffffc02b2830 <pmm_manager>
void pmm_init(void) {
ffffffffc020175c:	ec86                	sd	ra,88(sp)
ffffffffc020175e:	e4a6                	sd	s1,72(sp)
ffffffffc0201760:	fc4e                	sd	s3,56(sp)
ffffffffc0201762:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201764:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201768:	e8a2                	sd	s0,80(sp)
ffffffffc020176a:	e0ca                	sd	s2,64(sp)
ffffffffc020176c:	f852                	sd	s4,48(sp)
ffffffffc020176e:	f456                	sd	s5,40(sp)
ffffffffc0201770:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201772:	95bfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0201776:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020177a:	000b1997          	auipc	s3,0xb1
ffffffffc020177e:	0be98993          	addi	s3,s3,190 # ffffffffc02b2838 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201782:	000b1497          	auipc	s1,0xb1
ffffffffc0201786:	09e48493          	addi	s1,s1,158 # ffffffffc02b2820 <npage>
    pmm_manager->init();
ffffffffc020178a:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020178c:	000b1b17          	auipc	s6,0xb1
ffffffffc0201790:	09cb0b13          	addi	s6,s6,156 # ffffffffc02b2828 <pages>
    pmm_manager->init();
ffffffffc0201794:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201796:	57f5                	li	a5,-3
ffffffffc0201798:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020179a:	00006517          	auipc	a0,0x6
ffffffffc020179e:	99650513          	addi	a0,a0,-1642 # ffffffffc0207130 <commands+0x868>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02017a2:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02017a6:	927fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02017aa:	46c5                	li	a3,17
ffffffffc02017ac:	06ee                	slli	a3,a3,0x1b
ffffffffc02017ae:	40100613          	li	a2,1025
ffffffffc02017b2:	07e005b7          	lui	a1,0x7e00
ffffffffc02017b6:	16fd                	addi	a3,a3,-1
ffffffffc02017b8:	0656                	slli	a2,a2,0x15
ffffffffc02017ba:	00006517          	auipc	a0,0x6
ffffffffc02017be:	98e50513          	addi	a0,a0,-1650 # ffffffffc0207148 <commands+0x880>
ffffffffc02017c2:	90bfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02017c6:	777d                	lui	a4,0xfffff
ffffffffc02017c8:	000b2797          	auipc	a5,0xb2
ffffffffc02017cc:	0c378793          	addi	a5,a5,195 # ffffffffc02b388b <end+0xfff>
ffffffffc02017d0:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02017d2:	00088737          	lui	a4,0x88
ffffffffc02017d6:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02017d8:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02017dc:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017de:	4585                	li	a1,1
ffffffffc02017e0:	fff80837          	lui	a6,0xfff80
ffffffffc02017e4:	a019                	j	ffffffffc02017ea <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc02017e6:	000b3783          	ld	a5,0(s6)
ffffffffc02017ea:	00671693          	slli	a3,a4,0x6
ffffffffc02017ee:	97b6                	add	a5,a5,a3
ffffffffc02017f0:	07a1                	addi	a5,a5,8
ffffffffc02017f2:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02017f6:	6090                	ld	a2,0(s1)
ffffffffc02017f8:	0705                	addi	a4,a4,1
ffffffffc02017fa:	010607b3          	add	a5,a2,a6
ffffffffc02017fe:	fef764e3          	bltu	a4,a5,ffffffffc02017e6 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201802:	000b3503          	ld	a0,0(s6)
ffffffffc0201806:	079a                	slli	a5,a5,0x6
ffffffffc0201808:	c0200737          	lui	a4,0xc0200
ffffffffc020180c:	00f506b3          	add	a3,a0,a5
ffffffffc0201810:	60e6e563          	bltu	a3,a4,ffffffffc0201e1a <pmm_init+0x6dc>
ffffffffc0201814:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201818:	4745                	li	a4,17
ffffffffc020181a:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020181c:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020181e:	4ae6e563          	bltu	a3,a4,ffffffffc0201cc8 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201822:	00006517          	auipc	a0,0x6
ffffffffc0201826:	97650513          	addi	a0,a0,-1674 # ffffffffc0207198 <commands+0x8d0>
ffffffffc020182a:	8a3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020182e:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201832:	000b1917          	auipc	s2,0xb1
ffffffffc0201836:	fe690913          	addi	s2,s2,-26 # ffffffffc02b2818 <boot_pgdir>
    pmm_manager->check();
ffffffffc020183a:	7b9c                	ld	a5,48(a5)
ffffffffc020183c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020183e:	00006517          	auipc	a0,0x6
ffffffffc0201842:	97250513          	addi	a0,a0,-1678 # ffffffffc02071b0 <commands+0x8e8>
ffffffffc0201846:	887fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020184a:	00009697          	auipc	a3,0x9
ffffffffc020184e:	7b668693          	addi	a3,a3,1974 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0201852:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201856:	c02007b7          	lui	a5,0xc0200
ffffffffc020185a:	5cf6ec63          	bltu	a3,a5,ffffffffc0201e32 <pmm_init+0x6f4>
ffffffffc020185e:	0009b783          	ld	a5,0(s3)
ffffffffc0201862:	8e9d                	sub	a3,a3,a5
ffffffffc0201864:	000b1797          	auipc	a5,0xb1
ffffffffc0201868:	fad7b623          	sd	a3,-84(a5) # ffffffffc02b2810 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020186c:	100027f3          	csrr	a5,sstatus
ffffffffc0201870:	8b89                	andi	a5,a5,2
ffffffffc0201872:	48079263          	bnez	a5,ffffffffc0201cf6 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201876:	000bb783          	ld	a5,0(s7)
ffffffffc020187a:	779c                	ld	a5,40(a5)
ffffffffc020187c:	9782                	jalr	a5
ffffffffc020187e:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201880:	6098                	ld	a4,0(s1)
ffffffffc0201882:	c80007b7          	lui	a5,0xc8000
ffffffffc0201886:	83b1                	srli	a5,a5,0xc
ffffffffc0201888:	5ee7e163          	bltu	a5,a4,ffffffffc0201e6a <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020188c:	00093503          	ld	a0,0(s2)
ffffffffc0201890:	5a050d63          	beqz	a0,ffffffffc0201e4a <pmm_init+0x70c>
ffffffffc0201894:	03451793          	slli	a5,a0,0x34
ffffffffc0201898:	5a079963          	bnez	a5,ffffffffc0201e4a <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020189c:	4601                	li	a2,0
ffffffffc020189e:	4581                	li	a1,0
ffffffffc02018a0:	8e1ff0ef          	jal	ra,ffffffffc0201180 <get_page>
ffffffffc02018a4:	62051563          	bnez	a0,ffffffffc0201ece <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02018a8:	4505                	li	a0,1
ffffffffc02018aa:	df8ff0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc02018ae:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02018b0:	00093503          	ld	a0,0(s2)
ffffffffc02018b4:	4681                	li	a3,0
ffffffffc02018b6:	4601                	li	a2,0
ffffffffc02018b8:	85d2                	mv	a1,s4
ffffffffc02018ba:	d8fff0ef          	jal	ra,ffffffffc0201648 <page_insert>
ffffffffc02018be:	5e051863          	bnez	a0,ffffffffc0201eae <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02018c2:	00093503          	ld	a0,0(s2)
ffffffffc02018c6:	4601                	li	a2,0
ffffffffc02018c8:	4581                	li	a1,0
ffffffffc02018ca:	ee4ff0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc02018ce:	5c050063          	beqz	a0,ffffffffc0201e8e <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc02018d2:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02018d4:	0017f713          	andi	a4,a5,1
ffffffffc02018d8:	5a070963          	beqz	a4,ffffffffc0201e8a <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02018dc:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02018de:	078a                	slli	a5,a5,0x2
ffffffffc02018e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018e2:	52e7fa63          	bgeu	a5,a4,ffffffffc0201e16 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02018e6:	000b3683          	ld	a3,0(s6)
ffffffffc02018ea:	fff80637          	lui	a2,0xfff80
ffffffffc02018ee:	97b2                	add	a5,a5,a2
ffffffffc02018f0:	079a                	slli	a5,a5,0x6
ffffffffc02018f2:	97b6                	add	a5,a5,a3
ffffffffc02018f4:	10fa16e3          	bne	s4,a5,ffffffffc0202200 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc02018f8:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc02018fc:	4785                	li	a5,1
ffffffffc02018fe:	12f69de3          	bne	a3,a5,ffffffffc0202238 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201902:	00093503          	ld	a0,0(s2)
ffffffffc0201906:	77fd                	lui	a5,0xfffff
ffffffffc0201908:	6114                	ld	a3,0(a0)
ffffffffc020190a:	068a                	slli	a3,a3,0x2
ffffffffc020190c:	8efd                	and	a3,a3,a5
ffffffffc020190e:	00c6d613          	srli	a2,a3,0xc
ffffffffc0201912:	10e677e3          	bgeu	a2,a4,ffffffffc0202220 <pmm_init+0xae2>
ffffffffc0201916:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020191a:	96e2                	add	a3,a3,s8
ffffffffc020191c:	0006ba83          	ld	s5,0(a3)
ffffffffc0201920:	0a8a                	slli	s5,s5,0x2
ffffffffc0201922:	00fafab3          	and	s5,s5,a5
ffffffffc0201926:	00cad793          	srli	a5,s5,0xc
ffffffffc020192a:	62e7f263          	bgeu	a5,a4,ffffffffc0201f4e <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020192e:	4601                	li	a2,0
ffffffffc0201930:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201932:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201934:	e7aff0ef          	jal	ra,ffffffffc0200fae <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201938:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020193a:	5f551a63          	bne	a0,s5,ffffffffc0201f2e <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc020193e:	4505                	li	a0,1
ffffffffc0201940:	d62ff0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0201944:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201946:	00093503          	ld	a0,0(s2)
ffffffffc020194a:	46d1                	li	a3,20
ffffffffc020194c:	6605                	lui	a2,0x1
ffffffffc020194e:	85d6                	mv	a1,s5
ffffffffc0201950:	cf9ff0ef          	jal	ra,ffffffffc0201648 <page_insert>
ffffffffc0201954:	58051d63          	bnez	a0,ffffffffc0201eee <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201958:	00093503          	ld	a0,0(s2)
ffffffffc020195c:	4601                	li	a2,0
ffffffffc020195e:	6585                	lui	a1,0x1
ffffffffc0201960:	e4eff0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc0201964:	0e050ae3          	beqz	a0,ffffffffc0202258 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0201968:	611c                	ld	a5,0(a0)
ffffffffc020196a:	0107f713          	andi	a4,a5,16
ffffffffc020196e:	6e070d63          	beqz	a4,ffffffffc0202068 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0201972:	8b91                	andi	a5,a5,4
ffffffffc0201974:	6a078a63          	beqz	a5,ffffffffc0202028 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201978:	00093503          	ld	a0,0(s2)
ffffffffc020197c:	611c                	ld	a5,0(a0)
ffffffffc020197e:	8bc1                	andi	a5,a5,16
ffffffffc0201980:	68078463          	beqz	a5,ffffffffc0202008 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc0201984:	000aa703          	lw	a4,0(s5)
ffffffffc0201988:	4785                	li	a5,1
ffffffffc020198a:	58f71263          	bne	a4,a5,ffffffffc0201f0e <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020198e:	4681                	li	a3,0
ffffffffc0201990:	6605                	lui	a2,0x1
ffffffffc0201992:	85d2                	mv	a1,s4
ffffffffc0201994:	cb5ff0ef          	jal	ra,ffffffffc0201648 <page_insert>
ffffffffc0201998:	62051863          	bnez	a0,ffffffffc0201fc8 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc020199c:	000a2703          	lw	a4,0(s4)
ffffffffc02019a0:	4789                	li	a5,2
ffffffffc02019a2:	60f71363          	bne	a4,a5,ffffffffc0201fa8 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02019a6:	000aa783          	lw	a5,0(s5)
ffffffffc02019aa:	5c079f63          	bnez	a5,ffffffffc0201f88 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02019ae:	00093503          	ld	a0,0(s2)
ffffffffc02019b2:	4601                	li	a2,0
ffffffffc02019b4:	6585                	lui	a1,0x1
ffffffffc02019b6:	df8ff0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc02019ba:	5a050763          	beqz	a0,ffffffffc0201f68 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02019be:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02019c0:	00177793          	andi	a5,a4,1
ffffffffc02019c4:	4c078363          	beqz	a5,ffffffffc0201e8a <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02019c8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019ca:	00271793          	slli	a5,a4,0x2
ffffffffc02019ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019d0:	44d7f363          	bgeu	a5,a3,ffffffffc0201e16 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02019d4:	000b3683          	ld	a3,0(s6)
ffffffffc02019d8:	fff80637          	lui	a2,0xfff80
ffffffffc02019dc:	97b2                	add	a5,a5,a2
ffffffffc02019de:	079a                	slli	a5,a5,0x6
ffffffffc02019e0:	97b6                	add	a5,a5,a3
ffffffffc02019e2:	6efa1363          	bne	s4,a5,ffffffffc02020c8 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc02019e6:	8b41                	andi	a4,a4,16
ffffffffc02019e8:	6c071063          	bnez	a4,ffffffffc02020a8 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc02019ec:	00093503          	ld	a0,0(s2)
ffffffffc02019f0:	4581                	li	a1,0
ffffffffc02019f2:	bbbff0ef          	jal	ra,ffffffffc02015ac <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02019f6:	000a2703          	lw	a4,0(s4)
ffffffffc02019fa:	4785                	li	a5,1
ffffffffc02019fc:	68f71663          	bne	a4,a5,ffffffffc0202088 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0201a00:	000aa783          	lw	a5,0(s5)
ffffffffc0201a04:	74079e63          	bnez	a5,ffffffffc0202160 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201a08:	00093503          	ld	a0,0(s2)
ffffffffc0201a0c:	6585                	lui	a1,0x1
ffffffffc0201a0e:	b9fff0ef          	jal	ra,ffffffffc02015ac <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201a12:	000a2783          	lw	a5,0(s4)
ffffffffc0201a16:	72079563          	bnez	a5,ffffffffc0202140 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0201a1a:	000aa783          	lw	a5,0(s5)
ffffffffc0201a1e:	70079163          	bnez	a5,ffffffffc0202120 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201a22:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201a26:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a28:	000a3683          	ld	a3,0(s4)
ffffffffc0201a2c:	068a                	slli	a3,a3,0x2
ffffffffc0201a2e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a30:	3ee6f363          	bgeu	a3,a4,ffffffffc0201e16 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a34:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a38:	000b3503          	ld	a0,0(s6)
ffffffffc0201a3c:	96be                	add	a3,a3,a5
ffffffffc0201a3e:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0201a40:	00d507b3          	add	a5,a0,a3
ffffffffc0201a44:	4390                	lw	a2,0(a5)
ffffffffc0201a46:	4785                	li	a5,1
ffffffffc0201a48:	6af61c63          	bne	a2,a5,ffffffffc0202100 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0201a4c:	8699                	srai	a3,a3,0x6
ffffffffc0201a4e:	000805b7          	lui	a1,0x80
ffffffffc0201a52:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0201a54:	00c69613          	slli	a2,a3,0xc
ffffffffc0201a58:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201a5a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201a5c:	68e67663          	bgeu	a2,a4,ffffffffc02020e8 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201a60:	0009b603          	ld	a2,0(s3)
ffffffffc0201a64:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a66:	629c                	ld	a5,0(a3)
ffffffffc0201a68:	078a                	slli	a5,a5,0x2
ffffffffc0201a6a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a6c:	3ae7f563          	bgeu	a5,a4,ffffffffc0201e16 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a70:	8f8d                	sub	a5,a5,a1
ffffffffc0201a72:	079a                	slli	a5,a5,0x6
ffffffffc0201a74:	953e                	add	a0,a0,a5
ffffffffc0201a76:	100027f3          	csrr	a5,sstatus
ffffffffc0201a7a:	8b89                	andi	a5,a5,2
ffffffffc0201a7c:	2c079763          	bnez	a5,ffffffffc0201d4a <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0201a80:	000bb783          	ld	a5,0(s7)
ffffffffc0201a84:	4585                	li	a1,1
ffffffffc0201a86:	739c                	ld	a5,32(a5)
ffffffffc0201a88:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a8a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201a8e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a90:	078a                	slli	a5,a5,0x2
ffffffffc0201a92:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a94:	38e7f163          	bgeu	a5,a4,ffffffffc0201e16 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a98:	000b3503          	ld	a0,0(s6)
ffffffffc0201a9c:	fff80737          	lui	a4,0xfff80
ffffffffc0201aa0:	97ba                	add	a5,a5,a4
ffffffffc0201aa2:	079a                	slli	a5,a5,0x6
ffffffffc0201aa4:	953e                	add	a0,a0,a5
ffffffffc0201aa6:	100027f3          	csrr	a5,sstatus
ffffffffc0201aaa:	8b89                	andi	a5,a5,2
ffffffffc0201aac:	28079363          	bnez	a5,ffffffffc0201d32 <pmm_init+0x5f4>
ffffffffc0201ab0:	000bb783          	ld	a5,0(s7)
ffffffffc0201ab4:	4585                	li	a1,1
ffffffffc0201ab6:	739c                	ld	a5,32(a5)
ffffffffc0201ab8:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201aba:	00093783          	ld	a5,0(s2)
ffffffffc0201abe:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd774>
  asm volatile("sfence.vma");
ffffffffc0201ac2:	12000073          	sfence.vma
ffffffffc0201ac6:	100027f3          	csrr	a5,sstatus
ffffffffc0201aca:	8b89                	andi	a5,a5,2
ffffffffc0201acc:	24079963          	bnez	a5,ffffffffc0201d1e <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201ad0:	000bb783          	ld	a5,0(s7)
ffffffffc0201ad4:	779c                	ld	a5,40(a5)
ffffffffc0201ad6:	9782                	jalr	a5
ffffffffc0201ad8:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201ada:	71441363          	bne	s0,s4,ffffffffc02021e0 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ade:	00006517          	auipc	a0,0x6
ffffffffc0201ae2:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0207498 <commands+0xbd0>
ffffffffc0201ae6:	de6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201aea:	100027f3          	csrr	a5,sstatus
ffffffffc0201aee:	8b89                	andi	a5,a5,2
ffffffffc0201af0:	20079d63          	bnez	a5,ffffffffc0201d0a <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201af4:	000bb783          	ld	a5,0(s7)
ffffffffc0201af8:	779c                	ld	a5,40(a5)
ffffffffc0201afa:	9782                	jalr	a5
ffffffffc0201afc:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201afe:	6098                	ld	a4,0(s1)
ffffffffc0201b00:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201b04:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201b06:	00c71793          	slli	a5,a4,0xc
ffffffffc0201b0a:	6a05                	lui	s4,0x1
ffffffffc0201b0c:	02f47c63          	bgeu	s0,a5,ffffffffc0201b44 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b10:	00c45793          	srli	a5,s0,0xc
ffffffffc0201b14:	00093503          	ld	a0,0(s2)
ffffffffc0201b18:	2ee7f263          	bgeu	a5,a4,ffffffffc0201dfc <pmm_init+0x6be>
ffffffffc0201b1c:	0009b583          	ld	a1,0(s3)
ffffffffc0201b20:	4601                	li	a2,0
ffffffffc0201b22:	95a2                	add	a1,a1,s0
ffffffffc0201b24:	c8aff0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc0201b28:	2a050a63          	beqz	a0,ffffffffc0201ddc <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201b2c:	611c                	ld	a5,0(a0)
ffffffffc0201b2e:	078a                	slli	a5,a5,0x2
ffffffffc0201b30:	0157f7b3          	and	a5,a5,s5
ffffffffc0201b34:	28879463          	bne	a5,s0,ffffffffc0201dbc <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201b38:	6098                	ld	a4,0(s1)
ffffffffc0201b3a:	9452                	add	s0,s0,s4
ffffffffc0201b3c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201b40:	fcf468e3          	bltu	s0,a5,ffffffffc0201b10 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201b44:	00093783          	ld	a5,0(s2)
ffffffffc0201b48:	639c                	ld	a5,0(a5)
ffffffffc0201b4a:	66079b63          	bnez	a5,ffffffffc02021c0 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0201b4e:	4505                	li	a0,1
ffffffffc0201b50:	b52ff0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0201b54:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201b56:	00093503          	ld	a0,0(s2)
ffffffffc0201b5a:	4699                	li	a3,6
ffffffffc0201b5c:	10000613          	li	a2,256
ffffffffc0201b60:	85d6                	mv	a1,s5
ffffffffc0201b62:	ae7ff0ef          	jal	ra,ffffffffc0201648 <page_insert>
ffffffffc0201b66:	62051d63          	bnez	a0,ffffffffc02021a0 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0201b6a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c774>
ffffffffc0201b6e:	4785                	li	a5,1
ffffffffc0201b70:	60f71863          	bne	a4,a5,ffffffffc0202180 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201b74:	00093503          	ld	a0,0(s2)
ffffffffc0201b78:	6405                	lui	s0,0x1
ffffffffc0201b7a:	4699                	li	a3,6
ffffffffc0201b7c:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab8>
ffffffffc0201b80:	85d6                	mv	a1,s5
ffffffffc0201b82:	ac7ff0ef          	jal	ra,ffffffffc0201648 <page_insert>
ffffffffc0201b86:	46051163          	bnez	a0,ffffffffc0201fe8 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0201b8a:	000aa703          	lw	a4,0(s5)
ffffffffc0201b8e:	4789                	li	a5,2
ffffffffc0201b90:	72f71463          	bne	a4,a5,ffffffffc02022b8 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201b94:	00006597          	auipc	a1,0x6
ffffffffc0201b98:	a3c58593          	addi	a1,a1,-1476 # ffffffffc02075d0 <commands+0xd08>
ffffffffc0201b9c:	10000513          	li	a0,256
ffffffffc0201ba0:	60a040ef          	jal	ra,ffffffffc02061aa <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201ba4:	10040593          	addi	a1,s0,256
ffffffffc0201ba8:	10000513          	li	a0,256
ffffffffc0201bac:	610040ef          	jal	ra,ffffffffc02061bc <strcmp>
ffffffffc0201bb0:	6e051463          	bnez	a0,ffffffffc0202298 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc0201bb4:	000b3683          	ld	a3,0(s6)
ffffffffc0201bb8:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201bbc:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0201bbe:	40da86b3          	sub	a3,s5,a3
ffffffffc0201bc2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201bc4:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201bc6:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201bc8:	8031                	srli	s0,s0,0xc
ffffffffc0201bca:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bce:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201bd0:	50f77c63          	bgeu	a4,a5,ffffffffc02020e8 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201bd4:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201bd8:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201bdc:	96be                	add	a3,a3,a5
ffffffffc0201bde:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201be2:	592040ef          	jal	ra,ffffffffc0206174 <strlen>
ffffffffc0201be6:	68051963          	bnez	a0,ffffffffc0202278 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201bea:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201bee:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bf0:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0201bf4:	068a                	slli	a3,a3,0x2
ffffffffc0201bf6:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bf8:	20f6ff63          	bgeu	a3,a5,ffffffffc0201e16 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0201bfc:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bfe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201c00:	4ef47463          	bgeu	s0,a5,ffffffffc02020e8 <pmm_init+0x9aa>
ffffffffc0201c04:	0009b403          	ld	s0,0(s3)
ffffffffc0201c08:	9436                	add	s0,s0,a3
ffffffffc0201c0a:	100027f3          	csrr	a5,sstatus
ffffffffc0201c0e:	8b89                	andi	a5,a5,2
ffffffffc0201c10:	18079b63          	bnez	a5,ffffffffc0201da6 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0201c14:	000bb783          	ld	a5,0(s7)
ffffffffc0201c18:	4585                	li	a1,1
ffffffffc0201c1a:	8556                	mv	a0,s5
ffffffffc0201c1c:	739c                	ld	a5,32(a5)
ffffffffc0201c1e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c20:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201c22:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c24:	078a                	slli	a5,a5,0x2
ffffffffc0201c26:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c28:	1ee7f763          	bgeu	a5,a4,ffffffffc0201e16 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c2c:	000b3503          	ld	a0,0(s6)
ffffffffc0201c30:	fff80737          	lui	a4,0xfff80
ffffffffc0201c34:	97ba                	add	a5,a5,a4
ffffffffc0201c36:	079a                	slli	a5,a5,0x6
ffffffffc0201c38:	953e                	add	a0,a0,a5
ffffffffc0201c3a:	100027f3          	csrr	a5,sstatus
ffffffffc0201c3e:	8b89                	andi	a5,a5,2
ffffffffc0201c40:	14079763          	bnez	a5,ffffffffc0201d8e <pmm_init+0x650>
ffffffffc0201c44:	000bb783          	ld	a5,0(s7)
ffffffffc0201c48:	4585                	li	a1,1
ffffffffc0201c4a:	739c                	ld	a5,32(a5)
ffffffffc0201c4c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c4e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201c52:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c54:	078a                	slli	a5,a5,0x2
ffffffffc0201c56:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c58:	1ae7ff63          	bgeu	a5,a4,ffffffffc0201e16 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c5c:	000b3503          	ld	a0,0(s6)
ffffffffc0201c60:	fff80737          	lui	a4,0xfff80
ffffffffc0201c64:	97ba                	add	a5,a5,a4
ffffffffc0201c66:	079a                	slli	a5,a5,0x6
ffffffffc0201c68:	953e                	add	a0,a0,a5
ffffffffc0201c6a:	100027f3          	csrr	a5,sstatus
ffffffffc0201c6e:	8b89                	andi	a5,a5,2
ffffffffc0201c70:	10079363          	bnez	a5,ffffffffc0201d76 <pmm_init+0x638>
ffffffffc0201c74:	000bb783          	ld	a5,0(s7)
ffffffffc0201c78:	4585                	li	a1,1
ffffffffc0201c7a:	739c                	ld	a5,32(a5)
ffffffffc0201c7c:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201c7e:	00093783          	ld	a5,0(s2)
ffffffffc0201c82:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201c86:	12000073          	sfence.vma
ffffffffc0201c8a:	100027f3          	csrr	a5,sstatus
ffffffffc0201c8e:	8b89                	andi	a5,a5,2
ffffffffc0201c90:	0c079963          	bnez	a5,ffffffffc0201d62 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c94:	000bb783          	ld	a5,0(s7)
ffffffffc0201c98:	779c                	ld	a5,40(a5)
ffffffffc0201c9a:	9782                	jalr	a5
ffffffffc0201c9c:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201c9e:	3a8c1563          	bne	s8,s0,ffffffffc0202048 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201ca2:	00006517          	auipc	a0,0x6
ffffffffc0201ca6:	9a650513          	addi	a0,a0,-1626 # ffffffffc0207648 <commands+0xd80>
ffffffffc0201caa:	c22fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0201cae:	6446                	ld	s0,80(sp)
ffffffffc0201cb0:	60e6                	ld	ra,88(sp)
ffffffffc0201cb2:	64a6                	ld	s1,72(sp)
ffffffffc0201cb4:	6906                	ld	s2,64(sp)
ffffffffc0201cb6:	79e2                	ld	s3,56(sp)
ffffffffc0201cb8:	7a42                	ld	s4,48(sp)
ffffffffc0201cba:	7aa2                	ld	s5,40(sp)
ffffffffc0201cbc:	7b02                	ld	s6,32(sp)
ffffffffc0201cbe:	6be2                	ld	s7,24(sp)
ffffffffc0201cc0:	6c42                	ld	s8,16(sp)
ffffffffc0201cc2:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0201cc4:	1710106f          	j	ffffffffc0203634 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201cc8:	6785                	lui	a5,0x1
ffffffffc0201cca:	17fd                	addi	a5,a5,-1
ffffffffc0201ccc:	96be                	add	a3,a3,a5
ffffffffc0201cce:	77fd                	lui	a5,0xfffff
ffffffffc0201cd0:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0201cd2:	00c7d693          	srli	a3,a5,0xc
ffffffffc0201cd6:	14c6f063          	bgeu	a3,a2,ffffffffc0201e16 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0201cda:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0201cde:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201ce0:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0201ce4:	6a10                	ld	a2,16(a2)
ffffffffc0201ce6:	069a                	slli	a3,a3,0x6
ffffffffc0201ce8:	00c7d593          	srli	a1,a5,0xc
ffffffffc0201cec:	9536                	add	a0,a0,a3
ffffffffc0201cee:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201cf0:	0009b583          	ld	a1,0(s3)
}
ffffffffc0201cf4:	b63d                	j	ffffffffc0201822 <pmm_init+0xe4>
        intr_disable();
ffffffffc0201cf6:	953fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201cfa:	000bb783          	ld	a5,0(s7)
ffffffffc0201cfe:	779c                	ld	a5,40(a5)
ffffffffc0201d00:	9782                	jalr	a5
ffffffffc0201d02:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d04:	93ffe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d08:	bea5                	j	ffffffffc0201880 <pmm_init+0x142>
        intr_disable();
ffffffffc0201d0a:	93ffe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d0e:	000bb783          	ld	a5,0(s7)
ffffffffc0201d12:	779c                	ld	a5,40(a5)
ffffffffc0201d14:	9782                	jalr	a5
ffffffffc0201d16:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201d18:	92bfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d1c:	b3cd                	j	ffffffffc0201afe <pmm_init+0x3c0>
        intr_disable();
ffffffffc0201d1e:	92bfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d22:	000bb783          	ld	a5,0(s7)
ffffffffc0201d26:	779c                	ld	a5,40(a5)
ffffffffc0201d28:	9782                	jalr	a5
ffffffffc0201d2a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201d2c:	917fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d30:	b36d                	j	ffffffffc0201ada <pmm_init+0x39c>
ffffffffc0201d32:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d34:	915fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d38:	000bb783          	ld	a5,0(s7)
ffffffffc0201d3c:	6522                	ld	a0,8(sp)
ffffffffc0201d3e:	4585                	li	a1,1
ffffffffc0201d40:	739c                	ld	a5,32(a5)
ffffffffc0201d42:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d44:	8fffe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d48:	bb8d                	j	ffffffffc0201aba <pmm_init+0x37c>
ffffffffc0201d4a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d4c:	8fdfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d50:	000bb783          	ld	a5,0(s7)
ffffffffc0201d54:	6522                	ld	a0,8(sp)
ffffffffc0201d56:	4585                	li	a1,1
ffffffffc0201d58:	739c                	ld	a5,32(a5)
ffffffffc0201d5a:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d5c:	8e7fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d60:	b32d                	j	ffffffffc0201a8a <pmm_init+0x34c>
        intr_disable();
ffffffffc0201d62:	8e7fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d66:	000bb783          	ld	a5,0(s7)
ffffffffc0201d6a:	779c                	ld	a5,40(a5)
ffffffffc0201d6c:	9782                	jalr	a5
ffffffffc0201d6e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d70:	8d3fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d74:	b72d                	j	ffffffffc0201c9e <pmm_init+0x560>
ffffffffc0201d76:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d78:	8d1fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d7c:	000bb783          	ld	a5,0(s7)
ffffffffc0201d80:	6522                	ld	a0,8(sp)
ffffffffc0201d82:	4585                	li	a1,1
ffffffffc0201d84:	739c                	ld	a5,32(a5)
ffffffffc0201d86:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d88:	8bbfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d8c:	bdcd                	j	ffffffffc0201c7e <pmm_init+0x540>
ffffffffc0201d8e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d90:	8b9fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d94:	000bb783          	ld	a5,0(s7)
ffffffffc0201d98:	6522                	ld	a0,8(sp)
ffffffffc0201d9a:	4585                	li	a1,1
ffffffffc0201d9c:	739c                	ld	a5,32(a5)
ffffffffc0201d9e:	9782                	jalr	a5
        intr_enable();
ffffffffc0201da0:	8a3fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201da4:	b56d                	j	ffffffffc0201c4e <pmm_init+0x510>
        intr_disable();
ffffffffc0201da6:	8a3fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201daa:	000bb783          	ld	a5,0(s7)
ffffffffc0201dae:	4585                	li	a1,1
ffffffffc0201db0:	8556                	mv	a0,s5
ffffffffc0201db2:	739c                	ld	a5,32(a5)
ffffffffc0201db4:	9782                	jalr	a5
        intr_enable();
ffffffffc0201db6:	88dfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201dba:	b59d                	j	ffffffffc0201c20 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201dbc:	00005697          	auipc	a3,0x5
ffffffffc0201dc0:	73c68693          	addi	a3,a3,1852 # ffffffffc02074f8 <commands+0xc30>
ffffffffc0201dc4:	00005617          	auipc	a2,0x5
ffffffffc0201dc8:	f1460613          	addi	a2,a2,-236 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201dcc:	22800593          	li	a1,552
ffffffffc0201dd0:	00005517          	auipc	a0,0x5
ffffffffc0201dd4:	2f050513          	addi	a0,a0,752 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201dd8:	c30fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ddc:	00005697          	auipc	a3,0x5
ffffffffc0201de0:	6dc68693          	addi	a3,a3,1756 # ffffffffc02074b8 <commands+0xbf0>
ffffffffc0201de4:	00005617          	auipc	a2,0x5
ffffffffc0201de8:	ef460613          	addi	a2,a2,-268 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201dec:	22700593          	li	a1,551
ffffffffc0201df0:	00005517          	auipc	a0,0x5
ffffffffc0201df4:	2d050513          	addi	a0,a0,720 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201df8:	c10fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201dfc:	86a2                	mv	a3,s0
ffffffffc0201dfe:	00005617          	auipc	a2,0x5
ffffffffc0201e02:	29a60613          	addi	a2,a2,666 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0201e06:	22700593          	li	a1,551
ffffffffc0201e0a:	00005517          	auipc	a0,0x5
ffffffffc0201e0e:	2b650513          	addi	a0,a0,694 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201e12:	bf6fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201e16:	854ff0ef          	jal	ra,ffffffffc0200e6a <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201e1a:	00005617          	auipc	a2,0x5
ffffffffc0201e1e:	35660613          	addi	a2,a2,854 # ffffffffc0207170 <commands+0x8a8>
ffffffffc0201e22:	07f00593          	li	a1,127
ffffffffc0201e26:	00005517          	auipc	a0,0x5
ffffffffc0201e2a:	29a50513          	addi	a0,a0,666 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201e2e:	bdafe0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201e32:	00005617          	auipc	a2,0x5
ffffffffc0201e36:	33e60613          	addi	a2,a2,830 # ffffffffc0207170 <commands+0x8a8>
ffffffffc0201e3a:	0c100593          	li	a1,193
ffffffffc0201e3e:	00005517          	auipc	a0,0x5
ffffffffc0201e42:	28250513          	addi	a0,a0,642 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201e46:	bc2fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201e4a:	00005697          	auipc	a3,0x5
ffffffffc0201e4e:	3a668693          	addi	a3,a3,934 # ffffffffc02071f0 <commands+0x928>
ffffffffc0201e52:	00005617          	auipc	a2,0x5
ffffffffc0201e56:	e8660613          	addi	a2,a2,-378 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201e5a:	1eb00593          	li	a1,491
ffffffffc0201e5e:	00005517          	auipc	a0,0x5
ffffffffc0201e62:	26250513          	addi	a0,a0,610 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201e66:	ba2fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201e6a:	00005697          	auipc	a3,0x5
ffffffffc0201e6e:	36668693          	addi	a3,a3,870 # ffffffffc02071d0 <commands+0x908>
ffffffffc0201e72:	00005617          	auipc	a2,0x5
ffffffffc0201e76:	e6660613          	addi	a2,a2,-410 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201e7a:	1ea00593          	li	a1,490
ffffffffc0201e7e:	00005517          	auipc	a0,0x5
ffffffffc0201e82:	24250513          	addi	a0,a0,578 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201e86:	b82fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201e8a:	ffdfe0ef          	jal	ra,ffffffffc0200e86 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201e8e:	00005697          	auipc	a3,0x5
ffffffffc0201e92:	3f268693          	addi	a3,a3,1010 # ffffffffc0207280 <commands+0x9b8>
ffffffffc0201e96:	00005617          	auipc	a2,0x5
ffffffffc0201e9a:	e4260613          	addi	a2,a2,-446 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201e9e:	1f300593          	li	a1,499
ffffffffc0201ea2:	00005517          	auipc	a0,0x5
ffffffffc0201ea6:	21e50513          	addi	a0,a0,542 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201eaa:	b5efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201eae:	00005697          	auipc	a3,0x5
ffffffffc0201eb2:	3a268693          	addi	a3,a3,930 # ffffffffc0207250 <commands+0x988>
ffffffffc0201eb6:	00005617          	auipc	a2,0x5
ffffffffc0201eba:	e2260613          	addi	a2,a2,-478 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201ebe:	1f000593          	li	a1,496
ffffffffc0201ec2:	00005517          	auipc	a0,0x5
ffffffffc0201ec6:	1fe50513          	addi	a0,a0,510 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201eca:	b3efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201ece:	00005697          	auipc	a3,0x5
ffffffffc0201ed2:	35a68693          	addi	a3,a3,858 # ffffffffc0207228 <commands+0x960>
ffffffffc0201ed6:	00005617          	auipc	a2,0x5
ffffffffc0201eda:	e0260613          	addi	a2,a2,-510 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201ede:	1ec00593          	li	a1,492
ffffffffc0201ee2:	00005517          	auipc	a0,0x5
ffffffffc0201ee6:	1de50513          	addi	a0,a0,478 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201eea:	b1efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201eee:	00005697          	auipc	a3,0x5
ffffffffc0201ef2:	41a68693          	addi	a3,a3,1050 # ffffffffc0207308 <commands+0xa40>
ffffffffc0201ef6:	00005617          	auipc	a2,0x5
ffffffffc0201efa:	de260613          	addi	a2,a2,-542 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201efe:	1fc00593          	li	a1,508
ffffffffc0201f02:	00005517          	auipc	a0,0x5
ffffffffc0201f06:	1be50513          	addi	a0,a0,446 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201f0a:	afefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201f0e:	00005697          	auipc	a3,0x5
ffffffffc0201f12:	49a68693          	addi	a3,a3,1178 # ffffffffc02073a8 <commands+0xae0>
ffffffffc0201f16:	00005617          	auipc	a2,0x5
ffffffffc0201f1a:	dc260613          	addi	a2,a2,-574 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201f1e:	20100593          	li	a1,513
ffffffffc0201f22:	00005517          	auipc	a0,0x5
ffffffffc0201f26:	19e50513          	addi	a0,a0,414 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201f2a:	adefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201f2e:	00005697          	auipc	a3,0x5
ffffffffc0201f32:	3b268693          	addi	a3,a3,946 # ffffffffc02072e0 <commands+0xa18>
ffffffffc0201f36:	00005617          	auipc	a2,0x5
ffffffffc0201f3a:	da260613          	addi	a2,a2,-606 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201f3e:	1f900593          	li	a1,505
ffffffffc0201f42:	00005517          	auipc	a0,0x5
ffffffffc0201f46:	17e50513          	addi	a0,a0,382 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201f4a:	abefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201f4e:	86d6                	mv	a3,s5
ffffffffc0201f50:	00005617          	auipc	a2,0x5
ffffffffc0201f54:	14860613          	addi	a2,a2,328 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0201f58:	1f800593          	li	a1,504
ffffffffc0201f5c:	00005517          	auipc	a0,0x5
ffffffffc0201f60:	16450513          	addi	a0,a0,356 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201f64:	aa4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201f68:	00005697          	auipc	a3,0x5
ffffffffc0201f6c:	3d868693          	addi	a3,a3,984 # ffffffffc0207340 <commands+0xa78>
ffffffffc0201f70:	00005617          	auipc	a2,0x5
ffffffffc0201f74:	d6860613          	addi	a2,a2,-664 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201f78:	20600593          	li	a1,518
ffffffffc0201f7c:	00005517          	auipc	a0,0x5
ffffffffc0201f80:	14450513          	addi	a0,a0,324 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201f84:	a84fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201f88:	00005697          	auipc	a3,0x5
ffffffffc0201f8c:	48068693          	addi	a3,a3,1152 # ffffffffc0207408 <commands+0xb40>
ffffffffc0201f90:	00005617          	auipc	a2,0x5
ffffffffc0201f94:	d4860613          	addi	a2,a2,-696 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201f98:	20500593          	li	a1,517
ffffffffc0201f9c:	00005517          	auipc	a0,0x5
ffffffffc0201fa0:	12450513          	addi	a0,a0,292 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201fa4:	a64fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201fa8:	00005697          	auipc	a3,0x5
ffffffffc0201fac:	44868693          	addi	a3,a3,1096 # ffffffffc02073f0 <commands+0xb28>
ffffffffc0201fb0:	00005617          	auipc	a2,0x5
ffffffffc0201fb4:	d2860613          	addi	a2,a2,-728 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201fb8:	20400593          	li	a1,516
ffffffffc0201fbc:	00005517          	auipc	a0,0x5
ffffffffc0201fc0:	10450513          	addi	a0,a0,260 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201fc4:	a44fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201fc8:	00005697          	auipc	a3,0x5
ffffffffc0201fcc:	3f868693          	addi	a3,a3,1016 # ffffffffc02073c0 <commands+0xaf8>
ffffffffc0201fd0:	00005617          	auipc	a2,0x5
ffffffffc0201fd4:	d0860613          	addi	a2,a2,-760 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201fd8:	20300593          	li	a1,515
ffffffffc0201fdc:	00005517          	auipc	a0,0x5
ffffffffc0201fe0:	0e450513          	addi	a0,a0,228 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0201fe4:	a24fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201fe8:	00005697          	auipc	a3,0x5
ffffffffc0201fec:	59068693          	addi	a3,a3,1424 # ffffffffc0207578 <commands+0xcb0>
ffffffffc0201ff0:	00005617          	auipc	a2,0x5
ffffffffc0201ff4:	ce860613          	addi	a2,a2,-792 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0201ff8:	23200593          	li	a1,562
ffffffffc0201ffc:	00005517          	auipc	a0,0x5
ffffffffc0202000:	0c450513          	addi	a0,a0,196 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202004:	a04fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202008:	00005697          	auipc	a3,0x5
ffffffffc020200c:	38868693          	addi	a3,a3,904 # ffffffffc0207390 <commands+0xac8>
ffffffffc0202010:	00005617          	auipc	a2,0x5
ffffffffc0202014:	cc860613          	addi	a2,a2,-824 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202018:	20000593          	li	a1,512
ffffffffc020201c:	00005517          	auipc	a0,0x5
ffffffffc0202020:	0a450513          	addi	a0,a0,164 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202024:	9e4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202028:	00005697          	auipc	a3,0x5
ffffffffc020202c:	35868693          	addi	a3,a3,856 # ffffffffc0207380 <commands+0xab8>
ffffffffc0202030:	00005617          	auipc	a2,0x5
ffffffffc0202034:	ca860613          	addi	a2,a2,-856 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202038:	1ff00593          	li	a1,511
ffffffffc020203c:	00005517          	auipc	a0,0x5
ffffffffc0202040:	08450513          	addi	a0,a0,132 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202044:	9c4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202048:	00005697          	auipc	a3,0x5
ffffffffc020204c:	43068693          	addi	a3,a3,1072 # ffffffffc0207478 <commands+0xbb0>
ffffffffc0202050:	00005617          	auipc	a2,0x5
ffffffffc0202054:	c8860613          	addi	a2,a2,-888 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202058:	24300593          	li	a1,579
ffffffffc020205c:	00005517          	auipc	a0,0x5
ffffffffc0202060:	06450513          	addi	a0,a0,100 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202064:	9a4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202068:	00005697          	auipc	a3,0x5
ffffffffc020206c:	30868693          	addi	a3,a3,776 # ffffffffc0207370 <commands+0xaa8>
ffffffffc0202070:	00005617          	auipc	a2,0x5
ffffffffc0202074:	c6860613          	addi	a2,a2,-920 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202078:	1fe00593          	li	a1,510
ffffffffc020207c:	00005517          	auipc	a0,0x5
ffffffffc0202080:	04450513          	addi	a0,a0,68 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202084:	984fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202088:	00005697          	auipc	a3,0x5
ffffffffc020208c:	24068693          	addi	a3,a3,576 # ffffffffc02072c8 <commands+0xa00>
ffffffffc0202090:	00005617          	auipc	a2,0x5
ffffffffc0202094:	c4860613          	addi	a2,a2,-952 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202098:	20b00593          	li	a1,523
ffffffffc020209c:	00005517          	auipc	a0,0x5
ffffffffc02020a0:	02450513          	addi	a0,a0,36 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02020a4:	964fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02020a8:	00005697          	auipc	a3,0x5
ffffffffc02020ac:	37868693          	addi	a3,a3,888 # ffffffffc0207420 <commands+0xb58>
ffffffffc02020b0:	00005617          	auipc	a2,0x5
ffffffffc02020b4:	c2860613          	addi	a2,a2,-984 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02020b8:	20800593          	li	a1,520
ffffffffc02020bc:	00005517          	auipc	a0,0x5
ffffffffc02020c0:	00450513          	addi	a0,a0,4 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02020c4:	944fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02020c8:	00005697          	auipc	a3,0x5
ffffffffc02020cc:	1e868693          	addi	a3,a3,488 # ffffffffc02072b0 <commands+0x9e8>
ffffffffc02020d0:	00005617          	auipc	a2,0x5
ffffffffc02020d4:	c0860613          	addi	a2,a2,-1016 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02020d8:	20700593          	li	a1,519
ffffffffc02020dc:	00005517          	auipc	a0,0x5
ffffffffc02020e0:	fe450513          	addi	a0,a0,-28 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02020e4:	924fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02020e8:	00005617          	auipc	a2,0x5
ffffffffc02020ec:	fb060613          	addi	a2,a2,-80 # ffffffffc0207098 <commands+0x7d0>
ffffffffc02020f0:	06900593          	li	a1,105
ffffffffc02020f4:	00005517          	auipc	a0,0x5
ffffffffc02020f8:	f6c50513          	addi	a0,a0,-148 # ffffffffc0207060 <commands+0x798>
ffffffffc02020fc:	90cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202100:	00005697          	auipc	a3,0x5
ffffffffc0202104:	35068693          	addi	a3,a3,848 # ffffffffc0207450 <commands+0xb88>
ffffffffc0202108:	00005617          	auipc	a2,0x5
ffffffffc020210c:	bd060613          	addi	a2,a2,-1072 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202110:	21200593          	li	a1,530
ffffffffc0202114:	00005517          	auipc	a0,0x5
ffffffffc0202118:	fac50513          	addi	a0,a0,-84 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc020211c:	8ecfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202120:	00005697          	auipc	a3,0x5
ffffffffc0202124:	2e868693          	addi	a3,a3,744 # ffffffffc0207408 <commands+0xb40>
ffffffffc0202128:	00005617          	auipc	a2,0x5
ffffffffc020212c:	bb060613          	addi	a2,a2,-1104 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202130:	21000593          	li	a1,528
ffffffffc0202134:	00005517          	auipc	a0,0x5
ffffffffc0202138:	f8c50513          	addi	a0,a0,-116 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc020213c:	8ccfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202140:	00005697          	auipc	a3,0x5
ffffffffc0202144:	2f868693          	addi	a3,a3,760 # ffffffffc0207438 <commands+0xb70>
ffffffffc0202148:	00005617          	auipc	a2,0x5
ffffffffc020214c:	b9060613          	addi	a2,a2,-1136 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202150:	20f00593          	li	a1,527
ffffffffc0202154:	00005517          	auipc	a0,0x5
ffffffffc0202158:	f6c50513          	addi	a0,a0,-148 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc020215c:	8acfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202160:	00005697          	auipc	a3,0x5
ffffffffc0202164:	2a868693          	addi	a3,a3,680 # ffffffffc0207408 <commands+0xb40>
ffffffffc0202168:	00005617          	auipc	a2,0x5
ffffffffc020216c:	b7060613          	addi	a2,a2,-1168 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202170:	20c00593          	li	a1,524
ffffffffc0202174:	00005517          	auipc	a0,0x5
ffffffffc0202178:	f4c50513          	addi	a0,a0,-180 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc020217c:	88cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202180:	00005697          	auipc	a3,0x5
ffffffffc0202184:	3e068693          	addi	a3,a3,992 # ffffffffc0207560 <commands+0xc98>
ffffffffc0202188:	00005617          	auipc	a2,0x5
ffffffffc020218c:	b5060613          	addi	a2,a2,-1200 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202190:	23100593          	li	a1,561
ffffffffc0202194:	00005517          	auipc	a0,0x5
ffffffffc0202198:	f2c50513          	addi	a0,a0,-212 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc020219c:	86cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02021a0:	00005697          	auipc	a3,0x5
ffffffffc02021a4:	38868693          	addi	a3,a3,904 # ffffffffc0207528 <commands+0xc60>
ffffffffc02021a8:	00005617          	auipc	a2,0x5
ffffffffc02021ac:	b3060613          	addi	a2,a2,-1232 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02021b0:	23000593          	li	a1,560
ffffffffc02021b4:	00005517          	auipc	a0,0x5
ffffffffc02021b8:	f0c50513          	addi	a0,a0,-244 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02021bc:	84cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02021c0:	00005697          	auipc	a3,0x5
ffffffffc02021c4:	35068693          	addi	a3,a3,848 # ffffffffc0207510 <commands+0xc48>
ffffffffc02021c8:	00005617          	auipc	a2,0x5
ffffffffc02021cc:	b1060613          	addi	a2,a2,-1264 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02021d0:	22c00593          	li	a1,556
ffffffffc02021d4:	00005517          	auipc	a0,0x5
ffffffffc02021d8:	eec50513          	addi	a0,a0,-276 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02021dc:	82cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02021e0:	00005697          	auipc	a3,0x5
ffffffffc02021e4:	29868693          	addi	a3,a3,664 # ffffffffc0207478 <commands+0xbb0>
ffffffffc02021e8:	00005617          	auipc	a2,0x5
ffffffffc02021ec:	af060613          	addi	a2,a2,-1296 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02021f0:	21a00593          	li	a1,538
ffffffffc02021f4:	00005517          	auipc	a0,0x5
ffffffffc02021f8:	ecc50513          	addi	a0,a0,-308 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02021fc:	80cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202200:	00005697          	auipc	a3,0x5
ffffffffc0202204:	0b068693          	addi	a3,a3,176 # ffffffffc02072b0 <commands+0x9e8>
ffffffffc0202208:	00005617          	auipc	a2,0x5
ffffffffc020220c:	ad060613          	addi	a2,a2,-1328 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202210:	1f400593          	li	a1,500
ffffffffc0202214:	00005517          	auipc	a0,0x5
ffffffffc0202218:	eac50513          	addi	a0,a0,-340 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc020221c:	fedfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202220:	00005617          	auipc	a2,0x5
ffffffffc0202224:	e7860613          	addi	a2,a2,-392 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0202228:	1f700593          	li	a1,503
ffffffffc020222c:	00005517          	auipc	a0,0x5
ffffffffc0202230:	e9450513          	addi	a0,a0,-364 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202234:	fd5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202238:	00005697          	auipc	a3,0x5
ffffffffc020223c:	09068693          	addi	a3,a3,144 # ffffffffc02072c8 <commands+0xa00>
ffffffffc0202240:	00005617          	auipc	a2,0x5
ffffffffc0202244:	a9860613          	addi	a2,a2,-1384 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202248:	1f500593          	li	a1,501
ffffffffc020224c:	00005517          	auipc	a0,0x5
ffffffffc0202250:	e7450513          	addi	a0,a0,-396 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202254:	fb5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202258:	00005697          	auipc	a3,0x5
ffffffffc020225c:	0e868693          	addi	a3,a3,232 # ffffffffc0207340 <commands+0xa78>
ffffffffc0202260:	00005617          	auipc	a2,0x5
ffffffffc0202264:	a7860613          	addi	a2,a2,-1416 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202268:	1fd00593          	li	a1,509
ffffffffc020226c:	00005517          	auipc	a0,0x5
ffffffffc0202270:	e5450513          	addi	a0,a0,-428 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202274:	f95fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202278:	00005697          	auipc	a3,0x5
ffffffffc020227c:	3a868693          	addi	a3,a3,936 # ffffffffc0207620 <commands+0xd58>
ffffffffc0202280:	00005617          	auipc	a2,0x5
ffffffffc0202284:	a5860613          	addi	a2,a2,-1448 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202288:	23a00593          	li	a1,570
ffffffffc020228c:	00005517          	auipc	a0,0x5
ffffffffc0202290:	e3450513          	addi	a0,a0,-460 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202294:	f75fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202298:	00005697          	auipc	a3,0x5
ffffffffc020229c:	35068693          	addi	a3,a3,848 # ffffffffc02075e8 <commands+0xd20>
ffffffffc02022a0:	00005617          	auipc	a2,0x5
ffffffffc02022a4:	a3860613          	addi	a2,a2,-1480 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02022a8:	23700593          	li	a1,567
ffffffffc02022ac:	00005517          	auipc	a0,0x5
ffffffffc02022b0:	e1450513          	addi	a0,a0,-492 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02022b4:	f55fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02022b8:	00005697          	auipc	a3,0x5
ffffffffc02022bc:	30068693          	addi	a3,a3,768 # ffffffffc02075b8 <commands+0xcf0>
ffffffffc02022c0:	00005617          	auipc	a2,0x5
ffffffffc02022c4:	a1860613          	addi	a2,a2,-1512 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02022c8:	23300593          	li	a1,563
ffffffffc02022cc:	00005517          	auipc	a0,0x5
ffffffffc02022d0:	df450513          	addi	a0,a0,-524 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02022d4:	f35fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02022d8 <copy_range>:
               bool share) {
ffffffffc02022d8:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022da:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02022de:	f486                	sd	ra,104(sp)
ffffffffc02022e0:	f0a2                	sd	s0,96(sp)
ffffffffc02022e2:	eca6                	sd	s1,88(sp)
ffffffffc02022e4:	e8ca                	sd	s2,80(sp)
ffffffffc02022e6:	e4ce                	sd	s3,72(sp)
ffffffffc02022e8:	e0d2                	sd	s4,64(sp)
ffffffffc02022ea:	fc56                	sd	s5,56(sp)
ffffffffc02022ec:	f85a                	sd	s6,48(sp)
ffffffffc02022ee:	f45e                	sd	s7,40(sp)
ffffffffc02022f0:	f062                	sd	s8,32(sp)
ffffffffc02022f2:	ec66                	sd	s9,24(sp)
ffffffffc02022f4:	e86a                	sd	s10,16(sp)
ffffffffc02022f6:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022f8:	17d2                	slli	a5,a5,0x34
ffffffffc02022fa:	1e079763          	bnez	a5,ffffffffc02024e8 <copy_range+0x210>
    assert(USER_ACCESS(start, end));
ffffffffc02022fe:	002007b7          	lui	a5,0x200
ffffffffc0202302:	8432                	mv	s0,a2
ffffffffc0202304:	16f66a63          	bltu	a2,a5,ffffffffc0202478 <copy_range+0x1a0>
ffffffffc0202308:	8936                	mv	s2,a3
ffffffffc020230a:	16d67763          	bgeu	a2,a3,ffffffffc0202478 <copy_range+0x1a0>
ffffffffc020230e:	4785                	li	a5,1
ffffffffc0202310:	07fe                	slli	a5,a5,0x1f
ffffffffc0202312:	16d7e363          	bltu	a5,a3,ffffffffc0202478 <copy_range+0x1a0>
ffffffffc0202316:	5b7d                	li	s6,-1
ffffffffc0202318:	8aaa                	mv	s5,a0
ffffffffc020231a:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc020231c:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020231e:	000b0c97          	auipc	s9,0xb0
ffffffffc0202322:	502c8c93          	addi	s9,s9,1282 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202326:	000b0c17          	auipc	s8,0xb0
ffffffffc020232a:	502c0c13          	addi	s8,s8,1282 # ffffffffc02b2828 <pages>
    return page - pages + nbase;
ffffffffc020232e:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc0202332:	00cb5b13          	srli	s6,s6,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0202336:	4601                	li	a2,0
ffffffffc0202338:	85a2                	mv	a1,s0
ffffffffc020233a:	854e                	mv	a0,s3
ffffffffc020233c:	c73fe0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc0202340:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202342:	c175                	beqz	a0,ffffffffc0202426 <copy_range+0x14e>
        if (*ptep & PTE_V) {
ffffffffc0202344:	611c                	ld	a5,0(a0)
ffffffffc0202346:	8b85                	andi	a5,a5,1
ffffffffc0202348:	e785                	bnez	a5,ffffffffc0202370 <copy_range+0x98>
        start += PGSIZE;
ffffffffc020234a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020234c:	ff2465e3          	bltu	s0,s2,ffffffffc0202336 <copy_range+0x5e>
    return 0;
ffffffffc0202350:	4501                	li	a0,0
}
ffffffffc0202352:	70a6                	ld	ra,104(sp)
ffffffffc0202354:	7406                	ld	s0,96(sp)
ffffffffc0202356:	64e6                	ld	s1,88(sp)
ffffffffc0202358:	6946                	ld	s2,80(sp)
ffffffffc020235a:	69a6                	ld	s3,72(sp)
ffffffffc020235c:	6a06                	ld	s4,64(sp)
ffffffffc020235e:	7ae2                	ld	s5,56(sp)
ffffffffc0202360:	7b42                	ld	s6,48(sp)
ffffffffc0202362:	7ba2                	ld	s7,40(sp)
ffffffffc0202364:	7c02                	ld	s8,32(sp)
ffffffffc0202366:	6ce2                	ld	s9,24(sp)
ffffffffc0202368:	6d42                	ld	s10,16(sp)
ffffffffc020236a:	6da2                	ld	s11,8(sp)
ffffffffc020236c:	6165                	addi	sp,sp,112
ffffffffc020236e:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0202370:	4605                	li	a2,1
ffffffffc0202372:	85a2                	mv	a1,s0
ffffffffc0202374:	8556                	mv	a0,s5
ffffffffc0202376:	c39fe0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc020237a:	c161                	beqz	a0,ffffffffc020243a <copy_range+0x162>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc020237c:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc020237e:	0017f713          	andi	a4,a5,1
ffffffffc0202382:	01f7f493          	andi	s1,a5,31
ffffffffc0202386:	14070563          	beqz	a4,ffffffffc02024d0 <copy_range+0x1f8>
    if (PPN(pa) >= npage) {
ffffffffc020238a:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020238e:	078a                	slli	a5,a5,0x2
ffffffffc0202390:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202394:	12d77263          	bgeu	a4,a3,ffffffffc02024b8 <copy_range+0x1e0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202398:	000c3783          	ld	a5,0(s8)
ffffffffc020239c:	fff806b7          	lui	a3,0xfff80
ffffffffc02023a0:	9736                	add	a4,a4,a3
ffffffffc02023a2:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc02023a4:	4505                	li	a0,1
ffffffffc02023a6:	00e78db3          	add	s11,a5,a4
ffffffffc02023aa:	af9fe0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc02023ae:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02023b0:	0a0d8463          	beqz	s11,ffffffffc0202458 <copy_range+0x180>
            assert(npage != NULL);
ffffffffc02023b4:	c175                	beqz	a0,ffffffffc0202498 <copy_range+0x1c0>
    return page - pages + nbase;
ffffffffc02023b6:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc02023ba:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02023be:	40ed86b3          	sub	a3,s11,a4
ffffffffc02023c2:	8699                	srai	a3,a3,0x6
ffffffffc02023c4:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc02023c6:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023ca:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023cc:	06c7fa63          	bgeu	a5,a2,ffffffffc0202440 <copy_range+0x168>
    return page - pages + nbase;
ffffffffc02023d0:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02023d4:	000b0717          	auipc	a4,0xb0
ffffffffc02023d8:	46470713          	addi	a4,a4,1124 # ffffffffc02b2838 <va_pa_offset>
ffffffffc02023dc:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02023de:	8799                	srai	a5,a5,0x6
ffffffffc02023e0:	97de                	add	a5,a5,s7
    return KADDR(page2pa(page));
ffffffffc02023e2:	0167f733          	and	a4,a5,s6
ffffffffc02023e6:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02023ea:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02023ec:	04c77963          	bgeu	a4,a2,ffffffffc020243e <copy_range+0x166>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE); 
ffffffffc02023f0:	6605                	lui	a2,0x1
ffffffffc02023f2:	953e                	add	a0,a0,a5
ffffffffc02023f4:	60f030ef          	jal	ra,ffffffffc0206202 <memcpy>
            ret = page_insert(to, npage, start, perm); 
ffffffffc02023f8:	86a6                	mv	a3,s1
ffffffffc02023fa:	8622                	mv	a2,s0
ffffffffc02023fc:	85ea                	mv	a1,s10
ffffffffc02023fe:	8556                	mv	a0,s5
ffffffffc0202400:	a48ff0ef          	jal	ra,ffffffffc0201648 <page_insert>
            assert(ret == 0);
ffffffffc0202404:	d139                	beqz	a0,ffffffffc020234a <copy_range+0x72>
ffffffffc0202406:	00005697          	auipc	a3,0x5
ffffffffc020240a:	28268693          	addi	a3,a3,642 # ffffffffc0207688 <commands+0xdc0>
ffffffffc020240e:	00005617          	auipc	a2,0x5
ffffffffc0202412:	8ca60613          	addi	a2,a2,-1846 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202416:	18c00593          	li	a1,396
ffffffffc020241a:	00005517          	auipc	a0,0x5
ffffffffc020241e:	ca650513          	addi	a0,a0,-858 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202422:	de7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202426:	00200637          	lui	a2,0x200
ffffffffc020242a:	9432                	add	s0,s0,a2
ffffffffc020242c:	ffe00637          	lui	a2,0xffe00
ffffffffc0202430:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0202432:	dc19                	beqz	s0,ffffffffc0202350 <copy_range+0x78>
ffffffffc0202434:	f12461e3          	bltu	s0,s2,ffffffffc0202336 <copy_range+0x5e>
ffffffffc0202438:	bf21                	j	ffffffffc0202350 <copy_range+0x78>
                return -E_NO_MEM;
ffffffffc020243a:	5571                	li	a0,-4
ffffffffc020243c:	bf19                	j	ffffffffc0202352 <copy_range+0x7a>
ffffffffc020243e:	86be                	mv	a3,a5
ffffffffc0202440:	00005617          	auipc	a2,0x5
ffffffffc0202444:	c5860613          	addi	a2,a2,-936 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0202448:	06900593          	li	a1,105
ffffffffc020244c:	00005517          	auipc	a0,0x5
ffffffffc0202450:	c1450513          	addi	a0,a0,-1004 # ffffffffc0207060 <commands+0x798>
ffffffffc0202454:	db5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(page != NULL);
ffffffffc0202458:	00005697          	auipc	a3,0x5
ffffffffc020245c:	21068693          	addi	a3,a3,528 # ffffffffc0207668 <commands+0xda0>
ffffffffc0202460:	00005617          	auipc	a2,0x5
ffffffffc0202464:	87860613          	addi	a2,a2,-1928 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202468:	17200593          	li	a1,370
ffffffffc020246c:	00005517          	auipc	a0,0x5
ffffffffc0202470:	c5450513          	addi	a0,a0,-940 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202474:	d95fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202478:	00005697          	auipc	a3,0x5
ffffffffc020247c:	c8868693          	addi	a3,a3,-888 # ffffffffc0207100 <commands+0x838>
ffffffffc0202480:	00005617          	auipc	a2,0x5
ffffffffc0202484:	85860613          	addi	a2,a2,-1960 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202488:	15e00593          	li	a1,350
ffffffffc020248c:	00005517          	auipc	a0,0x5
ffffffffc0202490:	c3450513          	addi	a0,a0,-972 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202494:	d75fd0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(npage != NULL);
ffffffffc0202498:	00005697          	auipc	a3,0x5
ffffffffc020249c:	1e068693          	addi	a3,a3,480 # ffffffffc0207678 <commands+0xdb0>
ffffffffc02024a0:	00005617          	auipc	a2,0x5
ffffffffc02024a4:	83860613          	addi	a2,a2,-1992 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02024a8:	17300593          	li	a1,371
ffffffffc02024ac:	00005517          	auipc	a0,0x5
ffffffffc02024b0:	c1450513          	addi	a0,a0,-1004 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02024b4:	d55fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024b8:	00005617          	auipc	a2,0x5
ffffffffc02024bc:	b8860613          	addi	a2,a2,-1144 # ffffffffc0207040 <commands+0x778>
ffffffffc02024c0:	06200593          	li	a1,98
ffffffffc02024c4:	00005517          	auipc	a0,0x5
ffffffffc02024c8:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0207060 <commands+0x798>
ffffffffc02024cc:	d3dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02024d0:	00005617          	auipc	a2,0x5
ffffffffc02024d4:	ba060613          	addi	a2,a2,-1120 # ffffffffc0207070 <commands+0x7a8>
ffffffffc02024d8:	07400593          	li	a1,116
ffffffffc02024dc:	00005517          	auipc	a0,0x5
ffffffffc02024e0:	b8450513          	addi	a0,a0,-1148 # ffffffffc0207060 <commands+0x798>
ffffffffc02024e4:	d25fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02024e8:	00005697          	auipc	a3,0x5
ffffffffc02024ec:	be868693          	addi	a3,a3,-1048 # ffffffffc02070d0 <commands+0x808>
ffffffffc02024f0:	00004617          	auipc	a2,0x4
ffffffffc02024f4:	7e860613          	addi	a2,a2,2024 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02024f8:	15d00593          	li	a1,349
ffffffffc02024fc:	00005517          	auipc	a0,0x5
ffffffffc0202500:	bc450513          	addi	a0,a0,-1084 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc0202504:	d05fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202508 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202508:	12058073          	sfence.vma	a1
}
ffffffffc020250c:	8082                	ret

ffffffffc020250e <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020250e:	7179                	addi	sp,sp,-48
ffffffffc0202510:	e84a                	sd	s2,16(sp)
ffffffffc0202512:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202514:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202516:	f022                	sd	s0,32(sp)
ffffffffc0202518:	ec26                	sd	s1,24(sp)
ffffffffc020251a:	e44e                	sd	s3,8(sp)
ffffffffc020251c:	f406                	sd	ra,40(sp)
ffffffffc020251e:	84ae                	mv	s1,a1
ffffffffc0202520:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202522:	981fe0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0202526:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202528:	cd05                	beqz	a0,ffffffffc0202560 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020252a:	85aa                	mv	a1,a0
ffffffffc020252c:	86ce                	mv	a3,s3
ffffffffc020252e:	8626                	mv	a2,s1
ffffffffc0202530:	854a                	mv	a0,s2
ffffffffc0202532:	916ff0ef          	jal	ra,ffffffffc0201648 <page_insert>
ffffffffc0202536:	ed0d                	bnez	a0,ffffffffc0202570 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0202538:	000b0797          	auipc	a5,0xb0
ffffffffc020253c:	3307a783          	lw	a5,816(a5) # ffffffffc02b2868 <swap_init_ok>
ffffffffc0202540:	c385                	beqz	a5,ffffffffc0202560 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc0202542:	000b0517          	auipc	a0,0xb0
ffffffffc0202546:	2fe53503          	ld	a0,766(a0) # ffffffffc02b2840 <check_mm_struct>
ffffffffc020254a:	c919                	beqz	a0,ffffffffc0202560 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020254c:	4681                	li	a3,0
ffffffffc020254e:	8622                	mv	a2,s0
ffffffffc0202550:	85a6                	mv	a1,s1
ffffffffc0202552:	21f010ef          	jal	ra,ffffffffc0203f70 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0202556:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0202558:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020255a:	4785                	li	a5,1
ffffffffc020255c:	04f71663          	bne	a4,a5,ffffffffc02025a8 <pgdir_alloc_page+0x9a>
}
ffffffffc0202560:	70a2                	ld	ra,40(sp)
ffffffffc0202562:	8522                	mv	a0,s0
ffffffffc0202564:	7402                	ld	s0,32(sp)
ffffffffc0202566:	64e2                	ld	s1,24(sp)
ffffffffc0202568:	6942                	ld	s2,16(sp)
ffffffffc020256a:	69a2                	ld	s3,8(sp)
ffffffffc020256c:	6145                	addi	sp,sp,48
ffffffffc020256e:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202570:	100027f3          	csrr	a5,sstatus
ffffffffc0202574:	8b89                	andi	a5,a5,2
ffffffffc0202576:	eb99                	bnez	a5,ffffffffc020258c <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0202578:	000b0797          	auipc	a5,0xb0
ffffffffc020257c:	2b87b783          	ld	a5,696(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0202580:	739c                	ld	a5,32(a5)
ffffffffc0202582:	8522                	mv	a0,s0
ffffffffc0202584:	4585                	li	a1,1
ffffffffc0202586:	9782                	jalr	a5
            return NULL;
ffffffffc0202588:	4401                	li	s0,0
ffffffffc020258a:	bfd9                	j	ffffffffc0202560 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc020258c:	8bcfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202590:	000b0797          	auipc	a5,0xb0
ffffffffc0202594:	2a07b783          	ld	a5,672(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0202598:	739c                	ld	a5,32(a5)
ffffffffc020259a:	8522                	mv	a0,s0
ffffffffc020259c:	4585                	li	a1,1
ffffffffc020259e:	9782                	jalr	a5
            return NULL;
ffffffffc02025a0:	4401                	li	s0,0
        intr_enable();
ffffffffc02025a2:	8a0fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02025a6:	bf6d                	j	ffffffffc0202560 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc02025a8:	00005697          	auipc	a3,0x5
ffffffffc02025ac:	0f068693          	addi	a3,a3,240 # ffffffffc0207698 <commands+0xdd0>
ffffffffc02025b0:	00004617          	auipc	a2,0x4
ffffffffc02025b4:	72860613          	addi	a2,a2,1832 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02025b8:	1cb00593          	li	a1,459
ffffffffc02025bc:	00005517          	auipc	a0,0x5
ffffffffc02025c0:	b0450513          	addi	a0,a0,-1276 # ffffffffc02070c0 <commands+0x7f8>
ffffffffc02025c4:	c45fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02025c8 <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02025c8:	000ac797          	auipc	a5,0xac
ffffffffc02025cc:	16878793          	addi	a5,a5,360 # ffffffffc02ae730 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02025d0:	f51c                	sd	a5,40(a0)
ffffffffc02025d2:	e79c                	sd	a5,8(a5)
ffffffffc02025d4:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02025d6:	4501                	li	a0,0
ffffffffc02025d8:	8082                	ret

ffffffffc02025da <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02025da:	4501                	li	a0,0
ffffffffc02025dc:	8082                	ret

ffffffffc02025de <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02025de:	4501                	li	a0,0
ffffffffc02025e0:	8082                	ret

ffffffffc02025e2 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02025e2:	4501                	li	a0,0
ffffffffc02025e4:	8082                	ret

ffffffffc02025e6 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02025e6:	711d                	addi	sp,sp,-96
ffffffffc02025e8:	fc4e                	sd	s3,56(sp)
ffffffffc02025ea:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02025ec:	00005517          	auipc	a0,0x5
ffffffffc02025f0:	0c450513          	addi	a0,a0,196 # ffffffffc02076b0 <commands+0xde8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02025f4:	698d                	lui	s3,0x3
ffffffffc02025f6:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02025f8:	e0ca                	sd	s2,64(sp)
ffffffffc02025fa:	ec86                	sd	ra,88(sp)
ffffffffc02025fc:	e8a2                	sd	s0,80(sp)
ffffffffc02025fe:	e4a6                	sd	s1,72(sp)
ffffffffc0202600:	f456                	sd	s5,40(sp)
ffffffffc0202602:	f05a                	sd	s6,32(sp)
ffffffffc0202604:	ec5e                	sd	s7,24(sp)
ffffffffc0202606:	e862                	sd	s8,16(sp)
ffffffffc0202608:	e466                	sd	s9,8(sp)
ffffffffc020260a:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020260c:	ac1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202610:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb8>
    assert(pgfault_num==4);
ffffffffc0202614:	000b0917          	auipc	s2,0xb0
ffffffffc0202618:	23492903          	lw	s2,564(s2) # ffffffffc02b2848 <pgfault_num>
ffffffffc020261c:	4791                	li	a5,4
ffffffffc020261e:	14f91e63          	bne	s2,a5,ffffffffc020277a <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202622:	00005517          	auipc	a0,0x5
ffffffffc0202626:	0de50513          	addi	a0,a0,222 # ffffffffc0207700 <commands+0xe38>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020262a:	6a85                	lui	s5,0x1
ffffffffc020262c:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020262e:	a9ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0202632:	000b0417          	auipc	s0,0xb0
ffffffffc0202636:	21640413          	addi	s0,s0,534 # ffffffffc02b2848 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020263a:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
    assert(pgfault_num==4);
ffffffffc020263e:	4004                	lw	s1,0(s0)
ffffffffc0202640:	2481                	sext.w	s1,s1
ffffffffc0202642:	2b249c63          	bne	s1,s2,ffffffffc02028fa <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202646:	00005517          	auipc	a0,0x5
ffffffffc020264a:	0e250513          	addi	a0,a0,226 # ffffffffc0207728 <commands+0xe60>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020264e:	6b91                	lui	s7,0x4
ffffffffc0202650:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202652:	a7bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202656:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb8>
    assert(pgfault_num==4);
ffffffffc020265a:	00042903          	lw	s2,0(s0)
ffffffffc020265e:	2901                	sext.w	s2,s2
ffffffffc0202660:	26991d63          	bne	s2,s1,ffffffffc02028da <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202664:	00005517          	auipc	a0,0x5
ffffffffc0202668:	0ec50513          	addi	a0,a0,236 # ffffffffc0207750 <commands+0xe88>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020266c:	6c89                	lui	s9,0x2
ffffffffc020266e:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202670:	a5dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202674:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb8>
    assert(pgfault_num==4);
ffffffffc0202678:	401c                	lw	a5,0(s0)
ffffffffc020267a:	2781                	sext.w	a5,a5
ffffffffc020267c:	23279f63          	bne	a5,s2,ffffffffc02028ba <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202680:	00005517          	auipc	a0,0x5
ffffffffc0202684:	0f850513          	addi	a0,a0,248 # ffffffffc0207778 <commands+0xeb0>
ffffffffc0202688:	a45fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020268c:	6795                	lui	a5,0x5
ffffffffc020268e:	4739                	li	a4,14
ffffffffc0202690:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb8>
    assert(pgfault_num==5);
ffffffffc0202694:	4004                	lw	s1,0(s0)
ffffffffc0202696:	4795                	li	a5,5
ffffffffc0202698:	2481                	sext.w	s1,s1
ffffffffc020269a:	20f49063          	bne	s1,a5,ffffffffc020289a <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020269e:	00005517          	auipc	a0,0x5
ffffffffc02026a2:	0b250513          	addi	a0,a0,178 # ffffffffc0207750 <commands+0xe88>
ffffffffc02026a6:	a27fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02026aa:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc02026ae:	401c                	lw	a5,0(s0)
ffffffffc02026b0:	2781                	sext.w	a5,a5
ffffffffc02026b2:	1c979463          	bne	a5,s1,ffffffffc020287a <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02026b6:	00005517          	auipc	a0,0x5
ffffffffc02026ba:	04a50513          	addi	a0,a0,74 # ffffffffc0207700 <commands+0xe38>
ffffffffc02026be:	a0ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02026c2:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02026c6:	401c                	lw	a5,0(s0)
ffffffffc02026c8:	4719                	li	a4,6
ffffffffc02026ca:	2781                	sext.w	a5,a5
ffffffffc02026cc:	18e79763          	bne	a5,a4,ffffffffc020285a <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02026d0:	00005517          	auipc	a0,0x5
ffffffffc02026d4:	08050513          	addi	a0,a0,128 # ffffffffc0207750 <commands+0xe88>
ffffffffc02026d8:	9f5fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02026dc:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc02026e0:	401c                	lw	a5,0(s0)
ffffffffc02026e2:	471d                	li	a4,7
ffffffffc02026e4:	2781                	sext.w	a5,a5
ffffffffc02026e6:	14e79a63          	bne	a5,a4,ffffffffc020283a <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02026ea:	00005517          	auipc	a0,0x5
ffffffffc02026ee:	fc650513          	addi	a0,a0,-58 # ffffffffc02076b0 <commands+0xde8>
ffffffffc02026f2:	9dbfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026f6:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02026fa:	401c                	lw	a5,0(s0)
ffffffffc02026fc:	4721                	li	a4,8
ffffffffc02026fe:	2781                	sext.w	a5,a5
ffffffffc0202700:	10e79d63          	bne	a5,a4,ffffffffc020281a <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202704:	00005517          	auipc	a0,0x5
ffffffffc0202708:	02450513          	addi	a0,a0,36 # ffffffffc0207728 <commands+0xe60>
ffffffffc020270c:	9c1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202710:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0202714:	401c                	lw	a5,0(s0)
ffffffffc0202716:	4725                	li	a4,9
ffffffffc0202718:	2781                	sext.w	a5,a5
ffffffffc020271a:	0ee79063          	bne	a5,a4,ffffffffc02027fa <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020271e:	00005517          	auipc	a0,0x5
ffffffffc0202722:	05a50513          	addi	a0,a0,90 # ffffffffc0207778 <commands+0xeb0>
ffffffffc0202726:	9a7fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020272a:	6795                	lui	a5,0x5
ffffffffc020272c:	4739                	li	a4,14
ffffffffc020272e:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb8>
    assert(pgfault_num==10);
ffffffffc0202732:	4004                	lw	s1,0(s0)
ffffffffc0202734:	47a9                	li	a5,10
ffffffffc0202736:	2481                	sext.w	s1,s1
ffffffffc0202738:	0af49163          	bne	s1,a5,ffffffffc02027da <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020273c:	00005517          	auipc	a0,0x5
ffffffffc0202740:	fc450513          	addi	a0,a0,-60 # ffffffffc0207700 <commands+0xe38>
ffffffffc0202744:	989fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202748:	6785                	lui	a5,0x1
ffffffffc020274a:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc020274e:	06979663          	bne	a5,s1,ffffffffc02027ba <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0202752:	401c                	lw	a5,0(s0)
ffffffffc0202754:	472d                	li	a4,11
ffffffffc0202756:	2781                	sext.w	a5,a5
ffffffffc0202758:	04e79163          	bne	a5,a4,ffffffffc020279a <_fifo_check_swap+0x1b4>
}
ffffffffc020275c:	60e6                	ld	ra,88(sp)
ffffffffc020275e:	6446                	ld	s0,80(sp)
ffffffffc0202760:	64a6                	ld	s1,72(sp)
ffffffffc0202762:	6906                	ld	s2,64(sp)
ffffffffc0202764:	79e2                	ld	s3,56(sp)
ffffffffc0202766:	7a42                	ld	s4,48(sp)
ffffffffc0202768:	7aa2                	ld	s5,40(sp)
ffffffffc020276a:	7b02                	ld	s6,32(sp)
ffffffffc020276c:	6be2                	ld	s7,24(sp)
ffffffffc020276e:	6c42                	ld	s8,16(sp)
ffffffffc0202770:	6ca2                	ld	s9,8(sp)
ffffffffc0202772:	6d02                	ld	s10,0(sp)
ffffffffc0202774:	4501                	li	a0,0
ffffffffc0202776:	6125                	addi	sp,sp,96
ffffffffc0202778:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020277a:	00005697          	auipc	a3,0x5
ffffffffc020277e:	f5e68693          	addi	a3,a3,-162 # ffffffffc02076d8 <commands+0xe10>
ffffffffc0202782:	00004617          	auipc	a2,0x4
ffffffffc0202786:	55660613          	addi	a2,a2,1366 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020278a:	05100593          	li	a1,81
ffffffffc020278e:	00005517          	auipc	a0,0x5
ffffffffc0202792:	f5a50513          	addi	a0,a0,-166 # ffffffffc02076e8 <commands+0xe20>
ffffffffc0202796:	a73fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc020279a:	00005697          	auipc	a3,0x5
ffffffffc020279e:	08e68693          	addi	a3,a3,142 # ffffffffc0207828 <commands+0xf60>
ffffffffc02027a2:	00004617          	auipc	a2,0x4
ffffffffc02027a6:	53660613          	addi	a2,a2,1334 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02027aa:	07300593          	li	a1,115
ffffffffc02027ae:	00005517          	auipc	a0,0x5
ffffffffc02027b2:	f3a50513          	addi	a0,a0,-198 # ffffffffc02076e8 <commands+0xe20>
ffffffffc02027b6:	a53fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02027ba:	00005697          	auipc	a3,0x5
ffffffffc02027be:	04668693          	addi	a3,a3,70 # ffffffffc0207800 <commands+0xf38>
ffffffffc02027c2:	00004617          	auipc	a2,0x4
ffffffffc02027c6:	51660613          	addi	a2,a2,1302 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02027ca:	07100593          	li	a1,113
ffffffffc02027ce:	00005517          	auipc	a0,0x5
ffffffffc02027d2:	f1a50513          	addi	a0,a0,-230 # ffffffffc02076e8 <commands+0xe20>
ffffffffc02027d6:	a33fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc02027da:	00005697          	auipc	a3,0x5
ffffffffc02027de:	01668693          	addi	a3,a3,22 # ffffffffc02077f0 <commands+0xf28>
ffffffffc02027e2:	00004617          	auipc	a2,0x4
ffffffffc02027e6:	4f660613          	addi	a2,a2,1270 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02027ea:	06f00593          	li	a1,111
ffffffffc02027ee:	00005517          	auipc	a0,0x5
ffffffffc02027f2:	efa50513          	addi	a0,a0,-262 # ffffffffc02076e8 <commands+0xe20>
ffffffffc02027f6:	a13fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc02027fa:	00005697          	auipc	a3,0x5
ffffffffc02027fe:	fe668693          	addi	a3,a3,-26 # ffffffffc02077e0 <commands+0xf18>
ffffffffc0202802:	00004617          	auipc	a2,0x4
ffffffffc0202806:	4d660613          	addi	a2,a2,1238 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020280a:	06c00593          	li	a1,108
ffffffffc020280e:	00005517          	auipc	a0,0x5
ffffffffc0202812:	eda50513          	addi	a0,a0,-294 # ffffffffc02076e8 <commands+0xe20>
ffffffffc0202816:	9f3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc020281a:	00005697          	auipc	a3,0x5
ffffffffc020281e:	fb668693          	addi	a3,a3,-74 # ffffffffc02077d0 <commands+0xf08>
ffffffffc0202822:	00004617          	auipc	a2,0x4
ffffffffc0202826:	4b660613          	addi	a2,a2,1206 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020282a:	06900593          	li	a1,105
ffffffffc020282e:	00005517          	auipc	a0,0x5
ffffffffc0202832:	eba50513          	addi	a0,a0,-326 # ffffffffc02076e8 <commands+0xe20>
ffffffffc0202836:	9d3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc020283a:	00005697          	auipc	a3,0x5
ffffffffc020283e:	f8668693          	addi	a3,a3,-122 # ffffffffc02077c0 <commands+0xef8>
ffffffffc0202842:	00004617          	auipc	a2,0x4
ffffffffc0202846:	49660613          	addi	a2,a2,1174 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020284a:	06600593          	li	a1,102
ffffffffc020284e:	00005517          	auipc	a0,0x5
ffffffffc0202852:	e9a50513          	addi	a0,a0,-358 # ffffffffc02076e8 <commands+0xe20>
ffffffffc0202856:	9b3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc020285a:	00005697          	auipc	a3,0x5
ffffffffc020285e:	f5668693          	addi	a3,a3,-170 # ffffffffc02077b0 <commands+0xee8>
ffffffffc0202862:	00004617          	auipc	a2,0x4
ffffffffc0202866:	47660613          	addi	a2,a2,1142 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020286a:	06300593          	li	a1,99
ffffffffc020286e:	00005517          	auipc	a0,0x5
ffffffffc0202872:	e7a50513          	addi	a0,a0,-390 # ffffffffc02076e8 <commands+0xe20>
ffffffffc0202876:	993fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc020287a:	00005697          	auipc	a3,0x5
ffffffffc020287e:	f2668693          	addi	a3,a3,-218 # ffffffffc02077a0 <commands+0xed8>
ffffffffc0202882:	00004617          	auipc	a2,0x4
ffffffffc0202886:	45660613          	addi	a2,a2,1110 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020288a:	06000593          	li	a1,96
ffffffffc020288e:	00005517          	auipc	a0,0x5
ffffffffc0202892:	e5a50513          	addi	a0,a0,-422 # ffffffffc02076e8 <commands+0xe20>
ffffffffc0202896:	973fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc020289a:	00005697          	auipc	a3,0x5
ffffffffc020289e:	f0668693          	addi	a3,a3,-250 # ffffffffc02077a0 <commands+0xed8>
ffffffffc02028a2:	00004617          	auipc	a2,0x4
ffffffffc02028a6:	43660613          	addi	a2,a2,1078 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02028aa:	05d00593          	li	a1,93
ffffffffc02028ae:	00005517          	auipc	a0,0x5
ffffffffc02028b2:	e3a50513          	addi	a0,a0,-454 # ffffffffc02076e8 <commands+0xe20>
ffffffffc02028b6:	953fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc02028ba:	00005697          	auipc	a3,0x5
ffffffffc02028be:	e1e68693          	addi	a3,a3,-482 # ffffffffc02076d8 <commands+0xe10>
ffffffffc02028c2:	00004617          	auipc	a2,0x4
ffffffffc02028c6:	41660613          	addi	a2,a2,1046 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02028ca:	05a00593          	li	a1,90
ffffffffc02028ce:	00005517          	auipc	a0,0x5
ffffffffc02028d2:	e1a50513          	addi	a0,a0,-486 # ffffffffc02076e8 <commands+0xe20>
ffffffffc02028d6:	933fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc02028da:	00005697          	auipc	a3,0x5
ffffffffc02028de:	dfe68693          	addi	a3,a3,-514 # ffffffffc02076d8 <commands+0xe10>
ffffffffc02028e2:	00004617          	auipc	a2,0x4
ffffffffc02028e6:	3f660613          	addi	a2,a2,1014 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02028ea:	05700593          	li	a1,87
ffffffffc02028ee:	00005517          	auipc	a0,0x5
ffffffffc02028f2:	dfa50513          	addi	a0,a0,-518 # ffffffffc02076e8 <commands+0xe20>
ffffffffc02028f6:	913fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc02028fa:	00005697          	auipc	a3,0x5
ffffffffc02028fe:	dde68693          	addi	a3,a3,-546 # ffffffffc02076d8 <commands+0xe10>
ffffffffc0202902:	00004617          	auipc	a2,0x4
ffffffffc0202906:	3d660613          	addi	a2,a2,982 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020290a:	05400593          	li	a1,84
ffffffffc020290e:	00005517          	auipc	a0,0x5
ffffffffc0202912:	dda50513          	addi	a0,a0,-550 # ffffffffc02076e8 <commands+0xe20>
ffffffffc0202916:	8f3fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020291a <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020291a:	751c                	ld	a5,40(a0)
{
ffffffffc020291c:	1141                	addi	sp,sp,-16
ffffffffc020291e:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0202920:	cf91                	beqz	a5,ffffffffc020293c <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0202922:	ee0d                	bnez	a2,ffffffffc020295c <_fifo_swap_out_victim+0x42>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0202924:	679c                	ld	a5,8(a5)
}
ffffffffc0202926:	60a2                	ld	ra,8(sp)
ffffffffc0202928:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020292a:	6394                	ld	a3,0(a5)
ffffffffc020292c:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc020292e:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0202932:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0202934:	e314                	sd	a3,0(a4)
ffffffffc0202936:	e19c                	sd	a5,0(a1)
}
ffffffffc0202938:	0141                	addi	sp,sp,16
ffffffffc020293a:	8082                	ret
         assert(head != NULL);
ffffffffc020293c:	00005697          	auipc	a3,0x5
ffffffffc0202940:	efc68693          	addi	a3,a3,-260 # ffffffffc0207838 <commands+0xf70>
ffffffffc0202944:	00004617          	auipc	a2,0x4
ffffffffc0202948:	39460613          	addi	a2,a2,916 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020294c:	04100593          	li	a1,65
ffffffffc0202950:	00005517          	auipc	a0,0x5
ffffffffc0202954:	d9850513          	addi	a0,a0,-616 # ffffffffc02076e8 <commands+0xe20>
ffffffffc0202958:	8b1fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(in_tick==0);
ffffffffc020295c:	00005697          	auipc	a3,0x5
ffffffffc0202960:	eec68693          	addi	a3,a3,-276 # ffffffffc0207848 <commands+0xf80>
ffffffffc0202964:	00004617          	auipc	a2,0x4
ffffffffc0202968:	37460613          	addi	a2,a2,884 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020296c:	04200593          	li	a1,66
ffffffffc0202970:	00005517          	auipc	a0,0x5
ffffffffc0202974:	d7850513          	addi	a0,a0,-648 # ffffffffc02076e8 <commands+0xe20>
ffffffffc0202978:	891fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020297c <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020297c:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020297e:	cb91                	beqz	a5,ffffffffc0202992 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202980:	6394                	ld	a3,0(a5)
ffffffffc0202982:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0202986:	e398                	sd	a4,0(a5)
ffffffffc0202988:	e698                	sd	a4,8(a3)
}
ffffffffc020298a:	4501                	li	a0,0
    elm->next = next;
ffffffffc020298c:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020298e:	f614                	sd	a3,40(a2)
ffffffffc0202990:	8082                	ret
{
ffffffffc0202992:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202994:	00005697          	auipc	a3,0x5
ffffffffc0202998:	ec468693          	addi	a3,a3,-316 # ffffffffc0207858 <commands+0xf90>
ffffffffc020299c:	00004617          	auipc	a2,0x4
ffffffffc02029a0:	33c60613          	addi	a2,a2,828 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02029a4:	03200593          	li	a1,50
ffffffffc02029a8:	00005517          	auipc	a0,0x5
ffffffffc02029ac:	d4050513          	addi	a0,a0,-704 # ffffffffc02076e8 <commands+0xe20>
{
ffffffffc02029b0:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02029b2:	857fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02029b6 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02029b6:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02029b8:	00005697          	auipc	a3,0x5
ffffffffc02029bc:	ed868693          	addi	a3,a3,-296 # ffffffffc0207890 <commands+0xfc8>
ffffffffc02029c0:	00004617          	auipc	a2,0x4
ffffffffc02029c4:	31860613          	addi	a2,a2,792 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02029c8:	06d00593          	li	a1,109
ffffffffc02029cc:	00005517          	auipc	a0,0x5
ffffffffc02029d0:	ee450513          	addi	a0,a0,-284 # ffffffffc02078b0 <commands+0xfe8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02029d4:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02029d6:	833fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02029da <mm_create>:
mm_create(void) {
ffffffffc02029da:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02029dc:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02029e0:	e022                	sd	s0,0(sp)
ffffffffc02029e2:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02029e4:	475000ef          	jal	ra,ffffffffc0203658 <kmalloc>
ffffffffc02029e8:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02029ea:	c505                	beqz	a0,ffffffffc0202a12 <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc02029ec:	e408                	sd	a0,8(s0)
ffffffffc02029ee:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02029f0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02029f4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02029f8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02029fc:	000b0797          	auipc	a5,0xb0
ffffffffc0202a00:	e6c7a783          	lw	a5,-404(a5) # ffffffffc02b2868 <swap_init_ok>
ffffffffc0202a04:	ef81                	bnez	a5,ffffffffc0202a1c <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0202a06:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0202a0a:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0202a0e:	02043c23          	sd	zero,56(s0)
}
ffffffffc0202a12:	60a2                	ld	ra,8(sp)
ffffffffc0202a14:	8522                	mv	a0,s0
ffffffffc0202a16:	6402                	ld	s0,0(sp)
ffffffffc0202a18:	0141                	addi	sp,sp,16
ffffffffc0202a1a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202a1c:	548010ef          	jal	ra,ffffffffc0203f64 <swap_init_mm>
ffffffffc0202a20:	b7ed                	j	ffffffffc0202a0a <mm_create+0x30>

ffffffffc0202a22 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0202a22:	1101                	addi	sp,sp,-32
ffffffffc0202a24:	e04a                	sd	s2,0(sp)
ffffffffc0202a26:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202a28:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0202a2c:	e822                	sd	s0,16(sp)
ffffffffc0202a2e:	e426                	sd	s1,8(sp)
ffffffffc0202a30:	ec06                	sd	ra,24(sp)
ffffffffc0202a32:	84ae                	mv	s1,a1
ffffffffc0202a34:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202a36:	423000ef          	jal	ra,ffffffffc0203658 <kmalloc>
    if (vma != NULL) {
ffffffffc0202a3a:	c509                	beqz	a0,ffffffffc0202a44 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0202a3c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202a40:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202a42:	cd00                	sw	s0,24(a0)
}
ffffffffc0202a44:	60e2                	ld	ra,24(sp)
ffffffffc0202a46:	6442                	ld	s0,16(sp)
ffffffffc0202a48:	64a2                	ld	s1,8(sp)
ffffffffc0202a4a:	6902                	ld	s2,0(sp)
ffffffffc0202a4c:	6105                	addi	sp,sp,32
ffffffffc0202a4e:	8082                	ret

ffffffffc0202a50 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0202a50:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0202a52:	c505                	beqz	a0,ffffffffc0202a7a <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0202a54:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202a56:	c501                	beqz	a0,ffffffffc0202a5e <find_vma+0xe>
ffffffffc0202a58:	651c                	ld	a5,8(a0)
ffffffffc0202a5a:	02f5f263          	bgeu	a1,a5,ffffffffc0202a7e <find_vma+0x2e>
    return listelm->next;
ffffffffc0202a5e:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0202a60:	00f68d63          	beq	a3,a5,ffffffffc0202a7a <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0202a64:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202a68:	00e5e663          	bltu	a1,a4,ffffffffc0202a74 <find_vma+0x24>
ffffffffc0202a6c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202a70:	00e5ec63          	bltu	a1,a4,ffffffffc0202a88 <find_vma+0x38>
ffffffffc0202a74:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0202a76:	fef697e3          	bne	a3,a5,ffffffffc0202a64 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0202a7a:	4501                	li	a0,0
}
ffffffffc0202a7c:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202a7e:	691c                	ld	a5,16(a0)
ffffffffc0202a80:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0202a5e <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0202a84:	ea88                	sd	a0,16(a3)
ffffffffc0202a86:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0202a88:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0202a8c:	ea88                	sd	a0,16(a3)
ffffffffc0202a8e:	8082                	ret

ffffffffc0202a90 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202a90:	6590                	ld	a2,8(a1)
ffffffffc0202a92:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0202a96:	1141                	addi	sp,sp,-16
ffffffffc0202a98:	e406                	sd	ra,8(sp)
ffffffffc0202a9a:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202a9c:	01066763          	bltu	a2,a6,ffffffffc0202aaa <insert_vma_struct+0x1a>
ffffffffc0202aa0:	a085                	j	ffffffffc0202b00 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202aa2:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202aa6:	04e66863          	bltu	a2,a4,ffffffffc0202af6 <insert_vma_struct+0x66>
ffffffffc0202aaa:	86be                	mv	a3,a5
ffffffffc0202aac:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0202aae:	fef51ae3          	bne	a0,a5,ffffffffc0202aa2 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0202ab2:	02a68463          	beq	a3,a0,ffffffffc0202ada <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202ab6:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202aba:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202abe:	08e8f163          	bgeu	a7,a4,ffffffffc0202b40 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202ac2:	04e66f63          	bltu	a2,a4,ffffffffc0202b20 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0202ac6:	00f50a63          	beq	a0,a5,ffffffffc0202ada <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202aca:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202ace:	05076963          	bltu	a4,a6,ffffffffc0202b20 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0202ad2:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202ad6:	02c77363          	bgeu	a4,a2,ffffffffc0202afc <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0202ada:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0202adc:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0202ade:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0202ae2:	e390                	sd	a2,0(a5)
ffffffffc0202ae4:	e690                	sd	a2,8(a3)
}
ffffffffc0202ae6:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202ae8:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202aea:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0202aec:	0017079b          	addiw	a5,a4,1
ffffffffc0202af0:	d11c                	sw	a5,32(a0)
}
ffffffffc0202af2:	0141                	addi	sp,sp,16
ffffffffc0202af4:	8082                	ret
    if (le_prev != list) {
ffffffffc0202af6:	fca690e3          	bne	a3,a0,ffffffffc0202ab6 <insert_vma_struct+0x26>
ffffffffc0202afa:	bfd1                	j	ffffffffc0202ace <insert_vma_struct+0x3e>
ffffffffc0202afc:	ebbff0ef          	jal	ra,ffffffffc02029b6 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202b00:	00005697          	auipc	a3,0x5
ffffffffc0202b04:	dc068693          	addi	a3,a3,-576 # ffffffffc02078c0 <commands+0xff8>
ffffffffc0202b08:	00004617          	auipc	a2,0x4
ffffffffc0202b0c:	1d060613          	addi	a2,a2,464 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202b10:	07400593          	li	a1,116
ffffffffc0202b14:	00005517          	auipc	a0,0x5
ffffffffc0202b18:	d9c50513          	addi	a0,a0,-612 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202b1c:	eecfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202b20:	00005697          	auipc	a3,0x5
ffffffffc0202b24:	de068693          	addi	a3,a3,-544 # ffffffffc0207900 <commands+0x1038>
ffffffffc0202b28:	00004617          	auipc	a2,0x4
ffffffffc0202b2c:	1b060613          	addi	a2,a2,432 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202b30:	06c00593          	li	a1,108
ffffffffc0202b34:	00005517          	auipc	a0,0x5
ffffffffc0202b38:	d7c50513          	addi	a0,a0,-644 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202b3c:	eccfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202b40:	00005697          	auipc	a3,0x5
ffffffffc0202b44:	da068693          	addi	a3,a3,-608 # ffffffffc02078e0 <commands+0x1018>
ffffffffc0202b48:	00004617          	auipc	a2,0x4
ffffffffc0202b4c:	19060613          	addi	a2,a2,400 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202b50:	06b00593          	li	a1,107
ffffffffc0202b54:	00005517          	auipc	a0,0x5
ffffffffc0202b58:	d5c50513          	addi	a0,a0,-676 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202b5c:	eacfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202b60 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0202b60:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0202b62:	1141                	addi	sp,sp,-16
ffffffffc0202b64:	e406                	sd	ra,8(sp)
ffffffffc0202b66:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202b68:	e78d                	bnez	a5,ffffffffc0202b92 <mm_destroy+0x32>
ffffffffc0202b6a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202b6c:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0202b6e:	00a40c63          	beq	s0,a0,ffffffffc0202b86 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202b72:	6118                	ld	a4,0(a0)
ffffffffc0202b74:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0202b76:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202b78:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202b7a:	e398                	sd	a4,0(a5)
ffffffffc0202b7c:	38d000ef          	jal	ra,ffffffffc0203708 <kfree>
    return listelm->next;
ffffffffc0202b80:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0202b82:	fea418e3          	bne	s0,a0,ffffffffc0202b72 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0202b86:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0202b88:	6402                	ld	s0,0(sp)
ffffffffc0202b8a:	60a2                	ld	ra,8(sp)
ffffffffc0202b8c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0202b8e:	37b0006f          	j	ffffffffc0203708 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202b92:	00005697          	auipc	a3,0x5
ffffffffc0202b96:	d8e68693          	addi	a3,a3,-626 # ffffffffc0207920 <commands+0x1058>
ffffffffc0202b9a:	00004617          	auipc	a2,0x4
ffffffffc0202b9e:	13e60613          	addi	a2,a2,318 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202ba2:	09400593          	li	a1,148
ffffffffc0202ba6:	00005517          	auipc	a0,0x5
ffffffffc0202baa:	d0a50513          	addi	a0,a0,-758 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202bae:	e5afd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202bb2 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc0202bb2:	7139                	addi	sp,sp,-64
ffffffffc0202bb4:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202bb6:	6405                	lui	s0,0x1
ffffffffc0202bb8:	147d                	addi	s0,s0,-1
ffffffffc0202bba:	77fd                	lui	a5,0xfffff
ffffffffc0202bbc:	9622                	add	a2,a2,s0
ffffffffc0202bbe:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0202bc0:	f426                	sd	s1,40(sp)
ffffffffc0202bc2:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202bc4:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0202bc8:	f04a                	sd	s2,32(sp)
ffffffffc0202bca:	ec4e                	sd	s3,24(sp)
ffffffffc0202bcc:	e852                	sd	s4,16(sp)
ffffffffc0202bce:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0202bd0:	002005b7          	lui	a1,0x200
ffffffffc0202bd4:	00f67433          	and	s0,a2,a5
ffffffffc0202bd8:	06b4e363          	bltu	s1,a1,ffffffffc0202c3e <mm_map+0x8c>
ffffffffc0202bdc:	0684f163          	bgeu	s1,s0,ffffffffc0202c3e <mm_map+0x8c>
ffffffffc0202be0:	4785                	li	a5,1
ffffffffc0202be2:	07fe                	slli	a5,a5,0x1f
ffffffffc0202be4:	0487ed63          	bltu	a5,s0,ffffffffc0202c3e <mm_map+0x8c>
ffffffffc0202be8:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0202bea:	cd21                	beqz	a0,ffffffffc0202c42 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0202bec:	85a6                	mv	a1,s1
ffffffffc0202bee:	8ab6                	mv	s5,a3
ffffffffc0202bf0:	8a3a                	mv	s4,a4
ffffffffc0202bf2:	e5fff0ef          	jal	ra,ffffffffc0202a50 <find_vma>
ffffffffc0202bf6:	c501                	beqz	a0,ffffffffc0202bfe <mm_map+0x4c>
ffffffffc0202bf8:	651c                	ld	a5,8(a0)
ffffffffc0202bfa:	0487e263          	bltu	a5,s0,ffffffffc0202c3e <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202bfe:	03000513          	li	a0,48
ffffffffc0202c02:	257000ef          	jal	ra,ffffffffc0203658 <kmalloc>
ffffffffc0202c06:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202c08:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0202c0a:	02090163          	beqz	s2,ffffffffc0202c2c <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202c0e:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0202c10:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0202c14:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202c18:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202c1c:	85ca                	mv	a1,s2
ffffffffc0202c1e:	e73ff0ef          	jal	ra,ffffffffc0202a90 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0202c22:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0202c24:	000a0463          	beqz	s4,ffffffffc0202c2c <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0202c28:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>

out:
    return ret;
}
ffffffffc0202c2c:	70e2                	ld	ra,56(sp)
ffffffffc0202c2e:	7442                	ld	s0,48(sp)
ffffffffc0202c30:	74a2                	ld	s1,40(sp)
ffffffffc0202c32:	7902                	ld	s2,32(sp)
ffffffffc0202c34:	69e2                	ld	s3,24(sp)
ffffffffc0202c36:	6a42                	ld	s4,16(sp)
ffffffffc0202c38:	6aa2                	ld	s5,8(sp)
ffffffffc0202c3a:	6121                	addi	sp,sp,64
ffffffffc0202c3c:	8082                	ret
        return -E_INVAL;
ffffffffc0202c3e:	5575                	li	a0,-3
ffffffffc0202c40:	b7f5                	j	ffffffffc0202c2c <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0202c42:	00005697          	auipc	a3,0x5
ffffffffc0202c46:	cf668693          	addi	a3,a3,-778 # ffffffffc0207938 <commands+0x1070>
ffffffffc0202c4a:	00004617          	auipc	a2,0x4
ffffffffc0202c4e:	08e60613          	addi	a2,a2,142 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202c52:	0a700593          	li	a1,167
ffffffffc0202c56:	00005517          	auipc	a0,0x5
ffffffffc0202c5a:	c5a50513          	addi	a0,a0,-934 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202c5e:	daafd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202c62 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0202c62:	7139                	addi	sp,sp,-64
ffffffffc0202c64:	fc06                	sd	ra,56(sp)
ffffffffc0202c66:	f822                	sd	s0,48(sp)
ffffffffc0202c68:	f426                	sd	s1,40(sp)
ffffffffc0202c6a:	f04a                	sd	s2,32(sp)
ffffffffc0202c6c:	ec4e                	sd	s3,24(sp)
ffffffffc0202c6e:	e852                	sd	s4,16(sp)
ffffffffc0202c70:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0202c72:	c52d                	beqz	a0,ffffffffc0202cdc <dup_mmap+0x7a>
ffffffffc0202c74:	892a                	mv	s2,a0
ffffffffc0202c76:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0202c78:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0202c7a:	e595                	bnez	a1,ffffffffc0202ca6 <dup_mmap+0x44>
ffffffffc0202c7c:	a085                	j	ffffffffc0202cdc <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202c7e:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0202c80:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee0>
        vma->vm_end = vm_end;
ffffffffc0202c84:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0202c88:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0202c8c:	e05ff0ef          	jal	ra,ffffffffc0202a90 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0202c90:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc8>
ffffffffc0202c94:	fe843603          	ld	a2,-24(s0)
ffffffffc0202c98:	6c8c                	ld	a1,24(s1)
ffffffffc0202c9a:	01893503          	ld	a0,24(s2)
ffffffffc0202c9e:	4701                	li	a4,0
ffffffffc0202ca0:	e38ff0ef          	jal	ra,ffffffffc02022d8 <copy_range>
ffffffffc0202ca4:	e105                	bnez	a0,ffffffffc0202cc4 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0202ca6:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0202ca8:	02848863          	beq	s1,s0,ffffffffc0202cd8 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202cac:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0202cb0:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202cb4:	ff043a03          	ld	s4,-16(s0)
ffffffffc0202cb8:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202cbc:	19d000ef          	jal	ra,ffffffffc0203658 <kmalloc>
ffffffffc0202cc0:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0202cc2:	fd55                	bnez	a0,ffffffffc0202c7e <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202cc4:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0202cc6:	70e2                	ld	ra,56(sp)
ffffffffc0202cc8:	7442                	ld	s0,48(sp)
ffffffffc0202cca:	74a2                	ld	s1,40(sp)
ffffffffc0202ccc:	7902                	ld	s2,32(sp)
ffffffffc0202cce:	69e2                	ld	s3,24(sp)
ffffffffc0202cd0:	6a42                	ld	s4,16(sp)
ffffffffc0202cd2:	6aa2                	ld	s5,8(sp)
ffffffffc0202cd4:	6121                	addi	sp,sp,64
ffffffffc0202cd6:	8082                	ret
    return 0;
ffffffffc0202cd8:	4501                	li	a0,0
ffffffffc0202cda:	b7f5                	j	ffffffffc0202cc6 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0202cdc:	00005697          	auipc	a3,0x5
ffffffffc0202ce0:	c6c68693          	addi	a3,a3,-916 # ffffffffc0207948 <commands+0x1080>
ffffffffc0202ce4:	00004617          	auipc	a2,0x4
ffffffffc0202ce8:	ff460613          	addi	a2,a2,-12 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202cec:	0c000593          	li	a1,192
ffffffffc0202cf0:	00005517          	auipc	a0,0x5
ffffffffc0202cf4:	bc050513          	addi	a0,a0,-1088 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202cf8:	d10fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202cfc <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0202cfc:	1101                	addi	sp,sp,-32
ffffffffc0202cfe:	ec06                	sd	ra,24(sp)
ffffffffc0202d00:	e822                	sd	s0,16(sp)
ffffffffc0202d02:	e426                	sd	s1,8(sp)
ffffffffc0202d04:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202d06:	c531                	beqz	a0,ffffffffc0202d52 <exit_mmap+0x56>
ffffffffc0202d08:	591c                	lw	a5,48(a0)
ffffffffc0202d0a:	84aa                	mv	s1,a0
ffffffffc0202d0c:	e3b9                	bnez	a5,ffffffffc0202d52 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202d0e:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0202d10:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0202d14:	02850663          	beq	a0,s0,ffffffffc0202d40 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end); // 大概是移除页表引用
ffffffffc0202d18:	ff043603          	ld	a2,-16(s0)
ffffffffc0202d1c:	fe843583          	ld	a1,-24(s0)
ffffffffc0202d20:	854a                	mv	a0,s2
ffffffffc0202d22:	cb2fe0ef          	jal	ra,ffffffffc02011d4 <unmap_range>
ffffffffc0202d26:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202d28:	fe8498e3          	bne	s1,s0,ffffffffc0202d18 <exit_mmap+0x1c>
ffffffffc0202d2c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0202d2e:	00848c63          	beq	s1,s0,ffffffffc0202d46 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end); // 大概是释放页表页面
ffffffffc0202d32:	ff043603          	ld	a2,-16(s0)
ffffffffc0202d36:	fe843583          	ld	a1,-24(s0)
ffffffffc0202d3a:	854a                	mv	a0,s2
ffffffffc0202d3c:	ddefe0ef          	jal	ra,ffffffffc020131a <exit_range>
ffffffffc0202d40:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202d42:	fe8498e3          	bne	s1,s0,ffffffffc0202d32 <exit_mmap+0x36>
    }
}
ffffffffc0202d46:	60e2                	ld	ra,24(sp)
ffffffffc0202d48:	6442                	ld	s0,16(sp)
ffffffffc0202d4a:	64a2                	ld	s1,8(sp)
ffffffffc0202d4c:	6902                	ld	s2,0(sp)
ffffffffc0202d4e:	6105                	addi	sp,sp,32
ffffffffc0202d50:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202d52:	00005697          	auipc	a3,0x5
ffffffffc0202d56:	c1668693          	addi	a3,a3,-1002 # ffffffffc0207968 <commands+0x10a0>
ffffffffc0202d5a:	00004617          	auipc	a2,0x4
ffffffffc0202d5e:	f7e60613          	addi	a2,a2,-130 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202d62:	0d600593          	li	a1,214
ffffffffc0202d66:	00005517          	auipc	a0,0x5
ffffffffc0202d6a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202d6e:	c9afd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202d72 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0202d72:	7139                	addi	sp,sp,-64
ffffffffc0202d74:	f822                	sd	s0,48(sp)
ffffffffc0202d76:	f426                	sd	s1,40(sp)
ffffffffc0202d78:	fc06                	sd	ra,56(sp)
ffffffffc0202d7a:	f04a                	sd	s2,32(sp)
ffffffffc0202d7c:	ec4e                	sd	s3,24(sp)
ffffffffc0202d7e:	e852                	sd	s4,16(sp)
ffffffffc0202d80:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0202d82:	c59ff0ef          	jal	ra,ffffffffc02029da <mm_create>
    assert(mm != NULL);
ffffffffc0202d86:	84aa                	mv	s1,a0
ffffffffc0202d88:	03200413          	li	s0,50
ffffffffc0202d8c:	e919                	bnez	a0,ffffffffc0202da2 <vmm_init+0x30>
ffffffffc0202d8e:	a991                	j	ffffffffc02031e2 <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc0202d90:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202d92:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202d94:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0202d98:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202d9a:	8526                	mv	a0,s1
ffffffffc0202d9c:	cf5ff0ef          	jal	ra,ffffffffc0202a90 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202da0:	c80d                	beqz	s0,ffffffffc0202dd2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202da2:	03000513          	li	a0,48
ffffffffc0202da6:	0b3000ef          	jal	ra,ffffffffc0203658 <kmalloc>
ffffffffc0202daa:	85aa                	mv	a1,a0
ffffffffc0202dac:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202db0:	f165                	bnez	a0,ffffffffc0202d90 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0202db2:	00005697          	auipc	a3,0x5
ffffffffc0202db6:	dee68693          	addi	a3,a3,-530 # ffffffffc0207ba0 <commands+0x12d8>
ffffffffc0202dba:	00004617          	auipc	a2,0x4
ffffffffc0202dbe:	f1e60613          	addi	a2,a2,-226 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202dc2:	11300593          	li	a1,275
ffffffffc0202dc6:	00005517          	auipc	a0,0x5
ffffffffc0202dca:	aea50513          	addi	a0,a0,-1302 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202dce:	c3afd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202dd2:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202dd6:	1f900913          	li	s2,505
ffffffffc0202dda:	a819                	j	ffffffffc0202df0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0202ddc:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202dde:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202de0:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202de4:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202de6:	8526                	mv	a0,s1
ffffffffc0202de8:	ca9ff0ef          	jal	ra,ffffffffc0202a90 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202dec:	03240a63          	beq	s0,s2,ffffffffc0202e20 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202df0:	03000513          	li	a0,48
ffffffffc0202df4:	065000ef          	jal	ra,ffffffffc0203658 <kmalloc>
ffffffffc0202df8:	85aa                	mv	a1,a0
ffffffffc0202dfa:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202dfe:	fd79                	bnez	a0,ffffffffc0202ddc <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0202e00:	00005697          	auipc	a3,0x5
ffffffffc0202e04:	da068693          	addi	a3,a3,-608 # ffffffffc0207ba0 <commands+0x12d8>
ffffffffc0202e08:	00004617          	auipc	a2,0x4
ffffffffc0202e0c:	ed060613          	addi	a2,a2,-304 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202e10:	11900593          	li	a1,281
ffffffffc0202e14:	00005517          	auipc	a0,0x5
ffffffffc0202e18:	a9c50513          	addi	a0,a0,-1380 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202e1c:	becfd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202e20:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0202e22:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0202e24:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202e28:	2cf48d63          	beq	s1,a5,ffffffffc0203102 <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202e2c:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c75c>
ffffffffc0202e30:	ffe70613          	addi	a2,a4,-2
ffffffffc0202e34:	24d61763          	bne	a2,a3,ffffffffc0203082 <vmm_init+0x310>
ffffffffc0202e38:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202e3c:	24e69363          	bne	a3,a4,ffffffffc0203082 <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc0202e40:	0715                	addi	a4,a4,5
ffffffffc0202e42:	679c                	ld	a5,8(a5)
ffffffffc0202e44:	feb712e3          	bne	a4,a1,ffffffffc0202e28 <vmm_init+0xb6>
ffffffffc0202e48:	4a1d                	li	s4,7
ffffffffc0202e4a:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202e4c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202e50:	85a2                	mv	a1,s0
ffffffffc0202e52:	8526                	mv	a0,s1
ffffffffc0202e54:	bfdff0ef          	jal	ra,ffffffffc0202a50 <find_vma>
ffffffffc0202e58:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0202e5a:	30050463          	beqz	a0,ffffffffc0203162 <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202e5e:	00140593          	addi	a1,s0,1
ffffffffc0202e62:	8526                	mv	a0,s1
ffffffffc0202e64:	bedff0ef          	jal	ra,ffffffffc0202a50 <find_vma>
ffffffffc0202e68:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202e6a:	2c050c63          	beqz	a0,ffffffffc0203142 <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202e6e:	85d2                	mv	a1,s4
ffffffffc0202e70:	8526                	mv	a0,s1
ffffffffc0202e72:	bdfff0ef          	jal	ra,ffffffffc0202a50 <find_vma>
        assert(vma3 == NULL);
ffffffffc0202e76:	2a051663          	bnez	a0,ffffffffc0203122 <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0202e7a:	00340593          	addi	a1,s0,3
ffffffffc0202e7e:	8526                	mv	a0,s1
ffffffffc0202e80:	bd1ff0ef          	jal	ra,ffffffffc0202a50 <find_vma>
        assert(vma4 == NULL);
ffffffffc0202e84:	30051f63          	bnez	a0,ffffffffc02031a2 <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202e88:	00440593          	addi	a1,s0,4
ffffffffc0202e8c:	8526                	mv	a0,s1
ffffffffc0202e8e:	bc3ff0ef          	jal	ra,ffffffffc0202a50 <find_vma>
        assert(vma5 == NULL);
ffffffffc0202e92:	2e051863          	bnez	a0,ffffffffc0203182 <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202e96:	00893783          	ld	a5,8(s2)
ffffffffc0202e9a:	20879463          	bne	a5,s0,ffffffffc02030a2 <vmm_init+0x330>
ffffffffc0202e9e:	01093783          	ld	a5,16(s2)
ffffffffc0202ea2:	20fa1063          	bne	s4,a5,ffffffffc02030a2 <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202ea6:	0089b783          	ld	a5,8(s3)
ffffffffc0202eaa:	20879c63          	bne	a5,s0,ffffffffc02030c2 <vmm_init+0x350>
ffffffffc0202eae:	0109b783          	ld	a5,16(s3)
ffffffffc0202eb2:	20fa1863          	bne	s4,a5,ffffffffc02030c2 <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202eb6:	0415                	addi	s0,s0,5
ffffffffc0202eb8:	0a15                	addi	s4,s4,5
ffffffffc0202eba:	f9541be3          	bne	s0,s5,ffffffffc0202e50 <vmm_init+0xde>
ffffffffc0202ebe:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202ec0:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0202ec2:	85a2                	mv	a1,s0
ffffffffc0202ec4:	8526                	mv	a0,s1
ffffffffc0202ec6:	b8bff0ef          	jal	ra,ffffffffc0202a50 <find_vma>
ffffffffc0202eca:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0202ece:	c90d                	beqz	a0,ffffffffc0202f00 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202ed0:	6914                	ld	a3,16(a0)
ffffffffc0202ed2:	6510                	ld	a2,8(a0)
ffffffffc0202ed4:	00005517          	auipc	a0,0x5
ffffffffc0202ed8:	bb450513          	addi	a0,a0,-1100 # ffffffffc0207a88 <commands+0x11c0>
ffffffffc0202edc:	9f0fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202ee0:	00005697          	auipc	a3,0x5
ffffffffc0202ee4:	bd068693          	addi	a3,a3,-1072 # ffffffffc0207ab0 <commands+0x11e8>
ffffffffc0202ee8:	00004617          	auipc	a2,0x4
ffffffffc0202eec:	df060613          	addi	a2,a2,-528 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0202ef0:	13b00593          	li	a1,315
ffffffffc0202ef4:	00005517          	auipc	a0,0x5
ffffffffc0202ef8:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0202efc:	b0cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0202f00:	147d                	addi	s0,s0,-1
ffffffffc0202f02:	fd2410e3          	bne	s0,s2,ffffffffc0202ec2 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202f06:	8526                	mv	a0,s1
ffffffffc0202f08:	c59ff0ef          	jal	ra,ffffffffc0202b60 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202f0c:	00005517          	auipc	a0,0x5
ffffffffc0202f10:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0207ac8 <commands+0x1200>
ffffffffc0202f14:	9b8fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202f18:	85cfe0ef          	jal	ra,ffffffffc0200f74 <nr_free_pages>
ffffffffc0202f1c:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0202f1e:	abdff0ef          	jal	ra,ffffffffc02029da <mm_create>
ffffffffc0202f22:	000b0797          	auipc	a5,0xb0
ffffffffc0202f26:	90a7bf23          	sd	a0,-1762(a5) # ffffffffc02b2840 <check_mm_struct>
ffffffffc0202f2a:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0202f2c:	28050b63          	beqz	a0,ffffffffc02031c2 <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202f30:	000b0497          	auipc	s1,0xb0
ffffffffc0202f34:	8e84b483          	ld	s1,-1816(s1) # ffffffffc02b2818 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0202f38:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202f3a:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202f3c:	2e079f63          	bnez	a5,ffffffffc020323a <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202f40:	03000513          	li	a0,48
ffffffffc0202f44:	714000ef          	jal	ra,ffffffffc0203658 <kmalloc>
ffffffffc0202f48:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0202f4a:	18050c63          	beqz	a0,ffffffffc02030e2 <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc0202f4e:	002007b7          	lui	a5,0x200
ffffffffc0202f52:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0202f56:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202f58:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202f5a:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0202f5e:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0202f60:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0202f64:	b2dff0ef          	jal	ra,ffffffffc0202a90 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202f68:	10000593          	li	a1,256
ffffffffc0202f6c:	8522                	mv	a0,s0
ffffffffc0202f6e:	ae3ff0ef          	jal	ra,ffffffffc0202a50 <find_vma>
ffffffffc0202f72:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0202f76:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202f7a:	2ea99063          	bne	s3,a0,ffffffffc020325a <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc0202f7e:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ed8>
    for (i = 0; i < 100; i ++) {
ffffffffc0202f82:	0785                	addi	a5,a5,1
ffffffffc0202f84:	fee79de3          	bne	a5,a4,ffffffffc0202f7e <vmm_init+0x20c>
        sum += i;
ffffffffc0202f88:	6705                	lui	a4,0x1
ffffffffc0202f8a:	10000793          	li	a5,256
ffffffffc0202f8e:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8862>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202f92:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202f96:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0202f9a:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0202f9c:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202f9e:	fec79ce3          	bne	a5,a2,ffffffffc0202f96 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc0202fa2:	2e071863          	bnez	a4,ffffffffc0203292 <vmm_init+0x520>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fa6:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0202fa8:	000b0a97          	auipc	s5,0xb0
ffffffffc0202fac:	878a8a93          	addi	s5,s5,-1928 # ffffffffc02b2820 <npage>
ffffffffc0202fb0:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fb4:	078a                	slli	a5,a5,0x2
ffffffffc0202fb6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fb8:	2cc7f163          	bgeu	a5,a2,ffffffffc020327a <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fbc:	00006a17          	auipc	s4,0x6
ffffffffc0202fc0:	db4a3a03          	ld	s4,-588(s4) # ffffffffc0208d70 <nbase>
ffffffffc0202fc4:	414787b3          	sub	a5,a5,s4
ffffffffc0202fc8:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0202fca:	8799                	srai	a5,a5,0x6
ffffffffc0202fcc:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0202fce:	00c79713          	slli	a4,a5,0xc
ffffffffc0202fd2:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202fd4:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202fd8:	24c77563          	bgeu	a4,a2,ffffffffc0203222 <vmm_init+0x4b0>
ffffffffc0202fdc:	000b0997          	auipc	s3,0xb0
ffffffffc0202fe0:	85c9b983          	ld	s3,-1956(s3) # ffffffffc02b2838 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202fe4:	4581                	li	a1,0
ffffffffc0202fe6:	8526                	mv	a0,s1
ffffffffc0202fe8:	99b6                	add	s3,s3,a3
ffffffffc0202fea:	dc2fe0ef          	jal	ra,ffffffffc02015ac <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fee:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202ff2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ff6:	078a                	slli	a5,a5,0x2
ffffffffc0202ff8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ffa:	28e7f063          	bgeu	a5,a4,ffffffffc020327a <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ffe:	000b0997          	auipc	s3,0xb0
ffffffffc0203002:	82a98993          	addi	s3,s3,-2006 # ffffffffc02b2828 <pages>
ffffffffc0203006:	0009b503          	ld	a0,0(s3)
ffffffffc020300a:	414787b3          	sub	a5,a5,s4
ffffffffc020300e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203010:	953e                	add	a0,a0,a5
ffffffffc0203012:	4585                	li	a1,1
ffffffffc0203014:	f21fd0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203018:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc020301a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020301e:	078a                	slli	a5,a5,0x2
ffffffffc0203020:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203022:	24e7fc63          	bgeu	a5,a4,ffffffffc020327a <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0203026:	0009b503          	ld	a0,0(s3)
ffffffffc020302a:	414787b3          	sub	a5,a5,s4
ffffffffc020302e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203030:	4585                	li	a1,1
ffffffffc0203032:	953e                	add	a0,a0,a5
ffffffffc0203034:	f01fd0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    pgdir[0] = 0;
ffffffffc0203038:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc020303c:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0203040:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0203042:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0203046:	b1bff0ef          	jal	ra,ffffffffc0202b60 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc020304a:	000af797          	auipc	a5,0xaf
ffffffffc020304e:	7e07bb23          	sd	zero,2038(a5) # ffffffffc02b2840 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203052:	f23fd0ef          	jal	ra,ffffffffc0200f74 <nr_free_pages>
ffffffffc0203056:	1aa91663          	bne	s2,a0,ffffffffc0203202 <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020305a:	00005517          	auipc	a0,0x5
ffffffffc020305e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0207b68 <commands+0x12a0>
ffffffffc0203062:	86afd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0203066:	7442                	ld	s0,48(sp)
ffffffffc0203068:	70e2                	ld	ra,56(sp)
ffffffffc020306a:	74a2                	ld	s1,40(sp)
ffffffffc020306c:	7902                	ld	s2,32(sp)
ffffffffc020306e:	69e2                	ld	s3,24(sp)
ffffffffc0203070:	6a42                	ld	s4,16(sp)
ffffffffc0203072:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203074:	00005517          	auipc	a0,0x5
ffffffffc0203078:	b1450513          	addi	a0,a0,-1260 # ffffffffc0207b88 <commands+0x12c0>
}
ffffffffc020307c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020307e:	84efd06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203082:	00005697          	auipc	a3,0x5
ffffffffc0203086:	91e68693          	addi	a3,a3,-1762 # ffffffffc02079a0 <commands+0x10d8>
ffffffffc020308a:	00004617          	auipc	a2,0x4
ffffffffc020308e:	c4e60613          	addi	a2,a2,-946 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203092:	12200593          	li	a1,290
ffffffffc0203096:	00005517          	auipc	a0,0x5
ffffffffc020309a:	81a50513          	addi	a0,a0,-2022 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc020309e:	96afd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02030a2:	00005697          	auipc	a3,0x5
ffffffffc02030a6:	98668693          	addi	a3,a3,-1658 # ffffffffc0207a28 <commands+0x1160>
ffffffffc02030aa:	00004617          	auipc	a2,0x4
ffffffffc02030ae:	c2e60613          	addi	a2,a2,-978 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02030b2:	13200593          	li	a1,306
ffffffffc02030b6:	00004517          	auipc	a0,0x4
ffffffffc02030ba:	7fa50513          	addi	a0,a0,2042 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc02030be:	94afd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02030c2:	00005697          	auipc	a3,0x5
ffffffffc02030c6:	99668693          	addi	a3,a3,-1642 # ffffffffc0207a58 <commands+0x1190>
ffffffffc02030ca:	00004617          	auipc	a2,0x4
ffffffffc02030ce:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02030d2:	13300593          	li	a1,307
ffffffffc02030d6:	00004517          	auipc	a0,0x4
ffffffffc02030da:	7da50513          	addi	a0,a0,2010 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc02030de:	92afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc02030e2:	00005697          	auipc	a3,0x5
ffffffffc02030e6:	abe68693          	addi	a3,a3,-1346 # ffffffffc0207ba0 <commands+0x12d8>
ffffffffc02030ea:	00004617          	auipc	a2,0x4
ffffffffc02030ee:	bee60613          	addi	a2,a2,-1042 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02030f2:	15200593          	li	a1,338
ffffffffc02030f6:	00004517          	auipc	a0,0x4
ffffffffc02030fa:	7ba50513          	addi	a0,a0,1978 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc02030fe:	90afd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203102:	00005697          	auipc	a3,0x5
ffffffffc0203106:	88668693          	addi	a3,a3,-1914 # ffffffffc0207988 <commands+0x10c0>
ffffffffc020310a:	00004617          	auipc	a2,0x4
ffffffffc020310e:	bce60613          	addi	a2,a2,-1074 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203112:	12000593          	li	a1,288
ffffffffc0203116:	00004517          	auipc	a0,0x4
ffffffffc020311a:	79a50513          	addi	a0,a0,1946 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc020311e:	8eafd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc0203122:	00005697          	auipc	a3,0x5
ffffffffc0203126:	8d668693          	addi	a3,a3,-1834 # ffffffffc02079f8 <commands+0x1130>
ffffffffc020312a:	00004617          	auipc	a2,0x4
ffffffffc020312e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203132:	12c00593          	li	a1,300
ffffffffc0203136:	00004517          	auipc	a0,0x4
ffffffffc020313a:	77a50513          	addi	a0,a0,1914 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc020313e:	8cafd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc0203142:	00005697          	auipc	a3,0x5
ffffffffc0203146:	8a668693          	addi	a3,a3,-1882 # ffffffffc02079e8 <commands+0x1120>
ffffffffc020314a:	00004617          	auipc	a2,0x4
ffffffffc020314e:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203152:	12a00593          	li	a1,298
ffffffffc0203156:	00004517          	auipc	a0,0x4
ffffffffc020315a:	75a50513          	addi	a0,a0,1882 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc020315e:	8aafd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc0203162:	00005697          	auipc	a3,0x5
ffffffffc0203166:	87668693          	addi	a3,a3,-1930 # ffffffffc02079d8 <commands+0x1110>
ffffffffc020316a:	00004617          	auipc	a2,0x4
ffffffffc020316e:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203172:	12800593          	li	a1,296
ffffffffc0203176:	00004517          	auipc	a0,0x4
ffffffffc020317a:	73a50513          	addi	a0,a0,1850 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc020317e:	88afd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc0203182:	00005697          	auipc	a3,0x5
ffffffffc0203186:	89668693          	addi	a3,a3,-1898 # ffffffffc0207a18 <commands+0x1150>
ffffffffc020318a:	00004617          	auipc	a2,0x4
ffffffffc020318e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203192:	13000593          	li	a1,304
ffffffffc0203196:	00004517          	auipc	a0,0x4
ffffffffc020319a:	71a50513          	addi	a0,a0,1818 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc020319e:	86afd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc02031a2:	00005697          	auipc	a3,0x5
ffffffffc02031a6:	86668693          	addi	a3,a3,-1946 # ffffffffc0207a08 <commands+0x1140>
ffffffffc02031aa:	00004617          	auipc	a2,0x4
ffffffffc02031ae:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02031b2:	12e00593          	li	a1,302
ffffffffc02031b6:	00004517          	auipc	a0,0x4
ffffffffc02031ba:	6fa50513          	addi	a0,a0,1786 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc02031be:	84afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02031c2:	00005697          	auipc	a3,0x5
ffffffffc02031c6:	92668693          	addi	a3,a3,-1754 # ffffffffc0207ae8 <commands+0x1220>
ffffffffc02031ca:	00004617          	auipc	a2,0x4
ffffffffc02031ce:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02031d2:	14b00593          	li	a1,331
ffffffffc02031d6:	00004517          	auipc	a0,0x4
ffffffffc02031da:	6da50513          	addi	a0,a0,1754 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc02031de:	82afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc02031e2:	00004697          	auipc	a3,0x4
ffffffffc02031e6:	75668693          	addi	a3,a3,1878 # ffffffffc0207938 <commands+0x1070>
ffffffffc02031ea:	00004617          	auipc	a2,0x4
ffffffffc02031ee:	aee60613          	addi	a2,a2,-1298 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02031f2:	10c00593          	li	a1,268
ffffffffc02031f6:	00004517          	auipc	a0,0x4
ffffffffc02031fa:	6ba50513          	addi	a0,a0,1722 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc02031fe:	80afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203202:	00005697          	auipc	a3,0x5
ffffffffc0203206:	93e68693          	addi	a3,a3,-1730 # ffffffffc0207b40 <commands+0x1278>
ffffffffc020320a:	00004617          	auipc	a2,0x4
ffffffffc020320e:	ace60613          	addi	a2,a2,-1330 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203212:	17000593          	li	a1,368
ffffffffc0203216:	00004517          	auipc	a0,0x4
ffffffffc020321a:	69a50513          	addi	a0,a0,1690 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc020321e:	febfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203222:	00004617          	auipc	a2,0x4
ffffffffc0203226:	e7660613          	addi	a2,a2,-394 # ffffffffc0207098 <commands+0x7d0>
ffffffffc020322a:	06900593          	li	a1,105
ffffffffc020322e:	00004517          	auipc	a0,0x4
ffffffffc0203232:	e3250513          	addi	a0,a0,-462 # ffffffffc0207060 <commands+0x798>
ffffffffc0203236:	fd3fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc020323a:	00005697          	auipc	a3,0x5
ffffffffc020323e:	8c668693          	addi	a3,a3,-1850 # ffffffffc0207b00 <commands+0x1238>
ffffffffc0203242:	00004617          	auipc	a2,0x4
ffffffffc0203246:	a9660613          	addi	a2,a2,-1386 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020324a:	14f00593          	li	a1,335
ffffffffc020324e:	00004517          	auipc	a0,0x4
ffffffffc0203252:	66250513          	addi	a0,a0,1634 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0203256:	fb3fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020325a:	00005697          	auipc	a3,0x5
ffffffffc020325e:	8b668693          	addi	a3,a3,-1866 # ffffffffc0207b10 <commands+0x1248>
ffffffffc0203262:	00004617          	auipc	a2,0x4
ffffffffc0203266:	a7660613          	addi	a2,a2,-1418 # ffffffffc0206cd8 <commands+0x410>
ffffffffc020326a:	15700593          	li	a1,343
ffffffffc020326e:	00004517          	auipc	a0,0x4
ffffffffc0203272:	64250513          	addi	a0,a0,1602 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc0203276:	f93fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020327a:	00004617          	auipc	a2,0x4
ffffffffc020327e:	dc660613          	addi	a2,a2,-570 # ffffffffc0207040 <commands+0x778>
ffffffffc0203282:	06200593          	li	a1,98
ffffffffc0203286:	00004517          	auipc	a0,0x4
ffffffffc020328a:	dda50513          	addi	a0,a0,-550 # ffffffffc0207060 <commands+0x798>
ffffffffc020328e:	f7bfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc0203292:	00005697          	auipc	a3,0x5
ffffffffc0203296:	89e68693          	addi	a3,a3,-1890 # ffffffffc0207b30 <commands+0x1268>
ffffffffc020329a:	00004617          	auipc	a2,0x4
ffffffffc020329e:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02032a2:	16300593          	li	a1,355
ffffffffc02032a6:	00004517          	auipc	a0,0x4
ffffffffc02032aa:	60a50513          	addi	a0,a0,1546 # ffffffffc02078b0 <commands+0xfe8>
ffffffffc02032ae:	f5bfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02032b2 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02032b2:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02032b4:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02032b6:	f022                	sd	s0,32(sp)
ffffffffc02032b8:	ec26                	sd	s1,24(sp)
ffffffffc02032ba:	f406                	sd	ra,40(sp)
ffffffffc02032bc:	e84a                	sd	s2,16(sp)
ffffffffc02032be:	8432                	mv	s0,a2
ffffffffc02032c0:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02032c2:	f8eff0ef          	jal	ra,ffffffffc0202a50 <find_vma>

    pgfault_num++;
ffffffffc02032c6:	000af797          	auipc	a5,0xaf
ffffffffc02032ca:	5827a783          	lw	a5,1410(a5) # ffffffffc02b2848 <pgfault_num>
ffffffffc02032ce:	2785                	addiw	a5,a5,1
ffffffffc02032d0:	000af717          	auipc	a4,0xaf
ffffffffc02032d4:	56f72c23          	sw	a5,1400(a4) # ffffffffc02b2848 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02032d8:	c541                	beqz	a0,ffffffffc0203360 <do_pgfault+0xae>
ffffffffc02032da:	651c                	ld	a5,8(a0)
ffffffffc02032dc:	08f46263          	bltu	s0,a5,ffffffffc0203360 <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02032e0:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02032e2:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02032e4:	8b89                	andi	a5,a5,2
ffffffffc02032e6:	ebb9                	bnez	a5,ffffffffc020333c <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02032e8:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02032ea:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02032ec:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02032ee:	4605                	li	a2,1
ffffffffc02032f0:	85a2                	mv	a1,s0
ffffffffc02032f2:	cbdfd0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc02032f6:	c551                	beqz	a0,ffffffffc0203382 <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02032f8:	610c                	ld	a1,0(a0)
ffffffffc02032fa:	c1b9                	beqz	a1,ffffffffc0203340 <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02032fc:	000af797          	auipc	a5,0xaf
ffffffffc0203300:	56c7a783          	lw	a5,1388(a5) # ffffffffc02b2868 <swap_init_ok>
ffffffffc0203304:	c7bd                	beqz	a5,ffffffffc0203372 <do_pgfault+0xc0>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page); // 换入页面
ffffffffc0203306:	85a2                	mv	a1,s0
ffffffffc0203308:	0030                	addi	a2,sp,8
ffffffffc020330a:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc020330c:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page); // 换入页面
ffffffffc020330e:	583000ef          	jal	ra,ffffffffc0204090 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203312:	65a2                	ld	a1,8(sp)
ffffffffc0203314:	6c88                	ld	a0,24(s1)
ffffffffc0203316:	86ca                	mv	a3,s2
ffffffffc0203318:	8622                	mv	a2,s0
ffffffffc020331a:	b2efe0ef          	jal	ra,ffffffffc0201648 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc020331e:	6622                	ld	a2,8(sp)
ffffffffc0203320:	4685                	li	a3,1
ffffffffc0203322:	85a2                	mv	a1,s0
ffffffffc0203324:	8526                	mv	a0,s1
ffffffffc0203326:	44b000ef          	jal	ra,ffffffffc0203f70 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc020332a:	67a2                	ld	a5,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc020332c:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc020332e:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc0203330:	70a2                	ld	ra,40(sp)
ffffffffc0203332:	7402                	ld	s0,32(sp)
ffffffffc0203334:	64e2                	ld	s1,24(sp)
ffffffffc0203336:	6942                	ld	s2,16(sp)
ffffffffc0203338:	6145                	addi	sp,sp,48
ffffffffc020333a:	8082                	ret
        perm |= READ_WRITE;
ffffffffc020333c:	495d                	li	s2,23
ffffffffc020333e:	b76d                	j	ffffffffc02032e8 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203340:	6c88                	ld	a0,24(s1)
ffffffffc0203342:	864a                	mv	a2,s2
ffffffffc0203344:	85a2                	mv	a1,s0
ffffffffc0203346:	9c8ff0ef          	jal	ra,ffffffffc020250e <pgdir_alloc_page>
ffffffffc020334a:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc020334c:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020334e:	f3ed                	bnez	a5,ffffffffc0203330 <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203350:	00005517          	auipc	a0,0x5
ffffffffc0203354:	8b050513          	addi	a0,a0,-1872 # ffffffffc0207c00 <commands+0x1338>
ffffffffc0203358:	d75fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020335c:	5571                	li	a0,-4
            goto failed;
ffffffffc020335e:	bfc9                	j	ffffffffc0203330 <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203360:	85a2                	mv	a1,s0
ffffffffc0203362:	00005517          	auipc	a0,0x5
ffffffffc0203366:	84e50513          	addi	a0,a0,-1970 # ffffffffc0207bb0 <commands+0x12e8>
ffffffffc020336a:	d63fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc020336e:	5575                	li	a0,-3
        goto failed;
ffffffffc0203370:	b7c1                	j	ffffffffc0203330 <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203372:	00005517          	auipc	a0,0x5
ffffffffc0203376:	8b650513          	addi	a0,a0,-1866 # ffffffffc0207c28 <commands+0x1360>
ffffffffc020337a:	d53fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020337e:	5571                	li	a0,-4
            goto failed;
ffffffffc0203380:	bf45                	j	ffffffffc0203330 <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0203382:	00005517          	auipc	a0,0x5
ffffffffc0203386:	85e50513          	addi	a0,a0,-1954 # ffffffffc0207be0 <commands+0x1318>
ffffffffc020338a:	d43fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020338e:	5571                	li	a0,-4
        goto failed;
ffffffffc0203390:	b745                	j	ffffffffc0203330 <do_pgfault+0x7e>

ffffffffc0203392 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0203392:	7179                	addi	sp,sp,-48
ffffffffc0203394:	f022                	sd	s0,32(sp)
ffffffffc0203396:	f406                	sd	ra,40(sp)
ffffffffc0203398:	ec26                	sd	s1,24(sp)
ffffffffc020339a:	e84a                	sd	s2,16(sp)
ffffffffc020339c:	e44e                	sd	s3,8(sp)
ffffffffc020339e:	e052                	sd	s4,0(sp)
ffffffffc02033a0:	842e                	mv	s0,a1
    //检查从addr开始长为len的一段内存能否被用户态程序访问,可用返回1
    if (mm != NULL) {
ffffffffc02033a2:	c135                	beqz	a0,ffffffffc0203406 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc02033a4:	002007b7          	lui	a5,0x200
ffffffffc02033a8:	04f5e663          	bltu	a1,a5,ffffffffc02033f4 <user_mem_check+0x62>
ffffffffc02033ac:	00c584b3          	add	s1,a1,a2
ffffffffc02033b0:	0495f263          	bgeu	a1,s1,ffffffffc02033f4 <user_mem_check+0x62>
ffffffffc02033b4:	4785                	li	a5,1
ffffffffc02033b6:	07fe                	slli	a5,a5,0x1f
ffffffffc02033b8:	0297ee63          	bltu	a5,s1,ffffffffc02033f4 <user_mem_check+0x62>
ffffffffc02033bc:	892a                	mv	s2,a0
ffffffffc02033be:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02033c0:	6a05                	lui	s4,0x1
ffffffffc02033c2:	a821                	j	ffffffffc02033da <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02033c4:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02033c8:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02033ca:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02033cc:	c685                	beqz	a3,ffffffffc02033f4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02033ce:	c399                	beqz	a5,ffffffffc02033d4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02033d0:	02e46263          	bltu	s0,a4,ffffffffc02033f4 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02033d4:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc02033d6:	04947663          	bgeu	s0,s1,ffffffffc0203422 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc02033da:	85a2                	mv	a1,s0
ffffffffc02033dc:	854a                	mv	a0,s2
ffffffffc02033de:	e72ff0ef          	jal	ra,ffffffffc0202a50 <find_vma>
ffffffffc02033e2:	c909                	beqz	a0,ffffffffc02033f4 <user_mem_check+0x62>
ffffffffc02033e4:	6518                	ld	a4,8(a0)
ffffffffc02033e6:	00e46763          	bltu	s0,a4,ffffffffc02033f4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02033ea:	4d1c                	lw	a5,24(a0)
ffffffffc02033ec:	fc099ce3          	bnez	s3,ffffffffc02033c4 <user_mem_check+0x32>
ffffffffc02033f0:	8b85                	andi	a5,a5,1
ffffffffc02033f2:	f3ed                	bnez	a5,ffffffffc02033d4 <user_mem_check+0x42>
            return 0;
ffffffffc02033f4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02033f6:	70a2                	ld	ra,40(sp)
ffffffffc02033f8:	7402                	ld	s0,32(sp)
ffffffffc02033fa:	64e2                	ld	s1,24(sp)
ffffffffc02033fc:	6942                	ld	s2,16(sp)
ffffffffc02033fe:	69a2                	ld	s3,8(sp)
ffffffffc0203400:	6a02                	ld	s4,0(sp)
ffffffffc0203402:	6145                	addi	sp,sp,48
ffffffffc0203404:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203406:	c02007b7          	lui	a5,0xc0200
ffffffffc020340a:	4501                	li	a0,0
ffffffffc020340c:	fef5e5e3          	bltu	a1,a5,ffffffffc02033f6 <user_mem_check+0x64>
ffffffffc0203410:	962e                	add	a2,a2,a1
ffffffffc0203412:	fec5f2e3          	bgeu	a1,a2,ffffffffc02033f6 <user_mem_check+0x64>
ffffffffc0203416:	c8000537          	lui	a0,0xc8000
ffffffffc020341a:	0505                	addi	a0,a0,1
ffffffffc020341c:	00a63533          	sltu	a0,a2,a0
ffffffffc0203420:	bfd9                	j	ffffffffc02033f6 <user_mem_check+0x64>
        return 1;
ffffffffc0203422:	4505                	li	a0,1
ffffffffc0203424:	bfc9                	j	ffffffffc02033f6 <user_mem_check+0x64>

ffffffffc0203426 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0203426:	c94d                	beqz	a0,ffffffffc02034d8 <slob_free+0xb2>
{
ffffffffc0203428:	1141                	addi	sp,sp,-16
ffffffffc020342a:	e022                	sd	s0,0(sp)
ffffffffc020342c:	e406                	sd	ra,8(sp)
ffffffffc020342e:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0203430:	e9c1                	bnez	a1,ffffffffc02034c0 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203432:	100027f3          	csrr	a5,sstatus
ffffffffc0203436:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203438:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020343a:	ebd9                	bnez	a5,ffffffffc02034d0 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020343c:	000a4617          	auipc	a2,0xa4
ffffffffc0203440:	ee460613          	addi	a2,a2,-284 # ffffffffc02a7320 <slobfree>
ffffffffc0203444:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203446:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203448:	679c                	ld	a5,8(a5)
ffffffffc020344a:	02877a63          	bgeu	a4,s0,ffffffffc020347e <slob_free+0x58>
ffffffffc020344e:	00f46463          	bltu	s0,a5,ffffffffc0203456 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203452:	fef76ae3          	bltu	a4,a5,ffffffffc0203446 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0203456:	400c                	lw	a1,0(s0)
ffffffffc0203458:	00459693          	slli	a3,a1,0x4
ffffffffc020345c:	96a2                	add	a3,a3,s0
ffffffffc020345e:	02d78a63          	beq	a5,a3,ffffffffc0203492 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0203462:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0203464:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0203466:	00469793          	slli	a5,a3,0x4
ffffffffc020346a:	97ba                	add	a5,a5,a4
ffffffffc020346c:	02f40e63          	beq	s0,a5,ffffffffc02034a8 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0203470:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0203472:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0203474:	e129                	bnez	a0,ffffffffc02034b6 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0203476:	60a2                	ld	ra,8(sp)
ffffffffc0203478:	6402                	ld	s0,0(sp)
ffffffffc020347a:	0141                	addi	sp,sp,16
ffffffffc020347c:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020347e:	fcf764e3          	bltu	a4,a5,ffffffffc0203446 <slob_free+0x20>
ffffffffc0203482:	fcf472e3          	bgeu	s0,a5,ffffffffc0203446 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0203486:	400c                	lw	a1,0(s0)
ffffffffc0203488:	00459693          	slli	a3,a1,0x4
ffffffffc020348c:	96a2                	add	a3,a3,s0
ffffffffc020348e:	fcd79ae3          	bne	a5,a3,ffffffffc0203462 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0203492:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0203494:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0203496:	9db5                	addw	a1,a1,a3
ffffffffc0203498:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc020349a:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020349c:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020349e:	00469793          	slli	a5,a3,0x4
ffffffffc02034a2:	97ba                	add	a5,a5,a4
ffffffffc02034a4:	fcf416e3          	bne	s0,a5,ffffffffc0203470 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc02034a8:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc02034aa:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc02034ac:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc02034ae:	9ebd                	addw	a3,a3,a5
ffffffffc02034b0:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc02034b2:	e70c                	sd	a1,8(a4)
ffffffffc02034b4:	d169                	beqz	a0,ffffffffc0203476 <slob_free+0x50>
}
ffffffffc02034b6:	6402                	ld	s0,0(sp)
ffffffffc02034b8:	60a2                	ld	ra,8(sp)
ffffffffc02034ba:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02034bc:	986fd06f          	j	ffffffffc0200642 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc02034c0:	25bd                	addiw	a1,a1,15
ffffffffc02034c2:	8191                	srli	a1,a1,0x4
ffffffffc02034c4:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034c6:	100027f3          	csrr	a5,sstatus
ffffffffc02034ca:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02034cc:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034ce:	d7bd                	beqz	a5,ffffffffc020343c <slob_free+0x16>
        intr_disable();
ffffffffc02034d0:	978fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02034d4:	4505                	li	a0,1
ffffffffc02034d6:	b79d                	j	ffffffffc020343c <slob_free+0x16>
ffffffffc02034d8:	8082                	ret

ffffffffc02034da <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034da:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02034dc:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034de:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02034e2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034e4:	9bffd0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
  if(!page)
ffffffffc02034e8:	c91d                	beqz	a0,ffffffffc020351e <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02034ea:	000af697          	auipc	a3,0xaf
ffffffffc02034ee:	33e6b683          	ld	a3,830(a3) # ffffffffc02b2828 <pages>
ffffffffc02034f2:	8d15                	sub	a0,a0,a3
ffffffffc02034f4:	8519                	srai	a0,a0,0x6
ffffffffc02034f6:	00006697          	auipc	a3,0x6
ffffffffc02034fa:	87a6b683          	ld	a3,-1926(a3) # ffffffffc0208d70 <nbase>
ffffffffc02034fe:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0203500:	00c51793          	slli	a5,a0,0xc
ffffffffc0203504:	83b1                	srli	a5,a5,0xc
ffffffffc0203506:	000af717          	auipc	a4,0xaf
ffffffffc020350a:	31a73703          	ld	a4,794(a4) # ffffffffc02b2820 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020350e:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0203510:	00e7fa63          	bgeu	a5,a4,ffffffffc0203524 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0203514:	000af697          	auipc	a3,0xaf
ffffffffc0203518:	3246b683          	ld	a3,804(a3) # ffffffffc02b2838 <va_pa_offset>
ffffffffc020351c:	9536                	add	a0,a0,a3
}
ffffffffc020351e:	60a2                	ld	ra,8(sp)
ffffffffc0203520:	0141                	addi	sp,sp,16
ffffffffc0203522:	8082                	ret
ffffffffc0203524:	86aa                	mv	a3,a0
ffffffffc0203526:	00004617          	auipc	a2,0x4
ffffffffc020352a:	b7260613          	addi	a2,a2,-1166 # ffffffffc0207098 <commands+0x7d0>
ffffffffc020352e:	06900593          	li	a1,105
ffffffffc0203532:	00004517          	auipc	a0,0x4
ffffffffc0203536:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0207060 <commands+0x798>
ffffffffc020353a:	ccffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020353e <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc020353e:	1101                	addi	sp,sp,-32
ffffffffc0203540:	ec06                	sd	ra,24(sp)
ffffffffc0203542:	e822                	sd	s0,16(sp)
ffffffffc0203544:	e426                	sd	s1,8(sp)
ffffffffc0203546:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203548:	01050713          	addi	a4,a0,16
ffffffffc020354c:	6785                	lui	a5,0x1
ffffffffc020354e:	0cf77363          	bgeu	a4,a5,ffffffffc0203614 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0203552:	00f50493          	addi	s1,a0,15
ffffffffc0203556:	8091                	srli	s1,s1,0x4
ffffffffc0203558:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020355a:	10002673          	csrr	a2,sstatus
ffffffffc020355e:	8a09                	andi	a2,a2,2
ffffffffc0203560:	e25d                	bnez	a2,ffffffffc0203606 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0203562:	000a4917          	auipc	s2,0xa4
ffffffffc0203566:	dbe90913          	addi	s2,s2,-578 # ffffffffc02a7320 <slobfree>
ffffffffc020356a:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020356e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203570:	4398                	lw	a4,0(a5)
ffffffffc0203572:	08975e63          	bge	a4,s1,ffffffffc020360e <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0203576:	00f68b63          	beq	a3,a5,ffffffffc020358c <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020357a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020357c:	4018                	lw	a4,0(s0)
ffffffffc020357e:	02975a63          	bge	a4,s1,ffffffffc02035b2 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0203582:	00093683          	ld	a3,0(s2)
ffffffffc0203586:	87a2                	mv	a5,s0
ffffffffc0203588:	fef699e3          	bne	a3,a5,ffffffffc020357a <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc020358c:	ee31                	bnez	a2,ffffffffc02035e8 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc020358e:	4501                	li	a0,0
ffffffffc0203590:	f4bff0ef          	jal	ra,ffffffffc02034da <__slob_get_free_pages.constprop.0>
ffffffffc0203594:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0203596:	cd05                	beqz	a0,ffffffffc02035ce <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0203598:	6585                	lui	a1,0x1
ffffffffc020359a:	e8dff0ef          	jal	ra,ffffffffc0203426 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020359e:	10002673          	csrr	a2,sstatus
ffffffffc02035a2:	8a09                	andi	a2,a2,2
ffffffffc02035a4:	ee05                	bnez	a2,ffffffffc02035dc <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc02035a6:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02035aa:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02035ac:	4018                	lw	a4,0(s0)
ffffffffc02035ae:	fc974ae3          	blt	a4,s1,ffffffffc0203582 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc02035b2:	04e48763          	beq	s1,a4,ffffffffc0203600 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc02035b6:	00449693          	slli	a3,s1,0x4
ffffffffc02035ba:	96a2                	add	a3,a3,s0
ffffffffc02035bc:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02035be:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc02035c0:	9f05                	subw	a4,a4,s1
ffffffffc02035c2:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02035c4:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02035c6:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc02035c8:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc02035cc:	e20d                	bnez	a2,ffffffffc02035ee <slob_alloc.constprop.0+0xb0>
}
ffffffffc02035ce:	60e2                	ld	ra,24(sp)
ffffffffc02035d0:	8522                	mv	a0,s0
ffffffffc02035d2:	6442                	ld	s0,16(sp)
ffffffffc02035d4:	64a2                	ld	s1,8(sp)
ffffffffc02035d6:	6902                	ld	s2,0(sp)
ffffffffc02035d8:	6105                	addi	sp,sp,32
ffffffffc02035da:	8082                	ret
        intr_disable();
ffffffffc02035dc:	86cfd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
			cur = slobfree;
ffffffffc02035e0:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc02035e4:	4605                	li	a2,1
ffffffffc02035e6:	b7d1                	j	ffffffffc02035aa <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc02035e8:	85afd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02035ec:	b74d                	j	ffffffffc020358e <slob_alloc.constprop.0+0x50>
ffffffffc02035ee:	854fd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc02035f2:	60e2                	ld	ra,24(sp)
ffffffffc02035f4:	8522                	mv	a0,s0
ffffffffc02035f6:	6442                	ld	s0,16(sp)
ffffffffc02035f8:	64a2                	ld	s1,8(sp)
ffffffffc02035fa:	6902                	ld	s2,0(sp)
ffffffffc02035fc:	6105                	addi	sp,sp,32
ffffffffc02035fe:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0203600:	6418                	ld	a4,8(s0)
ffffffffc0203602:	e798                	sd	a4,8(a5)
ffffffffc0203604:	b7d1                	j	ffffffffc02035c8 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0203606:	842fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020360a:	4605                	li	a2,1
ffffffffc020360c:	bf99                	j	ffffffffc0203562 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020360e:	843e                	mv	s0,a5
ffffffffc0203610:	87b6                	mv	a5,a3
ffffffffc0203612:	b745                	j	ffffffffc02035b2 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203614:	00004697          	auipc	a3,0x4
ffffffffc0203618:	63c68693          	addi	a3,a3,1596 # ffffffffc0207c50 <commands+0x1388>
ffffffffc020361c:	00003617          	auipc	a2,0x3
ffffffffc0203620:	6bc60613          	addi	a2,a2,1724 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203624:	06400593          	li	a1,100
ffffffffc0203628:	00004517          	auipc	a0,0x4
ffffffffc020362c:	64850513          	addi	a0,a0,1608 # ffffffffc0207c70 <commands+0x13a8>
ffffffffc0203630:	bd9fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203634 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0203634:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0203636:	00004517          	auipc	a0,0x4
ffffffffc020363a:	65250513          	addi	a0,a0,1618 # ffffffffc0207c88 <commands+0x13c0>
kmalloc_init(void) {
ffffffffc020363e:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0203640:	a8dfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0203644:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203646:	00004517          	auipc	a0,0x4
ffffffffc020364a:	65a50513          	addi	a0,a0,1626 # ffffffffc0207ca0 <commands+0x13d8>
}
ffffffffc020364e:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203650:	a7dfc06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0203654 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0203654:	4501                	li	a0,0
ffffffffc0203656:	8082                	ret

ffffffffc0203658 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0203658:	1101                	addi	sp,sp,-32
ffffffffc020365a:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020365c:	6905                	lui	s2,0x1
{
ffffffffc020365e:	e822                	sd	s0,16(sp)
ffffffffc0203660:	ec06                	sd	ra,24(sp)
ffffffffc0203662:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203664:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc9>
{
ffffffffc0203668:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020366a:	04a7f963          	bgeu	a5,a0,ffffffffc02036bc <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc020366e:	4561                	li	a0,24
ffffffffc0203670:	ecfff0ef          	jal	ra,ffffffffc020353e <slob_alloc.constprop.0>
ffffffffc0203674:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0203676:	c929                	beqz	a0,ffffffffc02036c8 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0203678:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc020367c:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc020367e:	00f95763          	bge	s2,a5,ffffffffc020368c <kmalloc+0x34>
ffffffffc0203682:	6705                	lui	a4,0x1
ffffffffc0203684:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0203686:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203688:	fef74ee3          	blt	a4,a5,ffffffffc0203684 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc020368c:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc020368e:	e4dff0ef          	jal	ra,ffffffffc02034da <__slob_get_free_pages.constprop.0>
ffffffffc0203692:	e488                	sd	a0,8(s1)
ffffffffc0203694:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0203696:	c525                	beqz	a0,ffffffffc02036fe <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203698:	100027f3          	csrr	a5,sstatus
ffffffffc020369c:	8b89                	andi	a5,a5,2
ffffffffc020369e:	ef8d                	bnez	a5,ffffffffc02036d8 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc02036a0:	000af797          	auipc	a5,0xaf
ffffffffc02036a4:	1b078793          	addi	a5,a5,432 # ffffffffc02b2850 <bigblocks>
ffffffffc02036a8:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02036aa:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02036ac:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc02036ae:	60e2                	ld	ra,24(sp)
ffffffffc02036b0:	8522                	mv	a0,s0
ffffffffc02036b2:	6442                	ld	s0,16(sp)
ffffffffc02036b4:	64a2                	ld	s1,8(sp)
ffffffffc02036b6:	6902                	ld	s2,0(sp)
ffffffffc02036b8:	6105                	addi	sp,sp,32
ffffffffc02036ba:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02036bc:	0541                	addi	a0,a0,16
ffffffffc02036be:	e81ff0ef          	jal	ra,ffffffffc020353e <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc02036c2:	01050413          	addi	s0,a0,16
ffffffffc02036c6:	f565                	bnez	a0,ffffffffc02036ae <kmalloc+0x56>
ffffffffc02036c8:	4401                	li	s0,0
}
ffffffffc02036ca:	60e2                	ld	ra,24(sp)
ffffffffc02036cc:	8522                	mv	a0,s0
ffffffffc02036ce:	6442                	ld	s0,16(sp)
ffffffffc02036d0:	64a2                	ld	s1,8(sp)
ffffffffc02036d2:	6902                	ld	s2,0(sp)
ffffffffc02036d4:	6105                	addi	sp,sp,32
ffffffffc02036d6:	8082                	ret
        intr_disable();
ffffffffc02036d8:	f71fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		bb->next = bigblocks;
ffffffffc02036dc:	000af797          	auipc	a5,0xaf
ffffffffc02036e0:	17478793          	addi	a5,a5,372 # ffffffffc02b2850 <bigblocks>
ffffffffc02036e4:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02036e6:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02036e8:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc02036ea:	f59fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
		return bb->pages;
ffffffffc02036ee:	6480                	ld	s0,8(s1)
}
ffffffffc02036f0:	60e2                	ld	ra,24(sp)
ffffffffc02036f2:	64a2                	ld	s1,8(sp)
ffffffffc02036f4:	8522                	mv	a0,s0
ffffffffc02036f6:	6442                	ld	s0,16(sp)
ffffffffc02036f8:	6902                	ld	s2,0(sp)
ffffffffc02036fa:	6105                	addi	sp,sp,32
ffffffffc02036fc:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02036fe:	45e1                	li	a1,24
ffffffffc0203700:	8526                	mv	a0,s1
ffffffffc0203702:	d25ff0ef          	jal	ra,ffffffffc0203426 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0203706:	b765                	j	ffffffffc02036ae <kmalloc+0x56>

ffffffffc0203708 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0203708:	c179                	beqz	a0,ffffffffc02037ce <kfree+0xc6>
{
ffffffffc020370a:	1101                	addi	sp,sp,-32
ffffffffc020370c:	e822                	sd	s0,16(sp)
ffffffffc020370e:	ec06                	sd	ra,24(sp)
ffffffffc0203710:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0203712:	03451793          	slli	a5,a0,0x34
ffffffffc0203716:	842a                	mv	s0,a0
ffffffffc0203718:	e7c1                	bnez	a5,ffffffffc02037a0 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020371a:	100027f3          	csrr	a5,sstatus
ffffffffc020371e:	8b89                	andi	a5,a5,2
ffffffffc0203720:	ebc9                	bnez	a5,ffffffffc02037b2 <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203722:	000af797          	auipc	a5,0xaf
ffffffffc0203726:	12e7b783          	ld	a5,302(a5) # ffffffffc02b2850 <bigblocks>
    return 0;
ffffffffc020372a:	4601                	li	a2,0
ffffffffc020372c:	cbb5                	beqz	a5,ffffffffc02037a0 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc020372e:	000af697          	auipc	a3,0xaf
ffffffffc0203732:	12268693          	addi	a3,a3,290 # ffffffffc02b2850 <bigblocks>
ffffffffc0203736:	a021                	j	ffffffffc020373e <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203738:	01048693          	addi	a3,s1,16
ffffffffc020373c:	c3ad                	beqz	a5,ffffffffc020379e <kfree+0x96>
			if (bb->pages == block) {
ffffffffc020373e:	6798                	ld	a4,8(a5)
ffffffffc0203740:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0203742:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0203744:	fe871ae3          	bne	a4,s0,ffffffffc0203738 <kfree+0x30>
				*last = bb->next;
ffffffffc0203748:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc020374a:	ee3d                	bnez	a2,ffffffffc02037c8 <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc020374c:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0203750:	4098                	lw	a4,0(s1)
ffffffffc0203752:	08f46b63          	bltu	s0,a5,ffffffffc02037e8 <kfree+0xe0>
ffffffffc0203756:	000af697          	auipc	a3,0xaf
ffffffffc020375a:	0e26b683          	ld	a3,226(a3) # ffffffffc02b2838 <va_pa_offset>
ffffffffc020375e:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203760:	8031                	srli	s0,s0,0xc
ffffffffc0203762:	000af797          	auipc	a5,0xaf
ffffffffc0203766:	0be7b783          	ld	a5,190(a5) # ffffffffc02b2820 <npage>
ffffffffc020376a:	06f47363          	bgeu	s0,a5,ffffffffc02037d0 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc020376e:	00005517          	auipc	a0,0x5
ffffffffc0203772:	60253503          	ld	a0,1538(a0) # ffffffffc0208d70 <nbase>
ffffffffc0203776:	8c09                	sub	s0,s0,a0
ffffffffc0203778:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc020377a:	000af517          	auipc	a0,0xaf
ffffffffc020377e:	0ae53503          	ld	a0,174(a0) # ffffffffc02b2828 <pages>
ffffffffc0203782:	4585                	li	a1,1
ffffffffc0203784:	9522                	add	a0,a0,s0
ffffffffc0203786:	00e595bb          	sllw	a1,a1,a4
ffffffffc020378a:	faafd0ef          	jal	ra,ffffffffc0200f34 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc020378e:	6442                	ld	s0,16(sp)
ffffffffc0203790:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203792:	8526                	mv	a0,s1
}
ffffffffc0203794:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203796:	45e1                	li	a1,24
}
ffffffffc0203798:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020379a:	c8dff06f          	j	ffffffffc0203426 <slob_free>
ffffffffc020379e:	e215                	bnez	a2,ffffffffc02037c2 <kfree+0xba>
ffffffffc02037a0:	ff040513          	addi	a0,s0,-16
}
ffffffffc02037a4:	6442                	ld	s0,16(sp)
ffffffffc02037a6:	60e2                	ld	ra,24(sp)
ffffffffc02037a8:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02037aa:	4581                	li	a1,0
}
ffffffffc02037ac:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02037ae:	c79ff06f          	j	ffffffffc0203426 <slob_free>
        intr_disable();
ffffffffc02037b2:	e97fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02037b6:	000af797          	auipc	a5,0xaf
ffffffffc02037ba:	09a7b783          	ld	a5,154(a5) # ffffffffc02b2850 <bigblocks>
        return 1;
ffffffffc02037be:	4605                	li	a2,1
ffffffffc02037c0:	f7bd                	bnez	a5,ffffffffc020372e <kfree+0x26>
        intr_enable();
ffffffffc02037c2:	e81fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02037c6:	bfe9                	j	ffffffffc02037a0 <kfree+0x98>
ffffffffc02037c8:	e7bfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02037cc:	b741                	j	ffffffffc020374c <kfree+0x44>
ffffffffc02037ce:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc02037d0:	00004617          	auipc	a2,0x4
ffffffffc02037d4:	87060613          	addi	a2,a2,-1936 # ffffffffc0207040 <commands+0x778>
ffffffffc02037d8:	06200593          	li	a1,98
ffffffffc02037dc:	00004517          	auipc	a0,0x4
ffffffffc02037e0:	88450513          	addi	a0,a0,-1916 # ffffffffc0207060 <commands+0x798>
ffffffffc02037e4:	a25fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02037e8:	86a2                	mv	a3,s0
ffffffffc02037ea:	00004617          	auipc	a2,0x4
ffffffffc02037ee:	98660613          	addi	a2,a2,-1658 # ffffffffc0207170 <commands+0x8a8>
ffffffffc02037f2:	06e00593          	li	a1,110
ffffffffc02037f6:	00004517          	auipc	a0,0x4
ffffffffc02037fa:	86a50513          	addi	a0,a0,-1942 # ffffffffc0207060 <commands+0x798>
ffffffffc02037fe:	a0bfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203802 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203802:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203804:	00004617          	auipc	a2,0x4
ffffffffc0203808:	83c60613          	addi	a2,a2,-1988 # ffffffffc0207040 <commands+0x778>
ffffffffc020380c:	06200593          	li	a1,98
ffffffffc0203810:	00004517          	auipc	a0,0x4
ffffffffc0203814:	85050513          	addi	a0,a0,-1968 # ffffffffc0207060 <commands+0x798>
pa2page(uintptr_t pa) {
ffffffffc0203818:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020381a:	9effc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020381e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020381e:	7135                	addi	sp,sp,-160
ffffffffc0203820:	ed06                	sd	ra,152(sp)
ffffffffc0203822:	e922                	sd	s0,144(sp)
ffffffffc0203824:	e526                	sd	s1,136(sp)
ffffffffc0203826:	e14a                	sd	s2,128(sp)
ffffffffc0203828:	fcce                	sd	s3,120(sp)
ffffffffc020382a:	f8d2                	sd	s4,112(sp)
ffffffffc020382c:	f4d6                	sd	s5,104(sp)
ffffffffc020382e:	f0da                	sd	s6,96(sp)
ffffffffc0203830:	ecde                	sd	s7,88(sp)
ffffffffc0203832:	e8e2                	sd	s8,80(sp)
ffffffffc0203834:	e4e6                	sd	s9,72(sp)
ffffffffc0203836:	e0ea                	sd	s10,64(sp)
ffffffffc0203838:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020383a:	37e010ef          	jal	ra,ffffffffc0204bb8 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020383e:	000af697          	auipc	a3,0xaf
ffffffffc0203842:	01a6b683          	ld	a3,26(a3) # ffffffffc02b2858 <max_swap_offset>
ffffffffc0203846:	010007b7          	lui	a5,0x1000
ffffffffc020384a:	ff968713          	addi	a4,a3,-7
ffffffffc020384e:	17e1                	addi	a5,a5,-8
ffffffffc0203850:	42e7e663          	bltu	a5,a4,ffffffffc0203c7c <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203854:	000a4797          	auipc	a5,0xa4
ffffffffc0203858:	a7c78793          	addi	a5,a5,-1412 # ffffffffc02a72d0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020385c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020385e:	000afb97          	auipc	s7,0xaf
ffffffffc0203862:	002b8b93          	addi	s7,s7,2 # ffffffffc02b2860 <sm>
ffffffffc0203866:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc020386a:	9702                	jalr	a4
ffffffffc020386c:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc020386e:	c10d                	beqz	a0,ffffffffc0203890 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0203870:	60ea                	ld	ra,152(sp)
ffffffffc0203872:	644a                	ld	s0,144(sp)
ffffffffc0203874:	64aa                	ld	s1,136(sp)
ffffffffc0203876:	79e6                	ld	s3,120(sp)
ffffffffc0203878:	7a46                	ld	s4,112(sp)
ffffffffc020387a:	7aa6                	ld	s5,104(sp)
ffffffffc020387c:	7b06                	ld	s6,96(sp)
ffffffffc020387e:	6be6                	ld	s7,88(sp)
ffffffffc0203880:	6c46                	ld	s8,80(sp)
ffffffffc0203882:	6ca6                	ld	s9,72(sp)
ffffffffc0203884:	6d06                	ld	s10,64(sp)
ffffffffc0203886:	7de2                	ld	s11,56(sp)
ffffffffc0203888:	854a                	mv	a0,s2
ffffffffc020388a:	690a                	ld	s2,128(sp)
ffffffffc020388c:	610d                	addi	sp,sp,160
ffffffffc020388e:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203890:	000bb783          	ld	a5,0(s7)
ffffffffc0203894:	00004517          	auipc	a0,0x4
ffffffffc0203898:	45c50513          	addi	a0,a0,1116 # ffffffffc0207cf0 <commands+0x1428>
ffffffffc020389c:	000ab417          	auipc	s0,0xab
ffffffffc02038a0:	f3440413          	addi	s0,s0,-204 # ffffffffc02ae7d0 <free_area>
ffffffffc02038a4:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02038a6:	4785                	li	a5,1
ffffffffc02038a8:	000af717          	auipc	a4,0xaf
ffffffffc02038ac:	fcf72023          	sw	a5,-64(a4) # ffffffffc02b2868 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02038b0:	81dfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02038b4:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02038b6:	4d01                	li	s10,0
ffffffffc02038b8:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02038ba:	34878163          	beq	a5,s0,ffffffffc0203bfc <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02038be:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02038c2:	8b09                	andi	a4,a4,2
ffffffffc02038c4:	32070e63          	beqz	a4,ffffffffc0203c00 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc02038c8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02038cc:	679c                	ld	a5,8(a5)
ffffffffc02038ce:	2d85                	addiw	s11,s11,1
ffffffffc02038d0:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc02038d4:	fe8795e3          	bne	a5,s0,ffffffffc02038be <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02038d8:	84ea                	mv	s1,s10
ffffffffc02038da:	e9afd0ef          	jal	ra,ffffffffc0200f74 <nr_free_pages>
ffffffffc02038de:	42951763          	bne	a0,s1,ffffffffc0203d0c <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02038e2:	866a                	mv	a2,s10
ffffffffc02038e4:	85ee                	mv	a1,s11
ffffffffc02038e6:	00004517          	auipc	a0,0x4
ffffffffc02038ea:	45250513          	addi	a0,a0,1106 # ffffffffc0207d38 <commands+0x1470>
ffffffffc02038ee:	fdefc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02038f2:	8e8ff0ef          	jal	ra,ffffffffc02029da <mm_create>
ffffffffc02038f6:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02038f8:	46050a63          	beqz	a0,ffffffffc0203d6c <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02038fc:	000af797          	auipc	a5,0xaf
ffffffffc0203900:	f4478793          	addi	a5,a5,-188 # ffffffffc02b2840 <check_mm_struct>
ffffffffc0203904:	6398                	ld	a4,0(a5)
ffffffffc0203906:	3e071363          	bnez	a4,ffffffffc0203cec <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020390a:	000af717          	auipc	a4,0xaf
ffffffffc020390e:	f0e70713          	addi	a4,a4,-242 # ffffffffc02b2818 <boot_pgdir>
ffffffffc0203912:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0203916:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0203918:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020391c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203920:	42079663          	bnez	a5,ffffffffc0203d4c <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203924:	6599                	lui	a1,0x6
ffffffffc0203926:	460d                	li	a2,3
ffffffffc0203928:	6505                	lui	a0,0x1
ffffffffc020392a:	8f8ff0ef          	jal	ra,ffffffffc0202a22 <vma_create>
ffffffffc020392e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203930:	52050a63          	beqz	a0,ffffffffc0203e64 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc0203934:	8556                	mv	a0,s5
ffffffffc0203936:	95aff0ef          	jal	ra,ffffffffc0202a90 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020393a:	00004517          	auipc	a0,0x4
ffffffffc020393e:	43e50513          	addi	a0,a0,1086 # ffffffffc0207d78 <commands+0x14b0>
ffffffffc0203942:	f8afc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203946:	018ab503          	ld	a0,24(s5)
ffffffffc020394a:	4605                	li	a2,1
ffffffffc020394c:	6585                	lui	a1,0x1
ffffffffc020394e:	e60fd0ef          	jal	ra,ffffffffc0200fae <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203952:	4c050963          	beqz	a0,ffffffffc0203e24 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203956:	00004517          	auipc	a0,0x4
ffffffffc020395a:	47250513          	addi	a0,a0,1138 # ffffffffc0207dc8 <commands+0x1500>
ffffffffc020395e:	000ab497          	auipc	s1,0xab
ffffffffc0203962:	e0248493          	addi	s1,s1,-510 # ffffffffc02ae760 <check_rp>
ffffffffc0203966:	f66fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020396a:	000ab997          	auipc	s3,0xab
ffffffffc020396e:	e1698993          	addi	s3,s3,-490 # ffffffffc02ae780 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203972:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0203974:	4505                	li	a0,1
ffffffffc0203976:	d2cfd0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc020397a:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
          assert(check_rp[i] != NULL );
ffffffffc020397e:	2c050f63          	beqz	a0,ffffffffc0203c5c <swap_init+0x43e>
ffffffffc0203982:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203984:	8b89                	andi	a5,a5,2
ffffffffc0203986:	34079363          	bnez	a5,ffffffffc0203ccc <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020398a:	0a21                	addi	s4,s4,8
ffffffffc020398c:	ff3a14e3          	bne	s4,s3,ffffffffc0203974 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203990:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203992:	000aba17          	auipc	s4,0xab
ffffffffc0203996:	dcea0a13          	addi	s4,s4,-562 # ffffffffc02ae760 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc020399a:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc020399c:	ec3e                	sd	a5,24(sp)
ffffffffc020399e:	641c                	ld	a5,8(s0)
ffffffffc02039a0:	e400                	sd	s0,8(s0)
ffffffffc02039a2:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02039a4:	481c                	lw	a5,16(s0)
ffffffffc02039a6:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02039a8:	000ab797          	auipc	a5,0xab
ffffffffc02039ac:	e207ac23          	sw	zero,-456(a5) # ffffffffc02ae7e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02039b0:	000a3503          	ld	a0,0(s4)
ffffffffc02039b4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02039b6:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc02039b8:	d7cfd0ef          	jal	ra,ffffffffc0200f34 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02039bc:	ff3a1ae3          	bne	s4,s3,ffffffffc02039b0 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02039c0:	01042a03          	lw	s4,16(s0)
ffffffffc02039c4:	4791                	li	a5,4
ffffffffc02039c6:	42fa1f63          	bne	s4,a5,ffffffffc0203e04 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02039ca:	00004517          	auipc	a0,0x4
ffffffffc02039ce:	48650513          	addi	a0,a0,1158 # ffffffffc0207e50 <commands+0x1588>
ffffffffc02039d2:	efafc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02039d6:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02039d8:	000af797          	auipc	a5,0xaf
ffffffffc02039dc:	e607a823          	sw	zero,-400(a5) # ffffffffc02b2848 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02039e0:	4629                	li	a2,10
ffffffffc02039e2:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
     assert(pgfault_num==1);
ffffffffc02039e6:	000af697          	auipc	a3,0xaf
ffffffffc02039ea:	e626a683          	lw	a3,-414(a3) # ffffffffc02b2848 <pgfault_num>
ffffffffc02039ee:	4585                	li	a1,1
ffffffffc02039f0:	000af797          	auipc	a5,0xaf
ffffffffc02039f4:	e5878793          	addi	a5,a5,-424 # ffffffffc02b2848 <pgfault_num>
ffffffffc02039f8:	54b69663          	bne	a3,a1,ffffffffc0203f44 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02039fc:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0203a00:	4398                	lw	a4,0(a5)
ffffffffc0203a02:	2701                	sext.w	a4,a4
ffffffffc0203a04:	3ed71063          	bne	a4,a3,ffffffffc0203de4 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203a08:	6689                	lui	a3,0x2
ffffffffc0203a0a:	462d                	li	a2,11
ffffffffc0203a0c:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb8>
     assert(pgfault_num==2);
ffffffffc0203a10:	4398                	lw	a4,0(a5)
ffffffffc0203a12:	4589                	li	a1,2
ffffffffc0203a14:	2701                	sext.w	a4,a4
ffffffffc0203a16:	4ab71763          	bne	a4,a1,ffffffffc0203ec4 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203a1a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0203a1e:	4394                	lw	a3,0(a5)
ffffffffc0203a20:	2681                	sext.w	a3,a3
ffffffffc0203a22:	4ce69163          	bne	a3,a4,ffffffffc0203ee4 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203a26:	668d                	lui	a3,0x3
ffffffffc0203a28:	4631                	li	a2,12
ffffffffc0203a2a:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb8>
     assert(pgfault_num==3);
ffffffffc0203a2e:	4398                	lw	a4,0(a5)
ffffffffc0203a30:	458d                	li	a1,3
ffffffffc0203a32:	2701                	sext.w	a4,a4
ffffffffc0203a34:	4cb71863          	bne	a4,a1,ffffffffc0203f04 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203a38:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203a3c:	4394                	lw	a3,0(a5)
ffffffffc0203a3e:	2681                	sext.w	a3,a3
ffffffffc0203a40:	4ee69263          	bne	a3,a4,ffffffffc0203f24 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203a44:	6691                	lui	a3,0x4
ffffffffc0203a46:	4635                	li	a2,13
ffffffffc0203a48:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb8>
     assert(pgfault_num==4);
ffffffffc0203a4c:	4398                	lw	a4,0(a5)
ffffffffc0203a4e:	2701                	sext.w	a4,a4
ffffffffc0203a50:	43471a63          	bne	a4,s4,ffffffffc0203e84 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203a54:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203a58:	439c                	lw	a5,0(a5)
ffffffffc0203a5a:	2781                	sext.w	a5,a5
ffffffffc0203a5c:	44e79463          	bne	a5,a4,ffffffffc0203ea4 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203a60:	481c                	lw	a5,16(s0)
ffffffffc0203a62:	2c079563          	bnez	a5,ffffffffc0203d2c <swap_init+0x50e>
ffffffffc0203a66:	000ab797          	auipc	a5,0xab
ffffffffc0203a6a:	d1a78793          	addi	a5,a5,-742 # ffffffffc02ae780 <swap_in_seq_no>
ffffffffc0203a6e:	000ab717          	auipc	a4,0xab
ffffffffc0203a72:	d3a70713          	addi	a4,a4,-710 # ffffffffc02ae7a8 <swap_out_seq_no>
ffffffffc0203a76:	000ab617          	auipc	a2,0xab
ffffffffc0203a7a:	d3260613          	addi	a2,a2,-718 # ffffffffc02ae7a8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203a7e:	56fd                	li	a3,-1
ffffffffc0203a80:	c394                	sw	a3,0(a5)
ffffffffc0203a82:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203a84:	0791                	addi	a5,a5,4
ffffffffc0203a86:	0711                	addi	a4,a4,4
ffffffffc0203a88:	fec79ce3          	bne	a5,a2,ffffffffc0203a80 <swap_init+0x262>
ffffffffc0203a8c:	000ab717          	auipc	a4,0xab
ffffffffc0203a90:	cb470713          	addi	a4,a4,-844 # ffffffffc02ae740 <check_ptep>
ffffffffc0203a94:	000ab697          	auipc	a3,0xab
ffffffffc0203a98:	ccc68693          	addi	a3,a3,-820 # ffffffffc02ae760 <check_rp>
ffffffffc0203a9c:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203a9e:	000afc17          	auipc	s8,0xaf
ffffffffc0203aa2:	d82c0c13          	addi	s8,s8,-638 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203aa6:	000afc97          	auipc	s9,0xaf
ffffffffc0203aaa:	d82c8c93          	addi	s9,s9,-638 # ffffffffc02b2828 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203aae:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203ab2:	4601                	li	a2,0
ffffffffc0203ab4:	855a                	mv	a0,s6
ffffffffc0203ab6:	e836                	sd	a3,16(sp)
ffffffffc0203ab8:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0203aba:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203abc:	cf2fd0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc0203ac0:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203ac2:	65a2                	ld	a1,8(sp)
ffffffffc0203ac4:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203ac6:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203ac8:	1c050663          	beqz	a0,ffffffffc0203c94 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203acc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203ace:	0017f613          	andi	a2,a5,1
ffffffffc0203ad2:	1e060163          	beqz	a2,ffffffffc0203cb4 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203ad6:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203ada:	078a                	slli	a5,a5,0x2
ffffffffc0203adc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203ade:	14c7f363          	bgeu	a5,a2,ffffffffc0203c24 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ae2:	00005617          	auipc	a2,0x5
ffffffffc0203ae6:	28e60613          	addi	a2,a2,654 # ffffffffc0208d70 <nbase>
ffffffffc0203aea:	00063a03          	ld	s4,0(a2)
ffffffffc0203aee:	000cb603          	ld	a2,0(s9)
ffffffffc0203af2:	6288                	ld	a0,0(a3)
ffffffffc0203af4:	414787b3          	sub	a5,a5,s4
ffffffffc0203af8:	079a                	slli	a5,a5,0x6
ffffffffc0203afa:	97b2                	add	a5,a5,a2
ffffffffc0203afc:	14f51063          	bne	a0,a5,ffffffffc0203c3c <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203b00:	6785                	lui	a5,0x1
ffffffffc0203b02:	95be                	add	a1,a1,a5
ffffffffc0203b04:	6795                	lui	a5,0x5
ffffffffc0203b06:	0721                	addi	a4,a4,8
ffffffffc0203b08:	06a1                	addi	a3,a3,8
ffffffffc0203b0a:	faf592e3          	bne	a1,a5,ffffffffc0203aae <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203b0e:	00004517          	auipc	a0,0x4
ffffffffc0203b12:	3ea50513          	addi	a0,a0,1002 # ffffffffc0207ef8 <commands+0x1630>
ffffffffc0203b16:	db6fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0203b1a:	000bb783          	ld	a5,0(s7)
ffffffffc0203b1e:	7f9c                	ld	a5,56(a5)
ffffffffc0203b20:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203b22:	32051163          	bnez	a0,ffffffffc0203e44 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0203b26:	77a2                	ld	a5,40(sp)
ffffffffc0203b28:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203b2a:	67e2                	ld	a5,24(sp)
ffffffffc0203b2c:	e01c                	sd	a5,0(s0)
ffffffffc0203b2e:	7782                	ld	a5,32(sp)
ffffffffc0203b30:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203b32:	6088                	ld	a0,0(s1)
ffffffffc0203b34:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203b36:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0203b38:	bfcfd0ef          	jal	ra,ffffffffc0200f34 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203b3c:	ff349be3          	bne	s1,s3,ffffffffc0203b32 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203b40:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0203b44:	8556                	mv	a0,s5
ffffffffc0203b46:	81aff0ef          	jal	ra,ffffffffc0202b60 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203b4a:	000af797          	auipc	a5,0xaf
ffffffffc0203b4e:	cce78793          	addi	a5,a5,-818 # ffffffffc02b2818 <boot_pgdir>
ffffffffc0203b52:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203b54:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203b58:	000af697          	auipc	a3,0xaf
ffffffffc0203b5c:	ce06b423          	sd	zero,-792(a3) # ffffffffc02b2840 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b60:	639c                	ld	a5,0(a5)
ffffffffc0203b62:	078a                	slli	a5,a5,0x2
ffffffffc0203b64:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b66:	0ae7fd63          	bgeu	a5,a4,ffffffffc0203c20 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b6a:	414786b3          	sub	a3,a5,s4
ffffffffc0203b6e:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203b70:	8699                	srai	a3,a3,0x6
ffffffffc0203b72:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203b74:	00c69793          	slli	a5,a3,0xc
ffffffffc0203b78:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203b7a:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b7e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203b80:	22e7f663          	bgeu	a5,a4,ffffffffc0203dac <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0203b84:	000af797          	auipc	a5,0xaf
ffffffffc0203b88:	cb47b783          	ld	a5,-844(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0203b8c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b8e:	629c                	ld	a5,0(a3)
ffffffffc0203b90:	078a                	slli	a5,a5,0x2
ffffffffc0203b92:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b94:	08e7f663          	bgeu	a5,a4,ffffffffc0203c20 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b98:	414787b3          	sub	a5,a5,s4
ffffffffc0203b9c:	079a                	slli	a5,a5,0x6
ffffffffc0203b9e:	953e                	add	a0,a0,a5
ffffffffc0203ba0:	4585                	li	a1,1
ffffffffc0203ba2:	b92fd0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ba6:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203baa:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203bae:	078a                	slli	a5,a5,0x2
ffffffffc0203bb0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203bb2:	06e7f763          	bgeu	a5,a4,ffffffffc0203c20 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203bb6:	000cb503          	ld	a0,0(s9)
ffffffffc0203bba:	414787b3          	sub	a5,a5,s4
ffffffffc0203bbe:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203bc0:	4585                	li	a1,1
ffffffffc0203bc2:	953e                	add	a0,a0,a5
ffffffffc0203bc4:	b70fd0ef          	jal	ra,ffffffffc0200f34 <free_pages>
     pgdir[0] = 0;
ffffffffc0203bc8:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203bcc:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203bd0:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203bd2:	00878a63          	beq	a5,s0,ffffffffc0203be6 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203bd6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203bda:	679c                	ld	a5,8(a5)
ffffffffc0203bdc:	3dfd                	addiw	s11,s11,-1
ffffffffc0203bde:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203be2:	fe879ae3          	bne	a5,s0,ffffffffc0203bd6 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203be6:	1c0d9f63          	bnez	s11,ffffffffc0203dc4 <swap_init+0x5a6>
     assert(total==0);
ffffffffc0203bea:	1a0d1163          	bnez	s10,ffffffffc0203d8c <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203bee:	00004517          	auipc	a0,0x4
ffffffffc0203bf2:	35a50513          	addi	a0,a0,858 # ffffffffc0207f48 <commands+0x1680>
ffffffffc0203bf6:	cd6fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0203bfa:	b99d                	j	ffffffffc0203870 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203bfc:	4481                	li	s1,0
ffffffffc0203bfe:	b9f1                	j	ffffffffc02038da <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0203c00:	00004697          	auipc	a3,0x4
ffffffffc0203c04:	10868693          	addi	a3,a3,264 # ffffffffc0207d08 <commands+0x1440>
ffffffffc0203c08:	00003617          	auipc	a2,0x3
ffffffffc0203c0c:	0d060613          	addi	a2,a2,208 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203c10:	0bc00593          	li	a1,188
ffffffffc0203c14:	00004517          	auipc	a0,0x4
ffffffffc0203c18:	0cc50513          	addi	a0,a0,204 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203c1c:	decfc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203c20:	be3ff0ef          	jal	ra,ffffffffc0203802 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203c24:	00003617          	auipc	a2,0x3
ffffffffc0203c28:	41c60613          	addi	a2,a2,1052 # ffffffffc0207040 <commands+0x778>
ffffffffc0203c2c:	06200593          	li	a1,98
ffffffffc0203c30:	00003517          	auipc	a0,0x3
ffffffffc0203c34:	43050513          	addi	a0,a0,1072 # ffffffffc0207060 <commands+0x798>
ffffffffc0203c38:	dd0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203c3c:	00004697          	auipc	a3,0x4
ffffffffc0203c40:	29468693          	addi	a3,a3,660 # ffffffffc0207ed0 <commands+0x1608>
ffffffffc0203c44:	00003617          	auipc	a2,0x3
ffffffffc0203c48:	09460613          	addi	a2,a2,148 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203c4c:	0fc00593          	li	a1,252
ffffffffc0203c50:	00004517          	auipc	a0,0x4
ffffffffc0203c54:	09050513          	addi	a0,a0,144 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203c58:	db0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203c5c:	00004697          	auipc	a3,0x4
ffffffffc0203c60:	19468693          	addi	a3,a3,404 # ffffffffc0207df0 <commands+0x1528>
ffffffffc0203c64:	00003617          	auipc	a2,0x3
ffffffffc0203c68:	07460613          	addi	a2,a2,116 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203c6c:	0dc00593          	li	a1,220
ffffffffc0203c70:	00004517          	auipc	a0,0x4
ffffffffc0203c74:	07050513          	addi	a0,a0,112 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203c78:	d90fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203c7c:	00004617          	auipc	a2,0x4
ffffffffc0203c80:	04460613          	addi	a2,a2,68 # ffffffffc0207cc0 <commands+0x13f8>
ffffffffc0203c84:	02800593          	li	a1,40
ffffffffc0203c88:	00004517          	auipc	a0,0x4
ffffffffc0203c8c:	05850513          	addi	a0,a0,88 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203c90:	d78fc0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203c94:	00004697          	auipc	a3,0x4
ffffffffc0203c98:	22468693          	addi	a3,a3,548 # ffffffffc0207eb8 <commands+0x15f0>
ffffffffc0203c9c:	00003617          	auipc	a2,0x3
ffffffffc0203ca0:	03c60613          	addi	a2,a2,60 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203ca4:	0fb00593          	li	a1,251
ffffffffc0203ca8:	00004517          	auipc	a0,0x4
ffffffffc0203cac:	03850513          	addi	a0,a0,56 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203cb0:	d58fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203cb4:	00003617          	auipc	a2,0x3
ffffffffc0203cb8:	3bc60613          	addi	a2,a2,956 # ffffffffc0207070 <commands+0x7a8>
ffffffffc0203cbc:	07400593          	li	a1,116
ffffffffc0203cc0:	00003517          	auipc	a0,0x3
ffffffffc0203cc4:	3a050513          	addi	a0,a0,928 # ffffffffc0207060 <commands+0x798>
ffffffffc0203cc8:	d40fc0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203ccc:	00004697          	auipc	a3,0x4
ffffffffc0203cd0:	13c68693          	addi	a3,a3,316 # ffffffffc0207e08 <commands+0x1540>
ffffffffc0203cd4:	00003617          	auipc	a2,0x3
ffffffffc0203cd8:	00460613          	addi	a2,a2,4 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203cdc:	0dd00593          	li	a1,221
ffffffffc0203ce0:	00004517          	auipc	a0,0x4
ffffffffc0203ce4:	00050513          	mv	a0,a0
ffffffffc0203ce8:	d20fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203cec:	00004697          	auipc	a3,0x4
ffffffffc0203cf0:	07468693          	addi	a3,a3,116 # ffffffffc0207d60 <commands+0x1498>
ffffffffc0203cf4:	00003617          	auipc	a2,0x3
ffffffffc0203cf8:	fe460613          	addi	a2,a2,-28 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203cfc:	0c700593          	li	a1,199
ffffffffc0203d00:	00004517          	auipc	a0,0x4
ffffffffc0203d04:	fe050513          	addi	a0,a0,-32 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203d08:	d00fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203d0c:	00004697          	auipc	a3,0x4
ffffffffc0203d10:	00c68693          	addi	a3,a3,12 # ffffffffc0207d18 <commands+0x1450>
ffffffffc0203d14:	00003617          	auipc	a2,0x3
ffffffffc0203d18:	fc460613          	addi	a2,a2,-60 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203d1c:	0bf00593          	li	a1,191
ffffffffc0203d20:	00004517          	auipc	a0,0x4
ffffffffc0203d24:	fc050513          	addi	a0,a0,-64 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203d28:	ce0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc0203d2c:	00004697          	auipc	a3,0x4
ffffffffc0203d30:	17c68693          	addi	a3,a3,380 # ffffffffc0207ea8 <commands+0x15e0>
ffffffffc0203d34:	00003617          	auipc	a2,0x3
ffffffffc0203d38:	fa460613          	addi	a2,a2,-92 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203d3c:	0f300593          	li	a1,243
ffffffffc0203d40:	00004517          	auipc	a0,0x4
ffffffffc0203d44:	fa050513          	addi	a0,a0,-96 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203d48:	cc0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203d4c:	00004697          	auipc	a3,0x4
ffffffffc0203d50:	db468693          	addi	a3,a3,-588 # ffffffffc0207b00 <commands+0x1238>
ffffffffc0203d54:	00003617          	auipc	a2,0x3
ffffffffc0203d58:	f8460613          	addi	a2,a2,-124 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203d5c:	0cc00593          	li	a1,204
ffffffffc0203d60:	00004517          	auipc	a0,0x4
ffffffffc0203d64:	f8050513          	addi	a0,a0,-128 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203d68:	ca0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc0203d6c:	00004697          	auipc	a3,0x4
ffffffffc0203d70:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0207938 <commands+0x1070>
ffffffffc0203d74:	00003617          	auipc	a2,0x3
ffffffffc0203d78:	f6460613          	addi	a2,a2,-156 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203d7c:	0c400593          	li	a1,196
ffffffffc0203d80:	00004517          	auipc	a0,0x4
ffffffffc0203d84:	f6050513          	addi	a0,a0,-160 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203d88:	c80fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc0203d8c:	00004697          	auipc	a3,0x4
ffffffffc0203d90:	1ac68693          	addi	a3,a3,428 # ffffffffc0207f38 <commands+0x1670>
ffffffffc0203d94:	00003617          	auipc	a2,0x3
ffffffffc0203d98:	f4460613          	addi	a2,a2,-188 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203d9c:	11e00593          	li	a1,286
ffffffffc0203da0:	00004517          	auipc	a0,0x4
ffffffffc0203da4:	f4050513          	addi	a0,a0,-192 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203da8:	c60fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203dac:	00003617          	auipc	a2,0x3
ffffffffc0203db0:	2ec60613          	addi	a2,a2,748 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0203db4:	06900593          	li	a1,105
ffffffffc0203db8:	00003517          	auipc	a0,0x3
ffffffffc0203dbc:	2a850513          	addi	a0,a0,680 # ffffffffc0207060 <commands+0x798>
ffffffffc0203dc0:	c48fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc0203dc4:	00004697          	auipc	a3,0x4
ffffffffc0203dc8:	16468693          	addi	a3,a3,356 # ffffffffc0207f28 <commands+0x1660>
ffffffffc0203dcc:	00003617          	auipc	a2,0x3
ffffffffc0203dd0:	f0c60613          	addi	a2,a2,-244 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203dd4:	11d00593          	li	a1,285
ffffffffc0203dd8:	00004517          	auipc	a0,0x4
ffffffffc0203ddc:	f0850513          	addi	a0,a0,-248 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203de0:	c28fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0203de4:	00004697          	auipc	a3,0x4
ffffffffc0203de8:	09468693          	addi	a3,a3,148 # ffffffffc0207e78 <commands+0x15b0>
ffffffffc0203dec:	00003617          	auipc	a2,0x3
ffffffffc0203df0:	eec60613          	addi	a2,a2,-276 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203df4:	09500593          	li	a1,149
ffffffffc0203df8:	00004517          	auipc	a0,0x4
ffffffffc0203dfc:	ee850513          	addi	a0,a0,-280 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203e00:	c08fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203e04:	00004697          	auipc	a3,0x4
ffffffffc0203e08:	02468693          	addi	a3,a3,36 # ffffffffc0207e28 <commands+0x1560>
ffffffffc0203e0c:	00003617          	auipc	a2,0x3
ffffffffc0203e10:	ecc60613          	addi	a2,a2,-308 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203e14:	0ea00593          	li	a1,234
ffffffffc0203e18:	00004517          	auipc	a0,0x4
ffffffffc0203e1c:	ec850513          	addi	a0,a0,-312 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203e20:	be8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203e24:	00004697          	auipc	a3,0x4
ffffffffc0203e28:	f8c68693          	addi	a3,a3,-116 # ffffffffc0207db0 <commands+0x14e8>
ffffffffc0203e2c:	00003617          	auipc	a2,0x3
ffffffffc0203e30:	eac60613          	addi	a2,a2,-340 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203e34:	0d700593          	li	a1,215
ffffffffc0203e38:	00004517          	auipc	a0,0x4
ffffffffc0203e3c:	ea850513          	addi	a0,a0,-344 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203e40:	bc8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc0203e44:	00004697          	auipc	a3,0x4
ffffffffc0203e48:	0dc68693          	addi	a3,a3,220 # ffffffffc0207f20 <commands+0x1658>
ffffffffc0203e4c:	00003617          	auipc	a2,0x3
ffffffffc0203e50:	e8c60613          	addi	a2,a2,-372 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203e54:	10200593          	li	a1,258
ffffffffc0203e58:	00004517          	auipc	a0,0x4
ffffffffc0203e5c:	e8850513          	addi	a0,a0,-376 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203e60:	ba8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc0203e64:	00004697          	auipc	a3,0x4
ffffffffc0203e68:	d3c68693          	addi	a3,a3,-708 # ffffffffc0207ba0 <commands+0x12d8>
ffffffffc0203e6c:	00003617          	auipc	a2,0x3
ffffffffc0203e70:	e6c60613          	addi	a2,a2,-404 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203e74:	0cf00593          	li	a1,207
ffffffffc0203e78:	00004517          	auipc	a0,0x4
ffffffffc0203e7c:	e6850513          	addi	a0,a0,-408 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203e80:	b88fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0203e84:	00004697          	auipc	a3,0x4
ffffffffc0203e88:	85468693          	addi	a3,a3,-1964 # ffffffffc02076d8 <commands+0xe10>
ffffffffc0203e8c:	00003617          	auipc	a2,0x3
ffffffffc0203e90:	e4c60613          	addi	a2,a2,-436 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203e94:	09f00593          	li	a1,159
ffffffffc0203e98:	00004517          	auipc	a0,0x4
ffffffffc0203e9c:	e4850513          	addi	a0,a0,-440 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203ea0:	b68fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0203ea4:	00004697          	auipc	a3,0x4
ffffffffc0203ea8:	83468693          	addi	a3,a3,-1996 # ffffffffc02076d8 <commands+0xe10>
ffffffffc0203eac:	00003617          	auipc	a2,0x3
ffffffffc0203eb0:	e2c60613          	addi	a2,a2,-468 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203eb4:	0a100593          	li	a1,161
ffffffffc0203eb8:	00004517          	auipc	a0,0x4
ffffffffc0203ebc:	e2850513          	addi	a0,a0,-472 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203ec0:	b48fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0203ec4:	00004697          	auipc	a3,0x4
ffffffffc0203ec8:	fc468693          	addi	a3,a3,-60 # ffffffffc0207e88 <commands+0x15c0>
ffffffffc0203ecc:	00003617          	auipc	a2,0x3
ffffffffc0203ed0:	e0c60613          	addi	a2,a2,-500 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203ed4:	09700593          	li	a1,151
ffffffffc0203ed8:	00004517          	auipc	a0,0x4
ffffffffc0203edc:	e0850513          	addi	a0,a0,-504 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203ee0:	b28fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0203ee4:	00004697          	auipc	a3,0x4
ffffffffc0203ee8:	fa468693          	addi	a3,a3,-92 # ffffffffc0207e88 <commands+0x15c0>
ffffffffc0203eec:	00003617          	auipc	a2,0x3
ffffffffc0203ef0:	dec60613          	addi	a2,a2,-532 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203ef4:	09900593          	li	a1,153
ffffffffc0203ef8:	00004517          	auipc	a0,0x4
ffffffffc0203efc:	de850513          	addi	a0,a0,-536 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203f00:	b08fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0203f04:	00004697          	auipc	a3,0x4
ffffffffc0203f08:	f9468693          	addi	a3,a3,-108 # ffffffffc0207e98 <commands+0x15d0>
ffffffffc0203f0c:	00003617          	auipc	a2,0x3
ffffffffc0203f10:	dcc60613          	addi	a2,a2,-564 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203f14:	09b00593          	li	a1,155
ffffffffc0203f18:	00004517          	auipc	a0,0x4
ffffffffc0203f1c:	dc850513          	addi	a0,a0,-568 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203f20:	ae8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0203f24:	00004697          	auipc	a3,0x4
ffffffffc0203f28:	f7468693          	addi	a3,a3,-140 # ffffffffc0207e98 <commands+0x15d0>
ffffffffc0203f2c:	00003617          	auipc	a2,0x3
ffffffffc0203f30:	dac60613          	addi	a2,a2,-596 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203f34:	09d00593          	li	a1,157
ffffffffc0203f38:	00004517          	auipc	a0,0x4
ffffffffc0203f3c:	da850513          	addi	a0,a0,-600 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203f40:	ac8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0203f44:	00004697          	auipc	a3,0x4
ffffffffc0203f48:	f3468693          	addi	a3,a3,-204 # ffffffffc0207e78 <commands+0x15b0>
ffffffffc0203f4c:	00003617          	auipc	a2,0x3
ffffffffc0203f50:	d8c60613          	addi	a2,a2,-628 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0203f54:	09300593          	li	a1,147
ffffffffc0203f58:	00004517          	auipc	a0,0x4
ffffffffc0203f5c:	d8850513          	addi	a0,a0,-632 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0203f60:	aa8fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203f64 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203f64:	000af797          	auipc	a5,0xaf
ffffffffc0203f68:	8fc7b783          	ld	a5,-1796(a5) # ffffffffc02b2860 <sm>
ffffffffc0203f6c:	6b9c                	ld	a5,16(a5)
ffffffffc0203f6e:	8782                	jr	a5

ffffffffc0203f70 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203f70:	000af797          	auipc	a5,0xaf
ffffffffc0203f74:	8f07b783          	ld	a5,-1808(a5) # ffffffffc02b2860 <sm>
ffffffffc0203f78:	739c                	ld	a5,32(a5)
ffffffffc0203f7a:	8782                	jr	a5

ffffffffc0203f7c <swap_out>:
{
ffffffffc0203f7c:	711d                	addi	sp,sp,-96
ffffffffc0203f7e:	ec86                	sd	ra,88(sp)
ffffffffc0203f80:	e8a2                	sd	s0,80(sp)
ffffffffc0203f82:	e4a6                	sd	s1,72(sp)
ffffffffc0203f84:	e0ca                	sd	s2,64(sp)
ffffffffc0203f86:	fc4e                	sd	s3,56(sp)
ffffffffc0203f88:	f852                	sd	s4,48(sp)
ffffffffc0203f8a:	f456                	sd	s5,40(sp)
ffffffffc0203f8c:	f05a                	sd	s6,32(sp)
ffffffffc0203f8e:	ec5e                	sd	s7,24(sp)
ffffffffc0203f90:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203f92:	cde9                	beqz	a1,ffffffffc020406c <swap_out+0xf0>
ffffffffc0203f94:	8a2e                	mv	s4,a1
ffffffffc0203f96:	892a                	mv	s2,a0
ffffffffc0203f98:	8ab2                	mv	s5,a2
ffffffffc0203f9a:	4401                	li	s0,0
ffffffffc0203f9c:	000af997          	auipc	s3,0xaf
ffffffffc0203fa0:	8c498993          	addi	s3,s3,-1852 # ffffffffc02b2860 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203fa4:	00004b17          	auipc	s6,0x4
ffffffffc0203fa8:	024b0b13          	addi	s6,s6,36 # ffffffffc0207fc8 <commands+0x1700>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203fac:	00004b97          	auipc	s7,0x4
ffffffffc0203fb0:	004b8b93          	addi	s7,s7,4 # ffffffffc0207fb0 <commands+0x16e8>
ffffffffc0203fb4:	a825                	j	ffffffffc0203fec <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203fb6:	67a2                	ld	a5,8(sp)
ffffffffc0203fb8:	8626                	mv	a2,s1
ffffffffc0203fba:	85a2                	mv	a1,s0
ffffffffc0203fbc:	7f94                	ld	a3,56(a5)
ffffffffc0203fbe:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203fc0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203fc2:	82b1                	srli	a3,a3,0xc
ffffffffc0203fc4:	0685                	addi	a3,a3,1
ffffffffc0203fc6:	906fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203fca:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203fcc:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203fce:	7d1c                	ld	a5,56(a0)
ffffffffc0203fd0:	83b1                	srli	a5,a5,0xc
ffffffffc0203fd2:	0785                	addi	a5,a5,1
ffffffffc0203fd4:	07a2                	slli	a5,a5,0x8
ffffffffc0203fd6:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203fda:	f5bfc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203fde:	01893503          	ld	a0,24(s2)
ffffffffc0203fe2:	85a6                	mv	a1,s1
ffffffffc0203fe4:	d24fe0ef          	jal	ra,ffffffffc0202508 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203fe8:	048a0d63          	beq	s4,s0,ffffffffc0204042 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203fec:	0009b783          	ld	a5,0(s3)
ffffffffc0203ff0:	8656                	mv	a2,s5
ffffffffc0203ff2:	002c                	addi	a1,sp,8
ffffffffc0203ff4:	7b9c                	ld	a5,48(a5)
ffffffffc0203ff6:	854a                	mv	a0,s2
ffffffffc0203ff8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203ffa:	e12d                	bnez	a0,ffffffffc020405c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203ffc:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ffe:	01893503          	ld	a0,24(s2)
ffffffffc0204002:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0204004:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0204006:	85a6                	mv	a1,s1
ffffffffc0204008:	fa7fc0ef          	jal	ra,ffffffffc0200fae <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020400c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020400e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0204010:	8b85                	andi	a5,a5,1
ffffffffc0204012:	cfb9                	beqz	a5,ffffffffc0204070 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0204014:	65a2                	ld	a1,8(sp)
ffffffffc0204016:	7d9c                	ld	a5,56(a1)
ffffffffc0204018:	83b1                	srli	a5,a5,0xc
ffffffffc020401a:	0785                	addi	a5,a5,1
ffffffffc020401c:	00879513          	slli	a0,a5,0x8
ffffffffc0204020:	45f000ef          	jal	ra,ffffffffc0204c7e <swapfs_write>
ffffffffc0204024:	d949                	beqz	a0,ffffffffc0203fb6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0204026:	855e                	mv	a0,s7
ffffffffc0204028:	8a4fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020402c:	0009b783          	ld	a5,0(s3)
ffffffffc0204030:	6622                	ld	a2,8(sp)
ffffffffc0204032:	4681                	li	a3,0
ffffffffc0204034:	739c                	ld	a5,32(a5)
ffffffffc0204036:	85a6                	mv	a1,s1
ffffffffc0204038:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020403a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020403c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020403e:	fa8a17e3          	bne	s4,s0,ffffffffc0203fec <swap_out+0x70>
}
ffffffffc0204042:	60e6                	ld	ra,88(sp)
ffffffffc0204044:	8522                	mv	a0,s0
ffffffffc0204046:	6446                	ld	s0,80(sp)
ffffffffc0204048:	64a6                	ld	s1,72(sp)
ffffffffc020404a:	6906                	ld	s2,64(sp)
ffffffffc020404c:	79e2                	ld	s3,56(sp)
ffffffffc020404e:	7a42                	ld	s4,48(sp)
ffffffffc0204050:	7aa2                	ld	s5,40(sp)
ffffffffc0204052:	7b02                	ld	s6,32(sp)
ffffffffc0204054:	6be2                	ld	s7,24(sp)
ffffffffc0204056:	6c42                	ld	s8,16(sp)
ffffffffc0204058:	6125                	addi	sp,sp,96
ffffffffc020405a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020405c:	85a2                	mv	a1,s0
ffffffffc020405e:	00004517          	auipc	a0,0x4
ffffffffc0204062:	f0a50513          	addi	a0,a0,-246 # ffffffffc0207f68 <commands+0x16a0>
ffffffffc0204066:	866fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc020406a:	bfe1                	j	ffffffffc0204042 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020406c:	4401                	li	s0,0
ffffffffc020406e:	bfd1                	j	ffffffffc0204042 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0204070:	00004697          	auipc	a3,0x4
ffffffffc0204074:	f2868693          	addi	a3,a3,-216 # ffffffffc0207f98 <commands+0x16d0>
ffffffffc0204078:	00003617          	auipc	a2,0x3
ffffffffc020407c:	c6060613          	addi	a2,a2,-928 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204080:	06800593          	li	a1,104
ffffffffc0204084:	00004517          	auipc	a0,0x4
ffffffffc0204088:	c5c50513          	addi	a0,a0,-932 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc020408c:	97cfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204090 <swap_in>:
{
ffffffffc0204090:	7179                	addi	sp,sp,-48
ffffffffc0204092:	e84a                	sd	s2,16(sp)
ffffffffc0204094:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0204096:	4505                	li	a0,1
{
ffffffffc0204098:	ec26                	sd	s1,24(sp)
ffffffffc020409a:	e44e                	sd	s3,8(sp)
ffffffffc020409c:	f406                	sd	ra,40(sp)
ffffffffc020409e:	f022                	sd	s0,32(sp)
ffffffffc02040a0:	84ae                	mv	s1,a1
ffffffffc02040a2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02040a4:	dfffc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
     assert(result!=NULL);
ffffffffc02040a8:	c129                	beqz	a0,ffffffffc02040ea <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02040aa:	842a                	mv	s0,a0
ffffffffc02040ac:	01893503          	ld	a0,24(s2)
ffffffffc02040b0:	4601                	li	a2,0
ffffffffc02040b2:	85a6                	mv	a1,s1
ffffffffc02040b4:	efbfc0ef          	jal	ra,ffffffffc0200fae <get_pte>
ffffffffc02040b8:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02040ba:	6108                	ld	a0,0(a0)
ffffffffc02040bc:	85a2                	mv	a1,s0
ffffffffc02040be:	333000ef          	jal	ra,ffffffffc0204bf0 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc02040c2:	00093583          	ld	a1,0(s2)
ffffffffc02040c6:	8626                	mv	a2,s1
ffffffffc02040c8:	00004517          	auipc	a0,0x4
ffffffffc02040cc:	f5050513          	addi	a0,a0,-176 # ffffffffc0208018 <commands+0x1750>
ffffffffc02040d0:	81a1                	srli	a1,a1,0x8
ffffffffc02040d2:	ffbfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02040d6:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02040d8:	0089b023          	sd	s0,0(s3)
}
ffffffffc02040dc:	7402                	ld	s0,32(sp)
ffffffffc02040de:	64e2                	ld	s1,24(sp)
ffffffffc02040e0:	6942                	ld	s2,16(sp)
ffffffffc02040e2:	69a2                	ld	s3,8(sp)
ffffffffc02040e4:	4501                	li	a0,0
ffffffffc02040e6:	6145                	addi	sp,sp,48
ffffffffc02040e8:	8082                	ret
     assert(result!=NULL);
ffffffffc02040ea:	00004697          	auipc	a3,0x4
ffffffffc02040ee:	f1e68693          	addi	a3,a3,-226 # ffffffffc0208008 <commands+0x1740>
ffffffffc02040f2:	00003617          	auipc	a2,0x3
ffffffffc02040f6:	be660613          	addi	a2,a2,-1050 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02040fa:	07e00593          	li	a1,126
ffffffffc02040fe:	00004517          	auipc	a0,0x4
ffffffffc0204102:	be250513          	addi	a0,a0,-1054 # ffffffffc0207ce0 <commands+0x1418>
ffffffffc0204106:	902fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020410a <default_init>:
    elm->prev = elm->next = elm;
ffffffffc020410a:	000aa797          	auipc	a5,0xaa
ffffffffc020410e:	6c678793          	addi	a5,a5,1734 # ffffffffc02ae7d0 <free_area>
ffffffffc0204112:	e79c                	sd	a5,8(a5)
ffffffffc0204114:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0204116:	0007a823          	sw	zero,16(a5)
}
ffffffffc020411a:	8082                	ret

ffffffffc020411c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020411c:	000aa517          	auipc	a0,0xaa
ffffffffc0204120:	6c456503          	lwu	a0,1732(a0) # ffffffffc02ae7e0 <free_area+0x10>
ffffffffc0204124:	8082                	ret

ffffffffc0204126 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0204126:	715d                	addi	sp,sp,-80
ffffffffc0204128:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc020412a:	000aa417          	auipc	s0,0xaa
ffffffffc020412e:	6a640413          	addi	s0,s0,1702 # ffffffffc02ae7d0 <free_area>
ffffffffc0204132:	641c                	ld	a5,8(s0)
ffffffffc0204134:	e486                	sd	ra,72(sp)
ffffffffc0204136:	fc26                	sd	s1,56(sp)
ffffffffc0204138:	f84a                	sd	s2,48(sp)
ffffffffc020413a:	f44e                	sd	s3,40(sp)
ffffffffc020413c:	f052                	sd	s4,32(sp)
ffffffffc020413e:	ec56                	sd	s5,24(sp)
ffffffffc0204140:	e85a                	sd	s6,16(sp)
ffffffffc0204142:	e45e                	sd	s7,8(sp)
ffffffffc0204144:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204146:	2a878d63          	beq	a5,s0,ffffffffc0204400 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc020414a:	4481                	li	s1,0
ffffffffc020414c:	4901                	li	s2,0
ffffffffc020414e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0204152:	8b09                	andi	a4,a4,2
ffffffffc0204154:	2a070a63          	beqz	a4,ffffffffc0204408 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0204158:	ff87a703          	lw	a4,-8(a5)
ffffffffc020415c:	679c                	ld	a5,8(a5)
ffffffffc020415e:	2905                	addiw	s2,s2,1
ffffffffc0204160:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204162:	fe8796e3          	bne	a5,s0,ffffffffc020414e <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0204166:	89a6                	mv	s3,s1
ffffffffc0204168:	e0dfc0ef          	jal	ra,ffffffffc0200f74 <nr_free_pages>
ffffffffc020416c:	6f351e63          	bne	a0,s3,ffffffffc0204868 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204170:	4505                	li	a0,1
ffffffffc0204172:	d31fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0204176:	8aaa                	mv	s5,a0
ffffffffc0204178:	42050863          	beqz	a0,ffffffffc02045a8 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020417c:	4505                	li	a0,1
ffffffffc020417e:	d25fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0204182:	89aa                	mv	s3,a0
ffffffffc0204184:	70050263          	beqz	a0,ffffffffc0204888 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204188:	4505                	li	a0,1
ffffffffc020418a:	d19fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc020418e:	8a2a                	mv	s4,a0
ffffffffc0204190:	48050c63          	beqz	a0,ffffffffc0204628 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0204194:	293a8a63          	beq	s5,s3,ffffffffc0204428 <default_check+0x302>
ffffffffc0204198:	28aa8863          	beq	s5,a0,ffffffffc0204428 <default_check+0x302>
ffffffffc020419c:	28a98663          	beq	s3,a0,ffffffffc0204428 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02041a0:	000aa783          	lw	a5,0(s5)
ffffffffc02041a4:	2a079263          	bnez	a5,ffffffffc0204448 <default_check+0x322>
ffffffffc02041a8:	0009a783          	lw	a5,0(s3)
ffffffffc02041ac:	28079e63          	bnez	a5,ffffffffc0204448 <default_check+0x322>
ffffffffc02041b0:	411c                	lw	a5,0(a0)
ffffffffc02041b2:	28079b63          	bnez	a5,ffffffffc0204448 <default_check+0x322>
    return page - pages + nbase;
ffffffffc02041b6:	000ae797          	auipc	a5,0xae
ffffffffc02041ba:	6727b783          	ld	a5,1650(a5) # ffffffffc02b2828 <pages>
ffffffffc02041be:	40fa8733          	sub	a4,s5,a5
ffffffffc02041c2:	00005617          	auipc	a2,0x5
ffffffffc02041c6:	bae63603          	ld	a2,-1106(a2) # ffffffffc0208d70 <nbase>
ffffffffc02041ca:	8719                	srai	a4,a4,0x6
ffffffffc02041cc:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02041ce:	000ae697          	auipc	a3,0xae
ffffffffc02041d2:	6526b683          	ld	a3,1618(a3) # ffffffffc02b2820 <npage>
ffffffffc02041d6:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02041d8:	0732                	slli	a4,a4,0xc
ffffffffc02041da:	28d77763          	bgeu	a4,a3,ffffffffc0204468 <default_check+0x342>
    return page - pages + nbase;
ffffffffc02041de:	40f98733          	sub	a4,s3,a5
ffffffffc02041e2:	8719                	srai	a4,a4,0x6
ffffffffc02041e4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02041e6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02041e8:	4cd77063          	bgeu	a4,a3,ffffffffc02046a8 <default_check+0x582>
    return page - pages + nbase;
ffffffffc02041ec:	40f507b3          	sub	a5,a0,a5
ffffffffc02041f0:	8799                	srai	a5,a5,0x6
ffffffffc02041f2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02041f4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02041f6:	30d7f963          	bgeu	a5,a3,ffffffffc0204508 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02041fa:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02041fc:	00043c03          	ld	s8,0(s0)
ffffffffc0204200:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0204204:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0204208:	e400                	sd	s0,8(s0)
ffffffffc020420a:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc020420c:	000aa797          	auipc	a5,0xaa
ffffffffc0204210:	5c07aa23          	sw	zero,1492(a5) # ffffffffc02ae7e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0204214:	c8ffc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0204218:	2c051863          	bnez	a0,ffffffffc02044e8 <default_check+0x3c2>
    free_page(p0);
ffffffffc020421c:	4585                	li	a1,1
ffffffffc020421e:	8556                	mv	a0,s5
ffffffffc0204220:	d15fc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    free_page(p1);
ffffffffc0204224:	4585                	li	a1,1
ffffffffc0204226:	854e                	mv	a0,s3
ffffffffc0204228:	d0dfc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    free_page(p2);
ffffffffc020422c:	4585                	li	a1,1
ffffffffc020422e:	8552                	mv	a0,s4
ffffffffc0204230:	d05fc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    assert(nr_free == 3);
ffffffffc0204234:	4818                	lw	a4,16(s0)
ffffffffc0204236:	478d                	li	a5,3
ffffffffc0204238:	28f71863          	bne	a4,a5,ffffffffc02044c8 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020423c:	4505                	li	a0,1
ffffffffc020423e:	c65fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0204242:	89aa                	mv	s3,a0
ffffffffc0204244:	26050263          	beqz	a0,ffffffffc02044a8 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204248:	4505                	li	a0,1
ffffffffc020424a:	c59fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc020424e:	8aaa                	mv	s5,a0
ffffffffc0204250:	3a050c63          	beqz	a0,ffffffffc0204608 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204254:	4505                	li	a0,1
ffffffffc0204256:	c4dfc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc020425a:	8a2a                	mv	s4,a0
ffffffffc020425c:	38050663          	beqz	a0,ffffffffc02045e8 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0204260:	4505                	li	a0,1
ffffffffc0204262:	c41fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0204266:	36051163          	bnez	a0,ffffffffc02045c8 <default_check+0x4a2>
    free_page(p0);
ffffffffc020426a:	4585                	li	a1,1
ffffffffc020426c:	854e                	mv	a0,s3
ffffffffc020426e:	cc7fc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0204272:	641c                	ld	a5,8(s0)
ffffffffc0204274:	20878a63          	beq	a5,s0,ffffffffc0204488 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0204278:	4505                	li	a0,1
ffffffffc020427a:	c29fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc020427e:	30a99563          	bne	s3,a0,ffffffffc0204588 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0204282:	4505                	li	a0,1
ffffffffc0204284:	c1ffc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0204288:	2e051063          	bnez	a0,ffffffffc0204568 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc020428c:	481c                	lw	a5,16(s0)
ffffffffc020428e:	2a079d63          	bnez	a5,ffffffffc0204548 <default_check+0x422>
    free_page(p);
ffffffffc0204292:	854e                	mv	a0,s3
ffffffffc0204294:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0204296:	01843023          	sd	s8,0(s0)
ffffffffc020429a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020429e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02042a2:	c93fc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    free_page(p1);
ffffffffc02042a6:	4585                	li	a1,1
ffffffffc02042a8:	8556                	mv	a0,s5
ffffffffc02042aa:	c8bfc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    free_page(p2);
ffffffffc02042ae:	4585                	li	a1,1
ffffffffc02042b0:	8552                	mv	a0,s4
ffffffffc02042b2:	c83fc0ef          	jal	ra,ffffffffc0200f34 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02042b6:	4515                	li	a0,5
ffffffffc02042b8:	bebfc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc02042bc:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02042be:	26050563          	beqz	a0,ffffffffc0204528 <default_check+0x402>
ffffffffc02042c2:	651c                	ld	a5,8(a0)
ffffffffc02042c4:	8385                	srli	a5,a5,0x1
ffffffffc02042c6:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02042c8:	54079063          	bnez	a5,ffffffffc0204808 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02042cc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02042ce:	00043b03          	ld	s6,0(s0)
ffffffffc02042d2:	00843a83          	ld	s5,8(s0)
ffffffffc02042d6:	e000                	sd	s0,0(s0)
ffffffffc02042d8:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02042da:	bc9fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc02042de:	50051563          	bnez	a0,ffffffffc02047e8 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02042e2:	08098a13          	addi	s4,s3,128
ffffffffc02042e6:	8552                	mv	a0,s4
ffffffffc02042e8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02042ea:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02042ee:	000aa797          	auipc	a5,0xaa
ffffffffc02042f2:	4e07a923          	sw	zero,1266(a5) # ffffffffc02ae7e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02042f6:	c3ffc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02042fa:	4511                	li	a0,4
ffffffffc02042fc:	ba7fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0204300:	4c051463          	bnez	a0,ffffffffc02047c8 <default_check+0x6a2>
ffffffffc0204304:	0889b783          	ld	a5,136(s3)
ffffffffc0204308:	8385                	srli	a5,a5,0x1
ffffffffc020430a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020430c:	48078e63          	beqz	a5,ffffffffc02047a8 <default_check+0x682>
ffffffffc0204310:	0909a703          	lw	a4,144(s3)
ffffffffc0204314:	478d                	li	a5,3
ffffffffc0204316:	48f71963          	bne	a4,a5,ffffffffc02047a8 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020431a:	450d                	li	a0,3
ffffffffc020431c:	b87fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc0204320:	8c2a                	mv	s8,a0
ffffffffc0204322:	46050363          	beqz	a0,ffffffffc0204788 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0204326:	4505                	li	a0,1
ffffffffc0204328:	b7bfc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc020432c:	42051e63          	bnez	a0,ffffffffc0204768 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0204330:	418a1c63          	bne	s4,s8,ffffffffc0204748 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0204334:	4585                	li	a1,1
ffffffffc0204336:	854e                	mv	a0,s3
ffffffffc0204338:	bfdfc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    free_pages(p1, 3);
ffffffffc020433c:	458d                	li	a1,3
ffffffffc020433e:	8552                	mv	a0,s4
ffffffffc0204340:	bf5fc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
ffffffffc0204344:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0204348:	04098c13          	addi	s8,s3,64
ffffffffc020434c:	8385                	srli	a5,a5,0x1
ffffffffc020434e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204350:	3c078c63          	beqz	a5,ffffffffc0204728 <default_check+0x602>
ffffffffc0204354:	0109a703          	lw	a4,16(s3)
ffffffffc0204358:	4785                	li	a5,1
ffffffffc020435a:	3cf71763          	bne	a4,a5,ffffffffc0204728 <default_check+0x602>
ffffffffc020435e:	008a3783          	ld	a5,8(s4)
ffffffffc0204362:	8385                	srli	a5,a5,0x1
ffffffffc0204364:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204366:	3a078163          	beqz	a5,ffffffffc0204708 <default_check+0x5e2>
ffffffffc020436a:	010a2703          	lw	a4,16(s4)
ffffffffc020436e:	478d                	li	a5,3
ffffffffc0204370:	38f71c63          	bne	a4,a5,ffffffffc0204708 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0204374:	4505                	li	a0,1
ffffffffc0204376:	b2dfc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc020437a:	36a99763          	bne	s3,a0,ffffffffc02046e8 <default_check+0x5c2>
    free_page(p0);
ffffffffc020437e:	4585                	li	a1,1
ffffffffc0204380:	bb5fc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0204384:	4509                	li	a0,2
ffffffffc0204386:	b1dfc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc020438a:	32aa1f63          	bne	s4,a0,ffffffffc02046c8 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020438e:	4589                	li	a1,2
ffffffffc0204390:	ba5fc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    free_page(p2);
ffffffffc0204394:	4585                	li	a1,1
ffffffffc0204396:	8562                	mv	a0,s8
ffffffffc0204398:	b9dfc0ef          	jal	ra,ffffffffc0200f34 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020439c:	4515                	li	a0,5
ffffffffc020439e:	b05fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc02043a2:	89aa                	mv	s3,a0
ffffffffc02043a4:	48050263          	beqz	a0,ffffffffc0204828 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02043a8:	4505                	li	a0,1
ffffffffc02043aa:	af9fc0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc02043ae:	2c051d63          	bnez	a0,ffffffffc0204688 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02043b2:	481c                	lw	a5,16(s0)
ffffffffc02043b4:	2a079a63          	bnez	a5,ffffffffc0204668 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02043b8:	4595                	li	a1,5
ffffffffc02043ba:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02043bc:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02043c0:	01643023          	sd	s6,0(s0)
ffffffffc02043c4:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02043c8:	b6dfc0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    return listelm->next;
ffffffffc02043cc:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02043ce:	00878963          	beq	a5,s0,ffffffffc02043e0 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02043d2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02043d6:	679c                	ld	a5,8(a5)
ffffffffc02043d8:	397d                	addiw	s2,s2,-1
ffffffffc02043da:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02043dc:	fe879be3          	bne	a5,s0,ffffffffc02043d2 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02043e0:	26091463          	bnez	s2,ffffffffc0204648 <default_check+0x522>
    assert(total == 0);
ffffffffc02043e4:	46049263          	bnez	s1,ffffffffc0204848 <default_check+0x722>
}
ffffffffc02043e8:	60a6                	ld	ra,72(sp)
ffffffffc02043ea:	6406                	ld	s0,64(sp)
ffffffffc02043ec:	74e2                	ld	s1,56(sp)
ffffffffc02043ee:	7942                	ld	s2,48(sp)
ffffffffc02043f0:	79a2                	ld	s3,40(sp)
ffffffffc02043f2:	7a02                	ld	s4,32(sp)
ffffffffc02043f4:	6ae2                	ld	s5,24(sp)
ffffffffc02043f6:	6b42                	ld	s6,16(sp)
ffffffffc02043f8:	6ba2                	ld	s7,8(sp)
ffffffffc02043fa:	6c02                	ld	s8,0(sp)
ffffffffc02043fc:	6161                	addi	sp,sp,80
ffffffffc02043fe:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204400:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0204402:	4481                	li	s1,0
ffffffffc0204404:	4901                	li	s2,0
ffffffffc0204406:	b38d                	j	ffffffffc0204168 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0204408:	00004697          	auipc	a3,0x4
ffffffffc020440c:	90068693          	addi	a3,a3,-1792 # ffffffffc0207d08 <commands+0x1440>
ffffffffc0204410:	00003617          	auipc	a2,0x3
ffffffffc0204414:	8c860613          	addi	a2,a2,-1848 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204418:	0f000593          	li	a1,240
ffffffffc020441c:	00004517          	auipc	a0,0x4
ffffffffc0204420:	c3c50513          	addi	a0,a0,-964 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204424:	de5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0204428:	00004697          	auipc	a3,0x4
ffffffffc020442c:	ca868693          	addi	a3,a3,-856 # ffffffffc02080d0 <commands+0x1808>
ffffffffc0204430:	00003617          	auipc	a2,0x3
ffffffffc0204434:	8a860613          	addi	a2,a2,-1880 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204438:	0bd00593          	li	a1,189
ffffffffc020443c:	00004517          	auipc	a0,0x4
ffffffffc0204440:	c1c50513          	addi	a0,a0,-996 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204444:	dc5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204448:	00004697          	auipc	a3,0x4
ffffffffc020444c:	cb068693          	addi	a3,a3,-848 # ffffffffc02080f8 <commands+0x1830>
ffffffffc0204450:	00003617          	auipc	a2,0x3
ffffffffc0204454:	88860613          	addi	a2,a2,-1912 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204458:	0be00593          	li	a1,190
ffffffffc020445c:	00004517          	auipc	a0,0x4
ffffffffc0204460:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204464:	da5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0204468:	00004697          	auipc	a3,0x4
ffffffffc020446c:	cd068693          	addi	a3,a3,-816 # ffffffffc0208138 <commands+0x1870>
ffffffffc0204470:	00003617          	auipc	a2,0x3
ffffffffc0204474:	86860613          	addi	a2,a2,-1944 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204478:	0c000593          	li	a1,192
ffffffffc020447c:	00004517          	auipc	a0,0x4
ffffffffc0204480:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204484:	d85fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0204488:	00004697          	auipc	a3,0x4
ffffffffc020448c:	d3868693          	addi	a3,a3,-712 # ffffffffc02081c0 <commands+0x18f8>
ffffffffc0204490:	00003617          	auipc	a2,0x3
ffffffffc0204494:	84860613          	addi	a2,a2,-1976 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204498:	0d900593          	li	a1,217
ffffffffc020449c:	00004517          	auipc	a0,0x4
ffffffffc02044a0:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0208058 <commands+0x1790>
ffffffffc02044a4:	d65fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02044a8:	00004697          	auipc	a3,0x4
ffffffffc02044ac:	bc868693          	addi	a3,a3,-1080 # ffffffffc0208070 <commands+0x17a8>
ffffffffc02044b0:	00003617          	auipc	a2,0x3
ffffffffc02044b4:	82860613          	addi	a2,a2,-2008 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02044b8:	0d200593          	li	a1,210
ffffffffc02044bc:	00004517          	auipc	a0,0x4
ffffffffc02044c0:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0208058 <commands+0x1790>
ffffffffc02044c4:	d45fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc02044c8:	00004697          	auipc	a3,0x4
ffffffffc02044cc:	ce868693          	addi	a3,a3,-792 # ffffffffc02081b0 <commands+0x18e8>
ffffffffc02044d0:	00003617          	auipc	a2,0x3
ffffffffc02044d4:	80860613          	addi	a2,a2,-2040 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02044d8:	0d000593          	li	a1,208
ffffffffc02044dc:	00004517          	auipc	a0,0x4
ffffffffc02044e0:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0208058 <commands+0x1790>
ffffffffc02044e4:	d25fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02044e8:	00004697          	auipc	a3,0x4
ffffffffc02044ec:	cb068693          	addi	a3,a3,-848 # ffffffffc0208198 <commands+0x18d0>
ffffffffc02044f0:	00002617          	auipc	a2,0x2
ffffffffc02044f4:	7e860613          	addi	a2,a2,2024 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02044f8:	0cb00593          	li	a1,203
ffffffffc02044fc:	00004517          	auipc	a0,0x4
ffffffffc0204500:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204504:	d05fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0204508:	00004697          	auipc	a3,0x4
ffffffffc020450c:	c7068693          	addi	a3,a3,-912 # ffffffffc0208178 <commands+0x18b0>
ffffffffc0204510:	00002617          	auipc	a2,0x2
ffffffffc0204514:	7c860613          	addi	a2,a2,1992 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204518:	0c200593          	li	a1,194
ffffffffc020451c:	00004517          	auipc	a0,0x4
ffffffffc0204520:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204524:	ce5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc0204528:	00004697          	auipc	a3,0x4
ffffffffc020452c:	cd068693          	addi	a3,a3,-816 # ffffffffc02081f8 <commands+0x1930>
ffffffffc0204530:	00002617          	auipc	a2,0x2
ffffffffc0204534:	7a860613          	addi	a2,a2,1960 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204538:	0f800593          	li	a1,248
ffffffffc020453c:	00004517          	auipc	a0,0x4
ffffffffc0204540:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204544:	cc5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0204548:	00004697          	auipc	a3,0x4
ffffffffc020454c:	96068693          	addi	a3,a3,-1696 # ffffffffc0207ea8 <commands+0x15e0>
ffffffffc0204550:	00002617          	auipc	a2,0x2
ffffffffc0204554:	78860613          	addi	a2,a2,1928 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204558:	0df00593          	li	a1,223
ffffffffc020455c:	00004517          	auipc	a0,0x4
ffffffffc0204560:	afc50513          	addi	a0,a0,-1284 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204564:	ca5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204568:	00004697          	auipc	a3,0x4
ffffffffc020456c:	c3068693          	addi	a3,a3,-976 # ffffffffc0208198 <commands+0x18d0>
ffffffffc0204570:	00002617          	auipc	a2,0x2
ffffffffc0204574:	76860613          	addi	a2,a2,1896 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204578:	0dd00593          	li	a1,221
ffffffffc020457c:	00004517          	auipc	a0,0x4
ffffffffc0204580:	adc50513          	addi	a0,a0,-1316 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204584:	c85fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0204588:	00004697          	auipc	a3,0x4
ffffffffc020458c:	c5068693          	addi	a3,a3,-944 # ffffffffc02081d8 <commands+0x1910>
ffffffffc0204590:	00002617          	auipc	a2,0x2
ffffffffc0204594:	74860613          	addi	a2,a2,1864 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204598:	0dc00593          	li	a1,220
ffffffffc020459c:	00004517          	auipc	a0,0x4
ffffffffc02045a0:	abc50513          	addi	a0,a0,-1348 # ffffffffc0208058 <commands+0x1790>
ffffffffc02045a4:	c65fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02045a8:	00004697          	auipc	a3,0x4
ffffffffc02045ac:	ac868693          	addi	a3,a3,-1336 # ffffffffc0208070 <commands+0x17a8>
ffffffffc02045b0:	00002617          	auipc	a2,0x2
ffffffffc02045b4:	72860613          	addi	a2,a2,1832 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02045b8:	0b900593          	li	a1,185
ffffffffc02045bc:	00004517          	auipc	a0,0x4
ffffffffc02045c0:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0208058 <commands+0x1790>
ffffffffc02045c4:	c45fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02045c8:	00004697          	auipc	a3,0x4
ffffffffc02045cc:	bd068693          	addi	a3,a3,-1072 # ffffffffc0208198 <commands+0x18d0>
ffffffffc02045d0:	00002617          	auipc	a2,0x2
ffffffffc02045d4:	70860613          	addi	a2,a2,1800 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02045d8:	0d600593          	li	a1,214
ffffffffc02045dc:	00004517          	auipc	a0,0x4
ffffffffc02045e0:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0208058 <commands+0x1790>
ffffffffc02045e4:	c25fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02045e8:	00004697          	auipc	a3,0x4
ffffffffc02045ec:	ac868693          	addi	a3,a3,-1336 # ffffffffc02080b0 <commands+0x17e8>
ffffffffc02045f0:	00002617          	auipc	a2,0x2
ffffffffc02045f4:	6e860613          	addi	a2,a2,1768 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02045f8:	0d400593          	li	a1,212
ffffffffc02045fc:	00004517          	auipc	a0,0x4
ffffffffc0204600:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204604:	c05fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204608:	00004697          	auipc	a3,0x4
ffffffffc020460c:	a8868693          	addi	a3,a3,-1400 # ffffffffc0208090 <commands+0x17c8>
ffffffffc0204610:	00002617          	auipc	a2,0x2
ffffffffc0204614:	6c860613          	addi	a2,a2,1736 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204618:	0d300593          	li	a1,211
ffffffffc020461c:	00004517          	auipc	a0,0x4
ffffffffc0204620:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204624:	be5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204628:	00004697          	auipc	a3,0x4
ffffffffc020462c:	a8868693          	addi	a3,a3,-1400 # ffffffffc02080b0 <commands+0x17e8>
ffffffffc0204630:	00002617          	auipc	a2,0x2
ffffffffc0204634:	6a860613          	addi	a2,a2,1704 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204638:	0bb00593          	li	a1,187
ffffffffc020463c:	00004517          	auipc	a0,0x4
ffffffffc0204640:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204644:	bc5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc0204648:	00004697          	auipc	a3,0x4
ffffffffc020464c:	d0068693          	addi	a3,a3,-768 # ffffffffc0208348 <commands+0x1a80>
ffffffffc0204650:	00002617          	auipc	a2,0x2
ffffffffc0204654:	68860613          	addi	a2,a2,1672 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204658:	12500593          	li	a1,293
ffffffffc020465c:	00004517          	auipc	a0,0x4
ffffffffc0204660:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204664:	ba5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0204668:	00004697          	auipc	a3,0x4
ffffffffc020466c:	84068693          	addi	a3,a3,-1984 # ffffffffc0207ea8 <commands+0x15e0>
ffffffffc0204670:	00002617          	auipc	a2,0x2
ffffffffc0204674:	66860613          	addi	a2,a2,1640 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204678:	11a00593          	li	a1,282
ffffffffc020467c:	00004517          	auipc	a0,0x4
ffffffffc0204680:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204684:	b85fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204688:	00004697          	auipc	a3,0x4
ffffffffc020468c:	b1068693          	addi	a3,a3,-1264 # ffffffffc0208198 <commands+0x18d0>
ffffffffc0204690:	00002617          	auipc	a2,0x2
ffffffffc0204694:	64860613          	addi	a2,a2,1608 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204698:	11800593          	li	a1,280
ffffffffc020469c:	00004517          	auipc	a0,0x4
ffffffffc02046a0:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0208058 <commands+0x1790>
ffffffffc02046a4:	b65fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02046a8:	00004697          	auipc	a3,0x4
ffffffffc02046ac:	ab068693          	addi	a3,a3,-1360 # ffffffffc0208158 <commands+0x1890>
ffffffffc02046b0:	00002617          	auipc	a2,0x2
ffffffffc02046b4:	62860613          	addi	a2,a2,1576 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02046b8:	0c100593          	li	a1,193
ffffffffc02046bc:	00004517          	auipc	a0,0x4
ffffffffc02046c0:	99c50513          	addi	a0,a0,-1636 # ffffffffc0208058 <commands+0x1790>
ffffffffc02046c4:	b45fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02046c8:	00004697          	auipc	a3,0x4
ffffffffc02046cc:	c4068693          	addi	a3,a3,-960 # ffffffffc0208308 <commands+0x1a40>
ffffffffc02046d0:	00002617          	auipc	a2,0x2
ffffffffc02046d4:	60860613          	addi	a2,a2,1544 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02046d8:	11200593          	li	a1,274
ffffffffc02046dc:	00004517          	auipc	a0,0x4
ffffffffc02046e0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0208058 <commands+0x1790>
ffffffffc02046e4:	b25fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02046e8:	00004697          	auipc	a3,0x4
ffffffffc02046ec:	c0068693          	addi	a3,a3,-1024 # ffffffffc02082e8 <commands+0x1a20>
ffffffffc02046f0:	00002617          	auipc	a2,0x2
ffffffffc02046f4:	5e860613          	addi	a2,a2,1512 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02046f8:	11000593          	li	a1,272
ffffffffc02046fc:	00004517          	auipc	a0,0x4
ffffffffc0204700:	95c50513          	addi	a0,a0,-1700 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204704:	b05fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204708:	00004697          	auipc	a3,0x4
ffffffffc020470c:	bb868693          	addi	a3,a3,-1096 # ffffffffc02082c0 <commands+0x19f8>
ffffffffc0204710:	00002617          	auipc	a2,0x2
ffffffffc0204714:	5c860613          	addi	a2,a2,1480 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204718:	10e00593          	li	a1,270
ffffffffc020471c:	00004517          	auipc	a0,0x4
ffffffffc0204720:	93c50513          	addi	a0,a0,-1732 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204724:	ae5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204728:	00004697          	auipc	a3,0x4
ffffffffc020472c:	b7068693          	addi	a3,a3,-1168 # ffffffffc0208298 <commands+0x19d0>
ffffffffc0204730:	00002617          	auipc	a2,0x2
ffffffffc0204734:	5a860613          	addi	a2,a2,1448 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204738:	10d00593          	li	a1,269
ffffffffc020473c:	00004517          	auipc	a0,0x4
ffffffffc0204740:	91c50513          	addi	a0,a0,-1764 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204744:	ac5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0204748:	00004697          	auipc	a3,0x4
ffffffffc020474c:	b4068693          	addi	a3,a3,-1216 # ffffffffc0208288 <commands+0x19c0>
ffffffffc0204750:	00002617          	auipc	a2,0x2
ffffffffc0204754:	58860613          	addi	a2,a2,1416 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204758:	10800593          	li	a1,264
ffffffffc020475c:	00004517          	auipc	a0,0x4
ffffffffc0204760:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204764:	aa5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204768:	00004697          	auipc	a3,0x4
ffffffffc020476c:	a3068693          	addi	a3,a3,-1488 # ffffffffc0208198 <commands+0x18d0>
ffffffffc0204770:	00002617          	auipc	a2,0x2
ffffffffc0204774:	56860613          	addi	a2,a2,1384 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204778:	10700593          	li	a1,263
ffffffffc020477c:	00004517          	auipc	a0,0x4
ffffffffc0204780:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204784:	a85fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0204788:	00004697          	auipc	a3,0x4
ffffffffc020478c:	ae068693          	addi	a3,a3,-1312 # ffffffffc0208268 <commands+0x19a0>
ffffffffc0204790:	00002617          	auipc	a2,0x2
ffffffffc0204794:	54860613          	addi	a2,a2,1352 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204798:	10600593          	li	a1,262
ffffffffc020479c:	00004517          	auipc	a0,0x4
ffffffffc02047a0:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0208058 <commands+0x1790>
ffffffffc02047a4:	a65fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02047a8:	00004697          	auipc	a3,0x4
ffffffffc02047ac:	a9068693          	addi	a3,a3,-1392 # ffffffffc0208238 <commands+0x1970>
ffffffffc02047b0:	00002617          	auipc	a2,0x2
ffffffffc02047b4:	52860613          	addi	a2,a2,1320 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02047b8:	10500593          	li	a1,261
ffffffffc02047bc:	00004517          	auipc	a0,0x4
ffffffffc02047c0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0208058 <commands+0x1790>
ffffffffc02047c4:	a45fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02047c8:	00004697          	auipc	a3,0x4
ffffffffc02047cc:	a5868693          	addi	a3,a3,-1448 # ffffffffc0208220 <commands+0x1958>
ffffffffc02047d0:	00002617          	auipc	a2,0x2
ffffffffc02047d4:	50860613          	addi	a2,a2,1288 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02047d8:	10400593          	li	a1,260
ffffffffc02047dc:	00004517          	auipc	a0,0x4
ffffffffc02047e0:	87c50513          	addi	a0,a0,-1924 # ffffffffc0208058 <commands+0x1790>
ffffffffc02047e4:	a25fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02047e8:	00004697          	auipc	a3,0x4
ffffffffc02047ec:	9b068693          	addi	a3,a3,-1616 # ffffffffc0208198 <commands+0x18d0>
ffffffffc02047f0:	00002617          	auipc	a2,0x2
ffffffffc02047f4:	4e860613          	addi	a2,a2,1256 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02047f8:	0fe00593          	li	a1,254
ffffffffc02047fc:	00004517          	auipc	a0,0x4
ffffffffc0204800:	85c50513          	addi	a0,a0,-1956 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204804:	a05fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc0204808:	00004697          	auipc	a3,0x4
ffffffffc020480c:	a0068693          	addi	a3,a3,-1536 # ffffffffc0208208 <commands+0x1940>
ffffffffc0204810:	00002617          	auipc	a2,0x2
ffffffffc0204814:	4c860613          	addi	a2,a2,1224 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204818:	0f900593          	li	a1,249
ffffffffc020481c:	00004517          	auipc	a0,0x4
ffffffffc0204820:	83c50513          	addi	a0,a0,-1988 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204824:	9e5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204828:	00004697          	auipc	a3,0x4
ffffffffc020482c:	b0068693          	addi	a3,a3,-1280 # ffffffffc0208328 <commands+0x1a60>
ffffffffc0204830:	00002617          	auipc	a2,0x2
ffffffffc0204834:	4a860613          	addi	a2,a2,1192 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204838:	11700593          	li	a1,279
ffffffffc020483c:	00004517          	auipc	a0,0x4
ffffffffc0204840:	81c50513          	addi	a0,a0,-2020 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204844:	9c5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc0204848:	00004697          	auipc	a3,0x4
ffffffffc020484c:	b1068693          	addi	a3,a3,-1264 # ffffffffc0208358 <commands+0x1a90>
ffffffffc0204850:	00002617          	auipc	a2,0x2
ffffffffc0204854:	48860613          	addi	a2,a2,1160 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204858:	12600593          	li	a1,294
ffffffffc020485c:	00003517          	auipc	a0,0x3
ffffffffc0204860:	7fc50513          	addi	a0,a0,2044 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204864:	9a5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc0204868:	00003697          	auipc	a3,0x3
ffffffffc020486c:	4b068693          	addi	a3,a3,1200 # ffffffffc0207d18 <commands+0x1450>
ffffffffc0204870:	00002617          	auipc	a2,0x2
ffffffffc0204874:	46860613          	addi	a2,a2,1128 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204878:	0f300593          	li	a1,243
ffffffffc020487c:	00003517          	auipc	a0,0x3
ffffffffc0204880:	7dc50513          	addi	a0,a0,2012 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204884:	985fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204888:	00004697          	auipc	a3,0x4
ffffffffc020488c:	80868693          	addi	a3,a3,-2040 # ffffffffc0208090 <commands+0x17c8>
ffffffffc0204890:	00002617          	auipc	a2,0x2
ffffffffc0204894:	44860613          	addi	a2,a2,1096 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204898:	0ba00593          	li	a1,186
ffffffffc020489c:	00003517          	auipc	a0,0x3
ffffffffc02048a0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0208058 <commands+0x1790>
ffffffffc02048a4:	965fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02048a8 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02048a8:	1141                	addi	sp,sp,-16
ffffffffc02048aa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02048ac:	14058463          	beqz	a1,ffffffffc02049f4 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02048b0:	00659693          	slli	a3,a1,0x6
ffffffffc02048b4:	96aa                	add	a3,a3,a0
ffffffffc02048b6:	87aa                	mv	a5,a0
ffffffffc02048b8:	02d50263          	beq	a0,a3,ffffffffc02048dc <default_free_pages+0x34>
ffffffffc02048bc:	6798                	ld	a4,8(a5)
ffffffffc02048be:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02048c0:	10071a63          	bnez	a4,ffffffffc02049d4 <default_free_pages+0x12c>
ffffffffc02048c4:	6798                	ld	a4,8(a5)
ffffffffc02048c6:	8b09                	andi	a4,a4,2
ffffffffc02048c8:	10071663          	bnez	a4,ffffffffc02049d4 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02048cc:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02048d0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02048d4:	04078793          	addi	a5,a5,64
ffffffffc02048d8:	fed792e3          	bne	a5,a3,ffffffffc02048bc <default_free_pages+0x14>
    base->property = n;
ffffffffc02048dc:	2581                	sext.w	a1,a1
ffffffffc02048de:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02048e0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02048e4:	4789                	li	a5,2
ffffffffc02048e6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02048ea:	000aa697          	auipc	a3,0xaa
ffffffffc02048ee:	ee668693          	addi	a3,a3,-282 # ffffffffc02ae7d0 <free_area>
ffffffffc02048f2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02048f4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02048f6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02048fa:	9db9                	addw	a1,a1,a4
ffffffffc02048fc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02048fe:	0ad78463          	beq	a5,a3,ffffffffc02049a6 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0204902:	fe878713          	addi	a4,a5,-24
ffffffffc0204906:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020490a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020490c:	00e56a63          	bltu	a0,a4,ffffffffc0204920 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0204910:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204912:	04d70c63          	beq	a4,a3,ffffffffc020496a <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0204916:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204918:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020491c:	fee57ae3          	bgeu	a0,a4,ffffffffc0204910 <default_free_pages+0x68>
ffffffffc0204920:	c199                	beqz	a1,ffffffffc0204926 <default_free_pages+0x7e>
ffffffffc0204922:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204926:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204928:	e390                	sd	a2,0(a5)
ffffffffc020492a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020492c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020492e:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0204930:	00d70d63          	beq	a4,a3,ffffffffc020494a <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0204934:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0204938:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc020493c:	02059813          	slli	a6,a1,0x20
ffffffffc0204940:	01a85793          	srli	a5,a6,0x1a
ffffffffc0204944:	97b2                	add	a5,a5,a2
ffffffffc0204946:	02f50c63          	beq	a0,a5,ffffffffc020497e <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020494a:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020494c:	00d78c63          	beq	a5,a3,ffffffffc0204964 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0204950:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0204952:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0204956:	02061593          	slli	a1,a2,0x20
ffffffffc020495a:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020495e:	972a                	add	a4,a4,a0
ffffffffc0204960:	04e68a63          	beq	a3,a4,ffffffffc02049b4 <default_free_pages+0x10c>
}
ffffffffc0204964:	60a2                	ld	ra,8(sp)
ffffffffc0204966:	0141                	addi	sp,sp,16
ffffffffc0204968:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020496a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020496c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020496e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204970:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204972:	02d70763          	beq	a4,a3,ffffffffc02049a0 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0204976:	8832                	mv	a6,a2
ffffffffc0204978:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020497a:	87ba                	mv	a5,a4
ffffffffc020497c:	bf71                	j	ffffffffc0204918 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020497e:	491c                	lw	a5,16(a0)
ffffffffc0204980:	9dbd                	addw	a1,a1,a5
ffffffffc0204982:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204986:	57f5                	li	a5,-3
ffffffffc0204988:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020498c:	01853803          	ld	a6,24(a0)
ffffffffc0204990:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0204992:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0204994:	00b83423          	sd	a1,8(a6) # fffffffffff80008 <end+0x3fccd77c>
    return listelm->next;
ffffffffc0204998:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020499a:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc020499e:	b77d                	j	ffffffffc020494c <default_free_pages+0xa4>
ffffffffc02049a0:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02049a2:	873e                	mv	a4,a5
ffffffffc02049a4:	bf41                	j	ffffffffc0204934 <default_free_pages+0x8c>
}
ffffffffc02049a6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02049a8:	e390                	sd	a2,0(a5)
ffffffffc02049aa:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02049ac:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02049ae:	ed1c                	sd	a5,24(a0)
ffffffffc02049b0:	0141                	addi	sp,sp,16
ffffffffc02049b2:	8082                	ret
            base->property += p->property;
ffffffffc02049b4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02049b8:	ff078693          	addi	a3,a5,-16
ffffffffc02049bc:	9e39                	addw	a2,a2,a4
ffffffffc02049be:	c910                	sw	a2,16(a0)
ffffffffc02049c0:	5775                	li	a4,-3
ffffffffc02049c2:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02049c6:	6398                	ld	a4,0(a5)
ffffffffc02049c8:	679c                	ld	a5,8(a5)
}
ffffffffc02049ca:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02049cc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02049ce:	e398                	sd	a4,0(a5)
ffffffffc02049d0:	0141                	addi	sp,sp,16
ffffffffc02049d2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02049d4:	00004697          	auipc	a3,0x4
ffffffffc02049d8:	99c68693          	addi	a3,a3,-1636 # ffffffffc0208370 <commands+0x1aa8>
ffffffffc02049dc:	00002617          	auipc	a2,0x2
ffffffffc02049e0:	2fc60613          	addi	a2,a2,764 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02049e4:	08300593          	li	a1,131
ffffffffc02049e8:	00003517          	auipc	a0,0x3
ffffffffc02049ec:	67050513          	addi	a0,a0,1648 # ffffffffc0208058 <commands+0x1790>
ffffffffc02049f0:	819fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc02049f4:	00004697          	auipc	a3,0x4
ffffffffc02049f8:	97468693          	addi	a3,a3,-1676 # ffffffffc0208368 <commands+0x1aa0>
ffffffffc02049fc:	00002617          	auipc	a2,0x2
ffffffffc0204a00:	2dc60613          	addi	a2,a2,732 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204a04:	08000593          	li	a1,128
ffffffffc0204a08:	00003517          	auipc	a0,0x3
ffffffffc0204a0c:	65050513          	addi	a0,a0,1616 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204a10:	ff8fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204a14 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0204a14:	c941                	beqz	a0,ffffffffc0204aa4 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0204a16:	000aa597          	auipc	a1,0xaa
ffffffffc0204a1a:	dba58593          	addi	a1,a1,-582 # ffffffffc02ae7d0 <free_area>
ffffffffc0204a1e:	0105a803          	lw	a6,16(a1)
ffffffffc0204a22:	872a                	mv	a4,a0
ffffffffc0204a24:	02081793          	slli	a5,a6,0x20
ffffffffc0204a28:	9381                	srli	a5,a5,0x20
ffffffffc0204a2a:	00a7ee63          	bltu	a5,a0,ffffffffc0204a46 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0204a2e:	87ae                	mv	a5,a1
ffffffffc0204a30:	a801                	j	ffffffffc0204a40 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0204a32:	ff87a683          	lw	a3,-8(a5)
ffffffffc0204a36:	02069613          	slli	a2,a3,0x20
ffffffffc0204a3a:	9201                	srli	a2,a2,0x20
ffffffffc0204a3c:	00e67763          	bgeu	a2,a4,ffffffffc0204a4a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0204a40:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204a42:	feb798e3          	bne	a5,a1,ffffffffc0204a32 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0204a46:	4501                	li	a0,0
}
ffffffffc0204a48:	8082                	ret
    return listelm->prev;
ffffffffc0204a4a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204a4e:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0204a52:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0204a56:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0204a5a:	0068b423          	sd	t1,8(a7) # 1008 <_binary_obj___user_faultread_out_size-0x8bb0>
    next->prev = prev;
ffffffffc0204a5e:	01133023          	sd	a7,0(t1) # 80000 <_binary_obj___user_exit_out_size+0x74ed8>
        if (page->property > n) {
ffffffffc0204a62:	02c77863          	bgeu	a4,a2,ffffffffc0204a92 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0204a66:	071a                	slli	a4,a4,0x6
ffffffffc0204a68:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0204a6a:	41c686bb          	subw	a3,a3,t3
ffffffffc0204a6e:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204a70:	00870613          	addi	a2,a4,8
ffffffffc0204a74:	4689                	li	a3,2
ffffffffc0204a76:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204a7a:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0204a7e:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0204a82:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0204a86:	e290                	sd	a2,0(a3)
ffffffffc0204a88:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0204a8c:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0204a8e:	01173c23          	sd	a7,24(a4)
ffffffffc0204a92:	41c8083b          	subw	a6,a6,t3
ffffffffc0204a96:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204a9a:	5775                	li	a4,-3
ffffffffc0204a9c:	17c1                	addi	a5,a5,-16
ffffffffc0204a9e:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0204aa2:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0204aa4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0204aa6:	00004697          	auipc	a3,0x4
ffffffffc0204aaa:	8c268693          	addi	a3,a3,-1854 # ffffffffc0208368 <commands+0x1aa0>
ffffffffc0204aae:	00002617          	auipc	a2,0x2
ffffffffc0204ab2:	22a60613          	addi	a2,a2,554 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204ab6:	06200593          	li	a1,98
ffffffffc0204aba:	00003517          	auipc	a0,0x3
ffffffffc0204abe:	59e50513          	addi	a0,a0,1438 # ffffffffc0208058 <commands+0x1790>
default_alloc_pages(size_t n) {
ffffffffc0204ac2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204ac4:	f44fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ac8 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0204ac8:	1141                	addi	sp,sp,-16
ffffffffc0204aca:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204acc:	c5f1                	beqz	a1,ffffffffc0204b98 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0204ace:	00659693          	slli	a3,a1,0x6
ffffffffc0204ad2:	96aa                	add	a3,a3,a0
ffffffffc0204ad4:	87aa                	mv	a5,a0
ffffffffc0204ad6:	00d50f63          	beq	a0,a3,ffffffffc0204af4 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0204ada:	6798                	ld	a4,8(a5)
ffffffffc0204adc:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0204ade:	cf49                	beqz	a4,ffffffffc0204b78 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0204ae0:	0007a823          	sw	zero,16(a5)
ffffffffc0204ae4:	0007b423          	sd	zero,8(a5)
ffffffffc0204ae8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204aec:	04078793          	addi	a5,a5,64
ffffffffc0204af0:	fed795e3          	bne	a5,a3,ffffffffc0204ada <default_init_memmap+0x12>
    base->property = n;
ffffffffc0204af4:	2581                	sext.w	a1,a1
ffffffffc0204af6:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204af8:	4789                	li	a5,2
ffffffffc0204afa:	00850713          	addi	a4,a0,8
ffffffffc0204afe:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0204b02:	000aa697          	auipc	a3,0xaa
ffffffffc0204b06:	cce68693          	addi	a3,a3,-818 # ffffffffc02ae7d0 <free_area>
ffffffffc0204b0a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204b0c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0204b0e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0204b12:	9db9                	addw	a1,a1,a4
ffffffffc0204b14:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0204b16:	04d78a63          	beq	a5,a3,ffffffffc0204b6a <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0204b1a:	fe878713          	addi	a4,a5,-24
ffffffffc0204b1e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204b22:	4581                	li	a1,0
            if (base < page) {
ffffffffc0204b24:	00e56a63          	bltu	a0,a4,ffffffffc0204b38 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0204b28:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204b2a:	02d70263          	beq	a4,a3,ffffffffc0204b4e <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0204b2e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204b30:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204b34:	fee57ae3          	bgeu	a0,a4,ffffffffc0204b28 <default_init_memmap+0x60>
ffffffffc0204b38:	c199                	beqz	a1,ffffffffc0204b3e <default_init_memmap+0x76>
ffffffffc0204b3a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204b3e:	6398                	ld	a4,0(a5)
}
ffffffffc0204b40:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204b42:	e390                	sd	a2,0(a5)
ffffffffc0204b44:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204b46:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204b48:	ed18                	sd	a4,24(a0)
ffffffffc0204b4a:	0141                	addi	sp,sp,16
ffffffffc0204b4c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204b4e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204b50:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0204b52:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204b54:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204b56:	00d70663          	beq	a4,a3,ffffffffc0204b62 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0204b5a:	8832                	mv	a6,a2
ffffffffc0204b5c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0204b5e:	87ba                	mv	a5,a4
ffffffffc0204b60:	bfc1                	j	ffffffffc0204b30 <default_init_memmap+0x68>
}
ffffffffc0204b62:	60a2                	ld	ra,8(sp)
ffffffffc0204b64:	e290                	sd	a2,0(a3)
ffffffffc0204b66:	0141                	addi	sp,sp,16
ffffffffc0204b68:	8082                	ret
ffffffffc0204b6a:	60a2                	ld	ra,8(sp)
ffffffffc0204b6c:	e390                	sd	a2,0(a5)
ffffffffc0204b6e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204b70:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204b72:	ed1c                	sd	a5,24(a0)
ffffffffc0204b74:	0141                	addi	sp,sp,16
ffffffffc0204b76:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204b78:	00004697          	auipc	a3,0x4
ffffffffc0204b7c:	82068693          	addi	a3,a3,-2016 # ffffffffc0208398 <commands+0x1ad0>
ffffffffc0204b80:	00002617          	auipc	a2,0x2
ffffffffc0204b84:	15860613          	addi	a2,a2,344 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204b88:	04900593          	li	a1,73
ffffffffc0204b8c:	00003517          	auipc	a0,0x3
ffffffffc0204b90:	4cc50513          	addi	a0,a0,1228 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204b94:	e74fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc0204b98:	00003697          	auipc	a3,0x3
ffffffffc0204b9c:	7d068693          	addi	a3,a3,2000 # ffffffffc0208368 <commands+0x1aa0>
ffffffffc0204ba0:	00002617          	auipc	a2,0x2
ffffffffc0204ba4:	13860613          	addi	a2,a2,312 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0204ba8:	04600593          	li	a1,70
ffffffffc0204bac:	00003517          	auipc	a0,0x3
ffffffffc0204bb0:	4ac50513          	addi	a0,a0,1196 # ffffffffc0208058 <commands+0x1790>
ffffffffc0204bb4:	e54fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204bb8 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204bb8:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204bba:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204bbc:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204bbe:	96bfb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204bc2:	cd01                	beqz	a0,ffffffffc0204bda <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204bc4:	4505                	li	a0,1
ffffffffc0204bc6:	969fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204bca:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204bcc:	810d                	srli	a0,a0,0x3
ffffffffc0204bce:	000ae797          	auipc	a5,0xae
ffffffffc0204bd2:	c8a7b523          	sd	a0,-886(a5) # ffffffffc02b2858 <max_swap_offset>
}
ffffffffc0204bd6:	0141                	addi	sp,sp,16
ffffffffc0204bd8:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204bda:	00004617          	auipc	a2,0x4
ffffffffc0204bde:	81e60613          	addi	a2,a2,-2018 # ffffffffc02083f8 <default_pmm_manager+0x38>
ffffffffc0204be2:	45b5                	li	a1,13
ffffffffc0204be4:	00004517          	auipc	a0,0x4
ffffffffc0204be8:	83450513          	addi	a0,a0,-1996 # ffffffffc0208418 <default_pmm_manager+0x58>
ffffffffc0204bec:	e1cfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204bf0 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204bf0:	1141                	addi	sp,sp,-16
ffffffffc0204bf2:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bf4:	00855793          	srli	a5,a0,0x8
ffffffffc0204bf8:	cbb1                	beqz	a5,ffffffffc0204c4c <swapfs_read+0x5c>
ffffffffc0204bfa:	000ae717          	auipc	a4,0xae
ffffffffc0204bfe:	c5e73703          	ld	a4,-930(a4) # ffffffffc02b2858 <max_swap_offset>
ffffffffc0204c02:	04e7f563          	bgeu	a5,a4,ffffffffc0204c4c <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204c06:	000ae617          	auipc	a2,0xae
ffffffffc0204c0a:	c2263603          	ld	a2,-990(a2) # ffffffffc02b2828 <pages>
ffffffffc0204c0e:	8d91                	sub	a1,a1,a2
ffffffffc0204c10:	4065d613          	srai	a2,a1,0x6
ffffffffc0204c14:	00004717          	auipc	a4,0x4
ffffffffc0204c18:	15c73703          	ld	a4,348(a4) # ffffffffc0208d70 <nbase>
ffffffffc0204c1c:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204c1e:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c22:	8331                	srli	a4,a4,0xc
ffffffffc0204c24:	000ae697          	auipc	a3,0xae
ffffffffc0204c28:	bfc6b683          	ld	a3,-1028(a3) # ffffffffc02b2820 <npage>
ffffffffc0204c2c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c30:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c32:	02d77963          	bgeu	a4,a3,ffffffffc0204c64 <swapfs_read+0x74>
}
ffffffffc0204c36:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c38:	000ae797          	auipc	a5,0xae
ffffffffc0204c3c:	c007b783          	ld	a5,-1024(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204c40:	46a1                	li	a3,8
ffffffffc0204c42:	963e                	add	a2,a2,a5
ffffffffc0204c44:	4505                	li	a0,1
}
ffffffffc0204c46:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c48:	8edfb06f          	j	ffffffffc0200534 <ide_read_secs>
ffffffffc0204c4c:	86aa                	mv	a3,a0
ffffffffc0204c4e:	00003617          	auipc	a2,0x3
ffffffffc0204c52:	7e260613          	addi	a2,a2,2018 # ffffffffc0208430 <default_pmm_manager+0x70>
ffffffffc0204c56:	45d1                	li	a1,20
ffffffffc0204c58:	00003517          	auipc	a0,0x3
ffffffffc0204c5c:	7c050513          	addi	a0,a0,1984 # ffffffffc0208418 <default_pmm_manager+0x58>
ffffffffc0204c60:	da8fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204c64:	86b2                	mv	a3,a2
ffffffffc0204c66:	06900593          	li	a1,105
ffffffffc0204c6a:	00002617          	auipc	a2,0x2
ffffffffc0204c6e:	42e60613          	addi	a2,a2,1070 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0204c72:	00002517          	auipc	a0,0x2
ffffffffc0204c76:	3ee50513          	addi	a0,a0,1006 # ffffffffc0207060 <commands+0x798>
ffffffffc0204c7a:	d8efb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204c7e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c7e:	1141                	addi	sp,sp,-16
ffffffffc0204c80:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c82:	00855793          	srli	a5,a0,0x8
ffffffffc0204c86:	cbb1                	beqz	a5,ffffffffc0204cda <swapfs_write+0x5c>
ffffffffc0204c88:	000ae717          	auipc	a4,0xae
ffffffffc0204c8c:	bd073703          	ld	a4,-1072(a4) # ffffffffc02b2858 <max_swap_offset>
ffffffffc0204c90:	04e7f563          	bgeu	a5,a4,ffffffffc0204cda <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204c94:	000ae617          	auipc	a2,0xae
ffffffffc0204c98:	b9463603          	ld	a2,-1132(a2) # ffffffffc02b2828 <pages>
ffffffffc0204c9c:	8d91                	sub	a1,a1,a2
ffffffffc0204c9e:	4065d613          	srai	a2,a1,0x6
ffffffffc0204ca2:	00004717          	auipc	a4,0x4
ffffffffc0204ca6:	0ce73703          	ld	a4,206(a4) # ffffffffc0208d70 <nbase>
ffffffffc0204caa:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204cac:	00c61713          	slli	a4,a2,0xc
ffffffffc0204cb0:	8331                	srli	a4,a4,0xc
ffffffffc0204cb2:	000ae697          	auipc	a3,0xae
ffffffffc0204cb6:	b6e6b683          	ld	a3,-1170(a3) # ffffffffc02b2820 <npage>
ffffffffc0204cba:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cbe:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204cc0:	02d77963          	bgeu	a4,a3,ffffffffc0204cf2 <swapfs_write+0x74>
}
ffffffffc0204cc4:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cc6:	000ae797          	auipc	a5,0xae
ffffffffc0204cca:	b727b783          	ld	a5,-1166(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204cce:	46a1                	li	a3,8
ffffffffc0204cd0:	963e                	add	a2,a2,a5
ffffffffc0204cd2:	4505                	li	a0,1
}
ffffffffc0204cd4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cd6:	883fb06f          	j	ffffffffc0200558 <ide_write_secs>
ffffffffc0204cda:	86aa                	mv	a3,a0
ffffffffc0204cdc:	00003617          	auipc	a2,0x3
ffffffffc0204ce0:	75460613          	addi	a2,a2,1876 # ffffffffc0208430 <default_pmm_manager+0x70>
ffffffffc0204ce4:	45e5                	li	a1,25
ffffffffc0204ce6:	00003517          	auipc	a0,0x3
ffffffffc0204cea:	73250513          	addi	a0,a0,1842 # ffffffffc0208418 <default_pmm_manager+0x58>
ffffffffc0204cee:	d1afb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204cf2:	86b2                	mv	a3,a2
ffffffffc0204cf4:	06900593          	li	a1,105
ffffffffc0204cf8:	00002617          	auipc	a2,0x2
ffffffffc0204cfc:	3a060613          	addi	a2,a2,928 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0204d00:	00002517          	auipc	a0,0x2
ffffffffc0204d04:	36050513          	addi	a0,a0,864 # ffffffffc0207060 <commands+0x798>
ffffffffc0204d08:	d00fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204d0c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204d0c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204d10:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204d14:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204d16:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204d18:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204d1c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204d20:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204d24:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204d28:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204d2c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204d30:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204d34:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204d38:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204d3c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204d40:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204d44:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204d48:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204d4a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204d4c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204d50:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204d54:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204d58:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204d5c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204d60:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204d64:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204d68:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204d6c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204d70:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204d74:	8082                	ret

ffffffffc0204d76 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1 // s1是线程函数参数
ffffffffc0204d76:	8526                	mv	a0,s1
	jalr s0 // s0是线程函数地址
ffffffffc0204d78:	9402                	jalr	s0

	jal do_exit
ffffffffc0204d7a:	642000ef          	jal	ra,ffffffffc02053bc <do_exit>

ffffffffc0204d7e <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d7e:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d80:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d84:	e022                	sd	s0,0(sp)
ffffffffc0204d86:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d88:	8d1fe0ef          	jal	ra,ffffffffc0203658 <kmalloc>
ffffffffc0204d8c:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204d8e:	cd21                	beqz	a0,ffffffffc0204de6 <alloc_proc+0x68>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
ffffffffc0204d90:	57fd                	li	a5,-1
ffffffffc0204d92:	1782                	slli	a5,a5,0x20
ffffffffc0204d94:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc-> need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d96:	07000613          	li	a2,112
ffffffffc0204d9a:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204d9c:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204da0:	00053823          	sd	zero,16(a0)
        proc-> need_resched = 0;
ffffffffc0204da4:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204da8:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204dac:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204db0:	03050513          	addi	a0,a0,48
ffffffffc0204db4:	43c010ef          	jal	ra,ffffffffc02061f0 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204db8:	000ae797          	auipc	a5,0xae
ffffffffc0204dbc:	a587b783          	ld	a5,-1448(a5) # ffffffffc02b2810 <boot_cr3>
        proc->tf = NULL;
ffffffffc0204dc0:	0a043023          	sd	zero,160(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204dc4:	f45c                	sd	a5,168(s0)
        proc->flags = 0;
ffffffffc0204dc6:	0a042823          	sw	zero,176(s0)
        memset(&(proc->name), 0, PROC_NAME_LEN + 1);
ffffffffc0204dca:	4641                	li	a2,16
ffffffffc0204dcc:	4581                	li	a1,0
ffffffffc0204dce:	0b440513          	addi	a0,s0,180
ffffffffc0204dd2:	41e010ef          	jal	ra,ffffffffc02061f0 <memset>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        proc->wait_state = 0;
ffffffffc0204dd6:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204dda:	10043023          	sd	zero,256(s0)
ffffffffc0204dde:	0e043c23          	sd	zero,248(s0)
ffffffffc0204de2:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0204de6:	60a2                	ld	ra,8(sp)
ffffffffc0204de8:	8522                	mv	a0,s0
ffffffffc0204dea:	6402                	ld	s0,0(sp)
ffffffffc0204dec:	0141                	addi	sp,sp,16
ffffffffc0204dee:	8082                	ret

ffffffffc0204df0 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204df0:	000ae797          	auipc	a5,0xae
ffffffffc0204df4:	a807b783          	ld	a5,-1408(a5) # ffffffffc02b2870 <current>
ffffffffc0204df8:	73c8                	ld	a0,160(a5)
ffffffffc0204dfa:	fc5fb06f          	j	ffffffffc0200dbe <forkrets>

ffffffffc0204dfe <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dfe:	000ae797          	auipc	a5,0xae
ffffffffc0204e02:	a727b783          	ld	a5,-1422(a5) # ffffffffc02b2870 <current>
ffffffffc0204e06:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204e08:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204e0a:	00003617          	auipc	a2,0x3
ffffffffc0204e0e:	64660613          	addi	a2,a2,1606 # ffffffffc0208450 <default_pmm_manager+0x90>
ffffffffc0204e12:	00003517          	auipc	a0,0x3
ffffffffc0204e16:	64e50513          	addi	a0,a0,1614 # ffffffffc0208460 <default_pmm_manager+0xa0>
user_main(void *arg) {
ffffffffc0204e1a:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204e1c:	ab0fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204e20:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204e24:	b5078793          	addi	a5,a5,-1200 # a970 <_binary_obj___user_forktest_out_size>
ffffffffc0204e28:	e43e                	sd	a5,8(sp)
ffffffffc0204e2a:	00003517          	auipc	a0,0x3
ffffffffc0204e2e:	62650513          	addi	a0,a0,1574 # ffffffffc0208450 <default_pmm_manager+0x90>
ffffffffc0204e32:	00098797          	auipc	a5,0x98
ffffffffc0204e36:	b2e78793          	addi	a5,a5,-1234 # ffffffffc029c960 <_binary_obj___user_forktest_out_start>
ffffffffc0204e3a:	f03e                	sd	a5,32(sp)
ffffffffc0204e3c:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204e3e:	e802                	sd	zero,16(sp)
ffffffffc0204e40:	334010ef          	jal	ra,ffffffffc0206174 <strlen>
ffffffffc0204e44:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204e46:	4511                	li	a0,4
ffffffffc0204e48:	55a2                	lw	a1,40(sp)
ffffffffc0204e4a:	4662                	lw	a2,24(sp)
ffffffffc0204e4c:	5682                	lw	a3,32(sp)
ffffffffc0204e4e:	4722                	lw	a4,8(sp)
ffffffffc0204e50:	48a9                	li	a7,10
ffffffffc0204e52:	9002                	ebreak
ffffffffc0204e54:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204e56:	65c2                	ld	a1,16(sp)
ffffffffc0204e58:	00003517          	auipc	a0,0x3
ffffffffc0204e5c:	63050513          	addi	a0,a0,1584 # ffffffffc0208488 <default_pmm_manager+0xc8>
ffffffffc0204e60:	a6cfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#else
    KERNEL_EXECVE(exit); // user_main缺省参数，执行此处
#endif
    panic("user_main execve failed.\n");
ffffffffc0204e64:	00003617          	auipc	a2,0x3
ffffffffc0204e68:	63460613          	addi	a2,a2,1588 # ffffffffc0208498 <default_pmm_manager+0xd8>
ffffffffc0204e6c:	34d00593          	li	a1,845
ffffffffc0204e70:	00003517          	auipc	a0,0x3
ffffffffc0204e74:	64850513          	addi	a0,a0,1608 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0204e78:	b90fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204e7c <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e7c:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204e7e:	1141                	addi	sp,sp,-16
ffffffffc0204e80:	e406                	sd	ra,8(sp)
ffffffffc0204e82:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e86:	02f6ee63          	bltu	a3,a5,ffffffffc0204ec2 <put_pgdir+0x46>
ffffffffc0204e8a:	000ae517          	auipc	a0,0xae
ffffffffc0204e8e:	9ae53503          	ld	a0,-1618(a0) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204e92:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e94:	82b1                	srli	a3,a3,0xc
ffffffffc0204e96:	000ae797          	auipc	a5,0xae
ffffffffc0204e9a:	98a7b783          	ld	a5,-1654(a5) # ffffffffc02b2820 <npage>
ffffffffc0204e9e:	02f6fe63          	bgeu	a3,a5,ffffffffc0204eda <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204ea2:	00004517          	auipc	a0,0x4
ffffffffc0204ea6:	ece53503          	ld	a0,-306(a0) # ffffffffc0208d70 <nbase>
}
ffffffffc0204eaa:	60a2                	ld	ra,8(sp)
ffffffffc0204eac:	8e89                	sub	a3,a3,a0
ffffffffc0204eae:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204eb0:	000ae517          	auipc	a0,0xae
ffffffffc0204eb4:	97853503          	ld	a0,-1672(a0) # ffffffffc02b2828 <pages>
ffffffffc0204eb8:	4585                	li	a1,1
ffffffffc0204eba:	9536                	add	a0,a0,a3
}
ffffffffc0204ebc:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204ebe:	876fc06f          	j	ffffffffc0200f34 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204ec2:	00002617          	auipc	a2,0x2
ffffffffc0204ec6:	2ae60613          	addi	a2,a2,686 # ffffffffc0207170 <commands+0x8a8>
ffffffffc0204eca:	06e00593          	li	a1,110
ffffffffc0204ece:	00002517          	auipc	a0,0x2
ffffffffc0204ed2:	19250513          	addi	a0,a0,402 # ffffffffc0207060 <commands+0x798>
ffffffffc0204ed6:	b32fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204eda:	00002617          	auipc	a2,0x2
ffffffffc0204ede:	16660613          	addi	a2,a2,358 # ffffffffc0207040 <commands+0x778>
ffffffffc0204ee2:	06200593          	li	a1,98
ffffffffc0204ee6:	00002517          	auipc	a0,0x2
ffffffffc0204eea:	17a50513          	addi	a0,a0,378 # ffffffffc0207060 <commands+0x798>
ffffffffc0204eee:	b1afb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ef2 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204ef2:	7179                	addi	sp,sp,-48
ffffffffc0204ef4:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204ef6:	000ae917          	auipc	s2,0xae
ffffffffc0204efa:	97a90913          	addi	s2,s2,-1670 # ffffffffc02b2870 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204efe:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204f00:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204f04:	f406                	sd	ra,40(sp)
ffffffffc0204f06:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204f08:	02a48863          	beq	s1,a0,ffffffffc0204f38 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f0c:	100027f3          	csrr	a5,sstatus
ffffffffc0204f10:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f12:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f14:	ef9d                	bnez	a5,ffffffffc0204f52 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f16:	755c                	ld	a5,168(a0)
ffffffffc0204f18:	577d                	li	a4,-1
ffffffffc0204f1a:	177e                	slli	a4,a4,0x3f
ffffffffc0204f1c:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204f1e:	00a93023          	sd	a0,0(s2)
ffffffffc0204f22:	8fd9                	or	a5,a5,a4
ffffffffc0204f24:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context)); // 切换到新线程，结束返回ra寄存器保存地址，此处为forkret
ffffffffc0204f28:	03050593          	addi	a1,a0,48
ffffffffc0204f2c:	03048513          	addi	a0,s1,48
ffffffffc0204f30:	dddff0ef          	jal	ra,ffffffffc0204d0c <switch_to>
    if (flag) {
ffffffffc0204f34:	00099863          	bnez	s3,ffffffffc0204f44 <proc_run+0x52>
}
ffffffffc0204f38:	70a2                	ld	ra,40(sp)
ffffffffc0204f3a:	7482                	ld	s1,32(sp)
ffffffffc0204f3c:	6962                	ld	s2,24(sp)
ffffffffc0204f3e:	69c2                	ld	s3,16(sp)
ffffffffc0204f40:	6145                	addi	sp,sp,48
ffffffffc0204f42:	8082                	ret
ffffffffc0204f44:	70a2                	ld	ra,40(sp)
ffffffffc0204f46:	7482                	ld	s1,32(sp)
ffffffffc0204f48:	6962                	ld	s2,24(sp)
ffffffffc0204f4a:	69c2                	ld	s3,16(sp)
ffffffffc0204f4c:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204f4e:	ef4fb06f          	j	ffffffffc0200642 <intr_enable>
ffffffffc0204f52:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204f54:	ef4fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0204f58:	6522                	ld	a0,8(sp)
ffffffffc0204f5a:	4985                	li	s3,1
ffffffffc0204f5c:	bf6d                	j	ffffffffc0204f16 <proc_run+0x24>

ffffffffc0204f5e <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f5e:	7159                	addi	sp,sp,-112
ffffffffc0204f60:	e8ca                	sd	s2,80(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f62:	000ae917          	auipc	s2,0xae
ffffffffc0204f66:	92690913          	addi	s2,s2,-1754 # ffffffffc02b2888 <nr_process>
ffffffffc0204f6a:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f6e:	f486                	sd	ra,104(sp)
ffffffffc0204f70:	f0a2                	sd	s0,96(sp)
ffffffffc0204f72:	eca6                	sd	s1,88(sp)
ffffffffc0204f74:	e4ce                	sd	s3,72(sp)
ffffffffc0204f76:	e0d2                	sd	s4,64(sp)
ffffffffc0204f78:	fc56                	sd	s5,56(sp)
ffffffffc0204f7a:	f85a                	sd	s6,48(sp)
ffffffffc0204f7c:	f45e                	sd	s7,40(sp)
ffffffffc0204f7e:	f062                	sd	s8,32(sp)
ffffffffc0204f80:	ec66                	sd	s9,24(sp)
ffffffffc0204f82:	e86a                	sd	s10,16(sp)
ffffffffc0204f84:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f86:	6785                	lui	a5,0x1
ffffffffc0204f88:	34f75063          	bge	a4,a5,ffffffffc02052c8 <do_fork+0x36a>
ffffffffc0204f8c:	8a2a                	mv	s4,a0
ffffffffc0204f8e:	89ae                	mv	s3,a1
ffffffffc0204f90:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc0204f92:	dedff0ef          	jal	ra,ffffffffc0204d7e <alloc_proc>
ffffffffc0204f96:	84aa                	mv	s1,a0
ffffffffc0204f98:	2c050863          	beqz	a0,ffffffffc0205268 <do_fork+0x30a>
    proc->parent = current;
ffffffffc0204f9c:	000aea97          	auipc	s5,0xae
ffffffffc0204fa0:	8d4a8a93          	addi	s5,s5,-1836 # ffffffffc02b2870 <current>
ffffffffc0204fa4:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state == 0);
ffffffffc0204fa8:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8acc>
    proc->parent = current;
ffffffffc0204fac:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0204fae:	38071363          	bnez	a4,ffffffffc0205334 <do_fork+0x3d6>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204fb2:	4509                	li	a0,2
ffffffffc0204fb4:	eeffb0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
    if (page != NULL) {
ffffffffc0204fb8:	2c050763          	beqz	a0,ffffffffc0205286 <do_fork+0x328>
    return page - pages + nbase;
ffffffffc0204fbc:	000aed97          	auipc	s11,0xae
ffffffffc0204fc0:	86cd8d93          	addi	s11,s11,-1940 # ffffffffc02b2828 <pages>
ffffffffc0204fc4:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0204fc8:	000aed17          	auipc	s10,0xae
ffffffffc0204fcc:	858d0d13          	addi	s10,s10,-1960 # ffffffffc02b2820 <npage>
    return page - pages + nbase;
ffffffffc0204fd0:	00004c97          	auipc	s9,0x4
ffffffffc0204fd4:	da0cbc83          	ld	s9,-608(s9) # ffffffffc0208d70 <nbase>
ffffffffc0204fd8:	40d506b3          	sub	a3,a0,a3
ffffffffc0204fdc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204fde:	5c7d                	li	s8,-1
ffffffffc0204fe0:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204fe4:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0204fe6:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0204fea:	0186f733          	and	a4,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0204fee:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ff0:	30f77963          	bgeu	a4,a5,ffffffffc0205302 <do_fork+0x3a4>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204ff4:	000ab703          	ld	a4,0(s5)
ffffffffc0204ff8:	000aea97          	auipc	s5,0xae
ffffffffc0204ffc:	840a8a93          	addi	s5,s5,-1984 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0205000:	000ab783          	ld	a5,0(s5)
ffffffffc0205004:	02873b83          	ld	s7,40(a4)
ffffffffc0205008:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020500a:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc020500c:	020b8863          	beqz	s7,ffffffffc020503c <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0205010:	100a7a13          	andi	s4,s4,256
ffffffffc0205014:	1c0a0163          	beqz	s4,ffffffffc02051d6 <do_fork+0x278>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205018:	030ba703          	lw	a4,48(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020501c:	018bb783          	ld	a5,24(s7)
ffffffffc0205020:	c02006b7          	lui	a3,0xc0200
ffffffffc0205024:	2705                	addiw	a4,a4,1
ffffffffc0205026:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc020502a:	0374b423          	sd	s7,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020502e:	2ed7e663          	bltu	a5,a3,ffffffffc020531a <do_fork+0x3bc>
ffffffffc0205032:	000ab703          	ld	a4,0(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205036:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205038:	8f99                	sub	a5,a5,a4
ffffffffc020503a:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020503c:	6789                	lui	a5,0x2
ffffffffc020503e:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>
ffffffffc0205042:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0205044:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205046:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0205048:	87b6                	mv	a5,a3
ffffffffc020504a:	12040893          	addi	a7,s0,288
ffffffffc020504e:	00063803          	ld	a6,0(a2)
ffffffffc0205052:	6608                	ld	a0,8(a2)
ffffffffc0205054:	6a0c                	ld	a1,16(a2)
ffffffffc0205056:	6e18                	ld	a4,24(a2)
ffffffffc0205058:	0107b023          	sd	a6,0(a5)
ffffffffc020505c:	e788                	sd	a0,8(a5)
ffffffffc020505e:	eb8c                	sd	a1,16(a5)
ffffffffc0205060:	ef98                	sd	a4,24(a5)
ffffffffc0205062:	02060613          	addi	a2,a2,32
ffffffffc0205066:	02078793          	addi	a5,a5,32
ffffffffc020506a:	ff1612e3          	bne	a2,a7,ffffffffc020504e <do_fork+0xf0>
    proc->tf->gpr.a0 = 0;
ffffffffc020506e:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205072:	12098f63          	beqz	s3,ffffffffc02051b0 <do_fork+0x252>
ffffffffc0205076:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020507a:	00000797          	auipc	a5,0x0
ffffffffc020507e:	d7678793          	addi	a5,a5,-650 # ffffffffc0204df0 <forkret>
ffffffffc0205082:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205084:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205086:	100027f3          	csrr	a5,sstatus
ffffffffc020508a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020508c:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020508e:	14079063          	bnez	a5,ffffffffc02051ce <do_fork+0x270>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205092:	000a2817          	auipc	a6,0xa2
ffffffffc0205096:	29680813          	addi	a6,a6,662 # ffffffffc02a7328 <last_pid.1>
ffffffffc020509a:	00082783          	lw	a5,0(a6)
ffffffffc020509e:	6709                	lui	a4,0x2
ffffffffc02050a0:	0017851b          	addiw	a0,a5,1
ffffffffc02050a4:	00a82023          	sw	a0,0(a6)
ffffffffc02050a8:	08e55d63          	bge	a0,a4,ffffffffc0205142 <do_fork+0x1e4>
    if (last_pid >= next_safe) {
ffffffffc02050ac:	000a2317          	auipc	t1,0xa2
ffffffffc02050b0:	28030313          	addi	t1,t1,640 # ffffffffc02a732c <next_safe.0>
ffffffffc02050b4:	00032783          	lw	a5,0(t1)
ffffffffc02050b8:	000ad417          	auipc	s0,0xad
ffffffffc02050bc:	73040413          	addi	s0,s0,1840 # ffffffffc02b27e8 <proc_list>
ffffffffc02050c0:	08f55963          	bge	a0,a5,ffffffffc0205152 <do_fork+0x1f4>
        proc->pid = get_pid();
ffffffffc02050c4:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02050c6:	45a9                	li	a1,10
ffffffffc02050c8:	2501                	sext.w	a0,a0
ffffffffc02050ca:	53e010ef          	jal	ra,ffffffffc0206608 <hash32>
ffffffffc02050ce:	02051793          	slli	a5,a0,0x20
ffffffffc02050d2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02050d6:	000a9797          	auipc	a5,0xa9
ffffffffc02050da:	71278793          	addi	a5,a5,1810 # ffffffffc02ae7e8 <hash_list>
ffffffffc02050de:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02050e0:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050e2:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02050e4:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc02050e8:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02050ea:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02050ec:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050ee:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02050f0:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc02050f4:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc02050f6:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02050f8:	e21c                	sd	a5,0(a2)
ffffffffc02050fa:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02050fc:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc02050fe:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc0205100:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205104:	10e4b023          	sd	a4,256(s1)
ffffffffc0205108:	c311                	beqz	a4,ffffffffc020510c <do_fork+0x1ae>
        proc->optr->yptr = proc;
ffffffffc020510a:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc020510c:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0205110:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc0205112:	2785                	addiw	a5,a5,1
ffffffffc0205114:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc0205118:	14099a63          	bnez	s3,ffffffffc020526c <do_fork+0x30e>
    wakeup_proc(proc);
ffffffffc020511c:	8526                	mv	a0,s1
ffffffffc020511e:	66b000ef          	jal	ra,ffffffffc0205f88 <wakeup_proc>
    ret = proc->pid; 
ffffffffc0205122:	40c8                	lw	a0,4(s1)
}
ffffffffc0205124:	70a6                	ld	ra,104(sp)
ffffffffc0205126:	7406                	ld	s0,96(sp)
ffffffffc0205128:	64e6                	ld	s1,88(sp)
ffffffffc020512a:	6946                	ld	s2,80(sp)
ffffffffc020512c:	69a6                	ld	s3,72(sp)
ffffffffc020512e:	6a06                	ld	s4,64(sp)
ffffffffc0205130:	7ae2                	ld	s5,56(sp)
ffffffffc0205132:	7b42                	ld	s6,48(sp)
ffffffffc0205134:	7ba2                	ld	s7,40(sp)
ffffffffc0205136:	7c02                	ld	s8,32(sp)
ffffffffc0205138:	6ce2                	ld	s9,24(sp)
ffffffffc020513a:	6d42                	ld	s10,16(sp)
ffffffffc020513c:	6da2                	ld	s11,8(sp)
ffffffffc020513e:	6165                	addi	sp,sp,112
ffffffffc0205140:	8082                	ret
        last_pid = 1;
ffffffffc0205142:	4785                	li	a5,1
ffffffffc0205144:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0205148:	4505                	li	a0,1
ffffffffc020514a:	000a2317          	auipc	t1,0xa2
ffffffffc020514e:	1e230313          	addi	t1,t1,482 # ffffffffc02a732c <next_safe.0>
    return listelm->next;
ffffffffc0205152:	000ad417          	auipc	s0,0xad
ffffffffc0205156:	69640413          	addi	s0,s0,1686 # ffffffffc02b27e8 <proc_list>
ffffffffc020515a:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc020515e:	6789                	lui	a5,0x2
ffffffffc0205160:	00f32023          	sw	a5,0(t1)
ffffffffc0205164:	86aa                	mv	a3,a0
ffffffffc0205166:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0205168:	6e89                	lui	t4,0x2
ffffffffc020516a:	108e0963          	beq	t3,s0,ffffffffc020527c <do_fork+0x31e>
ffffffffc020516e:	88ae                	mv	a7,a1
ffffffffc0205170:	87f2                	mv	a5,t3
ffffffffc0205172:	6609                	lui	a2,0x2
ffffffffc0205174:	a811                	j	ffffffffc0205188 <do_fork+0x22a>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205176:	00e6d663          	bge	a3,a4,ffffffffc0205182 <do_fork+0x224>
ffffffffc020517a:	00c75463          	bge	a4,a2,ffffffffc0205182 <do_fork+0x224>
ffffffffc020517e:	863a                	mv	a2,a4
ffffffffc0205180:	4885                	li	a7,1
ffffffffc0205182:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205184:	00878d63          	beq	a5,s0,ffffffffc020519e <do_fork+0x240>
            if (proc->pid == last_pid) {
ffffffffc0205188:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc020518c:	fed715e3          	bne	a4,a3,ffffffffc0205176 <do_fork+0x218>
                if (++ last_pid >= next_safe) {
ffffffffc0205190:	2685                	addiw	a3,a3,1
ffffffffc0205192:	0ec6d063          	bge	a3,a2,ffffffffc0205272 <do_fork+0x314>
ffffffffc0205196:	679c                	ld	a5,8(a5)
ffffffffc0205198:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020519a:	fe8797e3          	bne	a5,s0,ffffffffc0205188 <do_fork+0x22a>
ffffffffc020519e:	c581                	beqz	a1,ffffffffc02051a6 <do_fork+0x248>
ffffffffc02051a0:	00d82023          	sw	a3,0(a6)
ffffffffc02051a4:	8536                	mv	a0,a3
ffffffffc02051a6:	f0088fe3          	beqz	a7,ffffffffc02050c4 <do_fork+0x166>
ffffffffc02051aa:	00c32023          	sw	a2,0(t1)
ffffffffc02051ae:	bf19                	j	ffffffffc02050c4 <do_fork+0x166>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02051b0:	89b6                	mv	s3,a3
ffffffffc02051b2:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02051b6:	00000797          	auipc	a5,0x0
ffffffffc02051ba:	c3a78793          	addi	a5,a5,-966 # ffffffffc0204df0 <forkret>
ffffffffc02051be:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02051c0:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051c2:	100027f3          	csrr	a5,sstatus
ffffffffc02051c6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02051c8:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051ca:	ec0784e3          	beqz	a5,ffffffffc0205092 <do_fork+0x134>
        intr_disable();
ffffffffc02051ce:	c7afb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02051d2:	4985                	li	s3,1
ffffffffc02051d4:	bd7d                	j	ffffffffc0205092 <do_fork+0x134>
    if ((mm = mm_create()) == NULL) {
ffffffffc02051d6:	805fd0ef          	jal	ra,ffffffffc02029da <mm_create>
ffffffffc02051da:	8b2a                	mv	s6,a0
ffffffffc02051dc:	c159                	beqz	a0,ffffffffc0205262 <do_fork+0x304>
    if ((page = alloc_page()) == NULL) {
ffffffffc02051de:	4505                	li	a0,1
ffffffffc02051e0:	cc3fb0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc02051e4:	cd25                	beqz	a0,ffffffffc020525c <do_fork+0x2fe>
    return page - pages + nbase;
ffffffffc02051e6:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc02051ea:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc02051ee:	40d506b3          	sub	a3,a0,a3
ffffffffc02051f2:	8699                	srai	a3,a3,0x6
ffffffffc02051f4:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc02051f6:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc02051fa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02051fc:	10fc7363          	bgeu	s8,a5,ffffffffc0205302 <do_fork+0x3a4>
ffffffffc0205200:	000aba03          	ld	s4,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205204:	6605                	lui	a2,0x1
ffffffffc0205206:	000ad597          	auipc	a1,0xad
ffffffffc020520a:	6125b583          	ld	a1,1554(a1) # ffffffffc02b2818 <boot_pgdir>
ffffffffc020520e:	9a36                	add	s4,s4,a3
ffffffffc0205210:	8552                	mv	a0,s4
ffffffffc0205212:	7f1000ef          	jal	ra,ffffffffc0206202 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205216:	038b8c13          	addi	s8,s7,56
    mm->pgdir = pgdir;
ffffffffc020521a:	014b3c23          	sd	s4,24(s6)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020521e:	4785                	li	a5,1
ffffffffc0205220:	40fc37af          	amoor.d	a5,a5,(s8)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205224:	8b85                	andi	a5,a5,1
ffffffffc0205226:	4a05                	li	s4,1
ffffffffc0205228:	c799                	beqz	a5,ffffffffc0205236 <do_fork+0x2d8>
        schedule();
ffffffffc020522a:	5df000ef          	jal	ra,ffffffffc0206008 <schedule>
ffffffffc020522e:	414c37af          	amoor.d	a5,s4,(s8)
    while (!try_lock(lock)) {
ffffffffc0205232:	8b85                	andi	a5,a5,1
ffffffffc0205234:	fbfd                	bnez	a5,ffffffffc020522a <do_fork+0x2cc>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205236:	85de                	mv	a1,s7
ffffffffc0205238:	855a                	mv	a0,s6
ffffffffc020523a:	a29fd0ef          	jal	ra,ffffffffc0202c62 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020523e:	57f9                	li	a5,-2
ffffffffc0205240:	60fc37af          	amoand.d	a5,a5,(s8)
ffffffffc0205244:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205246:	10078763          	beqz	a5,ffffffffc0205354 <do_fork+0x3f6>
good_mm:
ffffffffc020524a:	8bda                	mv	s7,s6
    if (ret != 0) {
ffffffffc020524c:	dc0506e3          	beqz	a0,ffffffffc0205018 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205250:	855a                	mv	a0,s6
ffffffffc0205252:	aabfd0ef          	jal	ra,ffffffffc0202cfc <exit_mmap>
    put_pgdir(mm);
ffffffffc0205256:	855a                	mv	a0,s6
ffffffffc0205258:	c25ff0ef          	jal	ra,ffffffffc0204e7c <put_pgdir>
    mm_destroy(mm);
ffffffffc020525c:	855a                	mv	a0,s6
ffffffffc020525e:	903fd0ef          	jal	ra,ffffffffc0202b60 <mm_destroy>
    kfree(proc);
ffffffffc0205262:	8526                	mv	a0,s1
ffffffffc0205264:	ca4fe0ef          	jal	ra,ffffffffc0203708 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205268:	5571                	li	a0,-4
    return ret;
ffffffffc020526a:	bd6d                	j	ffffffffc0205124 <do_fork+0x1c6>
        intr_enable();
ffffffffc020526c:	bd6fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205270:	b575                	j	ffffffffc020511c <do_fork+0x1be>
                    if (last_pid >= MAX_PID) {
ffffffffc0205272:	01d6c363          	blt	a3,t4,ffffffffc0205278 <do_fork+0x31a>
                        last_pid = 1;
ffffffffc0205276:	4685                	li	a3,1
                    goto repeat;
ffffffffc0205278:	4585                	li	a1,1
ffffffffc020527a:	bdc5                	j	ffffffffc020516a <do_fork+0x20c>
ffffffffc020527c:	c9a1                	beqz	a1,ffffffffc02052cc <do_fork+0x36e>
ffffffffc020527e:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0205282:	8536                	mv	a0,a3
ffffffffc0205284:	b581                	j	ffffffffc02050c4 <do_fork+0x166>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205286:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc0205288:	c02007b7          	lui	a5,0xc0200
ffffffffc020528c:	04f6ef63          	bltu	a3,a5,ffffffffc02052ea <do_fork+0x38c>
ffffffffc0205290:	000ad797          	auipc	a5,0xad
ffffffffc0205294:	5a87b783          	ld	a5,1448(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0205298:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020529c:	83b1                	srli	a5,a5,0xc
ffffffffc020529e:	000ad717          	auipc	a4,0xad
ffffffffc02052a2:	58273703          	ld	a4,1410(a4) # ffffffffc02b2820 <npage>
ffffffffc02052a6:	02e7f663          	bgeu	a5,a4,ffffffffc02052d2 <do_fork+0x374>
    return &pages[PPN(pa) - nbase];
ffffffffc02052aa:	00004717          	auipc	a4,0x4
ffffffffc02052ae:	ac673703          	ld	a4,-1338(a4) # ffffffffc0208d70 <nbase>
ffffffffc02052b2:	8f99                	sub	a5,a5,a4
ffffffffc02052b4:	079a                	slli	a5,a5,0x6
ffffffffc02052b6:	000ad517          	auipc	a0,0xad
ffffffffc02052ba:	57253503          	ld	a0,1394(a0) # ffffffffc02b2828 <pages>
ffffffffc02052be:	4589                	li	a1,2
ffffffffc02052c0:	953e                	add	a0,a0,a5
ffffffffc02052c2:	c73fb0ef          	jal	ra,ffffffffc0200f34 <free_pages>
}
ffffffffc02052c6:	bf71                	j	ffffffffc0205262 <do_fork+0x304>
    int ret = -E_NO_FREE_PROC;
ffffffffc02052c8:	556d                	li	a0,-5
ffffffffc02052ca:	bda9                	j	ffffffffc0205124 <do_fork+0x1c6>
    return last_pid;
ffffffffc02052cc:	00082503          	lw	a0,0(a6)
ffffffffc02052d0:	bbd5                	j	ffffffffc02050c4 <do_fork+0x166>
        panic("pa2page called with invalid pa");
ffffffffc02052d2:	00002617          	auipc	a2,0x2
ffffffffc02052d6:	d6e60613          	addi	a2,a2,-658 # ffffffffc0207040 <commands+0x778>
ffffffffc02052da:	06200593          	li	a1,98
ffffffffc02052de:	00002517          	auipc	a0,0x2
ffffffffc02052e2:	d8250513          	addi	a0,a0,-638 # ffffffffc0207060 <commands+0x798>
ffffffffc02052e6:	f23fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02052ea:	00002617          	auipc	a2,0x2
ffffffffc02052ee:	e8660613          	addi	a2,a2,-378 # ffffffffc0207170 <commands+0x8a8>
ffffffffc02052f2:	06e00593          	li	a1,110
ffffffffc02052f6:	00002517          	auipc	a0,0x2
ffffffffc02052fa:	d6a50513          	addi	a0,a0,-662 # ffffffffc0207060 <commands+0x798>
ffffffffc02052fe:	f0bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0205302:	00002617          	auipc	a2,0x2
ffffffffc0205306:	d9660613          	addi	a2,a2,-618 # ffffffffc0207098 <commands+0x7d0>
ffffffffc020530a:	06900593          	li	a1,105
ffffffffc020530e:	00002517          	auipc	a0,0x2
ffffffffc0205312:	d5250513          	addi	a0,a0,-686 # ffffffffc0207060 <commands+0x798>
ffffffffc0205316:	ef3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020531a:	86be                	mv	a3,a5
ffffffffc020531c:	00002617          	auipc	a2,0x2
ffffffffc0205320:	e5460613          	addi	a2,a2,-428 # ffffffffc0207170 <commands+0x8a8>
ffffffffc0205324:	16400593          	li	a1,356
ffffffffc0205328:	00003517          	auipc	a0,0x3
ffffffffc020532c:	19050513          	addi	a0,a0,400 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205330:	ed9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(current->wait_state == 0);
ffffffffc0205334:	00003697          	auipc	a3,0x3
ffffffffc0205338:	19c68693          	addi	a3,a3,412 # ffffffffc02084d0 <default_pmm_manager+0x110>
ffffffffc020533c:	00002617          	auipc	a2,0x2
ffffffffc0205340:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205344:	1a800593          	li	a1,424
ffffffffc0205348:	00003517          	auipc	a0,0x3
ffffffffc020534c:	17050513          	addi	a0,a0,368 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205350:	eb9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205354:	00003617          	auipc	a2,0x3
ffffffffc0205358:	19c60613          	addi	a2,a2,412 # ffffffffc02084f0 <default_pmm_manager+0x130>
ffffffffc020535c:	03100593          	li	a1,49
ffffffffc0205360:	00003517          	auipc	a0,0x3
ffffffffc0205364:	1a050513          	addi	a0,a0,416 # ffffffffc0208500 <default_pmm_manager+0x140>
ffffffffc0205368:	ea1fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020536c <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020536c:	7129                	addi	sp,sp,-320
ffffffffc020536e:	fa22                	sd	s0,304(sp)
ffffffffc0205370:	f626                	sd	s1,296(sp)
ffffffffc0205372:	f24a                	sd	s2,288(sp)
ffffffffc0205374:	84ae                	mv	s1,a1
ffffffffc0205376:	892a                	mv	s2,a0
ffffffffc0205378:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020537a:	4581                	li	a1,0
ffffffffc020537c:	12000613          	li	a2,288
ffffffffc0205380:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205382:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205384:	66d000ef          	jal	ra,ffffffffc02061f0 <memset>
    tf.gpr.s0 = (uintptr_t)fn; // 线程函数地址
ffffffffc0205388:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg; // 线程函数参数
ffffffffc020538a:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020538c:	100027f3          	csrr	a5,sstatus
ffffffffc0205390:	edd7f793          	andi	a5,a5,-291
ffffffffc0205394:	1207e793          	ori	a5,a5,288
ffffffffc0205398:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020539a:	860a                	mv	a2,sp
ffffffffc020539c:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry; // 线程函数入口
ffffffffc02053a0:	00000797          	auipc	a5,0x0
ffffffffc02053a4:	9d678793          	addi	a5,a5,-1578 # ffffffffc0204d76 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053a8:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry; // 线程函数入口
ffffffffc02053aa:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053ac:	bb3ff0ef          	jal	ra,ffffffffc0204f5e <do_fork>
}
ffffffffc02053b0:	70f2                	ld	ra,312(sp)
ffffffffc02053b2:	7452                	ld	s0,304(sp)
ffffffffc02053b4:	74b2                	ld	s1,296(sp)
ffffffffc02053b6:	7912                	ld	s2,288(sp)
ffffffffc02053b8:	6131                	addi	sp,sp,320
ffffffffc02053ba:	8082                	ret

ffffffffc02053bc <do_exit>:
do_exit(int error_code) {
ffffffffc02053bc:	7179                	addi	sp,sp,-48
ffffffffc02053be:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc02053c0:	000ad417          	auipc	s0,0xad
ffffffffc02053c4:	4b040413          	addi	s0,s0,1200 # ffffffffc02b2870 <current>
ffffffffc02053c8:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc02053ca:	f406                	sd	ra,40(sp)
ffffffffc02053cc:	ec26                	sd	s1,24(sp)
ffffffffc02053ce:	e84a                	sd	s2,16(sp)
ffffffffc02053d0:	e44e                	sd	s3,8(sp)
ffffffffc02053d2:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02053d4:	000ad717          	auipc	a4,0xad
ffffffffc02053d8:	4a473703          	ld	a4,1188(a4) # ffffffffc02b2878 <idleproc>
ffffffffc02053dc:	0ce78c63          	beq	a5,a4,ffffffffc02054b4 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc02053e0:	000ad497          	auipc	s1,0xad
ffffffffc02053e4:	4a048493          	addi	s1,s1,1184 # ffffffffc02b2880 <initproc>
ffffffffc02053e8:	6098                	ld	a4,0(s1)
ffffffffc02053ea:	0ee78b63          	beq	a5,a4,ffffffffc02054e0 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02053ee:	0287b983          	ld	s3,40(a5)
ffffffffc02053f2:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc02053f4:	02098663          	beqz	s3,ffffffffc0205420 <do_exit+0x64>
ffffffffc02053f8:	000ad797          	auipc	a5,0xad
ffffffffc02053fc:	4187b783          	ld	a5,1048(a5) # ffffffffc02b2810 <boot_cr3>
ffffffffc0205400:	577d                	li	a4,-1
ffffffffc0205402:	177e                	slli	a4,a4,0x3f
ffffffffc0205404:	83b1                	srli	a5,a5,0xc
ffffffffc0205406:	8fd9                	or	a5,a5,a4
ffffffffc0205408:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020540c:	0309a783          	lw	a5,48(s3)
ffffffffc0205410:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205414:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205418:	cb55                	beqz	a4,ffffffffc02054cc <do_exit+0x110>
        current->mm = NULL;
ffffffffc020541a:	601c                	ld	a5,0(s0)
ffffffffc020541c:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205420:	601c                	ld	a5,0(s0)
ffffffffc0205422:	470d                	li	a4,3
ffffffffc0205424:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205426:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020542a:	100027f3          	csrr	a5,sstatus
ffffffffc020542e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205430:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205432:	e3f9                	bnez	a5,ffffffffc02054f8 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0205434:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205436:	800007b7          	lui	a5,0x80000
ffffffffc020543a:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020543c:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020543e:	0ec52703          	lw	a4,236(a0)
ffffffffc0205442:	0af70f63          	beq	a4,a5,ffffffffc0205500 <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc0205446:	6018                	ld	a4,0(s0)
ffffffffc0205448:	7b7c                	ld	a5,240(a4)
ffffffffc020544a:	c3a1                	beqz	a5,ffffffffc020548a <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020544c:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205450:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205452:	0985                	addi	s3,s3,1
ffffffffc0205454:	a021                	j	ffffffffc020545c <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc0205456:	6018                	ld	a4,0(s0)
ffffffffc0205458:	7b7c                	ld	a5,240(a4)
ffffffffc020545a:	cb85                	beqz	a5,ffffffffc020548a <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc020545c:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd8>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205460:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0205462:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205464:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205466:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020546a:	10e7b023          	sd	a4,256(a5)
ffffffffc020546e:	c311                	beqz	a4,ffffffffc0205472 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0205470:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205472:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205474:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205476:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205478:	fd271fe3          	bne	a4,s2,ffffffffc0205456 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020547c:	0ec52783          	lw	a5,236(a0)
ffffffffc0205480:	fd379be3          	bne	a5,s3,ffffffffc0205456 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205484:	305000ef          	jal	ra,ffffffffc0205f88 <wakeup_proc>
ffffffffc0205488:	b7f9                	j	ffffffffc0205456 <do_exit+0x9a>
    if (flag) {
ffffffffc020548a:	020a1263          	bnez	s4,ffffffffc02054ae <do_exit+0xf2>
    schedule();
ffffffffc020548e:	37b000ef          	jal	ra,ffffffffc0206008 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205492:	601c                	ld	a5,0(s0)
ffffffffc0205494:	00003617          	auipc	a2,0x3
ffffffffc0205498:	0a460613          	addi	a2,a2,164 # ffffffffc0208538 <default_pmm_manager+0x178>
ffffffffc020549c:	20000593          	li	a1,512
ffffffffc02054a0:	43d4                	lw	a3,4(a5)
ffffffffc02054a2:	00003517          	auipc	a0,0x3
ffffffffc02054a6:	01650513          	addi	a0,a0,22 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc02054aa:	d5ffa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc02054ae:	994fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02054b2:	bff1                	j	ffffffffc020548e <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02054b4:	00003617          	auipc	a2,0x3
ffffffffc02054b8:	06460613          	addi	a2,a2,100 # ffffffffc0208518 <default_pmm_manager+0x158>
ffffffffc02054bc:	1d400593          	li	a1,468
ffffffffc02054c0:	00003517          	auipc	a0,0x3
ffffffffc02054c4:	ff850513          	addi	a0,a0,-8 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc02054c8:	d41fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc02054cc:	854e                	mv	a0,s3
ffffffffc02054ce:	82ffd0ef          	jal	ra,ffffffffc0202cfc <exit_mmap>
            put_pgdir(mm);
ffffffffc02054d2:	854e                	mv	a0,s3
ffffffffc02054d4:	9a9ff0ef          	jal	ra,ffffffffc0204e7c <put_pgdir>
            mm_destroy(mm);
ffffffffc02054d8:	854e                	mv	a0,s3
ffffffffc02054da:	e86fd0ef          	jal	ra,ffffffffc0202b60 <mm_destroy>
ffffffffc02054de:	bf35                	j	ffffffffc020541a <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02054e0:	00003617          	auipc	a2,0x3
ffffffffc02054e4:	04860613          	addi	a2,a2,72 # ffffffffc0208528 <default_pmm_manager+0x168>
ffffffffc02054e8:	1d700593          	li	a1,471
ffffffffc02054ec:	00003517          	auipc	a0,0x3
ffffffffc02054f0:	fcc50513          	addi	a0,a0,-52 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc02054f4:	d15fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc02054f8:	950fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02054fc:	4a05                	li	s4,1
ffffffffc02054fe:	bf1d                	j	ffffffffc0205434 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0205500:	289000ef          	jal	ra,ffffffffc0205f88 <wakeup_proc>
ffffffffc0205504:	b789                	j	ffffffffc0205446 <do_exit+0x8a>

ffffffffc0205506 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc0205506:	715d                	addi	sp,sp,-80
ffffffffc0205508:	f84a                	sd	s2,48(sp)
ffffffffc020550a:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc020550c:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205510:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc0205512:	fc26                	sd	s1,56(sp)
ffffffffc0205514:	f052                	sd	s4,32(sp)
ffffffffc0205516:	ec56                	sd	s5,24(sp)
ffffffffc0205518:	e85a                	sd	s6,16(sp)
ffffffffc020551a:	e45e                	sd	s7,8(sp)
ffffffffc020551c:	e486                	sd	ra,72(sp)
ffffffffc020551e:	e0a2                	sd	s0,64(sp)
ffffffffc0205520:	84aa                	mv	s1,a0
ffffffffc0205522:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0205524:	000adb97          	auipc	s7,0xad
ffffffffc0205528:	34cb8b93          	addi	s7,s7,844 # ffffffffc02b2870 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020552c:	00050b1b          	sext.w	s6,a0
ffffffffc0205530:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0205534:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0205536:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc0205538:	ccbd                	beqz	s1,ffffffffc02055b6 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020553a:	0359e863          	bltu	s3,s5,ffffffffc020556a <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020553e:	45a9                	li	a1,10
ffffffffc0205540:	855a                	mv	a0,s6
ffffffffc0205542:	0c6010ef          	jal	ra,ffffffffc0206608 <hash32>
ffffffffc0205546:	02051793          	slli	a5,a0,0x20
ffffffffc020554a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020554e:	000a9797          	auipc	a5,0xa9
ffffffffc0205552:	29a78793          	addi	a5,a5,666 # ffffffffc02ae7e8 <hash_list>
ffffffffc0205556:	953e                	add	a0,a0,a5
ffffffffc0205558:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc020555a:	a029                	j	ffffffffc0205564 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc020555c:	f2c42783          	lw	a5,-212(s0)
ffffffffc0205560:	02978163          	beq	a5,s1,ffffffffc0205582 <do_wait.part.0+0x7c>
ffffffffc0205564:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0205566:	fe851be3          	bne	a0,s0,ffffffffc020555c <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc020556a:	5579                	li	a0,-2
}
ffffffffc020556c:	60a6                	ld	ra,72(sp)
ffffffffc020556e:	6406                	ld	s0,64(sp)
ffffffffc0205570:	74e2                	ld	s1,56(sp)
ffffffffc0205572:	7942                	ld	s2,48(sp)
ffffffffc0205574:	79a2                	ld	s3,40(sp)
ffffffffc0205576:	7a02                	ld	s4,32(sp)
ffffffffc0205578:	6ae2                	ld	s5,24(sp)
ffffffffc020557a:	6b42                	ld	s6,16(sp)
ffffffffc020557c:	6ba2                	ld	s7,8(sp)
ffffffffc020557e:	6161                	addi	sp,sp,80
ffffffffc0205580:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc0205582:	000bb683          	ld	a3,0(s7)
ffffffffc0205586:	f4843783          	ld	a5,-184(s0)
ffffffffc020558a:	fed790e3          	bne	a5,a3,ffffffffc020556a <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020558e:	f2842703          	lw	a4,-216(s0)
ffffffffc0205592:	478d                	li	a5,3
ffffffffc0205594:	0ef70b63          	beq	a4,a5,ffffffffc020568a <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205598:	4785                	li	a5,1
ffffffffc020559a:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc020559c:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02055a0:	269000ef          	jal	ra,ffffffffc0206008 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02055a4:	000bb783          	ld	a5,0(s7)
ffffffffc02055a8:	0b07a783          	lw	a5,176(a5)
ffffffffc02055ac:	8b85                	andi	a5,a5,1
ffffffffc02055ae:	d7c9                	beqz	a5,ffffffffc0205538 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02055b0:	555d                	li	a0,-9
ffffffffc02055b2:	e0bff0ef          	jal	ra,ffffffffc02053bc <do_exit>
        proc = current->cptr;
ffffffffc02055b6:	000bb683          	ld	a3,0(s7)
ffffffffc02055ba:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055bc:	d45d                	beqz	s0,ffffffffc020556a <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055be:	470d                	li	a4,3
ffffffffc02055c0:	a021                	j	ffffffffc02055c8 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055c2:	10043403          	ld	s0,256(s0)
ffffffffc02055c6:	d869                	beqz	s0,ffffffffc0205598 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055c8:	401c                	lw	a5,0(s0)
ffffffffc02055ca:	fee79ce3          	bne	a5,a4,ffffffffc02055c2 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055ce:	000ad797          	auipc	a5,0xad
ffffffffc02055d2:	2aa7b783          	ld	a5,682(a5) # ffffffffc02b2878 <idleproc>
ffffffffc02055d6:	0c878963          	beq	a5,s0,ffffffffc02056a8 <do_wait.part.0+0x1a2>
ffffffffc02055da:	000ad797          	auipc	a5,0xad
ffffffffc02055de:	2a67b783          	ld	a5,678(a5) # ffffffffc02b2880 <initproc>
ffffffffc02055e2:	0cf40363          	beq	s0,a5,ffffffffc02056a8 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc02055e6:	000a0663          	beqz	s4,ffffffffc02055f2 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02055ea:	0e842783          	lw	a5,232(s0)
ffffffffc02055ee:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055f2:	100027f3          	csrr	a5,sstatus
ffffffffc02055f6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055f8:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055fa:	e7c1                	bnez	a5,ffffffffc0205682 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055fc:	6c70                	ld	a2,216(s0)
ffffffffc02055fe:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205600:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0205604:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205606:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205608:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020560a:	6470                	ld	a2,200(s0)
ffffffffc020560c:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020560e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205610:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc0205612:	c319                	beqz	a4,ffffffffc0205618 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0205614:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205616:	7c7c                	ld	a5,248(s0)
ffffffffc0205618:	c3b5                	beqz	a5,ffffffffc020567c <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc020561a:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020561e:	000ad717          	auipc	a4,0xad
ffffffffc0205622:	26a70713          	addi	a4,a4,618 # ffffffffc02b2888 <nr_process>
ffffffffc0205626:	431c                	lw	a5,0(a4)
ffffffffc0205628:	37fd                	addiw	a5,a5,-1
ffffffffc020562a:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc020562c:	e5a9                	bnez	a1,ffffffffc0205676 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020562e:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205630:	c02007b7          	lui	a5,0xc0200
ffffffffc0205634:	04f6ee63          	bltu	a3,a5,ffffffffc0205690 <do_wait.part.0+0x18a>
ffffffffc0205638:	000ad797          	auipc	a5,0xad
ffffffffc020563c:	2007b783          	ld	a5,512(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0205640:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205642:	82b1                	srli	a3,a3,0xc
ffffffffc0205644:	000ad797          	auipc	a5,0xad
ffffffffc0205648:	1dc7b783          	ld	a5,476(a5) # ffffffffc02b2820 <npage>
ffffffffc020564c:	06f6fa63          	bgeu	a3,a5,ffffffffc02056c0 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0205650:	00003517          	auipc	a0,0x3
ffffffffc0205654:	72053503          	ld	a0,1824(a0) # ffffffffc0208d70 <nbase>
ffffffffc0205658:	8e89                	sub	a3,a3,a0
ffffffffc020565a:	069a                	slli	a3,a3,0x6
ffffffffc020565c:	000ad517          	auipc	a0,0xad
ffffffffc0205660:	1cc53503          	ld	a0,460(a0) # ffffffffc02b2828 <pages>
ffffffffc0205664:	9536                	add	a0,a0,a3
ffffffffc0205666:	4589                	li	a1,2
ffffffffc0205668:	8cdfb0ef          	jal	ra,ffffffffc0200f34 <free_pages>
    kfree(proc);
ffffffffc020566c:	8522                	mv	a0,s0
ffffffffc020566e:	89afe0ef          	jal	ra,ffffffffc0203708 <kfree>
    return 0;
ffffffffc0205672:	4501                	li	a0,0
ffffffffc0205674:	bde5                	j	ffffffffc020556c <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0205676:	fcdfa0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020567a:	bf55                	j	ffffffffc020562e <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc020567c:	701c                	ld	a5,32(s0)
ffffffffc020567e:	fbf8                	sd	a4,240(a5)
ffffffffc0205680:	bf79                	j	ffffffffc020561e <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0205682:	fc7fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0205686:	4585                	li	a1,1
ffffffffc0205688:	bf95                	j	ffffffffc02055fc <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020568a:	f2840413          	addi	s0,s0,-216
ffffffffc020568e:	b781                	j	ffffffffc02055ce <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0205690:	00002617          	auipc	a2,0x2
ffffffffc0205694:	ae060613          	addi	a2,a2,-1312 # ffffffffc0207170 <commands+0x8a8>
ffffffffc0205698:	06e00593          	li	a1,110
ffffffffc020569c:	00002517          	auipc	a0,0x2
ffffffffc02056a0:	9c450513          	addi	a0,a0,-1596 # ffffffffc0207060 <commands+0x798>
ffffffffc02056a4:	b65fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02056a8:	00003617          	auipc	a2,0x3
ffffffffc02056ac:	eb060613          	addi	a2,a2,-336 # ffffffffc0208558 <default_pmm_manager+0x198>
ffffffffc02056b0:	2f700593          	li	a1,759
ffffffffc02056b4:	00003517          	auipc	a0,0x3
ffffffffc02056b8:	e0450513          	addi	a0,a0,-508 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc02056bc:	b4dfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056c0:	00002617          	auipc	a2,0x2
ffffffffc02056c4:	98060613          	addi	a2,a2,-1664 # ffffffffc0207040 <commands+0x778>
ffffffffc02056c8:	06200593          	li	a1,98
ffffffffc02056cc:	00002517          	auipc	a0,0x2
ffffffffc02056d0:	99450513          	addi	a0,a0,-1644 # ffffffffc0207060 <commands+0x798>
ffffffffc02056d4:	b35fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02056d8 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02056d8:	1141                	addi	sp,sp,-16
ffffffffc02056da:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056dc:	899fb0ef          	jal	ra,ffffffffc0200f74 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056e0:	f75fd0ef          	jal	ra,ffffffffc0203654 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);  // 创建用户进程
ffffffffc02056e4:	4601                	li	a2,0
ffffffffc02056e6:	4581                	li	a1,0
ffffffffc02056e8:	fffff517          	auipc	a0,0xfffff
ffffffffc02056ec:	71650513          	addi	a0,a0,1814 # ffffffffc0204dfe <user_main>
ffffffffc02056f0:	c7dff0ef          	jal	ra,ffffffffc020536c <kernel_thread>
    if (pid <= 0) {
ffffffffc02056f4:	00a04563          	bgtz	a0,ffffffffc02056fe <init_main+0x26>
ffffffffc02056f8:	a071                	j	ffffffffc0205784 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) { //等待子线程退出
        schedule();
ffffffffc02056fa:	10f000ef          	jal	ra,ffffffffc0206008 <schedule>
    if (code_store != NULL) {
ffffffffc02056fe:	4581                	li	a1,0
ffffffffc0205700:	4501                	li	a0,0
ffffffffc0205702:	e05ff0ef          	jal	ra,ffffffffc0205506 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) { //等待子线程退出
ffffffffc0205706:	d975                	beqz	a0,ffffffffc02056fa <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205708:	00003517          	auipc	a0,0x3
ffffffffc020570c:	e9050513          	addi	a0,a0,-368 # ffffffffc0208598 <default_pmm_manager+0x1d8>
ffffffffc0205710:	9bdfa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205714:	000ad797          	auipc	a5,0xad
ffffffffc0205718:	16c7b783          	ld	a5,364(a5) # ffffffffc02b2880 <initproc>
ffffffffc020571c:	7bf8                	ld	a4,240(a5)
ffffffffc020571e:	e339                	bnez	a4,ffffffffc0205764 <init_main+0x8c>
ffffffffc0205720:	7ff8                	ld	a4,248(a5)
ffffffffc0205722:	e329                	bnez	a4,ffffffffc0205764 <init_main+0x8c>
ffffffffc0205724:	1007b703          	ld	a4,256(a5)
ffffffffc0205728:	ef15                	bnez	a4,ffffffffc0205764 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc020572a:	000ad697          	auipc	a3,0xad
ffffffffc020572e:	15e6a683          	lw	a3,350(a3) # ffffffffc02b2888 <nr_process>
ffffffffc0205732:	4709                	li	a4,2
ffffffffc0205734:	0ae69463          	bne	a3,a4,ffffffffc02057dc <init_main+0x104>
    return listelm->next;
ffffffffc0205738:	000ad697          	auipc	a3,0xad
ffffffffc020573c:	0b068693          	addi	a3,a3,176 # ffffffffc02b27e8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205740:	6698                	ld	a4,8(a3)
ffffffffc0205742:	0c878793          	addi	a5,a5,200
ffffffffc0205746:	06f71b63          	bne	a4,a5,ffffffffc02057bc <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020574a:	629c                	ld	a5,0(a3)
ffffffffc020574c:	04f71863          	bne	a4,a5,ffffffffc020579c <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0205750:	00003517          	auipc	a0,0x3
ffffffffc0205754:	f3050513          	addi	a0,a0,-208 # ffffffffc0208680 <default_pmm_manager+0x2c0>
ffffffffc0205758:	975fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc020575c:	60a2                	ld	ra,8(sp)
ffffffffc020575e:	4501                	li	a0,0
ffffffffc0205760:	0141                	addi	sp,sp,16
ffffffffc0205762:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205764:	00003697          	auipc	a3,0x3
ffffffffc0205768:	e5c68693          	addi	a3,a3,-420 # ffffffffc02085c0 <default_pmm_manager+0x200>
ffffffffc020576c:	00001617          	auipc	a2,0x1
ffffffffc0205770:	56c60613          	addi	a2,a2,1388 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205774:	36000593          	li	a1,864
ffffffffc0205778:	00003517          	auipc	a0,0x3
ffffffffc020577c:	d4050513          	addi	a0,a0,-704 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205780:	a89fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205784:	00003617          	auipc	a2,0x3
ffffffffc0205788:	df460613          	addi	a2,a2,-524 # ffffffffc0208578 <default_pmm_manager+0x1b8>
ffffffffc020578c:	35800593          	li	a1,856
ffffffffc0205790:	00003517          	auipc	a0,0x3
ffffffffc0205794:	d2850513          	addi	a0,a0,-728 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205798:	a71fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020579c:	00003697          	auipc	a3,0x3
ffffffffc02057a0:	eb468693          	addi	a3,a3,-332 # ffffffffc0208650 <default_pmm_manager+0x290>
ffffffffc02057a4:	00001617          	auipc	a2,0x1
ffffffffc02057a8:	53460613          	addi	a2,a2,1332 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02057ac:	36300593          	li	a1,867
ffffffffc02057b0:	00003517          	auipc	a0,0x3
ffffffffc02057b4:	d0850513          	addi	a0,a0,-760 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc02057b8:	a51fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057bc:	00003697          	auipc	a3,0x3
ffffffffc02057c0:	e6468693          	addi	a3,a3,-412 # ffffffffc0208620 <default_pmm_manager+0x260>
ffffffffc02057c4:	00001617          	auipc	a2,0x1
ffffffffc02057c8:	51460613          	addi	a2,a2,1300 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02057cc:	36200593          	li	a1,866
ffffffffc02057d0:	00003517          	auipc	a0,0x3
ffffffffc02057d4:	ce850513          	addi	a0,a0,-792 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc02057d8:	a31fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc02057dc:	00003697          	auipc	a3,0x3
ffffffffc02057e0:	e3468693          	addi	a3,a3,-460 # ffffffffc0208610 <default_pmm_manager+0x250>
ffffffffc02057e4:	00001617          	auipc	a2,0x1
ffffffffc02057e8:	4f460613          	addi	a2,a2,1268 # ffffffffc0206cd8 <commands+0x410>
ffffffffc02057ec:	36100593          	li	a1,865
ffffffffc02057f0:	00003517          	auipc	a0,0x3
ffffffffc02057f4:	cc850513          	addi	a0,a0,-824 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc02057f8:	a11fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02057fc <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057fc:	7171                	addi	sp,sp,-176
ffffffffc02057fe:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205800:	000add97          	auipc	s11,0xad
ffffffffc0205804:	070d8d93          	addi	s11,s11,112 # ffffffffc02b2870 <current>
ffffffffc0205808:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020580c:	e54e                	sd	s3,136(sp)
ffffffffc020580e:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205810:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205814:	e94a                	sd	s2,144(sp)
ffffffffc0205816:	f4de                	sd	s7,104(sp)
ffffffffc0205818:	892a                	mv	s2,a0
ffffffffc020581a:	8bb2                	mv	s7,a2
ffffffffc020581c:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020581e:	862e                	mv	a2,a1
ffffffffc0205820:	4681                	li	a3,0
ffffffffc0205822:	85aa                	mv	a1,a0
ffffffffc0205824:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205826:	f506                	sd	ra,168(sp)
ffffffffc0205828:	f122                	sd	s0,160(sp)
ffffffffc020582a:	e152                	sd	s4,128(sp)
ffffffffc020582c:	fcd6                	sd	s5,120(sp)
ffffffffc020582e:	f8da                	sd	s6,112(sp)
ffffffffc0205830:	f0e2                	sd	s8,96(sp)
ffffffffc0205832:	ece6                	sd	s9,88(sp)
ffffffffc0205834:	e8ea                	sd	s10,80(sp)
ffffffffc0205836:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205838:	b5bfd0ef          	jal	ra,ffffffffc0203392 <user_mem_check>
ffffffffc020583c:	40050863          	beqz	a0,ffffffffc0205c4c <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205840:	4641                	li	a2,16
ffffffffc0205842:	4581                	li	a1,0
ffffffffc0205844:	1808                	addi	a0,sp,48
ffffffffc0205846:	1ab000ef          	jal	ra,ffffffffc02061f0 <memset>
    memcpy(local_name, name, len);
ffffffffc020584a:	47bd                	li	a5,15
ffffffffc020584c:	8626                	mv	a2,s1
ffffffffc020584e:	1e97e063          	bltu	a5,s1,ffffffffc0205a2e <do_execve+0x232>
ffffffffc0205852:	85ca                	mv	a1,s2
ffffffffc0205854:	1808                	addi	a0,sp,48
ffffffffc0205856:	1ad000ef          	jal	ra,ffffffffc0206202 <memcpy>
    if (mm != NULL) {
ffffffffc020585a:	1e098163          	beqz	s3,ffffffffc0205a3c <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc020585e:	00002517          	auipc	a0,0x2
ffffffffc0205862:	0da50513          	addi	a0,a0,218 # ffffffffc0207938 <commands+0x1070>
ffffffffc0205866:	89ffa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc020586a:	000ad797          	auipc	a5,0xad
ffffffffc020586e:	fa67b783          	ld	a5,-90(a5) # ffffffffc02b2810 <boot_cr3>
ffffffffc0205872:	577d                	li	a4,-1
ffffffffc0205874:	177e                	slli	a4,a4,0x3f
ffffffffc0205876:	83b1                	srli	a5,a5,0xc
ffffffffc0205878:	8fd9                	or	a5,a5,a4
ffffffffc020587a:	18079073          	csrw	satp,a5
ffffffffc020587e:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b88>
ffffffffc0205882:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205886:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc020588a:	2c070263          	beqz	a4,ffffffffc0205b4e <do_execve+0x352>
        current->mm = NULL;
ffffffffc020588e:	000db783          	ld	a5,0(s11)
ffffffffc0205892:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205896:	944fd0ef          	jal	ra,ffffffffc02029da <mm_create>
ffffffffc020589a:	84aa                	mv	s1,a0
ffffffffc020589c:	1c050b63          	beqz	a0,ffffffffc0205a72 <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc02058a0:	4505                	li	a0,1
ffffffffc02058a2:	e00fb0ef          	jal	ra,ffffffffc0200ea2 <alloc_pages>
ffffffffc02058a6:	3a050763          	beqz	a0,ffffffffc0205c54 <do_execve+0x458>
    return page - pages + nbase;
ffffffffc02058aa:	000adc97          	auipc	s9,0xad
ffffffffc02058ae:	f7ec8c93          	addi	s9,s9,-130 # ffffffffc02b2828 <pages>
ffffffffc02058b2:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc02058b6:	000adc17          	auipc	s8,0xad
ffffffffc02058ba:	f6ac0c13          	addi	s8,s8,-150 # ffffffffc02b2820 <npage>
    return page - pages + nbase;
ffffffffc02058be:	00003717          	auipc	a4,0x3
ffffffffc02058c2:	4b273703          	ld	a4,1202(a4) # ffffffffc0208d70 <nbase>
ffffffffc02058c6:	40d506b3          	sub	a3,a0,a3
ffffffffc02058ca:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02058cc:	5afd                	li	s5,-1
ffffffffc02058ce:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc02058d2:	96ba                	add	a3,a3,a4
ffffffffc02058d4:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc02058d6:	00cad713          	srli	a4,s5,0xc
ffffffffc02058da:	ec3a                	sd	a4,24(sp)
ffffffffc02058dc:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02058de:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02058e0:	36f77e63          	bgeu	a4,a5,ffffffffc0205c5c <do_execve+0x460>
ffffffffc02058e4:	000adb17          	auipc	s6,0xad
ffffffffc02058e8:	f54b0b13          	addi	s6,s6,-172 # ffffffffc02b2838 <va_pa_offset>
ffffffffc02058ec:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02058f0:	6605                	lui	a2,0x1
ffffffffc02058f2:	000ad597          	auipc	a1,0xad
ffffffffc02058f6:	f265b583          	ld	a1,-218(a1) # ffffffffc02b2818 <boot_pgdir>
ffffffffc02058fa:	9936                	add	s2,s2,a3
ffffffffc02058fc:	854a                	mv	a0,s2
ffffffffc02058fe:	105000ef          	jal	ra,ffffffffc0206202 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205902:	7782                	ld	a5,32(sp)
ffffffffc0205904:	4398                	lw	a4,0(a5)
ffffffffc0205906:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc020590a:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020590e:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9457>
ffffffffc0205912:	14f71663          	bne	a4,a5,ffffffffc0205a5e <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205916:	7682                	ld	a3,32(sp)
ffffffffc0205918:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020591c:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205920:	00371793          	slli	a5,a4,0x3
ffffffffc0205924:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205926:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205928:	078e                	slli	a5,a5,0x3
ffffffffc020592a:	97ce                	add	a5,a5,s3
ffffffffc020592c:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020592e:	00f9fc63          	bgeu	s3,a5,ffffffffc0205946 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205932:	0009a783          	lw	a5,0(s3)
ffffffffc0205936:	4705                	li	a4,1
ffffffffc0205938:	12e78f63          	beq	a5,a4,ffffffffc0205a76 <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc020593c:	77a2                	ld	a5,40(sp)
ffffffffc020593e:	03898993          	addi	s3,s3,56
ffffffffc0205942:	fef9e8e3          	bltu	s3,a5,ffffffffc0205932 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205946:	4701                	li	a4,0
ffffffffc0205948:	46ad                	li	a3,11
ffffffffc020594a:	00100637          	lui	a2,0x100
ffffffffc020594e:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205952:	8526                	mv	a0,s1
ffffffffc0205954:	a5efd0ef          	jal	ra,ffffffffc0202bb2 <mm_map>
ffffffffc0205958:	8a2a                	mv	s4,a0
ffffffffc020595a:	1e051063          	bnez	a0,ffffffffc0205b3a <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020595e:	6c88                	ld	a0,24(s1)
ffffffffc0205960:	467d                	li	a2,31
ffffffffc0205962:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205966:	ba9fc0ef          	jal	ra,ffffffffc020250e <pgdir_alloc_page>
ffffffffc020596a:	38050163          	beqz	a0,ffffffffc0205cec <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020596e:	6c88                	ld	a0,24(s1)
ffffffffc0205970:	467d                	li	a2,31
ffffffffc0205972:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205976:	b99fc0ef          	jal	ra,ffffffffc020250e <pgdir_alloc_page>
ffffffffc020597a:	34050963          	beqz	a0,ffffffffc0205ccc <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc020597e:	6c88                	ld	a0,24(s1)
ffffffffc0205980:	467d                	li	a2,31
ffffffffc0205982:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205986:	b89fc0ef          	jal	ra,ffffffffc020250e <pgdir_alloc_page>
ffffffffc020598a:	32050163          	beqz	a0,ffffffffc0205cac <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020598e:	6c88                	ld	a0,24(s1)
ffffffffc0205990:	467d                	li	a2,31
ffffffffc0205992:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205996:	b79fc0ef          	jal	ra,ffffffffc020250e <pgdir_alloc_page>
ffffffffc020599a:	2e050963          	beqz	a0,ffffffffc0205c8c <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc020599e:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc02059a0:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059a4:	6c94                	ld	a3,24(s1)
ffffffffc02059a6:	2785                	addiw	a5,a5,1
ffffffffc02059a8:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc02059aa:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059ac:	c02007b7          	lui	a5,0xc0200
ffffffffc02059b0:	2cf6e263          	bltu	a3,a5,ffffffffc0205c74 <do_execve+0x478>
ffffffffc02059b4:	000b3783          	ld	a5,0(s6)
ffffffffc02059b8:	577d                	li	a4,-1
ffffffffc02059ba:	177e                	slli	a4,a4,0x3f
ffffffffc02059bc:	8e9d                	sub	a3,a3,a5
ffffffffc02059be:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059c2:	f654                	sd	a3,168(a2)
ffffffffc02059c4:	8fd9                	or	a5,a5,a4
ffffffffc02059c6:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059ca:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059cc:	4581                	li	a1,0
ffffffffc02059ce:	12000613          	li	a2,288
ffffffffc02059d2:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02059d4:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059d8:	019000ef          	jal	ra,ffffffffc02061f0 <memset>
    tf->epc = elf->e_entry; //修改epc，sret返回地址发生变化，返回执行exit.c函数，其中执行退出，调用sys_exit
ffffffffc02059dc:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059de:	000db483          	ld	s1,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02059e2:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry; //修改epc，sret返回地址发生变化，返回执行exit.c函数，其中执行退出，调用sys_exit
ffffffffc02059e6:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc02059e8:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059ea:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP;
ffffffffc02059ee:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059f0:	4641                	li	a2,16
ffffffffc02059f2:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc02059f4:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry; //修改epc，sret返回地址发生变化，返回执行exit.c函数，其中执行退出，调用sys_exit
ffffffffc02059f6:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02059fa:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059fe:	8526                	mv	a0,s1
ffffffffc0205a00:	7f0000ef          	jal	ra,ffffffffc02061f0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205a04:	463d                	li	a2,15
ffffffffc0205a06:	180c                	addi	a1,sp,48
ffffffffc0205a08:	8526                	mv	a0,s1
ffffffffc0205a0a:	7f8000ef          	jal	ra,ffffffffc0206202 <memcpy>
}
ffffffffc0205a0e:	70aa                	ld	ra,168(sp)
ffffffffc0205a10:	740a                	ld	s0,160(sp)
ffffffffc0205a12:	64ea                	ld	s1,152(sp)
ffffffffc0205a14:	694a                	ld	s2,144(sp)
ffffffffc0205a16:	69aa                	ld	s3,136(sp)
ffffffffc0205a18:	7ae6                	ld	s5,120(sp)
ffffffffc0205a1a:	7b46                	ld	s6,112(sp)
ffffffffc0205a1c:	7ba6                	ld	s7,104(sp)
ffffffffc0205a1e:	7c06                	ld	s8,96(sp)
ffffffffc0205a20:	6ce6                	ld	s9,88(sp)
ffffffffc0205a22:	6d46                	ld	s10,80(sp)
ffffffffc0205a24:	6da6                	ld	s11,72(sp)
ffffffffc0205a26:	8552                	mv	a0,s4
ffffffffc0205a28:	6a0a                	ld	s4,128(sp)
ffffffffc0205a2a:	614d                	addi	sp,sp,176
ffffffffc0205a2c:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205a2e:	463d                	li	a2,15
ffffffffc0205a30:	85ca                	mv	a1,s2
ffffffffc0205a32:	1808                	addi	a0,sp,48
ffffffffc0205a34:	7ce000ef          	jal	ra,ffffffffc0206202 <memcpy>
    if (mm != NULL) {
ffffffffc0205a38:	e20993e3          	bnez	s3,ffffffffc020585e <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205a3c:	000db783          	ld	a5,0(s11)
ffffffffc0205a40:	779c                	ld	a5,40(a5)
ffffffffc0205a42:	e4078ae3          	beqz	a5,ffffffffc0205896 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205a46:	00003617          	auipc	a2,0x3
ffffffffc0205a4a:	c5a60613          	addi	a2,a2,-934 # ffffffffc02086a0 <default_pmm_manager+0x2e0>
ffffffffc0205a4e:	20a00593          	li	a1,522
ffffffffc0205a52:	00003517          	auipc	a0,0x3
ffffffffc0205a56:	a6650513          	addi	a0,a0,-1434 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205a5a:	faefa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc0205a5e:	8526                	mv	a0,s1
ffffffffc0205a60:	c1cff0ef          	jal	ra,ffffffffc0204e7c <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a64:	8526                	mv	a0,s1
ffffffffc0205a66:	8fafd0ef          	jal	ra,ffffffffc0202b60 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205a6a:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205a6c:	8552                	mv	a0,s4
ffffffffc0205a6e:	94fff0ef          	jal	ra,ffffffffc02053bc <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205a72:	5a71                	li	s4,-4
ffffffffc0205a74:	bfe5                	j	ffffffffc0205a6c <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a76:	0289b603          	ld	a2,40(s3)
ffffffffc0205a7a:	0209b783          	ld	a5,32(s3)
ffffffffc0205a7e:	1cf66d63          	bltu	a2,a5,ffffffffc0205c58 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a82:	0049a783          	lw	a5,4(s3)
ffffffffc0205a86:	0017f693          	andi	a3,a5,1
ffffffffc0205a8a:	c291                	beqz	a3,ffffffffc0205a8e <do_execve+0x292>
ffffffffc0205a8c:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a8e:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a92:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a94:	e779                	bnez	a4,ffffffffc0205b62 <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a96:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a98:	c781                	beqz	a5,ffffffffc0205aa0 <do_execve+0x2a4>
ffffffffc0205a9a:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a9e:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205aa0:	0026f793          	andi	a5,a3,2
ffffffffc0205aa4:	e3f1                	bnez	a5,ffffffffc0205b68 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205aa6:	0046f793          	andi	a5,a3,4
ffffffffc0205aaa:	c399                	beqz	a5,ffffffffc0205ab0 <do_execve+0x2b4>
ffffffffc0205aac:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205ab0:	0109b583          	ld	a1,16(s3)
ffffffffc0205ab4:	4701                	li	a4,0
ffffffffc0205ab6:	8526                	mv	a0,s1
ffffffffc0205ab8:	8fafd0ef          	jal	ra,ffffffffc0202bb2 <mm_map>
ffffffffc0205abc:	8a2a                	mv	s4,a0
ffffffffc0205abe:	ed35                	bnez	a0,ffffffffc0205b3a <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ac0:	0109bb83          	ld	s7,16(s3)
ffffffffc0205ac4:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ac6:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205aca:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ace:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ad2:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ad4:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ad6:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205ad8:	054be963          	bltu	s7,s4,ffffffffc0205b2a <do_execve+0x32e>
ffffffffc0205adc:	aa95                	j	ffffffffc0205c50 <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205ade:	6785                	lui	a5,0x1
ffffffffc0205ae0:	415b8533          	sub	a0,s7,s5
ffffffffc0205ae4:	9abe                	add	s5,s5,a5
ffffffffc0205ae6:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205aea:	015a7463          	bgeu	s4,s5,ffffffffc0205af2 <do_execve+0x2f6>
                size -= la - end;
ffffffffc0205aee:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205af2:	000cb683          	ld	a3,0(s9)
ffffffffc0205af6:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205af8:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205afc:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b00:	8699                	srai	a3,a3,0x6
ffffffffc0205b02:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b04:	67e2                	ld	a5,24(sp)
ffffffffc0205b06:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b0a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b0c:	14b87863          	bgeu	a6,a1,ffffffffc0205c5c <do_execve+0x460>
ffffffffc0205b10:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b14:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205b16:	9bb2                	add	s7,s7,a2
ffffffffc0205b18:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b1a:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b1c:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b1e:	6e4000ef          	jal	ra,ffffffffc0206202 <memcpy>
            start += size, from += size;
ffffffffc0205b22:	6622                	ld	a2,8(sp)
ffffffffc0205b24:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205b26:	054bf363          	bgeu	s7,s4,ffffffffc0205b6c <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b2a:	6c88                	ld	a0,24(s1)
ffffffffc0205b2c:	866a                	mv	a2,s10
ffffffffc0205b2e:	85d6                	mv	a1,s5
ffffffffc0205b30:	9dffc0ef          	jal	ra,ffffffffc020250e <pgdir_alloc_page>
ffffffffc0205b34:	842a                	mv	s0,a0
ffffffffc0205b36:	f545                	bnez	a0,ffffffffc0205ade <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc0205b38:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205b3a:	8526                	mv	a0,s1
ffffffffc0205b3c:	9c0fd0ef          	jal	ra,ffffffffc0202cfc <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b40:	8526                	mv	a0,s1
ffffffffc0205b42:	b3aff0ef          	jal	ra,ffffffffc0204e7c <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b46:	8526                	mv	a0,s1
ffffffffc0205b48:	818fd0ef          	jal	ra,ffffffffc0202b60 <mm_destroy>
    return ret;
ffffffffc0205b4c:	b705                	j	ffffffffc0205a6c <do_execve+0x270>
            exit_mmap(mm);
ffffffffc0205b4e:	854e                	mv	a0,s3
ffffffffc0205b50:	9acfd0ef          	jal	ra,ffffffffc0202cfc <exit_mmap>
            put_pgdir(mm); // 释放页表页面
ffffffffc0205b54:	854e                	mv	a0,s3
ffffffffc0205b56:	b26ff0ef          	jal	ra,ffffffffc0204e7c <put_pgdir>
            mm_destroy(mm); //把进程当前占用的内存释放，之后重新分配内存
ffffffffc0205b5a:	854e                	mv	a0,s3
ffffffffc0205b5c:	804fd0ef          	jal	ra,ffffffffc0202b60 <mm_destroy>
ffffffffc0205b60:	b33d                	j	ffffffffc020588e <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b62:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b66:	fb95                	bnez	a5,ffffffffc0205a9a <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b68:	4d5d                	li	s10,23
ffffffffc0205b6a:	bf35                	j	ffffffffc0205aa6 <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b6c:	0109b683          	ld	a3,16(s3)
ffffffffc0205b70:	0289b903          	ld	s2,40(s3)
ffffffffc0205b74:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205b76:	075bfd63          	bgeu	s7,s5,ffffffffc0205bf0 <do_execve+0x3f4>
            if (start == end) {
ffffffffc0205b7a:	dd7901e3          	beq	s2,s7,ffffffffc020593c <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b7e:	6785                	lui	a5,0x1
ffffffffc0205b80:	00fb8533          	add	a0,s7,a5
ffffffffc0205b84:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205b88:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205b8c:	0b597d63          	bgeu	s2,s5,ffffffffc0205c46 <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205b90:	000cb683          	ld	a3,0(s9)
ffffffffc0205b94:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b96:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205b9a:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b9e:	8699                	srai	a3,a3,0x6
ffffffffc0205ba0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205ba2:	67e2                	ld	a5,24(sp)
ffffffffc0205ba4:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ba8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205baa:	0ac5f963          	bgeu	a1,a2,ffffffffc0205c5c <do_execve+0x460>
ffffffffc0205bae:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bb2:	8652                	mv	a2,s4
ffffffffc0205bb4:	4581                	li	a1,0
ffffffffc0205bb6:	96c2                	add	a3,a3,a6
ffffffffc0205bb8:	9536                	add	a0,a0,a3
ffffffffc0205bba:	636000ef          	jal	ra,ffffffffc02061f0 <memset>
            start += size;
ffffffffc0205bbe:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bc2:	03597463          	bgeu	s2,s5,ffffffffc0205bea <do_execve+0x3ee>
ffffffffc0205bc6:	d6e90be3          	beq	s2,a4,ffffffffc020593c <do_execve+0x140>
ffffffffc0205bca:	00003697          	auipc	a3,0x3
ffffffffc0205bce:	afe68693          	addi	a3,a3,-1282 # ffffffffc02086c8 <default_pmm_manager+0x308>
ffffffffc0205bd2:	00001617          	auipc	a2,0x1
ffffffffc0205bd6:	10660613          	addi	a2,a2,262 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205bda:	25f00593          	li	a1,607
ffffffffc0205bde:	00003517          	auipc	a0,0x3
ffffffffc0205be2:	8da50513          	addi	a0,a0,-1830 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205be6:	e22fa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205bea:	ff5710e3          	bne	a4,s5,ffffffffc0205bca <do_execve+0x3ce>
ffffffffc0205bee:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205bf0:	d52bf6e3          	bgeu	s7,s2,ffffffffc020593c <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205bf4:	6c88                	ld	a0,24(s1)
ffffffffc0205bf6:	866a                	mv	a2,s10
ffffffffc0205bf8:	85d6                	mv	a1,s5
ffffffffc0205bfa:	915fc0ef          	jal	ra,ffffffffc020250e <pgdir_alloc_page>
ffffffffc0205bfe:	842a                	mv	s0,a0
ffffffffc0205c00:	dd05                	beqz	a0,ffffffffc0205b38 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c02:	6785                	lui	a5,0x1
ffffffffc0205c04:	415b8533          	sub	a0,s7,s5
ffffffffc0205c08:	9abe                	add	s5,s5,a5
ffffffffc0205c0a:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205c0e:	01597463          	bgeu	s2,s5,ffffffffc0205c16 <do_execve+0x41a>
                size -= la - end;
ffffffffc0205c12:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205c16:	000cb683          	ld	a3,0(s9)
ffffffffc0205c1a:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c1c:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205c20:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c24:	8699                	srai	a3,a3,0x6
ffffffffc0205c26:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c28:	67e2                	ld	a5,24(sp)
ffffffffc0205c2a:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c2e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c30:	02b87663          	bgeu	a6,a1,ffffffffc0205c5c <do_execve+0x460>
ffffffffc0205c34:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c38:	4581                	li	a1,0
            start += size;
ffffffffc0205c3a:	9bb2                	add	s7,s7,a2
ffffffffc0205c3c:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c3e:	9536                	add	a0,a0,a3
ffffffffc0205c40:	5b0000ef          	jal	ra,ffffffffc02061f0 <memset>
ffffffffc0205c44:	b775                	j	ffffffffc0205bf0 <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c46:	417a8a33          	sub	s4,s5,s7
ffffffffc0205c4a:	b799                	j	ffffffffc0205b90 <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205c4c:	5a75                	li	s4,-3
ffffffffc0205c4e:	b3c1                	j	ffffffffc0205a0e <do_execve+0x212>
        while (start < end) {
ffffffffc0205c50:	86de                	mv	a3,s7
ffffffffc0205c52:	bf39                	j	ffffffffc0205b70 <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205c54:	5a71                	li	s4,-4
ffffffffc0205c56:	bdc5                	j	ffffffffc0205b46 <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205c58:	5a61                	li	s4,-8
ffffffffc0205c5a:	b5c5                	j	ffffffffc0205b3a <do_execve+0x33e>
ffffffffc0205c5c:	00001617          	auipc	a2,0x1
ffffffffc0205c60:	43c60613          	addi	a2,a2,1084 # ffffffffc0207098 <commands+0x7d0>
ffffffffc0205c64:	06900593          	li	a1,105
ffffffffc0205c68:	00001517          	auipc	a0,0x1
ffffffffc0205c6c:	3f850513          	addi	a0,a0,1016 # ffffffffc0207060 <commands+0x798>
ffffffffc0205c70:	d98fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c74:	00001617          	auipc	a2,0x1
ffffffffc0205c78:	4fc60613          	addi	a2,a2,1276 # ffffffffc0207170 <commands+0x8a8>
ffffffffc0205c7c:	27a00593          	li	a1,634
ffffffffc0205c80:	00003517          	auipc	a0,0x3
ffffffffc0205c84:	83850513          	addi	a0,a0,-1992 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205c88:	d80fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c8c:	00003697          	auipc	a3,0x3
ffffffffc0205c90:	b5468693          	addi	a3,a3,-1196 # ffffffffc02087e0 <default_pmm_manager+0x420>
ffffffffc0205c94:	00001617          	auipc	a2,0x1
ffffffffc0205c98:	04460613          	addi	a2,a2,68 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205c9c:	27500593          	li	a1,629
ffffffffc0205ca0:	00003517          	auipc	a0,0x3
ffffffffc0205ca4:	81850513          	addi	a0,a0,-2024 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205ca8:	d60fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cac:	00003697          	auipc	a3,0x3
ffffffffc0205cb0:	aec68693          	addi	a3,a3,-1300 # ffffffffc0208798 <default_pmm_manager+0x3d8>
ffffffffc0205cb4:	00001617          	auipc	a2,0x1
ffffffffc0205cb8:	02460613          	addi	a2,a2,36 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205cbc:	27400593          	li	a1,628
ffffffffc0205cc0:	00002517          	auipc	a0,0x2
ffffffffc0205cc4:	7f850513          	addi	a0,a0,2040 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205cc8:	d40fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ccc:	00003697          	auipc	a3,0x3
ffffffffc0205cd0:	a8468693          	addi	a3,a3,-1404 # ffffffffc0208750 <default_pmm_manager+0x390>
ffffffffc0205cd4:	00001617          	auipc	a2,0x1
ffffffffc0205cd8:	00460613          	addi	a2,a2,4 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205cdc:	27300593          	li	a1,627
ffffffffc0205ce0:	00002517          	auipc	a0,0x2
ffffffffc0205ce4:	7d850513          	addi	a0,a0,2008 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205ce8:	d20fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205cec:	00003697          	auipc	a3,0x3
ffffffffc0205cf0:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0208708 <default_pmm_manager+0x348>
ffffffffc0205cf4:	00001617          	auipc	a2,0x1
ffffffffc0205cf8:	fe460613          	addi	a2,a2,-28 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205cfc:	27200593          	li	a1,626
ffffffffc0205d00:	00002517          	auipc	a0,0x2
ffffffffc0205d04:	7b850513          	addi	a0,a0,1976 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205d08:	d00fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205d0c <do_yield>:
    current->need_resched = 1;
ffffffffc0205d0c:	000ad797          	auipc	a5,0xad
ffffffffc0205d10:	b647b783          	ld	a5,-1180(a5) # ffffffffc02b2870 <current>
ffffffffc0205d14:	4705                	li	a4,1
ffffffffc0205d16:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d18:	4501                	li	a0,0
ffffffffc0205d1a:	8082                	ret

ffffffffc0205d1c <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d1c:	1101                	addi	sp,sp,-32
ffffffffc0205d1e:	e822                	sd	s0,16(sp)
ffffffffc0205d20:	e426                	sd	s1,8(sp)
ffffffffc0205d22:	ec06                	sd	ra,24(sp)
ffffffffc0205d24:	842e                	mv	s0,a1
ffffffffc0205d26:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d28:	c999                	beqz	a1,ffffffffc0205d3e <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205d2a:	000ad797          	auipc	a5,0xad
ffffffffc0205d2e:	b467b783          	ld	a5,-1210(a5) # ffffffffc02b2870 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d32:	7788                	ld	a0,40(a5)
ffffffffc0205d34:	4685                	li	a3,1
ffffffffc0205d36:	4611                	li	a2,4
ffffffffc0205d38:	e5afd0ef          	jal	ra,ffffffffc0203392 <user_mem_check>
ffffffffc0205d3c:	c909                	beqz	a0,ffffffffc0205d4e <do_wait+0x32>
ffffffffc0205d3e:	85a2                	mv	a1,s0
}
ffffffffc0205d40:	6442                	ld	s0,16(sp)
ffffffffc0205d42:	60e2                	ld	ra,24(sp)
ffffffffc0205d44:	8526                	mv	a0,s1
ffffffffc0205d46:	64a2                	ld	s1,8(sp)
ffffffffc0205d48:	6105                	addi	sp,sp,32
ffffffffc0205d4a:	fbcff06f          	j	ffffffffc0205506 <do_wait.part.0>
ffffffffc0205d4e:	60e2                	ld	ra,24(sp)
ffffffffc0205d50:	6442                	ld	s0,16(sp)
ffffffffc0205d52:	64a2                	ld	s1,8(sp)
ffffffffc0205d54:	5575                	li	a0,-3
ffffffffc0205d56:	6105                	addi	sp,sp,32
ffffffffc0205d58:	8082                	ret

ffffffffc0205d5a <do_kill>:
do_kill(int pid) {
ffffffffc0205d5a:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d5c:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205d5e:	e406                	sd	ra,8(sp)
ffffffffc0205d60:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d62:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205d66:	17f9                	addi	a5,a5,-2
ffffffffc0205d68:	02e7e963          	bltu	a5,a4,ffffffffc0205d9a <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205d6c:	842a                	mv	s0,a0
ffffffffc0205d6e:	45a9                	li	a1,10
ffffffffc0205d70:	2501                	sext.w	a0,a0
ffffffffc0205d72:	097000ef          	jal	ra,ffffffffc0206608 <hash32>
ffffffffc0205d76:	02051793          	slli	a5,a0,0x20
ffffffffc0205d7a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205d7e:	000a9797          	auipc	a5,0xa9
ffffffffc0205d82:	a6a78793          	addi	a5,a5,-1430 # ffffffffc02ae7e8 <hash_list>
ffffffffc0205d86:	953e                	add	a0,a0,a5
ffffffffc0205d88:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205d8a:	a029                	j	ffffffffc0205d94 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205d8c:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205d90:	00870b63          	beq	a4,s0,ffffffffc0205da6 <do_kill+0x4c>
ffffffffc0205d94:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205d96:	fef51be3          	bne	a0,a5,ffffffffc0205d8c <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205d9a:	5475                	li	s0,-3
}
ffffffffc0205d9c:	60a2                	ld	ra,8(sp)
ffffffffc0205d9e:	8522                	mv	a0,s0
ffffffffc0205da0:	6402                	ld	s0,0(sp)
ffffffffc0205da2:	0141                	addi	sp,sp,16
ffffffffc0205da4:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205da6:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205daa:	00177693          	andi	a3,a4,1
ffffffffc0205dae:	e295                	bnez	a3,ffffffffc0205dd2 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205db0:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205db2:	00176713          	ori	a4,a4,1
ffffffffc0205db6:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205dba:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205dbc:	fe06d0e3          	bgez	a3,ffffffffc0205d9c <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205dc0:	f2878513          	addi	a0,a5,-216
ffffffffc0205dc4:	1c4000ef          	jal	ra,ffffffffc0205f88 <wakeup_proc>
}
ffffffffc0205dc8:	60a2                	ld	ra,8(sp)
ffffffffc0205dca:	8522                	mv	a0,s0
ffffffffc0205dcc:	6402                	ld	s0,0(sp)
ffffffffc0205dce:	0141                	addi	sp,sp,16
ffffffffc0205dd0:	8082                	ret
        return -E_KILLED;
ffffffffc0205dd2:	545d                	li	s0,-9
ffffffffc0205dd4:	b7e1                	j	ffffffffc0205d9c <do_kill+0x42>

ffffffffc0205dd6 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205dd6:	1101                	addi	sp,sp,-32
ffffffffc0205dd8:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205dda:	000ad797          	auipc	a5,0xad
ffffffffc0205dde:	a0e78793          	addi	a5,a5,-1522 # ffffffffc02b27e8 <proc_list>
ffffffffc0205de2:	ec06                	sd	ra,24(sp)
ffffffffc0205de4:	e822                	sd	s0,16(sp)
ffffffffc0205de6:	e04a                	sd	s2,0(sp)
ffffffffc0205de8:	000a9497          	auipc	s1,0xa9
ffffffffc0205dec:	a0048493          	addi	s1,s1,-1536 # ffffffffc02ae7e8 <hash_list>
ffffffffc0205df0:	e79c                	sd	a5,8(a5)
ffffffffc0205df2:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205df4:	000ad717          	auipc	a4,0xad
ffffffffc0205df8:	9f470713          	addi	a4,a4,-1548 # ffffffffc02b27e8 <proc_list>
ffffffffc0205dfc:	87a6                	mv	a5,s1
ffffffffc0205dfe:	e79c                	sd	a5,8(a5)
ffffffffc0205e00:	e39c                	sd	a5,0(a5)
ffffffffc0205e02:	07c1                	addi	a5,a5,16
ffffffffc0205e04:	fef71de3          	bne	a4,a5,ffffffffc0205dfe <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) { // 创建第0个内核线程idleproc
ffffffffc0205e08:	f77fe0ef          	jal	ra,ffffffffc0204d7e <alloc_proc>
ffffffffc0205e0c:	000ad917          	auipc	s2,0xad
ffffffffc0205e10:	a6c90913          	addi	s2,s2,-1428 # ffffffffc02b2878 <idleproc>
ffffffffc0205e14:	00a93023          	sd	a0,0(s2)
ffffffffc0205e18:	0e050f63          	beqz	a0,ffffffffc0205f16 <proc_init+0x140>
        panic("cannot alloc idleproc.\n"); 
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e1c:	4789                	li	a5,2
ffffffffc0205e1e:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e20:	00003797          	auipc	a5,0x3
ffffffffc0205e24:	1e078793          	addi	a5,a5,480 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e28:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e2c:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e2e:	4785                	li	a5,1
ffffffffc0205e30:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e32:	4641                	li	a2,16
ffffffffc0205e34:	4581                	li	a1,0
ffffffffc0205e36:	8522                	mv	a0,s0
ffffffffc0205e38:	3b8000ef          	jal	ra,ffffffffc02061f0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205e3c:	463d                	li	a2,15
ffffffffc0205e3e:	00003597          	auipc	a1,0x3
ffffffffc0205e42:	a0258593          	addi	a1,a1,-1534 # ffffffffc0208840 <default_pmm_manager+0x480>
ffffffffc0205e46:	8522                	mv	a0,s0
ffffffffc0205e48:	3ba000ef          	jal	ra,ffffffffc0206202 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205e4c:	000ad717          	auipc	a4,0xad
ffffffffc0205e50:	a3c70713          	addi	a4,a4,-1476 # ffffffffc02b2888 <nr_process>
ffffffffc0205e54:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205e56:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0); // 创建第一个内核线程initproc
ffffffffc0205e5a:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e5c:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0); // 创建第一个内核线程initproc
ffffffffc0205e5e:	4581                	li	a1,0
ffffffffc0205e60:	00000517          	auipc	a0,0x0
ffffffffc0205e64:	87850513          	addi	a0,a0,-1928 # ffffffffc02056d8 <init_main>
    nr_process ++;
ffffffffc0205e68:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205e6a:	000ad797          	auipc	a5,0xad
ffffffffc0205e6e:	a0d7b323          	sd	a3,-1530(a5) # ffffffffc02b2870 <current>
    int pid = kernel_thread(init_main, NULL, 0); // 创建第一个内核线程initproc
ffffffffc0205e72:	cfaff0ef          	jal	ra,ffffffffc020536c <kernel_thread>
ffffffffc0205e76:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205e78:	08a05363          	blez	a0,ffffffffc0205efe <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205e7c:	6789                	lui	a5,0x2
ffffffffc0205e7e:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205e82:	17f9                	addi	a5,a5,-2
ffffffffc0205e84:	2501                	sext.w	a0,a0
ffffffffc0205e86:	02e7e363          	bltu	a5,a4,ffffffffc0205eac <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205e8a:	45a9                	li	a1,10
ffffffffc0205e8c:	77c000ef          	jal	ra,ffffffffc0206608 <hash32>
ffffffffc0205e90:	02051793          	slli	a5,a0,0x20
ffffffffc0205e94:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205e98:	96a6                	add	a3,a3,s1
ffffffffc0205e9a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205e9c:	a029                	j	ffffffffc0205ea6 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205e9e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c8c>
ffffffffc0205ea2:	04870b63          	beq	a4,s0,ffffffffc0205ef8 <proc_init+0x122>
    return listelm->next;
ffffffffc0205ea6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205ea8:	fef69be3          	bne	a3,a5,ffffffffc0205e9e <proc_init+0xc8>
    return NULL;
ffffffffc0205eac:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205eae:	0b478493          	addi	s1,a5,180
ffffffffc0205eb2:	4641                	li	a2,16
ffffffffc0205eb4:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205eb6:	000ad417          	auipc	s0,0xad
ffffffffc0205eba:	9ca40413          	addi	s0,s0,-1590 # ffffffffc02b2880 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ebe:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205ec0:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ec2:	32e000ef          	jal	ra,ffffffffc02061f0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205ec6:	463d                	li	a2,15
ffffffffc0205ec8:	00003597          	auipc	a1,0x3
ffffffffc0205ecc:	9a058593          	addi	a1,a1,-1632 # ffffffffc0208868 <default_pmm_manager+0x4a8>
ffffffffc0205ed0:	8526                	mv	a0,s1
ffffffffc0205ed2:	330000ef          	jal	ra,ffffffffc0206202 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ed6:	00093783          	ld	a5,0(s2)
ffffffffc0205eda:	cbb5                	beqz	a5,ffffffffc0205f4e <proc_init+0x178>
ffffffffc0205edc:	43dc                	lw	a5,4(a5)
ffffffffc0205ede:	eba5                	bnez	a5,ffffffffc0205f4e <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ee0:	601c                	ld	a5,0(s0)
ffffffffc0205ee2:	c7b1                	beqz	a5,ffffffffc0205f2e <proc_init+0x158>
ffffffffc0205ee4:	43d8                	lw	a4,4(a5)
ffffffffc0205ee6:	4785                	li	a5,1
ffffffffc0205ee8:	04f71363          	bne	a4,a5,ffffffffc0205f2e <proc_init+0x158>
}
ffffffffc0205eec:	60e2                	ld	ra,24(sp)
ffffffffc0205eee:	6442                	ld	s0,16(sp)
ffffffffc0205ef0:	64a2                	ld	s1,8(sp)
ffffffffc0205ef2:	6902                	ld	s2,0(sp)
ffffffffc0205ef4:	6105                	addi	sp,sp,32
ffffffffc0205ef6:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205ef8:	f2878793          	addi	a5,a5,-216
ffffffffc0205efc:	bf4d                	j	ffffffffc0205eae <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205efe:	00003617          	auipc	a2,0x3
ffffffffc0205f02:	94a60613          	addi	a2,a2,-1718 # ffffffffc0208848 <default_pmm_manager+0x488>
ffffffffc0205f06:	38300593          	li	a1,899
ffffffffc0205f0a:	00002517          	auipc	a0,0x2
ffffffffc0205f0e:	5ae50513          	addi	a0,a0,1454 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205f12:	af6fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n"); 
ffffffffc0205f16:	00003617          	auipc	a2,0x3
ffffffffc0205f1a:	91260613          	addi	a2,a2,-1774 # ffffffffc0208828 <default_pmm_manager+0x468>
ffffffffc0205f1e:	37500593          	li	a1,885
ffffffffc0205f22:	00002517          	auipc	a0,0x2
ffffffffc0205f26:	59650513          	addi	a0,a0,1430 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205f2a:	adefa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f2e:	00003697          	auipc	a3,0x3
ffffffffc0205f32:	96a68693          	addi	a3,a3,-1686 # ffffffffc0208898 <default_pmm_manager+0x4d8>
ffffffffc0205f36:	00001617          	auipc	a2,0x1
ffffffffc0205f3a:	da260613          	addi	a2,a2,-606 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205f3e:	38a00593          	li	a1,906
ffffffffc0205f42:	00002517          	auipc	a0,0x2
ffffffffc0205f46:	57650513          	addi	a0,a0,1398 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205f4a:	abefa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f4e:	00003697          	auipc	a3,0x3
ffffffffc0205f52:	92268693          	addi	a3,a3,-1758 # ffffffffc0208870 <default_pmm_manager+0x4b0>
ffffffffc0205f56:	00001617          	auipc	a2,0x1
ffffffffc0205f5a:	d8260613          	addi	a2,a2,-638 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205f5e:	38900593          	li	a1,905
ffffffffc0205f62:	00002517          	auipc	a0,0x2
ffffffffc0205f66:	55650513          	addi	a0,a0,1366 # ffffffffc02084b8 <default_pmm_manager+0xf8>
ffffffffc0205f6a:	a9efa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205f6e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f6e:	1141                	addi	sp,sp,-16
ffffffffc0205f70:	e022                	sd	s0,0(sp)
ffffffffc0205f72:	e406                	sd	ra,8(sp)
ffffffffc0205f74:	000ad417          	auipc	s0,0xad
ffffffffc0205f78:	8fc40413          	addi	s0,s0,-1796 # ffffffffc02b2870 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f7c:	6018                	ld	a4,0(s0)
ffffffffc0205f7e:	6f1c                	ld	a5,24(a4)
ffffffffc0205f80:	dffd                	beqz	a5,ffffffffc0205f7e <cpu_idle+0x10>
            schedule();
ffffffffc0205f82:	086000ef          	jal	ra,ffffffffc0206008 <schedule>
ffffffffc0205f86:	bfdd                	j	ffffffffc0205f7c <cpu_idle+0xe>

ffffffffc0205f88 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f88:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f8a:	1101                	addi	sp,sp,-32
ffffffffc0205f8c:	ec06                	sd	ra,24(sp)
ffffffffc0205f8e:	e822                	sd	s0,16(sp)
ffffffffc0205f90:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f92:	478d                	li	a5,3
ffffffffc0205f94:	04f70b63          	beq	a4,a5,ffffffffc0205fea <wakeup_proc+0x62>
ffffffffc0205f98:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f9a:	100027f3          	csrr	a5,sstatus
ffffffffc0205f9e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205fa0:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fa2:	ef9d                	bnez	a5,ffffffffc0205fe0 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205fa4:	4789                	li	a5,2
ffffffffc0205fa6:	02f70163          	beq	a4,a5,ffffffffc0205fc8 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205faa:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205fac:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205fb0:	e491                	bnez	s1,ffffffffc0205fbc <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205fb2:	60e2                	ld	ra,24(sp)
ffffffffc0205fb4:	6442                	ld	s0,16(sp)
ffffffffc0205fb6:	64a2                	ld	s1,8(sp)
ffffffffc0205fb8:	6105                	addi	sp,sp,32
ffffffffc0205fba:	8082                	ret
ffffffffc0205fbc:	6442                	ld	s0,16(sp)
ffffffffc0205fbe:	60e2                	ld	ra,24(sp)
ffffffffc0205fc0:	64a2                	ld	s1,8(sp)
ffffffffc0205fc2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205fc4:	e7efa06f          	j	ffffffffc0200642 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205fc8:	00003617          	auipc	a2,0x3
ffffffffc0205fcc:	93060613          	addi	a2,a2,-1744 # ffffffffc02088f8 <default_pmm_manager+0x538>
ffffffffc0205fd0:	45c9                	li	a1,18
ffffffffc0205fd2:	00003517          	auipc	a0,0x3
ffffffffc0205fd6:	90e50513          	addi	a0,a0,-1778 # ffffffffc02088e0 <default_pmm_manager+0x520>
ffffffffc0205fda:	a96fa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0205fde:	bfc9                	j	ffffffffc0205fb0 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205fe0:	e68fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205fe4:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205fe6:	4485                	li	s1,1
ffffffffc0205fe8:	bf75                	j	ffffffffc0205fa4 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205fea:	00003697          	auipc	a3,0x3
ffffffffc0205fee:	8d668693          	addi	a3,a3,-1834 # ffffffffc02088c0 <default_pmm_manager+0x500>
ffffffffc0205ff2:	00001617          	auipc	a2,0x1
ffffffffc0205ff6:	ce660613          	addi	a2,a2,-794 # ffffffffc0206cd8 <commands+0x410>
ffffffffc0205ffa:	45a5                	li	a1,9
ffffffffc0205ffc:	00003517          	auipc	a0,0x3
ffffffffc0206000:	8e450513          	addi	a0,a0,-1820 # ffffffffc02088e0 <default_pmm_manager+0x520>
ffffffffc0206004:	a04fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0206008 <schedule>:

void
schedule(void) {
ffffffffc0206008:	1141                	addi	sp,sp,-16
ffffffffc020600a:	e406                	sd	ra,8(sp)
ffffffffc020600c:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020600e:	100027f3          	csrr	a5,sstatus
ffffffffc0206012:	8b89                	andi	a5,a5,2
ffffffffc0206014:	4401                	li	s0,0
ffffffffc0206016:	efbd                	bnez	a5,ffffffffc0206094 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0206018:	000ad897          	auipc	a7,0xad
ffffffffc020601c:	8588b883          	ld	a7,-1960(a7) # ffffffffc02b2870 <current>
ffffffffc0206020:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206024:	000ad517          	auipc	a0,0xad
ffffffffc0206028:	85453503          	ld	a0,-1964(a0) # ffffffffc02b2878 <idleproc>
ffffffffc020602c:	04a88e63          	beq	a7,a0,ffffffffc0206088 <schedule+0x80>
ffffffffc0206030:	0c888693          	addi	a3,a7,200
ffffffffc0206034:	000ac617          	auipc	a2,0xac
ffffffffc0206038:	7b460613          	addi	a2,a2,1972 # ffffffffc02b27e8 <proc_list>
        le = last;
ffffffffc020603c:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020603e:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {  // 在proc_list链表总找到一个处于就绪态的线程即initproc
ffffffffc0206040:	4809                	li	a6,2
ffffffffc0206042:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206044:	00c78863          	beq	a5,a2,ffffffffc0206054 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {  // 在proc_list链表总找到一个处于就绪态的线程即initproc
ffffffffc0206048:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020604c:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {  // 在proc_list链表总找到一个处于就绪态的线程即initproc
ffffffffc0206050:	03070163          	beq	a4,a6,ffffffffc0206072 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206054:	fef697e3          	bne	a3,a5,ffffffffc0206042 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206058:	ed89                	bnez	a1,ffffffffc0206072 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020605a:	451c                	lw	a5,8(a0)
ffffffffc020605c:	2785                	addiw	a5,a5,1
ffffffffc020605e:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206060:	00a88463          	beq	a7,a0,ffffffffc0206068 <schedule+0x60>
            proc_run(next); // 运行proc_run函数完成线程切换
ffffffffc0206064:	e8ffe0ef          	jal	ra,ffffffffc0204ef2 <proc_run>
    if (flag) {
ffffffffc0206068:	e819                	bnez	s0,ffffffffc020607e <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020606a:	60a2                	ld	ra,8(sp)
ffffffffc020606c:	6402                	ld	s0,0(sp)
ffffffffc020606e:	0141                	addi	sp,sp,16
ffffffffc0206070:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206072:	4198                	lw	a4,0(a1)
ffffffffc0206074:	4789                	li	a5,2
ffffffffc0206076:	fef712e3          	bne	a4,a5,ffffffffc020605a <schedule+0x52>
ffffffffc020607a:	852e                	mv	a0,a1
ffffffffc020607c:	bff9                	j	ffffffffc020605a <schedule+0x52>
}
ffffffffc020607e:	6402                	ld	s0,0(sp)
ffffffffc0206080:	60a2                	ld	ra,8(sp)
ffffffffc0206082:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206084:	dbefa06f          	j	ffffffffc0200642 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206088:	000ac617          	auipc	a2,0xac
ffffffffc020608c:	76060613          	addi	a2,a2,1888 # ffffffffc02b27e8 <proc_list>
ffffffffc0206090:	86b2                	mv	a3,a2
ffffffffc0206092:	b76d                	j	ffffffffc020603c <schedule+0x34>
        intr_disable();
ffffffffc0206094:	db4fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0206098:	4405                	li	s0,1
ffffffffc020609a:	bfbd                	j	ffffffffc0206018 <schedule+0x10>

ffffffffc020609c <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020609c:	000ac797          	auipc	a5,0xac
ffffffffc02060a0:	7d47b783          	ld	a5,2004(a5) # ffffffffc02b2870 <current>
}
ffffffffc02060a4:	43c8                	lw	a0,4(a5)
ffffffffc02060a6:	8082                	ret

ffffffffc02060a8 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02060a8:	4501                	li	a0,0
ffffffffc02060aa:	8082                	ret

ffffffffc02060ac <sys_putc>:
    cputchar(c);
ffffffffc02060ac:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02060ae:	1141                	addi	sp,sp,-16
ffffffffc02060b0:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02060b2:	850fa0ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc02060b6:	60a2                	ld	ra,8(sp)
ffffffffc02060b8:	4501                	li	a0,0
ffffffffc02060ba:	0141                	addi	sp,sp,16
ffffffffc02060bc:	8082                	ret

ffffffffc02060be <sys_kill>:
    return do_kill(pid);
ffffffffc02060be:	4108                	lw	a0,0(a0)
ffffffffc02060c0:	c9bff06f          	j	ffffffffc0205d5a <do_kill>

ffffffffc02060c4 <sys_yield>:
    return do_yield();
ffffffffc02060c4:	c49ff06f          	j	ffffffffc0205d0c <do_yield>

ffffffffc02060c8 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02060c8:	6d14                	ld	a3,24(a0)
ffffffffc02060ca:	6910                	ld	a2,16(a0)
ffffffffc02060cc:	650c                	ld	a1,8(a0)
ffffffffc02060ce:	6108                	ld	a0,0(a0)
ffffffffc02060d0:	f2cff06f          	j	ffffffffc02057fc <do_execve>

ffffffffc02060d4 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02060d4:	650c                	ld	a1,8(a0)
ffffffffc02060d6:	4108                	lw	a0,0(a0)
ffffffffc02060d8:	c45ff06f          	j	ffffffffc0205d1c <do_wait>

ffffffffc02060dc <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02060dc:	000ac797          	auipc	a5,0xac
ffffffffc02060e0:	7947b783          	ld	a5,1940(a5) # ffffffffc02b2870 <current>
ffffffffc02060e4:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02060e6:	4501                	li	a0,0
ffffffffc02060e8:	6a0c                	ld	a1,16(a2)
ffffffffc02060ea:	e75fe06f          	j	ffffffffc0204f5e <do_fork>

ffffffffc02060ee <sys_exit>:
    return do_exit(error_code);
ffffffffc02060ee:	4108                	lw	a0,0(a0)
ffffffffc02060f0:	accff06f          	j	ffffffffc02053bc <do_exit>

ffffffffc02060f4 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060f4:	715d                	addi	sp,sp,-80
ffffffffc02060f6:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060f8:	000ac497          	auipc	s1,0xac
ffffffffc02060fc:	77848493          	addi	s1,s1,1912 # ffffffffc02b2870 <current>
ffffffffc0206100:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206102:	e0a2                	sd	s0,64(sp)
ffffffffc0206104:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206106:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206108:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020610a:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc020610c:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206110:	0327ee63          	bltu	a5,s2,ffffffffc020614c <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206114:	00391713          	slli	a4,s2,0x3
ffffffffc0206118:	00003797          	auipc	a5,0x3
ffffffffc020611c:	84878793          	addi	a5,a5,-1976 # ffffffffc0208960 <syscalls>
ffffffffc0206120:	97ba                	add	a5,a5,a4
ffffffffc0206122:	639c                	ld	a5,0(a5)
ffffffffc0206124:	c785                	beqz	a5,ffffffffc020614c <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206126:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206128:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020612a:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020612c:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020612e:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206130:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206132:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206134:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206136:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206138:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020613a:	0028                	addi	a0,sp,8
ffffffffc020613c:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc020613e:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206140:	e828                	sd	a0,80(s0)
}
ffffffffc0206142:	6406                	ld	s0,64(sp)
ffffffffc0206144:	74e2                	ld	s1,56(sp)
ffffffffc0206146:	7942                	ld	s2,48(sp)
ffffffffc0206148:	6161                	addi	sp,sp,80
ffffffffc020614a:	8082                	ret
    print_trapframe(tf);
ffffffffc020614c:	8522                	mv	a0,s0
ffffffffc020614e:	ee8fa0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206152:	609c                	ld	a5,0(s1)
ffffffffc0206154:	86ca                	mv	a3,s2
ffffffffc0206156:	00002617          	auipc	a2,0x2
ffffffffc020615a:	7c260613          	addi	a2,a2,1986 # ffffffffc0208918 <default_pmm_manager+0x558>
ffffffffc020615e:	43d8                	lw	a4,4(a5)
ffffffffc0206160:	06200593          	li	a1,98
ffffffffc0206164:	0b478793          	addi	a5,a5,180
ffffffffc0206168:	00002517          	auipc	a0,0x2
ffffffffc020616c:	7e050513          	addi	a0,a0,2016 # ffffffffc0208948 <default_pmm_manager+0x588>
ffffffffc0206170:	898fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0206174 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206174:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206178:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020617a:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020617c:	cb81                	beqz	a5,ffffffffc020618c <strlen+0x18>
        cnt ++;
ffffffffc020617e:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206180:	00a707b3          	add	a5,a4,a0
ffffffffc0206184:	0007c783          	lbu	a5,0(a5)
ffffffffc0206188:	fbfd                	bnez	a5,ffffffffc020617e <strlen+0xa>
ffffffffc020618a:	8082                	ret
    }
    return cnt;
}
ffffffffc020618c:	8082                	ret

ffffffffc020618e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020618e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206190:	e589                	bnez	a1,ffffffffc020619a <strnlen+0xc>
ffffffffc0206192:	a811                	j	ffffffffc02061a6 <strnlen+0x18>
        cnt ++;
ffffffffc0206194:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206196:	00f58863          	beq	a1,a5,ffffffffc02061a6 <strnlen+0x18>
ffffffffc020619a:	00f50733          	add	a4,a0,a5
ffffffffc020619e:	00074703          	lbu	a4,0(a4)
ffffffffc02061a2:	fb6d                	bnez	a4,ffffffffc0206194 <strnlen+0x6>
ffffffffc02061a4:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02061a6:	852e                	mv	a0,a1
ffffffffc02061a8:	8082                	ret

ffffffffc02061aa <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02061aa:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02061ac:	0005c703          	lbu	a4,0(a1)
ffffffffc02061b0:	0785                	addi	a5,a5,1
ffffffffc02061b2:	0585                	addi	a1,a1,1
ffffffffc02061b4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02061b8:	fb75                	bnez	a4,ffffffffc02061ac <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02061ba:	8082                	ret

ffffffffc02061bc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061bc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02061c0:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061c4:	cb89                	beqz	a5,ffffffffc02061d6 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02061c6:	0505                	addi	a0,a0,1
ffffffffc02061c8:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02061ca:	fee789e3          	beq	a5,a4,ffffffffc02061bc <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02061ce:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02061d2:	9d19                	subw	a0,a0,a4
ffffffffc02061d4:	8082                	ret
ffffffffc02061d6:	4501                	li	a0,0
ffffffffc02061d8:	bfed                	j	ffffffffc02061d2 <strcmp+0x16>

ffffffffc02061da <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02061da:	00054783          	lbu	a5,0(a0)
ffffffffc02061de:	c799                	beqz	a5,ffffffffc02061ec <strchr+0x12>
        if (*s == c) {
ffffffffc02061e0:	00f58763          	beq	a1,a5,ffffffffc02061ee <strchr+0x14>
    while (*s != '\0') {
ffffffffc02061e4:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02061e8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02061ea:	fbfd                	bnez	a5,ffffffffc02061e0 <strchr+0x6>
    }
    return NULL;
ffffffffc02061ec:	4501                	li	a0,0
}
ffffffffc02061ee:	8082                	ret

ffffffffc02061f0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02061f0:	ca01                	beqz	a2,ffffffffc0206200 <memset+0x10>
ffffffffc02061f2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02061f4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02061f6:	0785                	addi	a5,a5,1
ffffffffc02061f8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02061fc:	fec79de3          	bne	a5,a2,ffffffffc02061f6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206200:	8082                	ret

ffffffffc0206202 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206202:	ca19                	beqz	a2,ffffffffc0206218 <memcpy+0x16>
ffffffffc0206204:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206206:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206208:	0005c703          	lbu	a4,0(a1)
ffffffffc020620c:	0585                	addi	a1,a1,1
ffffffffc020620e:	0785                	addi	a5,a5,1
ffffffffc0206210:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206214:	fec59ae3          	bne	a1,a2,ffffffffc0206208 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206218:	8082                	ret

ffffffffc020621a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020621a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020621e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206220:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206224:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206226:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020622a:	f022                	sd	s0,32(sp)
ffffffffc020622c:	ec26                	sd	s1,24(sp)
ffffffffc020622e:	e84a                	sd	s2,16(sp)
ffffffffc0206230:	f406                	sd	ra,40(sp)
ffffffffc0206232:	e44e                	sd	s3,8(sp)
ffffffffc0206234:	84aa                	mv	s1,a0
ffffffffc0206236:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206238:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020623c:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020623e:	03067e63          	bgeu	a2,a6,ffffffffc020627a <printnum+0x60>
ffffffffc0206242:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0206244:	00805763          	blez	s0,ffffffffc0206252 <printnum+0x38>
ffffffffc0206248:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020624a:	85ca                	mv	a1,s2
ffffffffc020624c:	854e                	mv	a0,s3
ffffffffc020624e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206250:	fc65                	bnez	s0,ffffffffc0206248 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206252:	1a02                	slli	s4,s4,0x20
ffffffffc0206254:	00003797          	auipc	a5,0x3
ffffffffc0206258:	80c78793          	addi	a5,a5,-2036 # ffffffffc0208a60 <syscalls+0x100>
ffffffffc020625c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206260:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206262:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206264:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206268:	70a2                	ld	ra,40(sp)
ffffffffc020626a:	69a2                	ld	s3,8(sp)
ffffffffc020626c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020626e:	85ca                	mv	a1,s2
ffffffffc0206270:	87a6                	mv	a5,s1
}
ffffffffc0206272:	6942                	ld	s2,16(sp)
ffffffffc0206274:	64e2                	ld	s1,24(sp)
ffffffffc0206276:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206278:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020627a:	03065633          	divu	a2,a2,a6
ffffffffc020627e:	8722                	mv	a4,s0
ffffffffc0206280:	f9bff0ef          	jal	ra,ffffffffc020621a <printnum>
ffffffffc0206284:	b7f9                	j	ffffffffc0206252 <printnum+0x38>

ffffffffc0206286 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206286:	7119                	addi	sp,sp,-128
ffffffffc0206288:	f4a6                	sd	s1,104(sp)
ffffffffc020628a:	f0ca                	sd	s2,96(sp)
ffffffffc020628c:	ecce                	sd	s3,88(sp)
ffffffffc020628e:	e8d2                	sd	s4,80(sp)
ffffffffc0206290:	e4d6                	sd	s5,72(sp)
ffffffffc0206292:	e0da                	sd	s6,64(sp)
ffffffffc0206294:	fc5e                	sd	s7,56(sp)
ffffffffc0206296:	f06a                	sd	s10,32(sp)
ffffffffc0206298:	fc86                	sd	ra,120(sp)
ffffffffc020629a:	f8a2                	sd	s0,112(sp)
ffffffffc020629c:	f862                	sd	s8,48(sp)
ffffffffc020629e:	f466                	sd	s9,40(sp)
ffffffffc02062a0:	ec6e                	sd	s11,24(sp)
ffffffffc02062a2:	892a                	mv	s2,a0
ffffffffc02062a4:	84ae                	mv	s1,a1
ffffffffc02062a6:	8d32                	mv	s10,a2
ffffffffc02062a8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062aa:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02062ae:	5b7d                	li	s6,-1
ffffffffc02062b0:	00002a97          	auipc	s5,0x2
ffffffffc02062b4:	7dca8a93          	addi	s5,s5,2012 # ffffffffc0208a8c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062b8:	00003b97          	auipc	s7,0x3
ffffffffc02062bc:	9f0b8b93          	addi	s7,s7,-1552 # ffffffffc0208ca8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062c0:	000d4503          	lbu	a0,0(s10)
ffffffffc02062c4:	001d0413          	addi	s0,s10,1
ffffffffc02062c8:	01350a63          	beq	a0,s3,ffffffffc02062dc <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02062cc:	c121                	beqz	a0,ffffffffc020630c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02062ce:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062d0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02062d2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062d4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02062d8:	ff351ae3          	bne	a0,s3,ffffffffc02062cc <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062dc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02062e0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02062e4:	4c81                	li	s9,0
ffffffffc02062e6:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02062e8:	5c7d                	li	s8,-1
ffffffffc02062ea:	5dfd                	li	s11,-1
ffffffffc02062ec:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02062f0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062f2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02062f6:	0ff5f593          	zext.b	a1,a1
ffffffffc02062fa:	00140d13          	addi	s10,s0,1
ffffffffc02062fe:	04b56263          	bltu	a0,a1,ffffffffc0206342 <vprintfmt+0xbc>
ffffffffc0206302:	058a                	slli	a1,a1,0x2
ffffffffc0206304:	95d6                	add	a1,a1,s5
ffffffffc0206306:	4194                	lw	a3,0(a1)
ffffffffc0206308:	96d6                	add	a3,a3,s5
ffffffffc020630a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020630c:	70e6                	ld	ra,120(sp)
ffffffffc020630e:	7446                	ld	s0,112(sp)
ffffffffc0206310:	74a6                	ld	s1,104(sp)
ffffffffc0206312:	7906                	ld	s2,96(sp)
ffffffffc0206314:	69e6                	ld	s3,88(sp)
ffffffffc0206316:	6a46                	ld	s4,80(sp)
ffffffffc0206318:	6aa6                	ld	s5,72(sp)
ffffffffc020631a:	6b06                	ld	s6,64(sp)
ffffffffc020631c:	7be2                	ld	s7,56(sp)
ffffffffc020631e:	7c42                	ld	s8,48(sp)
ffffffffc0206320:	7ca2                	ld	s9,40(sp)
ffffffffc0206322:	7d02                	ld	s10,32(sp)
ffffffffc0206324:	6de2                	ld	s11,24(sp)
ffffffffc0206326:	6109                	addi	sp,sp,128
ffffffffc0206328:	8082                	ret
            padc = '0';
ffffffffc020632a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020632c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206330:	846a                	mv	s0,s10
ffffffffc0206332:	00140d13          	addi	s10,s0,1
ffffffffc0206336:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020633a:	0ff5f593          	zext.b	a1,a1
ffffffffc020633e:	fcb572e3          	bgeu	a0,a1,ffffffffc0206302 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0206342:	85a6                	mv	a1,s1
ffffffffc0206344:	02500513          	li	a0,37
ffffffffc0206348:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020634a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020634e:	8d22                	mv	s10,s0
ffffffffc0206350:	f73788e3          	beq	a5,s3,ffffffffc02062c0 <vprintfmt+0x3a>
ffffffffc0206354:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0206358:	1d7d                	addi	s10,s10,-1
ffffffffc020635a:	ff379de3          	bne	a5,s3,ffffffffc0206354 <vprintfmt+0xce>
ffffffffc020635e:	b78d                	j	ffffffffc02062c0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0206360:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0206364:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206368:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020636a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020636e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206372:	02d86463          	bltu	a6,a3,ffffffffc020639a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0206376:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020637a:	002c169b          	slliw	a3,s8,0x2
ffffffffc020637e:	0186873b          	addw	a4,a3,s8
ffffffffc0206382:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206386:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206388:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020638c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020638e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0206392:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206396:	fed870e3          	bgeu	a6,a3,ffffffffc0206376 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020639a:	f40ddce3          	bgez	s11,ffffffffc02062f2 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020639e:	8de2                	mv	s11,s8
ffffffffc02063a0:	5c7d                	li	s8,-1
ffffffffc02063a2:	bf81                	j	ffffffffc02062f2 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02063a4:	fffdc693          	not	a3,s11
ffffffffc02063a8:	96fd                	srai	a3,a3,0x3f
ffffffffc02063aa:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063ae:	00144603          	lbu	a2,1(s0)
ffffffffc02063b2:	2d81                	sext.w	s11,s11
ffffffffc02063b4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063b6:	bf35                	j	ffffffffc02062f2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02063b8:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063bc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02063c0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063c2:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02063c4:	bfd9                	j	ffffffffc020639a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02063c6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02063c8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02063cc:	01174463          	blt	a4,a7,ffffffffc02063d4 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02063d0:	1a088e63          	beqz	a7,ffffffffc020658c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02063d4:	000a3603          	ld	a2,0(s4)
ffffffffc02063d8:	46c1                	li	a3,16
ffffffffc02063da:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02063dc:	2781                	sext.w	a5,a5
ffffffffc02063de:	876e                	mv	a4,s11
ffffffffc02063e0:	85a6                	mv	a1,s1
ffffffffc02063e2:	854a                	mv	a0,s2
ffffffffc02063e4:	e37ff0ef          	jal	ra,ffffffffc020621a <printnum>
            break;
ffffffffc02063e8:	bde1                	j	ffffffffc02062c0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02063ea:	000a2503          	lw	a0,0(s4)
ffffffffc02063ee:	85a6                	mv	a1,s1
ffffffffc02063f0:	0a21                	addi	s4,s4,8
ffffffffc02063f2:	9902                	jalr	s2
            break;
ffffffffc02063f4:	b5f1                	j	ffffffffc02062c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02063f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02063f8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02063fc:	01174463          	blt	a4,a7,ffffffffc0206404 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0206400:	18088163          	beqz	a7,ffffffffc0206582 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0206404:	000a3603          	ld	a2,0(s4)
ffffffffc0206408:	46a9                	li	a3,10
ffffffffc020640a:	8a2e                	mv	s4,a1
ffffffffc020640c:	bfc1                	j	ffffffffc02063dc <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020640e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206412:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206414:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206416:	bdf1                	j	ffffffffc02062f2 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0206418:	85a6                	mv	a1,s1
ffffffffc020641a:	02500513          	li	a0,37
ffffffffc020641e:	9902                	jalr	s2
            break;
ffffffffc0206420:	b545                	j	ffffffffc02062c0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206422:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0206426:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206428:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020642a:	b5e1                	j	ffffffffc02062f2 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020642c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020642e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206432:	01174463          	blt	a4,a7,ffffffffc020643a <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0206436:	14088163          	beqz	a7,ffffffffc0206578 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020643a:	000a3603          	ld	a2,0(s4)
ffffffffc020643e:	46a1                	li	a3,8
ffffffffc0206440:	8a2e                	mv	s4,a1
ffffffffc0206442:	bf69                	j	ffffffffc02063dc <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0206444:	03000513          	li	a0,48
ffffffffc0206448:	85a6                	mv	a1,s1
ffffffffc020644a:	e03e                	sd	a5,0(sp)
ffffffffc020644c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020644e:	85a6                	mv	a1,s1
ffffffffc0206450:	07800513          	li	a0,120
ffffffffc0206454:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206456:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206458:	6782                	ld	a5,0(sp)
ffffffffc020645a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020645c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0206460:	bfb5                	j	ffffffffc02063dc <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206462:	000a3403          	ld	s0,0(s4)
ffffffffc0206466:	008a0713          	addi	a4,s4,8
ffffffffc020646a:	e03a                	sd	a4,0(sp)
ffffffffc020646c:	14040263          	beqz	s0,ffffffffc02065b0 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0206470:	0fb05763          	blez	s11,ffffffffc020655e <vprintfmt+0x2d8>
ffffffffc0206474:	02d00693          	li	a3,45
ffffffffc0206478:	0cd79163          	bne	a5,a3,ffffffffc020653a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020647c:	00044783          	lbu	a5,0(s0)
ffffffffc0206480:	0007851b          	sext.w	a0,a5
ffffffffc0206484:	cf85                	beqz	a5,ffffffffc02064bc <vprintfmt+0x236>
ffffffffc0206486:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020648a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020648e:	000c4563          	bltz	s8,ffffffffc0206498 <vprintfmt+0x212>
ffffffffc0206492:	3c7d                	addiw	s8,s8,-1
ffffffffc0206494:	036c0263          	beq	s8,s6,ffffffffc02064b8 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206498:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020649a:	0e0c8e63          	beqz	s9,ffffffffc0206596 <vprintfmt+0x310>
ffffffffc020649e:	3781                	addiw	a5,a5,-32
ffffffffc02064a0:	0ef47b63          	bgeu	s0,a5,ffffffffc0206596 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02064a4:	03f00513          	li	a0,63
ffffffffc02064a8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064aa:	000a4783          	lbu	a5,0(s4)
ffffffffc02064ae:	3dfd                	addiw	s11,s11,-1
ffffffffc02064b0:	0a05                	addi	s4,s4,1
ffffffffc02064b2:	0007851b          	sext.w	a0,a5
ffffffffc02064b6:	ffe1                	bnez	a5,ffffffffc020648e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02064b8:	01b05963          	blez	s11,ffffffffc02064ca <vprintfmt+0x244>
ffffffffc02064bc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02064be:	85a6                	mv	a1,s1
ffffffffc02064c0:	02000513          	li	a0,32
ffffffffc02064c4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02064c6:	fe0d9be3          	bnez	s11,ffffffffc02064bc <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064ca:	6a02                	ld	s4,0(sp)
ffffffffc02064cc:	bbd5                	j	ffffffffc02062c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02064ce:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02064d0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02064d4:	01174463          	blt	a4,a7,ffffffffc02064dc <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02064d8:	08088d63          	beqz	a7,ffffffffc0206572 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02064dc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02064e0:	0a044d63          	bltz	s0,ffffffffc020659a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02064e4:	8622                	mv	a2,s0
ffffffffc02064e6:	8a66                	mv	s4,s9
ffffffffc02064e8:	46a9                	li	a3,10
ffffffffc02064ea:	bdcd                	j	ffffffffc02063dc <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02064ec:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064f0:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02064f2:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02064f4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02064f8:	8fb5                	xor	a5,a5,a3
ffffffffc02064fa:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064fe:	02d74163          	blt	a4,a3,ffffffffc0206520 <vprintfmt+0x29a>
ffffffffc0206502:	00369793          	slli	a5,a3,0x3
ffffffffc0206506:	97de                	add	a5,a5,s7
ffffffffc0206508:	639c                	ld	a5,0(a5)
ffffffffc020650a:	cb99                	beqz	a5,ffffffffc0206520 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020650c:	86be                	mv	a3,a5
ffffffffc020650e:	00000617          	auipc	a2,0x0
ffffffffc0206512:	13a60613          	addi	a2,a2,314 # ffffffffc0206648 <etext+0x2a>
ffffffffc0206516:	85a6                	mv	a1,s1
ffffffffc0206518:	854a                	mv	a0,s2
ffffffffc020651a:	0ce000ef          	jal	ra,ffffffffc02065e8 <printfmt>
ffffffffc020651e:	b34d                	j	ffffffffc02062c0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206520:	00002617          	auipc	a2,0x2
ffffffffc0206524:	56060613          	addi	a2,a2,1376 # ffffffffc0208a80 <syscalls+0x120>
ffffffffc0206528:	85a6                	mv	a1,s1
ffffffffc020652a:	854a                	mv	a0,s2
ffffffffc020652c:	0bc000ef          	jal	ra,ffffffffc02065e8 <printfmt>
ffffffffc0206530:	bb41                	j	ffffffffc02062c0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206532:	00002417          	auipc	s0,0x2
ffffffffc0206536:	54640413          	addi	s0,s0,1350 # ffffffffc0208a78 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020653a:	85e2                	mv	a1,s8
ffffffffc020653c:	8522                	mv	a0,s0
ffffffffc020653e:	e43e                	sd	a5,8(sp)
ffffffffc0206540:	c4fff0ef          	jal	ra,ffffffffc020618e <strnlen>
ffffffffc0206544:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206548:	01b05b63          	blez	s11,ffffffffc020655e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020654c:	67a2                	ld	a5,8(sp)
ffffffffc020654e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206552:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206554:	85a6                	mv	a1,s1
ffffffffc0206556:	8552                	mv	a0,s4
ffffffffc0206558:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020655a:	fe0d9ce3          	bnez	s11,ffffffffc0206552 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020655e:	00044783          	lbu	a5,0(s0)
ffffffffc0206562:	00140a13          	addi	s4,s0,1
ffffffffc0206566:	0007851b          	sext.w	a0,a5
ffffffffc020656a:	d3a5                	beqz	a5,ffffffffc02064ca <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020656c:	05e00413          	li	s0,94
ffffffffc0206570:	bf39                	j	ffffffffc020648e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0206572:	000a2403          	lw	s0,0(s4)
ffffffffc0206576:	b7ad                	j	ffffffffc02064e0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206578:	000a6603          	lwu	a2,0(s4)
ffffffffc020657c:	46a1                	li	a3,8
ffffffffc020657e:	8a2e                	mv	s4,a1
ffffffffc0206580:	bdb1                	j	ffffffffc02063dc <vprintfmt+0x156>
ffffffffc0206582:	000a6603          	lwu	a2,0(s4)
ffffffffc0206586:	46a9                	li	a3,10
ffffffffc0206588:	8a2e                	mv	s4,a1
ffffffffc020658a:	bd89                	j	ffffffffc02063dc <vprintfmt+0x156>
ffffffffc020658c:	000a6603          	lwu	a2,0(s4)
ffffffffc0206590:	46c1                	li	a3,16
ffffffffc0206592:	8a2e                	mv	s4,a1
ffffffffc0206594:	b5a1                	j	ffffffffc02063dc <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0206596:	9902                	jalr	s2
ffffffffc0206598:	bf09                	j	ffffffffc02064aa <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020659a:	85a6                	mv	a1,s1
ffffffffc020659c:	02d00513          	li	a0,45
ffffffffc02065a0:	e03e                	sd	a5,0(sp)
ffffffffc02065a2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02065a4:	6782                	ld	a5,0(sp)
ffffffffc02065a6:	8a66                	mv	s4,s9
ffffffffc02065a8:	40800633          	neg	a2,s0
ffffffffc02065ac:	46a9                	li	a3,10
ffffffffc02065ae:	b53d                	j	ffffffffc02063dc <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02065b0:	03b05163          	blez	s11,ffffffffc02065d2 <vprintfmt+0x34c>
ffffffffc02065b4:	02d00693          	li	a3,45
ffffffffc02065b8:	f6d79de3          	bne	a5,a3,ffffffffc0206532 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02065bc:	00002417          	auipc	s0,0x2
ffffffffc02065c0:	4bc40413          	addi	s0,s0,1212 # ffffffffc0208a78 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065c4:	02800793          	li	a5,40
ffffffffc02065c8:	02800513          	li	a0,40
ffffffffc02065cc:	00140a13          	addi	s4,s0,1
ffffffffc02065d0:	bd6d                	j	ffffffffc020648a <vprintfmt+0x204>
ffffffffc02065d2:	00002a17          	auipc	s4,0x2
ffffffffc02065d6:	4a7a0a13          	addi	s4,s4,1191 # ffffffffc0208a79 <syscalls+0x119>
ffffffffc02065da:	02800513          	li	a0,40
ffffffffc02065de:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065e2:	05e00413          	li	s0,94
ffffffffc02065e6:	b565                	j	ffffffffc020648e <vprintfmt+0x208>

ffffffffc02065e8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065e8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02065ea:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065ee:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065f0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065f2:	ec06                	sd	ra,24(sp)
ffffffffc02065f4:	f83a                	sd	a4,48(sp)
ffffffffc02065f6:	fc3e                	sd	a5,56(sp)
ffffffffc02065f8:	e0c2                	sd	a6,64(sp)
ffffffffc02065fa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02065fc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065fe:	c89ff0ef          	jal	ra,ffffffffc0206286 <vprintfmt>
}
ffffffffc0206602:	60e2                	ld	ra,24(sp)
ffffffffc0206604:	6161                	addi	sp,sp,80
ffffffffc0206606:	8082                	ret

ffffffffc0206608 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206608:	9e3707b7          	lui	a5,0x9e370
ffffffffc020660c:	2785                	addiw	a5,a5,1
ffffffffc020660e:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206612:	02000793          	li	a5,32
ffffffffc0206616:	9f8d                	subw	a5,a5,a1
}
ffffffffc0206618:	00f5553b          	srlw	a0,a0,a5
ffffffffc020661c:	8082                	ret
