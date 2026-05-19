#!/bin/bash
# 一键部署包 - 简单安装脚本
# 用户级安装，不需要 root 权限

set -e

APP_NAME="图片查看器"
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
echo "一键部署 - ${APP_NAME}"
echo "======================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CURRENT_USER=$(whoami)
HOME_DIR="/home/$CURRENT_USER"
APP_DIR="$HOME_DIR/.local/share/applications/image-viewer"

# 检测桌面目录（支持中英文）
if command -v xdg-user-dir &> /dev/null; then
    DESKTOP_DIR=$(xdg-user-dir DESKTOP)
elif [ -d "$HOME_DIR/桌面" ]; then
    DESKTOP_DIR="$HOME_DIR/桌面"
else
    DESKTOP_DIR="$HOME_DIR/Desktop"
fi

# 创建应用目录
echo "创建应用目录..."
mkdir -p "$APP_DIR"

# 复制文件
echo "复制应用文件..."
if [ -f "image-viewer" ]; then
    cp "image-viewer" "$APP_DIR/"
else
    echo "错误: 未找到 image-viewer 文件"
    exit 1
fi

cp "config.json" "$APP_DIR/" 2>/dev/null || true
cp "sample.jpg" "$APP_DIR/" 2>/dev/null || true

chmod +x "$APP_DIR/image-viewer"

# 复制图标文件（如果存在）
ICON_FILE="icon.png"
if [ -f "$SCRIPT_DIR/$ICON_FILE" ]; then
    cp "$SCRIPT_DIR/$ICON_FILE" "$APP_DIR/"
    ICON_PATH="$APP_DIR/$ICON_FILE"
else
    ICON_PATH="application-x-executable"
fi

# 创建桌面快捷方式
echo "创建桌面快捷方式..."
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/image-viewer.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
GenericName=Image Viewer
Comment=全屏图片显示应用
Exec=$APP_DIR/image-viewer
Icon=$ICON_PATH
Terminal=false
Categories=Graphics;Viewer;
StartupNotify=true
Keywords=image;viewer;fullscreen;
Path=$APP_DIR
EOF

chmod +x "$DESKTOP_DIR/image-viewer.desktop"

# 创建菜单快捷方式
MENU_DIR="$HOME_DIR/.local/share/applications"
mkdir -p "$MENU_DIR"
cp "$DESKTOP_DIR/image-viewer.desktop" "$MENU_DIR/" 2>/dev/null || true

echo ""
echo "======================================"
echo "✓ 部署完成！"
echo "======================================"
echo ""
echo "应用位置: $APP_DIR"
echo ""
echo "启动方式："
echo "1. 双击桌面上的 '${APP_NAME}' 图标"
echo "2. 在应用程序菜单中找到 '${APP_NAME}'"
echo "3. 运行: $APP_DIR/image-viewer"
echo ""
echo "配置文件位置: $APP_DIR/config.json"
echo "按 ESC 键退出应用"
echo ""
