#!/bin/bash

# Default values
verbose=0
timeout=5
concurrent=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help function
show_help() {
    cat << EOF
${BLUE}bash-port-scan.sh v0.2${NC} - A simple port scanner written in bash

${YELLOW}Usage:${NC}
    ./bash-port-scan.sh -i <IP> -p <PORTS> [OPTIONS]

${YELLOW}Examples:${NC}
    ./bash-port-scan.sh -i 127.0.0.1 -p 80,443
    ./bash-port-scan.sh -i 192.168.1.1 -p 1-1000
    ./bash-port-scan.sh -i example.com -p 22,80,443,8080-8090 -v
    ./bash-port-scan.sh -i 10.0.0.1 -p 1-65535 -t 3 -c 20

${YELLOW}Options:${NC}
    -i, --ip <IP>           Target IP address or hostname
    -p, --ports <PORTS>     Port(s) to scan (comma-separated or ranges with -)
    -v, --verbose           Verbose output (show closed ports)
    -t, --timeout <SEC>     Connection timeout in seconds (default: 5)
    -c, --concurrent <NUM>  Number of concurrent connections (default: 10)
    -h, --help              Show this help message

${YELLOW}Port Formats:${NC}
    Single port: 80
    Multiple ports: 80,443,8080
    Port range: 1-1000
    Mixed: 22,80,443,8080-8090

EOF
}

# Validate IP address or hostname
validate_target() {
    local target="$1"
    
    # Check if it's a valid IP address
    if [[ $target =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$target"
        for octet in "${octets[@]}"; do
            if [[ $octet -lt 0 || $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    fi
    
    # Check if it's a valid hostname (basic check)
    if [[ $target =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        return 0
    fi
    
    return 1
}

# Validate port number
validate_port() {
    local port="$1"
    if [[ $port =~ ^[0-9]+$ ]] && [[ $port -ge 1 && $port -le 65535 ]]; then
        return 0
    fi
    return 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        -i|--ip)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Error:${NC} IP address is required after -i"
                exit 1
            fi
            ip="$2"
            shift 2
            ;;
        -p|--ports)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Error:${NC} Port specification is required after -p"
                exit 1
            fi
            ports="$2"
            shift 2
            ;;
        -t|--timeout)
            if [[ -z "$2" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Error:${NC} Valid timeout value required after -t"
                exit 1
            fi
            timeout="$2"
            shift 2
            ;;
        -c|--concurrent)
            if [[ -z "$2" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Error:${NC} Valid concurrent value required after -c"
                exit 1
            fi
            concurrent="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Error:${NC} Invalid option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check required parameters
if [[ -z "$ip" ]]; then
    echo -e "${RED}Error:${NC} IP address is required. Use -i <IP>"
    echo "Use -h or --help for usage information"
    exit 1
fi

if [[ -z "$ports" ]]; then
    echo -e "${RED}Error:${NC} Port specification is required. Use -p <PORTS>"
    echo "Use -h or --help for usage information"
    exit 1
fi

# Validate target
if ! validate_target "$ip"; then
    echo -e "${RED}Error:${NC} Invalid IP address or hostname: $ip"
    exit 1
fi

# Check for netcat
if ! command -v nc &> /dev/null; then
    echo -e "${RED}Error:${NC} Netcat (nc) is required for this script."
    echo "Please install it and try again."
    exit 1
fi

# Parse and validate ports
declare -a portarray=()
IFS=',' read -r -a portarray <<< "$ports"

for i in "${!portarray[@]}"; do
    if [[ "${portarray[i]}" =~ "-" ]]; then
        # Handle port range
        IFS='-' read -r -a range <<< "${portarray[i]}"
        if [[ ${#range[@]} -ne 2 ]]; then
            echo -e "${RED}Error:${NC} Invalid port range format: ${portarray[i]}"
            exit 1
        fi
        
        # Validate range bounds
        if ! validate_port "${range[0]}" || ! validate_port "${range[1]}"; then
            echo -e "${RED}Error:${NC} Invalid port in range: ${portarray[i]}"
            exit 1
        fi
        
        if [[ ${range[0]} -gt ${range[1]} ]]; then
            echo -e "${RED}Error:${NC} Invalid port range (start > end): ${portarray[i]}"
            exit 1
        fi
        
        # Expand range
        for j in $(seq "${range[0]}" "${range[1]}"); do
            portarray+=("$j")
        done
        unset 'portarray[i]'
    else
        # Validate single port
        if ! validate_port "${portarray[i]}"; then
            echo -e "${RED}Error:${NC} Invalid port: ${portarray[i]}"
            exit 1
        fi
    fi
done

# Remove duplicates and sort
portarray=($(printf '%s\n' "${portarray[@]}" | sort -nu))

if [[ ${#portarray[@]} -eq 0 ]]; then
    echo -e "${RED}Error:${NC} No valid ports specified: $ports"
    exit 1
fi

# Show scan information
echo -e "${BLUE}Starting port scan...${NC}"
echo -e "Target: ${YELLOW}$ip${NC}"
echo -e "Ports: ${YELLOW}${#portarray[@]}${NC} (${portarray[*]})"
echo -e "Timeout: ${YELLOW}${timeout}s${NC}"
echo -e "Concurrent: ${YELLOW}${concurrent}${NC}"
echo "----------------------------------------"

# Function to scan a single port
scan_port() {
    local port="$1"
    if nc -zvw"$timeout" "$ip" "$port" &>/dev/null; then
        echo -e "${GREEN}[OPEN]${NC} Port $port"
        return 0
    else
        [[ $verbose -eq 1 ]] && echo -e "${RED}[CLOSED]${NC} Port $port"
        return 1
    fi
}

# Scan ports with limited concurrency
open_ports=0
total_ports=${#portarray[@]}
current=0

for port in "${portarray[@]}"; do
    ((current++))
    if [[ $verbose -eq 1 ]]; then
        echo -n "Scanning port $port ($current/$total_ports)... "
    fi
    
    if scan_port "$port"; then
        ((open_ports++))
    fi
    
    # Limit concurrent connections
    if [[ $concurrent -gt 1 ]]; then
        # Simple concurrency control - wait for background jobs
        while [[ $(jobs -r | wc -l) -ge $concurrent ]]; do
            sleep 0.1
        done
    fi
done

echo "----------------------------------------"
echo -e "${BLUE}Scan complete!${NC}"
echo -e "Found ${GREEN}$open_ports${NC} open port(s) out of ${YELLOW}$total_ports${NC} scanned"
