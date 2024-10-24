#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>
#include <stdio.h>

/* In the first fit algorithm, the allocator keeps a list of free blocks (known as the free list) and,
   on receiving a request for memory, scans along the list for the first block that is large enough to
   satisfy the request. If the chosen block is significantly larger than that requested, then it is
   usually split, and the remainder added to the list as another free block.
   Please see Page 196~198, Section 8.2 of Yan Wei Min's chinese book "Data Structure -- C programming language"
*/
// you should rewrite functions: default_init,default_init_memmap,default_alloc_pages, default_free_pages.
/*
 * Details of FFMA
 * (1) Prepare: In order to implement the First-Fit Mem Alloc (FFMA), we should manage the free mem block use some list.
 *              The struct free_area_t is used for the management of free mem blocks. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list implementation.
 *              You should know howto USE: list_init, list_add(list_add_after), list_add_before, list_del, list_next, list_prev
 *              Another tricky method is to transform a general list struct to a special struct (such as struct page):
 *              you can find some MACRO: le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.)
 * (2) default_init: you can reuse the  demo default_init fun to init the free_list and set nr_free to 0.
 *              free_list is used to record the free mem blocks. nr_free is the total number for free mem blocks.
 * (3) default_init_memmap:  CALL GRAPH: kern_init --> pmm_init-->page_init-->init_memmap--> pmm_manager->init_memmap
 *              This fun is used to init a free block (with parameter: addr_base, page_number).
 *              First you should init each page (in memlayout.h) in this free block, include:
 *                  p->flags should be set bit PG_property (means this page is valid. In pmm_init fun (in pmm.c),
 *                  the bit PG_reserved is setted in p->flags)
 *                  if this page  is free and is not the first page of free block, p->property should be set to 0.
 *                  if this page  is free and is the first page of free block, p->property should be set to total num of block.
 *                  p->ref should be 0, because now p is free and no reference.
 *                  We can use p->page_link to link this page to free_list, (such as: list_add_before(&free_list, &(p->page_link)); )
 *              Finally, we should sum the number of free mem block: nr_free+=n
 * (4) default_alloc_pages: search find a first free block (block size >=n) in free list and reszie the free block, return the addr
 *              of malloced block.
 *              (4.1) So you should search freelist like this:
 *                       list_entry_t le = &free_list;
 *                       while((le=list_next(le)) != &free_list) {
 *                       ....
 *                 (4.1.1) In while loop, get the struct page and check the p->property (record the num of free block) >=n?
 *                       struct Page *p = le2page(le, page_link);
 *                       if(p->property >= n){ ...
 *                 (4.1.2) If we find this p, then it' means we find a free block(block size >=n), and the first n pages can be malloced.
 *                     Some flag bits of this page should be setted: PG_reserved =1, PG_property =0
 *                     unlink the pages from free_list
 *                     (4.1.2.1) If (p->property >n), we should re-caluclate number of the the rest of this free block,
 *                           (such as: le2page(le,page_link))->property = p->property - n;)
 *                 (4.1.3)  re-caluclate nr_free (number of the the rest of all free block)
 *                 (4.1.4)  return p
 *               (4.2) If we can not find a free block (block size >=n), then return NULL
 * (5) default_free_pages: relink the pages into  free list, maybe merge small free blocks into big free blocks.
 *               (5.1) according the base addr of withdrawed blocks, search free list, find the correct position
 *                     (from low to high addr), and insert the pages. (may use list_next, le2page, list_add_before)
 *               (5.2) reset the fields of pages, such as p->ref, p->flags (PageProperty)
 *               (5.3) try to merge low addr or high addr blocks. Notice: should change some pages's p->property correctly.
 */
free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

bool is_power_of_2(int x)
{
    return !(x & (x - 1));
}

unsigned get_power(unsigned n)
{
    unsigned i = 0;
    double tmp = n;
    while (tmp > 1)
    {
        tmp /= 2;
        i++;
    }
    return i;
}

unsigned *buddy;
int length;
struct Page *base0;

static void
buddy_system_init(void)
{
    list_init(&free_list);
    nr_free = 0;
}

