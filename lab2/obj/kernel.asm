
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44e60613          	addi	a2,a2,1102 # ffffffffc0206488 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	5f6010ef          	jal	ra,ffffffffc0201640 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	60650513          	addi	a0,a0,1542 # ffffffffc0201658 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	705000ef          	jal	ra,ffffffffc0200f6a <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	0c4010ef          	jal	ra,ffffffffc020116a <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	08e010ef          	jal	ra,ffffffffc020116a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	53c50513          	addi	a0,a0,1340 # ffffffffc0201678 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	54650513          	addi	a0,a0,1350 # ffffffffc0201698 <etext+0x46>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	4f458593          	addi	a1,a1,1268 # ffffffffc0201652 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	55250513          	addi	a0,a0,1362 # ffffffffc02016b8 <etext+0x66>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	55e50513          	addi	a0,a0,1374 # ffffffffc02016d8 <etext+0x86>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	30258593          	addi	a1,a1,770 # ffffffffc0206488 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	56a50513          	addi	a0,a0,1386 # ffffffffc02016f8 <etext+0xa6>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6ed58593          	addi	a1,a1,1773 # ffffffffc0206887 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	55c50513          	addi	a0,a0,1372 # ffffffffc0201718 <etext+0xc6>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	57e60613          	addi	a2,a2,1406 # ffffffffc0201748 <etext+0xf6>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	58a50513          	addi	a0,a0,1418 # ffffffffc0201760 <etext+0x10e>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	59260613          	addi	a2,a2,1426 # ffffffffc0201778 <etext+0x126>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	5aa58593          	addi	a1,a1,1450 # ffffffffc0201798 <etext+0x146>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	5aa50513          	addi	a0,a0,1450 # ffffffffc02017a0 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	5ac60613          	addi	a2,a2,1452 # ffffffffc02017b0 <etext+0x15e>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	5cc58593          	addi	a1,a1,1484 # ffffffffc02017d8 <etext+0x186>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	58c50513          	addi	a0,a0,1420 # ffffffffc02017a0 <etext+0x14e>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	5c860613          	addi	a2,a2,1480 # ffffffffc02017e8 <etext+0x196>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	5e058593          	addi	a1,a1,1504 # ffffffffc0201808 <etext+0x1b6>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	57050513          	addi	a0,a0,1392 # ffffffffc02017a0 <etext+0x14e>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	5ae50513          	addi	a0,a0,1454 # ffffffffc0201818 <etext+0x1c6>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	5b450513          	addi	a0,a0,1460 # ffffffffc0201840 <etext+0x1ee>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	60ec0c13          	addi	s8,s8,1550 # ffffffffc02018b0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	5be90913          	addi	s2,s2,1470 # ffffffffc0201868 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	5be48493          	addi	s1,s1,1470 # ffffffffc0201870 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	5bcb0b13          	addi	s6,s6,1468 # ffffffffc0201878 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	4d4a0a13          	addi	s4,s4,1236 # ffffffffc0201798 <etext+0x146>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	21c010ef          	jal	ra,ffffffffc02014ec <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	5cad0d13          	addi	s10,s10,1482 # ffffffffc02018b0 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	318010ef          	jal	ra,ffffffffc020160c <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	304010ef          	jal	ra,ffffffffc020160c <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	2e4010ef          	jal	ra,ffffffffc020162a <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	2a6010ef          	jal	ra,ffffffffc020162a <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	4fa50513          	addi	a0,a0,1274 # ffffffffc0201898 <etext+0x246>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	51e50513          	addi	a0,a0,1310 # ffffffffc02018f8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	35050513          	addi	a0,a0,848 # ffffffffc0201740 <etext+0xee>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	19a010ef          	jal	ra,ffffffffc02015ba <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	4ea50513          	addi	a0,a0,1258 # ffffffffc0201918 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	1740106f          	j	ffffffffc02015ba <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	1500106f          	j	ffffffffc02015a0 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	1800106f          	j	ffffffffc02015d4 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	4ba50513          	addi	a0,a0,1210 # ffffffffc0201938 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	4c250513          	addi	a0,a0,1218 # ffffffffc0201950 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	4cc50513          	addi	a0,a0,1228 # ffffffffc0201968 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	4d650513          	addi	a0,a0,1238 # ffffffffc0201980 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	4e050513          	addi	a0,a0,1248 # ffffffffc0201998 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	4ea50513          	addi	a0,a0,1258 # ffffffffc02019b0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	4f450513          	addi	a0,a0,1268 # ffffffffc02019c8 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	4fe50513          	addi	a0,a0,1278 # ffffffffc02019e0 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	50850513          	addi	a0,a0,1288 # ffffffffc02019f8 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	51250513          	addi	a0,a0,1298 # ffffffffc0201a10 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	51c50513          	addi	a0,a0,1308 # ffffffffc0201a28 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	52650513          	addi	a0,a0,1318 # ffffffffc0201a40 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	53050513          	addi	a0,a0,1328 # ffffffffc0201a58 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	53a50513          	addi	a0,a0,1338 # ffffffffc0201a70 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	54450513          	addi	a0,a0,1348 # ffffffffc0201a88 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	54e50513          	addi	a0,a0,1358 # ffffffffc0201aa0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	55850513          	addi	a0,a0,1368 # ffffffffc0201ab8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	56250513          	addi	a0,a0,1378 # ffffffffc0201ad0 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	56c50513          	addi	a0,a0,1388 # ffffffffc0201ae8 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	57650513          	addi	a0,a0,1398 # ffffffffc0201b00 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	58050513          	addi	a0,a0,1408 # ffffffffc0201b18 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	58a50513          	addi	a0,a0,1418 # ffffffffc0201b30 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	59450513          	addi	a0,a0,1428 # ffffffffc0201b48 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	59e50513          	addi	a0,a0,1438 # ffffffffc0201b60 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	5a850513          	addi	a0,a0,1448 # ffffffffc0201b78 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	5b250513          	addi	a0,a0,1458 # ffffffffc0201b90 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	5bc50513          	addi	a0,a0,1468 # ffffffffc0201ba8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	5c650513          	addi	a0,a0,1478 # ffffffffc0201bc0 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	5d050513          	addi	a0,a0,1488 # ffffffffc0201bd8 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	5da50513          	addi	a0,a0,1498 # ffffffffc0201bf0 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	5e450513          	addi	a0,a0,1508 # ffffffffc0201c08 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	5ea50513          	addi	a0,a0,1514 # ffffffffc0201c20 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201c38 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201c50 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	5f650513          	addi	a0,a0,1526 # ffffffffc0201c68 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	5fe50513          	addi	a0,a0,1534 # ffffffffc0201c80 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	60250513          	addi	a0,a0,1538 # ffffffffc0201c98 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	6c870713          	addi	a4,a4,1736 # ffffffffc0201d78 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	64e50513          	addi	a0,a0,1614 # ffffffffc0201d10 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	62450513          	addi	a0,a0,1572 # ffffffffc0201cf0 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	5da50513          	addi	a0,a0,1498 # ffffffffc0201cb0 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	65050513          	addi	a0,a0,1616 # ffffffffc0201d30 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	64850513          	addi	a0,a0,1608 # ffffffffc0201d58 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	5b650513          	addi	a0,a0,1462 # ffffffffc0201cd0 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	61c50513          	addi	a0,a0,1564 # ffffffffc0201d48 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <buddy_system_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)

static void
buddy_system_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <buddy_system_nr_free_pages>:

static size_t
buddy_system_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <buddy_system_free_pages>:
{
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200822:	16058863          	beqz	a1,ffffffffc0200992 <buddy_system_free_pages+0x174>
    int i = get_power(n);
ffffffffc0200826:	0005879b          	sext.w	a5,a1
    while (tmp > 1)
ffffffffc020082a:	4705                	li	a4,1
    double tmp = n;
ffffffffc020082c:	d21587d3          	fcvt.d.wu	fa5,a1
    while (tmp > 1)
ffffffffc0200830:	12f77d63          	bgeu	a4,a5,ffffffffc020096a <buddy_system_free_pages+0x14c>
    unsigned i = 0;
ffffffffc0200834:	4781                	li	a5,0
ffffffffc0200836:	00002717          	auipc	a4,0x2
ffffffffc020083a:	ada73687          	fld	fa3,-1318(a4) # ffffffffc0202310 <error_string+0x38>
ffffffffc020083e:	00002717          	auipc	a4,0x2
ffffffffc0200842:	ada73707          	fld	fa4,-1318(a4) # ffffffffc0202318 <error_string+0x40>
        tmp /= 2;
ffffffffc0200846:	12d7f7d3          	fmul.d	fa5,fa5,fa3
        i++;
ffffffffc020084a:	2785                	addiw	a5,a5,1
    while (tmp > 1)
ffffffffc020084c:	a2f71753          	flt.d	a4,fa4,fa5
ffffffffc0200850:	fb7d                	bnez	a4,ffffffffc0200846 <buddy_system_free_pages+0x28>
    unsigned size = (1 << i);
ffffffffc0200852:	4705                	li	a4,1
ffffffffc0200854:	00f717bb          	sllw	a5,a4,a5
    for (; p != base + size; p++)
ffffffffc0200858:	02079713          	slli	a4,a5,0x20
ffffffffc020085c:	9301                	srli	a4,a4,0x20
ffffffffc020085e:	00271693          	slli	a3,a4,0x2
ffffffffc0200862:	96ba                	add	a3,a3,a4
ffffffffc0200864:	068e                	slli	a3,a3,0x3
ffffffffc0200866:	96aa                	add	a3,a3,a0
    unsigned size = (1 << i);
ffffffffc0200868:	0007861b          	sext.w	a2,a5
    for (; p != base + size; p++)
ffffffffc020086c:	00d50f63          	beq	a0,a3,ffffffffc020088a <buddy_system_free_pages+0x6c>
ffffffffc0200870:	87aa                	mv	a5,a0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200872:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200874:	8b05                	andi	a4,a4,1
ffffffffc0200876:	ef75                	bnez	a4,ffffffffc0200972 <buddy_system_free_pages+0x154>
ffffffffc0200878:	6798                	ld	a4,8(a5)
ffffffffc020087a:	8b09                	andi	a4,a4,2
ffffffffc020087c:	eb7d                	bnez	a4,ffffffffc0200972 <buddy_system_free_pages+0x154>



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020087e:	0007a023          	sw	zero,0(a5)
    for (; p != base + size; p++)
ffffffffc0200882:	02878793          	addi	a5,a5,40
ffffffffc0200886:	fed796e3          	bne	a5,a3,ffffffffc0200872 <buddy_system_free_pages+0x54>
    unsigned offset = base - base0;
ffffffffc020088a:	00006797          	auipc	a5,0x6
ffffffffc020088e:	bae7b783          	ld	a5,-1106(a5) # ffffffffc0206438 <base0>
ffffffffc0200892:	8d1d                	sub	a0,a0,a5
ffffffffc0200894:	40355793          	srai	a5,a0,0x3
ffffffffc0200898:	00002717          	auipc	a4,0x2
ffffffffc020089c:	a8873703          	ld	a4,-1400(a4) # ffffffffc0202320 <error_string+0x48>
ffffffffc02008a0:	02e78733          	mul	a4,a5,a4
    nr_free += size;
ffffffffc02008a4:	00005517          	auipc	a0,0x5
ffffffffc02008a8:	76c50513          	addi	a0,a0,1900 # ffffffffc0206010 <free_area>
    unsigned index = length / 2 + offset - 1;
ffffffffc02008ac:	00006817          	auipc	a6,0x6
ffffffffc02008b0:	b9c82803          	lw	a6,-1124(a6) # ffffffffc0206448 <length>
    nr_free += size;
ffffffffc02008b4:	4914                	lw	a3,16(a0)
    unsigned index = length / 2 + offset - 1;
ffffffffc02008b6:	01f8579b          	srliw	a5,a6,0x1f
ffffffffc02008ba:	010787bb          	addw	a5,a5,a6
ffffffffc02008be:	4017d79b          	sraiw	a5,a5,0x1
    nr_free += size;
ffffffffc02008c2:	9e35                	addw	a2,a2,a3
    unsigned index = length / 2 + offset - 1;
ffffffffc02008c4:	37fd                	addiw	a5,a5,-1
    nr_free += size;
ffffffffc02008c6:	c910                	sw	a2,16(a0)
    unsigned index = length / 2 + offset - 1;
ffffffffc02008c8:	9fb9                	addw	a5,a5,a4
    unsigned node_size = 1;
ffffffffc02008ca:	4705                	li	a4,1
    while (node_size < n)
ffffffffc02008cc:	02071693          	slli	a3,a4,0x20
ffffffffc02008d0:	9281                	srli	a3,a3,0x20
ffffffffc02008d2:	02b6f363          	bgeu	a3,a1,ffffffffc02008f8 <buddy_system_free_pages+0xda>
        if (index % 2 == 0)
ffffffffc02008d6:	0017f693          	andi	a3,a5,1
        node_size *= 2;
ffffffffc02008da:	0017171b          	slliw	a4,a4,0x1
        if (index % 2 == 0)
ffffffffc02008de:	ea81                	bnez	a3,ffffffffc02008ee <buddy_system_free_pages+0xd0>
            index = (index - 2) / 2;
ffffffffc02008e0:	37f9                	addiw	a5,a5,-2
ffffffffc02008e2:	0017d79b          	srliw	a5,a5,0x1
        if (index == 0)
ffffffffc02008e6:	f3fd                	bnez	a5,ffffffffc02008cc <buddy_system_free_pages+0xae>
}
ffffffffc02008e8:	60a2                	ld	ra,8(sp)
ffffffffc02008ea:	0141                	addi	sp,sp,16
ffffffffc02008ec:	8082                	ret
            index = (index - 1) / 2;
