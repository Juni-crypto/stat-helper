#!/bin/bash

# Kubernetes & Docker Monitoring Tool
# Created by ChumaOruWorks and Juni-Crypto
# Version 1.0.0

# Check for terminal capabilities
if [ -t 1 ]; then
  # Colors for better visual experience - only if terminal supports it
  BOLD='\033[1m'
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  PURPLE='\033[0;35m'
  CYAN='\033[0;36m'
  GRAY='\033[0;37m'
  NC='\033[0m' # No Color
else
  # No colors for non-terminals
  BOLD=''
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  PURPLE=''
  CYAN=''
  GRAY=''
  NC=''
fi

# Make sure we have proper UTF-8 support, otherwise use ASCII
if locale -k LC_CTYPE 2>/dev/null | grep -q "charmap=UTF-8"; then
  # Box drawing characters for tables - Unicode
  H_LINE="─"
  V_LINE="│"
  TL_CORNER="┌"
  TR_CORNER="┐"
  BL_CORNER="└"
  BR_CORNER="┘"
  T_DOWN="┬"
  T_UP="┴"
  T_RIGHT="├"
  T_LEFT="┤"
  CROSS="┼"
else
  # ASCII fallback
  H_LINE="-"
  V_LINE="|"
  TL_CORNER="+"
  TR_CORNER="+"
  BL_CORNER="+"
  BR_CORNER="+"
  T_DOWN="+"
  T_UP="+"
  T_RIGHT="+"
  T_LEFT="+"
  CROSS="+"
fi

# Function to create a horizontal line without sequential numbers
draw_line() {
    local width=$1
    local char=${2:-$H_LINE}
    printf "%s" $TL_CORNER
    for ((i=1; i<=width; i++)); do
        printf "%s" "$char"
    done
    printf "%s\n" $TR_CORNER
}

# Function to create a horizontal separator
draw_separator() {
    local width=$1
    local char=${2:-$H_LINE}
    printf "%s" $T_RIGHT
    for ((i=1; i<=width; i++)); do
        printf "%s" "$char"
    done
    printf "%s\n" $T_LEFT
}

# Function to create a bottom line
draw_bottom_line() {
    local width=$1
    local char=${2:-$H_LINE}
    printf "%s" $BL_CORNER
    for ((i=1; i<=width; i++)); do
        printf "%s" "$char"
    done
    printf "%s\n" $BR_CORNER
}

# Function to create a container for text
draw_container() {
    local text="$1"
    local padding=$2
    local width=$(( ${#text} + (padding * 2) ))
    
    draw_line $width
    printf "%s%*s%s%*s%s\n" "$V_LINE" $padding "" "$text" $padding "" "$V_LINE"
    draw_bottom_line $width
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to center text
center_text() {
    local text="$1"
    local width=$2
    local textwidth=${#text}
    local padding=$(( (width - textwidth) / 2 ))
    
    printf "%*s%s%*s" $padding "" "$text" $(( width - textwidth - padding )) ""
}

# Function to display header with current date/time and username
display_header() {
    clear
    current_date=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    current_user=$(whoami)
    host_name=$(hostname)
    
    width=70
    
    draw_line $width
    printf "%s %-68s %s\n" "$V_LINE" "$(center_text "Kubernetes & Docker Monitoring Tool" 68)" "$V_LINE"
    draw_separator $width
    printf "%s ${GREEN}%-20s${NC} ${CYAN}%45s${NC} %s\n" "$V_LINE" "Date:" "$current_date" "$V_LINE"
    printf "%s ${GREEN}%-20s${NC} ${CYAN}%45s${NC} %s\n" "$V_LINE" "User:" "$current_user" "$V_LINE"
    printf "%s ${GREEN}%-20s${NC} ${CYAN}%45s${NC} %s\n" "$V_LINE" "Host:" "$host_name" "$V_LINE"
    
    # Credits section
    draw_separator $width
    printf "%s %-68s %s\n" "$V_LINE" "$(center_text "Developed by Juni-Crypto @ ChumaoruWorks Club" 68)" "$V_LINE"
    printf "%s %-68s %s\n" "$V_LINE" "$(center_text "https://github.com/Juni-crypto" 68)" "$V_LINE"
    
    # System status indicators
    draw_separator $width
    printf "%s %-68s %s\n" "$V_LINE" "$(center_text "System Status" 68)" "$V_LINE"
    
    # Check Kubernetes status
    if is_kube_running; then
        kube_status="${GREEN}● Active${NC}"
        kube_version=$(kubectl version --short 2>/dev/null | grep "Client Version" | cut -d ":" -f2 | tr -d ' ')
    else
        kube_status="${RED}○ Inactive${NC}"
        kube_version="N/A"
    fi
    
    # Check Docker status
    if is_docker_running; then
        docker_status="${GREEN}● Active${NC}"
        docker_version=$(docker version --format '{{.Client.Version}}' 2>/dev/null || echo "N/A")
    else
        docker_status="${RED}○ Inactive${NC}"
        docker_version="N/A"
    fi
    
    printf "%s ${GREEN}%-20s${NC} %s (%s) %s\n" "$V_LINE" "Kubernetes:" "$kube_status" "$kube_version" "$V_LINE"
    printf "%s ${GREEN}%-20s${NC} %s (%s) %s\n" "$V_LINE" "Docker:" "$docker_status" "$docker_version" "$V_LINE"
    
    draw_bottom_line $width
    echo ""
}

# Function to format section titles
section_title() {
    local title="$1"
    local width=70
    echo ""
    draw_line $width
    printf "%s ${BOLD}${YELLOW}%-$(($width-2))s${NC} %s\n" "$V_LINE" "$(center_text "$title" $(($width-2)))" "$V_LINE"
    draw_bottom_line $width
    echo ""
}

# Function to create a progress bar
progress_bar() {
    local percent=$1
    local width=40
    local completed=$(( width * percent / 100 ))
    local remaining=$(( width - completed ))
    
    printf "${BOLD}[${GREEN}"
    for ((i=1; i<=completed; i++)); do
        printf "#"
    done
    printf "${RED}"
    for ((i=1; i<=remaining; i++)); do
        printf "."
    done
    printf "${NC}${BOLD}] ${YELLOW}%d%%${NC}\n" $percent
}

# Function to check if Kubernetes is running
is_kube_running() {
    command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1
}

# Function to check if Docker is running
is_docker_running() {
    command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1
}

# Function to convert bytes to human-readable format
human_readable() {
    local bytes=$1
    if (( bytes < 1024 )); then
        echo "${bytes}B"
    elif (( bytes < 1048576 )); then
        echo "$((bytes / 1024))KB"
    elif (( bytes < 1073741824 )); then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# Function to format kubectl output with column
format_kubectl_output() {
    local cmd="$1"
    local header="$2"
    
    echo -e "${BOLD}${YELLOW}$header${NC}"
    eval "$cmd" | column -t
}

# Function to display Kubernetes stats menu
kube_stats_menu() {
    while true; do
        display_header
        section_title "Kubernetes Statistics Menu"
        
        options=(
            "Complete Stats"
            "Pod Management"
            "Namespace Management"
            "Node Stats"
            "Deployment Stats"
            "Service Stats"
            "Resource Usage"
            "Events Monitor"
            "Logs Viewer"
            "ConfigMap and Secret Management"
            "PersistentVolume Stats"
            "Cluster Health Dashboard"
            "Back to Main Menu"
        )
        
        for i in "${!options[@]}"; do
            printf " ${CYAN}%2d${NC}) ${GREEN}%s${NC}\n" $((i+1)) "${options[$i]}"
        done
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Select an option: "${NC})" kube_option
        
        case $kube_option in
            1)
                display_kubernetes_complete_stats
                ;;
            2)
                pod_stats_submenu
                ;;
            3)
                namespace_management
                ;;
            4)
                display_node_stats
                ;;
            5)
                display_deployment_stats
                ;;
            6)
                display_service_stats
                ;;
            7)
                display_resource_usage
                ;;
            8)
                display_events_monitor
                ;;
            9)
                logs_viewer
                ;;
            10)
                configmap_secret_management
                ;;
            11)
                display_persistent_volume_stats
                ;;
            12)
                display_cluster_health
                ;;
            13)
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Press Enter to continue..."${NC})"
    done
}

# Basic placeholder functions for Kubernetes functionality
display_kubernetes_complete_stats() {
    display_header
    section_title "Complete Kubernetes Statistics"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display stats.${NC}"
        return
    fi
    
    # Overview
    echo -e "${BOLD}${CYAN}CLUSTER OVERVIEW:${NC}"
    kubectl version --short || echo "Error retrieving Kubernetes version"
    
    echo ""
    echo -e "${BOLD}${CYAN}NODES:${NC}"
    kubectl get nodes || echo "No nodes found or cannot access node information"
    
    echo ""
    echo -e "${BOLD}${CYAN}NAMESPACES:${NC}"
    kubectl get namespaces || echo "No namespaces found"
    
    echo ""
    echo -e "${BOLD}${CYAN}PODS:${NC}"
    kubectl get pods --all-namespaces || echo "No pods found"
}

namespace_management() {
    display_header
    section_title "Namespace Management"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot manage namespaces.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}AVAILABLE NAMESPACES:${NC}"
    kubectl get namespaces
}

