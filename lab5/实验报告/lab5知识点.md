# lab5知识点

## 一、进程的状态

| 状态名称      | 含义                 | 产生的原因/方法                                |
| ------------- | -------------------- | ---------------------------------------------- |
| PROC_UNINIT   | 未初始化             | `alloc_proc` 分配了进程                        |
| PROC_SLEEPING | 睡眠中               | 调用 `try_free_pages`、`do_wait` 或 `do_sleep` |
| PROC_RUNNABLE | 可运行（或正在运行） | 调用 `proc_init` 或 `wakeup_proc`              |
| PROC_ZOMBIE   | 即将结束（僵尸态）   | 调用 `do_exit` 退出进程                        |

```
alloc_page()--> PROC_UNINIT --wakeup_proc()--> RUNNABLE --> do_exit() --> PROC_ZOMBIE
                                                   |  |                     ↑ ↑
                                                   ↓  ↓                     | |
                                                do_wait()                   | |
                                                   |  |                     ↑ ↑
                                                   ↓  ↓                     | |
                                            PROC_SLEEPING --> do_exit() --> | |
                                            
```

## 二、进程的关系

**父进程（parent）**：通过 `proc->parent` 表示。

**子进程（children）**：通过 `proc->cptr` 表示。

**兄弟关系**：

- **老的兄弟（older sibling）**：通过 `proc->optr` 表示。
- **年轻的兄弟（younger sibling）**：通过 `proc->yptr` 表示。

## 三、进程的结构体

```
struct proc_struct {
    enum proc_state state;                      // Process state
    int pid;                                    // Process ID
    int runs;                                   // the running times of Proces
    uintptr_t kstack;                           // Process kernel stack
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
    struct proc_struct *parent;                 // the parent process
    struct mm_struct *mm;                       // Process's memory management field
    struct context context;                     // Switch here to run process
    struct trapframe *tf;                       // Trap frame for current interrupt
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // Process link list 
    list_entry_t hash_link;                     // Process hash list
    int exit_code;                              // exit code (be sent to parent proc)
    uint32_t wait_state;                        // waiting state
    struct proc_struct *cptr, *yptr, *optr;     // relations between processes
};
```

**`state`** (enum proc_state)：

- 进程的状态。可能的值包括运行、就绪、睡眠等，用于表示进程当前的活动状态。

**`pid`** (int)：

- 进程的ID（PID），是操作系统用来唯一标识进程的一个整数值。

**`runs`** (int)：

- 记录进程被调度执行的次数。这个字段可以用于统计进程的运行频率，或者在负载均衡中使用（例如轮询调度算法）。

**`kstack`** (uintptr_t)：

- 指向进程的内核栈的指针。当进程在内核模式下执行时，使用这个栈来存储局部变量、函数调用等。

**`need_resched`** (volatile bool)：

- 一个布尔值，表示进程是否需要被重新调度。通常用于抢占式调度系统中，指示进程是否应被操作系统重新调度。

**`parent`** (struct proc_struct *)：

- 指向父进程的指针。每个进程都可能有一个父进程，通常在创建进程时，子进程会保存父进程的引用。

**`mm`** (struct mm_struct *)：

- 进程的内存管理结构体。它描述了进程的虚拟内存空间（包括堆、栈等内存区域的管理）。

**`context`** (struct context)：

- 用于保存进程的上下文信息（如寄存器的值等），方便在进程切换时恢复其执行状态。

**`tf`** (struct trapframe *)：

- 指向进程的陷阱帧（trap frame），保存进程中断或异常时的寄存器状态。

**`cr3`** (uintptr_t)：

- CR3寄存器的值，表示进程页目录表的基址。在x86架构中，CR3寄存器用于指向当前进程的页目录。

**`flags`** (uint32_t)：

- 进程的标志位。用于存储进程的各种状态标志，例如是否处于调试模式、是否是系统进程等。

**`name`** (char[PROC_NAME_LEN + 1])：

- 进程的名称。用于描述进程的标识符，通常是一个字符串。

**`list_link`** (list_entry_t)：

- 用于将进程插入进程链表中的字段。这是一个链表结构，进程可以通过这个字段与其他进程形成链表关系。

**`hash_link`** (list_entry_t)：

- 用于将进程插入进程哈希表中的字段。哈希表通常用于快速查找进程。

**`exit_code`** (int)：

- 进程的退出代码。当进程终止时，操作系统会记录进程的退出状态码，用于通知父进程。

**`wait_state`** (uint32_t)：

- 进程的等待状态。表示进程当前是否在等待某些事件，如等待I/O操作完成等。

**`cptr, yptr, optr`** (struct proc_struct *)：

- 这三个字段用于表示进程之间的关系，分别是子进程（child process）、兄弟进程（sibling process）和父进程（parent process）。

## 四、用户态进程执行过程

- 在此对用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过进行描述

在init_main中调用kernel_thread

```c
static int
init_main(void *arg) {
    ...
    int pid = kernel_thread(user_main, NULL, 0);
    ...
}
```

kernel_thread中调用do_fork创建并唤醒进程

```c
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    ...
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}
```

随之执行参数中函数user_main，进程开始执行

```c
static int
user_main(void *arg) {
...
#else
    KERNEL_EXECVE(exit);
...
}
```

user_main函数调用宏KERNEL_EXECVE

```c
#define KERNEL_EXECVE(x) ({                                             
            ...
            __KERNEL_EXECVE(#x, _binary_obj___user_##x##_out_start,     \
                            _binary_obj___user_##x##_out_size);         \
        })
```

