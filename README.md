# Bash Port Scanner

A simple Bash script to scan ports on a given IP address.

## Installation

1. Clone the repository:

```
git clone https://github.com/jason-allen-oneal/bash-port-scan.git
```

2. Make the script executable:

```
chmod +x bash-port-scan.sh
```

## Usage

```
./bash-port-scan.sh -i <IP_ADDRESS> -p <PORTS>
```

### Options

- `-i | --ip`: specify the IP address to scan (required)
- `-p | --ports`: specify the port(s) to scan (required). This can be a comma-separated list or a range (e.g. 80-100).

### Example

```
./bash-port-scan.sh -i 127.0.0.1 -p 80,443
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.