display_node_stats() {
    display_header
    section_title "Kubernetes Node Statistics"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display node stats.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}NODE DETAILS:${NC}"
    kubectl get nodes -o wide || echo "No nodes found or cannot access node information"
    
    # Get node resource usage if available
    if command_exists "kubectl"; then
        if kubectl top nodes &>/dev/null; then
            echo ""
            echo -e "${BOLD}${CYAN}NODE RESOURCE USAGE:${NC}"
            kubectl top nodes
        else
            echo ""
            echo -e "${YELLOW}kubectl top command not available or metrics server not running.${NC}"
            echo -e "${YELLOW}Unable to show resource usage.${NC}"
        fi
    fi
}

# Function to list containers in a pod
list_pod_containers() {
    display_header
    section_title "Containers in Pod"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot list containers.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}AVAILABLE NAMESPACES:${NC}"
    kubectl get namespaces || echo "No namespaces found"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Enter namespace (default: default): "${NC})" namespace
    namespace=${namespace:-default}
    
    echo ""
    echo -e "${BOLD}${CYAN}AVAILABLE PODS IN $namespace:${NC}"
    kubectl get pods -n $namespace || {
        echo -e "${RED}No pods found in namespace $namespace or namespace doesn't exist.${NC}"
        return
    }
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter pod name: "${NC})" pod_name
    
    if [ -z "$pod_name" ]; then
        echo -e "${RED}No pod name provided. Returning to menu.${NC}"
        return
    fi
    
    # Check if pod exists
    if ! kubectl get pod $pod_name -n $namespace &>/dev/null; then
        echo -e "${RED}Pod $pod_name not found in namespace $namespace.${NC}"
        return
    fi
    
    # Display container info
    echo ""
    echo -e "${BOLD}${CYAN}CONTAINERS IN POD '$pod_name':${NC}"
    draw_line 80
    printf "%s %-30s %s %-20s %s %-20s %s\n" "$V_LINE" "CONTAINER NAME" "$V_LINE" "IMAGE" "$V_LINE" "STATUS" "$V_LINE"
    draw_separator 80
    
    # Get container info
    containers=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.containers[*].name}')
    for container in $containers; do
        image=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{.spec.containers[?(@.name==\"$container\")].image}")
        ready=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{.status.containerStatuses[?(@.name==\"$container\")].ready}")
        
        if [ "$ready" = "true" ]; then
            status="${GREEN}Running${NC}"
        else
            state=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{.status.containerStatuses[?(@.name==\"$container\")].state}" | grep -oE 'waiting|running|terminated')
            if [ "$state" = "waiting" ]; then
                status="${YELLOW}Waiting${NC}"
            elif [ "$state" = "terminated" ]; then
                status="${RED}Terminated${NC}"
            else
                status="${GRAY}Unknown${NC}"
            fi
        fi
        
        printf "%s %-30s %s %-20s %s %-20b %s\n" "$V_LINE" "$container" "$V_LINE" "$image" "$V_LINE" "$status" "$V_LINE"
    done
    draw_bottom_line 80
    
    # Display init containers if any
    init_containers=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null)
    if [ -n "$init_containers" ]; then
        echo ""
        echo -e "${BOLD}${CYAN}INIT CONTAINERS:${NC}"
        draw_line 80
        printf "%s %-30s %s %-20s %s %-20s %s\n" "$V_LINE" "INIT CONTAINER NAME" "$V_LINE" "IMAGE" "$V_LINE" "STATUS" "$V_LINE"
        draw_separator 80
        
        for container in $init_containers; do
            image=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{.spec.initContainers[?(@.name==\"$container\")].image}")
            completed=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{.status.initContainerStatuses[?(@.name==\"$container\")].ready}")
            
            if [ "$completed" = "true" ]; then
                status="${GREEN}Completed${NC}"
            else
                state=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{.status.initContainerStatuses[?(@.name==\"$container\")].state}" | grep -oE 'waiting|running|terminated')
                if [ "$state" = "waiting" ]; then
                    status="${YELLOW}Waiting${NC}"
                elif [ "$state" = "running" ]; then
                    status="${BLUE}Running${NC}"
                elif [ "$state" = "terminated" ]; then
                    status="${RED}Terminated${NC}"
                else
                    status="${GRAY}Unknown${NC}"
                fi
            fi
            
            printf "%s %-30s %s %-20s %s %-20b %s\n" "$V_LINE" "$container" "$V_LINE" "$image" "$V_LINE" "$status" "$V_LINE"
        done
        draw_bottom_line 80
    fi
    
    # Display ephemeral containers if any (for K8s 1.20+)
    ephemeral_containers=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.ephemeralContainers[*].name}' 2>/dev/null)
    if [ -n "$ephemeral_containers" ]; then
        echo ""
        echo -e "${BOLD}${CYAN}EPHEMERAL CONTAINERS:${NC}"
        for container in $ephemeral_containers; do
            image=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{.spec.ephemeralContainers[?(@.name==\"$container\")].image}")
            echo "$container (Image: $image)"
        done
    fi
}

# Function to execute shell in a container
exec_container_shell() {
    display_header
    section_title "Container Shell Access"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot access container shell.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}AVAILABLE NAMESPACES:${NC}"
    kubectl get namespaces || echo "No namespaces found"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Enter namespace (default: default): "${NC})" namespace
    namespace=${namespace:-default}
    
    echo ""
    echo -e "${BOLD}${CYAN}AVAILABLE PODS IN $namespace:${NC}"
    kubectl get pods -n $namespace || {
        echo -e "${RED}No pods found in namespace $namespace or namespace doesn't exist.${NC}"
        return
    }
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter pod name: "${NC})" pod_name
    
    if [ -z "$pod_name" ]; then
        echo -e "${RED}No pod name provided. Returning to menu.${NC}"
        return
    fi
    
    # Check if pod exists
    if ! kubectl get pod $pod_name -n $namespace &>/dev/null; then
        echo -e "${RED}Pod $pod_name not found in namespace $namespace.${NC}"
        return
    fi
    
    # Get container list
    containers=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
    container_count=$(echo $containers | wc -w)
    
    if [ $container_count -gt 1 ]; then
        echo ""
        echo -e "${BOLD}${CYAN}AVAILABLE CONTAINERS IN POD:${NC}"
        echo $containers | tr ' ' '\n'
        echo ""
        
        read -p "$(echo -e ${YELLOW}"Enter container name: "${NC})" container_name
        
        if [ -z "$container_name" ]; then
            echo -e "${RED}No container name provided. Using first container.${NC}"
            container_name=$(echo $containers | awk '{print $1}')
        fi
    else
        container_name=$(echo $containers | awk '{print $1}')
    fi
    
    # Let the user choose the shell type
    echo ""
    echo -e "${BOLD}${CYAN}AVAILABLE SHELLS:${NC}"
    echo "1) /bin/bash (standard bash shell)"
    echo "2) /bin/sh (standard sh shell)"
    echo "3) Custom command"
    echo ""
    read -p "$(echo -e ${YELLOW}"Select shell option (default: 1): "${NC})" shell_option
    
    case $shell_option in
        2)
            shell_command="/bin/sh"
            ;;
        3)
            echo ""
            read -p "$(echo -e ${YELLOW}"Enter custom command (e.g. /bin/zsh): "${NC})" custom_command
            shell_command=${custom_command:-"/bin/sh"}
            ;;
        *)
            shell_command="/bin/bash"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Connecting to container '$container_name' in pod '$pod_name' (Namespace: $namespace)...${NC}"
    echo -e "${YELLOW}Type 'exit' to return to the monitoring tool.${NC}"
    echo -e "${CYAN}----- CONTAINER SHELL SESSION START -----${NC}"
    
    # Execute shell in the container
    if kubectl exec -it $pod_name -c $container_name -n $namespace -- $shell_command; then
        echo -e "${CYAN}----- CONTAINER SHELL SESSION END -----${NC}"
    else
        echo ""
        echo -e "${RED}Failed to connect to the container shell.${NC}"
        echo -e "${YELLOW}The selected shell '$shell_command' might not be available in the container.${NC}"
        echo -e "${YELLOW}Try selecting a different shell option.${NC}"
    fi
}

# Function to run a command in a container
run_container_command() {
    display_header
    section_title "Run Command in Container"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot run command in container.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}AVAILABLE NAMESPACES:${NC}"
    kubectl get namespaces || echo "No namespaces found"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Enter namespace (default: default): "${NC})" namespace
    namespace=${namespace:-default}
    
    echo ""
    echo -e "${BOLD}${CYAN}AVAILABLE PODS IN $namespace:${NC}"
    kubectl get pods -n $namespace || {
        echo -e "${RED}No pods found in namespace $namespace or namespace doesn't exist.${NC}"
        return
    }
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter pod name: "${NC})" pod_name
    
    if [ -z "$pod_name" ]; then
        echo -e "${RED}No pod name provided. Returning to menu.${NC}"
        return
    fi
    
    # Check if pod exists
    if ! kubectl get pod $pod_name -n $namespace &>/dev/null; then
        echo -e "${RED}Pod $pod_name not found in namespace $namespace.${NC}"
        return
    fi
    
    # Get container list
    containers=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
    container_count=$(echo $containers | wc -w)
    
    if [ $container_count -gt 1 ]; then
        echo ""
        echo -e "${BOLD}${CYAN}AVAILABLE CONTAINERS IN POD:${NC}"
        echo $containers | tr ' ' '\n'
        echo ""
        
        read -p "$(echo -e ${YELLOW}"Enter container name: "${NC})" container_name
        
        if [ -z "$container_name" ]; then
            echo -e "${RED}No container name provided. Using first container.${NC}"
            container_name=$(echo $containers | awk '{print $1}')
        fi
    else
        container_name=$(echo $containers | awk '{print $1}')
    fi
    
    # Get command to execute
    echo ""
    echo -e "${BOLD}${CYAN}COMMON COMMANDS:${NC}"
    echo "1) ls -la (List files with details)"
    echo "2) env (Show environment variables)"
    echo "3) ps aux (Show processes)"
    echo "4) cat /etc/os-release (Show OS info)"
    echo "5) df -h (Show disk space)"
    echo "6) netstat -tulpn (Show network connections)"
    echo "7) Custom command"
    echo ""
    read -p "$(echo -e ${YELLOW}"Select command option (default: 1): "${NC})" cmd_option
    
    case $cmd_option in
        2)
            command="env"
            ;;
        3)
            command="ps aux"
            ;;
        4)
            command="cat /etc/os-release"
            ;;
        5)
            command="df -h"
            ;;
        6)
            command="netstat -tulpn"
            ;;
        7)
            echo ""
            read -p "$(echo -e ${YELLOW}"Enter custom command: "${NC})" custom_command
            command=${custom_command:-"ls -la"}
            ;;
        *)
            command="ls -la"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Executing '$command' in container '$container_name' of pod '$pod_name' (Namespace: $namespace)...${NC}"
    echo -e "${CYAN}----- COMMAND OUTPUT START -----${NC}"
    
    # Execute command in the container
    if ! kubectl exec $pod_name -c $container_name -n $namespace -- sh -c "$command"; then
        echo -e "${RED}Command failed to execute.${NC}"
        echo -e "${YELLOW}The command or required tools might not be available in the container.${NC}"
    fi
    
    echo -e "${CYAN}----- COMMAND OUTPUT END -----${NC}"
}

