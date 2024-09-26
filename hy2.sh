#!/bin/bash

# 清除屏幕内容
clear

# 颜色定义
GREEN="\033[38;2;91;194;75m"
RED="\033[38;2;217;61;48m"
YELLOW="\033[38;2;251;230;77m"
BLUE="\e[34m"
CYAN="\033[38;2;32;255;218m"     # 青色
MAGENTA="\033[38;2;255;32;140m"  # 洋红色
ORANGE="\033[38;2;247;116;41m"
RESET="\033[0m"

# 自备域名 YAML 模板
yaml_template_1=$(cat <<'EOF'
listen: :$port_number

acme:
  domains:
    - $domain_change
  email: tim_cook@gmail.com

auth:
  type: password
  password: $passwd_change

masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true
EOF
)

# 无域名 YAML 模板
yaml_template_2=$(cat <<'EOF'
listen: :$port_number
 
tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key
 
auth:
  type: password
  password: $passwd_change
 
masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true
EOF
)

# 返回上一级菜单的提示函数
function return_to_sub_menu() {
    while true; do
        echo ""
        echo ""
        read -p "$(echo -e "${ORANGE}请输入数字 0 返回上一级菜单: ")" return_to_sub_choice
        if [ "$return_to_sub_choice" == "0" ]; then
            tput reset
            return
        else
            echo ""
            echo -e "${RED}输入有误！${RESET}"
            echo ""
        fi
    done
}

# 返回主菜单提示函数
function return_to_main_menu() {
while true; do
    echo ""
    echo ""
    echo ""
    read -p "$(echo -e "${ORANGE}请输入数字 0 来返回主菜单: ")" return_to_main_choice
    if [ "$return_to_main_choice" == "0" ]; then
        tput reset
        return 0
    else
        echo ""
        echo -e "${RED}您的输入有误！${RESET}"
        echo ""
    fi
done
}

# 中止当前流程的提示函数
function abort_process() {
    while true; do
        echo ""
        echo ""
        read -p "$(echo -e "${ORANGE}请输入数字 0 返回上一级菜单: ")" abort_process_choice
        if [ "$abort_process_choice" == "0" ]; then
            tput reset
            continue
        else
            echo ""
            echo -e "${RED}输入有误！${RESET}"
            echo ""
        fi
    done
}

# 打印欢迎横幅
echo ""
echo -e "------- Welcome to the Hysteria 2 Advanced Configuration Tool -------"
echo ""
echo ""
echo ""
echo -e " █████   █████  ███         █████   █████ █████ █████ ██████   ██████
░░███   ░░███  ░░░         ░░███   ░░███ ░░███ ░░███ ░░██████ ██████ 
 ░███    ░███  ████         ░███    ░███  ░░███ ███   ░███░█████░███ 
 ░███████████ ░░███         ░███████████   ░░█████    ░███░░███ ░███ 
 ░███░░░░░███  ░███         ░███░░░░░███    ███░███   ░███ ░░░  ░███ 
 ░███    ░███  ░███         ░███    ░███   ███ ░░███  ░███      ░███ 
 █████   █████ █████  ██    █████   █████ █████ █████ █████     █████
░░░░░   ░░░░░ ░░░░░  ██    ░░░░░   ░░░░░ ░░░░░ ░░░░░ ░░░░░     ░░░░░ 
                    ░░                                               
                                                                     
                                                                     "
echo -e "----------------- 欢迎使用 Hysteria 2 高级配置工具 -----------------"

# 检测是否以 root 用户或具有 sudo 权限的用户运行脚本
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo -e "${RED}检测到当前用户非 root 用户，或没有使用 sudo 命令运行脚本！${RESET}"
    echo ""
    echo -e "${YELLOW}请切换为 root 用户或使用 sudo 命令运行该脚本。${RESET}"
    echo ""
    echo -e "${MAGENTA}脚本已自动退出。${RESET}"
    exit 1
fi

# 更新系统和软件包并安装依赖
echo ""
echo -e "${YELLOW}正在更新系统并安装环境依赖……${RESET}"
echo ""
apt-get update > /dev/null && apt-get upgrade -y > /dev/null && apt-get install curl wget unzip openssl sed dnsutils -y  > /dev/null
if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}系统和软件更新失败，请检查相关错误，或手动更新后再次运行脚本。${RESET}"
    echo ""
    echo -e "${MAGENTA}脚本已自动退出。${RESET}"
    echo ""
    exit 1
fi
echo -e "${GREEN}已成功更新系统和软件！${RESET}"

# 显示菜单并处理输入
show_menu() {
    # 清屏
    clear

    while true; do
        # 打印欢迎横幅
        echo ""
        echo -e "------- Welcome to the Hysteria 2 Advanced Configuration Tool -------"
        echo ""
        echo ""
        echo ""
        echo -e " █████   █████  ███         █████   █████ █████ █████ ██████   ██████
░░███   ░░███  ░░░         ░░███   ░░███ ░░███ ░░███ ░░██████ ██████ 
 ░███    ░███  ████         ░███    ░███  ░░███ ███   ░███░█████░███ 
 ░███████████ ░░███         ░███████████   ░░█████    ░███░░███ ░███ 
 ░███░░░░░███  ░███         ░███░░░░░███    ███░███   ░███ ░░░  ░███ 
 ░███    ░███  ░███         ░███    ░███   ███ ░░███  ░███      ░███ 
 █████   █████ █████  ██    █████   █████ █████ █████ █████     █████
░░░░░   ░░░░░ ░░░░░  ██    ░░░░░   ░░░░░ ░░░░░ ░░░░░ ░░░░░     ░░░░░ 
                    ░░                                               

                                                                     "
        echo -e "----------------- 欢迎使用 Hysteria 2 高级配置工具 -----------------"
        # 展示菜单
        echo ""
        echo ""
        echo -e "${ORANGE}请选择您需要的功能：${RESET}"
        echo ""
        echo ""
        echo -e "${GREEN}  1. 安装/更新 Hysteria 2 最新版本${RESET}"
        echo -e "${GREEN}  2. 安装/更新 Hysteria 2 指定版本${RESET}"
        echo ""
        echo ""
        echo -e "${GREEN}  3. 编辑服务端配置文件${RESET}"
        echo -e "${GREEN}  4. 启动 Hysteria 2 并查看服务状态${RESET}"
        echo ""
        echo ""
        echo -e "${GREEN}  5. 设置端口跳跃${RESET}"
        echo -e "${GREEN}  6. 设置系统缓冲区${RESET}"
        echo ""
        echo ""
        echo -e "${GREEN}  7. 停止 Hysteria 2${RESET}"
        echo -e "${GREEN}  8. 重启 Hysteria 2${RESET}"
        echo -e "${GREEN}  9. 卸载 Hysteria 2${RESET}"
        echo ""
        echo ""
        echo -e "${GREEN} 10. 打印相关配置${RESET}"
        echo -e "${GREEN} 11. 常用工具${RESET}"
        echo ""
        echo ""
        echo -e "${YELLOW}  0. 退出脚本${RESET}"
        echo ""

        # 用户输入选择并验证
        read_choice

        # 根据选择执行相应操作
        case $choice in
            1) install_hysteria_latest_version ;;
            2) install_hysteria_specified_version ;;
            3) edit_server_config ;;
            4) start_hysteria_service ;;
            5) set_port_hop ;;
            6) set_buffer_size ;;
            7) stop_hysteria_service ;;
            8) restart_hysteria_service ;;
            9) uninstall_hysteria ;;
            10) print_configuration ;;
            11) common_tools ;;
            0) exit 0 ;;
            *) echo -e "${RED}无效的选择，请重新输入！${RESET}" ;;
        esac
    done
}

# 提示用户输入选择
read_choice() {
    while true; do
        # 第一次提示输入
        echo ""
        read -p "$(echo -e "${RESET}请输入您的选择 [0-11]：${RESET}")" choice
        
        # 验证用户输入是否有效
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -le 11 ]; then
            break  # 输入有效，退出循环
        else
            # 提示用户输入无效，并在提示后重新输入
            echo ""
            echo -e "${RED}您的输入有误！${RESET}"
            echo ""
            read -p "$(echo -e "${RESET}请重新输入您的选择 [0-11]：${RESET}")" choice
            # 验证用户的重新输入
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -le 11 ]; then
                break  # 输入有效，退出循环
            fi
        fi
    done
}

