# creatively OS (cos)

本仓库内容完全由 AI 生成：包括源代码、构建脚本、备份脚本、发布说明和文档。开发者负责触发、验证与发布流程。

注意：本仓库的 `README.md` 文档由 GitHub Copilot（AI 助手）生成/编写。

这是一个用汇编语言编写的简单 16 位操作系统项目，项目名称为 creatively OS（简称 `cos`）。

## 项目结构

```
os/
├── boot.asm      # MBR引导加载程序 (引导扇区)，负责加载内核并跳转到 0x1000
├── kernel.asm    # 内核代码，包含命令行交互和基本系统功能
├── Makefile      # GNU Make 构建脚本，用于 Linux/WSL/QEMU 构建
├── build.bat     # Windows 批处理构建脚本
├── build.ps1     # PowerShell 构建脚本
├── boot.bin      # 生成的引导程序二进制文件
├── kernel.bin    # 生成的内核二进制文件
├── os.img        # 生成的软盘镜像
└── README.md     # 本文件
```

## 项目特性

- **16位实模式操作系统**: 运行在 x86 实模式下
- **MBR 引导加载程序**: 标准的 512 字节启动扇区
- **简单菜单系统**: 提供用户交互界面
- **系统信息显示**: 显示基本系统信息

## 系统要求

### 开发工具
- **NASM**: 汇编编译器
  ```bash
  # Windows (使用Chocolatey)
  choco install nasm
  
  # Windows (使用scoop)
  scoop install nasm
  ```

- **QEMU**: 虚拟机(可选，用于测试)
  ```bash
  # Windows (使用Chocolatey)
  choco install qemu
  
  # Windows (使用scoop)
  scoop install qemu
  ```

- **GNU Make**: 构建工具
  ```bash
  # Windows (使用Chocolatey)
  choco install make
  ```

## 编译和运行

### 编译操作系统
```bash
make
```

这会生成文件：
- `boot.bin` - 引导程序二进制文件
- `kernel.bin` - 内核二进制文件
- `os.img` - 完整的操作系统镜像

### 运行虚拟机 (需要QEMU)
```bash
make run
```

### 调试模式
```bash
make debug
```

### 快速编译（不生成镜像）
```bash
nasm -f bin -o boot.bin boot.asm
nasm -f bin -o kernel.bin kernel.asm
```

### 清理
```bash
make clean
```

## 备份流程

项目包含 `backup.ps1`，用于在修改前将当前仓库文件复制到 `backup/<timestamp>`。在 Windows 下也可以直接运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File backup.ps1
```

如果使用 `build.bat` 或 `build.ps1` 构建，构建前会自动执行此备份脚本（当 `backup.ps1` 存在时）。

## 操作系统功能

## 引导程序 (boot.asm)
- 初始化段寄存器
- 清屏
- 显示欢迎消息
- 提供3个菜单选项
- 处理用户输入

### 功能菜单
1. **显示系统信息** - 显示系统基本信息
2. **显示时间** - 获取系统时间
3. **显示CPU信息** - 显示CPU架构信息

## 代码解析

### 引导程序的关键部分

```asm
[org 0x7c00]  ; 设置代码原点为0x7c00（MBR地址）
[bits 16]     ; 16位代码
```

**BIOS中断使用:**
- `int 0x10` - 视频服务
  - `0x0003` - 清屏
  - `0x0e` - 写字符
- `int 0x16` - 键盘输入

### 字符串打印函数
```asm
print_string:  ; 打印由0终止的字符串
```

使用BIOS中断`int 0x10`逐字符输出。

## 扩展建议

1. **内存管理**: 实现简单的内存分配器
2. **文件系统**: 支持读写文件
3. **进程管理**: 实现简单的进程调度
4. **驱动程序**: 磁盘、网络驱动
5. **高级语言**: 用C语言编写更多功能

## 磁盘镜像的结构

```
os.img
├── 偏移量 0x0000 - 0x01FF (512字节) → boot.bin
├── 偏移量 0x0200 - 0x03FF (512字节) → kernel.bin (第一部分)
└── ...
```

## 使用虚拟机运行

### QEMU 命令
```bash
# 从软盘启动
qemu-system-i386 -fda os.img -boot a

# 启用调试
qemu-system-i386 -fda os.img -boot a -s -S

# 连接GDB调试
gdb
(gdb) target remote localhost:1234
(gdb) break *0x7c00
(gdb) continue
```

### VirtualBox 步骤
1. 创建新虚拟机 (MS-DOS 类型)
2. 虚拟磁盘设置为 `os.img`
3. 启动虚拟机

## 常见问题

## 版本号规则

本项目采用语义化但带阶段标记的版本号规则，格式为：

- `v<major>.<stage>.<bugfix>`

解释：
- `major`：主版本号，表示重大架构或不兼容的大改动（例如从 16 位到 32 位保护模式）；
- `stage`：阶段内功能更新编号，用于同一主版本下的重要功能添加或增强（阶段内的大更新）；
- `bugfix`：补丁号，用于小修复与回归修复。

示例：
- `v1.2.3`：主版本 1，第 2 阶段的重要功能更新，第 3 个补丁修复。

发布注意：在创建 GitHub Release 时请使用该格式作为 Release 标签与标题（例如 `v1.2.3`），并在 Release 说明中用中文或英文清晰描述变更内容，避免直接从自动工具复制时出现编码或转义导致的乱码。


**Q: 如何修改菜单选项?**  
A: 编辑 `boot.asm` 中的 `menu_msg`, `opt1_msg` 等字符串。

**Q: 如何添加更多功能?**  
A: 在 `kernel.asm` 中添加新的函数和功能。

**Q: 支持什么x86处理器?**  
A: 所有支持实模式的x86处理器 (8086及以上)。

**Q: 如何让操作系统持久化运行?**  
A: 修改 `kernel_loop` 部分添加更多处理逻辑。

## 学习资源

- x86汇编基础
- BIOS中断参考
- 操作系统原理
- 计算机体系结构

## 许可证

MIT License - 仅用于学习和研究目的

## 贡献

欢迎提交问题、建议和改进！

---

**最后更新**: 2026年4月