pod_stats_submenu() {
    while true; do
        display_header
        section_title "Pod Management"
        
        options=(
            "All Pods Overview"
            "Pods in Specific Namespace"
            "Detailed Pod Information"
            "Pod Resource Usage"
            "Pod Logs"
            "List Containers in Pod" # New option
            "Container Shell Access" # New option
            "Run Command in Container" # New option
            "Back to Kubernetes Menu"
        )
        
        for i in "${!options[@]}"; do
            printf " ${CYAN}%2d${NC}) ${GREEN}%s${NC}\n" $((i+1)) "${options[$i]}"
        done
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Select an option: "${NC})" pod_option
        
        case $pod_option in
            1)
                display_all_pods_overview
                ;;
            2)
                display_pods_in_namespace
                ;;
            3)
                display_detailed_pod_info
                ;;
            4)
                display_pod_resource_usage
                ;;
            5)
                logs_viewer
                ;;
            6)
                list_pod_containers # New function
                ;;
            7)
                exec_container_shell # New function
                ;;
            8)
                run_container_command # New function
                ;;
            9)
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Press Enter to continue..."${NC})"
    done
}

display_all_pods_overview() {
    display_header
    section_title "All Pods Overview"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display pod overview.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}PODS BY NAMESPACE:${NC}"
    kubectl get pods --all-namespaces || echo "No pods found"
    
    # Show pod status summary if possible
    total_pods=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l)
    if [ "$total_pods" -gt 0 ]; then
        running_pods=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -c "Running")
        pending_pods=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -c "Pending")
        failed_pods=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -c "Failed")
        other_pods=$((total_pods - running_pods - pending_pods - failed_pods))
        
        echo ""
        echo -e "${BOLD}${CYAN}POD STATUS SUMMARY:${NC}"
        draw_line 60
        printf "%s %-15s %s %-15s %s %-15s %s\n" "$V_LINE" "Status" "$V_LINE" "Count" "$V_LINE" "Percentage" "$V_LINE"
        draw_separator 60
        printf "%s ${GREEN}%-15s${NC} %s %-15s %s %-15s %s\n" "$V_LINE" "Running" "$V_LINE" "$running_pods" "$V_LINE" "$(calculate_percentage $running_pods $total_pods)%" "$V_LINE"
        printf "%s ${YELLOW}%-15s${NC} %s %-15s %s %-15s %s\n" "$V_LINE" "Pending" "$V_LINE" "$pending_pods" "$V_LINE" "$(calculate_percentage $pending_pods $total_pods)%" "$V_LINE"
        printf "%s ${RED}%-15s${NC} %s %-15s %s %-15s %s\n" "$V_LINE" "Failed" "$V_LINE" "$failed_pods" "$V_LINE" "$(calculate_percentage $failed_pods $total_pods)%" "$V_LINE"
        printf "%s ${GRAY}%-15s${NC} %s %-15s %s %-15s %s\n" "$V_LINE" "Other" "$V_LINE" "$other_pods" "$V_LINE" "$(calculate_percentage $other_pods $total_pods)%" "$V_LINE"
        draw_bottom_line 60
    fi
}

display_pods_in_namespace() {
    display_header
    section_title "Pods in Specific Namespace"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display namespaced pods.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}AVAILABLE NAMESPACES:${NC}"
    kubectl get namespaces || echo "No namespaces found"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Enter namespace name: "${NC})" namespace
    
    if [ -z "$namespace" ]; then
        echo -e "${RED}No namespace provided. Using 'default'.${NC}"
        namespace="default"
    fi
    
    # Check if namespace exists
    if ! kubectl get namespace "$namespace" &>/dev/null; then
        echo -e "${RED}Namespace '$namespace' does not exist. Returning to menu.${NC}"
        return
    fi
    
    echo ""
    echo -e "${BOLD}${CYAN}PODS IN NAMESPACE '$namespace':${NC}"
    kubectl get pods -n "$namespace" || echo "No pods found in namespace $namespace"
}

display_detailed_pod_info() {
    display_header
    section_title "Detailed Pod Information"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display pod details.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}AVAILABLE NAMESPACES:${NC}"
    kubectl get namespaces || echo "No namespaces found"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Enter namespace (default: default): "${NC})" namespace
    namespace=${namespace:-default}
    
    echo ""
    echo -e "${BOLD}${CYAN}AVAILABLE PODS IN $namespace:${NC}"
    kubectl get pods -n $namespace || {
        echo -e "${RED}No pods found in namespace $namespace or namespace doesn't exist.${NC}"
        return
    }
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter pod name: "${NC})" pod_name
    
    if [ -z "$pod_name" ]; then
        echo -e "${RED}No pod name provided. Returning to menu.${NC}"
        return
    fi
    
    # Check if pod exists
    if ! kubectl get pod $pod_name -n $namespace &>/dev/null; then
        echo -e "${RED}Pod $pod_name not found in namespace $namespace.${NC}"
        return
    fi
    
    # Display detailed info
    echo ""
    echo -e "${BOLD}${CYAN}DETAILED INFORMATION FOR POD '$pod_name':${NC}"
    kubectl describe pod $pod_name -n $namespace
}

display_pod_resource_usage() {
    display_header
    section_title "Pod Resource Usage"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display resource usage.${NC}"
        return
    fi
    
    # Check if 'kubectl top' is available
    if ! kubectl top pods --all-namespaces &>/dev/null; then
        echo -e "${YELLOW}kubectl top command not available or metrics server not running.${NC}"
        echo -e "${YELLOW}Unable to show resource usage.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}POD RESOURCE USAGE (ALL NAMESPACES):${NC}"
    kubectl top pods --all-namespaces --sort-by=cpu
    
    echo ""
    read -p "$(echo -e ${YELLOW}"View pods in specific namespace? (y/n, default: n): "${NC})" view_namespace
    
    if [[ "$view_namespace" == "y" || "$view_namespace" == "Y" ]]; then
        echo ""
        echo -e "${BOLD}${CYAN}AVAILABLE NAMESPACES:${NC}"
        kubectl get namespaces || echo "No namespaces found"
        echo ""
        
        read -p "$(echo -e ${YELLOW}"Enter namespace name: "${NC})" namespace
        
        if [ -z "$namespace" ]; then
            echo -e "${RED}No namespace provided. Using 'default'.${NC}"
            namespace="default"
        fi
        
        # Check if namespace exists
        if ! kubectl get namespace "$namespace" &>/dev/null; then
            echo -e "${RED}Namespace '$namespace' does not exist. Returning to menu.${NC}"
            return
        fi
        
        echo ""
        echo -e "${BOLD}${CYAN}POD RESOURCE USAGE IN NAMESPACE '$namespace':${NC}"
        kubectl top pods -n "$namespace" --sort-by=cpu || echo "No resource usage data for pods in namespace $namespace"
    fi
}

display_deployment_stats() {
    display_header
    section_title "Deployment Statistics"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display deployment stats.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}ALL DEPLOYMENTS:${NC}"
    kubectl get deployments --all-namespaces || echo "No deployments found"
}

display_service_stats() {
    display_header
    section_title "Service Statistics"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display service stats.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}ALL SERVICES:${NC}"
    kubectl get services --all-namespaces || echo "No services found"
}

