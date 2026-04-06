# creatively OS (cos) - 项目计划和扩展指南

## 项目阶段

### ✅ 第一阶段 - 基础引导 (已完成)
- [x] MBR引导加载程序
- [x] 16位实模式支持
- [x] BIOS中断集成
- [x] 基本菜单系统
- [x] 字符输出功能

### 第二阶段 - 内核基础
- [ ] 中断描述符表 (IDT)
- [ ] 全局描述符表 (GDT)
- [ ] 切换到保护模式
- [ ] 内存管理初始化
- [ ] 堆栈管理

### 第三阶段 - 驱动程序
- [ ] 磁盘驱动 (读写扇区)
- [ ] 键盘驱动 (中断处理)
- [ ] 时钟驱动
- [ ] 串口驱动 (调试输出)
- [ ] 显示驱动升级

### 第四阶段 - 文件系统
- [ ] 文件系统设计 (FAT12/FAT16)
- [ ] 文件读写操作
- [ ] 目录结构
- [ ] 文件查询
- [ ] 引导加载program support

### 第五阶段 - 进程管理
- [ ] 进程控制块 (PCB)
- [ ] 进程调度算法
- [ ] 上下文切换
- [ ] 多进程管理
- [ ] 进程通信 (IPC)

### 第六阶段 - 内存管理
- [ ] 虚拟内存
- [ ] 分页管理
- [ ] 分段管理
- [ ] 内存保护
- [ ] 缺页处理

### 第七阶段 - Shell/命令行
- [ ] 简单命令行界面 (CLI)
- [ ] 基本命令 (ls, cd, cat等)
- [ ] 环境变量
- [ ] 脚本支持
- [ ] 管道功能

## 学习路线

### 初级 (准备工作)
1. x86汇编基础
   - 寄存器和指令集
   - 内存寻址模式
   - 栈和函数调用

2. BIOS编程
   - BIOS中断表
   - 显示 (int 0x10)
   - 键盘 (int 0x16)
   - 磁盘 (int 0x13)
   - 时间 (int 0x1A)

3. 操作系统基础
   - 引导过程
   - 实模式vs保护模式
   - 中断和异常
   - 内存管理

### 中级 (核心功能)
4. 保护模式
   - 全局描述符表 (GDT)
   - 中断描述符表 (IDT)
   - 分段
   - 权限级别

5. 内存管理
   - 分页
   - 虚拟内存
   - 页表
   - TLB

6. 进程管理
   - 进程调度
   - 上下文切换
   - 优先级
   - 进程间通信

### 高级 (系统功能)
7. 文件系统
   - FAT32文件系统
   - ext2文件系统
   - 索引节点 (i-node)
   - 缓存机制

8. 驱动程序
   - 设备驱动架构
   - 中断处理
   - DMA操作
   - 设备管理

## 代码结构建议

```
os/
├── boot/
│   ├── boot.asm          # MBR引导程序
│   └── bootloader.asm    # 第二阶段引导
├── kernel/
│   ├── kernel.asm        # 内核入口
│   ├── kernel.c          # 内核主函数
│   ├── setup.asm         # 系统初始化
│   └── main.c            # 内核主程序
├── drivers/
│   ├── disk.asm          # 磁盘驱动
│   ├── keyboard.asm      # 键盘驱动
│   ├── screen.asm        # 屏幕驱动
│   └── timer.asm         # 计时器驱动
├── fs/
│   ├── fat.c             # FAT文件系统
│   ├── inode.c           # i-node管理
│   └── cache.c           # 缓存管理
├── mm/
│   ├── memory.c          # 内存管理
│   ├── paging.asm        # 分页
│   └── kmalloc.c         # 内核内存分配
├── process/
│   ├── process.c         # 进程管理
│   ├── schedule.c        # 调度器
│   └── context.asm       # 上下文切换
├── include/
│   ├── types.h           # 类型定义
│   ├── defs.h            # 宏定义
│   ├── printk.h          # 打印函数
│   └── config.h          # 配置
└── tools/
    ├── Makefile          # 构建脚本
    └── image.sh          # 镜像生成
```

