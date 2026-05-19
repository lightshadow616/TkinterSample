# 全屏图片显示应用

适用于海光 x86 架构国产电脑（银河麒麟操作系统 V11）的全屏图片显示应用。

## 功能特性

- ✓ 全屏显示图片
- ✓ 自动适应屏幕大小（保持宽高比）
- ✓ 通过配置文件指定图片路径
- ✓ 按 ESC 键退出
- ✓ 支持窗口大小变化时自动调整
- ✓ 打包为独立可执行文件（无需安装 Python）
- ✓ 桌面快捷方式图标（类似 Windows 快捷方式）

## 系统要求

- **操作系统**: 银河麒麟操作系统 V11（基于 Linux 6.6 内核）
- **硬件架构**: 海光 x86_64
- **Python**: Python 3.6+（仅开发时需要，运行打包后的程序不需要）

## 快速开始

### 方式一：Docker 交叉编译（Windows/Mac 用户推荐）⭐

在 Windows 或 Mac 上使用 Docker 为麒麟系统打包，**无需安装虚拟机**！

**Windows:**

```bash
docker-build-windows.bat
```

**Linux/Mac:**

```bash
chmod +x docker-build-linux.sh
./docker-build-linux.sh
```

详细说明请查看 [Docker打包指南.md](Docker打包指南.md)

### 方式二：在麒麟系统上直接打包（最简单）

将项目复制到麒麟系统后：

```bash
# 一键打包和安装
chmod +x build.sh
./build.sh
```

完成后桌面上会出现应用图标，双击即可启动！

### 方式三：从源码运行

```bash
# 1. 安装依赖
pip install -r requirements.txt

# 2. 配置图片路径（编辑 config.json）
nano config.json

# 3. 运行应用
python3 TkinterSample.py
```

## 配置说明

编辑 `config.json` 文件：

```json
{
  "image_path": "sample.jpg",
  "window_title": "图片查看器",
  "app_name": "我的应用"
}
```

配置项说明：

- `image_path`: 要显示的图片路径（支持相对路径和绝对路径）
- `window_title`: 窗口标题
- `app_name`: **桌面图标显示的名称**（打包时使用，可自定义）

## 打包部署

详细部署说明请查看 [部署说明.md](部署说明.md)

### 主要脚本

- `build.sh` - 一键打包和安装（包含创建桌面快捷方式）
- `install-system.sh` - 系统级安装（所有用户可用，需要 root 权限）
- `install-desktop-shortcut.sh` - 单独创建桌面快捷方式

## 使用说明

1. **启动应用**：双击桌面上的"图片查看器"图标
2. **退出应用**：按 `ESC` 键

## 项目结构

```
TkinterSample/
├── TkinterSample.py              # 主程序源代码
├── config.json                   # 配置文件
├── requirements.txt              # Python 依赖列表
├── sample.jpg                    # 示例图片
├── build.sh                      # 一键打包脚本 ⭐
├── install-system.sh             # 系统级安装脚本
├── install-desktop-shortcut.sh   # 桌面快捷方式安装脚本
├── README.md                     # 项目说明
├── 部署说明.md                   # 详细部署指南
└── dist/
    └── image-viewer              # 打包生成的可执行文件
```

## 技术栈

- **Python 3.6+**
- **Pillow** - 图像处理库
- **Tkinter** - GUI 框架
- **PyInstaller** - 打包工具

## 常见问题

**Q: 桌面图标不显示？**
A: 确保 `.desktop` 文件有执行权限：`chmod +x ~/Desktop/image-viewer.desktop`

**Q: 如何更改显示的图片？**
A: 编辑 `~/.local/share/applications/image-viewer/config.json` 中的 `image_path` 字段

**Q: 应用无法启动？**
A: 在终端中运行 `~/.local/share/applications/image-viewer/image-viewer` 查看错误信息

更多问题请查看 [部署说明.md](部署说明.md) 的故障排除章节。

## 许可证

本项目仅供学习和内部使用。

---

**祝您使用愉快！**
