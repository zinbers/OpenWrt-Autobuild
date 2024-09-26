#!/bin/bash
clear

## Custom-made
# GCC CFlags for R2S
sed -i 's,-mcpu=generic,-march=armv8-a,g' include/target.mk
# Overclock or not
rm -rf ./target/linux/rockchip/patches-5.15/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch
cp -f ../PATCH/overclock/999-rk3328-enable-1512mhz-and-minimum-at-816mhz.patch ./target/linux/rockchip/patches-5.15/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch
# Add PWM fans
#wget -P target/linux/rockchip/armv8/base-files/etc/init.d/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/etc/init.d/fa-rk3328-pwmfan
#wget -P target/linux/rockchip/armv8/base-files/usr/bin/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/usr/bin/start-rk3328-pwm-fan.sh
#sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
# Swap LAN & WAN
#sed -i 's,"eth1" "eth0","eth0" "eth1",g' target/linux/rockchip/armv8/base-files/etc/board.d/02_network
#sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network
# Switch to vendor rtl8152 driver
# sed -i 's,kmod-usb-net-rtl8152,kmod-usb-net-rtl8152-vendor,g' target/linux/rockchip/image/armv8.mk
# Addition-Trans-zh-master
cp -rf ../PATCH/duplicate/addition-trans-zh-rockchip ./package/utils/addition-trans-zh
# Add cputemp.sh and fix Apple iOS apns
cp -rf ../PATCH/script/cputemp.sh ./package/base-files/files/bin/cputemp
cp -rf ../PATCH/duplicate/files ./files

# Match Vermagic
latest_release="$(curl -s https://api.github.com/repos/openwrt/openwrt/tags | grep -Eo "v23.05.+[0-9\.]" | head -n 1 | sed 's/v//g')"
wget https://downloads.openwrt.org/releases/${latest_release}/targets/rockchip/armv8/packages/Packages.gz
zgrep -m 1 "Depends: kernel (=.*)$" Packages.gz | sed -e 's/.*-\(.*\))/\1/' >.vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

# Final Cleanup
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
