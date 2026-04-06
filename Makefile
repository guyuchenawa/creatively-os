# 简单操作系统Makefile
# 用于编译和生成启动镜像

ASM = nasm
ASMFLAGS = -f bin
LD = ld
LDFLAGS = -m elf_i386 -Ttext 0x1000

# 源文件
BOOT_SRC = boot.asm
KERNEL_SRC = kernel.asm

# 目标文件
BOOT_BIN = boot.bin
KERNEL_BIN = kernel.bin
OS_IMG = os.img

# 默认目标
all: $(OS_IMG)

# 编译引导程序
$(BOOT_BIN): $(BOOT_SRC)
	$(ASM) $(ASMFLAGS) -o $@ $<
	@echo "✓ 引导程序编译完成: $@"

# 编译内核
$(KERNEL_BIN): $(KERNEL_SRC)
	$(ASM) $(ASMFLAGS) -o $@ $<
	@echo "✓ 内核编译完成: $@"

# 生成操作系统镜像
$(OS_IMG): $(BOOT_BIN) $(KERNEL_BIN)
	@echo "正在生成操作系统镜像..."
	cat $(BOOT_BIN) $(KERNEL_BIN) > $@
	@echo "✓ 操作系统镜像生成完成: $@"
	@ls -lh $@

# 运行虚拟机（使用QEMU）
run: $(OS_IMG)
	@echo "启动虚拟机..."
	qemu-system-i386 -fda $< -boot a

# 调试模式运行（使用QEMU GDB）
debug: $(OS_IMG)
	@echo "以调试模式启动虚拟机..."
	qemu-system-i386 -fda $< -boot a -s -S

# 清理生成的文件
clean:
	@echo "清理生成的文件..."
	rm -f $(BOOT_BIN) $(KERNEL_BIN) $(OS_IMG)
	@echo "✓ 清理完成"

# 显示帮助信息
help:
	@echo "简单操作系统构建工具"
	@echo "===================="
	@echo "命令:"
	@echo "  make        - 编译操作系统"
	@echo "  make run    - 编译并运行虚拟机"
	@echo "  make debug  - 使用调试器运行虚拟机"
	@echo "  make clean  - 清理生成的文件"
	@echo "  make help   - 显示此帮助信息"

.PHONY: all run debug clean help
