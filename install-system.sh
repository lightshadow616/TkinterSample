#!/bin/bash
# 银河麒麟系统 - 系统级安装脚本
# 将应用安装到系统目录，所有用户可用
# 需要 root 权限

set -e

# 从配置文件读取应用名称
APP_NAME="图片查看器"  # 默认值
if [ -f config.json ]; then
    EXTRACTED_NAME=$(python3 -c "
import json, sys
try:
    with open('config.json', 'r', encoding='utf-8') as f:
        config = json.load(f)
        name = config.get('app_name', config.get('window_title', ''))
        if name:
            print(name)
except:
    pass
" 2>/dev/null || echo "")
    
    if [ -n "$EXTRACTED_NAME" ]; then
        APP_NAME="$EXTRACTED_NAME"
    fi
fi

echo "======================================"
echo "系统级安装 - ${APP_NAME}"
echo "======================================"
echo "应用名称: $APP_NAME"
echo ""

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "错误: 此脚本需要 root 权限"
    echo "请使用: sudo $0"
    exit 1
fi

# 定义安装路径
INSTALL_DIR="/opt/image-viewer"
BIN_DIR="/usr/local/bin"
APP_DIR="/usr/share/applications"

# 检查是否已打包
if [ ! -f "dist/image-viewer" ]; then
    echo "错误: 未找到打包文件 dist/image-viewer"
    echo "请先运行: ./build.sh"
    exit 1
fi

# 创建安装目录
echo "创建安装目录..."
mkdir -p "$INSTALL_DIR"

# 复制文件
echo "复制应用文件..."
cp dist/image-viewer "$INSTALL_DIR/"
cp config.json "$INSTALL_DIR/"
cp sample.jpg "$INSTALL_DIR/"

# 设置权限
chmod +x "$INSTALL_DIR/image-viewer"
chown -R root:root "$INSTALL_DIR"

# 创建系统级符号链接
echo "创建系统命令..."
ln -sf "$INSTALL_DIR/image-viewer" "$BIN_DIR/image-viewer"

# 复制图标文件（如果存在）
ICON_FILE="icon.png"
if [ -f "$ICON_FILE" ]; then
    cp "$ICON_FILE" "$INSTALL_DIR/"
    ICON_PATH="$INSTALL_DIR/$ICON_FILE"
else
    ICON_PATH="application-x-executable"
fi

# 创建系统级桌面快捷方式（使用配置的应用名称）
echo "创建系统菜单项..."
cat > "$APP_DIR/image-viewer.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
GenericName=Image Viewer
Comment=全屏图片显示应用 - 适用于海光x86架构国产电脑
Exec=$INSTALL_DIR/image-viewer
Icon=$ICON_PATH
Terminal=false
Categories=Graphics;Viewer;
StartupNotify=true
Keywords=image;viewer;fullscreen;
EOF

chmod +x "$APP_DIR/image-viewer.desktop"

echo ""
echo "======================================"
echo "✓ 系统级安装完成！"
echo "======================================"
echo ""
echo "安装位置: $INSTALL_DIR"
echo "启动命令: image-viewer"
echo ""
echo "所有用户都可以："
echo "1. 在应用程序菜单中找到 '${APP_NAME}'"
echo "2. 在终端中运行 'image-viewer' 命令启动"
echo "3. 按 ESC 键退出应用"
echo ""