宏KERNEL_EXECVE调用kernel_execve,执行ebreak，发生断点异常

```c
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
    ...
    asm volatile(
        ...
        "ebreak\n"
        ...)
    ...
}
```

断点异常产生，执行trap函数,调用trap_dispatch函数

```c
void trap(struct trapframe *tf) { trap_dispatch(tf); }
```

trap_dispatch函数调用exception_handler函数

```c
static inline void trap_dispatch(struct trapframe *tf) {
    ...
    else {
        exception_handler(tf);
    }
}
```

trap_dispatch函数执行到CAUSE_BREAKPOINT处,调用syscall

```c
void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
        ...
         case CAUSE_BREAKPOINT:
            if(tf->gpr.a7 == 10){
                tf->epc += 4;
                syscall();
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
            }
            break;
        ...
    }
}
```

syscall根据参数，执行sys_exec，调用do_execve

```c
void
syscall(void) {
    struct trapframe *tf = current->tf;
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
        if (syscalls[num] != NULL) {
            arg[0] = tf->gpr.a1;
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
            return ;
        }
    }   
```



```c
static int
sys_exec(uint64_t arg[]) {
    ...
    return do_execve(name, len, binary, size);
}
```

do_execve调用load_icode，加载文件

```c
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
    ...
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    ...
}
```

加载完毕，返回至__alltraps的末尾，执行__trapret后的内容，直到sret，退出内核态，回到用户态，执行加载的文件。

```c
.globl __trapret
__trapret:
    RESTORE_ALL
    # return from supervisor call
    sret
```

## 五、load_icode

```
static int
load_icode(unsigned char *binary, size_t size) {
    if (current->mm != NULL) {
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            // continue ;
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U | PTE_V;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        // modify the perm bits here for RISC-V
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC) perm |= PTE_X;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    /* LAB5:2213034
     * should set tf->gpr.sp, tf->epc, tf->status
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf->gpr.sp should be user stack top (the value of sp)
     *          tf->epc should be entry point of user program (the value of sepc)
     *          tf->status should be appropriate for user program (the value of sstatus)
     *          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
     */
    tf->gpr.sp = USTACKTOP;
    tf->epc = elf->e_entry; //修改epc，sret返回地址发生变化，返回执行exit.c函数，其中执行退出，调用sys_exit
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);

    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}
```

主要目的:将用户程序加载到当前进程的地址空间中，并准备其运行环境

`binary`：指向程序的 ELF 格式二进制文件的内容。

`size`：`binary` 的大小。

### (1)创建进程的内存管理结构

调用 `mm_create` 创建一个新的 `mm_struct`，用于管理进程的虚拟内存空间。

```
struct mm_struct *
mm_create(void) {
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));

    if (mm != NULL) {
        list_init(&(mm->mmap_list));
        mm->mmap_cache = NULL;
        mm->pgdir = NULL;
        mm->map_count = 0;

        if (swap_init_ok) swap_init_mm(mm);
        else mm->sm_priv = NULL;
        
        set_mm_count(mm, 0);
        lock_init(&(mm->mm_lock));
    }    
    return mm;
}
```

**为进程分配内存管理结构**：`mm_struct` 是进程内存管理的核心数据结构，维护了页表、虚拟内存区域等信息。

**初始化关键字段**：包括 VMA 链表、页表指针、锁等，确保结构体在使用前的正确性。

**支持交换功能**：通过 `swap_init_mm` 处理与交换相关的初始化。

**并发保护**：设置锁保护内存管理数据结构

### (2)设置页目录表

调用 `setup_pgdir` 函数，创建页目录表（PDT）并将其地址存储到 `mm->pgdir`

```
static int
setup_pgdir(struct mm_struct *mm) {
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
        return -E_NO_MEM;
    }
    pde_t *pgdir = page2kva(page);
    memcpy(pgdir, boot_pgdir, PGSIZE);

    mm->pgdir = pgdir;
    return 0;
}
```

**分配页目录**：通过 `alloc_page` 为进程分配一页内存，用于存储页目录。

**初始化页目录**：复制内核模板页目录 `boot_pgdir`(ffffffffc020b000) 的内容，保证基本的内核地址映射。

**关联到进程**：将页目录绑定到当前进程的 `mm_struct`。

**返回状态**：若内存分配成功且初始化完成，返回 `0`；否则返回错误码。

### (3)将 ELF 文件中的程序段（TEXT/DATA 和 BSS）加载到内存

> **TEXT**：存储指令（代码段）。
>
> **DATA**：存储已初始化的全局/静态变量。
>
> **BSS**：存储未初始化的全局/静态变量（初始值为 0）。

#### (3.1) 获取 ELF 文件头

 `binary` 解释为 ELF 文件头 `elfhdr`,`elfhdr` 包含了整个 ELF 文件的基本信息，如魔数、入口地址、程序段偏移等

```
/* file header */
struct elfhdr {
    uint32_t e_magic;     // must equal ELF_MAGIC
    uint8_t e_elf[12];
    uint16_t e_type;      // 1=relocatable, 2=executable, 3=shared object, 4=core image
    uint16_t e_machine;   // 3=x86, 4=68K, etc.
    uint32_t e_version;   // file version, always 1
    uint64_t e_entry;     // entry point if executable
    uint64_t e_phoff;     // file position of program header or 0
    uint64_t e_shoff;     // file position of section header or 0
    uint32_t e_flags;     // architecture-specific flags, usually 0
    uint16_t e_ehsize;    // size of this elf header
    uint16_t e_phentsize; // size of an entry in program header
    uint16_t e_phnum;     // number of entries in program header or 0
    uint16_t e_shentsize; // size of an entry in section header
    uint16_t e_shnum;     // number of entries in section header or 0
    uint16_t e_shstrndx;  // section number that contains section name strings
};
```

