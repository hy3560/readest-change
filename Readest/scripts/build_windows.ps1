# Readest Windows Build Script
# 确保你已安装 Visual Studio 2022 (Desktop development with C++)

Write-Host "开始构建 Readest Windows 生产版本..." -ForegroundColor Cyan

# 1. 清理旧构建
flutter clean

# 2. 获取依赖
flutter pub get

# 3. 运行代码生成器 (Isar/JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. 编译 Release 版本
# 使用 --pwa-strategy 只是为了展示扩展性，Windows 主要依赖编译优化
flutter build windows --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "构建成功！可执行文件位于: build\windows\x64\runner\Release\readest.exe" -ForegroundColor Green
} else {
    Write-Host "构建失败，请检查 Visual Studio 2022 配置。" -ForegroundColor Red
}