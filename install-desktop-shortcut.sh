#!/bin/bash
# 在银河麒麟系统上创建桌面快捷方式
# 适用于已打包好的应用

set -e

echo "======================================"
echo "创建桌面快捷方式"
echo "======================================"

# 获取当前用户信息
CURRENT_USER=$(whoami)
HOME_DIR="/home/$CURRENT_USER"

# 检测桌面目录（支持中英文）
if command -v xdg-user-dir &> /dev/null; then
    DESKTOP_DIR=$(xdg-user-dir DESKTOP)
elif [ -d "$HOME_DIR/桌面" ]; then
    DESKTOP_DIR="$HOME_DIR/桌面"
else
    DESKTOP_DIR="$HOME_DIR/Desktop"
fi

# 从配置文件读取应用名称
APP_NAME="图片查看器"  # 默认值
CONFIG_FILE="$HOME/.local/share/applications/image-viewer/config.json"
if [ -f "$CONFIG_FILE" ]; then
    EXTRACTED_NAME=$(python3 -c "
import json, sys
try:
    with open('$CONFIG_FILE', 'r', encoding='utf-8') as f:
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

echo "应用名称: $APP_NAME"
echo ""

# 检查应用是否已打包
APP_DIR="$HOME_DIR/.local/share/applications/image-viewer"
EXECUTABLE="$APP_DIR/image-viewer"

if [ ! -f "$EXECUTABLE" ]; then
    echo "错误: 未找到可执行文件 $EXECUTABLE"
    echo ""
    echo "请先运行打包脚本: ./build.sh"
    echo "或者手动将可执行文件复制到: $APP_DIR"
    exit 1
fi

# 确保桌面目录存在
mkdir -p "$DESKTOP_DIR"

# 复制图标文件（如果存在）
ICON_FILE="icon.png"
if [ -f "$APP_DIR/$ICON_FILE" ]; then
    ICON_PATH="$APP_DIR/$ICON_FILE"
else
    ICON_PATH="application-x-executable"
fi

# 创建桌面快捷方式文件
DESKTOP_FILE="$DESKTOP_DIR/image-viewer.desktop"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
GenericName=Image Viewer
Comment=全屏图片显示应用 - 适用于海光x86架构国产电脑
Exec=$APP_DIR/image-viewer
Icon=$ICON_PATH
Terminal=false
Categories=Graphics;Viewer;
StartupNotify=true
Keywords=image;viewer;fullscreen;
EOF

# 添加执行权限
chmod +x "$DESKTOP_FILE"

echo "✓ 桌面快捷方式已创建: $DESKTOP_FILE"
echo "  显示名称: $APP_NAME"
echo ""
echo "现在可以在桌面上看到 '${APP_NAME}' 图标"
echo "双击图标即可启动应用"