e_magic：ELF 文件的魔数，用于标识该文件是否为 ELF 格式

 e_elf[12]：用于存储 ELF 文件的标识信息，包含版本和字节序等重要信息。

e_type：ELF 文件的类型

> `1`：可重定位文件（如 `.o` 文件）。
>
> `2`：可执行文件（如程序）。
>
> `3`：共享对象（如动态链接库 `lib.so`）。
>
> `4`：核心转储文件（程序崩溃时产生的文件

e_machine：目标体系结构

> `3`：x86 架构。
>
> `62`：x86-64 架构。
>
> `4`：68K 架构。

e_version：文件的版本

e_entry：程序入口点的虚拟地址

e_phoff：程序头的文件偏移

e_shoff：节头的文件偏移，节头用于描述文件中各个节的详细信息，节可以是数据段、符号表、调试信息等。

e_flags：架构相关的标志

 e_ehsize：ELF 文件头的大小

e_phentsize：每个程序头的大小

e_phnum：程序头的数量。

e_shentsize：每个节头的大小。

e_shnum：节头的数量

e_shstrndx：节头字符串表的索引

#### (3.2) 获取程序段头表

通过 `elf->e_phoff` 获取程序段表的起始地址。

> `p_type`：段类型（如是否可加载）。
>
> `p_va`：段的虚拟地址。
>
> `p_offset`：段在文件中的偏移。
>
> `p_filesz`：段在文件中的大小。
>
> `p_memsz`：段在内存中的大小（可能大于 `p_filesz`，用于支持 BSS 部分

#### (3.3) 检查 ELF 文件合法性

确保 ELF 文件头中 `e_magic` 符合预期

#### (3.4) 遍历程序段表

遍历所有段，只处理 `p_type` 为 `ELF_PT_LOAD`（可加载）的段。

#### (3.5) 设置段的内存映射

调用 `mm_map` 为段的虚拟地址范围分配对应的虚拟内存区域（VMA）

根据段的权限标志（`ph->p_flags`）设置内存访问权限：

- `ELF_PF_R`：可读，映射为 `VM_READ`。
- `ELF_PF_W`：可写，映射为 `VM_WRITE`。
- `ELF_PF_X`：可执行，映射为 `VM_EXEC`

#### (3.6.1) 加载 TEXT/DATA 部分

从 `binary` 中将段的内容拷贝到对应的虚拟地址：

- 通过 `pgdir_alloc_page` 分配物理页面并建立虚拟地址到物理地址的映射。
- 使用 `memcpy` 将段的数据（`p_offset` 开始的 `p_filesz` 大小内容）拷贝到内存。

#### (3.6.2) 初始化 BSS 部分

如果 `p_memsz > p_filesz`，表示段中存在未初始化的数据部分（BSS）。

这些额外的内存区域需要初始化为 0。

- 通过 `memset` 实现清零。

### （4）为用户进程构建用户栈（stack）内存

目的是为用户进程分配并初始化用户栈的内存。首先，它为栈分配虚拟内存区域，然后通过调用 `pgdir_alloc_page` 为栈的每个页面分配物理内存。通过这些操作，用户进程的栈就可以正常使用。

`mm_map` 函数被用来为用户进程分配栈内存。它会将栈的虚拟地址空间 `[USTACKTOP - USTACKSIZE, USTACKTOP)` 映射到物理内存中。

### （5）操作进程的内存管理结构以及相关的寄存器

目的是为当前进程配置其内存管理信息。它增加内存管理结构的引用计数，设置当前进程的 `mm`（内存管理结构），并通过将页目录的物理地址加载到 CR3 寄存器中来使 CPU 知道当前进程的页表位置。这些操作确保进程能够正确访问其虚拟内存，并将正确的页表加载到硬件中

### （6）设置一个合适的 `trapframe`

目的是设置一个新的 `trapframe`，使得用户程序能够正确地从内核模式返回到用户模式并开始执行。通过设置 `sp`（栈指针）、`epc`（程序计数器）和 `status`（状态寄存器），CPU 能够正确地切换到用户程序，并执行用户程序的入口点。

tf->gpr.sp = USTACKTOP;
设置用户栈顶地址（USTACKTOP）。在 trapframe 中，gpr.sp 是保存堆栈指针（sp）的寄存器。USTACKTOP 表示用户进程的栈顶地址，通常是在用户空间分配的栈空间的最高地址。

tf->epc = elf->e_entry;
设置 epc（程序计数器），也就是用户程序的入口点（elf->e_entry）。epc 寄存器指向用户程序的起始位置，程序从这里开始执行。在 RISC-V 中，当从内核模式返回到用户模式时，CPU 会跳转到 epc 指定的地址。

tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
设置 status 寄存器。status 寄存器包含了当前处理器的状态，比如是否处于内核模式或用户模式，以及中断使能状态。SSTATUS_SPP 和 SSTATUS_SPIE 是用来标记当前状态的标志位。
SSTATUS_SPP（Supervisor Previous Privilege）表示之前的特权级别。内核模式时为 1，用户模式时为 0。
SSTATUS_SPIE（Supervisor Previous Interrupt Enable）表示之前的中断使能状态。
通过将 SSTATUS_SPP 和 SSTATUS_SPIE 位清零，确保在用户程序开始执行时，系统状态处于正确的用户模式状态。

## 六、do_fork

### 1. **初始化和检查最大进程数**