ffffffffc02008ee:	37fd                	addiw	a5,a5,-1
ffffffffc02008f0:	0017d79b          	srliw	a5,a5,0x1
        if (index == 0)
ffffffffc02008f4:	ffe1                	bnez	a5,ffffffffc02008cc <buddy_system_free_pages+0xae>
ffffffffc02008f6:	bfcd                	j	ffffffffc02008e8 <buddy_system_free_pages+0xca>
    buddy[index] = node_size;
ffffffffc02008f8:	02079613          	slli	a2,a5,0x20
ffffffffc02008fc:	00006517          	auipc	a0,0x6
ffffffffc0200900:	b4453503          	ld	a0,-1212(a0) # ffffffffc0206440 <buddy>
ffffffffc0200904:	01e65693          	srli	a3,a2,0x1e
ffffffffc0200908:	96aa                	add	a3,a3,a0
ffffffffc020090a:	c298                	sw	a4,0(a3)
    while (index)
ffffffffc020090c:	dff1                	beqz	a5,ffffffffc02008e8 <buddy_system_free_pages+0xca>
        if (index % 2 == 0)
ffffffffc020090e:	0017f693          	andi	a3,a5,1
ffffffffc0200912:	eaa1                	bnez	a3,ffffffffc0200962 <buddy_system_free_pages+0x144>
            index = (index - 2) / 2;
ffffffffc0200914:	37f9                	addiw	a5,a5,-2
ffffffffc0200916:	0017d79b          	srliw	a5,a5,0x1
        unsigned left = buddy[2 * index + 1];
ffffffffc020091a:	0017969b          	slliw	a3,a5,0x1
        unsigned right = buddy[2 * index + 2];
ffffffffc020091e:	0026861b          	addiw	a2,a3,2
ffffffffc0200922:	1602                	slli	a2,a2,0x20
        unsigned left = buddy[2 * index + 1];
ffffffffc0200924:	2685                	addiw	a3,a3,1
ffffffffc0200926:	02069593          	slli	a1,a3,0x20
        unsigned right = buddy[2 * index + 2];
ffffffffc020092a:	9201                	srli	a2,a2,0x20
        unsigned left = buddy[2 * index + 1];
ffffffffc020092c:	01e5d693          	srli	a3,a1,0x1e
        unsigned right = buddy[2 * index + 2];
ffffffffc0200930:	060a                	slli	a2,a2,0x2
        unsigned left = buddy[2 * index + 1];
ffffffffc0200932:	96aa                	add	a3,a3,a0
        unsigned right = buddy[2 * index + 2];
ffffffffc0200934:	962a                	add	a2,a2,a0
        unsigned left = buddy[2 * index + 1];
ffffffffc0200936:	428c                	lw	a1,0(a3)
        unsigned right = buddy[2 * index + 2];
ffffffffc0200938:	4210                	lw	a2,0(a2)
        node_size *= 2;
ffffffffc020093a:	0017181b          	slliw	a6,a4,0x1
            buddy[index] = node_size;
ffffffffc020093e:	02079713          	slli	a4,a5,0x20
ffffffffc0200942:	01e75693          	srli	a3,a4,0x1e
        if (left + right == node_size)
ffffffffc0200946:	00c588bb          	addw	a7,a1,a2
        node_size *= 2;
ffffffffc020094a:	0008071b          	sext.w	a4,a6
            buddy[index] = node_size;
ffffffffc020094e:	96aa                	add	a3,a3,a0
        if (left + right == node_size)
ffffffffc0200950:	00e88663          	beq	a7,a4,ffffffffc020095c <buddy_system_free_pages+0x13e>
            buddy[index] = (left > right) ? left : right;
ffffffffc0200954:	882e                	mv	a6,a1
ffffffffc0200956:	00c5f363          	bgeu	a1,a2,ffffffffc020095c <buddy_system_free_pages+0x13e>
ffffffffc020095a:	8832                	mv	a6,a2
ffffffffc020095c:	0106a023          	sw	a6,0(a3)
    while (index)
ffffffffc0200960:	b775                	j	ffffffffc020090c <buddy_system_free_pages+0xee>
            index = (index - 1) / 2;
ffffffffc0200962:	37fd                	addiw	a5,a5,-1
ffffffffc0200964:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200968:	bf4d                	j	ffffffffc020091a <buddy_system_free_pages+0xfc>
    while (tmp > 1)
ffffffffc020096a:	4605                	li	a2,1
ffffffffc020096c:	02850693          	addi	a3,a0,40
ffffffffc0200970:	b701                	j	ffffffffc0200870 <buddy_system_free_pages+0x52>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200972:	00001697          	auipc	a3,0x1
ffffffffc0200976:	47668693          	addi	a3,a3,1142 # ffffffffc0201de8 <commands+0x538>
ffffffffc020097a:	00001617          	auipc	a2,0x1
ffffffffc020097e:	43660613          	addi	a2,a2,1078 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200982:	0cc00593          	li	a1,204
ffffffffc0200986:	00001517          	auipc	a0,0x1
ffffffffc020098a:	44250513          	addi	a0,a0,1090 # ffffffffc0201dc8 <commands+0x518>
ffffffffc020098e:	a1fff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200992:	00001697          	auipc	a3,0x1
ffffffffc0200996:	41668693          	addi	a3,a3,1046 # ffffffffc0201da8 <commands+0x4f8>
ffffffffc020099a:	00001617          	auipc	a2,0x1
ffffffffc020099e:	41660613          	addi	a2,a2,1046 # ffffffffc0201db0 <commands+0x500>
ffffffffc02009a2:	0c500593          	li	a1,197
ffffffffc02009a6:	00001517          	auipc	a0,0x1
ffffffffc02009aa:	42250513          	addi	a0,a0,1058 # ffffffffc0201dc8 <commands+0x518>
ffffffffc02009ae:	9ffff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02009b2 <buddy_system_alloc_pages>:
    assert(n > 0);
ffffffffc02009b2:	1e050563          	beqz	a0,ffffffffc0200b9c <buddy_system_alloc_pages+0x1ea>
    if (n > nr_free)
ffffffffc02009b6:	00005897          	auipc	a7,0x5
ffffffffc02009ba:	65a88893          	addi	a7,a7,1626 # ffffffffc0206010 <free_area>
ffffffffc02009be:	0108e783          	lwu	a5,16(a7)
ffffffffc02009c2:	85aa                	mv	a1,a0
ffffffffc02009c4:	1ca7e663          	bltu	a5,a0,ffffffffc0200b90 <buddy_system_alloc_pages+0x1de>
    if (n <= 1)
ffffffffc02009c8:	4785                	li	a5,1
ffffffffc02009ca:	00f50863          	beq	a0,a5,ffffffffc02009da <buddy_system_alloc_pages+0x28>
    return !(x & (x - 1));
ffffffffc02009ce:	fff5079b          	addiw	a5,a0,-1
ffffffffc02009d2:	8fe9                	and	a5,a5,a0
    else if (!is_power_of_2(n))
ffffffffc02009d4:	2781                	sext.w	a5,a5
ffffffffc02009d6:	18079163          	bnez	a5,ffffffffc0200b58 <buddy_system_alloc_pages+0x1a6>
    if (buddy[index] < n)
ffffffffc02009da:	00006617          	auipc	a2,0x6
ffffffffc02009de:	a6663603          	ld	a2,-1434(a2) # ffffffffc0206440 <buddy>
ffffffffc02009e2:	00066783          	lwu	a5,0(a2)
ffffffffc02009e6:	1ab7e563          	bltu	a5,a1,ffffffffc0200b90 <buddy_system_alloc_pages+0x1de>
    for (node_size = length / 2; node_size != n; node_size /= 2)
ffffffffc02009ea:	00006817          	auipc	a6,0x6
ffffffffc02009ee:	a5e80813          	addi	a6,a6,-1442 # ffffffffc0206448 <length>
ffffffffc02009f2:	00082703          	lw	a4,0(a6)
ffffffffc02009f6:	01f7579b          	srliw	a5,a4,0x1f
ffffffffc02009fa:	9fb9                	addw	a5,a5,a4
ffffffffc02009fc:	4017d79b          	sraiw	a5,a5,0x1
ffffffffc0200a00:	02079693          	slli	a3,a5,0x20
ffffffffc0200a04:	9281                	srli	a3,a3,0x20
ffffffffc0200a06:	0007871b          	sext.w	a4,a5
ffffffffc0200a0a:	0ad58963          	beq	a1,a3,ffffffffc0200abc <buddy_system_alloc_pages+0x10a>
    unsigned index = 0;
ffffffffc0200a0e:	4781                	li	a5,0
        if (buddy[2 * index + 1] >= n)
ffffffffc0200a10:	0017951b          	slliw	a0,a5,0x1
ffffffffc0200a14:	0015079b          	addiw	a5,a0,1
ffffffffc0200a18:	02079313          	slli	t1,a5,0x20
ffffffffc0200a1c:	01e35693          	srli	a3,t1,0x1e
ffffffffc0200a20:	96b2                	add	a3,a3,a2
ffffffffc0200a22:	0006e683          	lwu	a3,0(a3)
ffffffffc0200a26:	00b6f463          	bgeu	a3,a1,ffffffffc0200a2e <buddy_system_alloc_pages+0x7c>
            index = 2 * index + 2;
ffffffffc0200a2a:	0025079b          	addiw	a5,a0,2
    for (node_size = length / 2; node_size != n; node_size /= 2)
ffffffffc0200a2e:	0017571b          	srliw	a4,a4,0x1
ffffffffc0200a32:	02071693          	slli	a3,a4,0x20
ffffffffc0200a36:	9281                	srli	a3,a3,0x20
ffffffffc0200a38:	fcb69ce3          	bne	a3,a1,ffffffffc0200a10 <buddy_system_alloc_pages+0x5e>
    offset = (index + 1) * node_size - length / 2;
