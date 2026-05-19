# Docker 打包 - 快速开始

## 3 步完成打包

### 步骤 1: 确保 Docker 正在运行

**Windows/Mac:** 启动 Docker Desktop  
**Linux:** `sudo systemctl start docker`

### 步骤 2: 运行打包脚本

**Windows:**

```bash
docker-build-windows.bat
```

**Linux/Mac:**

```bash
chmod +x docker-build-linux.sh
./docker-build-linux.sh
```

### 步骤 3: 获取打包结果

打包完成后，文件位于：`dist-linux/image-viewer`

将此文件和整个 `dist-linux` 文件夹复制到麒麟系统即可使用。

---

## 常用命令

### 清理 Docker 缓存

```bash
docker system prune -a
```

### 查看镜像大小

```bash
docker images | grep kylin-packager
```

### 重新构建（无缓存）

```bash
docker build --no-cache -t kylin-packager .
```

---

## 需要帮助？

详细文档请查看：[Docker打包指南.md](Docker打包指南.md)