# 1.安装/更新 Hysteria 2 最新版本
install_hysteria_latest_version() {
    # 1. 清屏
    clear

    # 2. 运行安装命令并隐藏输出
    echo ""
    echo ""
    echo -e "${BLUE}正在安装/更新 Hysteria 2 最新版本...${RESET}"
    install_output=$(bash <(curl -fsSL https://get.hy2.sh/) 2>&1)

    # 3. 检查安装结果
    if echo "$install_output" | grep -q -E "Congratulation! Hysteria 2 has been successfully installed on your server.|Hysteria has been successfully update to"; then
        # 安装成功
        echo ""
        echo ""
        echo -e "${GREEN}您已经成功安装/更新 Hysteria 2 最新版本！${RESET}"
    elif echo "$install_output" | grep -q "Installed version is up-to-date, there is nothing to do."; then
        # 系统已安装最新版本
        echo ""
        echo ""
        echo -e "${GREEN}您当前的 Hysteria 2 已经是最新版本！${RESET}"
    else
        # 安装失败
        echo ""
        echo ""
        echo -e "${RED}安装/更新 Hysteria 2 最新版本时遇到了错误！错误信息如下：${RESET}"
        echo ""
        echo -e "${RESET}$install_output${RESET}"
    fi

    # 4. 提示返回主菜单
    return_to_main_menu
}

# 2.安装/更新 Hysteria 2 指定版本
install_hysteria_specified_version() {
    # 1. 清屏
    clear

    # 2. 询问用户需要安装的版本号
    while true; do
        echo ""
        echo ""
        read -p "$(echo -e "${RESET}请输入您需要安装/更新的 Hysteria 2 版本号（如 2.5.1）：${RESET}")" version_number
        # 检查输入是否为合法版本号格式 (例如: 1.0.0)
        if [[ "$version_number" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            break  # 如果格式正确，跳出循环，继续后续流程
        else
            # 如果格式错误，提示并重新让用户输入
            echo ""
            echo -e "${RED}您输入的版本号格式无效！${RESET}"
            echo ""
            read -p "$(echo -e "${RESET}请重新输入您需要安装/更新的 Hysteria 2 版本号（如 2.5.1）：${RESET}")" version_number
        fi
    done

    # 3. 运行安装命令并隐藏输出
    echo ""
    echo ""
    echo -e "${BLUE}正在安装/更新 Hysteria 2 版本 v$version_number...${RESET}"
    install_output=$(bash <(curl -fsSL https://get.hy2.sh/) --version v"$version_number" 2>&1)

    # 4. 检查安装结果
    if echo "$install_output" | grep -q "Hysteria has been successfully updated to v$version_number."; then
        # 更新成功
        echo ""
        echo -e "${GREEN}您已经成功安装/更新 Hysteria 2 v$version_number 版本！${RESET}"
    elif echo "$install_output" | grep -q "Installed version is up-to-date, there is nothing to do."; then
        # 已经是最新版本
        echo ""
        echo -e "${GREEN}您当前的 Hysteria 2 已经是最新版本！${RESET}"
    else
        # 安装失败
        echo ""
        echo -e "${RED}安装/更新 Hysteria 2 v$version_number 版本时遇到了错误！输出信息如下：${RESET}"
        echo ""
        echo -e "${RESET}$install_output${RESET}"
    fi

    # 5. 提示返回主菜单
    return_to_main_menu
}

# 3.编辑服务端配置文件
edit_server_config() {
    while true; do
        # 1. 清屏
        clear

        # 2. 提示信息
        echo -e "${ORANGE}请选择您要搭建 Hysteria 2 的方式：${RESET}"
        echo ""
        echo -e "${GREEN}   1. 自备域名搭建${RESET}"
        echo -e "${GREEN}   2. 无域名搭建${RESET}"
        echo ""
        echo -e "${YELLOW}   0. 返回主菜单${RESET}"
        echo ""
        
        # 让用户输入数字进行选择
        read -p "$(echo -e "${RESET}请输入您的选择 [1/2/0]：${RESET}")" config_choice

        case "$config_choice" in
            1)
                # 自备域名搭建

                # 1. 清屏并输出提示
                clear
                echo -e "${BLUE}准备配置服务端配置文件...${RESET}"

                # 随机生成推荐的可用端口号
                generate_random_port() {
                    while true; do
                        random_port_number=$((RANDOM % 50000 + 10001))
                        
                        if [[ $random_port_number%100 -ne 0 && $random_port_number%1000 -ne 0 && $random_port_number%10000 -ne 0 && "$random_port_number" != $(echo $random_port_number | grep -E '(.)\1{2,}') ]]; then
                            if ! ss -lntu | grep -q ":$random_port_number "; then
                                break
                            fi
                        fi
                    done
                }

                # 2. 让用户输入 Hysteria 2 需要监听的端口，并提供推荐的可用随机端口
                while true; do
                    generate_random_port  # 每次显示时都生成一个新的随机可用端口
                    echo ""
                    echo ""
                    read -p "$(echo -e "${YELLOW}请输入 Hysteria 2 监听端口（按下回车键来使用推荐的可用随机端口 $random_port_number）: ${RESET}")" port_number
                    
                    # 如果用户直接回车，使用推荐的端口，并跳过端口检测
                    if [ -z "$port_number" ]; then
                        port_number=$random_port_number
                        echo ""
                        echo -e "${GREEN}已成功将 $port_number 端口设定为目标监听端口！${RESET}"
                        break
                    else
                        # 用户输入了自定义端口，进行占用检测
                        echo ""
                        echo -e "${BLUE}正在检测端口 $port_number 是否已被占用...${RESET}"

                        check_port() {
                            ss -lntu | grep -q ":$1 "
                        }

                        # 如果端口被占用，提示用户重新输入
                        if check_port "$port_number"; then
                            echo ""
                            echo -e "${RED}端口 $port_number 已被占用！以下是当前系统正在监听的端口：${RESET}"
                            echo ""
                            ss -lntu
                        else
                            echo ""
                            echo -e "${GREEN}已成功将 $port_number 端口设定为目标监听端口！${RESET}"
                            break
                        fi
                    fi
                done

                # 3. 让用户输入域名并检测域名解析
                while true; do
                    echo ""
                    echo ""
                    read -p "$(echo -e "${YELLOW}请输入已解析到本服务器 IP 的域名: ${RESET}")" domain_change
                    echo ""

                    # 允许多级域名的域名格式检测
                    if [[ ! "$domain_change" =~ ^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$ ]]; then
                        echo ""
                        echo -e "${RED}域名格式无效！${RESET}"
                        echo ""
                        read -p "$(echo -e "${YELLOW}请重新输入已解析到本服务器 IP 的有效域名（如 example.com）：${RESET}")" domain_change
                        continue
                    fi

                    echo ""
                    echo -e "${BLUE}正在检测域名是否已解析到本服务器 IP...${RESET}"

                    server_ip=$(curl -s ifconfig.me)
                    
                    # 第一次使用 nslookup 进行域名解析检测
                    domain_ip=$(nslookup $domain_change 2>/dev/null | awk '/^Address: / { print $2 }')

                    if [ -z "$domain_ip" ]; then
                        echo ""
                        echo -e "${RED}第一次检测失败！${RESET}"
                        echo ""
                        echo -e "${BLUE}正在尝试使用备用方案检测…${RESET}"
                        # 备用方案使用 dig 进行域名解析检测
                        sleep 2
                        domain_ip=$(dig +short $domain_change)
                    fi

                    if [ "$domain_ip" == "$server_ip" ]; then
                        echo ""
                        echo -e "${GREEN}$domain_change 已解析到本服务器 IP！${RESET}"
                        break
                    else
                        echo ""
                        echo -e "${RED}$domain_change 尚未解析到本服务器 IP！${RESET}"
                        # 第一次询问用户是否要继续
                        echo ""
                        echo -e "${YELLOW}如果继续，服务端配置文件可以照常编辑，但可能影响 Hysteria 2 服务的启动，是否要继续？${RESET}"
                        echo ""
                        read -p "$(echo -e "${RESET}请输入您的选择 [Yy/Nn]：${RESET}")" user_choice
                        # 输入错误的循环提示
                        while true; do
                            case "$user_choice" in
                                [Yy] | [Yy][Ee][Ss] )
                                    break 2 # 跳出两层循环
                                    ;;
                                [Nn] | [Nn][Oo] )
                                    return
                                    ;;
                                * )
                                    # 只提示无效输入，并直接等待用户再次输入
                                    echo ""
                                    echo -e "${RED}您的输入有误!${RESET}"
                                    echo ""
                                    read -p "$(echo -e "${RESET}请重新输入您的选择 [Yy/Nn]：${RESET}")" user_choice
                                    ;;
                            esac
                        done
                    fi
                done

                # 4. 生成密码

                # 生成 24 个字符的随机密码，包含大写字母、小写字母和数字的函数
                generate_password() {
                    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24
                }

                # 生成
                passwd_change=$(generate_password)

                # 5. 编辑 YAML 配置文件
                echo ""
                echo ""
                echo -e "${BLUE}正在自动编辑服务端配置文件...${RESET}"

                # 检查 YAML 文件并删除
                config_file="/etc/hysteria/config.yaml"
                if [ -f "$config_file" ];then
                    sudo rm -f "$config_file"
                fi

                # 使用预定义的 YAML 模板写入配置文件
                echo "$yaml_template_1" | sudo tee $config_file > /dev/null

                # 替换占位符为实际的端口号和域名
                sudo sed -i "s/\$port_number/$port_number/g" /etc/hysteria/config.yaml
                sudo sed -i "s/\$domain_change/$domain_change/g" /etc/hysteria/config.yaml
                sudo sed -i "s/\$passwd_change/$passwd_change/g" /etc/hysteria/config.yaml

                # 输出成功提示
                echo ""
                echo -e "${GREEN}已成功配置服务端配置文件！${RESET}"

                # 6. 提取并打印配置文件中的关键参数
                config_port_number=$(grep '^listen:' /etc/hysteria/config.yaml | grep -Eo ':[0-9]+' | sed 's/^://')
                config_domain=$(grep -m 1 'domains:' -A 1 /etc/hysteria/config.yaml | grep -Eo '^[[:space:]]*-[[:space:]]*[^[:space:]#]+' | sed 's/^[[:space:]]*-[[:space:]]*//')
                config_passwd=$(grep '^  password:' /etc/hysteria/config.yaml | sed -E 's/^[[:space:]]*password:[[:space:]]*//;s/[[:space:]]+#.*//')
                
                echo ""
                echo ""
                echo -e "${ORANGE}已为您打印服务端配置文件的关键参数如下：${RESET}"
                echo ""
                echo -e "${CYAN}端口号：${RESET}$config_port_number"
                echo -e "${CYAN}域名：${RESET}$config_domain"
                echo -e "${CYAN}密码：${RESET}$config_passwd"

                # 7. 提示返回子菜单
                return_to_sub_menu
                ;;
            2)
                # 无域名搭建
                
                # 1. 清屏并输出提示
                clear
                echo -e "${BLUE}准备配置服务器配置文件...${RESET}"

                # 随机生成推荐的可用端口号
                generate_random_port() {
                    while true; do
                        random_port_number=$((RANDOM % 50000 + 10001))
                        
                        if [[ $random_port_number%100 -ne 0 && $random_port_number%1000 -ne 0 && $random_port_number%10000 -ne 0 && "$random_port_number" != $(echo $random_port_number | grep -E '(.)\1{2,}') ]]; then
                            if ! ss -lntu | grep -q ":$random_port_number "; then
                                break
                            fi
                        fi
                    done
                }

                # 2. 让用户输入 Hysteria 2 需要监听的端口，并提供推荐的可用随机端口
                while true; do
                    generate_random_port  # 每次显示时都生成一个新的随机可用端口
                    echo ""
                    read -p "$(echo -e "${YELLOW}请输入 Hysteria 2 监听端口（按下回车键来使用推荐的可用随机端口 $random_port_number）: ${RESET}")" port_number
                    
                    # 如果用户直接回车，使用推荐的端口，并跳过端口检测
                    if [ -z "$port_number" ]; then
                        port_number=$random_port_number
                        echo ""
                        echo -e "${GREEN}端口 $port_number 可以使用。已成功将其设定为目标监听端口！${RESET}"
                        break
                    else
                        # 用户输入了自定义端口，进行占用检测
                        echo ""
                        echo -e "${BLUE}正在检测端口 $port_number 是否已被占用...${RESET}"

                        check_port() {
                            ss -lntu | grep -q ":$1 "
                        }

                        # 如果端口被占用，提示用户重新输入
                        if check_port "$port_number"; then
                            echo ""
                            echo -e "${RED}端口 $port_number 已经被占用。以下是当前系统正在监听的端口：${RESET}"
                            echo ""
                            ss -lntu
                        else
                            echo ""
                            echo -e "${GREEN}端口 $port_number 可以使用。已成功将其设定为目标监听端口！${RESET}"
                            break
                        fi
                    fi
                done

                # 3. 生成自有证书
                echo ""
                echo ""
                echo -e "${BLUE}正在生成自有证书...${RESET}"
                openssl_output=$(openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /etc/hysteria/server.key -out /etc/hysteria/server.crt -subj "/CN=bing.com" -days 36500 2>&1 >/dev/null && sudo chown hysteria /etc/hysteria/server.key && sudo chown hysteria /etc/hysteria/server.crt)

                # 检查命令执行是否成功
                if [ $? -eq 0 ]; then
                    echo ""
                    echo -e "${GREEN}自有证书生成成功！${RESET}"
                else
                    echo ""
                    echo -e "${RED}生成证书时发生错误！错误信息如下：${RESET}"
                    echo ""
                    echo -e "$openssl_output${RESET}"  # 输出错误信息
                    echo ""
                    # 第一次询问用户是否要继续
                    echo ""
                    echo -e "${YELLOW}如果继续，服务端配置文件可以照常编辑，但可能影响 Hysteria 2 服务的启动，是否要继续？${RESET}"
                    echo ""
                    read -p "$(echo -e "${RESET}请输入您的选择 [Yy/Nn]：${RESET}")" user_choice
                    # 输入错误的循环提示
                    while true; do
                        case "$user_choice" in
                            [Yy] | [Yy][Ee][Ss] )
                                break
                                ;;
                            [Nn] | [Nn][Oo] )
                                return
                                ;;
                            * )
                                # 只提示无效输入，并直接等待用户再次输入
                                echo ""
                                echo -e "${RED}您的输入有误!${RESET}"
                                echo ""
                                read -p "$(echo -e "${RESET}请重新输入您的选择 [Yy/Nn]：${RESET}")" user_choice
                                ;;
                        esac
                    done
                fi

                # 4. 生成密码

                # 生成 24 个字符的随机密码，包含大写字母、小写字母和数字的函数
                generate_password() {
                    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24
                }
                
                # 生成
                passwd_change=$(generate_password)

                # 5. 编辑 YAML 配置文件
                echo ""
                echo ""
                echo -e "${BLUE}正在自动编辑服务端配置文件...${RESET}"

                # 检查 YAML 文件并删除
                config_file="/etc/hysteria/config.yaml"
                if [ -f "$config_file" ];then
                    sudo rm -f "$config_file"
                fi

                # 使用预定义的 YAML 模板写入配置文件
                echo "$yaml_template_2" | sudo tee $config_file > /dev/null

                # 替换占位符为实际的端口号和域名
                sudo sed -i "s/\$port_number/$port_number/g" /etc/hysteria/config.yaml
                sudo sed -i "s/\$passwd_change/$passwd_change/g" /etc/hysteria/config.yaml

                # 输出成功提示
                echo ""
                echo -e "${GREEN}已成功配置服务端配置文件！${RESET}"

                # 6. 提取并打印配置文件中的关键参数
                config_port_number=$(grep '^listen:' /etc/hysteria/config.yaml | grep -Eo ':[0-9]+' | sed 's/^://')
                config_passwd=$(grep '^  password:' /etc/hysteria/config.yaml | sed -E 's/^[[:space:]]*password:[[:space:]]*//;s/[[:space:]]+#.*//')
                
                echo ""
                echo ""
                echo -e "${ORANGE}已为您打印服务端配置文件的关键参数如下：${RESET}"
                echo ""
                echo -e "${CYAN}端口号：${RESET}$config_port_number"
                echo -e "${CYAN}密码：${RESET}$config_passwd"
                echo ""
                echo -e "${CYAN}自签证书保存路径：${RESET}/etc/hysteria/server.crt"
                echo -e "${CYAN}私钥保存路径：${RESET}/etc/hysteria/server.key"

                # 7. 提示返回子菜单
                return_to_sub_menu
                ;;
            0)
                # 返回主菜单
                tput reset
                return 0
                ;;
            *)
                # 无效输入，提示并重新读取输入
                echo ""
                echo -e "${RED}您的输入有误！${RESET}"
                echo ""
                read -p "$(echo -e "${RESET}请重新您的输入选择 [1/2/0]：${RESET}")" config_choice
                ;;
        esac
    done
}