```
int ret = -E_NO_FREE_PROC;
struct proc_struct *proc;
if (nr_process >= MAX_PROCESS) {
    goto fork_out;
}
```

- `ret` 初始值为 `-E_NO_FREE_PROC`，表示没有可用的进程空间。
- `nr_process` 是当前系统中进程的数量，`MAX_PROCESS` 是系统中最大允许的进程数。如果当前进程数已达到最大值，直接跳到 `fork_out`，返回 `-E_NO_FREE_PROC`。

### 2. **分配进程结构体**

```
if ((proc = alloc_proc()) == NULL) {
    goto fork_out;
}
```

- `alloc_proc()` 函数为新进程分配一个进程控制块（`proc_struct`）。如果分配失败（返回 `NULL`），跳到 `fork_out` 返回失败。

### 3. **设置新进程的父进程**

```
proc->parent = current;
assert(current->wait_state == 0);
```

- 将新进程的父进程指针设置为当前进程（即调用 `fork` 的进程）。
- `assert(current->wait_state == 0)` 检查当前进程的 `wait_state` 是否为 0，确保当前进程没有处于等待子进程状态。

### 4. **分配内核栈**

```
if ((setup_kstack(proc)) == -E_NO_MEM) {
    goto bad_fork_cleanup_kstack;
}
```

- `setup_kstack(proc)` 为新进程分配一个内核栈。如果分配失败（返回 `-E_NO_MEM`），跳到 `bad_fork_cleanup_kstack` 进行清理。

### 5. **复制内存管理结构**

```
if(copy_mm(clone_flags, proc) != 0) {
    goto bad_fork_cleanup_proc;
}
```

- `copy_mm(clone_flags, proc)` 复制父进程的内存管理结构。`clone_flags` 决定了复制的策略。如果复制失败，跳到 `bad_fork_cleanup_proc` 进行清理。

### 6. **复制线程信息**

```
copy_thread(proc, stack, tf);
```

- `copy_thread` 用于设置新进程的线程信息。它会设置进程的栈（`stack`）和陷阱帧（`tf`，即进程上下文信息）。

### 7. **处理进程的 PID 和插入哈希表**

```
bool intr_flag;
local_intr_save(intr_flag);
{
    proc->pid = get_pid();
    hash_proc(proc);
    set_links(proc);
}
local_intr_restore(intr_flag);
```

- `get_pid()` 为新进程分配一个唯一的进程 ID（PID）。
- `hash_proc(proc)` 将新进程插入到进程哈希表中。
- `set_links(proc)` 设置新进程的相关链接信息，例如父子进程关系等。
- `local_intr_save` 和 `local_intr_restore` 用于保存和恢复中断状态，确保在修改进程结构时不被中断打断。

### 8. **将进程设为可运行**

```
wakeup_proc(proc);
```

- `wakeup_proc(proc)` 设置新进程为可运行状态，将其放入就绪队列。

### 9. **返回新进程的 PID**

```
ret = proc->pid;
```

- 最后，将新进程的 PID 存入 `ret` 并返回，表示新进程的创建成功。

### 10. **错误清理**

```
fork_out:
return ret;

bad_fork_cleanup_kstack:
put_kstack(proc);

bad_fork_cleanup_proc:
kfree(proc);
goto fork_out;
```

- 如果在任何步骤发生错误，将跳到 

	```
	bad_fork_cleanup_kstack
	```

	 或 

	```
	bad_fork_cleanup_proc
	```

	 标签进行清理。

	- `put_kstack(proc)` 释放内核栈。
	- `kfree(proc)` 释放进程控制块。

- 最后跳转到 `fork_out` 返回错误代码 `ret`。

## 七、do_exit

`do_exit` 处理了进程退出的所有步骤，包括：

1. 确保不是空闲进程（`idleproc`）或初始化进程（`initproc`）退出。
2. 释放与当前进程相关的内存管理结构（如页目录、虚拟内存映射等）。
3. 设置进程为 `PROC_ZOMBIE` 状态，表示进程已结束但仍等待父进程处理。
4. 处理父子进程之间的关系，确保父进程能正确收养并处理子进程退出状态。
5. 调用调度器切换到其他进程执行。

### 1.处理特殊情况

```
if (current == idleproc) {
    panic("idleproc exit.\n");
}
if (current == initproc) {
    panic("initproc exit.\n");
}
```

- **`idleproc`**：是系统的空闲进程，通常在没有其他进程运行时由操作系统调度。如果这个进程退出了，表示系统发生了不可预见的错误，因此会触发一个 panic。
- **`initproc`**：是系统的初始化进程，通常是第一个创建的进程，负责启动其他进程。如果这个进程退出了，系统将无法继续运行，操作系统也会触发 panic。

### 2. **释放内存管理结构（`mm`）**

```
struct mm_struct *mm = current->mm;
if (mm != NULL) {
    lcr3(boot_cr3);
    if (mm_count_dec(mm) == 0) {
        exit_mmap(mm);
        put_pgdir(mm);
        mm_destroy(mm);
    }
    current->mm = NULL;
}
```

- `mm_struct` 是一个表示进程内存管理的结构体，包含了进程的虚拟内存信息。

- **`lcr3(boot_cr3)`**：切换到启动时的页目录（通常是内核页目录）。

- `mm_count_dec(mm)`

	：减少进程的内存引用计数。如果引用计数变为 0，表示没有其他进程使用该内存结构，需要清理和释放资源：

	- `exit_mmap(mm)`：解除与内存映射相关的资源。
	- `put_pgdir(mm)`：释放进程的页目录。
	- `mm_destroy(mm)`：销毁内存管理结构。

