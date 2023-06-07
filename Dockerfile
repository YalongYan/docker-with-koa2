# FROM 表示设置要制作的镜像基于哪个镜像，FROM指令必须是整个Dockerfile的第一个指令，如果指定的镜像不存在默认会自动从Docker Hub上下载。
# 如果不指定版本，会默认使用latest,就是最新版本
FROM node:14.3.0

# 创建文件夹 这个文件夹是node环境下的
RUN mkdir -p /app/koa2-demo/

# 将根目录下的文件都copy到container（运行此镜像的容器）文件系统的文件夹下
COPY . /app/koa2-demo

# WORKDIR指令用于设置Dockerfile中的RUN、CMD和ENTRYPOINT指令执行命令的工作目录(默认为/目录)，该指令在Dockerfile文件中可以出现多次，如果使用相对路径则为相对于WORKDIR上一次的值，
# 例如WORKDIR /data，WORKDIR logs，RUN pwd最终输出的当前目录是/data/logs。
# cd到 /app/koa2-demo
WORKDIR /app/koa2-demo

# 安装项目依赖包
RUN npm install --registry=https://registry.npm.taobao.org


# 容器对外暴露的端口号(这个3000 必须是当前node项目的端口)
EXPOSE 3000

# 容器启动时执行的命令，类似npm run start
CMD ["npm", "start"]