# 4.启动 Hysteria 2 并查看服务状态
start_hysteria_service() {
    while true; do
        # 1. 清屏
        clear

        # 2. 提示信息
        echo -e "${ORANGE}请根据您搭建 Hysteria 2 的方式来选择启动模式：${RESET}"
        echo ""
        echo -e "${GREEN}   1. 启动通过自备域名搭建的 Hysteria 2 服务${RESET}"
        echo -e "${GREEN}   2. 启动通过无域名搭建的 Hysteria 2 服务${RESET}"
        echo ""
        echo -e "${YELLOW}   0. 返回主菜单${RESET}"
        echo ""
        
        # 让用户输入数字进行选择
        read -p "$(echo -e "${RESET}请输入您的选择 [1/2/0]：${RESET}")" config_choice

        case "$config_choice" in
            1)
                # 启动通过自备域名搭建的 Hysteria 2 服务

                # 1. 清屏
                clear
                echo -e "${BLUE}准备检查 Hysteria 2 启动环境…${RESET}"

                # 2a. 读取配置文件中的端口号并检测是否被占用
                echo ""
                echo ""
                echo -e "${BLUE}正在检查端口号配置…${RESET}"
                config_port_number=$(grep '^listen:' /etc/hysteria/config.yaml | grep -Eo ':[0-9]+' | sed 's/^://')

                if [ -n "$config_port_number" ]; then
                    echo ""
                    echo -e "${RESET}检测到 Hysteria 2 监听的端口号为: $config_port_number${RESET}"
                    echo ""
                    echo ""
                    echo -e "${BLUE}正在检查端口号是否被占用…${RESET}"
                    if ss -lntu | grep -q ":$config_port_number "; then
                        echo ""
                        echo -e "${RED}端口号 $config_port_number 已被占用！${RESET}"
                        echo ""
                        echo -e "${YELLOW}即将中止启动流程…${RESET}"
                        # 跳转到 # 5 提示返回子菜单
                        abort_process
                    else
                        echo ""
                        echo -e "${GREEN}端口 $config_port_number 可正常使用！${RESET}"
                    fi
                else
                    echo ""
                    echo -e "${RED}未在配置文件中检测到端口号！请检查配置文件。${RESET}"
                    echo ""
                    echo -e "${YELLOW}即将中止启动流程…${RESET}"
                    # 跳转到 # 5 提示返回子菜单
                    abort_process
                fi

                # 2b. 检查是否存在域名并检测域名解析
                echo ""
                echo ""
                echo -e "${BLUE}正在检查域名配置…${RESET}"

                # 使用 grep 读取域名并处理注释和空值
                config_domain=$(grep -m 1 'domains:' -A 1 /etc/hysteria/config.yaml | grep -Eo '^[[:space:]]*-[[:space:]]*[^[:space:]#]+' | sed 's/^[[:space:]]*-[[:space:]]*//')

                if [ -n "$config_domain" ]; then
                    echo ""
                    echo -e "${RESET}检测到配置文件中的自备域名为: $config_domain${RESET}"
                    
                    # 获取服务器的 IP
                    server_ip=$(curl -s ifconfig.me)

                    # 优先使用 nslookup 检测域名解析 IP
                    echo ""
                    echo -e "${BLUE}正在检测自备域名的解析记录…${RESET}"
                    domain_ip=$(nslookup $config_domain | awk '/^Address: / { print $2 }')

                    # 如果 nslookup 没有检测到结果，则启用备用方案 dig
                    if [ -z "$domain_ip" ]; then
                        echo ""
                        echo -e "${RED}第一次检测失败！${RESET}"
                        echo ""
                        echo -e "${BLUE}正在尝试使用备用方案检测…${RESET}"
                        domain_ip=$(dig +short $config_domain)
                    fi

                    # 判断解析的 IP 是否与服务器 IP 匹配
                    if [ -n "$domain_ip" ] && [ "$domain_ip" == "$server_ip" ]; then
                        echo ""
                        echo -e "${GREEN}自备域名 $config_domain 已正确解析到服务器 IP！${RESET}"
                    else
                        echo ""
                        echo -e "${RED}自备域名 $config_domain 尚未解析到服务器 IP！${RESET}"
                        echo ""
                        echo -e "${YELLOW}即将中止启动流程…${RESET}"
                        # 跳转到 # 5 提示返回子菜单
                        abort_process
                    fi
                else
                    echo ""
                    echo -e "${RED}未在配置文件中检测到域名！请检查配置文件。${RESET}"
                    echo ""
                    echo -e "${YELLOW}即将中止启动流程…${RESET}"
                    # 跳转到 # 5 提示返回子菜单
                    abort_process
                fi

                # 2c. 检查 80 端口是否被占用
                echo ""
                echo ""
                echo -e "${BLUE}准备检查自备域名的 TLS 证书获取环境…${RESET}"
                echo ""
                echo -e "${BLUE}正在检查 80 端口是否被占用…${RESET}"

                if ss -lntu | grep -q ":80 "; then
                    echo ""
                    echo -e "${RED}80 端口已被占用！${RESET}"
                    echo ""
                    echo -e "${YELLOW}请在系统中自行释放 80 端口，以便 Hysteria 2 启动时可以顺利为自备域名申请 TLS 证书。${RESET}"
                    echo ""
                    echo -e "${YELLOW}即将中止启动流程…${RESET}"
                    # 跳转到 # 5 提示返回子菜单
                    abort_process
                else
                    echo ""
                    echo -e "${GREEN}80 端口状态正常！${RESET}"
                fi

                # 3. 启动 Hysteria 2 服务

                # 启用 Hysteria 2 服务并隐藏输出
                echo ""
                echo ""
                echo -e "${BLUE}正在为 Hysteria 2 服务启用持久化配置…${RESET}"
                enable_output=$(systemctl enable hysteria-server.service 2>&1 > /dev/null)
                if [ $? -eq 0 ]; then
                    echo ""
                    echo -e "${GREEN}已成功为 Hysteria 2 服务启用持久化配置！${RESET}"
                else
                    echo ""
                    echo -e "${RED}为 Hysteria 2 服务启用持久化配置失败！以下是错误信息: ${RESET}"
                    echo ""
                    echo -e "${RESET}${enable_output}${RESET}"
                    echo ""
                    echo -e "${YELLOW}即将中止启动流程…${RESET}"
                    abort_process
                fi

                # 隐藏输出启动 Hysteria 2 服务并捕获错误信息
                echo ""
                echo ""
                echo -e "${BLUE}正在发送启动 Hysteria 2 服务的指令…${RESET}"
                start_output=$(systemctl start hysteria-server.service 2>&1 > /dev/null)
                if [ $? -eq 0 ]; then
                    echo ""
                    echo -e "${GREEN}Hysteria 2 服务启动指令发送成功！${RESET}"
                else
                    echo ""
                    echo -e "${RED}Hysteria 2 服务启动指令发送失败！以下是错误信息: ${RESET}"
                    echo ""
                    echo -e "${RESET}${start_output}${RESET}"
                    echo ""
                    echo -e "${YELLOW}即将中止启动流程…${RESET}"
                    abort_process
                fi

                # 4. 检测 Hysteria 2 的运行状态
                echo ""
                echo ""
                echo -e "${BLUE}正在检测 Hysteria 2 的启动结果和运行状态…${RESET}"

                # 定义一个函数来检测服务状态
                check_hysteria_status() {
                    # 运行 systemctl status 命令并隐藏输出，捕获返回内容
                    status_output=$(systemctl status hysteria-server.service 2>&1)
                    
                    # 检查返回内容中是否同时包含 'server up and running' 和 'active (running)'
                    if echo "$status_output" | grep -q "server up and running" && echo "$status_output" | grep -q "active (running)"; then
                        return 0  # 成功
                    else
                        return 1  # 失败
                    fi
                }

                # 定义最大检测次数
                max_attempts=3

                # 尝试第一次检测
                sleep 3
                for attempt in $(seq 1 $max_attempts); do
                    if check_hysteria_status; then
                        echo ""
                        echo ""
                        echo -e "${GREEN}Hysteria 2 服务已成功启动并运行！${RESET}"
                        break
                    else
                        if [ "$attempt" -lt "$max_attempts" ]; then
                            # 等待 2 秒后尝试第二次检查，等待 3 秒后尝试第三次检查
                            sleep $((attempt + 1))
                            echo ""
                            echo -e "${YELLOW}暂未检测到正向信息，正在进行第 $((attempt + 1)) 次检测…${RESET}"
                        else
                            # 如果三次检测都失败，输出错误信息
                            echo ""
                            echo -e "${RED}Hysteria 2 服务启动和运行失败！以下是运行状态信息：${RESET}"
                            echo ""
                            echo -e "${RESET}$status_output${RESET}"
                        fi
                    fi
                done

                # 5. 提示返回子菜单
                return_to_sub_menu
                ;;
            2)
                # 启动通过无域名搭建的 Hysteria 2 服务

                # 1. 清屏
                clear
                echo -e "${BLUE}准备检查 Hysteria 2 启动环境…${RESET}"

                # 2a. 读取配置文件中的端口号并检测是否被占用
                echo ""
                echo ""
                echo -e "${BLUE}正在检查端口号配置…${RESET}"
                config_port_number=$(grep '^listen:' /etc/hysteria/config.yaml | grep -Eo ':[0-9]+' | sed 's/^://')

                if [ -n "$config_port_number" ]; then
                    echo ""
                    echo -e "${GREEN}检测到 Hysteria 2 监听的端口号为: $config_port_number${RESET}"
                    echo ""
                    echo -e "${BLUE}正在检查端口号是否被占用…${RESET}"
                    if ss -lntu | grep -q ":$config_port_number "; then
                        echo ""
                        echo -e "${RED}端口号 $config_port_number 已被占用！${RESET}"
                        echo ""
                        echo -e "${YELLOW}即将中止启动流程…${RESET}"
                        # 跳转到 # 5 提示返回子菜单
                        abort_process
                    else
                        echo ""
                        echo -e "${GREEN}端口 $config_port_number 可正常使用！${RESET}"
                    fi
                else
                    echo ""
                    echo -e "${RED}未在配置文件中检测到端口号！请检查配置文件。${RESET}"
                    echo ""
                    echo -e "${YELLOW}即将中止启动流程…${RESET}"
                    # 跳转到 # 5 提示返回子菜单
                    abort_process
                fi

                # 2b. 检查自有证书配置
                echo ""
                echo ""
                echo -e "${BLUE}准备检查自有证书配置…${RESET}"

                # 提取证书和密钥路径

                # 提取证书路径，允许路径中包含空格，并且检查是否以 .crt 结尾
                cert_path=$(grep '^  cert:' /etc/hysteria/config.yaml | sed -E 's/^[[:space:]]*cert:[[:space:]]*//;s/[[:space:]]*#.*//' | grep -Eo '/[^[:space:]]+\.crt$')
                # 提取密钥路径，允许路径中包含空格，并且检查是否以 .key 结尾
                key_path=$(grep '^  key:' /etc/hysteria/config.yaml | sed -E 's/^[[:space:]]*key:[[:space:]]*//;s/[[:space:]]*#.*//' | grep -Eo '/[^[:space:]]+\.key$')

                # 检查证书文件是否存在
                if [ -f "$cert_path" ]; then
                    echo ""
                    echo -e "${GREEN}已成功检测到自签证书！${RESET}"
                    cert_exists=true
                else
                    echo ""
                    echo -e "${RED}未检测到自签证书！${RESET}"
                    cert_exists=false
                fi

                # 检查密钥文件是否存在
                if [ -f "$key_path" ]; then
                    echo ""
                    echo -e "${GREEN}已成功检测到密钥！${RESET}"
                    key_exists=true
                else
                    echo ""
                    echo -e "${RED}未检测到密钥！${RESET}"
                    key_exists=false
                fi

                # 缺乏必要自有证书配置的处理流程
                if [ "$cert_exists" == false ] || [ "$key_exists" == false ]; then
                    echo ""
                    echo -e "${RED}由于没有检测到必要的自有证书配置，缺乏启动 Hysteria 2 服务的要素。${RESET}"
                    echo ""
                    echo -e "${YELLOW}即将中止启动流程…${RESET}"
                    # 跳转到 # 5 提示返回子菜单
                    abort_process
                fi

                # 3. 启动 Hysteria 2 服务

                echo ""
                echo ""
                echo -e "${BLUE}正在准备 Hysteria 2 服务启动环境…${RESET}"

                # 启用 Hysteria 2 服务并隐藏输出
                echo ""
                echo -e "${BLUE}正在为 Hysteria 2 服务启用持久化配置…${RESET}"
                enable_output=$(systemctl enable hysteria-server.service 2>&1 > /dev/null)
                if [ $? -eq 0 ]; then
                    echo ""
                    echo -e "${GREEN}已成功为 Hysteria 2 服务启用持久化配置！${RESET}"
                else
                    echo ""
                    echo -e "${RED}为 Hysteria 2 服务启用持久化配置失败！以下是错误信息: ${RESET}"
                    echo ""
                    echo -e "${RESET}${enable_output}${RESET}"
                    echo ""
                    echo -e "${YELLOW}即将中止启动流程…${RESET}"
                    abort_process
                fi

                # 隐藏输出启动 Hysteria 2 服务并捕获错误信息
                echo ""
                echo -e "${BLUE}正在发送启动 Hysteria 2 服务的指令…${RESET}"
                start_output=$(systemctl start hysteria-server.service 2>&1 > /dev/null)
                if [ $? -eq 0 ]; then
                    echo ""
                    echo -e "${GREEN}Hysteria 2 服务启动指令发送成功！${RESET}"
                else
                    echo ""
                    echo -e "${RED}Hysteria 2 服务启动指令发送失败！以下是错误信息: ${RESET}"
                    echo ""
                    echo -e "${RESET}${start_output}${RESET}"
                    echo ""
                    echo -e "${YELLOW}即将中止启动流程…${RESET}"
                    abort_process
                fi

                # 4. 检测 Hysteria 2 的运行状态
                echo ""
                echo ""
                echo -e "${BLUE}正在检测 Hysteria 2 的启动结果和运行状态…${RESET}"

                # 定义一个函数来检测服务状态
                check_hysteria_status() {
                    # 运行 systemctl status 命令并隐藏输出，捕获返回内容
                    status_output=$(systemctl status hysteria-server.service 2>&1)
                    
                    # 检查返回内容中是否同时包含 'server up and running' 和 'active (running)'
                    if echo "$status_output" | grep -q "server up and running" && echo "$status_output" | grep -q "active (running)"; then
                        return 0  # 成功
                    else
                        return 1  # 失败
                    fi
                }

                # 定义最大检测次数
                max_attempts=3

                # 尝试第一次检测
                for attempt in $(seq 1 $max_attempts); do
                    if check_hysteria_status; then
                        echo ""
                        echo -e "${GREEN}Hysteria 2 服务已成功启动并运行！${RESET}"
                        break
                    else
                        if [ "$attempt" -lt "$max_attempts" ]; then
                            # 等待 2 秒后尝试第二次检查，等待 3 秒后尝试第三次检查
                            sleep $((attempt + 1))
                            echo ""
                            echo -e "${YELLOW}暂未检测到正向信息，正在进行第 $((attempt + 1)) 次检测…${RESET}"
                        else
                            # 如果三次检测都失败，输出错误信息
                            echo ""
                            echo -e "${RED}Hysteria 2 服务启动和运行失败！以下是运行状态信息：${RESET}"
                            echo ""
                            echo -e "${RESET}$status_output${RESET}"
                        fi
                    fi
                done

                # 5. 提示返回子菜单
                return_to_sub_menu
                ;;
            0)
                # 返回主菜单
                tput reset
                return 0
                ;;
            *)
                # 无效输入，提示并重新读取输入
                echo ""
                echo -e "${RED}您的输入有误！${RESET}"
                echo ""
                read -p "$(echo -e "${RESET}请重新您的输入选择 [1/2/0]：${RESET}")" config_choice
                ;;
        esac
    done
}

