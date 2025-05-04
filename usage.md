# Kubernetes & Docker Monitoring Tool - Usage Guide

**Version:** 1.0.0  
**Author:** Juni-crypto  
**Date:** 2025-05-04 14:30:02 UTC  
**GitHub:** https://github.com/Juni-crypto  
**Organization:** ChumaoruWorks Club  

This document provides detailed instructions for using the Kubernetes & Docker Monitoring Tool.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Main Menu](#main-menu)
3. [Kubernetes Monitoring](#kubernetes-monitoring)
4. [Docker Monitoring](#docker-monitoring)
5. [System Resource Monitoring](#system-resource-monitoring)
6. [Exporting Statistics](#exporting-statistics)
7. [Tips and Tricks](#tips-and-tricks)
8. [Troubleshooting](#troubleshooting)

## Getting Started

### Starting the Tool

Once installed, you can launch the tool by running:

```bash
stat-helper
```

If you installed manually, navigate to the script's directory and run:

```bash
./stat-helper.sh
```

### Tool Overview

Upon launching, the tool displays:

- Current date and time (UTC)
- Your username and hostname
- Status of Kubernetes and Docker services
- Main menu options

## Main Menu

The main menu dynamically adjusts based on your environment:

- **Kubernetes Statistics**: Available if Kubernetes is running
- **Docker Statistics**: Available if Docker is running
- **System Resource Statistics**: Always available
- **Export Statistics to File**: Always available
- **Help**: Always available
- **Exit**: Always available

Navigate using the number keys and press Enter to select an option.

## Kubernetes Monitoring

### Complete Statistics

Shows a comprehensive overview of your Kubernetes cluster including:

- Cluster version
- Node status
- Namespaces
- Running pods across all namespaces

### Pod Management

This submenu offers detailed pod management capabilities:

- **All Pods Overview**: List pods across all namespaces
- **Pods in Specific Namespace**: Filter pods by namespace
- **Detailed Pod Information**: View complete information for a specific pod
- **Pod Resource Usage**: View CPU and memory consumption
- **Pod Logs**: Access pod logs
- **List Containers in Pod**: View all containers in a specific pod
- **Container Shell Access**: Get interactive shell access to containers
- **Run Command in Container**: Execute commands in containers

### Container Shell Access

To access a container shell:

1. Select "Container Shell Access"
2. Choose the namespace
3. Select the pod
4. Choose the container (if multiple exist)
5. Select the shell type (bash, sh, or custom)

You'll get an interactive terminal session in the container. Type `exit` to return to the monitoring tool.

### Namespace Management

View and inspect namespace details and their resources.

### Node Statistics

View detailed information about cluster nodes including:

- Status
- Roles
- CPU and memory allocation
- Resource usage

### Deployment and Service Statistics

View configurations and status of deployments and services across namespaces.

### Resource Usage

Monitor CPU and memory consumption across:

- Nodes
- Pods
- Containers

### Events Monitor

Track cluster events with timestamps for troubleshooting.

### Logs Viewer

Access and follow logs from any pod or container with filtering options.

## Docker Monitoring

### Container Dashboard

Provides an overview of all Docker containers with:

- Container counts (total, running, stopped)
- Container IDs, names, images, and status
- Port mappings

### Image Management

Lists all Docker images with:

- Repository and tag information
- Image sizes
- Creation dates
- Dangling image detection

### Detailed Container Information

Inspect detailed information about any container including:

- Basic information (ID, name, image)
- State details (running, paused, restarting)
- Network settings
- Volume mounts
- Resource usage (if running)

### Container Shell Access

To access a Docker container shell:

1. Select "Container Shell Access" from the Docker menu
2. Choose a container from the list
3. Select the shell type (bash, sh, or custom)

You'll get an interactive terminal session in the container. Type `exit` to return to the monitoring tool.

### Run Command in Container

Execute one-off commands in a container:

1. Select "Run Command in Container"
2. Choose a container
3. Select a command from the common commands list or enter a custom command

The command output will be displayed immediately.

### Resource Usage Monitor

View real-time CPU, memory, and I/O usage for all running containers.

### Network and Volume Management

Inspect and manage Docker networks and volumes.

## System Resource Monitoring

### System Overview

Provides a complete overview of your system:

- Hostname and OS details
- CPU and memory information
- Disk usage
- Network interfaces

### CPU Statistics

Detailed CPU information with:

- CPU model, cores, and threads
- Current CPU load
- Top CPU-consuming processes

### Memory Statistics

Memory usage visualization with:

- Total, used, and free memory
- Swap usage
- Memory usage percentage
- Top memory-consuming processes

### Disk Usage

Detailed disk usage information:

- Filesystem usage
- Mount points
- Usage percentages with visual indicators
- Option to find largest directories

### Network Statistics

View active network interfaces and connections.

### Process Monitor

Interactive process monitoring with:

- Top CPU and memory processes
- Process search functionality

### System Load

Track system load with:

- 1, 5, and 15-minute load averages
- Load per CPU core with visual indicators
- Uptime information
- Current system status

## Exporting Statistics

The tool can export statistics to text files for offline analysis:

- **Export Kubernetes Stats**: Saves comprehensive Kubernetes information
- **Export Docker Stats**: Saves Docker container and image information
- **Export System Stats**: Saves system resource information
- **Export All Stats**: Combines all statistics into a single file

Exports are saved to `./stats_exports/` with timestamps in the filename.

## Tips and Tricks

- **Navigation**: Press Enter to return to the previous menu after viewing information
- **Exit**: Press Ctrl+C at any time to exit the application
- **Terminal Size**: For best experience, use a terminal with at least 80x24 characters
- **Color Support**: Make sure your terminal supports ANSI color codes for optimal visualization
- **Refresh Data**: Exit and re-enter a menu to refresh the displayed information
- **Following Logs**: When viewing logs, choose the follow option to see real-time updates

## Troubleshooting

### Common Issues

#### Kubernetes Not Detected

- Ensure kubectl is properly installed and configured
- Check that your kubeconfig file is correctly set up
- Verify cluster connectivity with `kubectl cluster-info`

#### Docker Not Detected

- Ensure Docker is installed and running with `systemctl status docker`
- Verify your user has permissions to access Docker
- Try running with sudo if you have permission issues

#### Display Issues

- If colors aren't displaying correctly, check your terminal's color support
- For box drawing issues, ensure your terminal supports UTF-8

#### Performance

- On large clusters, some operations may take time
- Use namespace filters to reduce query scope

### Command Reference

| Feature | Command Example |
|---------|----------------|
| View Pod Logs | `kubectl logs <pod> -n <namespace>` |
| Container Shell | `kubectl exec -it <pod> -c <container> -n <namespace> -- /bin/bash` |
| Docker Container Shell | `docker exec -it <container> bash` |
| Export All Stats | Select "Export Statistics to File" > "Export All Stats" |

© 2025 Juni-crypto, ChumaoruWorks Club. All rights reserved.

For additional help or to report issues, please visit: https://github.com/Juni-crypto/stat-helper/issues