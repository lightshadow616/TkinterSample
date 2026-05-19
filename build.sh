#!/bin/bash
# 银河麒麟操作系统 V11 打包脚本
# 基于 Linux 6.6 内核，适用于海光 x86 架构

set -e  # 遇到错误立即退出

# 从配置文件读取应用名称（如果存在）
APP_NAME="图片查看器"  # 默认值
if [ -f config.json ]; then
    # 尝试从 JSON 中提取 app_name 字段
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
echo "银河麒麟系统 - ${APP_NAME}打包工具"
echo "======================================"
echo "应用名称: $APP_NAME"
echo ""

# 获取当前用户
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

# 检查 Python 版本
echo "检查 Python 环境..."
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 Python3，请先安装 Python3"
    echo "安装命令: sudo yum install python3 或 sudo apt-get install python3"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python 版本: $PYTHON_VERSION"

# 检查 PyInstaller 是否安装
echo "检查 PyInstaller..."
if ! python3 -m pip show pyinstaller &> /dev/null; then
    echo "正在安装 PyInstaller..."
    python3 -m pip install pyinstaller
    if [ $? -ne 0 ]; then
        echo "错误: PyInstaller 安装失败"
        echo "尝试使用系统包管理器安装: sudo yum install python3-pyinstaller"
        exit 1
    fi
fi

# 安装项目依赖
echo "安装项目依赖..."
if [ -f requirements.txt ]; then
    python3 -m pip install -r requirements.txt
fi

# 清理旧的构建文件
echo "清理旧的构建文件..."
rm -rf build dist *.spec

# 使用 PyInstaller 打包（使用 python3 -m 方式更可靠）
echo "开始打包..."
python3 -m PyInstaller --name="image-viewer" \
    --onefile \
    --windowed \
    --add-data "config.json:." \
    --add-data "sample.jpg:." \
    --clean \
    TkinterSample.py

# 检查打包是否成功
if [ $? -eq 0 ] && [ -f "dist/image-viewer" ]; then
    echo ""
    echo "======================================"
    echo "✓ 打包成功！"
    echo "======================================"
    echo "可执行文件: dist/image-viewer"
    echo ""

    # 创建应用安装目录（使用固定目录名，避免中文路径问题）
    APP_DIR="$HOME_DIR/.local/share/applications/image-viewer"
    mkdir -p "$APP_DIR"

    # 复制可执行文件
    cp dist/image-viewer "$APP_DIR/"
    chmod +x "$APP_DIR/image-viewer"

    # 复制资源文件
    cp config.json "$APP_DIR/"
    cp sample.jpg "$APP_DIR/"

    echo "✓ 应用已安装到: $APP_DIR"
    echo ""

    # 复制图标文件（如果存在）
    ICON_FILE="icon.png"
    if [ -f "$ICON_FILE" ]; then
        cp "$ICON_FILE" "$APP_DIR/"
        ICON_PATH="$APP_DIR/$ICON_FILE"
        echo "✓ 图标已复制: $ICON_PATH"
    else
        ICON_PATH="application-x-executable"
    fi

    # 创建桌面快捷方式（使用配置的应用名称）
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

    chmod +x "$DESKTOP_FILE"
    echo "✓ 桌面快捷方式已创建: $DESKTOP_FILE"
    echo "  显示名称: $APP_NAME"
    echo ""
    echo "======================================"
    echo "部署完成！"
    echo "======================================"
    echo ""
    echo "使用方法："
    echo "1. 双击桌面上的 '${APP_NAME}' 图标启动"
    echo "2. 编辑 $APP_DIR/config.json 修改配置"
    echo "3. 按 ESC 键退出应用"
    echo ""
else
    echo ""
    echo "======================================"
    echo "✗ 打包失败！"
    echo "======================================"
    echo "请检查错误信息并修复后重试"
    exit 1
fi