static void
buddy_system_init_memmap(struct Page *base, size_t n)
{
    //cprintf("init %u page from %u\n", n, base);
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++)
    {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
        SetPageProperty(p);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    base0 = base;

    int i = get_power(n);
    // cprintf("init i %d\n", i);

    length = 2 * (1 << (i));
    // cprintf("init length %d\n", length);

    unsigned node_size = length;
    // cprintf("init node_size %u\n", node_size);

    buddy = (unsigned *)(base + length);

    for (i = 0; i < length; ++i)
    {
        if (is_power_of_2(i + 1))
            node_size /= 2;
        buddy[i] = node_size;
    }
    // cprintf("alloc buddy[0] %u\n", buddy[0]);
}

static struct Page *
buddy_system_alloc_pages(size_t n)
{
    assert(n > 0);
    if (n > nr_free)
    {
        return NULL;
    }
    struct Page *page = NULL;

    unsigned index = 0;
    unsigned node_size;
    unsigned offset = 0;

    if (n <= 1)
        n = 1;
    else if (!is_power_of_2(n))
    {
        unsigned pw = get_power(n);
        n = (1 << pw);
    }

    if (buddy[index] < n)
        return NULL;
    for (node_size = length / 2; node_size != n; node_size /= 2)
    {
        if (buddy[2 * index + 1] >= n)
        {
            index = 2 * index + 1;
        }
        else
        {
            index = 2 * index + 2;
        }
    }
    buddy[index] = 0;

    offset = (index + 1) * node_size - length / 2;

    while (index > 0)
    {
        if (index % 2 == 0)
        {
            index = (index - 2) / 2;
        }
        else
        {
            index = (index - 1) / 2;
        }
        buddy[index] = (buddy[2 * index + 1] > buddy[2 * index + 2]) ? buddy[2 * index + 1] : buddy[2 * index + 2];
    }

    page = base0 + offset;
    page->property = n;
    int i = get_power(n);
    unsigned size = (1 << i);
    nr_free -= size;
    for (struct Page *p = page; p != page + size; p++)
    {
        ClearPageProperty(p);
    }

    return page;
}

static void
buddy_system_free_pages(struct Page *base, size_t n)
{
    assert(n > 0);
    int i = get_power(n);
    unsigned size = (1 << i);

    struct Page *p = base;
    for (; p != base + size; p++)
    {
        assert(!PageReserved(p) && !PageProperty(p));
        set_page_ref(p, 0);
    }
    nr_free += size;

    unsigned offset = base - base0;

    unsigned node_size = 1;

    unsigned index = length / 2 + offset - 1;

    while (node_size < n)
    {
        node_size *= 2;
        if (index % 2 == 0)
        {
            index = (index - 2) / 2;
        }
        else
        {
            index = (index - 1) / 2;
        }
        if (index == 0)
            return;
    }

    buddy[index] = node_size;

    while (index)
    {
        if (index % 2 == 0)
        {
            index = (index - 2) / 2;
        }
        else
        {
            index = (index - 1) / 2;
        }
        node_size *= 2;
        unsigned left = buddy[2 * index + 1];
        unsigned right = buddy[2 * index + 2];
        if (left + right == node_size)
            buddy[index] = node_size;
        else
            buddy[index] = (left > right) ? left : right;
    }
}

static size_t
buddy_system_nr_free_pages(void)
{
    return nr_free;
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_check(void)
{
    cprintf("%sbuddy check%s\n","====", "====");
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    free_page(p0);
    free_page(p1);
    free_page(p2);

    p0 = alloc_pages(34);
    p1 = alloc_pages(65);
    p2 = alloc_pages(24);


    // 检验p1和p0是否相邻，并且分配内存是否是大于分配内存的2的幂次
    assert(p1 == p0 + 128);
    // 检验p2和p0是否相邻,并且分配内存是否是大于分配内存的2的幂次
    assert(p2 == p0 + 64);

    // 检验p0、p2释放后分配p2是否使用了p0的空间
    free_page(p0);
    free_page(p2);
    p2 = alloc_pages(34);
    assert(p2 == p0);

    // 检验释放后内存的合并是否正确
    free_page(p2);
    p2 = alloc_pages(128);
    assert(p0 == p2);

    free_page(p1);
}
// 这个结构体在
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_check,
};