- 最后，将 `current->mm` 设置为 `NULL`，表示当前进程的内存管理已被销毁。

### 3. **设置进程状态为 `PROC_ZOMBIE`**

```
current->state = PROC_ZOMBIE;
current->exit_code = error_code;
```

- 将当前进程的状态设置为 `PROC_ZOMBIE`，意味着进程已经结束，但父进程尚未获取其退出状态。
- `current->exit_code = error_code`：将退出代码（错误码）保存，父进程稍后可以通过 `wait()` 获取。

### 4. **处理进程父子关系**

```
bool intr_flag;
struct proc_struct *proc;
local_intr_save(intr_flag);
{
    proc = current->parent;
    if (proc->wait_state == WT_CHILD) {
        wakeup_proc(proc);
    }
    while (current->cptr != NULL) {
        proc = current->cptr;
        current->cptr = proc->optr;

        proc->yptr = NULL;
        if ((proc->optr = initproc->cptr) != NULL) {
            initproc->cptr->yptr = proc;
        }
        proc->parent = initproc;
        initproc->cptr = proc;
        if (proc->state == PROC_ZOMBIE) {
            if (initproc->wait_state == WT_CHILD) {
                wakeup_proc(initproc);
            }
        }
    }
}
local_intr_restore(intr_flag);
```

- **父进程**：首先，获取当前进程的父进程（`current->parent`）。如果父进程处于等待子进程状态（`WT_CHILD`），则唤醒父进程，表示它可以继续执行。

- 子进程处理：

	- 如果当前进程有子进程（`current->cptr != NULL`），将子进程移交给 `initproc`（初始化进程），因为 `initproc` 负责收养所有孤儿进程。
	- `cptr` 和 `optr` 是进程的子进程和兄弟进程的指针，`yptr` 是指向父进程的指针。将子进程从当前进程的子进程链表中移除，添加到 `initproc` 的子进程链表中。
	- 如果子进程已经处于 `PROC_ZOMBIE` 状态（表示它已经退出但父进程还没有处理），并且 `initproc` 处于 `WT_CHILD` 状态，那么唤醒 `initproc`，使其可以收养子进程并处理它的退出状态。

### 5. **调度与进程退出**

```
schedule();
panic("do_exit will not return!! %d.\n", current->pid);
```

- `schedule()`：调用调度器，选择下一个可运行的进程执行。在 `do_exit` 中调用 `schedule`，意味着当前进程已经完全退出，调度器会选择一个新的进程运行。
- `panic("do_exit will not return!! %d.\n", current->pid);`：这行代码永远不会被执行。`schedule()` 会导致进程调度，当前进程退出并交给下一个进程执行，因此这行代码是一个 "不会返回" 的警告。



## 八、do_execve

`do_execve` 函数的主要任务是实现程序的替换，它完成以下操作：

1. 检查进程是否可以访问传入的程序名。
2. 处理并保存程序名。
3. 清理当前进程的内存管理结构，释放旧的地址空间。
4. 加载新的程序二进制文件（`icode`）。
5. 设置当前进程的名称为新的程序名。
6. 如果加载新程序成功，则返回 0；如果失败，则退出当前进程并报告错误

### 1. **用户内存检查**

```
if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
    return -E_INVAL;
}
```

- `user_mem_check` 用来验证进程是否有权限访问传入的程序名 `name` 指定的内存区域。如果不允许访问（例如，地址不在进程的有效内存区域内），则返回 `-E_INVAL`（无效参数）。

### 2. **处理进程名**

```
if (len > PROC_NAME_LEN) { 
    len = PROC_NAME_LEN;
}

char local_name[PROC_NAME_LEN + 1];
memset(local_name, 0, sizeof(local_name));
memcpy(local_name, name, len);
```

- `len` 是程序名的长度，进程名有上限，`PROC_NAME_LEN` 定义了最大长度。如果 `len` 大于 `PROC_NAME_LEN`，则将其截断为最大长度。
- 通过 `memcpy` 将程序名拷贝到一个本地变量 `local_name` 中，并确保该字符串以 `'\0'` 结束。

### 3. **处理当前进程的内存管理**

```
if (mm != NULL) {
    cputs("mm != NULL");
    lcr3(boot_cr3);
    if (mm_count_dec(mm) == 0) {
        exit_mmap(mm);
        put_pgdir(mm);
        mm_destroy(mm);
    }
    current->mm = NULL;
}
```

- **`mm != NULL`**：检查当前进程是否有内存管理结构 `mm_struct`。如果有，表示当前进程有自己的虚拟内存空间。

- `lcr3(boot_cr3)`：将 CR3 寄存器加载为 `boot_cr3`，即切换回内核的页目录。这样做是为了清理进程的虚拟地址空间，避免在执行新程序时干扰旧的内存映射。

- 释放当前进程的内存管理资源

	：

	- `mm_count_dec(mm)`：减少内存管理结构的引用计数。如果计数为 0，表示没有其他进程使用该内存结构，因此可以进行清理。
	- `exit_mmap(mm)`：清除与内存映射相关的资源。
	- `put_pgdir(mm)`：释放当前进程的页目录。
	- `mm_destroy(mm)`：销毁当前进程的内存管理结构。

- `current->mm = NULL`：将当前进程的 `mm` 设置为 `NULL`，表示当前进程没有内存管理结构。

### 4. **加载新程序的执行代码**

```
int ret;
if ((ret = load_icode(binary, size)) != 0) {
    goto execve_exit;
}
```

