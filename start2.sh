#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Node.js exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists node; then
    echo "Error: Node.js is not installed"
    exit 1
fi

# Function to start and store PID
start_process() {
    local name=$1
    local command=$2
    echo -e "${BLUE}Starting $name...${NC}"
    $command &
    local pid=$!
    echo $pid > ".$name.pid"
    echo -e "${GREEN}$name started with PID: $pid${NC}"
}

# Clean up existing processes
echo "Cleaning up any existing secondary processes..."
for pid_file in .*.pid; do
    if [[ "$pid_file" == .secondary-* ]]; then
        pid=$(cat "$pid_file")
        kill $pid 2>/dev/null || true
        rm "$pid_file"
    fi
done

# Start the secondary app (change port here if needed)
start_process "secondary-main" "npx nx serve main --port=4300"

echo -e "\n${GREEN}Secondary application started!${NC}"
echo -e "Secondary app: ${BLUE}http://localhost:4300${NC}"

# Handle termination
cleanup() {
    echo -e "\n${BLUE}Stopping secondary applications...${NC}"
    for pid_file in .*.pid; do
        if [[ "$pid_file" == .secondary-* ]]; then
            pid=$(cat "$pid_file")
            kill $pid 2>/dev/null || true
            rm "$pid_file"
        fi
    done
    echo -e "${GREEN}Secondary applications stopped${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

echo -e "\n${BLUE}Press Ctrl+C to stop secondary app${NC}"
while true; do
    sleep 1
done