display_resource_usage() {
    display_header
    section_title "Resource Usage"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display resource usage.${NC}"
        return
    fi
    
    if kubectl top nodes &>/dev/null; then
        echo -e "${BOLD}${CYAN}NODE RESOURCE USAGE:${NC}"
        kubectl top nodes
        
        echo ""
        echo -e "${BOLD}${CYAN}POD RESOURCE USAGE:${NC}"
        kubectl top pods --all-namespaces
    else
        echo -e "${YELLOW}kubectl top command not available or metrics server not running.${NC}"
        echo -e "${YELLOW}Unable to show resource usage.${NC}"
    fi
}

display_events_monitor() {
    display_header
    section_title "Events Monitor"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display events.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}RECENT EVENTS:${NC}"
    kubectl get events --all-namespaces --sort-by='.lastTimestamp' || echo "No events found"
}

logs_viewer() {
    display_header
    section_title "Logs Viewer"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot view logs.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}AVAILABLE NAMESPACES:${NC}"
    kubectl get namespaces || echo "No namespaces found"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Enter namespace (default: default): "${NC})" namespace
    namespace=${namespace:-default}
    
    echo ""
    echo -e "${BOLD}${CYAN}AVAILABLE PODS IN $namespace:${NC}"
    kubectl get pods -n $namespace || {
        echo -e "${RED}No pods found in namespace $namespace or namespace doesn't exist.${NC}"
        return
    }
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter pod name: "${NC})" pod_name
    
    if [ -z "$pod_name" ]; then
        echo -e "${RED}No pod name provided. Returning to menu.${NC}"
        return
    fi
    
    # Check if pod exists
    if ! kubectl get pod $pod_name -n $namespace &>/dev/null; then
        echo -e "${RED}Pod $pod_name not found in namespace $namespace.${NC}"
        return
    fi
    
    # Get container list
    containers=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
    container_count=$(echo $containers | wc -w)
    
    if [ $container_count -gt 1 ]; then
        echo ""
        echo -e "${BOLD}${CYAN}AVAILABLE CONTAINERS IN POD:${NC}"
        echo $containers | tr ' ' '\n'
        echo ""
        
        read -p "$(echo -e ${YELLOW}"Enter container name: "${NC})" container_name
        
        if [ -z "$container_name" ]; then
            echo -e "${RED}No container name provided. Using first container.${NC}"
            container_name=$(echo $containers | awk '{print $1}')
        fi
        
        echo ""
        echo -e "${BOLD}${CYAN}LOGS FOR CONTAINER $container_name IN POD $pod_name:${NC}"
        kubectl logs $pod_name -c $container_name -n $namespace || echo "Failed to retrieve logs"
    else
        echo ""
        echo -e "${BOLD}${CYAN}LOGS FOR POD $pod_name:${NC}"
        kubectl logs $pod_name -n $namespace || echo "Failed to retrieve logs"
    fi
}

configmap_secret_management() {
    display_header
    section_title "ConfigMap and Secret Management"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot manage ConfigMaps and Secrets.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}AVAILABLE NAMESPACES:${NC}"
    kubectl get namespaces || echo "No namespaces found"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Enter namespace (default: default): "${NC})" namespace
    namespace=${namespace:-default}
    
    echo ""
    echo -e "${BOLD}${CYAN}CONFIGMAPS IN $namespace:${NC}"
    kubectl get configmaps -n $namespace || echo "No ConfigMaps found"
    
    echo ""
    echo -e "${BOLD}${CYAN}SECRETS IN $namespace:${NC}"
    kubectl get secrets -n $namespace || echo "No Secrets found"
}

display_persistent_volume_stats() {
    display_header
    section_title "PersistentVolume Statistics"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display PV stats.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}PERSISTENT VOLUMES:${NC}"
    kubectl get pv || echo "No PersistentVolumes found"
    
    echo ""
    echo -e "${BOLD}${CYAN}PERSISTENT VOLUME CLAIMS:${NC}"
    kubectl get pvc --all-namespaces || echo "No PersistentVolumeClaims found"
}

display_cluster_health() {
    display_header
    section_title "Cluster Health Dashboard"
    
    if ! is_kube_running; then
        echo -e "${RED}Kubernetes is not running. Cannot display cluster health.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}NODE STATUS:${NC}"
    kubectl get nodes || echo "No nodes found"
    
    echo ""
    echo -e "${BOLD}${CYAN}COMPONENT STATUS:${NC}"
    kubectl get componentstatuses 2>/dev/null || echo "ComponentStatus API deprecated or unavailable"
    
    echo ""
    echo -e "${BOLD}${CYAN}API SERVER HEALTH:${NC}"
    if kubectl get --raw='/healthz' &>/dev/null; then
        echo -e "${GREEN}API Server is healthy${NC}"
    else
        echo -e "${RED}API Server may have issues${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}${CYAN}NAMESPACE STATUS:${NC}"
    kubectl get namespaces || echo "No namespaces found"
}

# Function for Docker stats menu
docker_stats_menu() {
    while true; do
        display_header
        section_title "Docker Statistics Menu"
        
        options=(
            "Container Dashboard"
            "Image Management"
            "Detailed Container Information"
            "Resource Usage Monitor"
            "Network Statistics"
            "Volume Management"
            "Docker System Information"
            "Docker Events Monitor"
            "Container Logs Viewer"
            "Container Shell Access"  # New option
            "Run Command in Container" # New option
            "Back to Main Menu"
        )
        
        for i in "${!options[@]}"; do
            printf " ${CYAN}%2d${NC}) ${GREEN}%s${NC}\n" $((i+1)) "${options[$i]}"
        done
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Select an option: "${NC})" docker_option

        case $docker_option in
            1)
                display_container_dashboard
                ;;
            2)
                display_image_management
                ;;
            3)
                display_detailed_container_info
                ;;
            4)
                display_docker_resource_usage
                ;;
            5)
                display_network_stats
                ;;
            6)
                display_volume_stats
                ;;
            7)
                display_docker_system_info
                ;;
            8)
                display_docker_events
                ;;
            9)
                docker_logs_viewer
                ;;
            10)
                docker_container_shell
                ;;
            11)
                docker_run_command
                ;;
            12)
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Press Enter to continue..."${NC})"
    done
}

# Function for Docker container shell access
docker_container_shell() {
    display_header
    section_title "Docker Container Shell Access"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot access container shell.${NC}"
        return
    fi
    
    # Get container list
    echo -e "${BOLD}${CYAN}RUNNING CONTAINERS:${NC}"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" || {
        echo -e "${RED}No running containers found.${NC}"
        return
    }
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter container ID or name: "${NC})" container
    
    if [ -z "$container" ]; then
        echo -e "${RED}No container specified. Returning to menu.${NC}"
        return
    fi
    
    # Check if container exists
    if ! docker inspect "$container" &>/dev/null; then
        echo -e "${RED}Container '$container' does not exist. Returning to menu.${NC}"
        return
    fi
    
    # Check if container is running
    if [ "$(docker inspect --format='{{.State.Running}}' "$container" 2>/dev/null)" != "true" ]; then
        echo -e "${RED}Container '$container' is not running. Cannot access shell.${NC}"
        echo -e "${YELLOW}Would you like to start the container? (y/n, default: n): ${NC}"
        read start_container
        
        if [[ "$start_container" == "y" || "$start_container" == "Y" ]]; then
            echo -e "${BLUE}Starting container '$container'...${NC}"
            if ! docker start "$container"; then
                echo -e "${RED}Failed to start container '$container'. Returning to menu.${NC}"
                return
            fi
            echo -e "${GREEN}Container started successfully.${NC}"
        else
            echo -e "${YELLOW}Container was not started. Returning to menu.${NC}"
            return
        fi
    fi
    
    # Let the user choose the shell type
    echo ""
    echo -e "${BOLD}${CYAN}AVAILABLE SHELLS:${NC}"
    echo "1) /bin/bash (standard bash shell)"
    echo "2) /bin/sh (standard sh shell)"
    echo "3) Custom command"
    echo ""
    read -p "$(echo -e ${YELLOW}"Select shell option (default: 1): "${NC})" shell_option
    
    case $shell_option in
        2)
            shell_command="sh"
            ;;
        3)
            echo ""
            read -p "$(echo -e ${YELLOW}"Enter custom command (e.g. zsh): "${NC})" custom_command
            shell_command=${custom_command:-"sh"}
            ;;
        *)
            shell_command="bash"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Connecting to container '$container' shell...${NC}"
    echo -e "${YELLOW}Type 'exit' to return to the monitoring tool.${NC}"
    echo -e "${CYAN}----- CONTAINER SHELL SESSION START -----${NC}"
    
    # Execute shell in the container
    if docker exec -it "$container" $shell_command; then
        echo -e "${CYAN}----- CONTAINER SHELL SESSION END -----${NC}"
    else
        echo ""
        echo -e "${RED}Failed to connect to the container shell.${NC}"
        echo -e "${YELLOW}The selected shell '$shell_command' might not be available in the container.${NC}"
        echo -e "${YELLOW}Try selecting a different shell option.${NC}"
    fi
}

