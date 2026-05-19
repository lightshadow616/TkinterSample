#!/bin/bash
# 创建 DEB 安装包 - 银河麒麟系统专用
# 生成标准的 .deb 安装包

set -e

# 从配置文件读取应用名称
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
echo "创建 DEB 安装包 - ${APP_NAME}"
echo "======================================"
echo ""

# 检查是否已打包
if [ ! -f "dist/image-viewer" ]; then
    echo "错误: 未找到打包文件 dist/image-viewer"
    echo "请先运行: ./build.sh"
    exit 1
fi

# 检查必要工具
if ! command -v fakeroot &> /dev/null; then
    echo "正在安装必要工具..."
    sudo apt-get update
    sudo apt-get install -y fakeroot dpkg
fi

# 创建 DEB 包结构
VERSION="1.0.0"
ARCH="amd64"
PACKAGE_NAME="image-viewer"
DEB_DIR="${PACKAGE_NAME}_${VERSION}_${ARCH}"

echo "创建 DEB 包结构..."
rm -rf "$DEB_DIR"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/opt/image-viewer"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/usr/local/bin"

# 创建控制文件
cat > "$DEB_DIR/DEBIAN/control" <<EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION}
Section: graphics
Priority: optional
Architecture: ${ARCH}
Maintainer: Image Viewer Team
Description: 全屏图片显示应用
 适用于海光x86架构国产电脑的全屏图片显示应用
EOF

# 创建安装后脚本
cat > "$DEB_DIR/DEBIAN/postinst" <<'EOF'
#!/bin/bash
set -e
echo "正在配置 image-viewer..."

# 创建符号链接
if [ ! -L "/usr/local/bin/image-viewer" ]; then
    ln -s /opt/image-viewer/image-viewer /usr/local/bin/image-viewer
fi

echo "安装完成！"
echo ""
echo "使用方法："
echo "1. 在应用程序菜单中找到 '图片查看器'"
echo "2. 或在终端运行: image-viewer"
echo ""
EOF
chmod 755 "$DEB_DIR/DEBIAN/postinst"

# 复制文件
echo "复制应用文件..."
cp dist/image-viewer "$DEB_DIR/opt/image-viewer/"
cp config.json "$DEB_DIR/opt/image-viewer/"
cp sample.jpg "$DEB_DIR/opt/image-viewer/"
chmod +x "$DEB_DIR/opt/image-viewer/image-viewer"

# 复制图标文件（如果存在）
ICON_FILE="icon.png"
if [ -f "$ICON_FILE" ]; then
    cp "$ICON_FILE" "$DEB_DIR/opt/image-viewer/"
    ICON_PATH="/opt/image-viewer/$ICON_FILE"
else
    ICON_PATH="application-x-executable"
fi

# 创建桌面快捷方式
cat > "$DEB_DIR/usr/share/applications/image-viewer.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
GenericName=Image Viewer
Comment=全屏图片显示应用 - 适用于海光x86架构国产电脑
Exec=/opt/image-viewer/image-viewer
Icon=$ICON_PATH
Terminal=false
Categories=Graphics;Viewer;
StartupNotify=true
Keywords=image;viewer;fullscreen;
EOF

# 创建 DEB 包
echo "正在构建 DEB 包..."
fakeroot dpkg-deb --build "$DEB_DIR"
DEB_FILE="${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
echo ""

if [ -f "$DEB_FILE" ]; then
    echo "======================================"
    echo "✓ DEB 包创建成功！"
    echo "======================================"
    echo ""
    echo "安装包: $DEB_FILE"
    echo "大小: $(du -h $DEB_FILE)"
    echo ""
    echo "安装方法："
    echo "sudo dpkg -i $DEB_FILE"
    echo ""
    echo "卸载方法："
    echo "sudo dpkg -r image-viewer"
    echo ""
else
    echo "✗ DEB 包创建失败！"
    exit 1
fi

# 清理临时目录
rm -rf "$DEB_DIR"