# 5.设置端口跳跃
set_port_hop() {
    # 1. 清屏
    clear

    # 2. 让用户输入希望设置的端口跳跃功能起始端口和终止端口，并进行校验
    echo -e "${BLUE}准备配置端口跳跃…${RESET}"
    while true; do
        echo ""
        echo ""
        read -p "$(echo -e "请输入希望设置的端口跳跃功能起始端口（按下回车键使用默认 20000 端口）: ")" user_start_port
        user_start_port=${user_start_port:-20000}
        if [[ "$user_start_port" =~ ^[0-9]+$ ]] && [ "$user_start_port" -ge 1 ] && [ "$user_start_port" -le 65535 ]; then
            echo ""
            echo -e "${GREEN}起始端口设置成功！${RESET}"
            break
        else
            echo ""
            echo -e "${RED}您输入的端口号无效！请重新输入（1-65535）。${RESET}"
        fi
    done

    while true; do
        echo ""
        echo ""
        read -p "$(echo -e "请输入希望设置的端口跳跃功能终止端口（按下回车键使用默认 60000 端口）: ")" user_end_port
        user_end_port=${user_end_port:-60000}
        if [[ "$user_end_port" =~ ^[0-9]+$ ]] && [ "$user_end_port" -ge 1 ] && [ "$user_end_port" -le 65535 ]; then
            echo ""
            echo -e "${GREEN}终止端口设置成功！${RESET}"
            break
        else
            echo ""
            echo -e "${RED}您输入的端口号无效！请重新输入（1-65535）。${RESET}"
        fi
    done

    # 3. 检查当前系统的防火墙配置
    echo ""
    echo ""
    echo -e "${BLUE}正在检查当前系统的防火墙配置…${RESET}"

    # 初始化防火墙检测变量
    has_iptables=false
    has_nftables=false
    has_firewalld=false

    # 检查 iptables 是否存在
    if command -v iptables > /dev/null; then
        has_iptables=true
        echo ""
        echo -e "${RESET}检测到 iptables。${RESET}"
    fi

    # 检查 nftables 是否存在
    if command -v nft > /dev/null; then
        has_nftables=true
        echo ""
        echo -e "${RESET}检测到 nftables。${RESET}"
    fi

    # 检查 firewalld 是否存在
    if systemctl is-active firewalld > /dev/null; then
        has_firewalld=true
        echo ""
        echo -e "${RESET}检测到 firewalld。${RESET}"
    fi

    # 确定 firewall_type 的优先级
    if $has_iptables; then
        # 优先级 1：只要安装了 iptables，无论是否安装 nftables 或 firewalld，都设置为 iptables
        firewall_type="iptables"
    elif $has_nftables && ! $has_iptables && ! $has_firewalld; then
        # 优先级 2：如果仅安装了 nftables，但没有 iptables 和 firewalld，则设置为 nftables
        firewall_type="nftables"
    elif $has_firewalld; then
        # 优先级 3：如果安装了 firewalld，无论是否安装 iptables 或 nftables，都设置为 firewalld
        firewall_type="firewalld"
    else
        # 无法确定防火墙类型
        firewall_type="unknown"
    fi

    # 4. 根据 iptables 设置端口跳跃功能

    # 提取 Hysteria 2 监听端口
    config_port_number=$(grep '^listen:' /etc/hysteria/config.yaml | grep -Eo ':[0-9]+' | sed 's/^://')

    case $firewall_type in
        # 4. 根据 iptables 设置端口跳跃功能
        "iptables")
            echo ""
            echo ""
            echo -e "${BLUE}准备根据您的防火墙配置来设置端口跳跃功能…${RESET}"
            echo ""

            # 4a. 配置允许本地访问
            echo ""
            echo -e "${BLUE}正在配置允许本地访问…${RESET}"
            iptables -A INPUT -i lo -j ACCEPT > /dev/null 2>&1
            ip6tables -A INPUT -i lo -j ACCEPT > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已允许本地访问！${RESET}"

            # 4b. 放行 22、80、443 端口和所有出站流量
            iptables -A INPUT -p tcp --dport 22 -j ACCEPT > /dev/null 2>&1
            iptables -A INPUT -p tcp --dport 80 -j ACCEPT > /dev/null 2>&1
            iptables -A INPUT -p tcp --dport 443 -j ACCEPT > /dev/null 2>&1
            ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT > /dev/null 2>&1
            ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT > /dev/null 2>&1
            ip6tables -A INPUT -p tcp --dport 443 -j ACCEPT > /dev/null 2>&1
            iptables -A OUTPUT -j ACCEPT > /dev/null 2>&1
            ip6tables -A OUTPUT -j ACCEPT > /dev/null 2>&1

            # 4c. 放行 Hysteria 2 监听的 UDP 端口
            echo ""
            echo -e "${BLUE}正在放行 Hysteria 2 监听的 UDP 端口…${RESET}"
            iptables -A INPUT -p udp --dport "$config_port_number" -j ACCEPT > /dev/null 2>&1
            ip6tables -A INPUT -p udp --dport "$config_port_number" -j ACCEPT > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已放行 $config_port_number 端口的 UDP 流量。${RESET}"

            # 4d. 配置 UDP 端口跳跃范围
            echo ""
            echo -e "${BLUE}正在配置 UDP 端口跳跃范围…${RESET}"
            iptables -A INPUT -p udp --dport "$user_start_port":"$user_end_port" -j ACCEPT > /dev/null 2>&1
            ip6tables -A INPUT -p udp --dport "$user_start_port":"$user_end_port" -j ACCEPT > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已配置 UDP 端口跳跃范围为 $user_start_port:$user_end_port。${RESET}"

            # 4e. 配置允许本机返回流量
            echo ""
            echo -e "${BLUE}正在配置允许本机返回流量…${RESET}"
            iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT > /dev/null 2>&1
            ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已允许本机返回流量。${RESET}"

            # 4f. 配置 UDP 数据包重定向
            echo ""
            echo -e "${BLUE}正在配置 UDP 数据包重定向…${RESET}"
            iptables -t nat -A PREROUTING -p udp --dport "$user_start_port":"$user_end_port" -j DNAT --to-destination :"$config_port_number" > /dev/null 2>&1
            ip6tables -t nat -A PREROUTING -p udp --dport "$user_start_port":"$user_end_port" -j DNAT --to-destination :"$config_port_number" > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已将端口跳跃范围内的 UDP 流量重定向至 Hysteria 2 监听的 $config_port_number 端口。${RESET}"

            # 4g. 保存 iptables 配置

            # 检测系统中是否已安装 netfilter-persistent
            echo ""
            echo ""
            echo -e "${BLUE}准备保存端口跳跃配置…${RESET}"
            if command -v netfilter-persistent > /dev/null 2>&1; then
                # 如果检测到 netfilter-persistent，则通过它保存 iptables 配置
                netfilter-persistent save > /dev/null 2>&1
                echo ""
                echo -e "${GREEN}已成功保存端口跳跃配置…${RESET}"
            else
                # 如果系统仅安装了 iptables 而未安装 nftables，则安装 iptables-persistent 来保存 iptables 配置
                echo ""
                echo -e "${YELLOW}未检测到 netfilter-persistent。${RESET}"
                if $has_iptables && ! $has_nftables; then
                    echo ""
                    echo -e "${BLUE}根据当前系统的防火墙配置，正在安装 netfilter-persistent 并保存配置…${RESET}"
                    apt-get update > /dev/null 2>&1
                    apt-get install -y netfilter-persistent > /dev/null 2>&1
                    netfilter-persistent save > /dev/null 2>&1
                    echo ""
                    echo -e "${GREEN}已成功通过 netfilter-persistent 保存端口跳跃配置！${RESET}"
                elif $has_iptables && $has_nftables; then
                    # 如果系统同时安装了 iptables 和 nftables，则安装 netfilter-persistent 来保存 iptables 配置
                    echo ""
                    echo -e "${BLUE}根据当前系统的防火墙配置，正在安装 netfilter-persistent 并保存配置…${RESET}"
                    apt-get update > /dev/null 2>&1
                    apt-get install -y netfilter-persistent > /dev/null 2>&1
                    netfilter-persistent save > /dev/null 2>&1
                    echo ""
                    echo -e "${GREEN}已成功通过 netfilter-persistent 保存端口跳跃配置！${RESET}"
                else
                    # 其他情况，提示手动保存配置
                    echo -e "${RED}未检测到适合的防火墙工具/配置，请手动保存 iptables 配置。${RESET}"
                fi
            fi
            echo ""
            echo ""
            echo -e "${GREEN}已成功设置端口跳跃功能！${RESET}"

            # 4h. 提示返回主菜单
            return_to_main_menu
            ;;
        # 5. 根据 nftables 设置端口跳跃功能
        "nftables")
            echo ""
            echo ""
            echo -e "${BLUE}准备根据您的防火墙配置来设置端口跳跃功能…${RESET}"

            # 5a. 配置允许本地访问
            echo ""
            echo -e "${BLUE}正在配置允许本地访问…${RESET}"
            nft add rule inet filter input iif lo accept > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已允许本地访问。${RESET}"

            # 5b. 放行 22、80、443 端口和所有出站流量
            nft add rule inet filter input tcp dport {22,80,443} accept > /dev/null 2>&1
            nft add rule inet filter output accept > /dev/null 2>&1

            # 5c. 放行 Hysteria 2 监听的 UDP 端口
            echo ""
            echo -e "${BLUE}正在放行 Hysteria 2 监听的 UDP 端口…${RESET}"
            config_port_number=$(grep "listen" /etc/hysteria/config.yaml | awk '{print $2}' | sed 's/://')
            nft add rule inet filter input udp dport "$config_port_number" accept > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已放行 $config_port_number 端口的 UDP 流量。${RESET}"

            # 5d. 配置 UDP 端口跳跃范围
            echo ""
            echo -e "${BLUE}正在配置 UDP 端口跳跃范围…${RESET}"
            nft add rule inet filter input udp dport "$user_start_port"-"$user_end_port" accept > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已配置 UDP 端口跳跃范围为 $user_start_port:$user_end_port。${RESET}"

            # 5e. 配置 UDP 数据包重定向
            echo ""
            echo -e "${BLUE}正在配置 UDP 数据包重定向…${RESET}"
            nft add rule inet nat prerouting udp dport "$user_start_port"-"$user_end_port" dnat to :"$config_port_number" > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已将端口跳跃范围内的 UDP 流量重定向至 Hysteria 2 监听的 $config_port_number 端口。${RESET}"

            # 5f. 保存 nftables 配置
            echo ""
            echo ""
            echo -e "${BLUE}准备保存端口跳跃配置…${RESET}"
            if ! command -v netfilter-persistent > /dev/null; then
                echo ""
                echo -e "${YELLOW}根据当前系统配置，正在安装 netfilter-persistent 并保存配置…${RESET}"
                apt-get update > /dev/null 2>&1
                apt-get install -y netfilter-persistent > /dev/null 2>&1
                netfilter-persistent save > /dev/null 2>&1
                echo ""
                echo -e "${GREEN}已成功通过 netfilter-persistent 保存端口跳跃配置！${RESET}"    
            else
                netfilter-persistent save > /dev/null 2>&1
                echo ""
                echo -e "${GREEN}已成功保存端口跳跃配置！${RESET}"
            fi
            echo ""
            echo ""
            echo -e "${GREEN}已成功设置端口跳跃功能！${RESET}"

            # 5g. 提示返回主菜单
            return_to_main_menu
            ;;
        # 6. 根据 firewalld 设置端口跳跃功能
        "firewalld")
            echo ""
            echo ""
            echo -e "${BLUE}使用 firewalld 配置端口跳跃功能…${RESET}"

            # 6a. 配置允许本地访问
            echo ""
            echo -e "${BLUE}正在配置允许本地访问…${RESET}"
            firewall-cmd --zone=trusted --add-source=127.0.0.1/8 --permanent > /dev/null 2>&1
            firewall-cmd --zone=trusted --add-source=::1 --permanent > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已允许本地访问。${RESET}"

            # 6b. 放行 22、80、443 端口和所有出站流量
            firewall-cmd --zone=public --add-port=22/tcp --permanent > /dev/null 2>&1
            firewall-cmd --zone=public --add-port=80/tcp --permanent > /dev/null 2>&1
            firewall-cmd --zone=public --add-port=443/tcp --permanent > /dev/null 2>&1
            firewall-cmd --zone=public --set-target=ACCEPT --permanent > /dev/null 2>&1

            # 6c. 放行 Hysteria 2 监听的 UDP 端口
            echo ""
            echo -e "${BLUE}正在放行 Hysteria 2 监听的 UDP 端口…${RESET}"
            firewall-cmd --zone=public --add-port="$user_start_port"-"$user_end_port"/udp --permanent > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已放行 $config_port_number 端口的 UDP 流量。${RESET}"

            # 6d. 配置 UDP 端口跳跃范围
            echo ""
            echo -e "${BLUE}正在配置 UDP 端口跳跃范围…${RESET}"
            firewall-cmd --zone=public --add-port="$user_start_port"-"$user_end_port"/udp --permanent > /dev/null 2>&1
            echo ""
            cho -e "${GREEN}已配置 UDP 端口跳跃范围为 $user_start_port:$user_end_port。${RESET}"

            # 6e. 配置允许本机返回流量
            echo ""
            echo -e "${BLUE}正在配置允许本机返回流量…${RESET}"
            firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="0.0.0.0/0" service name="ssh" accept' --permanent > /dev/null 2>&1
            firewall-cmd --zone=public --add-rich-rule='rule family="ipv6" source address="::/0" service name="ssh" accept' --permanent > /dev/null 2>&1
            firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="0.0.0.0/0" service name="http" accept' --permanent > /dev/null 2>&1
            firewall-cmd --zone=public --add-rich-rule='rule family="ipv6" source address="::/0" service name="http" accept' --permanent > /dev/null 2>&1
            firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="0.0.0.0/0" service name="https" accept' --permanent > /dev/null 2>&1
            firewall-cmd --zone=public --add-rich-rule='rule family="ipv6" source address="::/0" service name="https" accept' --permanent > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已允许本机返回流量。${RESET}"

            # 6f. 配置 UDP 数据包重定向
            echo ""
            echo -e "${BLUE}正在配置 UDP 数据包重定向…${RESET}"
            firewall-cmd --zone=public --add-forward-port=port="$user_start_port"-"$user_end_port":proto=udp:toport="$config_port_number" --permanent > /dev/null 2>&1
            echo ""
            echo -e "${GREEN}已将端口跳跃范围内的 UDP 流量重定向至 Hysteria 2 监听的 $config_port_number 端口。${RESET}"

            # 6g. 重新加载 firewalld
            echo -e "${BLUE}正在重新加载 firewalld…${RESET}"
            firewall-cmd --reload > /dev/null 2>&1
            echo ""
            echo ""
            echo -e "${GREEN}已成功设置端口跳跃功能！${RESET}"

            # 6h. 提示返回主菜单
            return_to_main_menu
            ;;
        # 未检测到支持的防火墙配置
        *)
            echo ""
            echo ""
            echo -e "${RED}配置端口跳跃功能失败！未检测到支持的防火墙工具/配置。${RESET}"
            return_to_main_menu
            ;;
    esac
}