# Function to run a command in a Docker container
docker_run_command() {
    display_header
    section_title "Run Command in Docker Container"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot run command in container.${NC}"
        return
    fi
    
    # Get container list
    echo -e "${BOLD}${CYAN}AVAILABLE CONTAINERS:${NC}"
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}" || {
        echo -e "${RED}No containers found.${NC}"
        return
    }
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter container ID or name: "${NC})" container
    
    if [ -z "$container" ]; then
        echo -e "${RED}No container specified. Returning to menu.${NC}"
        return
    fi
    
    # Check if container exists
    if ! docker inspect "$container" &>/dev/null; then
        echo -e "${RED}Container '$container' does not exist. Returning to menu.${NC}"
        return
    fi
    
    # Check if container is running
    if [ "$(docker inspect --format='{{.State.Running}}' "$container" 2>/dev/null)" != "true" ]; then
        echo -e "${YELLOW}Container '$container' is not running. Commands may not work properly.${NC}"
        echo -e "${YELLOW}Would you like to start the container? (y/n, default: n): ${NC}"
        read start_container
        
        if [[ "$start_container" == "y" || "$start_container" == "Y" ]]; then
            echo -e "${BLUE}Starting container '$container'...${NC}"
            if ! docker start "$container"; then
                echo -e "${RED}Failed to start container '$container'. Returning to menu.${NC}"
                return
            fi
            echo -e "${GREEN}Container started successfully.${NC}"
        fi
    fi
    
    # Get command to execute
    echo ""
    echo -e "${BOLD}${CYAN}COMMON COMMANDS:${NC}"
    echo "1) ls -la (List files with details)"
    echo "2) env (Show environment variables)"
    echo "3) ps aux (Show processes)"
    echo "4) cat /etc/os-release (Show OS info)"
    echo "5) df -h (Show disk space)"
    echo "6) netstat -tulpn (Show network connections)"
    echo "7) Custom command"
    echo ""
    read -p "$(echo -e ${YELLOW}"Select command option (default: 1): "${NC})" cmd_option
    
    case $cmd_option in
        2)
            command="env"
            ;;
        3)
            command="ps aux"
            ;;
        4)
            command="cat /etc/os-release"
            ;;
        5)
            command="df -h"
            ;;
        6)
            command="netstat -tulpn"
            ;;
        7)
            echo ""
            read -p "$(echo -e ${YELLOW}"Enter custom command: "${NC})" custom_command
            command=${custom_command:-"ls -la"}
            ;;
        *)
            command="ls -la"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Executing '$command' in container '$container'...${NC}"
    echo -e "${CYAN}----- COMMAND OUTPUT START -----${NC}"
    
    # Execute command in the container
    if ! docker exec "$container" sh -c "$command"; then
        echo -e "${RED}Command failed to execute.${NC}"
        echo -e "${YELLOW}The command or required tools might not be available in the container.${NC}"
    fi
    
    echo -e "${CYAN}----- COMMAND OUTPUT END -----${NC}"
}

# Function to display container dashboard
display_container_dashboard() {
    display_header
    section_title "Container Dashboard"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot display container dashboard.${NC}"
        return
    fi
    
    # Get container stats
    total_containers=$(docker ps -a -q 2>/dev/null | wc -l)
    running_containers=$(docker ps -q 2>/dev/null | wc -l)
    stopped_containers=$((total_containers - running_containers))
    
    # Display summary
    echo -e "${BOLD}${CYAN}DOCKER OVERVIEW:${NC}"
    draw_line 60
    printf "%s %-25s %s %-30s %s\n" "$V_LINE" "Metric" "$V_LINE" "Value" "$V_LINE"
    draw_separator 60
    printf "%s %-25s %s %-30s %s\n" "$V_LINE" "Total Containers" "$V_LINE" "$total_containers" "$V_LINE"
    printf "%s %-25s %s ${GREEN}%-30s${NC} %s\n" "$V_LINE" "Running Containers" "$V_LINE" "$running_containers" "$V_LINE"
    printf "%s %-25s %s ${YELLOW}%-30s${NC} %s\n" "$V_LINE" "Stopped Containers" "$V_LINE" "$stopped_containers" "$V_LINE"
    draw_bottom_line 60
    
    # Display running containers
    echo ""
    echo -e "${BOLD}${CYAN}RUNNING CONTAINERS:${NC}"
    if [ "$running_containers" -gt 0 ]; then
        docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker ps
    else
        echo -e "${YELLOW}No running containers${NC}"
    fi
    
    # Display stopped containers
    echo ""
    echo -e "${BOLD}${CYAN}STOPPED CONTAINERS:${NC}"
    if [ "$stopped_containers" -gt 0 ]; then
        docker ps -f "status=exited" --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null || docker ps -f "status=exited"
    else
        echo -e "${YELLOW}No stopped containers${NC}"
    fi
}

# Function to display image management
display_image_management() {
    display_header
    section_title "Docker Image Management"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot display image management.${NC}"
        return
    fi
    
    # Get image stats
    total_images=$(docker images -q 2>/dev/null | sort -u | wc -l)
    
    # Display summary
    echo -e "${BOLD}${CYAN}IMAGE SUMMARY:${NC}"
    echo "Total Images: $total_images"
    
    # Display all images
    echo ""
    echo -e "${BOLD}${CYAN}ALL IMAGES:${NC}"
    if [ "$total_images" -gt 0 ]; then
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}" 2>/dev/null || docker images
    else
        echo -e "${YELLOW}No images found${NC}"
    fi
    
    # Display dangling images
    dangling_images=$(docker images -f "dangling=true" -q 2>/dev/null | wc -l)
    if [ "$dangling_images" -gt 0 ]; then
        echo ""
        echo -e "${BOLD}${YELLOW}DANGLING IMAGES:${NC}"
        docker images -f "dangling=true" --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" 2>/dev/null || docker images -f "dangling=true"
    fi
}

# Function to display detailed container info
display_detailed_container_info() {
    display_header
    section_title "Detailed Container Information"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot display container information.${NC}"
        return
    fi
    
    # List all containers
    echo -e "${BOLD}${CYAN}ALL CONTAINERS:${NC}"
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null || docker ps -a
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter container ID or name for detailed info (or leave empty to return): "${NC})" container
    
    if [ -z "$container" ]; then
        return
    fi
    
    # Check if container exists
    if ! docker inspect "$container" &>/dev/null; then
        echo -e "${RED}Container '$container' does not exist. Returning to menu.${NC}"
        return
    fi
    
    # Display detailed info
    echo ""
    section_title "Container: $container"
    
    # Basic info
    echo -e "${BOLD}${CYAN}BASIC INFORMATION:${NC}"
    docker inspect --format '
    ID: {{.Id}}
    Name: {{.Name}}
    Image: {{.Config.Image}}
    Created: {{.Created}}
    Status: {{.State.Status}}
    ' "$container" | sed 's/^    //'
    
    # State details
    echo ""
    echo -e "${BOLD}${CYAN}STATE DETAILS:${NC}"
    docker inspect --format '
    Status: {{.State.Status}}
    Running: {{.State.Running}}
    Paused: {{.State.Paused}}
    Restarting: {{.State.Restarting}}
    Pid: {{.State.Pid}}
    ' "$container" | sed 's/^    //'
    
    # Network settings
    echo ""
    echo -e "${BOLD}${CYAN}NETWORK SETTINGS:${NC}"
    docker inspect --format '{{range $net, $conf := .NetworkSettings.Networks}}
    Network: {{$net}}
    IP Address: {{$conf.IPAddress}}
    Gateway: {{$conf.Gateway}}
    {{end}}' "$container" | sed 's/^    //'
    
    # Mount information
    echo ""
    echo -e "${BOLD}${CYAN}VOLUME MOUNTS:${NC}"
    docker inspect --format '{{range .Mounts}}
    Type: {{.Type}}
    Source: {{.Source}}
    Destination: {{.Destination}}
    Mode: {{.Mode}}
    RW: {{.RW}}
    {{end}}' "$container" | sed 's/^    //' || echo "No mounts found"
    
    # Get current resource usage if running
    if docker inspect --format '{{.State.Running}}' "$container" 2>/dev/null | grep -q "true"; then
        echo ""
        echo -e "${BOLD}${CYAN}CURRENT RESOURCE USAGE:${NC}"
        docker stats --no-stream "$container" 2>/dev/null || echo "Could not get resource usage"
    fi
}

# Function to display Docker resource usage
display_docker_resource_usage() {
    display_header
    section_title "Docker Resource Usage"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot display resource usage.${NC}"
        return
    fi
    
    # Display resource usage stats
    echo -e "${BOLD}${CYAN}CONTAINER RESOURCE USAGE:${NC}"
    docker stats --no-stream 2>/dev/null || echo "Could not get resource usage statistics"
}

# Function to display network statistics
display_network_stats() {
    display_header
    section_title "Docker Network Statistics"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot display network statistics.${NC}"
        return
    fi
    
    # List all networks
    echo -e "${BOLD}${CYAN}DOCKER NETWORKS:${NC}"
    docker network ls 2>/dev/null || echo "Could not list networks"
    
    # Display detailed network info for selected network
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter network name for details (or leave empty to skip): "${NC})" network
    
    if [ -n "$network" ]; then
        if docker network inspect "$network" &>/dev/null; then
            echo ""
            echo -e "${BOLD}${CYAN}NETWORK DETAILS FOR $network:${NC}"
            docker network inspect "$network" | grep -A 10 "Name\|Driver\|Subnet\|Gateway\|Container" || echo "Could not get network details"
        else
            echo -e "${RED}Network '$network' not found.${NC}"
        fi
    fi
}

