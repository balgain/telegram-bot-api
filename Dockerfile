# 使用一个包含构建工具的基础镜像
FROM ubuntu:20.04

# 设置环境变量，避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装编译所需的依赖项
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git \
    cmake \
    gperf \
    zlib1g-dev \
    libssl-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /usr/src/telegram-bot-api

# 将项目文件复制到容器中
COPY . .

# 创建并进入构建目录
RUN mkdir -p build && cd build && \
    # 运行 cmake 来配置项目
    cmake .. && \
    # 编译项目
    cmake --build . --target telegram-bot-api

# 暴露 API 服务器的默认端口
EXPOSE 8081

# 设置容器启动时执行的命令
# 您需要在这里替换为您的 API_ID 和 API_HASH
# CMD ["./build/telegram-bot-api", "--api-id=<YOUR_API_ID>", "--api-hash=<YOUR_API_HASH>", "--local"]
# 为了通用性，我们使用 entrypoint
ENTRYPOINT ["./build/telegram-bot-api"]