# 6.设置系统缓冲区
set_buffer_size() {
    # 1. 清屏
    clear

    # 2. 设置系统缓冲区
    echo -e "${BLUE}正在设置系统缓冲区…${RESET}"
    sysctl -w net.core.rmem_max=16777216 > /dev/null 2>&1
    sysctl -w net.core.wmem_max=16777216 > /dev/null 2>&1
    echo ""
    echo -e "${GREEN}已成功设置系统缓冲区！${RESET}"

    # 3. 输出 OpenWrt 等应用的相关配置提示
    echo ""
    echo ""
    echo -e "${ORANGE}请在 OpenWrt 等应用内对应配置以下内容："
    echo ""
    echo -e "${CYAN}QUIC 流接收窗口：${RESET}26843545"
    echo -e "${CYAN}QUIC 连接接收窗口：${RESET}67108864"

    # 4. 提示返回主菜单
    return_to_main_menu
}

# 7.停止 Hysteria 2
stop_hysteria_service() {
    # 1. 清屏
    clear

    # 2. 隐藏输出停止 Hysteria 2 服务并捕获错误信息
    echo -e "${BLUE}正在发送停止 Hysteria 2 服务的指令…${RESET}"
    start_output=$(systemctl stop hysteria-server.service 2>&1 > /dev/null)
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}Hysteria 2 服务停止指令发送成功！${RESET}"
    else
        echo ""
        echo -e "${RED}Hysteria 2 服务停止指令发送失败！以下是错误信息: ${RESET}"
        echo ""
        echo -e "${RESET}${start_output}${RESET}"
        echo ""
        echo -e "${YELLOW}即将中止停止流程…${RESET}"
        return_to_main_menu
    fi

    # 3. 检测 Hysteria 2 的运行状态
    echo ""
    echo ""
    echo -e "${BLUE}正在检测 Hysteria 2 的停止结果和运行状态…${RESET}"

    # 定义一个函数来检测服务状态
    check_hysteria_status() {
        # 运行 systemctl status 命令并隐藏输出，捕获返回内容
        start_output=$(systemctl status hysteria-server.service 2>&1 > /dev/null)
        
        # 检查返回内容中是否同时包含 'server up and running' 和 'active (running)'
        if echo "$status_output" | grep -q "inactive (dead)" && echo "$status_output" | grep -q "Stopped Hysteria Server Service"; then
            return 0  # 成功
        else
            return 1  # 失败
        fi
    }

    # 定义最大检测次数
    max_attempts=3

    # 尝试第一次检测
    for attempt in $(seq 1 $max_attempts); do
        if check_hysteria_status; then
            echo ""
            echo -e "${GREEN}Hysteria 2 服务已成功停止！${RESET}"
            break
        else
            if [ "$attempt" -lt "$max_attempts" ]; then
                # 等待 2 秒后尝试第二次检查，等待 3 秒后尝试第三次检查
                sleep $((attempt + 1))
                echo ""
                echo -e "${YELLOW}暂未检测到正向信息，正在进行第 $((attempt + 1)) 次检测…${RESET}"
            else
                # 如果三次检测都失败，输出错误信息
                echo ""
                echo -e "${RED}Hysteria 2 服务停止失败！以下是状态信息：${RESET}"
                echo ""
                echo -e "${RESET}$status_output${RESET}"
            fi
        fi
    done


    # 4. 提示返回主菜单
    return_to_main_menu
}