## 开发工具链

### 必需工具
- **NASM** - 汇编器
- **GCC** - C编译器 (交叉编译器)
- **GNU Make** - 构建工具
- **QEMU** - 虚拟机

### 可选工具
- **GDB** - 调试器
- **Bochs** - 虚拟机 (带调试支持)
- **Binutils** - 二进制工具
- **Grub** - 启动管理器

### 交叉编译工具链设置
```bash
# Ubuntu/Debian
sudo apt-get install nasm gcc Make qemu-system

# 构建交叉编译工具链
./setup_toolchain.sh
```

## 重要概念

### 1. 引导过程
```
BIOS POST
  ↓
找到引导设备 (MBR)
  ↓
执行 boot.asm (MBR)
  ↓
显示启动菜单
  ↓
加载内核
  ↓
初始化系统
  ↓
启动shell/应用
```

### 2. 内存布局
```
0x00000000 - 0x000003FF : 中断向量表 (IVT) - 1024字节
0x00000400 - 0x000004FF : BIOS数据区 - 256字节
0x00000500 - 0x00007BFF : 自由区域 - 30KB
0x00007C00 - 0x00007DFF : 引导扇区 (MBR) - 512字节
0x00007E00 - 0x0009FFFF : 自由区域 - 622KB
0x000A0000 - 0x000FFFFF : BIOS ROM和I/O - 384KB
0x00100000 - 0xFFFFFFF : 扩展内存 - 大部分系统内存
```

### 3. 实模式 vs 保护模式
| 特性 | 实模式 | 保护模式 |
|------|--------|----------|
| 寻址 | 分段型 | 虚拟地址 |
| 最大内存 | 1MB | 4GB |
| 特权级 | 无 | Ring 0-3 |
| 中断处理 | 向量表 | IDT |
| 多任务 | 不支持 | 支持 |

## 参考资源

### 书籍
- "Operating System Concepts" - Silberschatz等
- "The Linux Kernel" - Torvalds等
- "Architecture of x86 Computer Systems" - Zak

### 在线资源
- OSDev.org - http://wiki.osdev.org
- Xv6 - MIT操作系统课程
- Linux内核源码
- QEMU文档

### 教程
- Babyostep-osdev.org
- Writing an OS in Rust
- Simple bootloader tutorials

## 常见问题解答

**Q: 从哪里开始?**  
A: 从理解x86汇编和BIOS中断开始。阅读boot.asm代码和注释。

**Q: 如何调试?**  
A: 使用QEMU + GDB组合。设置断点在0x7c00观察引导过程。

**Q: 如何从实模式转到保护模式?**  
A: 实现GDT，设置控制寄存器CR0的PE位，进行远跳转。

**Q: 跨平台支持?**  
A: 当前使用x86特定代码。不同架构需要重写汇编部分。

**Q: 如何添加C代码?**  
A: 使用交叉编译器编译C代码为.o文件，链接到汇编代码中。

## 关键术语词汇表

- **MBR** - 主引导记录 (Master Boot Record)
- **BIOS** - 基本输入/输出系统 (Basic Input/Output System)
- **IDT** - 中断描述符表 (Interrupt Descriptor Table)
- **GDT** - 全局描述符表 (Global Descriptor Table)
- **PCB** - 进程控制块 (Process Control Block)
- **ISR** - 中断服务程序 (Interrupt Service Routine)
- **TLB** - 转换后备缓冲区 (Translation Lookaside Buffer)
- **IPC** - 进程间通信 (Inter-Process Communication)
- **FAT** - 文件分配表 (File Allocation Table)
- **i-node** - 索引节点

## 下一步是什么?

1. 深入学习boot.asm代码
2. 尝试修改菜单和消息
3. 学习x86汇编指令集
4. 实现IDT和中断处理
5. 添加更多系统功能
6. 迁移到保护模式
7. 实现文件系统
8. 构建用户应用程序

---

# **最后更新**: 2026年4月
# **维护者**: OS学习者社区
# **许可证**: MIT License

祝你的操作系统开发之旅愉快！🚀