# Function to display volume statistics
display_volume_stats() {
    display_header
    section_title "Docker Volume Management"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot display volume information.${NC}"
        return
    fi
    
    # List all volumes
    echo -e "${BOLD}${CYAN}DOCKER VOLUMES:${NC}"
    docker volume ls 2>/dev/null || echo "Could not list volumes"
    
    # Display detailed volume info for selected volume
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter volume name for details (or leave empty to skip): "${NC})" volume
    
    if [ -n "$volume" ]; then
        if docker volume inspect "$volume" &>/dev/null; then
            echo ""
            echo -e "${BOLD}${CYAN}VOLUME DETAILS FOR $volume:${NC}"
            docker volume inspect "$volume" || echo "Could not get volume details"
        else
            echo -e "${RED}Volume '$volume' not found.${NC}"
        fi
    fi
}

# Function to display Docker system information
display_docker_system_info() {
    display_header
    section_title "Docker System Information"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot display system information.${NC}"
        return
    fi
    
    # Display Docker info
    echo -e "${BOLD}${CYAN}DOCKER INFO:${NC}"
    docker info 2>/dev/null || echo "Could not get Docker information"
    
    # Display Docker disk usage
    echo ""
    echo -e "${BOLD}${CYAN}DOCKER DISK USAGE:${NC}"
    docker system df 2>/dev/null || echo "Could not get Docker disk usage"
    
    # Display Docker version
    echo ""
    echo -e "${BOLD}${CYAN}DOCKER VERSION:${NC}"
    docker version 2>/dev/null || echo "Could not get Docker version"
}

# Function to display Docker events
display_docker_events() {
    display_header
    section_title "Docker Events Monitor"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot display events.${NC}"
        return
    fi
    
    echo -e "${BOLD}${CYAN}DOCKER EVENTS (LAST 1 HOUR):${NC}"
    docker events --since '1h' --until '0s' --format 'TIME: {{.Time}} EVENT: {{.Type}} {{.Action}} {{.Actor.Attributes.name}}' 2>/dev/null || echo "No events found or could not get events"
    
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop monitoring events and return to menu...${NC}"
    echo -e "${BLUE}Displaying live events for 30 seconds:${NC}"
    
    # Monitor events for 30 seconds (can be interrupted with Ctrl+C)
    timeout 30 docker events --format 'TIME: {{.Time}} EVENT: {{.Type}} {{.Action}} {{.Actor.Attributes.name}}' 2>/dev/null || echo "Could not monitor events"
}

# Function for Docker logs viewer
docker_logs_viewer() {
    display_header
    section_title "Docker Logs Viewer"
    
    if ! is_docker_running; then
        echo -e "${RED}Docker is not running. Cannot view logs.${NC}"
        return
    fi
    
    # List all containers
    echo -e "${BOLD}${CYAN}AVAILABLE CONTAINERS:${NC}"
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}" 2>/dev/null || docker ps -a
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Enter container ID or name: "${NC})" container
    
    if [ -z "$container" ]; then
        echo -e "${RED}No container specified. Returning to menu.${NC}"
        return
    fi
    
    # Check if container exists
    if ! docker inspect "$container" &>/dev/null; then
        echo -e "${RED}Container '$container' does not exist. Returning to menu.${NC}"
        return
    fi
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Show last N lines (default: 50): "${NC})" lines
    lines=${lines:-50}
    
    echo ""
    echo -e "${BOLD}${CYAN}LOGS FOR CONTAINER $container (LAST $lines LINES):${NC}"
    docker logs --tail $lines "$container" 2>/dev/null || echo "Could not get logs for container"
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Follow logs? (y/n, default: n): "${NC})" follow
    
    if [[ "$follow" == "y" || "$follow" == "Y" ]]; then
        echo -e "${YELLOW}Press Ctrl+C to stop following logs and return to menu...${NC}"
        echo ""
        docker logs --tail $lines -f "$container" 2>/dev/null || echo "Could not follow logs for container"
    fi
}

# Function to display system resource stats menu
system_stats_menu() {
    while true; do
        display_header
        section_title "System Resource Statistics"
        
        options=(
            "System Overview"
            "CPU Statistics"
            "Memory Statistics"
            "Disk Usage"
            "Network Statistics"
            "Process Monitor"
            "System Load"
            "Back to Main Menu"
        )
        
        for i in "${!options[@]}"; do
            printf " ${CYAN}%2d${NC}) ${GREEN}%s${NC}\n" $((i+1)) "${options[$i]}"
        done
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Select an option: "${NC})" sys_option

        case $sys_option in
            1)
                display_system_overview
                ;;
            2)
                display_cpu_stats
                ;;
            3)
                display_memory_stats
                ;;
            4)
                display_disk_usage
                ;;
            5)
                display_network_stats_system
                ;;
            6)
                display_process_monitor
                ;;
            7)
                display_system_load
                ;;
            8)
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Press Enter to continue..."${NC})"
    done
}

# Function to display system overview
display_system_overview() {
    display_header
    section_title "System Overview"
    
    # Get system info
    hostname=$(hostname)
    os_info=$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown OS")
    kernel=$(uname -r)
    uptime=$(uptime -p 2>/dev/null || uptime)
    
    # CPU info
    cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//' || echo "Unknown CPU")
    cpu_cores=$(grep -c "processor" /proc/cpuinfo 2>/dev/null || echo "Unknown")
    
    # Display system info
    echo -e "${BOLD}${CYAN}SYSTEM INFORMATION:${NC}"
    draw_line 60
    printf "%s %-25s %s %-30s %s\n" "$V_LINE" "Hostname" "$V_LINE" "$hostname" "$V_LINE"
    printf "%s %-25s %s %-30s %s\n" "$V_LINE" "Operating System" "$V_LINE" "$os_info" "$V_LINE"
    printf "%s %-25s %s %-30s %s\n" "$V_LINE" "Kernel" "$V_LINE" "$kernel" "$V_LINE"
    printf "%s %-25s %s %-30s %s\n" "$V_LINE" "Uptime" "$V_LINE" "$uptime" "$V_LINE"
    draw_bottom_line 60
    
    # Display hardware info
    echo ""
    echo -e "${BOLD}${CYAN}HARDWARE INFORMATION:${NC}"
    draw_line 60
    printf "%s %-25s %s %-30s %s\n" "$V_LINE" "CPU Model" "$V_LINE" "$cpu_model" "$V_LINE"
    printf "%s %-25s %s %-30s %s\n" "$V_LINE" "CPU Cores" "$V_LINE" "$cpu_cores" "$V_LINE"
    draw_bottom_line 60
    
    # Check if we can display memory info
    if command_exists "free"; then
        echo ""
        echo -e "${BOLD}${CYAN}MEMORY INFORMATION:${NC}"
        free -h
    fi
    
    # Check if we can display disk info
    if command_exists "df"; then
        echo ""
        echo -e "${BOLD}${CYAN}DISK INFORMATION:${NC}"
        df -h | grep -vE '^tmpfs|^devtmpfs|^udev' | grep -v '/snap/'
    fi
}

# Function to display CPU statistics
display_cpu_stats() {
    display_header
    section_title "CPU Statistics"
    
    # Check if we have the required tools
    if command_exists "lscpu"; then
        echo -e "${BOLD}${CYAN}CPU INFORMATION:${NC}"
        lscpu | grep -E 'Model name|Socket|Core|Thread|CPU MHz|CPU max MHz|CPU min MHz|Flags|Virtualization'
    else
        echo -e "${BOLD}${CYAN}CPU INFORMATION:${NC}"
        grep -E 'model name|cpu MHz|siblings|cpu cores' /proc/cpuinfo 2>/dev/null | head -5 || echo "CPU information not available"
    fi
    
    # Display CPU load
    echo ""
    echo -e "${BOLD}${CYAN}CPU LOAD:${NC}"
    if command_exists "top"; then
        top -bn1 | head -n 5
    else
        echo "CPU load information not available"
    fi
    
    # Display running processes using CPU
    if command_exists "ps"; then
        echo ""
        echo -e "${BOLD}${CYAN}TOP CPU PROCESSES:${NC}"
        ps aux --sort=-%cpu | head -11
    fi
}

# Function to display memory statistics
display_memory_stats() {
    display_header
    section_title "Memory Statistics"
    
    # Display memory usage
    if command_exists "free"; then
        echo -e "${BOLD}${CYAN}MEMORY USAGE:${NC}"
        free -h
        
        # Calculate usage percentages
        echo ""
        echo -e "${BOLD}${CYAN}MEMORY USAGE PERCENTAGE:${NC}"
        mem_total=$(free | grep Mem | awk '{print $2}')
        mem_used=$(free | grep Mem | awk '{print $3}')
        mem_used_percent=$((mem_used * 100 / mem_total))
        
        echo -n "Memory Usage: "
        progress_bar $mem_used_percent
        
        # Calculate swap usage if available
        swap_total=$(free | grep Swap | awk '{print $2}')
        if [ "$swap_total" -gt 0 ]; then
            swap_used=$(free | grep Swap | awk '{print $3}')
            swap_used_percent=$((swap_used * 100 / swap_total))
            
            echo -n "Swap Usage: "
            progress_bar $swap_used_percent
        fi
    else
        echo -e "${YELLOW}Memory information not available ('free' command not found)${NC}"
    fi
    
    # Display processes using memory
    if command_exists "ps"; then
        echo ""
        echo -e "${BOLD}${CYAN}TOP MEMORY PROCESSES:${NC}"
        ps aux --sort=-%mem | head -11
    fi
}

