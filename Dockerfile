# 使用更新的、包含构建工具的基础镜像
FROM ubuntu:22.04 AS builder

# 设置环境变量，避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装编译所需的所有依赖项
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git \
    cmake \
    gperf \
    zlib1g-dev \
    libssl-dev \
    libreadline-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /usr/src/telegram-bot-api

# 将项目文件复制到容器中
COPY . .

# 创建并进入构建目录，并以 Release 模式进行编译
RUN mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --target install

# --- 创建最终的、更小的镜像 ---
FROM ubuntu:22.04

# 安装运行时的最小依赖
RUN apt-get update && \
    apt-get install -y \
    libssl-dev \
    zlib1g-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 从构建器阶段复制编译好的二进制文件
COPY --from=builder /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api

# 暴露 API 服务器的默认端口
EXPOSE 8081

# 设置容器启动时执行的命令
ENTRYPOINT ["/usr/local/bin/telegram-bot-api"]