ffffffffc0200a3c:	00178e1b          	addiw	t3,a5,1
ffffffffc0200a40:	02ee073b          	mulw	a4,t3,a4
    buddy[index] = 0;
ffffffffc0200a44:	02079513          	slli	a0,a5,0x20
ffffffffc0200a48:	01e55693          	srli	a3,a0,0x1e
ffffffffc0200a4c:	96b2                	add	a3,a3,a2
ffffffffc0200a4e:	0006a023          	sw	zero,0(a3)
    offset = (index + 1) * node_size - length / 2;
ffffffffc0200a52:	00082683          	lw	a3,0(a6)
ffffffffc0200a56:	01f6de1b          	srliw	t3,a3,0x1f
ffffffffc0200a5a:	00de0e3b          	addw	t3,t3,a3
ffffffffc0200a5e:	401e5e1b          	sraiw	t3,t3,0x1
ffffffffc0200a62:	41c70e3b          	subw	t3,a4,t3
    while (index > 0)
ffffffffc0200a66:	e7a1                	bnez	a5,ffffffffc0200aae <buddy_system_alloc_pages+0xfc>
ffffffffc0200a68:	a0b5                	j	ffffffffc0200ad4 <buddy_system_alloc_pages+0x122>
            index = (index - 2) / 2;
ffffffffc0200a6a:	37f9                	addiw	a5,a5,-2
ffffffffc0200a6c:	0017d79b          	srliw	a5,a5,0x1
        buddy[index] = (buddy[2 * index + 1] > buddy[2 * index + 2]) ? buddy[2 * index + 1] : buddy[2 * index + 2];
ffffffffc0200a70:	0017871b          	addiw	a4,a5,1
ffffffffc0200a74:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200a78:	fff7069b          	addiw	a3,a4,-1
ffffffffc0200a7c:	1702                	slli	a4,a4,0x20
ffffffffc0200a7e:	02069513          	slli	a0,a3,0x20
ffffffffc0200a82:	9301                	srli	a4,a4,0x20
ffffffffc0200a84:	01e55693          	srli	a3,a0,0x1e
ffffffffc0200a88:	070a                	slli	a4,a4,0x2
ffffffffc0200a8a:	9732                	add	a4,a4,a2
ffffffffc0200a8c:	96b2                	add	a3,a3,a2
ffffffffc0200a8e:	4308                	lw	a0,0(a4)
ffffffffc0200a90:	4294                	lw	a3,0(a3)
ffffffffc0200a92:	02079813          	slli	a6,a5,0x20
ffffffffc0200a96:	01e85713          	srli	a4,a6,0x1e
ffffffffc0200a9a:	0006831b          	sext.w	t1,a3
ffffffffc0200a9e:	0005081b          	sext.w	a6,a0
ffffffffc0200aa2:	9732                	add	a4,a4,a2
ffffffffc0200aa4:	01037363          	bgeu	t1,a6,ffffffffc0200aaa <buddy_system_alloc_pages+0xf8>
ffffffffc0200aa8:	86aa                	mv	a3,a0
ffffffffc0200aaa:	c314                	sw	a3,0(a4)
    while (index > 0)
ffffffffc0200aac:	c785                	beqz	a5,ffffffffc0200ad4 <buddy_system_alloc_pages+0x122>
        if (index % 2 == 0)
ffffffffc0200aae:	0017f693          	andi	a3,a5,1
ffffffffc0200ab2:	dec5                	beqz	a3,ffffffffc0200a6a <buddy_system_alloc_pages+0xb8>
            index = (index - 1) / 2;
ffffffffc0200ab4:	37fd                	addiw	a5,a5,-1
ffffffffc0200ab6:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200aba:	bf5d                	j	ffffffffc0200a70 <buddy_system_alloc_pages+0xbe>
    buddy[index] = 0;
ffffffffc0200abc:	00062023          	sw	zero,0(a2)
    offset = (index + 1) * node_size - length / 2;
ffffffffc0200ac0:	00082703          	lw	a4,0(a6)
ffffffffc0200ac4:	01f75e1b          	srliw	t3,a4,0x1f
ffffffffc0200ac8:	00ee0e3b          	addw	t3,t3,a4
ffffffffc0200acc:	401e5e1b          	sraiw	t3,t3,0x1
ffffffffc0200ad0:	41c78e3b          	subw	t3,a5,t3
    page = base0 + offset;
ffffffffc0200ad4:	020e1793          	slli	a5,t3,0x20
ffffffffc0200ad8:	9381                	srli	a5,a5,0x20
ffffffffc0200ada:	00279513          	slli	a0,a5,0x2
ffffffffc0200ade:	97aa                	add	a5,a5,a0
ffffffffc0200ae0:	078e                	slli	a5,a5,0x3
ffffffffc0200ae2:	00006517          	auipc	a0,0x6
ffffffffc0200ae6:	95653503          	ld	a0,-1706(a0) # ffffffffc0206438 <base0>
    page->property = n;
ffffffffc0200aea:	0005871b          	sext.w	a4,a1
    page = base0 + offset;
ffffffffc0200aee:	953e                	add	a0,a0,a5
    page->property = n;
ffffffffc0200af0:	c918                	sw	a4,16(a0)
    while (tmp > 1)
ffffffffc0200af2:	4785                	li	a5,1
    double tmp = n;
ffffffffc0200af4:	d21707d3          	fcvt.d.wu	fa5,a4
    while (tmp > 1)
ffffffffc0200af8:	08b7fe63          	bgeu	a5,a1,ffffffffc0200b94 <buddy_system_alloc_pages+0x1e2>
    unsigned i = 0;
ffffffffc0200afc:	4781                	li	a5,0
ffffffffc0200afe:	00002717          	auipc	a4,0x2
ffffffffc0200b02:	81273687          	fld	fa3,-2030(a4) # ffffffffc0202310 <error_string+0x38>
ffffffffc0200b06:	00002717          	auipc	a4,0x2
ffffffffc0200b0a:	81273707          	fld	fa4,-2030(a4) # ffffffffc0202318 <error_string+0x40>
        tmp /= 2;
ffffffffc0200b0e:	12d7f7d3          	fmul.d	fa5,fa5,fa3
        i++;
ffffffffc0200b12:	2785                	addiw	a5,a5,1
    while (tmp > 1)
ffffffffc0200b14:	a2f71753          	flt.d	a4,fa4,fa5
ffffffffc0200b18:	fb7d                	bnez	a4,ffffffffc0200b0e <buddy_system_alloc_pages+0x15c>
    unsigned size = (1 << i);
ffffffffc0200b1a:	4705                	li	a4,1
ffffffffc0200b1c:	00f717bb          	sllw	a5,a4,a5
    for (struct Page *p = page; p != page + size; p++)
ffffffffc0200b20:	02079693          	slli	a3,a5,0x20
ffffffffc0200b24:	9281                	srli	a3,a3,0x20
ffffffffc0200b26:	00269713          	slli	a4,a3,0x2
ffffffffc0200b2a:	9736                	add	a4,a4,a3
ffffffffc0200b2c:	070e                	slli	a4,a4,0x3
    nr_free -= size;
ffffffffc0200b2e:	0108a683          	lw	a3,16(a7)
    for (struct Page *p = page; p != page + size; p++)
ffffffffc0200b32:	972a                	add	a4,a4,a0
    nr_free -= size;
ffffffffc0200b34:	40f687bb          	subw	a5,a3,a5
ffffffffc0200b38:	00f8a823          	sw	a5,16(a7)
    for (struct Page *p = page; p != page + size; p++)
ffffffffc0200b3c:	00e50d63          	beq	a0,a4,ffffffffc0200b56 <buddy_system_alloc_pages+0x1a4>
ffffffffc0200b40:	87aa                	mv	a5,a0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b42:	56f5                	li	a3,-3
ffffffffc0200b44:	00878613          	addi	a2,a5,8
ffffffffc0200b48:	60d6302f          	amoand.d	zero,a3,(a2)
ffffffffc0200b4c:	02878793          	addi	a5,a5,40
ffffffffc0200b50:	fee79ae3          	bne	a5,a4,ffffffffc0200b44 <buddy_system_alloc_pages+0x192>
ffffffffc0200b54:	8082                	ret
}
ffffffffc0200b56:	8082                	ret
    double tmp = n;
ffffffffc0200b58:	d21507d3          	fcvt.d.wu	fa5,a0
    unsigned i = 0;
ffffffffc0200b5c:	4781                	li	a5,0
ffffffffc0200b5e:	00001717          	auipc	a4,0x1
ffffffffc0200b62:	7b273687          	fld	fa3,1970(a4) # ffffffffc0202310 <error_string+0x38>
ffffffffc0200b66:	00001717          	auipc	a4,0x1
ffffffffc0200b6a:	7b273707          	fld	fa4,1970(a4) # ffffffffc0202318 <error_string+0x40>
        tmp /= 2;
ffffffffc0200b6e:	12d7f7d3          	fmul.d	fa5,fa5,fa3
        i++;
ffffffffc0200b72:	2785                	addiw	a5,a5,1
    while (tmp > 1)
ffffffffc0200b74:	a2f71753          	flt.d	a4,fa4,fa5
ffffffffc0200b78:	fb7d                	bnez	a4,ffffffffc0200b6e <buddy_system_alloc_pages+0x1bc>
        n = (1 << pw);
ffffffffc0200b7a:	4585                	li	a1,1
    if (buddy[index] < n)
ffffffffc0200b7c:	00006617          	auipc	a2,0x6
ffffffffc0200b80:	8c463603          	ld	a2,-1852(a2) # ffffffffc0206440 <buddy>
        n = (1 << pw);
ffffffffc0200b84:	00f595bb          	sllw	a1,a1,a5
    if (buddy[index] < n)
ffffffffc0200b88:	00066783          	lwu	a5,0(a2)
ffffffffc0200b8c:	e4b7ffe3          	bgeu	a5,a1,ffffffffc02009ea <buddy_system_alloc_pages+0x38>
        return NULL;
ffffffffc0200b90:	4501                	li	a0,0
ffffffffc0200b92:	8082                	ret
    while (tmp > 1)
