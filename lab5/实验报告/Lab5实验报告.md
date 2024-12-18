# Lab5实验报告

## 一、实验目的

1. 了解第一个用户进程创建过程
2. 了解系统调用框架的实现机制
3. 了解ucore如何实现系统调用sys_fork/sys_exec/sys_exit/sys_wait来进行进程管理

## 二、实验内容

### 1、练习一

```
    tf->gpr.sp = USTACKTOP;
    tf->epc = elf->e_entry; 
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
```

将用户态栈指针初始化为用户栈的顶部位置，确保用户程序启动时拥有正确的栈空间

将程序计数器设置为用户程序的入口地址是为了确保程序从正确的起始位置运行

配置状态寄存器，使其切换到用户态运行，同时配置正确的中断状态

> **`SSTATUS_SPP`**: Supervisor Previous Privilege Level，表示之前的特权级。如果清除该位，则表示切换到用户态。
>
> **`SSTATUS_SPIE`**: Supervisor Previous Interrupt Enable，表示之前是否启用了中断。如果清除该位，表示进入用户态时关闭中断。

**问题**：请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

**答：**

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

### 2、练习二

```
void* src_kvaddr = page2kva(page); 
void* dst_kvaddr = page2kva(npage); 
memcpy(dst_kvaddr, src_kvaddr, PGSIZE); 
ret = page_insert(to, npage, start, perm); 
```

获取源页和目标页的内核虚拟地址。

复制源页内容到目标页。

将目标页插入到目标地址空间的页表中，完成虚拟地址到目标页的映射。

> **`to`**: 表示目标地址空间，通常是一个页目录或页表的抽象结构（如 `struct mm_struct` 或 `pmap_t`）。
>
> **`npage`**: 表示要插入的物理页（新页）。
>
> **`start`**: 表示虚拟地址，目标页将在该虚拟地址上被映射。
>
> **`perm`**: 表示权限，例如读、写、执行等权限位（如 `PTE_U`、`PTE_W`）

**问题**：如何设计实现`Copy on Write`机制？给出概要设计，鼓励给出详细设计。

**答：**Copy on Write是一种优化技术，用于在多个进程或线程共享同一资源(如内存块)时减少内存复制的开销。它的基本思想是，当多个进程或线程共享同一资源时，在有进程或线程尝试修改该资源时才会进行实际的复制操作，否则它们会共享同一个资源。以下是cow机制的概要设计:

- 内存块资源初始化时，给每个内存块一个引用计数器，记录当前有多少个进程或线程在使用它。当另一个进程或线程希望共享该内存块资源时，可以简单地将指针或引用指向该资源
- 在内存块进行资源分配时，如果有多个进程或线程需要共享一个内存块，该内存块的引用计数会增加，但此时它们实际上共享同一个内存块，而不是分别拷贝一份。
- 当任何一个进程或线程尝试修改共享的内存块时，就会发生写保护错误，并触发一个异常。异常处理程序会调用操作系统内部函数来执行以下操作：
	a. 其需要为触发异常的进程或线程分配一个新的专用内存块，与共享的内存块拷贝一份相同大小的数据。
	b. 修改进程或线程的虚拟地址空间，将它们的虚拟地址指向新的专用内存块，这样它们将不再共享原来的内存块。
	c. 将新分配的内存块的引用计数器设置为1，表示只有一个进程或线程使用这个内存块。
- 而其他进程则会继续使用原来的内存块，而不知道出现了写保护错误，它们的地址映射仍然指向共享的原始内存块。
- 当有进程或线程退出时，或者不再需要使用某个共享的内存块时，它们的引用计数器会减1。当引用计数器变为0时，内存块就可以被销毁并释放。

### 3、练习三

**问题1：**请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？

**答：** 

 **fork执行流程：**

- **用户态**：
	1. 用户进程调用 `fork`。
	2. 触发从用户态到内核态的上下文切换。
- **内核态**：
	1. **分配资源**：内核分配一个新的 `proc_struct` 来描述子进程，并初始化相关资源（如内存空间、文件描述符等）。
	2. **复制父进程**：根据需要（如 `CLONE_VM` 等标志），内核决定是复制父进程的内存（`copy_mm`）还是共享父进程的内存。
	3. **创建子进程的内核栈**：为子进程分配并初始化内核栈（`setup_kstack`）。
	4. **设置子进程的状态和上下文**：将子进程的 `trapframe` 和上下文信息初始化（`copy_thread`）。
	5. **唤醒子进程**：将子进程的状态设置为 `PROC_RUNNABLE`，并唤醒它准备调度（`wakeup_proc`）。
	6. 内核通过 `ret` 返回子进程的 PID，`fork` 在父进程中返回子进程的 PID，在子进程中返回 `0`。