- 调用 `load_icode(binary, size)` 来加载新的程序到当前进程的用户态虚拟空间。`binary` 是程序的二进制代码，`size` 是其大小。如果加载失败（`ret != 0`），则跳转到 `execve_exit` 标签进行清理。

### 5. **设置进程名**

```
set_proc_name(current, local_name);
```

- 设置当前进程的名称为 `local_name`，即执行的程序名。

### 6. **返回成功**

```
return 0;
```

- 如果成功执行 `load_icode` 和其他操作，返回 0，表示执行成功。

### 7. **错误处理**

```
do_exit(ret);
panic("already exit: %e.\n", ret);
```

- 如果 `load_icode` 加载程序失败，调用 `do_exit(ret)` 退出当前进程并传递错误代码。
- `panic` 用来处理无法恢复的错误情况，输出错误信息并停止系统执行

## 九、do_yield

```
int do_yield(void) {
    current->need_resched = 1;  // 设置当前进程的需要重新调度标志
    return 0;                    // 返回 0，表示成功
}

```

用于实现进程的**主动放弃 CPU（让出 CPU）**

## 十、do_wait

`do_wait` 是一个操作系统核心功能，实现父进程(当前进程)等待子进程退出的机制。它保证：

- 合法性检查。
- 高效资源回收。
- 与调度系统的良好集成。

### 1.**检查 `code_store` 的合法性**：

```
if (code_store != NULL) {
    if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
        return -E_INVAL;
    }
}
```

- 确保 `code_store` 指向的内存是合法的用户空间地址（写权限）。
- 若不合法，返回 `-E_INVAL`。

> user_mem_check    //检查从addr开始长为len的一段内存能否被用户态程序访问,可用返回1

### 2.**查找符合条件的子进程**：

```
if (pid != 0) {
    proc = find_proc(pid);
    if (proc != NULL && proc->parent == current) {
        ...
    }
} else {
    proc = current->cptr;
    for (; proc != NULL; proc = proc->optr) {
        ...
    }
}
```

- 如果 `pid != 0`，直接查找 `pid` 对应的子进程。
- 如果 `pid == 0`，遍历当前进程的所有子进程，寻找符合条件的。
- 如果找到 `PROC_ZOMBIE` 状态的子进程，跳转到 `found` 标签。

### 3.**等待子进程**：

```
if (haskid) {
    current->state = PROC_SLEEPING;
    current->wait_state = WT_CHILD;
    schedule();
    ...
    goto repeat;
}
```

- 如果当前有子进程但没有找到退出的子进程：
	- 将当前进程设置为 `PROC_SLEEPING` 状态。
	- 设置等待状态为 `WT_CHILD`。
	- 调度其他进程运行（`schedule()`），当前进程进入等待状态。
- 如果被唤醒后仍未找到目标，继续 `repeat` 检查。

### 4.**处理退出的子进程**：

```
if (proc == idleproc || proc == initproc) {
    panic("wait idleproc or initproc.\n");
}
if (code_store != NULL) {
    *code_store = proc->exit_code;
}
local_intr_save(intr_flag);
{
    unhash_proc(proc);
    remove_links(proc);
}
local_intr_restore(intr_flag);
put_kstack(proc);
kfree(proc);
```

- 检查目标子进程是否为 `idleproc` 或 `initproc`（这些特殊进程不允许被等待）。
- 若 `code_store` 非空，将退出码保存到用户空间。
- 禁用中断，安全地：
	- 从进程哈希表中移除子进程。
	- 断开与其他进程的关联（如父子关系）。
- 释放子进程的资源（如内核栈、结构体等）。

### 5.**处理无子进程的情况**：

 如果当前进程没有符合条件的子进程：

```
return -E_BAD_PROC;
```

## 十一、do_kill

是一个简单但关键的内核函数，用于标记进程退出，并处理可能的等待状态。它的核心目标是：

1. 找到目标进程并标记为退出。
2. 如果进程正在等待，唤醒它以终止操作。
3. 返回不同的错误码表示进程不存在或已经在退出。

### **1. 查找目标进程**

```
struct proc_struct *proc;
if ((proc = find_proc(pid)) != NULL) {
```

- 使用 `find_proc(pid)` 函数查找 `pid` 对应的进程结构体。
- 如果找不到，说明目标进程不存在，直接返回 `-E_INVAL`，表示参数无效。

------

### **2. 检查并设置退出标志**

```
if (!(proc->flags & PF_EXITING)) {
    proc->flags |= PF_EXITING;
```

- 检查目标进程的标志位 

	```
	flags
	```

	 是否包含 

	```
	PF_EXITING
	```

	：

	- `PF_EXITING` 通常是一个标志位，表示进程正在退出中。
	- 如果未设置此标志（`!(proc->flags & PF_EXITING)`），说明进程还未处于退出状态。

- 设置 `PF_EXITING` 标志，通知内核该进程即将退出。

------

### **3. 唤醒等待的进程**

```
if (proc->wait_state & WT_INTERRUPTED) {
    wakeup_proc(proc);
}
```

- 检查目标进程的等待状态 

	```
	wait_state
	```

	 是否包含 

	```
	WT_INTERRUPTED
	```

	：

	- `WT_INTERRUPTED` 表示进程因某种中断条件而在等待。

- 如果进程处于这种等待状态，需要通过 `wakeup_proc(proc)` 将其唤醒，通知进程它已经被杀死，进而终止操作。

------

### **4. 返回结果**

```
return 0;
```

- 如果上述操作成功完成，返回 `0`，表示操作成功。

### **5. 已经在退出的进程**