ffffffffc0200b94:	4785                	li	a5,1
ffffffffc0200b96:	02800713          	li	a4,40
ffffffffc0200b9a:	bf51                	j	ffffffffc0200b2e <buddy_system_alloc_pages+0x17c>
{
ffffffffc0200b9c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200b9e:	00001697          	auipc	a3,0x1
ffffffffc0200ba2:	20a68693          	addi	a3,a3,522 # ffffffffc0201da8 <commands+0x4f8>
ffffffffc0200ba6:	00001617          	auipc	a2,0x1
ffffffffc0200baa:	20a60613          	addi	a2,a2,522 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200bae:	08400593          	li	a1,132
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	21650513          	addi	a0,a0,534 # ffffffffc0201dc8 <commands+0x518>
{
ffffffffc0200bba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200bbc:	ff0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bc0 <buddy_check>:
// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_check(void)
{
    cprintf("%sbuddy check%s\n","====", "====");
ffffffffc0200bc0:	00001617          	auipc	a2,0x1
ffffffffc0200bc4:	25060613          	addi	a2,a2,592 # ffffffffc0201e10 <commands+0x560>
{
ffffffffc0200bc8:	1101                	addi	sp,sp,-32
    cprintf("%sbuddy check%s\n","====", "====");
ffffffffc0200bca:	85b2                	mv	a1,a2
ffffffffc0200bcc:	00001517          	auipc	a0,0x1
ffffffffc0200bd0:	24c50513          	addi	a0,a0,588 # ffffffffc0201e18 <commands+0x568>
{
ffffffffc0200bd4:	ec06                	sd	ra,24(sp)
ffffffffc0200bd6:	e822                	sd	s0,16(sp)
ffffffffc0200bd8:	e426                	sd	s1,8(sp)
ffffffffc0200bda:	e04a                	sd	s2,0(sp)
    cprintf("%sbuddy check%s\n","====", "====");
ffffffffc0200bdc:	cd6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    assert((p0 = alloc_page()) != NULL);
ffffffffc0200be0:	4505                	li	a0,1
ffffffffc0200be2:	30a000ef          	jal	ra,ffffffffc0200eec <alloc_pages>
ffffffffc0200be6:	1a050063          	beqz	a0,ffffffffc0200d86 <buddy_check+0x1c6>
ffffffffc0200bea:	842a                	mv	s0,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bec:	4505                	li	a0,1
ffffffffc0200bee:	2fe000ef          	jal	ra,ffffffffc0200eec <alloc_pages>
ffffffffc0200bf2:	84aa                	mv	s1,a0
ffffffffc0200bf4:	16050963          	beqz	a0,ffffffffc0200d66 <buddy_check+0x1a6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bf8:	4505                	li	a0,1
ffffffffc0200bfa:	2f2000ef          	jal	ra,ffffffffc0200eec <alloc_pages>
ffffffffc0200bfe:	892a                	mv	s2,a0
ffffffffc0200c00:	14050363          	beqz	a0,ffffffffc0200d46 <buddy_check+0x186>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c04:	0a940163          	beq	s0,s1,ffffffffc0200ca6 <buddy_check+0xe6>
ffffffffc0200c08:	08a40f63          	beq	s0,a0,ffffffffc0200ca6 <buddy_check+0xe6>
ffffffffc0200c0c:	08a48d63          	beq	s1,a0,ffffffffc0200ca6 <buddy_check+0xe6>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c10:	401c                	lw	a5,0(s0)
ffffffffc0200c12:	ebd5                	bnez	a5,ffffffffc0200cc6 <buddy_check+0x106>
ffffffffc0200c14:	409c                	lw	a5,0(s1)
ffffffffc0200c16:	ebc5                	bnez	a5,ffffffffc0200cc6 <buddy_check+0x106>
ffffffffc0200c18:	411c                	lw	a5,0(a0)
ffffffffc0200c1a:	e7d5                	bnez	a5,ffffffffc0200cc6 <buddy_check+0x106>

    free_page(p0);
ffffffffc0200c1c:	8522                	mv	a0,s0
ffffffffc0200c1e:	4585                	li	a1,1
ffffffffc0200c20:	30a000ef          	jal	ra,ffffffffc0200f2a <free_pages>
    free_page(p1);
ffffffffc0200c24:	8526                	mv	a0,s1
ffffffffc0200c26:	4585                	li	a1,1
ffffffffc0200c28:	302000ef          	jal	ra,ffffffffc0200f2a <free_pages>
    free_page(p2);
ffffffffc0200c2c:	4585                	li	a1,1
ffffffffc0200c2e:	854a                	mv	a0,s2
ffffffffc0200c30:	2fa000ef          	jal	ra,ffffffffc0200f2a <free_pages>

    p0 = alloc_pages(34);
ffffffffc0200c34:	02200513          	li	a0,34
ffffffffc0200c38:	2b4000ef          	jal	ra,ffffffffc0200eec <alloc_pages>
ffffffffc0200c3c:	842a                	mv	s0,a0
    p1 = alloc_pages(65);
ffffffffc0200c3e:	04100513          	li	a0,65
ffffffffc0200c42:	2aa000ef          	jal	ra,ffffffffc0200eec <alloc_pages>
ffffffffc0200c46:	892a                	mv	s2,a0
    p2 = alloc_pages(24);
ffffffffc0200c48:	4561                	li	a0,24
ffffffffc0200c4a:	2a2000ef          	jal	ra,ffffffffc0200eec <alloc_pages>


    // 检验p1和p0是否相邻，并且分配内存是否是大于分配内存的2的幂次
    assert(p1 == p0 + 128);
ffffffffc0200c4e:	6785                	lui	a5,0x1
ffffffffc0200c50:	40078793          	addi	a5,a5,1024 # 1400 <kern_entry-0xffffffffc01fec00>
ffffffffc0200c54:	97a2                	add	a5,a5,s0
    p2 = alloc_pages(24);
ffffffffc0200c56:	84aa                	mv	s1,a0
    assert(p1 == p0 + 128);
ffffffffc0200c58:	08f91763          	bne	s2,a5,ffffffffc0200ce6 <buddy_check+0x126>
    // 检验p2和p0是否相邻,并且分配内存是否是大于分配内存的2的幂次
    assert(p2 == p0 + 64);
ffffffffc0200c5c:	6785                	lui	a5,0x1
ffffffffc0200c5e:	a0078793          	addi	a5,a5,-1536 # a00 <kern_entry-0xffffffffc01ff600>
ffffffffc0200c62:	97a2                	add	a5,a5,s0
ffffffffc0200c64:	0cf51163          	bne	a0,a5,ffffffffc0200d26 <buddy_check+0x166>

    // 检验p0、p2释放后分配p2是否使用了p0的空间
    free_page(p0);
ffffffffc0200c68:	4585                	li	a1,1
ffffffffc0200c6a:	8522                	mv	a0,s0
ffffffffc0200c6c:	2be000ef          	jal	ra,ffffffffc0200f2a <free_pages>
    free_page(p2);
ffffffffc0200c70:	8526                	mv	a0,s1
ffffffffc0200c72:	4585                	li	a1,1
ffffffffc0200c74:	2b6000ef          	jal	ra,ffffffffc0200f2a <free_pages>
    p2 = alloc_pages(34);
ffffffffc0200c78:	02200513          	li	a0,34
ffffffffc0200c7c:	270000ef          	jal	ra,ffffffffc0200eec <alloc_pages>
    assert(p2 == p0);
ffffffffc0200c80:	08a41363          	bne	s0,a0,ffffffffc0200d06 <buddy_check+0x146>

    // 检验释放后内存的合并是否正确
    free_page(p2);
ffffffffc0200c84:	4585                	li	a1,1
ffffffffc0200c86:	2a4000ef          	jal	ra,ffffffffc0200f2a <free_pages>
    p2 = alloc_pages(128);
ffffffffc0200c8a:	08000513          	li	a0,128
ffffffffc0200c8e:	25e000ef          	jal	ra,ffffffffc0200eec <alloc_pages>
    assert(p0 == p2);
ffffffffc0200c92:	10a41a63          	bne	s0,a0,ffffffffc0200da6 <buddy_check+0x1e6>

    free_page(p1);
}
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	60e2                	ld	ra,24(sp)
ffffffffc0200c9a:	64a2                	ld	s1,8(sp)
    free_page(p1);
ffffffffc0200c9c:	854a                	mv	a0,s2
}
ffffffffc0200c9e:	6902                	ld	s2,0(sp)
    free_page(p1);
ffffffffc0200ca0:	4585                	li	a1,1
}
ffffffffc0200ca2:	6105                	addi	sp,sp,32
    free_page(p1);
ffffffffc0200ca4:	a459                	j	ffffffffc0200f2a <free_pages>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ca6:	00001697          	auipc	a3,0x1
ffffffffc0200caa:	1ea68693          	addi	a3,a3,490 # ffffffffc0201e90 <commands+0x5e0>
ffffffffc0200cae:	00001617          	auipc	a2,0x1
ffffffffc0200cb2:	10260613          	addi	a2,a2,258 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200cb6:	10f00593          	li	a1,271
ffffffffc0200cba:	00001517          	auipc	a0,0x1
ffffffffc0200cbe:	10e50513          	addi	a0,a0,270 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200cc2:	eeaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200cc6:	00001697          	auipc	a3,0x1
ffffffffc0200cca:	1f268693          	addi	a3,a3,498 # ffffffffc0201eb8 <commands+0x608>
ffffffffc0200cce:	00001617          	auipc	a2,0x1
ffffffffc0200cd2:	0e260613          	addi	a2,a2,226 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200cd6:	11000593          	li	a1,272
ffffffffc0200cda:	00001517          	auipc	a0,0x1
ffffffffc0200cde:	0ee50513          	addi	a0,a0,238 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200ce2:	ecaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 == p0 + 128);
ffffffffc0200ce6:	00001697          	auipc	a3,0x1
ffffffffc0200cea:	21268693          	addi	a3,a3,530 # ffffffffc0201ef8 <commands+0x648>
ffffffffc0200cee:	00001617          	auipc	a2,0x1
ffffffffc0200cf2:	0c260613          	addi	a2,a2,194 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200cf6:	11c00593          	li	a1,284
ffffffffc0200cfa:	00001517          	auipc	a0,0x1
ffffffffc0200cfe:	0ce50513          	addi	a0,a0,206 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200d02:	eaaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 == p0);
ffffffffc0200d06:	00001697          	auipc	a3,0x1
ffffffffc0200d0a:	21268693          	addi	a3,a3,530 # ffffffffc0201f18 <commands+0x668>
ffffffffc0200d0e:	00001617          	auipc	a2,0x1
ffffffffc0200d12:	0a260613          	addi	a2,a2,162 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200d16:	12400593          	li	a1,292
ffffffffc0200d1a:	00001517          	auipc	a0,0x1
ffffffffc0200d1e:	0ae50513          	addi	a0,a0,174 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200d22:	e8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 == p0 + 64);
ffffffffc0200d26:	00001697          	auipc	a3,0x1
ffffffffc0200d2a:	1e268693          	addi	a3,a3,482 # ffffffffc0201f08 <commands+0x658>
ffffffffc0200d2e:	00001617          	auipc	a2,0x1
ffffffffc0200d32:	08260613          	addi	a2,a2,130 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200d36:	11e00593          	li	a1,286
ffffffffc0200d3a:	00001517          	auipc	a0,0x1
ffffffffc0200d3e:	08e50513          	addi	a0,a0,142 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200d42:	e6aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d46:	00001697          	auipc	a3,0x1
ffffffffc0200d4a:	12a68693          	addi	a3,a3,298 # ffffffffc0201e70 <commands+0x5c0>
ffffffffc0200d4e:	00001617          	auipc	a2,0x1
ffffffffc0200d52:	06260613          	addi	a2,a2,98 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200d56:	10d00593          	li	a1,269
ffffffffc0200d5a:	00001517          	auipc	a0,0x1
ffffffffc0200d5e:	06e50513          	addi	a0,a0,110 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200d62:	e4aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d66:	00001697          	auipc	a3,0x1
ffffffffc0200d6a:	0ea68693          	addi	a3,a3,234 # ffffffffc0201e50 <commands+0x5a0>
ffffffffc0200d6e:	00001617          	auipc	a2,0x1
ffffffffc0200d72:	04260613          	addi	a2,a2,66 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200d76:	10c00593          	li	a1,268
ffffffffc0200d7a:	00001517          	auipc	a0,0x1
ffffffffc0200d7e:	04e50513          	addi	a0,a0,78 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200d82:	e2aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d86:	00001697          	auipc	a3,0x1
ffffffffc0200d8a:	0aa68693          	addi	a3,a3,170 # ffffffffc0201e30 <commands+0x580>
ffffffffc0200d8e:	00001617          	auipc	a2,0x1
ffffffffc0200d92:	02260613          	addi	a2,a2,34 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200d96:	10b00593          	li	a1,267
ffffffffc0200d9a:	00001517          	auipc	a0,0x1
ffffffffc0200d9e:	02e50513          	addi	a0,a0,46 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200da2:	e0aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 == p2);
ffffffffc0200da6:	00001697          	auipc	a3,0x1
ffffffffc0200daa:	18268693          	addi	a3,a3,386 # ffffffffc0201f28 <commands+0x678>
ffffffffc0200dae:	00001617          	auipc	a2,0x1
ffffffffc0200db2:	00260613          	addi	a2,a2,2 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200db6:	12900593          	li	a1,297
ffffffffc0200dba:	00001517          	auipc	a0,0x1
ffffffffc0200dbe:	00e50513          	addi	a0,a0,14 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200dc2:	deaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200dc6 <buddy_system_init_memmap>:
{
ffffffffc0200dc6:	1141                	addi	sp,sp,-16
ffffffffc0200dc8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200dca:	10058163          	beqz	a1,ffffffffc0200ecc <buddy_system_init_memmap+0x106>
    for (; p != base + n; p++)
ffffffffc0200dce:	00259693          	slli	a3,a1,0x2
ffffffffc0200dd2:	96ae                	add	a3,a3,a1
ffffffffc0200dd4:	068e                	slli	a3,a3,0x3
ffffffffc0200dd6:	96aa                	add	a3,a3,a0
ffffffffc0200dd8:	87aa                	mv	a5,a0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200dda:	4609                	li	a2,2
ffffffffc0200ddc:	02d50363          	beq	a0,a3,ffffffffc0200e02 <buddy_system_init_memmap+0x3c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200de0:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200de2:	8b05                	andi	a4,a4,1
ffffffffc0200de4:	c761                	beqz	a4,ffffffffc0200eac <buddy_system_init_memmap+0xe6>
        p->flags = p->property = 0;
ffffffffc0200de6:	0007a823          	sw	zero,16(a5)
ffffffffc0200dea:	0007b423          	sd	zero,8(a5)
ffffffffc0200dee:	0007a023          	sw	zero,0(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200df2:	00878713          	addi	a4,a5,8
ffffffffc0200df6:	40c7302f          	amoor.d	zero,a2,(a4)
    for (; p != base + n; p++)
ffffffffc0200dfa:	02878793          	addi	a5,a5,40
ffffffffc0200dfe:	fed791e3          	bne	a5,a3,ffffffffc0200de0 <buddy_system_init_memmap+0x1a>
    base->property = n;
ffffffffc0200e02:	2581                	sext.w	a1,a1
ffffffffc0200e04:	c90c                	sw	a1,16(a0)
ffffffffc0200e06:	4689                	li	a3,2
ffffffffc0200e08:	00850793          	addi	a5,a0,8
ffffffffc0200e0c:	40d7b02f          	amoor.d	zero,a3,(a5)
    nr_free += n;
ffffffffc0200e10:	00005717          	auipc	a4,0x5
ffffffffc0200e14:	20070713          	addi	a4,a4,512 # ffffffffc0206010 <free_area>
ffffffffc0200e18:	4b1c                	lw	a5,16(a4)
    base0 = base;
ffffffffc0200e1a:	00005617          	auipc	a2,0x5
ffffffffc0200e1e:	60a63f23          	sd	a0,1566(a2) # ffffffffc0206438 <base0>
    while (tmp > 1)
ffffffffc0200e22:	4605                	li	a2,1
    nr_free += n;
ffffffffc0200e24:	9fad                	addw	a5,a5,a1
ffffffffc0200e26:	cb1c                	sw	a5,16(a4)
    double tmp = n;
ffffffffc0200e28:	d21587d3          	fcvt.d.wu	fa5,a1
    while (tmp > 1)
ffffffffc0200e2c:	06b67363          	bgeu	a2,a1,ffffffffc0200e92 <buddy_system_init_memmap+0xcc>
    unsigned i = 0;
ffffffffc0200e30:	4781                	li	a5,0
ffffffffc0200e32:	00001717          	auipc	a4,0x1
ffffffffc0200e36:	4de73687          	fld	fa3,1246(a4) # ffffffffc0202310 <error_string+0x38>
ffffffffc0200e3a:	00001717          	auipc	a4,0x1
ffffffffc0200e3e:	4de73707          	fld	fa4,1246(a4) # ffffffffc0202318 <error_string+0x40>
        tmp /= 2;
ffffffffc0200e42:	12d7f7d3          	fmul.d	fa5,fa5,fa3
        i++;
ffffffffc0200e46:	2785                	addiw	a5,a5,1
    while (tmp > 1)
ffffffffc0200e48:	a2f71753          	flt.d	a4,fa4,fa5
ffffffffc0200e4c:	fb7d                	bnez	a4,ffffffffc0200e42 <buddy_system_init_memmap+0x7c>
    length = 2 * (1 << (i));
ffffffffc0200e4e:	4709                	li	a4,2
ffffffffc0200e50:	00f7163b          	sllw	a2,a4,a5
    buddy = (unsigned *)(base + length);
ffffffffc0200e54:	00261713          	slli	a4,a2,0x2
ffffffffc0200e58:	9732                	add	a4,a4,a2
ffffffffc0200e5a:	070e                	slli	a4,a4,0x3
    length = 2 * (1 << (i));
ffffffffc0200e5c:	00005597          	auipc	a1,0x5
ffffffffc0200e60:	5ec58593          	addi	a1,a1,1516 # ffffffffc0206448 <length>
    buddy = (unsigned *)(base + length);
ffffffffc0200e64:	972a                	add	a4,a4,a0
    length = 2 * (1 << (i));
ffffffffc0200e66:	c190                	sw	a2,0(a1)
    buddy = (unsigned *)(base + length);
ffffffffc0200e68:	00005797          	auipc	a5,0x5
ffffffffc0200e6c:	5ce7bc23          	sd	a4,1496(a5) # ffffffffc0206440 <buddy>
    for (i = 0; i < length; ++i)
ffffffffc0200e70:	00c05e63          	blez	a2,ffffffffc0200e8c <buddy_system_init_memmap+0xc6>
    unsigned node_size = length;
ffffffffc0200e74:	4781                	li	a5,0
        if (is_power_of_2(i + 1))
ffffffffc0200e76:	86be                	mv	a3,a5
ffffffffc0200e78:	2785                	addiw	a5,a5,1
ffffffffc0200e7a:	8efd                	and	a3,a3,a5
ffffffffc0200e7c:	e299                	bnez	a3,ffffffffc0200e82 <buddy_system_init_memmap+0xbc>
            node_size /= 2;
ffffffffc0200e7e:	0016561b          	srliw	a2,a2,0x1
        buddy[i] = node_size;
ffffffffc0200e82:	c310                	sw	a2,0(a4)
    for (i = 0; i < length; ++i)
ffffffffc0200e84:	4194                	lw	a3,0(a1)
ffffffffc0200e86:	0711                	addi	a4,a4,4
ffffffffc0200e88:	fed7c7e3          	blt	a5,a3,ffffffffc0200e76 <buddy_system_init_memmap+0xb0>
}
ffffffffc0200e8c:	60a2                	ld	ra,8(sp)
ffffffffc0200e8e:	0141                	addi	sp,sp,16
ffffffffc0200e90:	8082                	ret
    length = 2 * (1 << (i));
ffffffffc0200e92:	00005597          	auipc	a1,0x5
ffffffffc0200e96:	5b658593          	addi	a1,a1,1462 # ffffffffc0206448 <length>
    buddy = (unsigned *)(base + length);
ffffffffc0200e9a:	05050713          	addi	a4,a0,80
    length = 2 * (1 << (i));
ffffffffc0200e9e:	c194                	sw	a3,0(a1)
    buddy = (unsigned *)(base + length);
ffffffffc0200ea0:	00005797          	auipc	a5,0x5
ffffffffc0200ea4:	5ae7b023          	sd	a4,1440(a5) # ffffffffc0206440 <buddy>
    unsigned node_size = length;
ffffffffc0200ea8:	4609                	li	a2,2
ffffffffc0200eaa:	b7e9                	j	ffffffffc0200e74 <buddy_system_init_memmap+0xae>
        assert(PageReserved(p));
ffffffffc0200eac:	00001697          	auipc	a3,0x1
ffffffffc0200eb0:	08c68693          	addi	a3,a3,140 # ffffffffc0201f38 <commands+0x688>
ffffffffc0200eb4:	00001617          	auipc	a2,0x1
ffffffffc0200eb8:	efc60613          	addi	a2,a2,-260 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200ebc:	06200593          	li	a1,98
ffffffffc0200ec0:	00001517          	auipc	a0,0x1
ffffffffc0200ec4:	f0850513          	addi	a0,a0,-248 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200ec8:	ce4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200ecc:	00001697          	auipc	a3,0x1
ffffffffc0200ed0:	edc68693          	addi	a3,a3,-292 # ffffffffc0201da8 <commands+0x4f8>
ffffffffc0200ed4:	00001617          	auipc	a2,0x1
ffffffffc0200ed8:	edc60613          	addi	a2,a2,-292 # ffffffffc0201db0 <commands+0x500>
ffffffffc0200edc:	05e00593          	li	a1,94
ffffffffc0200ee0:	00001517          	auipc	a0,0x1
ffffffffc0200ee4:	ee850513          	addi	a0,a0,-280 # ffffffffc0201dc8 <commands+0x518>
ffffffffc0200ee8:	cc4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200eec <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200eec:	100027f3          	csrr	a5,sstatus
ffffffffc0200ef0:	8b89                	andi	a5,a5,2
ffffffffc0200ef2:	e799                	bnez	a5,ffffffffc0200f00 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200ef4:	00005797          	auipc	a5,0x5
ffffffffc0200ef8:	56c7b783          	ld	a5,1388(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200efc:	6f9c                	ld	a5,24(a5)
ffffffffc0200efe:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200f00:	1141                	addi	sp,sp,-16
ffffffffc0200f02:	e406                	sd	ra,8(sp)
ffffffffc0200f04:	e022                	sd	s0,0(sp)
ffffffffc0200f06:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200f08:	d56ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f0c:	00005797          	auipc	a5,0x5
ffffffffc0200f10:	5547b783          	ld	a5,1364(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200f14:	6f9c                	ld	a5,24(a5)
ffffffffc0200f16:	8522                	mv	a0,s0
ffffffffc0200f18:	9782                	jalr	a5
ffffffffc0200f1a:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200f1c:	d3cff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200f20:	60a2                	ld	ra,8(sp)
ffffffffc0200f22:	8522                	mv	a0,s0
ffffffffc0200f24:	6402                	ld	s0,0(sp)
ffffffffc0200f26:	0141                	addi	sp,sp,16
ffffffffc0200f28:	8082                	ret

ffffffffc0200f2a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f2a:	100027f3          	csrr	a5,sstatus
ffffffffc0200f2e:	8b89                	andi	a5,a5,2
ffffffffc0200f30:	e799                	bnez	a5,ffffffffc0200f3e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200f32:	00005797          	auipc	a5,0x5
ffffffffc0200f36:	52e7b783          	ld	a5,1326(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200f3a:	739c                	ld	a5,32(a5)
ffffffffc0200f3c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f3e:	1101                	addi	sp,sp,-32
ffffffffc0200f40:	ec06                	sd	ra,24(sp)
ffffffffc0200f42:	e822                	sd	s0,16(sp)
ffffffffc0200f44:	e426                	sd	s1,8(sp)
ffffffffc0200f46:	842a                	mv	s0,a0
ffffffffc0200f48:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f4a:	d14ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f4e:	00005797          	auipc	a5,0x5
ffffffffc0200f52:	5127b783          	ld	a5,1298(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200f56:	739c                	ld	a5,32(a5)
ffffffffc0200f58:	85a6                	mv	a1,s1
ffffffffc0200f5a:	8522                	mv	a0,s0
ffffffffc0200f5c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f5e:	6442                	ld	s0,16(sp)
ffffffffc0200f60:	60e2                	ld	ra,24(sp)
ffffffffc0200f62:	64a2                	ld	s1,8(sp)
ffffffffc0200f64:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f66:	cf2ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0200f6a <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200f6a:	00001797          	auipc	a5,0x1
ffffffffc0200f6e:	ffe78793          	addi	a5,a5,-2 # ffffffffc0201f68 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f72:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200f74:	1101                	addi	sp,sp,-32
ffffffffc0200f76:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f78:	00001517          	auipc	a0,0x1
ffffffffc0200f7c:	02850513          	addi	a0,a0,40 # ffffffffc0201fa0 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200f80:	00005497          	auipc	s1,0x5
ffffffffc0200f84:	4e048493          	addi	s1,s1,1248 # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc0200f88:	ec06                	sd	ra,24(sp)
ffffffffc0200f8a:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200f8c:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f8e:	924ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200f92:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f94:	00005417          	auipc	s0,0x5
ffffffffc0200f98:	4e440413          	addi	s0,s0,1252 # ffffffffc0206478 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200f9c:	679c                	ld	a5,8(a5)
ffffffffc0200f9e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fa0:	57f5                	li	a5,-3
ffffffffc0200fa2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200fa4:	00001517          	auipc	a0,0x1
ffffffffc0200fa8:	01450513          	addi	a0,a0,20 # ffffffffc0201fb8 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fac:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200fae:	904ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200fb2:	46c5                	li	a3,17
ffffffffc0200fb4:	06ee                	slli	a3,a3,0x1b
ffffffffc0200fb6:	40100613          	li	a2,1025
ffffffffc0200fba:	16fd                	addi	a3,a3,-1
ffffffffc0200fbc:	07e005b7          	lui	a1,0x7e00
ffffffffc0200fc0:	0656                	slli	a2,a2,0x15
ffffffffc0200fc2:	00001517          	auipc	a0,0x1
ffffffffc0200fc6:	00e50513          	addi	a0,a0,14 # ffffffffc0201fd0 <buddy_system_pmm_manager+0x68>
ffffffffc0200fca:	8e8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200fce:	777d                	lui	a4,0xfffff
ffffffffc0200fd0:	00006797          	auipc	a5,0x6
ffffffffc0200fd4:	4b778793          	addi	a5,a5,1207 # ffffffffc0207487 <end+0xfff>
ffffffffc0200fd8:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200fda:	00005517          	auipc	a0,0x5
ffffffffc0200fde:	47650513          	addi	a0,a0,1142 # ffffffffc0206450 <npage>
ffffffffc0200fe2:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200fe6:	00005597          	auipc	a1,0x5
ffffffffc0200fea:	47258593          	addi	a1,a1,1138 # ffffffffc0206458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200fee:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ff0:	e19c                	sd	a5,0(a1)
ffffffffc0200ff2:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200ff4:	4701                	li	a4,0
ffffffffc0200ff6:	4885                	li	a7,1
ffffffffc0200ff8:	fff80837          	lui	a6,0xfff80
ffffffffc0200ffc:	a011                	j	ffffffffc0201000 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200ffe:	619c                	ld	a5,0(a1)
ffffffffc0201000:	97b6                	add	a5,a5,a3
ffffffffc0201002:	07a1                	addi	a5,a5,8
ffffffffc0201004:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201008:	611c                	ld	a5,0(a0)
ffffffffc020100a:	0705                	addi	a4,a4,1
ffffffffc020100c:	02868693          	addi	a3,a3,40
ffffffffc0201010:	01078633          	add	a2,a5,a6
ffffffffc0201014:	fec765e3          	bltu	a4,a2,ffffffffc0200ffe <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201018:	6190                	ld	a2,0(a1)
ffffffffc020101a:	00279713          	slli	a4,a5,0x2
ffffffffc020101e:	973e                	add	a4,a4,a5
ffffffffc0201020:	fec006b7          	lui	a3,0xfec00
ffffffffc0201024:	070e                	slli	a4,a4,0x3
ffffffffc0201026:	96b2                	add	a3,a3,a2
ffffffffc0201028:	96ba                	add	a3,a3,a4
ffffffffc020102a:	c0200737          	lui	a4,0xc0200
ffffffffc020102e:	08e6ef63          	bltu	a3,a4,ffffffffc02010cc <pmm_init+0x162>
ffffffffc0201032:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201034:	45c5                	li	a1,17
ffffffffc0201036:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201038:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020103a:	04b6e863          	bltu	a3,a1,ffffffffc020108a <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020103e:	609c                	ld	a5,0(s1)
ffffffffc0201040:	7b9c                	ld	a5,48(a5)
ffffffffc0201042:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201044:	00001517          	auipc	a0,0x1
ffffffffc0201048:	02450513          	addi	a0,a0,36 # ffffffffc0202068 <buddy_system_pmm_manager+0x100>
ffffffffc020104c:	866ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201050:	00004597          	auipc	a1,0x4
ffffffffc0201054:	fb058593          	addi	a1,a1,-80 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201058:	00005797          	auipc	a5,0x5
ffffffffc020105c:	40b7bc23          	sd	a1,1048(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201060:	c02007b7          	lui	a5,0xc0200
ffffffffc0201064:	08f5e063          	bltu	a1,a5,ffffffffc02010e4 <pmm_init+0x17a>
ffffffffc0201068:	6010                	ld	a2,0(s0)
}
ffffffffc020106a:	6442                	ld	s0,16(sp)
ffffffffc020106c:	60e2                	ld	ra,24(sp)
ffffffffc020106e:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201070:	40c58633          	sub	a2,a1,a2
ffffffffc0201074:	00005797          	auipc	a5,0x5
ffffffffc0201078:	3ec7ba23          	sd	a2,1012(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020107c:	00001517          	auipc	a0,0x1
ffffffffc0201080:	00c50513          	addi	a0,a0,12 # ffffffffc0202088 <buddy_system_pmm_manager+0x120>
}
ffffffffc0201084:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201086:	82cff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020108a:	6705                	lui	a4,0x1
ffffffffc020108c:	177d                	addi	a4,a4,-1
ffffffffc020108e:	96ba                	add	a3,a3,a4
ffffffffc0201090:	777d                	lui	a4,0xfffff
ffffffffc0201092:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201094:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201098:	00f57e63          	bgeu	a0,a5,ffffffffc02010b4 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc020109c:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020109e:	982a                	add	a6,a6,a0
ffffffffc02010a0:	00281513          	slli	a0,a6,0x2
ffffffffc02010a4:	9542                	add	a0,a0,a6
ffffffffc02010a6:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010a8:	8d95                	sub	a1,a1,a3
ffffffffc02010aa:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02010ac:	81b1                	srli	a1,a1,0xc
ffffffffc02010ae:	9532                	add	a0,a0,a2
ffffffffc02010b0:	9782                	jalr	a5
}
ffffffffc02010b2:	b771                	j	ffffffffc020103e <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02010b4:	00001617          	auipc	a2,0x1
ffffffffc02010b8:	f8460613          	addi	a2,a2,-124 # ffffffffc0202038 <buddy_system_pmm_manager+0xd0>
ffffffffc02010bc:	06b00593          	li	a1,107
ffffffffc02010c0:	00001517          	auipc	a0,0x1
ffffffffc02010c4:	f9850513          	addi	a0,a0,-104 # ffffffffc0202058 <buddy_system_pmm_manager+0xf0>
ffffffffc02010c8:	ae4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010cc:	00001617          	auipc	a2,0x1
ffffffffc02010d0:	f3460613          	addi	a2,a2,-204 # ffffffffc0202000 <buddy_system_pmm_manager+0x98>
ffffffffc02010d4:	06f00593          	li	a1,111
ffffffffc02010d8:	00001517          	auipc	a0,0x1
ffffffffc02010dc:	f5050513          	addi	a0,a0,-176 # ffffffffc0202028 <buddy_system_pmm_manager+0xc0>
ffffffffc02010e0:	accff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02010e4:	86ae                	mv	a3,a1
ffffffffc02010e6:	00001617          	auipc	a2,0x1
ffffffffc02010ea:	f1a60613          	addi	a2,a2,-230 # ffffffffc0202000 <buddy_system_pmm_manager+0x98>
ffffffffc02010ee:	08a00593          	li	a1,138
ffffffffc02010f2:	00001517          	auipc	a0,0x1
ffffffffc02010f6:	f3650513          	addi	a0,a0,-202 # ffffffffc0202028 <buddy_system_pmm_manager+0xc0>
ffffffffc02010fa:	ab2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02010fe <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02010fe:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201102:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201104:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201108:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020110a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020110e:	f022                	sd	s0,32(sp)
ffffffffc0201110:	ec26                	sd	s1,24(sp)
ffffffffc0201112:	e84a                	sd	s2,16(sp)
ffffffffc0201114:	f406                	sd	ra,40(sp)
ffffffffc0201116:	e44e                	sd	s3,8(sp)
ffffffffc0201118:	84aa                	mv	s1,a0
ffffffffc020111a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020111c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201120:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201122:	03067e63          	bgeu	a2,a6,ffffffffc020115e <printnum+0x60>
ffffffffc0201126:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201128:	00805763          	blez	s0,ffffffffc0201136 <printnum+0x38>
ffffffffc020112c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020112e:	85ca                	mv	a1,s2
ffffffffc0201130:	854e                	mv	a0,s3
ffffffffc0201132:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201134:	fc65                	bnez	s0,ffffffffc020112c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201136:	1a02                	slli	s4,s4,0x20
ffffffffc0201138:	00001797          	auipc	a5,0x1
ffffffffc020113c:	f9078793          	addi	a5,a5,-112 # ffffffffc02020c8 <buddy_system_pmm_manager+0x160>
ffffffffc0201140:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201144:	9a3e                	add	s4,s4,a5
}
ffffffffc0201146:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201148:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020114c:	70a2                	ld	ra,40(sp)
ffffffffc020114e:	69a2                	ld	s3,8(sp)
ffffffffc0201150:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201152:	85ca                	mv	a1,s2
ffffffffc0201154:	87a6                	mv	a5,s1
}
ffffffffc0201156:	6942                	ld	s2,16(sp)
ffffffffc0201158:	64e2                	ld	s1,24(sp)
ffffffffc020115a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020115c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020115e:	03065633          	divu	a2,a2,a6
ffffffffc0201162:	8722                	mv	a4,s0
ffffffffc0201164:	f9bff0ef          	jal	ra,ffffffffc02010fe <printnum>
ffffffffc0201168:	b7f9                	j	ffffffffc0201136 <printnum+0x38>

ffffffffc020116a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020116a:	7119                	addi	sp,sp,-128
ffffffffc020116c:	f4a6                	sd	s1,104(sp)
ffffffffc020116e:	f0ca                	sd	s2,96(sp)
ffffffffc0201170:	ecce                	sd	s3,88(sp)
ffffffffc0201172:	e8d2                	sd	s4,80(sp)
ffffffffc0201174:	e4d6                	sd	s5,72(sp)
ffffffffc0201176:	e0da                	sd	s6,64(sp)
ffffffffc0201178:	fc5e                	sd	s7,56(sp)
ffffffffc020117a:	f06a                	sd	s10,32(sp)
ffffffffc020117c:	fc86                	sd	ra,120(sp)
ffffffffc020117e:	f8a2                	sd	s0,112(sp)
ffffffffc0201180:	f862                	sd	s8,48(sp)
ffffffffc0201182:	f466                	sd	s9,40(sp)
ffffffffc0201184:	ec6e                	sd	s11,24(sp)
ffffffffc0201186:	892a                	mv	s2,a0
ffffffffc0201188:	84ae                	mv	s1,a1
ffffffffc020118a:	8d32                	mv	s10,a2
ffffffffc020118c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020118e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201192:	5b7d                	li	s6,-1
ffffffffc0201194:	00001a97          	auipc	s5,0x1
ffffffffc0201198:	f68a8a93          	addi	s5,s5,-152 # ffffffffc02020fc <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020119c:	00001b97          	auipc	s7,0x1
ffffffffc02011a0:	13cb8b93          	addi	s7,s7,316 # ffffffffc02022d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011a4:	000d4503          	lbu	a0,0(s10)
ffffffffc02011a8:	001d0413          	addi	s0,s10,1
ffffffffc02011ac:	01350a63          	beq	a0,s3,ffffffffc02011c0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02011b0:	c121                	beqz	a0,ffffffffc02011f0 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02011b2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011b4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02011b6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011b8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02011bc:	ff351ae3          	bne	a0,s3,ffffffffc02011b0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011c0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02011c4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02011c8:	4c81                	li	s9,0
ffffffffc02011ca:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02011cc:	5c7d                	li	s8,-1
ffffffffc02011ce:	5dfd                	li	s11,-1
ffffffffc02011d0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02011d4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011d6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02011da:	0ff5f593          	zext.b	a1,a1
ffffffffc02011de:	00140d13          	addi	s10,s0,1
ffffffffc02011e2:	04b56263          	bltu	a0,a1,ffffffffc0201226 <vprintfmt+0xbc>
ffffffffc02011e6:	058a                	slli	a1,a1,0x2
ffffffffc02011e8:	95d6                	add	a1,a1,s5
ffffffffc02011ea:	4194                	lw	a3,0(a1)
ffffffffc02011ec:	96d6                	add	a3,a3,s5
ffffffffc02011ee:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02011f0:	70e6                	ld	ra,120(sp)
ffffffffc02011f2:	7446                	ld	s0,112(sp)
ffffffffc02011f4:	74a6                	ld	s1,104(sp)
ffffffffc02011f6:	7906                	ld	s2,96(sp)
ffffffffc02011f8:	69e6                	ld	s3,88(sp)
ffffffffc02011fa:	6a46                	ld	s4,80(sp)
ffffffffc02011fc:	6aa6                	ld	s5,72(sp)
ffffffffc02011fe:	6b06                	ld	s6,64(sp)
ffffffffc0201200:	7be2                	ld	s7,56(sp)
ffffffffc0201202:	7c42                	ld	s8,48(sp)
ffffffffc0201204:	7ca2                	ld	s9,40(sp)
ffffffffc0201206:	7d02                	ld	s10,32(sp)
ffffffffc0201208:	6de2                	ld	s11,24(sp)
ffffffffc020120a:	6109                	addi	sp,sp,128
ffffffffc020120c:	8082                	ret
            padc = '0';
ffffffffc020120e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201210:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201214:	846a                	mv	s0,s10
ffffffffc0201216:	00140d13          	addi	s10,s0,1
ffffffffc020121a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020121e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201222:	fcb572e3          	bgeu	a0,a1,ffffffffc02011e6 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201226:	85a6                	mv	a1,s1
ffffffffc0201228:	02500513          	li	a0,37
ffffffffc020122c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020122e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201232:	8d22                	mv	s10,s0
ffffffffc0201234:	f73788e3          	beq	a5,s3,ffffffffc02011a4 <vprintfmt+0x3a>
ffffffffc0201238:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020123c:	1d7d                	addi	s10,s10,-1
ffffffffc020123e:	ff379de3          	bne	a5,s3,ffffffffc0201238 <vprintfmt+0xce>
ffffffffc0201242:	b78d                	j	ffffffffc02011a4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201244:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201248:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020124c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020124e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201252:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201256:	02d86463          	bltu	a6,a3,ffffffffc020127e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020125a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020125e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201262:	0186873b          	addw	a4,a3,s8
ffffffffc0201266:	0017171b          	slliw	a4,a4,0x1
ffffffffc020126a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020126c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201270:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201272:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201276:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020127a:	fed870e3          	bgeu	a6,a3,ffffffffc020125a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020127e:	f40ddce3          	bgez	s11,ffffffffc02011d6 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201282:	8de2                	mv	s11,s8
ffffffffc0201284:	5c7d                	li	s8,-1
ffffffffc0201286:	bf81                	j	ffffffffc02011d6 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201288:	fffdc693          	not	a3,s11
ffffffffc020128c:	96fd                	srai	a3,a3,0x3f
ffffffffc020128e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201292:	00144603          	lbu	a2,1(s0)
ffffffffc0201296:	2d81                	sext.w	s11,s11
ffffffffc0201298:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020129a:	bf35                	j	ffffffffc02011d6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020129c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012a0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02012a4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012a6:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02012a8:	bfd9                	j	ffffffffc020127e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02012aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012ac:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02012b0:	01174463          	blt	a4,a7,ffffffffc02012b8 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02012b4:	1a088e63          	beqz	a7,ffffffffc0201470 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02012b8:	000a3603          	ld	a2,0(s4)
ffffffffc02012bc:	46c1                	li	a3,16
ffffffffc02012be:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02012c0:	2781                	sext.w	a5,a5
ffffffffc02012c2:	876e                	mv	a4,s11
ffffffffc02012c4:	85a6                	mv	a1,s1
ffffffffc02012c6:	854a                	mv	a0,s2
ffffffffc02012c8:	e37ff0ef          	jal	ra,ffffffffc02010fe <printnum>
            break;
ffffffffc02012cc:	bde1                	j	ffffffffc02011a4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02012ce:	000a2503          	lw	a0,0(s4)
ffffffffc02012d2:	85a6                	mv	a1,s1
ffffffffc02012d4:	0a21                	addi	s4,s4,8
ffffffffc02012d6:	9902                	jalr	s2
            break;
ffffffffc02012d8:	b5f1                	j	ffffffffc02011a4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012da:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012dc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02012e0:	01174463          	blt	a4,a7,ffffffffc02012e8 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02012e4:	18088163          	beqz	a7,ffffffffc0201466 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02012e8:	000a3603          	ld	a2,0(s4)
ffffffffc02012ec:	46a9                	li	a3,10
ffffffffc02012ee:	8a2e                	mv	s4,a1
ffffffffc02012f0:	bfc1                	j	ffffffffc02012c0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012f2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02012f6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012f8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012fa:	bdf1                	j	ffffffffc02011d6 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02012fc:	85a6                	mv	a1,s1
ffffffffc02012fe:	02500513          	li	a0,37
ffffffffc0201302:	9902                	jalr	s2
            break;
ffffffffc0201304:	b545                	j	ffffffffc02011a4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201306:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020130a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020130c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020130e:	b5e1                	j	ffffffffc02011d6 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201310:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201312:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201316:	01174463          	blt	a4,a7,ffffffffc020131e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020131a:	14088163          	beqz	a7,ffffffffc020145c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020131e:	000a3603          	ld	a2,0(s4)
ffffffffc0201322:	46a1                	li	a3,8
ffffffffc0201324:	8a2e                	mv	s4,a1
ffffffffc0201326:	bf69                	j	ffffffffc02012c0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201328:	03000513          	li	a0,48
ffffffffc020132c:	85a6                	mv	a1,s1
ffffffffc020132e:	e03e                	sd	a5,0(sp)
ffffffffc0201330:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201332:	85a6                	mv	a1,s1
ffffffffc0201334:	07800513          	li	a0,120
ffffffffc0201338:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020133a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020133c:	6782                	ld	a5,0(sp)
ffffffffc020133e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201340:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201344:	bfb5                	j	ffffffffc02012c0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201346:	000a3403          	ld	s0,0(s4)
ffffffffc020134a:	008a0713          	addi	a4,s4,8
ffffffffc020134e:	e03a                	sd	a4,0(sp)
ffffffffc0201350:	14040263          	beqz	s0,ffffffffc0201494 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201354:	0fb05763          	blez	s11,ffffffffc0201442 <vprintfmt+0x2d8>
ffffffffc0201358:	02d00693          	li	a3,45
ffffffffc020135c:	0cd79163          	bne	a5,a3,ffffffffc020141e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201360:	00044783          	lbu	a5,0(s0)
ffffffffc0201364:	0007851b          	sext.w	a0,a5
ffffffffc0201368:	cf85                	beqz	a5,ffffffffc02013a0 <vprintfmt+0x236>
ffffffffc020136a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020136e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201372:	000c4563          	bltz	s8,ffffffffc020137c <vprintfmt+0x212>
ffffffffc0201376:	3c7d                	addiw	s8,s8,-1
ffffffffc0201378:	036c0263          	beq	s8,s6,ffffffffc020139c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020137c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020137e:	0e0c8e63          	beqz	s9,ffffffffc020147a <vprintfmt+0x310>
ffffffffc0201382:	3781                	addiw	a5,a5,-32
ffffffffc0201384:	0ef47b63          	bgeu	s0,a5,ffffffffc020147a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201388:	03f00513          	li	a0,63
ffffffffc020138c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020138e:	000a4783          	lbu	a5,0(s4)
ffffffffc0201392:	3dfd                	addiw	s11,s11,-1
ffffffffc0201394:	0a05                	addi	s4,s4,1
ffffffffc0201396:	0007851b          	sext.w	a0,a5
ffffffffc020139a:	ffe1                	bnez	a5,ffffffffc0201372 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020139c:	01b05963          	blez	s11,ffffffffc02013ae <vprintfmt+0x244>
ffffffffc02013a0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02013a2:	85a6                	mv	a1,s1
ffffffffc02013a4:	02000513          	li	a0,32
ffffffffc02013a8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02013aa:	fe0d9be3          	bnez	s11,ffffffffc02013a0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02013ae:	6a02                	ld	s4,0(sp)
ffffffffc02013b0:	bbd5                	j	ffffffffc02011a4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02013b2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013b4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02013b8:	01174463          	blt	a4,a7,ffffffffc02013c0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02013bc:	08088d63          	beqz	a7,ffffffffc0201456 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02013c0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02013c4:	0a044d63          	bltz	s0,ffffffffc020147e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02013c8:	8622                	mv	a2,s0
ffffffffc02013ca:	8a66                	mv	s4,s9
ffffffffc02013cc:	46a9                	li	a3,10
ffffffffc02013ce:	bdcd                	j	ffffffffc02012c0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02013d0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013d4:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02013d6:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02013d8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02013dc:	8fb5                	xor	a5,a5,a3
ffffffffc02013de:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013e2:	02d74163          	blt	a4,a3,ffffffffc0201404 <vprintfmt+0x29a>
ffffffffc02013e6:	00369793          	slli	a5,a3,0x3
ffffffffc02013ea:	97de                	add	a5,a5,s7
ffffffffc02013ec:	639c                	ld	a5,0(a5)
ffffffffc02013ee:	cb99                	beqz	a5,ffffffffc0201404 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02013f0:	86be                	mv	a3,a5
ffffffffc02013f2:	00001617          	auipc	a2,0x1
ffffffffc02013f6:	d0660613          	addi	a2,a2,-762 # ffffffffc02020f8 <buddy_system_pmm_manager+0x190>
ffffffffc02013fa:	85a6                	mv	a1,s1
ffffffffc02013fc:	854a                	mv	a0,s2
ffffffffc02013fe:	0ce000ef          	jal	ra,ffffffffc02014cc <printfmt>
ffffffffc0201402:	b34d                	j	ffffffffc02011a4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201404:	00001617          	auipc	a2,0x1
ffffffffc0201408:	ce460613          	addi	a2,a2,-796 # ffffffffc02020e8 <buddy_system_pmm_manager+0x180>
ffffffffc020140c:	85a6                	mv	a1,s1
ffffffffc020140e:	854a                	mv	a0,s2
ffffffffc0201410:	0bc000ef          	jal	ra,ffffffffc02014cc <printfmt>
ffffffffc0201414:	bb41                	j	ffffffffc02011a4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201416:	00001417          	auipc	s0,0x1
ffffffffc020141a:	cca40413          	addi	s0,s0,-822 # ffffffffc02020e0 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020141e:	85e2                	mv	a1,s8
ffffffffc0201420:	8522                	mv	a0,s0
ffffffffc0201422:	e43e                	sd	a5,8(sp)
ffffffffc0201424:	1cc000ef          	jal	ra,ffffffffc02015f0 <strnlen>
ffffffffc0201428:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020142c:	01b05b63          	blez	s11,ffffffffc0201442 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201430:	67a2                	ld	a5,8(sp)
ffffffffc0201432:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201436:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201438:	85a6                	mv	a1,s1
ffffffffc020143a:	8552                	mv	a0,s4
ffffffffc020143c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020143e:	fe0d9ce3          	bnez	s11,ffffffffc0201436 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201442:	00044783          	lbu	a5,0(s0)
ffffffffc0201446:	00140a13          	addi	s4,s0,1
ffffffffc020144a:	0007851b          	sext.w	a0,a5
ffffffffc020144e:	d3a5                	beqz	a5,ffffffffc02013ae <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201450:	05e00413          	li	s0,94
ffffffffc0201454:	bf39                	j	ffffffffc0201372 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201456:	000a2403          	lw	s0,0(s4)
ffffffffc020145a:	b7ad                	j	ffffffffc02013c4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020145c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201460:	46a1                	li	a3,8
ffffffffc0201462:	8a2e                	mv	s4,a1
ffffffffc0201464:	bdb1                	j	ffffffffc02012c0 <vprintfmt+0x156>
ffffffffc0201466:	000a6603          	lwu	a2,0(s4)
ffffffffc020146a:	46a9                	li	a3,10
ffffffffc020146c:	8a2e                	mv	s4,a1
ffffffffc020146e:	bd89                	j	ffffffffc02012c0 <vprintfmt+0x156>
ffffffffc0201470:	000a6603          	lwu	a2,0(s4)
ffffffffc0201474:	46c1                	li	a3,16
ffffffffc0201476:	8a2e                	mv	s4,a1
ffffffffc0201478:	b5a1                	j	ffffffffc02012c0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020147a:	9902                	jalr	s2
ffffffffc020147c:	bf09                	j	ffffffffc020138e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020147e:	85a6                	mv	a1,s1
ffffffffc0201480:	02d00513          	li	a0,45
ffffffffc0201484:	e03e                	sd	a5,0(sp)
ffffffffc0201486:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201488:	6782                	ld	a5,0(sp)
ffffffffc020148a:	8a66                	mv	s4,s9
ffffffffc020148c:	40800633          	neg	a2,s0
ffffffffc0201490:	46a9                	li	a3,10
ffffffffc0201492:	b53d                	j	ffffffffc02012c0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201494:	03b05163          	blez	s11,ffffffffc02014b6 <vprintfmt+0x34c>
ffffffffc0201498:	02d00693          	li	a3,45
ffffffffc020149c:	f6d79de3          	bne	a5,a3,ffffffffc0201416 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02014a0:	00001417          	auipc	s0,0x1
ffffffffc02014a4:	c4040413          	addi	s0,s0,-960 # ffffffffc02020e0 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014a8:	02800793          	li	a5,40
ffffffffc02014ac:	02800513          	li	a0,40
ffffffffc02014b0:	00140a13          	addi	s4,s0,1
ffffffffc02014b4:	bd6d                	j	ffffffffc020136e <vprintfmt+0x204>
ffffffffc02014b6:	00001a17          	auipc	s4,0x1
ffffffffc02014ba:	c2ba0a13          	addi	s4,s4,-981 # ffffffffc02020e1 <buddy_system_pmm_manager+0x179>
ffffffffc02014be:	02800513          	li	a0,40
ffffffffc02014c2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014c6:	05e00413          	li	s0,94
ffffffffc02014ca:	b565                	j	ffffffffc0201372 <vprintfmt+0x208>

ffffffffc02014cc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014cc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02014ce:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014d2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02014d4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014d6:	ec06                	sd	ra,24(sp)
ffffffffc02014d8:	f83a                	sd	a4,48(sp)
ffffffffc02014da:	fc3e                	sd	a5,56(sp)
ffffffffc02014dc:	e0c2                	sd	a6,64(sp)
ffffffffc02014de:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02014e0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02014e2:	c89ff0ef          	jal	ra,ffffffffc020116a <vprintfmt>
}
ffffffffc02014e6:	60e2                	ld	ra,24(sp)
ffffffffc02014e8:	6161                	addi	sp,sp,80
ffffffffc02014ea:	8082                	ret

ffffffffc02014ec <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02014ec:	715d                	addi	sp,sp,-80
ffffffffc02014ee:	e486                	sd	ra,72(sp)
ffffffffc02014f0:	e0a6                	sd	s1,64(sp)
ffffffffc02014f2:	fc4a                	sd	s2,56(sp)
ffffffffc02014f4:	f84e                	sd	s3,48(sp)
ffffffffc02014f6:	f452                	sd	s4,40(sp)
ffffffffc02014f8:	f056                	sd	s5,32(sp)
ffffffffc02014fa:	ec5a                	sd	s6,24(sp)
ffffffffc02014fc:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02014fe:	c901                	beqz	a0,ffffffffc020150e <readline+0x22>
ffffffffc0201500:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201502:	00001517          	auipc	a0,0x1
ffffffffc0201506:	bf650513          	addi	a0,a0,-1034 # ffffffffc02020f8 <buddy_system_pmm_manager+0x190>
ffffffffc020150a:	ba9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020150e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201510:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201512:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201514:	4aa9                	li	s5,10
ffffffffc0201516:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201518:	00005b97          	auipc	s7,0x5
ffffffffc020151c:	b10b8b93          	addi	s7,s7,-1264 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201520:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201524:	c07fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201528:	00054a63          	bltz	a0,ffffffffc020153c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020152c:	00a95a63          	bge	s2,a0,ffffffffc0201540 <readline+0x54>
ffffffffc0201530:	029a5263          	bge	s4,s1,ffffffffc0201554 <readline+0x68>
        c = getchar();
ffffffffc0201534:	bf7fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201538:	fe055ae3          	bgez	a0,ffffffffc020152c <readline+0x40>
            return NULL;
ffffffffc020153c:	4501                	li	a0,0
ffffffffc020153e:	a091                	j	ffffffffc0201582 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201540:	03351463          	bne	a0,s3,ffffffffc0201568 <readline+0x7c>
ffffffffc0201544:	e8a9                	bnez	s1,ffffffffc0201596 <readline+0xaa>
        c = getchar();
ffffffffc0201546:	be5fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020154a:	fe0549e3          	bltz	a0,ffffffffc020153c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020154e:	fea959e3          	bge	s2,a0,ffffffffc0201540 <readline+0x54>
ffffffffc0201552:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201554:	e42a                	sd	a0,8(sp)
ffffffffc0201556:	b93fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc020155a:	6522                	ld	a0,8(sp)
ffffffffc020155c:	009b87b3          	add	a5,s7,s1
ffffffffc0201560:	2485                	addiw	s1,s1,1
ffffffffc0201562:	00a78023          	sb	a0,0(a5)
ffffffffc0201566:	bf7d                	j	ffffffffc0201524 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201568:	01550463          	beq	a0,s5,ffffffffc0201570 <readline+0x84>
ffffffffc020156c:	fb651ce3          	bne	a0,s6,ffffffffc0201524 <readline+0x38>
            cputchar(c);
ffffffffc0201570:	b79fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201574:	00005517          	auipc	a0,0x5
ffffffffc0201578:	ab450513          	addi	a0,a0,-1356 # ffffffffc0206028 <buf>
ffffffffc020157c:	94aa                	add	s1,s1,a0
ffffffffc020157e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201582:	60a6                	ld	ra,72(sp)
ffffffffc0201584:	6486                	ld	s1,64(sp)
ffffffffc0201586:	7962                	ld	s2,56(sp)
ffffffffc0201588:	79c2                	ld	s3,48(sp)
ffffffffc020158a:	7a22                	ld	s4,40(sp)
ffffffffc020158c:	7a82                	ld	s5,32(sp)
ffffffffc020158e:	6b62                	ld	s6,24(sp)
ffffffffc0201590:	6bc2                	ld	s7,16(sp)
ffffffffc0201592:	6161                	addi	sp,sp,80
ffffffffc0201594:	8082                	ret
            cputchar(c);
ffffffffc0201596:	4521                	li	a0,8
ffffffffc0201598:	b51fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc020159c:	34fd                	addiw	s1,s1,-1
ffffffffc020159e:	b759                	j	ffffffffc0201524 <readline+0x38>

ffffffffc02015a0 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02015a0:	4781                	li	a5,0
ffffffffc02015a2:	00005717          	auipc	a4,0x5
ffffffffc02015a6:	a6673703          	ld	a4,-1434(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02015aa:	88ba                	mv	a7,a4
ffffffffc02015ac:	852a                	mv	a0,a0
ffffffffc02015ae:	85be                	mv	a1,a5
ffffffffc02015b0:	863e                	mv	a2,a5
ffffffffc02015b2:	00000073          	ecall
ffffffffc02015b6:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02015b8:	8082                	ret

ffffffffc02015ba <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02015ba:	4781                	li	a5,0
ffffffffc02015bc:	00005717          	auipc	a4,0x5
ffffffffc02015c0:	ec473703          	ld	a4,-316(a4) # ffffffffc0206480 <SBI_SET_TIMER>
ffffffffc02015c4:	88ba                	mv	a7,a4
ffffffffc02015c6:	852a                	mv	a0,a0
ffffffffc02015c8:	85be                	mv	a1,a5
ffffffffc02015ca:	863e                	mv	a2,a5
ffffffffc02015cc:	00000073          	ecall
ffffffffc02015d0:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02015d2:	8082                	ret

ffffffffc02015d4 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02015d4:	4501                	li	a0,0
ffffffffc02015d6:	00005797          	auipc	a5,0x5
ffffffffc02015da:	a2a7b783          	ld	a5,-1494(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02015de:	88be                	mv	a7,a5
ffffffffc02015e0:	852a                	mv	a0,a0
ffffffffc02015e2:	85aa                	mv	a1,a0
ffffffffc02015e4:	862a                	mv	a2,a0
ffffffffc02015e6:	00000073          	ecall
ffffffffc02015ea:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02015ec:	2501                	sext.w	a0,a0
ffffffffc02015ee:	8082                	ret

ffffffffc02015f0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02015f0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015f2:	e589                	bnez	a1,ffffffffc02015fc <strnlen+0xc>
ffffffffc02015f4:	a811                	j	ffffffffc0201608 <strnlen+0x18>
        cnt ++;
ffffffffc02015f6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015f8:	00f58863          	beq	a1,a5,ffffffffc0201608 <strnlen+0x18>
ffffffffc02015fc:	00f50733          	add	a4,a0,a5
ffffffffc0201600:	00074703          	lbu	a4,0(a4)
ffffffffc0201604:	fb6d                	bnez	a4,ffffffffc02015f6 <strnlen+0x6>
ffffffffc0201606:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201608:	852e                	mv	a0,a1
ffffffffc020160a:	8082                	ret

ffffffffc020160c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020160c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201610:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201614:	cb89                	beqz	a5,ffffffffc0201626 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201616:	0505                	addi	a0,a0,1
ffffffffc0201618:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020161a:	fee789e3          	beq	a5,a4,ffffffffc020160c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020161e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201622:	9d19                	subw	a0,a0,a4
ffffffffc0201624:	8082                	ret
ffffffffc0201626:	4501                	li	a0,0
ffffffffc0201628:	bfed                	j	ffffffffc0201622 <strcmp+0x16>

ffffffffc020162a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020162a:	00054783          	lbu	a5,0(a0)
ffffffffc020162e:	c799                	beqz	a5,ffffffffc020163c <strchr+0x12>
        if (*s == c) {
ffffffffc0201630:	00f58763          	beq	a1,a5,ffffffffc020163e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201634:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201638:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020163a:	fbfd                	bnez	a5,ffffffffc0201630 <strchr+0x6>
    }
    return NULL;
ffffffffc020163c:	4501                	li	a0,0
}
ffffffffc020163e:	8082                	ret

ffffffffc0201640 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201640:	ca01                	beqz	a2,ffffffffc0201650 <memset+0x10>
ffffffffc0201642:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201644:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201646:	0785                	addi	a5,a5,1
ffffffffc0201648:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020164c:	fec79de3          	bne	a5,a2,ffffffffc0201646 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201650:	8082                	ret