# Function to display disk usage
display_disk_usage() {
    display_header
    section_title "Disk Usage"
    
    # Display disk usage
    if command_exists "df"; then
        echo -e "${BOLD}${CYAN}FILESYSTEM USAGE:${NC}"
        df -h | grep -vE '^tmpfs|^devtmpfs|^udev' | grep -v '/snap/' | column -t
        
        # Display disk usage percentages
        echo ""
        echo -e "${BOLD}${CYAN}DISK USAGE PERCENTAGES:${NC}"
        
        df -h | grep -vE '^tmpfs|^devtmpfs|^udev|^Filesystem' | grep -v '/snap/' | while read line; do
            fs=$(echo $line | awk '{print $1}')
            mount=$(echo $line | awk '{print $6}')
            used_percent=$(echo $line | awk '{print $5}' | sed 's/%//')
            
            echo -e "${CYAN}$fs${NC} ($mount): "
            progress_bar $used_percent
        done
    else
        echo -e "${YELLOW}Disk usage information not available ('df' command not found)${NC}"
    fi
    
    # Display largest directories
    if command_exists "du"; then
        echo ""
        read -p "$(echo -e ${YELLOW}"Display largest directories in /? (y/n, default: n): "${NC})" show_dirs
        
        if [[ "$show_dirs" == "y" || "$show_dirs" == "Y" ]]; then
            echo ""
            echo -e "${BOLD}${CYAN}LARGEST DIRECTORIES IN /:${NC}"
            echo -e "${YELLOW}This may take a while...${NC}"
            du -h --max-depth=2 / 2>/dev/null | sort -hr | head -10
        fi
    fi
}

# Function to display network statistics for the system
display_network_stats_system() {
    display_header
    section_title "Network Statistics"
    
    # Display interfaces
    if command_exists "ip"; then
        echo -e "${BOLD}${CYAN}NETWORK INTERFACES:${NC}"
        ip -c a | grep -E 'inet|^[0-9]' || echo "Could not get network interface information"
    elif command_exists "ifconfig"; then
        echo -e "${BOLD}${CYAN}NETWORK INTERFACES:${NC}"
        ifconfig | grep -E 'inet|^[a-zA-Z0-9]' || echo "Could not get network interface information"
    else
        echo -e "${YELLOW}Network interface information not available${NC}"
    fi
    
    # Display network connections
    if command_exists "netstat"; then
        echo ""
        echo -e "${BOLD}${CYAN}ACTIVE CONNECTIONS:${NC}"
        netstat -tulpn 2>/dev/null | head -30 || echo "Could not get active connections"
    elif command_exists "ss"; then
        echo ""
        echo -e "${BOLD}${CYAN}ACTIVE CONNECTIONS:${NC}"
        ss -tulpn | head -30 || echo "Could not get active connections"
    else
        echo -e "${YELLOW}Active connections information not available${NC}"
    fi
}

# Function to display process monitor
display_process_monitor() {
    display_header
    section_title "Process Monitor"
    
    if command_exists "ps"; then
        echo -e "${BOLD}${CYAN}TOP CPU PROCESSES:${NC}"
        ps aux --sort=-%cpu | head -11
        
        echo ""
        echo -e "${BOLD}${CYAN}TOP MEMORY PROCESSES:${NC}"
        ps aux --sort=-%mem | head -11
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Enter process name or ID to search (or leave empty to return): "${NC})" process
        
        if [ -n "$process" ]; then
            echo ""
            echo -e "${BOLD}${CYAN}PROCESSES MATCHING '$process':${NC}"
            ps aux | grep -i "$process" | grep -v grep
        fi
    else
        echo -e "${YELLOW}Process information not available ('ps' command not found)${NC}"
    fi
}

# Function to display system load
display_system_load() {
    display_header
    section_title "System Load"
    
    # Display load average
    if [ -f "/proc/loadavg" ]; then
        echo -e "${BOLD}${CYAN}LOAD AVERAGE:${NC}"
        load_avg=$(cat /proc/loadavg)
        echo "Load Average (1min, 5min, 15min): $load_avg"
        
        # Extract load values
        load_1=$(echo $load_avg | awk '{print $1}')
        load_5=$(echo $load_avg | awk '{print $2}')
        load_15=$(echo $load_avg | awk '{print $3}')
        
        # Get number of cores
        cores=$(grep -c "processor" /proc/cpuinfo 2>/dev/null || echo 1)
        
        # Calculate load percentage per core
        load_1_percent=$(echo "$load_1 * 100 / $cores" | bc -l 2>/dev/null || echo 0)
        load_5_percent=$(echo "$load_5 * 100 / $cores" | bc -l 2>/dev/null || echo 0)
        load_15_percent=$(echo "$load_15 * 100 / $cores" | bc -l 2>/dev/null || echo 0)
        
        # Format to integers for progress bar
        load_1_int=$(printf "%.0f" $load_1_percent 2>/dev/null || echo 0)
        load_5_int=$(printf "%.0f" $load_5_percent 2>/dev/null || echo 0)
        load_15_int=$(printf "%.0f" $load_15_percent 2>/dev/null || echo 0)
        
        # Cap at 100% for progress bar
        [ $load_1_int -gt 100 ] && load_1_int=100
        [ $load_5_int -gt 100 ] && load_5_int=100
        [ $load_15_int -gt 100 ] && load_15_int=100
        
        echo ""
        echo -e "${BOLD}${CYAN}LOAD PER CORE:${NC}"
        echo -n "1 minute: "
        progress_bar $load_1_int
        
        echo -n "5 minutes: "
        progress_bar $load_5_int
        
        echo -n "15 minutes: "
        progress_bar $load_15_int
    else
        echo -e "${YELLOW}Load average information not available${NC}"
    fi
    
    # Display uptime
    echo ""
    echo -e "${BOLD}${CYAN}UPTIME:${NC}"
    uptime
    
    # Display top output
    if command_exists "top"; then
        echo ""
        echo -e "${BOLD}${CYAN}CURRENT SYSTEM STATUS:${NC}"
        top -bn1 | head -15
    fi
}

# Function to calculate percentage
calculate_percentage() {
    local value=$1
    local total=$2
    
    if [ "$total" -eq 0 ]; then
        echo 0
    else
        echo $((value * 100 / total))
    fi
}