```
return -E_KILLED;
```

- 如果目标进程的 `PF_EXITING` 标志已经被设置，说明该进程已经进入退出状态，不能重复操作。
- 返回 `-E_KILLED`，表示目标进程已经被标记为终止。

### **6. 找不到进程**

```
return -E_INVAL;
```

- 如果 `find_proc(pid)` 返回 `NULL`，说明没有找到 `pid` 对应的进程。
- 返回 `-E_INVAL`，表示参数无效或进程不存在。

## 十二、kernel_execve

这个函数 `kernel_execve` 的作用是通过系统调用接口（`SYS_exec`）在内核中执行一个用户程序。它使用 RISC-V 汇编语言的 `ebreak` 指令触发异常来进行系统调用，从而执行用户程序

通过 `name` 和 `binary` 等信息构造用户程序加载请求。

使用 RISC-V 的系统调用机制，通过 `ebreak` 指令进入内核态。

内核异常处理程序解析系统调用号（`a7 = 10`），执行对应的 `SYS_exec` 系统调用逻辑。

内核完成用户程序加载后，返回结果给 `ret`。

将结果返回给调用者。

```
asm volatile(
    "li a0, %1\n"
    "lw a1, %2\n"
    "lw a2, %3\n"
    "lw a3, %4\n"
    "lw a4, %5\n"
    "li a7, 10\n"
    "ebreak\n"
    "sw a0, %0\n"
    : "=m"(ret)
    : "i"(SYS_exec), "m"(name), "m"(len), "m"(binary), "m"(size)
    : "memory");
```

**寄存器传递参数**：

- `a0` 到 `a4` 寄存器

	用于传递函数参数：

	- `a0`: 系统调用号（`SYS_exec`）。
	- `a1`: 用户程序的名称地址（`name`）。
	- `a2`: 用户程序名称的长度（`len`）。
	- `a3`: 用户程序二进制代码的地址（`binary`）。
	- `a4`: 用户程序二进制代码的大小（`size`）。

- **`a7` 寄存器**指定系统调用号，这里为 `10`，表示触发 `SYS_exec` 系统调用。

**触发系统调用**：

- **`ebreak` 指令**触发异常，进入内核的异常处理程序。
- 在异常处理程序中，根据 `a7` 的值（系统调用号）确定执行具体的系统调用逻辑。

**返回值保存**：

- 系统调用的结果通过 `a0` 寄存器返回。
- `sw a0, %0` 将返回值保存到 `ret` 中，供 C 代码使用。

**约束说明**：

- 输入约束：
	- `"i"(SYS_exec)`：将常量 `SYS_exec` 加载到 `a0`。
	- `"m"(name)`、`"m"(len)`、`"m"(binary)`、`"m"(size)`：将内存变量的值加载到相应的寄存器。
- 输出约束：
	- `"=m"(ret)`：将返回值写入到变量 `ret`。
- **`memory` 修饰符**：表示内存可能被修改，避免编译器优化导致问题

## 十三、系统调用

```
/* syscall number */
#define SYS_exit            1
#define SYS_fork            2
#define SYS_wait            3
#define SYS_exec            4
#define SYS_clone           5
#define SYS_yield           10
#define SYS_sleep           11
#define SYS_kill            12
#define SYS_gettime         17
#define SYS_getpid          18
#define SYS_brk             19
#define SYS_mmap            20
#define SYS_munmap          21
#define SYS_shmem           22
#define SYS_putc            30
#define SYS_pgdir           31
```

| 系统调用   | 功能描述                               | 实现方法                                            |
| ---------- | -------------------------------------- | --------------------------------------------------- |
| SYS_exit   | 进程退出                               | 调用 `do_exit`                                      |
| SYS_fork   | 创建子进程，并复制父进程的内存管理信息 | 调用 `do_fork` 和 `wakeup_proc`                     |
| SYS_wait   | 等待某个进程结束                       | 调用 `do_wait`                                      |
| SYS_exec   | 在进程中加载并执行一个新程序           | 刷新内存管理(mm)并加载程序                          |
| SYS_clone  | 创建子线程（共享父进程的内存）         | 调用 `do_fork` 和 `wakeup_proc`                     |
| SYS_yield  | 进程主动让出CPU，触发重新调度          | 设置 `proc->need_sched=1`，调度器重新调度           |
| SYS_sleep  | 进程进入睡眠状态                       | 调用 `do_sleep`                                     |
| SYS_kill   | 杀死进程                               | 设置标志位 `PF_EXITING` 并调用 `wakeup_proc` 等处理 |
| SYS_getpid | 获取当前进程的PID                      | 返回 `proc->pid`                                    |

## 十四、kernel_execve的宏调用

这些宏通过链接器生成的符号或动态参数，调用底层 `kernel_execve` 函数，实现了从内核态加载并执行用户程序的功能。设计上的分层封装既确保了灵活性，又简化了用户调用，适合操作系统内核中的用户程序加载场景。

```
#define __KERNEL_EXECVE(name, binary, size) ({                          \
            cprintf("kernel_execve: pid = %d, name = \"%s\".\n",        \
                    current->pid, name);                                \
            kernel_execve(name, binary, (size_t)(size));                \
        })

#define KERNEL_EXECVE(x) ({                                             \
            extern unsigned char _binary_obj___user_##x##_out_start[],  \
                _binary_obj___user_##x##_out_size[];                    \
            __KERNEL_EXECVE(#x, _binary_obj___user_##x##_out_start,     \
                            _binary_obj___user_##x##_out_size);         \
        })
// _binary_obj___user_##x##_out_start[]：x代码行执行起始位置
//  _binary_obj___user_##x##_out_size[]：x代码行大小
// 此处是执行了 __KERNEL_EXECVE(exit, _binary_obj___user_exit_out_start,  _binary_obj___user_exit_out_size);

#define __KERNEL_EXECVE2(x, xstart, xsize) ({                           \
            extern unsigned char xstart[], xsize[];                     \
            __KERNEL_EXECVE(#x, xstart, (size_t)xsize);                 \
        })

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)
```

