# 仓库快速摘要（供 AI / 开发者快速理解）

此文件由自动化脚本生成，旨在在下一次对话时快速让模型与开发者了解仓库结构、构建与备份流程。

项目概览
- 项目名：creatively OS（简称 `cos`）。
- 目标：一个简单的 16 位实模式操作系统（MBR 引导 + 简单内核）。
- 主要语言：x86 汇编（NASM 格式）。

重要声明：本仓库内容已由 AI 完全生成（包括源代码、构建与备份脚本、文档和发布说明）。开发者负责触发、审核与发布该内容。

关键文件
- `boot.asm` - 启动扇区（MBR），org 0x7c00，生成 `boot.bin`。
- `kernel.asm` - 内核代码，org 0x1000，生成 `kernel.bin`。
- `Makefile` - GNU Make 构建脚本（Linux/WSL/QEMU）。
- `build.bat` / `build.ps1` - Windows 下的构建脚本（会在构建前调用 `backup.ps1`）。
- `backup.ps1` - 备份脚本，会把仓库文件复制到 `backup/<timestamp>/`。
- `os.img`, `boot.bin`, `kernel.bin` - 构建产物（可忽略入备份，脚本已排除）。

构建说明（快速）
- Windows (PowerShell): `.
build.ps1` 或 `build.bat`。
- 快速单步编译（不生成镜像）:
  - `nasm -f bin -o boot.bin boot.asm`
  - `nasm -f bin -o kernel.bin kernel.asm`
- 使用 Make (Linux/WSL): `make`，镜像生成和 `make run` 启动 QEMU。

备份位置
- 预构建备份由 `backup.ps1` 创建，路径：`backup/<yyyyMMdd_HHmmss>/`。
- 我已添加一个后构建备份工具 `tools/compile_and_backup.ps1`（运行构建并在成功后做一次额外备份），以便每次修改后手动或由助手调用时能立即产生构建与备份记录。

如何在下一次对话快速上手（给 AI 的提示）
1. 先打开 `REPO_AI_SUMMARY.md` 与 `/memories/repo/repo_summary.md`（如果存在）以获取构建、备份和关键路径说明。
2. 若要修改源码，建议：
   - 编辑 `boot.asm` 或 `kernel.asm`。
   - 运行 `tools\compile_and_backup.ps1`（或 `build.ps1`，两者均会产生备份）。
3. 若需在 CI 或自动化环境中实现“每次修改后自动构建并备份”，可使用文件系统监听器或 Git 钩子（`pre-commit`/`post-commit`）来调用 `tools\compile_and_backup.ps1`。

维护者备注
- 该仓库已在 Windows 环境下测试，NASM 已通过 Chocolatey 安装。
 - 许可证：GPL-3.0-or-later