# 8.重启 Hysteria 2
restart_hysteria_service() {
    # 1. 清屏
    clear

    # 2. 隐藏输出重启 Hysteria 2 服务并捕获错误信息
    echo -e "${BLUE}正在发送重启 Hysteria 2 服务的指令…${RESET}"
    start_output=$(systemctl restart hysteria-server.service 2>&1 > /dev/null)
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}Hysteria 2 服务重启指令发送成功！${RESET}"
    else
        echo ""
        echo -e "${RED}Hysteria 2 服务重启指令发送失败！以下是错误信息: ${RESET}"
        echo ""
        echo -e "${RESET}${start_output}${RESET}"
        echo ""
        echo -e "${YELLOW}即将中止重启流程…${RESET}"
        return_to_main_menu
    fi

    # 3. 检测 Hysteria 2 的运行状态
    echo ""
    echo ""
    echo -e "${BLUE}正在检测 Hysteria 2 的重启结果和运行状态…${RESET}"

    # 定义一个函数来检测服务状态
    check_hysteria_status() {
        # 运行 systemctl status 命令并隐藏输出，捕获返回内容
        start_output=$(systemctl status hysteria-server.service 2>&1 > /dev/null)
        
        # 检查返回内容中是否同时包含 'server up and running' 和 'active (running)'
        if echo "$status_output" | grep -q "server up and running" && echo "$status_output" | grep -q "active (running)"; then
            return 0  # 成功
        else
            return 1  # 失败
        fi
    }

    # 定义最大检测次数
    max_attempts=3

    # 尝试第一次检测
    for attempt in $(seq 1 $max_attempts); do
        if check_hysteria_status; then
            echo ""
            echo -e "${GREEN}Hysteria 2 服务已成功重启并运行！${RESET}"
            break
        else
            if [ "$attempt" -lt "$max_attempts" ]; then
                # 等待 2 秒后尝试第二次检查，等待 3 秒后尝试第三次检查
                sleep $((attempt + 1))
                echo ""
                echo -e "${YELLOW}暂未检测到正向信息，正在进行第 $((attempt + 1)) 次检测…${RESET}"
            else
                # 如果三次检测都失败，输出错误信息
                echo ""
                echo -e "${RED}Hysteria 2 服务重启和运行失败！以下是运行状态信息：${RESET}"
                echo ""
                echo -e "${RESET}$status_output${RESET}"
            fi
        fi
    done


    # 4. 提示返回主菜单
    return_to_main_menu
}

# 9.卸载 Hysteria 2
uninstall_hysteria() {
    while true; do
        # 1. 清屏
        clear

        # # 2. 让用户确认是否继续卸载
        # echo -e "${YELLOW}您即将进入卸载 Hysteria 2 的操作引导页面。正式卸载后，相关操作不可逆转。是否要开始？${RESET}"
        # echo ""
        # read -p "$(echo -e "${RESET}请输入您的选择：[Yy/Nn]${RESET}")" user_choice
        # case "$user_choice" in
        #     Y|Yes|YES|yes)
        #         break
        #         ;;
        #     N|No|NO|no)
        #         echo ""
        #         echo -e "${GREEN}您已放弃进入卸载操作引导页面。即将返回主菜单…${RESET}"
        #         sleep 2
        #         return
        #         ;;
        #     *)
        #         echo ""
        #         echo -e "${RED}您的输入有误！${RESET}"
        #         echo ""
        #         continue
        #         ;;
        # esac

        # 3. 显示卸载选项菜单
        echo ""
        echo ""
        echo -e "${ORANGE}请选择您要执行的操作："
        echo ""
        echo ""
        echo -e "${GREEN}  1. 一键卸载 Hysteria 2 服务及相关配置、文件"
        echo ""
        echo -e "${GREEN}  2. 卸载 Hysteria 2 主程序"
        echo -e "${GREEN}  3. 删除配置文件和 ACME 证书"
        echo -e "${GREEN}  4. 禁用 Hysteria 2 相关系统服务"
        echo ""
        echo -e "${YELLOW}  0. 返回主菜单"
        echo ""
        echo ""
        read -p "$(echo -e "${RESET}请输入您的选择 [0-4]：${RESET}")" uninstall_choice

        case "$uninstall_choice" in
            1)
                # 一键卸载 Hysteria 2 服务及相关文件

                # 1. 清屏
                clear
                echo -e "${BLUE}正在卸载 Hysteria 2 主程序…${RESET}"
                
                # 2. 卸载 Hysteria 2 主程序
                uninstall_output=$(bash <(curl -fsSL https://get.hy2.sh/) --remove 2>&1)
                if echo "$uninstall_output" | grep -q "No such file or directory"; then
                    echo ""
                    echo -e "${YELLOW}您的系统中没有安装 Hysteria 2 主程序！${RESET}"
                elif echo "$uninstall_output" | grep -q "Congratulation! Hysteria has been successfully removed from your server."; then
                    echo ""
                    echo -e "${GREEN}Hysteria 2 主程序已成功卸载！${RESET}"
                else
                    echo ""
                    echo -e "${RED}卸载 Hysteria 2 主程序时出错！以下是输出信息：${RESET}"
                    echo ""
                    echo "$uninstall_output"
                fi

                # 3. 删除配置文件和 ACME 证书
                echo ""
                echo ""
                echo -e "${BLUE}正在删除配置文件和 ACME 证书…${RESET}"
                
                # 删除 /etc/hysteria 目录
                remove_config_output=$(rm -rf /etc/hysteria 2>&1)
                if echo "$remove_config_output" | grep -q "No such file or directory"; then
                    echo ""
                    echo -e "${YELLOW}您的系统中不存在 Hysteria 2 配置文件或配置文件已删除！${RESET}"
                else
                    echo ""
                    echo -e "${GREEN}已成功删除配置文件！${RESET}"
                fi
                
                # 删除 hysteria 用户
                delete_user_output=$(userdel -r hysteria 2>&1)
                if [ -z "$delete_user_output" ]; then
                    echo ""
                    echo -e "${GREEN}已成功删除 ACME 证书！${RESET}"
                elif echo "$delete_user_output" | grep -q "not exist"; then
                    echo ""
                    echo -e "${YELLOW}hysteria 用户不存在导致无法删除 ACME 证书，或相关文件已经被删除！${RESET}"
                elif echo "$delete_user_output" | grep -q "used by process"; then
                    echo ""
                    echo -e "${YELLOW}hysteria 用户正在拥有某个进程，这可能是 Hysteria 2 主程序仍未卸载！${RESET}"
                fi

                # 4. 禁用 Hysteria 2 相关系统服务
                echo ""
                echo ""
                echo -e "${BLUE}正在禁用 Hysteria 2 相关系统服务…${RESET}"
                disable_service_output=$(rm -f /etc/systemd/system/multi-user.target.wants/hysteria-server.service \
                    && rm -f /etc/systemd/system/multi-user.target.wants/hysteria-server@*.service \
                    && systemctl daemon-reload 2>&1)

                if [ -z "$disable_service_output" ]; then
                    echo ""
                    echo -e "${GREEN}已成功禁用 Hysteria 2 相关系统服务！${RESET}"
                else
                    echo ""
                    echo -e "${RED}禁用 Hysteria 2 相关系统服务时出错！以下是输出信息：${RESET}"
                    echo ""
                    echo "$disable_service_output"
                fi

                # 5. 完成卸载流程
                echo ""
                echo ""
                echo -e "${GREEN}已经完成一键卸载 Hysteria 2 服务及相关文件的所有流程！${RESET}"

                # 6. 提示返回上一级菜单
                return_to_sub_menu
                ;;
            2)
                # 卸载 Hysteria 2 主程序

                # 1. 清屏
                clear
                echo -e "${BLUE}正在卸载 Hysteria 2 主程序…${RESET}"
                
                # 2. 卸载 Hysteria 2 主程序
                uninstall_output=$(bash <(curl -fsSL https://get.hy2.sh/) --remove 2>&1)
                if echo "$uninstall_output" | grep -q "No such file or directory"; then
                    echo ""
                    echo -e "${YELLOW}您的系统中没有安装 Hysteria 2 主程序！${RESET}"
                elif echo "$uninstall_output" | grep -q "Congratulation! Hysteria has been successfully removed from your server."; then
                    echo ""
                    echo -e "${GREEN}Hysteria 2 主程序已成功卸载！${RESET}"
                else
                    echo ""
                    echo -e "${RED}卸载 Hysteria 2 主程序时出错！以下是输出信息：${RESET}"
                    echo ""
                    echo "$uninstall_output"
                fi
                
                # 3.提示返回上一级菜单
                return_to_sub_menu
                ;;
            3)
                # 删除配置文件和 ACME 证书

                # 1. 清屏
                clear

                # 2. 删除配置文件和 ACME 证书
                echo ""
                echo ""
                echo -e "${BLUE}正在删除配置文件和 ACME 证书…${RESET}"
                
                # 删除 /etc/hysteria 目录
                remove_config_output=$(rm -rf /etc/hysteria 2>&1)
                if echo "$remove_config_output" | grep -q "No such file or directory"; then
                    echo ""
                    echo -e "${YELLOW}您的系统中不存在 Hysteria 2 配置文件或配置文件已删除！${RESET}"
                else
                    echo ""
                    echo -e "${GREEN}已成功删除配置文件！${RESET}"
                fi
                
                # 删除 hysteria 用户
                delete_user_output=$(userdel -r hysteria 2>&1)
                if [ -z "$delete_user_output" ]; then
                    echo ""
                    echo -e "${GREEN}已成功删除 ACME 证书！${RESET}"
                elif echo "$delete_user_output" | grep -q "not exist"; then
                    echo ""
                    echo -e "${YELLOW}hysteria 用户不存在导致无法删除 ACME 证书，或相关文件已经被删除！${RESET}"
                elif echo "$delete_user_output" | grep -q "used by process"; then
                    echo ""
                    echo -e "${YELLOW}hysteria 用户正在拥有某个进程，这可能是 Hysteria 2 主程序仍未卸载！${RESET}"
                fi
                
                # 3.提示返回上一级菜单
                return_to_sub_menu
                ;;
            4)
                # 禁用 Hysteria 2 相关系统服务

                # 1. 清屏
                clear

                # 2. 禁用 Hysteria 2 相关系统服务
                echo ""
                echo ""
                echo -e "${BLUE}正在禁用 Hysteria 2 相关系统服务…${RESET}"
                disable_service_output=$(rm -f /etc/systemd/system/multi-user.target.wants/hysteria-server.service \
                    && rm -f /etc/systemd/system/multi-user.target.wants/hysteria-server@*.service \
                    && systemctl daemon-reload 2>&1)

                if [ -z "$disable_service_output" ]; then
                    echo ""
                    echo -e "${GREEN}已成功禁用 Hysteria 2 相关系统服务！${RESET}"
                else
                    echo ""
                    echo -e "${RED}禁用 Hysteria 2 相关系统服务时出错！以下是输出信息：${RESET}"
                    echo ""
                    echo "$disable_service_output"
                fi
                
                # 3. 提示返回上一级菜单
                return_to_sub_menu
                ;;
            0)
                # 返回主菜单
                tput reset
                return 0
                ;;
            *)
                # 无效输入，提示并重新读取输入

                echo ""
                echo -e "${RED}您的输入有误！${RESET}"
                echo ""
                read -p "$(echo -e "${RESET}请重新您的输入选择 [0-4]：${RESET}")" config_choice
                ;;
        esac
    done
}

