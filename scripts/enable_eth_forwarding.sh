#!/usr/bin/env bash
sudo ip l set eth0 up
sudo ip a a 192.168.10.1/24 dev eth0
sudo /etc/init.d/dnsmasq restart
sudo sysctl -w net/ipv4/ip_forward=1
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
