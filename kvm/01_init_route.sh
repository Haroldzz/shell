#!/usr/bin/env bash
#
ip route add 10.8.0.0/16 via 10.1.234.254
ip route add 192.168.10.0/24 via 10.1.234.254
ip route add 192.168.11.0/24 via 10.1.234.254
ip route add 192.168.12.0/24 via 10.1.234.254
ip route add 192.168.13.0/24 via 10.1.234.254
ip route add 192.168.14.0/24 via 10.1.234.254
ip route add 192.168.15.0/24 via 10.1.234.254
ip route add 192.168.16.0/24 via 10.1.234.254
ip route del default via 10.1.234.254
ip route add default via 10.1.234.11
