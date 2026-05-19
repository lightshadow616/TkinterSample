# Docker 交叉编译打包指南

## 概述

本方案使用 Docker 容器在任意操作系统上为银河麒麟系统（Linux）打包应用。

### 优势

- ✅ **跨平台** - Windows、Mac、Linux 均可使用
- ✅ **环境隔离** - 不污染本地 Python 环境
- ✅ **完全兼容** - 基于 Ubuntu 22.04，与麒麟系统高度兼容
- ✅ **可重复** - 每次打包都在干净的环境中进行
- ✅ **轻量级** - 无需安装虚拟机或双系统

---

## 前置要求

### 1. 安装 Docker

**Windows:**

- 下载：<https://www.docker.com/products/docker-desktop>
- 安装后重启电脑
- 确保 Docker Desktop 正在运行

**Mac:**

- 下载：<https://www.docker.com/products/docker-desktop>
- 安装并启动 Docker Desktop

**Linux (Ubuntu/Debian):**

```bash
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
```

**Linux (CentOS/RHEL):**

```bash
sudo yum install docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 2. 验证 Docker 安装

```bash
docker --version
docker info
```

---

## 使用方法

### Windows 用户

1. **打开命令提示符或 PowerShell**
   - 按 `Win + R`，输入 `cmd`，回车

2. **进入项目目录**

   ```bash
   cd d:\Custom_Space\AI_Work\TkinterSample
   ```

3. **运行打包脚本**

   ```bash
   docker-build-windows.bat
   ```

4. **等待打包完成**
   - 首次运行需要下载基础镜像（约 5-10 分钟）
   - 后续运行只需 2-3 分钟

5. **获取打包结果**
   - 位置：`dist-linux\image-viewer`

---

### Linux/Mac 用户

1. **打开终端**

2. **进入项目目录**

   ```bash
   cd /path/to/TkinterSample
   ```

3. **添加执行权限**

   ```bash
   chmod +x docker-build-linux.sh
   ```

4. **运行打包脚本**

   ```bash
   ./docker-build-linux.sh
   ```

5. **等待打包完成**

6. **获取打包结果**
   - 位置：`dist-linux/image-viewer`

---

## 手动执行（不使用脚本）

如果您想手动执行每一步：

### 步骤 1: 构建 Docker 镜像

```bash
docker build -t kylin-packager .
```

### 步骤 2: 运行容器

```bash
docker run --name temp-packager kylin-packager
```

### 步骤 3: 提取文件

```bash
# 创建输出目录
mkdir -p dist-linux

# 复制可执行文件
docker cp temp-packager:/app/dist/image-viewer dist-linux/

# 复制配置文件和图片
docker cp temp-packager:/app/config.json dist-linux/
docker cp temp-packager:/app/sample.jpg dist-linux/

# 清理临时容器
docker rm temp-packager

# 复制安装脚本
cp install-system.sh dist-linux/
cp install-desktop-shortcut.sh dist-linux/
```

---

## 部署到麒麟系统

### 方法一：系统级安装（推荐）

```bash
# 在麒麟系统上
cd dist-linux
chmod +x *.sh
sudo ./install-system.sh
```

这会将应用安装到 `/opt/image-viewer/`，所有用户可用。

### 方法二：用户级安装

```bash
# 在麒麟系统上
cd dist-linux
chmod +x *.sh
./install-desktop-shortcut.sh
```

这会为当前用户创建桌面快捷方式。

---

## 自定义配置

### 修改应用名称

编辑 `config.json`：

```json
{
  "image_path": "sample.jpg",
  "window_title": "图片查看器",
  "app_name": "我的应用名称"
}
```

然后重新运行打包脚本。

### 更换图片

将您的图片文件放到项目目录，修改 `config.json` 中的 `image_path`：

```json
{
  "image_path": "my-photo.jpg"
}
```

---

## 故障排除

### 问题 1: Docker 未运行

**Windows/Mac:**

- 启动 Docker Desktop
- 等待系统托盘图标显示 "Docker is running"

**Linux:**

```bash
sudo systemctl start docker
sudo systemctl enable docker  # 开机自启
```

### 问题 2: 权限不足（Linux）

```bash
# 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 重新登录或执行
newgrp docker
```

### 问题 3: 磁盘空间不足

```bash
# 清理未使用的 Docker 资源
docker system prune -a

# 查看 Docker 占用空间
docker system df
```

### 问题 4: 网络问题导致下载失败

```bash
# 配置 Docker 镜像加速器（中国用户）
# 编辑 /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}

# 重启 Docker
sudo systemctl restart docker
```

### 问题 5: 打包后文件无法在麒麟系统运行

检查架构兼容性：

```bash
# 在打包后的机器上
file dist-linux/image-viewer

# 应该显示: ELF 64-bit LSB executable, x86-64
```

麒麟系统海光 CPU 是 x86_64 架构，应该完全兼容。

---

## 高级用法

### 修改 Dockerfile

如果需要调整打包环境，可以编辑 `Dockerfile`：

```dockerfile
# 更改 Python 版本
FROM ubuntu:22.04

# 添加额外的系统库
RUN apt-get install -y your-library

# ...其他配置
```

### 优化构建速度

使用 Docker 缓存层：

```bash
# 先安装依赖（变化少）
docker build --target dependencies -t kylin-base .

# 再打包代码（变化多）
docker build -t kylin-packager .
```

### 保存镜像供离线使用

```bash
# 导出镜像
docker save kylin-packager -o kylin-packager.tar

# 导入镜像（另一台机器）
docker load -i kylin-packager.tar
```

---

## 文件说明

| 文件 | 用途 |
|------|------|
| `Dockerfile` | Docker 镜像配置文件 |
| `.dockerignore` | Docker 忽略文件列表 |
| `docker-build-windows.bat` | Windows 一键打包脚本 |
| `docker-build-linux.sh` | Linux/Mac 一键打包脚本 |
| `dist-linux/` | 打包输出目录 |

---

## 技术细节

### 基础镜像选择

使用 `ubuntu:22.04` 的原因：

- 与麒麟系统 V11 基于相似的 glibc 版本
- 官方维护，稳定性好
- 社区支持完善

### PyInstaller 参数说明

```bash
--onefile          # 打包成单个可执行文件
--windowed         # 不显示控制台窗口
--add-data         # 包含额外文件（config.json, sample.jpg）
--clean            # 清理临时文件
```

### 生成的可执行文件

- 格式：ELF 64-bit LSB executable
- 架构：x86-64
- 大小：约 30-50 MB（包含所有依赖）
- 无需安装 Python 即可运行

---

## 常见问题 FAQ

**Q: 每次打包都需要下载镜像吗？**

A: 不需要。首次构建后会缓存镜像，后续构建只需几秒。

**Q: 可以在没有网络的机器上使用吗？**

A: 可以。先在有网络的机器上构建镜像，然后导出为 tar 文件传输。

**Q: 打包后的文件大小是多少？**

A: 约 30-50 MB，取决于包含的库。

**Q: 能否打包成 RPM/DEB 安装包？**

A: 当前方案生成独立可执行文件。如需 RPM/DEB，需要在麒麟系统上使用 fpm 等工具二次打包。

**Q: Docker 镜像有多大？**

A: 约 500-800 MB（包含所有构建依赖）。

---

## 总结

Docker 交叉编译方案是在 Windows/Mac 上为麒麟 Linux 打包的最佳选择：

- ✅ 无需安装虚拟机
- ✅ 环境干净隔离
- ✅ 完全兼容麒麟系统
- ✅ 操作简单方便

**祝您打包顺利！**
