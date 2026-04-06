# 快速开始指南

## 5分钟入门

### 第一步：安装依赖工具

#### Windows 用户
安装工具最简单的办法是使用包管理器：

**方式1 - 使用 Chocolatey:**
```powershell
choco install nasm make qemu
```

**方式2 - 使用 Scoop:**
```powershell
scoop install nasm make qemu
```

**方式3 - 手动安装:**
1. NASM: [下载](https://www.nasm.us/)
2. GNU Make: [下载](http://gnuwin32.sourceforge.net/packages/make.htm) 或通过MinGW
3. QEMU: [下载](https://www.qemu.org/)

#### Linux 用户
```bash
# Ubuntu/Debian
sudo apt-get install nasm make qemu-system

# Fedora/RHEL
sudo dnf install nasm make qemu-system-x86
```

### 第二步：编译操作系统

#### 使用 PowerShell (推荐 Windows)
```powershell
# 编译项目
.\build.ps1

# 运行虚拟机
.\build.ps1 run

# 调试模式
.\build.ps1 debug

# 清理文件
.\build.ps1 clean
```

#### 使用批处理脚本
```batch
REM 编译项目
build.bat

REM 运行虚拟机
build.bat run

REM 调试模式
build.bat debug

REM 清理文件
build.bat clean
```

#### 使用 Makefile (Linux/macOS)
```bash
# 编译项目
make

# 运行虚拟机
make run

# 调试模式
make debug

# 清理文件
make clean
```

#### 手动编译
```bash
# 编译引导程序
nasm -f bin -o boot.bin boot.asm

# 编译内核
nasm -f bin -o kernel.bin kernel.asm

# 生成镜像
cat boot.bin kernel.bin > os.img

# 运行虚拟机
qemu-system-i386 -fda os.img -boot a
```

### 第三步：使用虚拟机

虚拟机启动后，你会看到：

```
================================
  欢迎来到 creatively OS v1.0.1 (cos)
================================

请选择操作:
1. 显示系统信息
2. 显示时间
3. 显示CPU信息

请输入选择 (1-3): 
```

输入 **1**, **2** 或 **3** 试试：
- 按 **1** 显示系统信息
- 按 **2** 显示时间功能
- 按 **3** 显示CPU信息

按任意键继续，或关闭虚拟机窗口退出。

## 文件说明

| 文件 | 说明 |
|------|------|
| `boot.asm` | MBR引导加载程序 (512字节) |
| `kernel.asm` | 操作系统内核代码 |
| `boot.bin` | 编译后的引导程序 (生成) |
| `kernel.bin` | 编译后的内核代码 (生成) |
| `os.img` | 完整的操作系统镜像 (生成) |
| `build.bat` | Windows批处理编译脚本 |
| `build.ps1` | PowerShell编译脚本 |
| `Makefile` | Unix/Linux编译脚本 |
| `README.md` | 项目说明文档 |
| `DEVELOPMENT.md` | 开发指南和扩展建议 |

## 项目结构

```
os/
├── boot.asm                (引导程序源代码)
├── kernel.asm              (内核源代码)
├── build.bat               (Windows编译脚本)
├── build.ps1               (PowerShell编译脚本)
├── Makefile                (Unix编译脚本)
├── README.md               (项目说明)
├── DEVELOPMENT.md          (开发指南)
├── QUICKSTART.md           (本文件)
├── *.bin                   (生成的二进制文件)
└── os.img                  (生成的系统镜像)
```

## 常见问题

### Q: 出现 "NASM not found"
A: NASM未安装或不在PATH中。请检查NASM是否正确安装。
```bash
# 检查NASM
nasm -version

# 重新安装NASM
# Windows: choco install nasm -force
# Linux: sudo apt-get install nasm
```

### Q: 编译报错 "illegal instruction"
A: 检查你的汇编代码是否有语法错误。查看错误行号并修正。

### Q: QEMU未找到
A: 安装QEMU虚拟机
```bash
# Windows
choco install qemu

# Linux
sudo apt-get install qemu-system-x86
```

### Q: 虚拟机无法启动
A: 确保os.img文件存在且不为空
```bash
# 检查文件大小
dir os.img          # Windows
ls -lh os.img       # Linux
```

### Q: 如何关闭虚拟机
A: 关闭QEMU窗口或按Ctrl+Alt+2进入QEMU monitor，输入quit

## 源代码讲解

### boot.asm 关键部分

```asm
[org 0x7c00]           ; 代码从0x7c00加载
[bits 16]              ; 16位代码

start:
    mov ax, 0          ; 初始化 ax 寄存器
    mov ds, ax         ; 设置数据段
```

**主要任务:**
1. 初始化寄存器和段
2. 清屏显示欢迎信息
3. 显示菜单
4. 处理用户输入
5. 显示对应信息

**BIOS中断:**
- `int 0x10` - 视频服务（显示字符）
- `int 0x16` - 键盘输入

### kernel.asm 关键部分

```asm
kernel_main:
    call init_idt       ; 初始化中断表
    call init_memory    ; 初始化内存
    sti                 ; 启用中断
    jmp kernel_loop     ; 进入无限循环
```

## 下一步学习

1. **理解汇编代码** - 逐行研究boot.asm
2. **修改菜单文本** - 更改欢迎信息和菜单
3. **添加更多功能** - 实现新的BIOS中断调用
4. **学习保护模式** - 研究如何从实模式切换到保护模式
5. **实现内核功能** - 添加中断处理、内存管理等

## 有用的命令

### 编译单个文件
```bash
nasm -f bin -o boot.bin boot.asm
```

### 查看镜像内容
```bash
hexdump -C os.img | head -20
# 或
xxd os.img | head -20
```

### 使用GDB调试
```bash
# 启动QEMU调试模式
qemu-system-i386 -fda os.img -boot a -s -S

# 新终端连接GDB
gdb
(gdb) target remote localhost:1234
(gdb) break *0x7c00
(gdb) continue
```

### 将镜像写入USB（真实硬件）
```bash
# Windows PowerShell (管理员)
dd if=os.img of=\\.\d: bs=4M status=progress

# Linux
sudo dd if=os.img of=/dev/sdX bs=4M status=progress
```

## 资源链接

- [OSDev.org](http://wiki.osdev.org) - 操作系统开发资源
- [NASM手册](https://www.nasm.us/doc/)
- [x86汇编](https://www.felixcloutier.com/x86/)
- [BIOS中断](https://en.wikipedia.org/wiki/INT_13H)
- [QEMU用户手册](https://qemu.readthedocs.io/)

## 成功标志 ✓

编译成功时会看到：
```
✓ 编译成功！
生成文件:
-rw-r--r-- 1 user group 1024 Apr 4 os.img
```

虚拟机成功启动时会看到：
```
================================
  欢迎来到简单操作系统 v0.1
================================
```

## 故障排除

| 问题 | 解决方案 |
|------|---------|
| 文件未找到 | 确保在项目目录运行命令 |
| 编译错误 | 检查汇编语法，查看NASM错误信息 |
| 虚拟机不启动 | 检查镜像文件是否存在，尝试重新编译 |
| 菜单无响应 | 尝试按1、2或3 |

## 获得帮助

- 查看 [README.md](README.md) 了解详细说明
- 查看 [DEVELOPMENT.md](DEVELOPMENT.md) 了解开发指南
- 访问 [OSDev.org](http://wiki.osdev.org) 获取技术资源
- 查看source代码注释

---

祝你使用愉快！🎉

**最后更新**: 2026年4月
**难度等级**: 初级 ★☆☆
**预计时间**: 5-10分钟入门，数小时深入学习
