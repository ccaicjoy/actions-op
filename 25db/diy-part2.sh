#!/bin/bash
#
# 版权所有 (c) 2019-2020 P3TERX <https://p3terx.com>
#
# 本程序是自由软件，根据 MIT 许可证授权。
# 详情请参阅 /LICENSE 文件。
#
# https://github.com/P3TERX/Actions-OpenWrt
# 文件名: diy-part2.sh
# 描述: OpenWrt DIY 脚本 Part 2 (更新 feeds 之后执行)
#

# 修改默认 IP 地址
# 使用 sed 命令修改默认 IP 地址，将 192.168.1.1 替换为 192.168.50.5
# 注意：此行目前被注释掉，默认 IP 修改功能未启用。如果需要修改默认 IP，请移除行首的 '#' 符号。
# sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

##-----------------删除重复软件包------------------
# 删除重复的软件包，这里是删除 open-app-filter 软件包
rm -rf feeds/packages/net/open-app-filter

##-----------------添加 OpenClash 开发版核心文件------------------
# 添加 OpenClash 开发版核心文件
# 从 GitHub 下载 OpenClash 开发版核心文件 clash-linux-arm64.tar.gz 到 /tmp 目录
# 使用 curl 命令下载，参数说明：
#   -sL: 静默模式，显示错误信息，并跟随重定向
#   -m 30: 设置最大下载时间为 30 秒
#   --retry 2: 下载失败重试 2 次
#   -o /tmp/clash.tar.gz:  将下载的文件保存为 /tmp/clash.tar.gz
curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz

# 解压下载的 clash.tar.gz 压缩包到 /tmp 目录
# 使用 tar 命令解压，参数说明：
#   zxvf: z (gzip 格式), x (解压), v (显示详细信息), f (指定文件)
#   -C /tmp: 解压到 /tmp 目录
#   >/dev/null 2>&1:  将标准输出和标准错误输出重定向到 /dev/null，静默输出
tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1

# 给解压后的 /tmp/clash 文件添加可执行权限
# 使用 chmod 命令修改权限，参数说明：
#   +x: 添加可执行权限
#   >/dev/null 2>&1: 静默输出
chmod +x /tmp/clash >/dev/null 2>&1

# 创建目录 feeds/luci/applications/luci-app-openclash/root/etc/openclash/core，用于存放 clash 核心文件
# 使用 mkdir 命令创建目录，参数说明：
#   -p: 递归创建目录，如果父目录不存在也一并创建
mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core

# 将 /tmp/clash 文件移动到 luci-app-openclash 软件包的 core 目录，并重命名为 clash
# 使用 mv 命令移动文件，参数说明：
#   >/dev/null 2>&1: 静默输出
mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash >/dev/null 2>&1

# 删除下载的压缩包文件 /tmp/clash.tar.gz，清理临时文件
# 使用 rm 命令删除文件，参数说明：
#   -rf: 递归强制删除目录和文件
#   >/dev/null 2>&1: 静默输出
rm -rf /tmp/clash.tar.gz >/dev/null 2>&1

##-----------------删除 DDNS 的示例配置-----------------
# 删除 DDNS 配置文件中默认的 myddns_ipv4 示例配置段落
# 使用 sed 命令编辑文件，参数说明：
#   -i: 直接修改文件内容
#   '/myddns_ipv4/,$d': sed 地址范围和命令
#     '/myddns_ipv4/,$': 地址范围，从匹配到 'myddns_ipv4' 的行开始到文件末尾 ($)
#     d: 删除命令，删除匹配地址范围内的行
#   feeds/packages/net/ddns-scripts/files/etc/config/ddns: 要修改的文件路径
sed -i '/myddns_ipv4/,$d' feeds/packages/net/ddns-scripts/files/etc/config/ddns

##-----------------手动设置 MT7981B 的 CPU 频率-----------------
# 手动设置 MT7981B 设备的 CPU 频率为 1.3GHz
# 使用 sed 命令修改 cpuinfo 文件
#   -i: 直接修改文件内容
#   '/"mediatek"\/\*|\"mvebu"\/\*/{n; s/.*/\tcpu_freq="1.3GHz" ;;/}'：复杂的 sed 命令
#     '/"mediatek"\/\*|\"mvebu"\/\*/': 正则表达式，匹配包含 "mediatek" 或 "mvebu" 的行
#       "mediatek" 和 "mvebu" 是目标平台标识
#       \/\*  :  \* 需要转义，表示字面意义的星号 *
#       | :  或者
#     {n; s/.*/\tcpu_freq="1.3GHz" ;;} :  sed 块命令
#       n: 读取下一行到模式空间 (当前处理行变为匹配行的下一行)
#       s/.*/\tcpu_freq="1.3GHz" ;; : 替换命令，替换当前行所有内容为 '\tcpu_freq="1.3GHz" ;;'
#         . : 匹配任意字符
#         * : 匹配前一个字符零次或多次
#         \t : 制表符
#         cpu_freq="1.3GHz" ;; : 要替换的字符串，设置 cpu_freq 变量为 "1.3GHz"
#   package/emortal/autocore/files/generic/cpuinfo: 要修改的文件路径，cpuinfo 配置文件
sed -i '/"mediatek"\/\*|\"mvebu"\/\*/{n; s/.*/\tcpu_freq="1.3GHz" ;;/}' package/emortal/autocore/files/generic/cpuinfo
