# Bash Port Scanner

A fast, feature-rich port scanner written in Bash that uses netcat for reliable TCP port scanning.

## ✨ Features

- **Fast scanning** with configurable concurrency
- **Flexible port specification** (single ports, comma-separated lists, ranges)
- **Hostname support** (not just IP addresses)
- **Colored output** for better readability
- **Configurable timeout** for different network conditions
- **Verbose mode** for detailed scanning information
- **Input validation** with helpful error messages
- **Progress tracking** during scans

## 🚀 Installation

### Prerequisites

- **Bash** (version 4.0 or higher)
- **Netcat** (`nc`) - for TCP port scanning
- **Linux/macOS** (tested on Ubuntu, CentOS, macOS)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/jason-allen-oneal/bash-port-scan.git
   cd bash-port-scan
   ```

2. **Make the script executable:**
   ```bash
   chmod +x bash-port-scan.sh
   ```

3. **Test the installation:**
   ```bash
   ./bash-port-scan.sh -h
   ```

## 📖 Usage

### Basic Syntax

```bash
./bash-port-scan.sh -i <TARGET> -p <PORTS> [OPTIONS]
```

### Required Parameters

- `-i, --ip <TARGET>`: Target IP address or hostname to scan
- `-p, --ports <PORTS>`: Port(s) to scan (see Port Formats below)

### Optional Parameters

- `-v, --verbose`: Enable verbose output (show closed ports)
- `-t, --timeout <SECONDS>`: Connection timeout in seconds (default: 5)
- `-c, --concurrent <NUMBER>`: Number of concurrent connections (default: 10)
- `-h, --help`: Show help message

### Port Formats

| Format | Example | Description |
|--------|---------|-------------|
| Single port | `80` | Scan one specific port |
| Multiple ports | `80,443,8080` | Scan multiple specific ports |
| Port range | `1-1000` | Scan a range of ports |
| Mixed | `22,80,443,8080-8090` | Combine single ports and ranges |

## 🔍 Examples

### Basic Usage

```bash
# Scan common web ports
./bash-port-scan.sh -i 127.0.0.1 -p 80,443

# Scan a port range
./bash-port-scan.sh -i 192.168.1.1 -p 1-1000

# Scan using hostname
./bash-port-scan.sh -i example.com -p 22,80,443
```

### Advanced Usage

```bash
# Verbose scan with progress tracking
./bash-port-scan.sh -i 10.0.0.1 -p 22,80,443,8080-8090 -v

# Fast scan with custom timeout and concurrency
./bash-port-scan.sh -i 192.168.1.100 -p 1-65535 -t 3 -c 20

# Quick scan of common ports
./bash-port-scan.sh -i localhost -p 21,22,23,25,53,80,110,143,443,993,995
```

### Network Security Testing

```bash
# Scan for common services
./bash-port-scan.sh -i target.example.com -p 21,22,23,25,53,80,110,143,443,993,995,1433,1521,3306,3389,5432,5900,6379,8080,8443

# Quick vulnerability assessment
./bash-port-scan.sh -i 192.168.1.0/24 -p 22,80,443 -t 2 -c 50
```

## 📊 Output Examples

### Standard Output
```
Starting port scan...
Target: 127.0.0.1
Ports: 3 (80 443 8080)
Timeout: 5s
Concurrent: 10
----------------------------------------
[OPEN] Port 80
[OPEN] Port 443
----------------------------------------
Scan complete!
Found 2 open port(s) out of 3 scanned
```

### Verbose Output
```
Starting port scan...
Target: example.com
Ports: 5 (22 80 443 8080 8443)
Timeout: 5s
Concurrent: 10
----------------------------------------
Scanning port 22 (1/5)... [CLOSED] Port 22
Scanning port 80 (2/5)... [OPEN] Port 80
Scanning port 443 (3/5)... [OPEN] Port 443
Scanning port 8080 (4/5)... [CLOSED] Port 8080
Scanning port 8443 (5/5)... [CLOSED] Port 8443
----------------------------------------
Scan complete!
Found 2 open port(s) out of 5 scanned
```

## ⚙️ Configuration

### Performance Tuning

- **Timeout**: Lower values (1-3s) for fast local networks, higher values (5-10s) for slower networks
- **Concurrency**: Higher values (20-50) for faster scanning, lower values (5-10) for stealth scanning
- **Port ranges**: Use specific port lists instead of large ranges for faster results

### Common Use Cases

| Scenario | Recommended Settings |
|----------|---------------------|
| Local network scan | `-t 2 -c 20` |
| Internet scan | `-t 5 -c 10` |
| Stealth scan | `-t 3 -c 5` |
| Fast scan | `-t 1 -c 50` |

## 🔧 Troubleshooting

### Common Issues

**"Netcat (nc) is required"**
```bash
# Ubuntu/Debian
sudo apt-get install netcat

# CentOS/RHEL
sudo yum install nc

# macOS
brew install netcat
```

**"Permission denied"**
```bash
chmod +x bash-port-scan.sh
```

**"Invalid IP address"**
- Ensure the target is a valid IP address or hostname
- Check DNS resolution for hostnames

**"No open ports found"**
- Verify the target is reachable (`ping <target>`)
- Check firewall settings
- Try increasing timeout with `-t 10`

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⚠️ Disclaimer

This tool is for educational and authorized security testing purposes only. Always ensure you have permission to scan the target systems. The authors are not responsible for any misuse of this tool.

## 📈 Version History

- **v0.2** - Enhanced error handling, colored output, new features
- **v0.1** - Initial release with basic port scanning functionality