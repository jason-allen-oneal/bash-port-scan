#!/bin/bash

while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help)
			printf "bash-port-scan.sh v0.1\nUsage: ./bash-port-scan.sh -i 127.0.0.1 -p 80,443\n./bash-port-scan.sh -i 127.0.0.1 -p 1-1000\n"; 
			exit;;
		-v|--verbose)
			verbose=1;;
		-i|--ip) ip="$2"; shift;;
		-p|--ports) ports="$2"; shift;;
		*) echo "Invalid option: $1"; exit 1;;
	esac
	shift
done

if [[ -z "$ip" ]]; then
	echo "Please enter an IP address with -i"
	exit 1
fi

if [[ -z "$ports" ]]; then
	echo "Please enter the port(s) with -p"
	exit 1
fi

portarray=()
IFS=',' read -r -a portarray <<< "$ports"
for i in "${!portarray[@]}"; do
	if [[ "${portarray[i]}" =~ "-" ]]; then
		IFS='-' read -r -a range <<< "${portarray[i]}"
		if [[ ${#range[@]} -ne 2 || ! ${range[0]} =~ ^[0-9]+$ || ! ${range[1]} =~ ^[0-9]+$ || ${range[0]} -gt ${range[1]} ]]; then
			echo "Invalid port range: ${portarray[i]}"
			exit 1
		fi
		for j in $(seq "${range[0]}" "${range[1]}"); do portarray+=("$j"); done
		unset 'portarray[i]'
	fi
done
portarray=($(echo "${portarray[@]}" | tr ' ' '\n' | sort -nu))
if [[ ${#portarray[@]} -eq 0 ]]; then
	echo "Invalid port(s): $ports"
	exit 1
fi

if ! command -v nc &> /dev/null; then
	echo "Netcat (nc) is required for this script. Please install it and try again."
	exit 1
fi

[[ $verbose -eq 1 ]] && echo "Beginning scan of $ip"
shuf_portarray=($(shuf -e "${portarray[@]}"))
for p in "${shuf_portarray[@]}"; do
	if nc -zvw5 "$ip" "$p" &>/dev/null; then
		echo "$([[ $verbose -eq 1 ]] && echo "Port $p open" || echo "$p")"
	else
		[[ $verbose -eq 1 ]] && echo "Port $p closed"
	fi
done
echo "Scan complete."