# 10.打印相关配置
print_configuration() {
    while true; do
        # 1. 清屏
        clear

        # 2. 显示选择菜单
        echo ""
        echo ""
        echo -e "${ORANGE}请输入相应数字来选择您要打印的配置：${RESET}"
        echo ""
        echo ""
        echo -e "${GREEN}   1.  一键打印客户端所需配置参数${RESET}"
        echo ""
        echo ""        
        echo -e "${GREEN}   2. Hysteria 2 服务监听的端口号${RESET}"
        # echo -e "${GREEN}   2. 端口跳跃范围${RESET}"
        echo -e "${GREEN}   3. 域名${RESET}"
        echo -e "${GREEN}   4. 密码${RESET}"
        echo -e "${GREEN}   5. 证书和私钥保存路径${RESET}"
        echo ""
        echo ""
        echo -e "${YELLOW}   0. 返回主菜单${RESET}"
        echo ""
        echo ""
        read -p "$(echo -e "${RESET}请输入您的选择 [0-5]：${RESET}")" print_choice

        case "$print_choice" in
            1)
                # 一键打印客户端所需配置参数

                # 1. 清屏
                clear
                echo -e "${BLUE}正在查询客户端配置所需的端口号、域名、密码…${RESET}"
                echo ""

                # 2. 打印端口号           
                config_port_number=$(grep "listen" /etc/hysteria/config.yaml | awk '{print $2}' | sed 's/://')
                if [ -n "$config_port_number" ]; then
                    echo ""
                    echo -e "${CYAN}Hysteria 2 服务监听的端口号为：${RESET}${config_port_number}"
                else
                    echo ""
                    echo -e "${RED}端口号查询失败！未能从配置文件中找到端口号。${RESET}"
                fi

                # 3. 打印域名
                config_domain=$(grep -m 1 'domains:' -A 1 /etc/hysteria/config.yaml | grep -Eo '^[[:space:]]*-[[:space:]]*[^[:space:]#]+' | sed 's/^[[:space:]]*-[[:space:]]*//')
                if [ -n "$config_domain" ]; then
                    echo ""
                    echo -e "${CYAN}Hysteria 2 服务使用的自备配置域名为：${RESET}${config_domain}"
                else
                    echo ""
                    echo -e "${RED}域名查询失败！未能从配置文件中找到域名，这可能是您使用无域名方式搭建 Hysteria 2，或者是 YAML 文件存在的语法等。${RESET}"
                fi
                
                # 4. 打印密码
                config_passwd=$(grep '^  password:' /etc/hysteria/config.yaml | sed -E 's/^[[:space:]]*password:[[:space:]]*//;s/[[:space:]]+#.*//')
                if [ -n "$config_passwd" ]; then
                    echo ""
                    echo -e "${CYAN}Hysteria 2 服务配置的密码为：${RESET}${config_passwd}"
                else
                    echo ""
                    echo -e "${RED}密码查询失败！未能从配置文件中找到密码。${RESET}"
                fi

                # 5.  提示返回上一级菜单
                return_to_sub_menu
                ;;
            2)
                # 打印 Hysteria 2 服务监听的端口号
                
                # 1. 清屏
                clear
                echo -e "${BLUE}正在查询 Hysteria 2 服务监听的端口号…${RESET}"

                # 2. 打印端口号           
                config_port_number=$(grep "listen" /etc/hysteria/config.yaml | awk '{print $2}' | sed 's/://')
                if [ -n "$config_port_number" ]; then
                    echo ""
                    echo -e "${CYAN}Hysteria 2 服务监听的端口号为：${RESET}${config_port_number}"
                else
                    echo ""
                    echo -e "${RED}端口号查询失败！未能从配置文件中找到端口号。${RESET}"
                fi

                # 3.  提示返回上一级菜单
                return_to_sub_menu
                ;;
            # 2)
            #     # 打印端口跳跃范围

            #     # 清屏
            #     clear
            #     echo -e "${BLUE}正在查询端口跳跃范围…${RESET}"

            #     # 1. 使用 grep 工具从 /etc/hysteria/config.yaml 中提取 Hysteria 2 正在监听的端口号
            #     config_port_number=$(grep '^listen:' /etc/hysteria/config.yaml | grep -Eo ':[0-9]+' | sed 's/^://')

            #     # 2. 检测系统中是否存在 firewalld 防火墙
            #     if command -v firewall-cmd > /dev/null; then
            #         # 2-1. 查询 firewalld 防火墙配置
            #         firewall_output=$(firewall-cmd --zone=public --list-forward-ports 2>/dev/null)
            #         if echo "$firewall_output" | grep -q "$config_port_number"; then
            #             firewalld_start_port=$(echo "$firewall_output" | grep "$config_port_number" | awk '{print $3}')
            #             firewalld_end_port=$(echo "$firewall_output" | grep "$config_port_number" | awk '{print $5}')
            #             echo ""
            #             echo -e "${CYAN}通过 firewalld 防火墙查询到 Hysteria 2 服务的端口转发范围为 ${firewalld_start_port} 到 ${firewalld_end_port}。${RESET}"
            #         else
            #             echo ""
            #             echo -e "${RED}端口跳跃范围查询失败！firewalld 防火墙配置中没有和 Hysteria 2 服务监听端口相关的端口转发配置。${RESET}"
            #         fi
            #     fi

            #     # 3. 检测系统中是否存在 iptables 防火墙
            #     if command -v iptables > /dev/null; then
            #         # 3-1. 查询 iptables 防火墙配置
            #         iptables_output=$(iptables -t nat -nL --line 2>/dev/null)
            #         ip4tables_start_port=""
            #         ip4tables_end_port=""

            #         # 从查询结果中查找匹配 $config_port_number 的行，并提取起始端口和终止端口
            #         matched_line=$(echo "$iptables_output" | grep "$config_port_number")
            #         if [ -n "$matched_line" ]; then
            #             # 精确提取端口范围的处理
            #             port_range=$(echo "$matched_line" | grep -oP '(?<=dpt:)\d+(-\d+)?')
            #             if [[ "$port_range" =~ "-" ]]; then
            #                 # 提取起始端口和终止端口
            #                 ip4tables_start_port=$(echo "$port_range" | cut -d'-' -f1)
            #                 ip4tables_end_port=$(echo "$port_range" | cut -d'-' -f2)
            #             else
            #                 # 只有单个端口的情况
            #                 ip4tables_start_port=$port_range
            #                 ip4tables_end_port=$port_range
            #             fi
            #         else
            #             # 3-1-2. 检查 ip6tables 配置
            #             ip6tables_output=$(ip6tables -t nat -nL --line 2>/dev/null)
            #             ip6tables_start_port=""
            #             ip6tables_end_port=""

            #             # 从查询结果中查找匹配 $config_port_number 的行，并提取起始端口和终止端口
            #             matched_line6=$(echo "$ip6tables_output" | grep "$config_port_number")
            #             if [ -n "$matched_line6" ]; then
            #                 # 精确提取端口范围的处理
            #                 port_range6=$(echo "$matched_line6" | grep -oP '(?<=dpt:)\d+(-\d+)?')
            #                 if [[ "$port_range6" =~ "-" ]]; then
            #                     # 提取起始端口和终止端口
            #                     ip6tables_start_port=$(echo "$port_range6" | cut -d'-' -f1)
            #                     ip6tables_end_port=$(echo "$port_range6" | cut -d'-' -f2)
            #                 else
            #                     # 只有单个端口的情况
            #                     ip6tables_start_port=$port_range6
            #                     ip6tables_end_port=$port_range6
            #                 fi
            #             else
            #                 # 检测是否存在 nftables 防火墙
            #                 if command -v nft > /dev/null; then
            #                     nft_output=$(nft list ruleset 2>/dev/null)
            #                     nftables_start_port=""
            #                     nftables_end_port=""

            #                     # 从查询结果中查找匹配 $config_port_number 的行，并提取起始端口和终止端口
            #                     matched_line_nft=$(echo "$nft_output" | grep "$config_port_number")
            #                     if [ -n "$matched_line_nft" ]; then
            #                         # 提取匹配行中的端口范围
            #                         nft_port_range=$(echo "$matched_line_nft" | grep -oP 'dport \d+(-\d+)?' | grep -oP '\d+(-\d+)?')
            #                         if [[ "$nft_port_range" =~ "-" ]]; then
            #                             # 提取起始端口和终止端口
            #                             nftables_start_port=$(echo "$nft_port_range" | cut -d'-' -f1)
            #                             nftables_end_port=$(echo "$nft_port_range" | cut -d'-' -f2)
            #                         else
            #                             # 只有单个端口的情况
            #                             nftables_start_port=$nft_port_range
            #                             nftables_end_port=$nft_port_range
            #                         fi
            #                         echo ""
            #                         echo -e "${CYAN}通过 nftables 防火墙查询到 Hysteria 2 服务的端口转发范围为 ${nftables_start_port} 到 ${nftables_end_port}。${RESET}"
            #                     else
            #                         echo ""
            #                         echo -e "${RED}端口跳跃范围查询失败！nftables 防火墙配置中没有和 Hysteria 2 服务监听端口相关的端口转发配置。${RESET}"
            #                     fi
            #                 else
            #                     echo ""
            #                     echo -e "${RED}端口跳跃范围查询失败！iptables 防火墙配置中没有和 Hysteria 2 服务监听端口相关的端口转发配置。${RESET}"
            #                 fi
            #             fi
            #         fi
            #     fi

            #     # 4. 检测系统中是否存在 nftables 防火墙
            #     if command -v nft > /dev/null; then
            #         # 4-1. 查询 nftables 防火墙配置
            #         nft_output=$(nft list ruleset 2>/dev/null)
            #         nftables_start_port=""
            #         nftables_end_port=""

            #         # 从查询结果中查找匹配 $config_port_number 的行，并提取起始端口和终止端口
            #         matched_line_nft=$(echo "$nft_output" | grep "$config_port_number")
            #         if [ -n "$matched_line_nft" ]; then
            #             # 提取匹配行中的端口范围
            #             nft_port_range=$(echo "$matched_line_nft" | grep -oP 'dport \d+(-\d+)?' | grep -oP '\d+(-\d+)?')
            #             if [[ "$nft_port_range" =~ "-" ]]; then
            #                 # 提取起始端口和终止端口
            #                 nftables_start_port=$(echo "$nft_port_range" | cut -d'-' -f1)
            #                 nftables_end_port=$(echo "$nft_port_range" | cut -d'-' -f2)
            #             else
            #                 # 只有单个端口的情况
            #                 nftables_start_port=$nft_port_range
            #                 nftables_end_port=$nft_port_range
            #             fi
            #         fi
            #     fi
            #     # 5. 确认 $ip4tables_start_port 和 $ip6tables_start_port 的存在情况
            #     if [ -n "$ip4tables_start_port" ]; then
            #         # 只要 $ip4tables_start_port 存在，就将 $iptables_start_port 设为 $ip4tables_start_port
            #         iptables_start_port=$ip4tables_start_port
            #     elif [ -z "$ip4tables_start_port" ] && [ -n "$ip6tables_start_port" ]; then
            #         # 仅当 $ip4tables_start_port 不存在且 $ip6tables_start_port 存在时，才将 $iptables_start_port 设为 $ip6tables_start_port
            #         iptables_start_port=$ip6tables_start_port
            #     else
            #         # 如果两个变量都没有值，将 $iptables_start_port 设为 "undefined"
            #         iptables_start_port="undefined"
            #     fi

            #     # 6. 确认 $ip4tables_end_port 和 $ip6tables_end_port 的存在情况
            #     if [ -n "$ip4tables_end_port" ]; then
            #         # 只要 $ip4tables_end_port 存在，无论 $ip6tables_end_port 是否存在，都将 $iptables_end_port 设为 $ip4tables_end_port
            #         iptables_end_port=$ip4tables_end_port
            #     elif [ -z "$ip4tables_end_port" ] && [ -n "$ip6tables_end_port" ]; then
            #         # 仅当 $ip4tables_end_port 不存在且 $ip6tables_end_port 存在时，才将 $iptables_end_port 设为 $ip6tables_end_port
            #         iptables_end_port=$ip6tables_end_port
            #     else
            #         # 如果两个变量都没有值，将 $iptables_end_port 设为 "undefined"
            #         iptables_end_port="undefined"
            #     fi

            #     # 7. 确认 $iptables_start_port 和 $nftables_start_port 的存在情况
            #     if [ "$iptables_start_port" != "undefined" ] && [ "$nftables_start_port" == "undefined" ]; then
            #         # 仅当 $iptables_start_port 存在且 $nftables_start_port 不存在时
            #         echo ""
            #         echo -e "${CYAN}通过 iptables 防火墙查询到 Hysteria 2 服务的端口转发范围为 ${iptables_start_port} 到 ${iptables_end_port}。${RESET}"

            #     elif [ "$iptables_start_port" != "undefined" ] && [ "$nftables_start_port" != "undefined" ]; then
            #         # 当 $iptables_start_port 和 $nftables_start_port 都存在时
            #         if [ "$iptables_start_port" == "$nftables_start_port" ] && [ "$iptables_end_port" == "$nftables_end_port" ]; then
            #             # 当两个防火墙的起始端口和终止端口都一致时
            #             echo ""
            #             echo -e "${CYAN}通过 iptables 和 nftables 防火墙查询到 Hysteria 2 服务的端口转发范围为 ${iptables_start_port} 到 ${iptables_end_port}。${RESET}"
            #         else
            #             # 当两个防火墙的起始端口和终止端口不一致时
            #             echo ""
            #             echo -e "${CYAN}通过 iptables 防火墙查询到 Hysteria 2 服务的端口转发范围为 ${iptables_start_port} 到 ${iptables_end_port}。${RESET}"
            #             echo -e "${CYAN}通过 nftables 防火墙查询到 Hysteria 2 服务的端口转发范围为 ${nftables_start_port} 到 ${nftables_end_port}。${RESET}"
            #         fi
            #     else
            #         # 当 $iptables_start_port 和 $nftables_start_port 都不存在时
            #         echo ""
            #         echo -e "${RED}端口跳跃范围查询失败！iptables 和 nftables 防火墙配置中均没有和 Hysteria 2 服务监听端口相关的端口转发配置。${RESET}"
            #     fi

            #     # 8. 提示返回上一级菜单
            #     return_to_sub_menu
            #     ;;
            3)
                # 打印域名

                # 1. 清屏
                clear
                echo -e "${BLUE}正在查询自备域名…${RESET}"

                # 2. 打印域名
                config_domain=$(grep -m 1 'domains:' -A 1 /etc/hysteria/config.yaml | grep -Eo '^[[:space:]]*-[[:space:]]*[^[:space:]#]+' | sed 's/^[[:space:]]*-[[:space:]]*//')
                if [ -n "$config_domain" ]; then
                    echo ""
                    echo -e "${CYAN}Hysteria 2 服务使用的自备配置域名为：${RESET}${config_domain}"
                else
                    echo ""
                    echo -e "${RED}域名查询失败！未能从配置文件中找到域名，这可能是您使用无域名方式搭建 Hysteria 2，或者是 YAML 文件存在的语法等。${RESET}"
                fi
                
                # 3.  提示返回上一级菜单
                return_to_sub_menu
                ;;
            4)
                # 打印密码
                
                # 1. 清屏
                clear
                echo -e "${BLUE}正在查询密码…${RESET}"

                # 2. 打印密码
                config_passwd=$(grep '^  password:' /etc/hysteria/config.yaml | sed -E 's/^[[:space:]]*password:[[:space:]]*//;s/[[:space:]]+#.*//')
                if [ -n "$config_passwd" ]; then
                    echo ""
                    echo -e "${CYAN}Hysteria 2 服务配置的密码为：${RESET}${config_passwd}"
                else
                    echo ""
                    echo -e "${RED}密码查询失败！未能从配置文件中找到密码。${RESET}"
                fi

                # 3.  提示返回上一级菜单
                return_to_sub_menu
                ;;
            5)
                # 打印证书及其密钥保存路径

                # 1. 清屏
                clear
                echo -e "${BLUE}正在查询证书和私钥保存路径…${RESET}"

                # 2. 提取证书和密钥路径

                # 提取证书路径，允许路径中包含空格，并且检查是否以 .crt 结尾
                cert_profile_path=$(grep '^  cert:' /etc/hysteria/config.yaml | sed -E 's/^[[:space:]]*cert:[[:space:]]*//;s/[[:space:]]*#.*//' | grep -Eo '/[^[:space:]]+\.crt$')
                # 提取密钥路径，允许路径中包含空格，并且检查是否以 .key 结尾
                key_profile_path=$(grep '^  key:' /etc/hysteria/config.yaml | sed -E 's/^[[:space:]]*key:[[:space:]]*//;s/[[:space:]]*#.*//' | grep -Eo '/[^[:space:]]+\.key$')
                
                # 3. 打印路径
                if [ -n "$cert_profile_path" ] && [ -n "$key_profile_path" ]; then
                    echo ""
                    echo -e "${CYAN}自签证书保存路径：${RESET}${cert_profile_path}"
                    echo -e "${CYAN}私钥保存路径：${RESET}${key_profile_path}"
                else
                    echo ""
                    echo -e "${RED}证书和私钥保存路径查询失败！未能从配置文件中找到证书或密钥路径，这可能是因为您使用自备域名方式搭建 Hysteria 2。${RESET}"
                fi

                # 4. 提示返回上一级菜单
                return_to_sub_menu
                ;;
            0)
                # 返回主菜单
                tput reset
                return 0
                ;;
            *)
                # 无效输入，提示并重新读取输入

                echo ""
                echo -e "${RED}您的输入有误！${RESET}"
                echo ""
                read -p "$(echo -e "${RESET}请重新您的输入选择 [0-5]：${RESET}")" config_choice
                ;;
        esac
    done
}

