#!/bin/bash

verbose=0
empty=""

while [ "$1" != "$empty" ]; do
	case "$1" in
		-h | --help )
printf "bash-port-scan.sh v0.1\r\nUsage: ./bash-port-scan.sh -i 127.0.0.1 -p 80,443\r\n./bash-port-scan.sh -i 127.0.0.1 -p 1-1000\r\n"; shift;;
		-v | --verbose )
verbose=1; shift;;
		-i | --ip )	
ip="$2";	shift;;
		-p | --ports )
ports="$2";	shift;; 
	esac
	shift
done

if [[ "$ip" = "$empty" ]]; then
	echo "Please enter an IP address with -i"
	exit
fi

if [[ "$ports" = "$empty" ]]; then
	echo "Please enter the port(s) with -p"
	exit
fi

portarray=()
if [[ "$ports" == *","* ]]; then
	IFS=','
	read -r -a portarray <<< "$ports"
elif [[ "$ports" == *"-"* ]]; then
	IFS='-'	
	read -r -a range <<< "$ports"
	
	first="${range[0]}"
	last="${range[1]}"
	
	mapfile -t portarray < <(seq $first 1 $last)
else
	portarray=($ports)
fi

if [ $verbose -eq 1 ]; then
	echo "Beginning scan of $ip"
fi

mapfile -t portarray < <(shuf -e "${portarray[@]}")

for p in "${portarray[@]}"; do
	result=$(nc -zvw5 $ip $p 2>&1 | grep open)
	if [ "$result" = "$empty" ]; then
		if [ $verbose -eq 1 ]; then
			str="Port "
			closed=" closed"
			echo "$str$p$closed"
		fi
	else
		str="Port "
		closed=" open"
		echo "$str$p$closed"
	fi
done

echo "Scan complete."