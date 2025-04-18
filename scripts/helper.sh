#!/bin/bash

# 检查并引入 /etc/tailscale/tools.sh 文件
[ -f /etc/tailscale/tools.sh ] && . /etc/tailscale/tools.sh

if [ -s "$VALID_MIRRORS" ]; then
    custom_proxy=$(head -n 1 "$VALID_MIRRORS")
else
    custom_proxy="https://ghproxy.ch3ng.top/https://github.com/"
fi

# 自动判断 curl 和 wget 可用性
get_download_tool() {
    if command -v curl > /dev/null 2>&1; then
        echo "curl"
    elif command -v wget > /dev/null 2>&1; then
        echo "wget"
    else
        log_info "❌ 没有找到 curl 或 wget，无法下载或执行操作。"
        exit 1
    fi
}

# 获取可用的下载工具
download_tool=$(get_download_tool)

show_menu() {
    log_info 
    log_info 
    log_info "请选择操作："
    log_info "1. 安装 Tailscale (包括重装)"
    log_info "2. 启动 Tailscale"
    log_info "3. 管理 Tailscale 自动更新"
    log_info "4. 查看本地 Tailscale 版本"
    log_info "5. 查看 Tailscale 最新版本"
    log_info "6. 管理推送"
    log_info "7. 排序代理池"
    log_info "8. 更新代理池"
    log_info "9. 更新脚本包"
    log_info "10. 卸载 Tailscale"
    log_info "0. 退出"
}

# 处理用户选择
handle_choice() {
    case $1 in
        1)
            /etc/tailscale/setup.sh
            ;;
        2)
            tailscale up
            ;;
        3)
            /etc/tailscale/update_ctl.sh
            ;;
        4)
            if [ -f "$VERSION_FILE" ]; then
                log_info "📦 当前本地版本: $(cat "$VERSION_FILE")"
            else
                log_info "⚠️ 本地未记录版本信息"
            fi
            ;;
        5)
            /etc/tailscale/fetch_and_install.sh --dry-run
            ;;
        6)
            /etc/tailscale/notify_ctl.sh
            ;;
        7)
            /etc/tailscale/test_mirrors.sh
            ;;
        8)
            if [ "$download_tool" = "curl" ]; then
                curl -sSL -o /tmp/pretest_mirrors.sh "${custom_proxy}CH3NGYZ/ts-test/raw/refs/heads/main/pretest_mirrors.sh" && sh /tmp/pretest_mirrors.sh
            else
                wget -O /tmp/pretest_mirrors.sh "${custom_proxy}CH3NGYZ/ts-test/raw/refs/heads/main/pretest_mirrors.sh" && sh /tmp/pretest_mirrors.sh
            fi
            ;;
        9)
            if [ "$download_tool" = "curl" ]; then
                curl -sSL "${custom_proxy}CH3NGYZ/ts-test/raw/refs/heads/main/install.sh" | sh
            else
                wget -O- "${custom_proxy}CH3NGYZ/ts-test/raw/refs/heads/main/install.sh" | sh
            fi
            log_info 请重启 tailscale-helper 命令以使用最新脚本
            ;;
        10)
            /etc/tailscale/uninstall.sh
            ;;
        0)
            exit 0
            ;;
        *)
            log_info "❌ 无效选择，请重新输入。"
            ;;
    esac
}

# 主循环
while true; do
    show_menu
    log_info "✅ 请输入你的选择:"
    read choice
    handle_choice "$choice"
    sleep 3
done