# Function to export statistics to file
export_stats() {
    display_header
    section_title "Export Statistics to File"
    
    export_options=(
        "Export Kubernetes Stats"
        "Export Docker Stats"
        "Export System Stats"
        "Export All Stats"
        "Back to Main Menu"
    )
    
    for i in "${!export_options[@]}"; do
        printf " ${CYAN}%2d${NC}) ${GREEN}%s${NC}\n" $((i+1)) "${export_options[$i]}"
    done
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Select an option: "${NC})" export_option
    
    # Create directory for exports if it doesn't exist
    mkdir -p ./stats_exports
    timestamp=$(date +"%Y%m%d_%H%M%S")
    
    case $export_option in
        1)
            if is_kube_running; then
                export_file="./stats_exports/kubernetes_stats_${timestamp}.txt"
                echo -e "${BLUE}Exporting Kubernetes Stats to ${export_file}...${NC}"
                
                {
                    echo "===== KUBERNETES STATISTICS EXPORT ====="
                    echo "Date: $(date)"
                    echo "User: $(whoami)"
                    echo "Hostname: $(hostname)"
                    echo "====================================="
                    echo ""
                    
                    echo "===== KUBERNETES VERSION ====="
                    kubectl version
                    echo ""
                    
                    echo "===== NODES ====="
                    kubectl get nodes -o wide
                    echo ""
                    
                    echo "===== NAMESPACES ====="
                    kubectl get namespaces
                    echo ""
                    
                    echo "===== PODS (ALL NAMESPACES) ====="
                    kubectl get pods --all-namespaces
                    echo ""
                    
                    echo "===== DEPLOYMENTS (ALL NAMESPACES) ====="
                    kubectl get deployments --all-namespaces
                    echo ""
                    
                    echo "===== SERVICES (ALL NAMESPACES) ====="
                    kubectl get services --all-namespaces
                    echo ""
                    
                } > "$export_file"
                
                echo -e "${GREEN}Export completed successfully!${NC}"
                echo -e "File saved to: ${CYAN}$export_file${NC}"
            else
                echo -e "${RED}Kubernetes is not running. Cannot export stats.${NC}"
            fi
            ;;
        2)
            if is_docker_running; then
                export_file="./stats_exports/docker_stats_${timestamp}.txt"
                echo -e "${BLUE}Exporting Docker Stats to ${export_file}...${NC}"
                
                {
                    echo "===== DOCKER STATISTICS EXPORT ====="
                    echo "Date: $(date)"
                    echo "User: $(whoami)"
                    echo "Hostname: $(hostname)"
                    echo "====================================="
                    echo ""
                    
                    echo "===== DOCKER VERSION ====="
                    docker version
                    echo ""
                    
                    echo "===== DOCKER INFO ====="
                    docker info
                    echo ""
                    
                    echo "===== CONTAINERS (ALL) ====="
                    docker ps -a
                    echo ""
                    
                    echo "===== IMAGES ====="
                    docker images
                    echo ""
                    
                    echo "===== NETWORKS ====="
                    docker network ls
                    echo ""
                    
                    echo "===== VOLUMES ====="
                    docker volume ls
                    echo ""
                    
                } > "$export_file"
                
                echo -e "${GREEN}Export completed successfully!${NC}"
                echo -e "File saved to: ${CYAN}$export_file${NC}"
            else
                echo -e "${RED}Docker is not running. Cannot export stats.${NC}"
            fi
            ;;
        3)
            export_file="./stats_exports/system_stats_${timestamp}.txt"
            echo -e "${BLUE}Exporting System Stats to ${export_file}...${NC}"
            
            {
                echo "===== SYSTEM STATISTICS EXPORT ====="
                echo "Date: $(date)"
                echo "User: $(whoami)"
                echo "Hostname: $(hostname)"
                echo "====================================="
                echo ""
                
                echo "===== SYSTEM INFO ====="
                echo "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown OS")"
                echo "Kernel: $(uname -a)"
                echo "Uptime: $(uptime)"
                echo ""
                
                echo "===== CPU INFO ====="
                if command_exists "lscpu"; then
                    lscpu
                else
                    grep -E 'model name|cpu MHz|siblings|cpu cores' /proc/cpuinfo 2>/dev/null | head -5 || echo "CPU information not available"
                fi
                echo ""
                
                echo "===== MEMORY INFO ====="
                if command_exists "free"; then
                    free -h
                else
                    echo "Memory information not available"
                fi
                echo ""
                
                echo "===== DISK USAGE ====="
                if command_exists "df"; then
                    df -h
                else
                    echo "Disk usage information not available"
                fi
                echo ""
                
                echo "===== TOP PROCESSES (CPU) ====="
                if command_exists "ps"; then
                    ps aux --sort=-%cpu | head -11
                else
                    echo "Process information not available"
                fi
                echo ""
                
            } > "$export_file"
            
            echo -e "${GREEN}Export completed successfully!${NC}"
            echo -e "File saved to: ${CYAN}$export_file${NC}"
            ;;
        4)
            all_export_file="./stats_exports/all_stats_${timestamp}.txt"
            echo -e "${BLUE}Exporting All Stats to ${all_export_file}...${NC}"
            
            {
                echo "=============================================="
                echo "===== COMPLETE SYSTEM MONITORING EXPORT ====="
                echo "=============================================="
                echo "Date: $(date)"
                echo "User: $(whoami)"
                echo "Hostname: $(hostname)"
                echo "=============================================="
                echo ""
                
                echo "=============================================="
                echo "===== SYSTEM INFORMATION ====="
                echo "=============================================="
                echo "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown OS")"
                echo "Kernel: $(uname -a)"
                echo "Uptime: $(uptime)"
                echo ""
                
                echo "===== CPU INFO ====="
                if command_exists "lscpu"; then
                    lscpu
                else
                    grep -E 'model name|cpu MHz|siblings|cpu cores' /proc/cpuinfo 2>/dev/null | head -5 || echo "CPU information not available"
                fi
                echo ""
                
                echo "===== MEMORY INFO ====="
                if command_exists "free"; then
                    free -h
                else
                    echo "Memory information not available"
                fi
                echo ""
                
                echo "===== DISK USAGE ====="
                if command_exists "df"; then
                    df -h
                else
                    echo "Disk usage information not available"
                fi
                echo ""
                
                echo "=============================================="
                echo "===== DOCKER INFORMATION ====="
                echo "=============================================="
                if is_docker_running; then
                    echo "===== DOCKER VERSION ====="
                    docker version
                    echo ""
                    
                    echo "===== DOCKER INFO ====="
                    docker info
                    echo ""
                    
                    echo "===== CONTAINERS (ALL) ====="
                    docker ps -a
                    echo ""
                    
                    echo "===== IMAGES ====="
                    docker images
                    echo ""
                else
                    echo "Docker is not running. Cannot export Docker stats."
                fi
                echo ""
                
                echo "=============================================="
                echo "===== KUBERNETES INFORMATION ====="
                echo "=============================================="
                if is_kube_running; then
                    echo "===== KUBERNETES VERSION ====="
                    kubectl version
                    echo ""
                    
                    echo "===== NODES ====="
                    kubectl get nodes -o wide
                    echo ""
                    
                    echo "===== NAMESPACES ====="
                    kubectl get namespaces
                    echo ""
                    
                    echo "===== PODS (ALL NAMESPACES) ====="
                    kubectl get pods --all-namespaces
                    echo ""
                else
                    echo "Kubernetes is not running. Cannot export Kubernetes stats."
                fi
                
            } > "$all_export_file"
            
            echo -e "${GREEN}Export completed successfully!${NC}"
            echo -e "File saved to: ${CYAN}$all_export_file${NC}"
            ;;
        5)
            return
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            export_stats
            ;;
    esac
    
    echo ""
    read -p "$(echo -e ${YELLOW}"Press Enter to continue..."${NC})"
}

# Function to show help information
show_help() {
    display_header
    section_title "Help Information"
    
    draw_line 70
    printf "%s %-68s %s\n" "$V_LINE" "$(center_text "Kubernetes & Docker Monitoring Tool" 68)" "$V_LINE"
    draw_bottom_line 70
    
    echo ""
    echo -e "${BOLD}${CYAN}ABOUT THIS TOOL:${NC}"
    echo "This monitoring tool provides statistics and management capabilities"
    echo "for Kubernetes clusters, Docker environments, and system resources."
    echo ""
    
    echo -e "${BOLD}${CYAN}MAIN FEATURES:${NC}"
    echo "1. ${GREEN}Kubernetes Monitoring${NC}"
    echo "   - Cluster overview and health dashboard"
    echo "   - Pod, deployment, service, and namespace management"
    echo "   - Resource usage tracking and logs viewing"
    echo "   - Container shell access and command execution"
    echo ""
    echo "2. ${GREEN}Docker Monitoring${NC}"
    echo "   - Container and image management"
    echo "   - Resource usage and performance metrics"
    echo "   - Network, volume, and system information"
    echo "   - Container shell access and command execution"
    echo ""
    echo "3. ${GREEN}System Resource Monitoring${NC}"
    echo "   - CPU, memory, and disk usage statistics"
    echo "   - Network interface and connection monitoring"
    echo "   - Process tracking and system load analysis"
    echo ""
    echo "4. ${GREEN}Export Capabilities${NC}"
    echo "   - Export statistics to text files for offline analysis"
    echo ""
    
    echo -e "${BOLD}${CYAN}REQUIREMENTS:${NC}"
    echo "- Kubernetes monitoring requires kubectl to be installed and configured"
    echo "- Docker monitoring requires Docker to be installed and running"
    echo "- System monitoring uses standard Linux utilities"
    echo ""
    
    echo -e "${BOLD}${CYAN}NAVIGATION TIPS:${NC}"
    echo "- Use the number keys to select options from menus"
    echo "- Press Enter to confirm selections"
    echo "- Most screens have a 'Back to Previous Menu' option"
    echo "- Press Ctrl+C at any time to exit the application"
    echo ""
    
    echo -e "${BOLD}${CYAN}VERSION INFORMATION:${NC}"
    echo "Version: 1.0.0"
    echo "Author: Juni-crypto"
    echo "GitHub: https://github.com/Juni-crypto"
    echo "Organization: ChumaoruWorks Club"
    echo "Last Updated: 2025-05-04"
    echo ""
    
    read -p "$(echo -e ${YELLOW}"Press Enter to return to the main menu..."${NC})"
}

# Main Menu
main_menu() {
    while true; do
        display_header
        section_title "Main Menu"
        
        # Initialize an empty array for options
        options=()
        
        # Dynamically render options based on services running
        if is_kube_running; then
            options+=("Kubernetes Statistics")
            kube_index=${#options[@]}
        fi
        
        if is_docker_running; then
            options+=("Docker Statistics")
            docker_index=${#options[@]}
        fi
        
        # Add fixed options
        options+=("System Resource Statistics")
        system_index=${#options[@]}
        
        options+=("Export Statistics to File")
        export_index=${#options[@]}
        
        options+=("Help")
        help_index=${#options[@]}
        
        options+=("Exit")
        exit_index=${#options[@]}
        
        # Display options with appropriate styling
        for i in "${!options[@]}"; do
            if [[ $((i+1)) -eq $exit_index ]]; then
                printf " ${RED}%2d${NC}) ${RED}%s${NC}\n" $((i+1)) "${options[$i]}"
            else
                printf " ${CYAN}%2d${NC}) ${GREEN}%s${NC}\n" $((i+1)) "${options[$i]}"
            fi
        done
        
        echo ""
        read -p "$(echo -e ${YELLOW}"Select an option: "${NC})" main_option
        
        if [[ -n "$kube_index" ]] && [[ $main_option -eq $kube_index ]]; then
            kube_stats_menu
        elif [[ -n "$docker_index" ]] && [[ $main_option -eq $docker_index ]]; then
            docker_stats_menu
        elif [[ $main_option -eq $system_index ]]; then
            system_stats_menu
        elif [[ $main_option -eq $export_index ]]; then
            export_stats
        elif [[ $main_option -eq $help_index ]]; then
            show_help
        elif [[ $main_option -eq $exit_index ]]; then
            echo -e "${BLUE}Exiting...${NC}"
            exit 0
        else
            echo -e "${RED}Invalid option. Please try again.${NC}"
            sleep 2
        fi
    done
}

# Start the script
main_menu