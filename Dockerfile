# =====================================================
# 银河麒麟操作系统应用打包 Docker 镜像
# 基于 Ubuntu 22.04（与麒麟系统高度兼容）
# =====================================================

FROM ubuntu:22.04

# 设置非交互模式，避免安装过程中的提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置工作目录
WORKDIR /app

# 安装系统依赖（Tkinter 和图形界面所需库）
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-tk \
    tk-dev \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxft-dev \
    libxtst-dev \
    libxt-dev \
    libsm-dev \
    libice-dev \
    file \
    && rm -rf /var/lib/apt/lists/*

# 创建符号链接，使 python3 可以用 python 调用
RUN ln -s /usr/bin/python3 /usr/bin/python

# 复制项目文件
COPY requirements.txt .
COPY TkinterSample.py .
COPY config.json .
COPY sample.jpg .

# 安装 Python 依赖
RUN pip3 install --no-cache-dir -r requirements.txt
RUN pip3 install --no-cache-dir pyinstaller

# 执行打包命令
RUN echo "========================================" && \
    echo "开始打包..." && \
    echo "========================================" && \
    pyinstaller --name="image-viewer" \
        --onefile \
        --windowed \
        --add-data "config.json:." \
        --add-data "sample.jpg:." \
        --clean \
        TkinterSample.py && \
    echo "========================================" && \
    echo "打包完成！" && \
    echo "========================================" && \
    file dist/image-viewer && \
    ls -lh dist/

# 默认命令：显示打包结果
CMD ["bash", "-c", "echo '打包完成！可执行文件位于 dist/image-viewer'"]
