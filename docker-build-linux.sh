#!/bin/bash
# =====================================================
# Docker 交叉编译打包脚本 (Linux/Mac)
# 为银河麒麟系统 (Linux) 打包应用
# =====================================================

set -e  # 遇到错误立即退出

echo ""
echo "======================================"
echo "  Docker 交叉编译打包工具"
echo "  为银河麒麟系统 (Linux) 打包应用"
echo "======================================"
echo ""

# ===== 检查 Docker 是否安装 =====
if ! command -v docker &> /dev/null; then
    echo "[错误] 未找到 Docker 命令"
    echo ""
    echo "请先安装 Docker:"
    echo "  Ubuntu/Debian: sudo apt-get install docker.io"
    echo "  CentOS/RHEL:   sudo yum install docker"
    echo "  Mac:           安装 Docker Desktop"
    echo ""
    exit 1
fi

echo "[检查] Docker 版本..."
docker --version
echo ""

# ===== 检查 Docker 是否运行 =====
if ! docker info &> /dev/null; then
    echo "[错误] Docker 未运行"
    echo ""
    echo "请启动 Docker 服务:"
    echo "  Linux: sudo systemctl start docker"
    echo "  Mac:   启动 Docker Desktop"
    echo ""
    exit 1
fi
echo "[OK] Docker 运行正常"
echo ""

# ===== 清理旧的构建产物 =====
echo "[清理] 删除旧的构建文件..."
rm -rf dist-linux build dist *.spec
echo "[OK] 清理完成"
echo ""

# ===== 构建 Docker 镜像 =====
echo "[1/3] 构建 Docker 镜像..."
echo "       （首次运行需要下载基础镜像，约需 5-10 分钟）"
echo ""

docker build -t kylin-packager .

if [ $? -ne 0 ]; then
    echo ""
    echo "[错误] Docker 镜像构建失败"
    echo "请检查 Dockerfile 和项目文件"
    echo ""
    exit 1
fi

echo "[OK] 镜像构建成功"
echo ""

# ===== 运行容器并提取文件 =====
echo "[2/3] 运行打包容器..."
echo ""

docker run --name temp-packager kylin-packager || {
    echo ""
    echo "[警告] 容器运行出现警告，尝试提取文件..."
    echo ""
}

echo "[3/3] 提取打包结果..."
echo ""

# 创建输出目录
mkdir -p dist-linux

# 从容器中复制文件
if ! docker cp temp-packager:/app/dist/image-viewer dist-linux/; then
    echo "[错误] 无法提取可执行文件"
    echo ""
    echo "打包可能失败，请检查上面的日志"
    docker rm temp-packager > /dev/null 2>&1 || true
    exit 1
fi

docker cp temp-packager:/app/config.json dist-linux/ 2>/dev/null || true
docker cp temp-packager:/app/sample.jpg dist-linux/ 2>/dev/null || true

# 清理临时容器
docker rm temp-packager > /dev/null 2>&1 || true

# 复制安装脚本和文档
cp install-system.sh dist-linux/
cp install-desktop-shortcut.sh dist-linux/
cp README.md dist-linux/
cp 部署说明.md dist-linux/ 2>/dev/null || true

echo ""
echo "======================================"
echo "  ✓ 打包完成！"
echo "======================================"
echo ""
echo "Linux 可执行文件: dist-linux/image-viewer"
echo ""
echo "文件列表:"
ls -lh dist-linux/
echo ""
echo "======================================"
echo "下一步操作:"
echo "======================================"
echo ""
echo "1. 将 dist-linux 文件夹复制到麒麟系统"
echo ""
echo "2. 在麒麟系统终端中执行:"
echo "   cd dist-linux"
echo "   chmod +x *.sh"
echo "   sudo ./install-system.sh"
echo ""
echo "3. 或者用户级安装:"
echo "   ./install-desktop-shortcut.sh"
echo ""
echo "======================================"
echo ""
