.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1 // s1是线程函数参数
	jalr s0 // s0是线程函数地址

	jal do_exit
