# Kubernetes & Docker Monitoring Tool

![Version](https://img.shields.io/badge/version-v1.0.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

A comprehensive, terminal-based monitoring tool for Kubernetes clusters, Docker environments, and system resources. This tool provides a unified interface for managing and monitoring your containerized infrastructure with an intuitive menu-driven approach.

## 🌟 Features

### Kubernetes Monitoring
- **Cluster Overview**: View nodes, namespaces, and cluster health
- **Pod Management**: List, inspect, and manage pods across namespaces
- **Container Access**: Shell into containers and execute commands
- **Resource Tracking**: Monitor CPU and memory usage across the cluster
- **Log Viewing**: Access real-time logs from pods and containers
- **Deployment & Service Management**: Monitor and inspect deployments and services

### Docker Monitoring
- **Container Dashboard**: Real-time overview of running and stopped containers
- **Image Management**: List, inspect, and manage Docker images
- **Shell Access**: Get shell access to running containers
- **Resource Monitoring**: Track CPU, memory, and disk usage of containers
- **Network Statistics**: View and analyze Docker network configurations
- **Volume Management**: Inspect and manage Docker volumes

### System Resource Monitoring
- **System Overview**: CPU, memory, disk, and network statistics
- **Process Monitoring**: Track resource usage by processes
- **Performance Analysis**: View system load and performance metrics

### Additional Features
- **Export Capabilities**: Export statistics to text files for offline analysis
- **User-Friendly Interface**: Intuitive menu-driven navigation
- **Color-Coded Output**: Easy-to-read terminal output with color highlights
- **Real-Time Updates**: Live monitoring of resources and events

## 🚀 Quick Start

### Installation

**Method 1: Quick Installation (Recommended)**

```bash
# Clone the repository
git clone https://github.com/Juni-crypto/stat-helper.git
cd stat-helper

# Run the installer script
sudo ./install.sh

# Launch the tool
stat-helper
```

**Method 2: Manual Installation**

```bash
# Download the script
git clone https://github.com/Juni-crypto/stat-helper.git
cd stat-helper

# Make the script executable
chmod +x stat-helper.sh

# Run the script
./stat-helper.sh
```

**Method 3: User-local Installation**

```bash
# Clone the repository
git clone https://github.com/Juni-crypto/stat-helper.git
cd stat-helper

# Run the setup script
./setup.sh

# Reload your shell configuration
source ~/.bashrc

# Launch the tool
stat-helper
```

## 📋 Requirements
- **Kubernetes Monitoring**: Requires kubectl to be installed and configured
- **Docker Monitoring**: Requires Docker to be installed and running
- **System Monitoring**: Uses standard Linux utilities (ps, top, free, etc.)
- **Terminal**: Bash shell environment with color support
- **Permissions**: Some features may require admin/root privileges

## 🔧 Compatibility
- **Linux**: Fully compatible with major distributions (Ubuntu, Debian, CentOS, etc.)
- **macOS**: Compatible with recent versions
- **Windows**: Compatible through WSL (Windows Subsystem for Linux)

## 👤 Author
Developed by Juni-Crypto @ ChumaoruWorks Club

GitHub: https://github.com/Juni-crypto

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

## 📱 Contact
For issues, feature requests, or contributions, please open an issue on the GitHub repository.