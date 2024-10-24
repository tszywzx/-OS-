# buddy_system_pmm设计文档



## 1、初始化

初始化伙伴系统的内存映射，包括设置页面的状态、计算节点数量和初始化节点大小

```
static void
buddy_system_init_memmap(struct Page *base, size_t n)
{
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++)
    {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
        SetPageProperty(base);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    base0 = base;

    int i = get_power(n);
    
	#计算伙伴系统需要的节点数量。length 是伙伴树中节点的数量，每个节点代表一个内存块大小
    length = 2 * (1 << (i));

    unsigned node_size = length;

    buddy = (unsigned *)(base + length);

    for (i = 0; i < length; ++i)
    {
        if (is_power_of_2(i + 1))
            node_size /= 2;
        buddy[i] = node_size;
    }
}
```



## 2、分配内存

>**在伙伴树中找到合适的节点**：
>
>- 从伙伴树的根节点开始（索引为0），循环直到找到大小至少为 `n` 的节点。
>- 在循环中，根据子节点的大小决定向下遍历哪如何计算释放的页面块在伙伴树中的索引，以及如何在遍历伙伴树时合并节点。通过这种方式，伙伴系统能够在释放内存时尝试合并相邻的空闲块，从而减少内存碎片。个子树。
>- 如果左子节点（`2 * index + 1`）的大小足够，则选择左子节点；否则选择右子节点（`2 * index + 2`）。
>
>**更新伙伴树**：
>
>- 从分配的节点开始向上遍历伙伴树，更新每个父节点的大小。
>- 如果一个节点的两个子节点的大小不同，则选择较大的那个作为父节点的大小。

```
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
        return null;
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
```



## 3、释放内存

> 1. **计算伙伴树索引**：
> 	- 计算释放的页面块在伙伴树中的索引 `index`。
> 2. **合并节点**：
> 	- 向上遍历伙伴树，尝试合并节点，直到达到正确的大小 `node_size` 等于 `n`。
> 	- 如果当前索引的子节点大小之和等于 `node_size`，则将当前节点的大小设置为 `node_size`。
> 3. **更新伙伴树**：
> 	- 继续向上遍历伙伴树，更新每个父节点的大小。
> 	- 如果一个节点的两个子节点的大小相同，则将它们合并为一个节点。

```
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
```



## 4、测试用例

```
static void
buddy_check(void)
{
    cprintf("%sbuddy check%s\n", "===="，"====");
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
    assert(p2 == p1 + 64);

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
```

测试截图

![image-20241024114713152](C:\Users\辛杰\AppData\Roaming\Typora\typora-user-images\image-20241024114713152.png)