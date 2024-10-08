# Hysteria 2 高级配置工具

## 一键命令

    bash <(curl -Ls Hysteria.sh)
> 提示：您需要在 root 用户下或以 sudo 权限运行

## 概述
Hysteria 2 高级配置工具（Hysteria 2 Advanced Configuration Tool）是一个方便、快捷地用于配置和管理 Hysteria 2 的 Bash 脚本工具。该工具旨在简化 Hysteria 2 的安装、配置、启动、停止、重启、卸载等操作，并提供丰富的高级设置选项，如端口跳跃、系统缓冲区调整、查看相关配置和常用工具等。我非常高兴可以将该脚本分享给对于 Hysteria 2 有着轻松配置管理需求的用户！

## 功能概览
**1. 安装/更新 Hysteria 2 最新版本**
- 安装/更新 Hysteria 2 最新版本
- 检查安装/更新结果

**2. 安装/更新 Hysteria 2 指定版本**
- 安装/更新指定版本号的 Hysteria 2
- 检查安装/更新结果

**3. 编辑服务端配置文件**
    1. 自备域名搭建
        * 指定端口号（检测占用）
        * 指定域名（检测解析）
        * 生成密码
    2. 无域名搭建
        * 指定端口号（检测占用）
        * 生成证书和密钥
        * 生成密码

**4. 启动 Hysteria 2 并查看服务状态**
    1. 启动通过自备域名搭建的 Hysteria 2 服务
        *  检测端口号占用
        *  检测域名解析
        *  检查证书申请网络环境
        *  启动并检测运行状态
    2. 启动通过无域名搭建的 Hysteria 2 服务
        * 检测端口号占用
        * 检查证书
        * 启动并检测运行状态

**5. 设置端口跳跃**
- 自定义端口跳跃范围
- 根据系统使用的防火墙自动配置端口跳跃

**6. 设置系统缓冲区**

**7. 停止 Hysteria 2**

**8. 重启 Hysteria 2**

**9. 卸载 Hysteria 2**
- 一键卸载 Hysteria 2 服务及相关配置、文件
- 卸载 Hysteria 2 主程序
- 删除配置文件和 ACME 证书
- 禁用 Hysteria 2 相关系统服务

**10. 打印（查询）相关配置**
- 一键打印客户端所需配置参数
- Hysteria 2 服务监听的端口号
- 域名
- 密码
- 证书和私钥保存路径

**11. 常用工具**
- 域名解析检测
- 端口占用检测
- 查看防火墙配置内容

## **脚本运行要求**

- 运行系统在已验证系统列表中
- root 用户或使用 sudo 命令

## **已验证系统**

- [x] Debian 11
- [x] Debian 12
