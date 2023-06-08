# docker-with-koa2
use docker to deploy koa2 program

这里使用 `koa2` 做为演示项目，使用 `Dockerfile` 构建 `Docker` 镜像，项目 `Git` 地址： [仓库地址](https://github.com/YalongYan/docker-with-koa2)

### 安装Docker
网上都有教程可以自行查找，这里演示的环境是在mac下进行的
### 在node项目根目录下创建 Dockerfile 文件
项目目录如下：

![](https://img2023.cnblogs.com/blog/872412/202306/872412-20230607161415155-1745275241.png)

`Dockerfile` 文件内容如下：
```
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
```
### 构建镜像
构建方法如下
```
docker build -t koa2-demo:1.0 .
```
>-t 是 镜像名字
1.0 是镜像版本，不写版本，默认就是latest
.  指定镜像构建过程中的上下文环境的目录

构建成功后执行,查看镜像列表
```
docker image ls
```
如下图所示，就是构建成功了

![](https://img2023.cnblogs.com/blog/872412/202306/872412-20230607162401891-842880330.png)

### 运行容器
运行容器代码：
```
docker run -d -p 4000:3000 --name="koa2" koa2-demo:1.0
```
> -d 是在后台执行
-p 是端口映射，这里4000:3000 意思是电脑的4000端口 映射到容器内的3000端口
--name 是容器的名字
最后是执行使用的镜像， 镜像必须指明版本，不然就默认 latest

执行` docker ps` 可以查看运行中的容器,如下图所示

![](https://img2023.cnblogs.com/blog/872412/202306/872412-20230607163113642-1406121351.png)

本地访问：[http://localhost:4000/](http://localhost:4000/)  页面可以正常访问

### Pm2项目下的Docker启动方式
大部分node.js项目都是用pm2 守护进程的，Dockerfile 改成如下方式
```
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
RUN npm install pm2 -g --registry=https://registry.npm.taobao.org

# 容器对外暴露的端口号(这个3000 必须是当前node项目的端口)
EXPOSE 3000

# 容器启动时执行的命令，类似npm run start
# CMD ["npm", "start"]
# CMD ["pm2-runtime", "pm2.json"]
CMD ["pm2", "pm2.json"]

```
上面代码的启动方式就是执行了 `pm2 start pm2.json`
但是发现容器起不来，是因为pm2 的启动方式是在后台运行，Docker 会以为没有程序在运行，所以需要做下调整，新的Dockerfile 内容如下：
```
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
RUN npm install pm2 -g --registry=https://registry.npm.taobao.org

# 容器对外暴露的端口号(这个3000 必须是当前node项目的端口)
EXPOSE 3000

# 容器启动时执行的命令，类似npm run start
# CMD ["npm", "start"]
CMD ["pm2-runtime", "pm2.json"]

```
就只是把 `pm2 start pm2.json` 改为 `pm2-runtime start pm2.json` 即可

### Docker 常用命令
- docker image ls  # 查看本地镜像  
- docker images # 查看本地镜像
- docker ps  # 查看运行中的容器，停止状态的容器不展示
- docker ps - a # 查看全部容器，包括停止状态的容器
- docker logs 容器id  # 查看容器的日志， 容器id不用输入全部，一般输入容器id的前三位就行
- docker exec -it 容器id bash # 进入容器内部， 在容器内部 输入 exit 退出容器
- docker stop 容器id # 关闭容器
- docker rm 容器id # 删除容器
- docker rmi 镜像id # 删除镜像