### __KERNEL_EXECVE

打印当前进程的 PID 和要执行的用户程序名称。

调用 `kernel_execve` 函数加载和执行用户程序

### KERNEL_EXECVE

这是一个高层封装宏，进一步简化对 `kernel_execve` 的调用。

它利用链接器生成的符号（`_binary_obj___user_##x##_out_start` 和 `_binary_obj___user_##x##_out_size`）指定用户程序的位置和大小

### __KERNEL_EXECVE2

这是 `__KERNEL_EXECVE` 的变体，允许直接传递二进制起始地址（`xstart`）和大小（`xsize`）。

适用于动态指定用户程序起始地址和大小的场景

### KERNEL_EXECVE2

高层封装宏，用于调用 `__KERNEL_EXECVE2`。

提供更灵活的方式执行用户程序，用户可以手动指定起始地址和大小，而无需依赖特定的链接符号。

## 十五、user_main

通过调用 `KERNEL_EXECVE` 宏加载和执行一个用户程序。



## 十六、vmm.c

### 1、mm_map

```
int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
    if (!USER_ACCESS(start, end)) {
        return -E_INVAL;
    }

    assert(mm != NULL);

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
        goto out;
    }
    ret = -E_NO_MEM;

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;

out:
    return ret;
}
```

这个函数的目的是将一个内存区域（由 `addr` 和 `len` 指定）映射到当前进程的虚拟地址空间。具体步骤包括：

1. 检查地址是否合法并在页边界对齐。
2. 查找是否已有相应的虚拟内存区域（VMA）存在。
3. 如果没有，则创建一个新的 VMA，并将其插入到进程的内存管理结构中。
4. 最后，如果有必要，返回新创建的 VMA 信息

### 2、dup_mmap

```
int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    while ((le = list_prev(le)) != list) {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
}

```

`dup_mmap` 是一个用于复制进程虚拟内存映射的函数，它通过复制源进程的内存区域信息（VMA）和页表内容，实现在目标进程中映射相同的内存区域。这种操作通常出现在进程创建（如 `fork`）或内存共享场景中，确保两个进程可以访问相同的物理内存。

1. 复制源进程 `from` 的虚拟内存映射（VMA）到目标进程 `to`。

2. 遍历源进程的内存映射列表，逐个复制 VMA。

3. 创建新的 VMA 并插入目标进程的内存映射列表。

4. 将源进程的页表内容复制到目标进程的页表中

### 3、exit_mmap

```
void
exit_mmap(struct mm_struct *mm) {
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end); // 大概是移除页表引用
    }
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end); // 大概是释放页表页面
    }
}
```

**`exit_mmap`** 函数负责在进程退出时清理其所有的内存映射。具体来说，它遍历进程的虚拟内存区域链表，对每个 VMA 执行两步操作：

1. **取消页表引用**：解除虚拟地址到物理地址的映射，使得进程不再能够访问这些内存区域。
2. **释放物理内存页**：释放与该虚拟内存区域关联的物理内存页，确保内存资源得到回收。

## 十七、trap.c

**`exception_handler`**：捕获用户态的 `ecall` 异常，跳转到系统调用处理函数。

**`syscall.c`**：定义了具体的系统调用实现，每个系统调用对应一个处理函数。

**`syscall()`**：根据系统调用编号调用对应的处理函数，进行具体的系统调用操作。

**系统调用函数指针数组**：通过数组索引实现系统调用的调度，使得系统能够根据用户请求执行相应的内核操作。

## 十八、user_mem_check

`user_mem_check` 函数用于检查用户程序是否能合法访问指定的内存区域。其核心功能包括：

- 检查内存区域是否在用户空间范围内。
- 检查该内存区域是否存在，并且是否具有足够的权限（读或写）。
- 如果是栈区域，还会进行额外的检查，确保栈的访问不越界

如果 `mm` 为 `NULL`（表示不在用户程序的上下文中），则调用 `KERN_ACCESS` 来检查该内存区域是否属于内核空间。如果 `KERN_ACCESS` 返回允许访问，则返回 `1`，否则返回 `0`

## 十九、trapentry.S

这段代码通过 `SAVE_ALL` 和 `RESTORE_ALL` 两个宏来保存和恢复异常发生时的上下文。它根据当前是用户态还是内核态，决定如何正确保存和恢复栈指针，并保存和恢复寄存器、异常信息等。这是实现 RISC-V 异常处理的关键部分，确保在发生中断或异常时，系统能够正确地保存现场并在处理完后恢复执行。

**`__alltraps`**： 这是异常处理的入口点，首先调用 `SAVE_ALL` 保存当前的寄存器状态，然后跳转到 `trap` 函数处理具体的异常。

**`__trapret`**： 这是异常处理的返回点，在异常处理完成后，通过调用 `RESTORE_ALL` 恢复所有寄存器和栈指针，并通过 `sret` 返回到异常发生之前的执行点。

**`forkrets`**： 这是在 `fork` 系统调用中使用的入口点，将新的进程的栈指针设置为该进程的 `trapframe`，然后跳转到 `__trapret` 恢复栈指针和寄存器。