- **用户态**：
	- 父进程接收到子进程的 PID，子进程接收到 `0`，`fork` 系统调用结束。
	- 用户进程根据 `fork` 的返回值进行后续处理。



**exec执行流程：**

- **用户态**：
	1. 用户进程调用 `execve`，并传递新程序的路径、参数、环境变量等。
	2. 触发系统调用，进程从用户态切换到内核态。
- **内核态**：
	1. **检查权限**：内核检查程序路径是否有效，权限是否足够。
	2. **释放当前资源**：如果进程有内存（`mm_struct`），内核会释放当前进程的地址空间，包括页表和内存映射（`exit_mmap`）。
	3. **加载新程序**：内核通过 `load_icode` 加载新程序的二进制代码到内存。
	4. **设置新程序的内存**：为新程序配置内存空间（`setup_new_mm`），并设置新的用户堆栈。
	5. **重设进程的状态**：清除进程的旧信息（如文件描述符），并加载新程序的执行信息。
	6. 内核将控制权返回给用户程序，新程序开始执行。
- **用户态**：
	- `execve` 系统调用完成后，原先的程序被新程序替换，用户态开始执行新的程序代码。



 **wait执行流程：**

- **用户态**：
	1. 父进程调用 `wait` 等待子进程退出。
	2. 触发系统调用，进程从用户态切换到内核态。
- **内核态**：
	1. **查找子进程**：内核检查父进程是否有子进程，若没有，返回错误（`E_BAD_PROC`）。
	2. **等待子进程退出**：如果子进程没有退出，父进程会被挂起，进入睡眠状态（`PROC_SLEEPING`），等待子进程变为 `PROC_ZOMBIE`。
	3. **唤醒父进程**：当子进程退出并变为僵尸进程（`PROC_ZOMBIE`）时，父进程被唤醒，收集子进程的退出码，并清理子进程资源。
	4. **返回退出码**：子进程退出码通过 `code_store` 返回给父进程。
- **用户态**：
	- 父进程从内核态返回，获取子进程的退出状态，并继续执行。



 **exit执行流程：**

- **用户态**：
	1. 用户进程调用 `exit`，传递退出码。
	2. 触发系统调用，进程从用户态切换到内核态。
- **内核态**：
	1. **释放资源**：内核释放当前进程的内存（`mm_struct`）、文件描述符等资源。
	2. **标记进程为僵尸进程**：将进程状态设为 `PROC_ZOMBIE`，并记录退出码。
	3. **通知父进程**：如果父进程在等待子进程（`WT_CHILD`），唤醒父进程。
	4. **重新分配子进程**：将当前进程的子进程分配给 `initproc`，确保孤儿进程得到处理。
	5. **调度切换**：调用 `schedule` 切换到其他进程。
- **用户态**：
	- 当前进程不会再返回，其他进程开始执行。



fork,exec,wait和exit中封装了类似于sys_fork这样的系统调用函数，这四个函数操作都是在用户态完成的，而当用户态程序触发ebreak或者ecall中断时，会触发trap从而进入内核态，从而发起syscall系统调用，然后会对系统调用的函数进行分发，然后调用sys_fork等内核态运行的操作。

具体来说，用户态调用fork等函数，并触发trap进入内核态，根据寄存器参数分发相应的函数指针，触发系统调用的相关函数，类似于sys_fork等，调用完成后内核态通过sret返回用户态，实现交错执行。

在这些系统调用的执行流程中，用户态和内核态之间的切换是关键的。当用户程序执行系统调用时，会触发从用户态切换到内核态，让操作系统执行相关的内核代码。在系统调用完成后，操作系统会将控制权切回到用户态，让用户程序继续执行。

**问题2：**请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）

**答：**

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

## 三、扩展练习Challenge

### 1、拓展练习一

**问题：**实现 Copy on Write （COW）机制

**答：**未实现

### 2、拓展练习二

**问题：**说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？

**答：**

（1）用户进程是在我们执行user_main的加载时，会调用到kernel_execve函数，通过系统调用syscall调用do_execve函数，该函数中会调用load_icode函数，其中完成了用户进程到内存的加载。load_icode函数的主要工作就是给用户进程建立一个能够让用户进程正常运行的用户环境。

（2）uCore 的程序加载机制较为简化，不涉及共享库、动态链接、按需加载等复杂操作。它侧重于展示操作系统的基本功能，而没有像 Linux、Windows 等操作系统那样复杂的虚拟内存和进程管理功能。

## 四、实验中重点知识点

具体见知识点报告