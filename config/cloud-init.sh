#!/bin/bash
sudo apt-get update
sudo apt-get install -y sudo nano bind9-host

mkdir /etc/systemd/resolved.conf.d/
printf "[Resolve]\nDNS=127.0.0.1\nDNSStubListener=no\n" >/etc/systemd/resolved.conf.d/adguardhome.conf
mv /etc/resolv.conf /etc/resolv.conf.backup
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl reload-or-restart systemd-resolved

wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz
tar xvf AdGuardHome_linux_amd64.tar.gz
rm /AdGuardHome_linux_amd64.tar.gz

cd AdGuardHome || exit
echo "${adguard_config}" >AdGuardHome.yaml
curl https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt --output /AdGuardHome/data/filters/1.txt
curl https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt --output /AdGuardHome/data/filters/2.txt
curl https://www.malwaredomainlist.com/hostslist/hosts.txt --output /AdGuardHome/data/filters/4.txt

sudo ./AdGuardHome -s install
sudo ./AdGuardHome -s start
