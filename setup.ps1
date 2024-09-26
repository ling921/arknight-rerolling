# 获取当前脚本所在的目录
$currentDirectory = Get-Location

# 检查当前目录是否存在maa.exe
$maaExecutablePath = Join-Path $currentDirectory "maa.exe"
if (!(Test-Path $maaExecutablePath)) {
    Write-Host "maa.exe 不存在, 请先下载 maa-cli"
    exit
}

# 需要软链的文件夹
$maaLinkSource = Join-Path $currentDirectory "maa"
# 软链的文件夹不存在，则创建maa目录
if (!(Test-Path $maaLinkSource)) {
    New-Item -ItemType Directory -Path $maaLinkSource
}


# 获取maa-cli 资源文件完整路径
$loongDirectory = Join-Path $env:APPDATA "loong"

# 软链的目标文件夹
$maaLinkTarget = Join-Path $loongDirectory "maa"

# 资源文件路径文件夹不存在，则创建；存在，则删除其下maa目录
if (!(Test-Path $loongDirectory)) {
    New-Item -ItemType Directory -Path $loongDirectory
} else {
    if (Test-Path $maaLinkTarget) {
        Remove-Item $maaLinkTarget -Force
    }
}

# 创建资源文件的软链接
New-Item -ItemType SymbolicLink -Path $maaLinkTarget -Target $maaLinkSource
Write-Host "已创建maa资源文件的软链接"

# 检查当前目录是否在PATH环境变量中
$currentDirectory = Get-Location
$pathVariable = [Environment]::GetEnvironmentVariable("Path", "User")
if ($pathVariable -notcontains $currentDirectory) {
    # 将当前目录添加到PATH环境变量
    $newPath = "$pathVariable;$currentDirectory"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "已将当前目录添加到PATH环境变量"
} else {
    Write-Host "当前目录已在PATH环境变量中"
}

# 安装maa
& $maaExecutablePath "install"