# 11.常用工具
common_tools() {
    while true; do
        # 1. 清屏
        clear

        # 2. 提示信息
        echo ""
        echo ""
        echo -e "${ORANGE}请选择您要使用的工具："
        echo ""
        echo ""
        echo -e "${GREEN}  1. 域名解析检测"
        echo -e "${GREEN}  2. 端口占用检测"
        echo -e "${GREEN}  3. 查看防火墙配置内容"
        echo ""
        echo -e "${YELLOW}  0. 返回主菜单"
        echo ""
        echo ""
        read -p "$(echo -e "${RESET}请输入您的选择 [0-3]：${RESET}")" tool_choice

        case "$tool_choice" in
            1)
                # 1. 清屏
                clear

                # 2. 域名解析检测
                read -p "$(echo -e "${RESET}请输入您要检测的域名: ")" domain

                # 首次检测方案：nslookup
                domain_ip=$(nslookup "$domain" | awk '/^Address: / { print $2 }' | grep -v "#")

                if [ -z "$domain_ip" ]; then
                    echo ""
                    echo -e "${RED}第一次检测失败！${RESET}"
                    echo ""
                    echo -e "${BLUE}正在尝试使用备用方案检测…${RESET}"
                    # 备用检测方案：dig
                    domain_ip=$(dig +short "$domain" A)
                fi

                server_ip=$(curl -s ifconfig.me)

                if [ -z "$domain_ip" ]; then
                    echo ""
                    echo -e "检测失败！该域名没有配置 A 记录或解析失败，请检查域名配置。"
                else
                    echo ""
                    echo -e "${CYAN}您查询的域名解析 IP 为: ${RESET}$domain_ip"
                    echo -e "${CYAN}当前服务器 IP 为: ${RESET}$server_ip"
                    
                    if [ "$domain_ip" == "$server_ip" ]; then
                        echo ""
                        echo -e "${GREEN}您查询的域名已解析到本服务器 IP。${RESET}"
                    else
                        echo ""
                        echo -e "${YELLOW}您查询的域名尚未解析到本服务器 IP，请等待 DNS 传播后再试，或前往域名管理面板确认。${RESET}"
                    fi
                fi

                # 3. 返回子菜单
                return_to_sub_menu
                ;;
            2)
                # 1. 清屏
                clear

                # 定义端口号校验函数
                validate_port() {
                    if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]; then
                        return 0  # 端口号有效
                    else
                        return 1  # 端口号无效
                    fi
                }

                # 2. 端口占用检测
                while true; do
                    read -p "$(echo -e "${RESET}请输入您要检测的端口号 (1-65535): ${RESET}")" port_number
                    if validate_port "$port_number"; then
                        if ss -lntu | grep -q ":$port_number "; then
                            service=$(ss -lntu | grep ":$port_number " | awk '{print $1}')
                            echo ""
                            echo -e "${YELLOW}您查询的端口号正在被 $service 监听中!${RESET}"
                        else
                            echo ""
                            echo -e "${GREEN}您查询的端口号没有被占用！${RESET}"
                        fi
                        break  # 跳出循环，结束端口号输入
                    else
                        echo ""
                        echo -e "${RED}您输入的端口号无效！请重新输入（1-65535）。${RESET}"
                    fi
                done

                # 3. 返回子菜单
                return_to_sub_menu
                ;;
            3)
                # 1. 清屏
                clear

                # 2. 检测防火墙安装状态
                echo -e "${BLUE}正在检测当前系统使用的防火墙…${RESET}"
                iptables_installed=$(dpkg -l | grep iptables)
                nftables_installed=$(dpkg -l | grep nftables)
                firewalld_installed=$(dpkg -l | grep firewalld)
                ufw_installed=$(dpkg -l | grep ufw)

                # 输出检测到的防火墙状态
                if [ -n "$iptables_installed" ]; then
                    echo ""
                    echo -e "${RESET}已检测到 iptables 防火墙。${RESET}"
                fi

                if [ -n "$nftables_installed" ]; then
                    echo ""
                    echo -e "${RESET}已检测到 nftables 防火墙。${RESET}"
                fi

                if [ -n "$firewalld_installed" ]; then
                    echo ""
                    echo -e "${RESET}已检测到 firewalld 防火墙。${RESET}"
                fi

                # 打印防火墙配置
                if [ -n "$nftables_installed" ] && [ -z "$iptables_installed" ]; then
                    echo ""
                    echo -e "${BLUE}准备打印防火墙配置…${RESET}"
                    echo ""
                    echo -e "${CYAN}nftables 防火墙配置如下：${RESET}"
                    echo ""
                    nft list ruleset
                    return_to_sub_menu
                elif [ -n "$firewalld_installed" ]; then
                    echo ""
                    echo -e "${BLUE}准备打印防火墙配置…${RESET}"
                    echo ""
                    echo -e "${CYAN}firewalld 防火墙配置如下：${RESET}"
                    echo ""
                    firewall-cmd --list-all
                    return_to_sub_menu
                elif [ -n "$iptables_installed" ] && [ -z "$nftables_installed" ]; then
                    echo ""
                    echo -e "${BLUE}准备打印防火墙配置…${RESET}"
                    echo ""
                    echo -e "${CYAN}iptables 防火墙配置如下：${RESET}"
                    echo ""
                    iptables -L
                    return_to_sub_menu
                elif [ -n "$iptables_installed" ] && [ -n "$nftables_installed" ]; then
                    # 同时检测到 iptables 和 nftables，用户选择操作
                    while true; do
                        echo ""
                        echo -e "${ORANGE}请选择您要进行的操作：${RESET}"
                        echo ""
                        echo -e "${GREEN}  1. 打印 iptables 防火墙配置"
                        echo -e "${GREEN}  2. 打印 nftables 防火墙配置"
                        echo ""
                        echo -e "${YELLOW}  0. 返回上一级菜单"
                        echo ""
                        read -p "$(echo -e "${RESET}请输入您的选择: [1/2/0]${RESET}")" user_choice

                        case $user_choice in
                            1)
                                echo ""
                                echo -e "${BLUE}准备打印防火墙配置：${RESET}"
                                sleep 1
                                echo ""
                                echo -e "${CYAN}iptables 防火墙配置如下：${RESET}"
                                echo ""
                                iptables -L
                                return_to_sub_menu
                                ;;
                            2)
                                echo ""
                                echo -e "${BLUE}准备打印防火墙配置：${RESET}"
                                sleep 1
                                echo ""
                                echo -e "${CYAN}nftables 防火墙配置如下：${RESET}"
                                echo ""
                                nft list ruleset
                                return_to_sub_menu
                                ;;
                            0)
                                tput reset
                                return
                                ;;
                            *)
                                echo ""
                                echo -e "${RED}您的输入有误！${RESET}"
                                echo ""
                                read -p "$(echo -e "${RESET}请重新您的输入选择 [1/2/0]：${RESET}")" user_choice
                                ;;
                        esac
                    done
                else
                    echo ""
                    echo -e "${YELLOW}未在当前系统检测到防火墙工具/配置！${RESET}"
                    echo ""
                    echo -e "${MAGENTA}即将中止打印流程…${RESET}"
                    echo ""
                    return_to_sub_menu
                fi

                # 2. 返回子菜单
                return_to_sub_menu
                ;;
            0)
                # 返回主菜单
                tput reset
                return 0
                ;;
            *)
                # 无效输入，提示并重新读取输入

                echo ""
                echo -e "${RED}您的输入有误！${RESET}"
                echo ""
                read -p "$(echo -e "${RESET}请重新您的输入选择 [0-3]：${RESET}")" tool_choice
                ;;
        esac
    done
}

# 主程序循环
while true; do
    show_menu
    read_choice
    process_choice
done
