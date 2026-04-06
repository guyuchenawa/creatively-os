# creatively OS (cos) - Changelog

## [1.0.1] - 2026-04-05
- 修复 `boot.asm` 内核加载地址，确保内核加载到 `0x1000`
- 添加 `backup.ps1` 自动备份脚本，用于将当前仓库文件复制到 `backup/<timestamp>`
- 添加 `VERSION` 文件，声明当前版本
- 更新 `README.md`，说明版本与备份流程
- 更新 `build.ps1` 和 `build.bat`，在构建前自动执行备份（如果 `backup.ps1` 存在）

## [1.0.0] - 初始版本
- 基本 MBR 引导加载程序和 16 位内核
- 简单命令行界面和菜单功能
