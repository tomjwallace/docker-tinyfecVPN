#!/bin/sh

TINYVPN="tinyvpn"

function main () {
	ensureTunExists
	start $@
}

function ensureTunExists () {
	if [ ! -c /dev/net/tun ]; then
		mkdir -p /dev/net
		mknod /dev/net/tun c 10 200
	fi
}

function getDefaultGateway () {
	echo $(ip route | grep default | head -n1 | tr " " "\n" | grep -A1 via | tail -n1)
}

function getInterfaceName () {
	if [ -n "$1" ]; then
		echo $(ip -d tuntap | grep -B1 $TINYVPN | head -n1 | cut -d: -f1)
	fi
}

function getType () {
	for arg in $@; do
		case $arg in
			"-c"|"-s")
				echo $arg
				;;
		esac
	done
}

function makeRouting () {
	if [ -n "$1" ]; then
		case $2 in
			"-c")
				GATEWAY=$(getDefaultGateway)
				ip route delete default
				ip route add default dev $1
				ip route add 10.0.0.0/8 via $GATEWAY
				ip route add 172.16.0.0/12 via $GATEWAY
				ip route add 192.168.0.0/16 via $GATEWAY
				iptables -t nat -A POSTROUTING -o $1 -j MASQUERADE
				;;
			"-s")
				iptables -t nat -A POSTROUTING ! -o $1 -j MASQUERADE
				;;
		esac
	fi
}

function start () {
	$TINYVPN $@ &
	sleep 1
	makeRouting $(getInterfaceName $!) $(getType $@)
	trap "kill -TERM $!" TERM
	wait $!
}

main $@
