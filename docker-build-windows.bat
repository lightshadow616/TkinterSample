@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ======================================
echo   Docker 交叉编译打包工具
echo   为银河麒麟系统 (Linux) 打包应用
echo ======================================
echo.

REM ===== 检查 Docker 是否安装 =====
where docker >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Docker 命令
    echo.
    echo 请先安装 Docker Desktop:
    echo https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)

echo [检查] Docker 版本...
docker --version
echo.

REM ===== 检查 Docker 是否运行 =====
docker info >nul 2>&1
if errorlevel 1 (
    echo [错误] Docker 未运行
    echo.
    echo 请启动 Docker Desktop，然后重新运行此脚本
    echo.
    pause
    exit /b 1
)
echo [OK] Docker 运行正常
echo.

REM ===== 清理旧的构建产物 =====
echo [清理] 删除旧的构建文件...
if exist "dist-linux" rmdir /s /q "dist-linux"
if exist "build" rmdir /s /q "build"
if exist "dist" rmdir /s /q "dist"
for %%f in (*.spec) do if exist "%%f" del "%%f"
echo [OK] 清理完成
echo.

REM ===== 构建 Docker 镜像 =====
echo [1/3] 构建 Docker 镜像...
echo        （首次运行需要下载基础镜像，约需 5-10 分钟）
echo.

docker build -t kylin-packager .

if errorlevel 1 (
    echo.
    echo [错误] Docker 镜像构建失败
    echo 请检查 Dockerfile 和项目文件
    echo.
    pause
    exit /b 1
)

echo [OK] 镜像构建成功
echo.

REM ===== 运行容器并提取文件 =====
echo [2/3] 运行打包容器...
echo.

docker run --name temp-packager kylin-packager

if errorlevel 1 (
    echo.
    echo [警告] 容器运行出现警告，尝试提取文件...
    echo.
)

echo [3/3] 提取打包结果...
echo.

REM 创建输出目录
mkdir dist-linux

REM 从容器中复制文件
docker cp temp-packager:/app/dist/image-viewer dist-linux\ 2>nul
if errorlevel 1 (
    echo [错误] 无法提取可执行文件
    echo.
    echo 打包可能失败，请检查上面的日志
    docker rm temp-packager >nul 2>&1
    pause
    exit /b 1
)

docker cp temp-packager:/app/config.json dist-linux\ 2>nul
docker cp temp-packager:/app/sample.jpg dist-linux\ 2>nul

REM 清理临时容器
docker rm temp-packager >nul 2>&1

REM 复制安装脚本和文档
copy install-system.sh dist-linux\ >nul
copy install-desktop-shortcut.sh dist-linux\ >nul
copy README.md dist-linux\ >nul
copy 部署说明.md dist-linux\ >nul

echo.
echo ======================================
echo   打包完成！
echo ======================================
echo.
echo Linux 可执行文件: dist-linux\image-viewer
echo.
echo 文件列表:
dir /b dist-linux
echo.
echo ======================================
echo 下一步操作:
echo ======================================
echo.
echo 1. 将 dist-linux 文件夹复制到麒麟系统
echo.
echo 2. 在麒麟系统终端中执行:
echo    cd dist-linux
echo    chmod +x *.sh
echo    sudo ./install-system.sh
echo.
echo 3. 或者用户级安装:
echo    ./install-desktop-shortcut.sh
echo.
echo ======================================
echo.

pause
