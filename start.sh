#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if required commands exist
if ! command_exists node; then
    echo "Error: Node.js is not installed"
    exit 1
fi

if ! command_exists python3; then
    echo "Error: Python 3 is not installed"
    exit 1
fi

# Function to start a process and store its PID
start_process() {
    local name=$1
    local command=$2
    echo -e "${BLUE}Starting $name...${NC}"
    $command &
    local pid=$!
    echo $pid > ".$name.pid"
    echo -e "${GREEN}$name started with PID: $pid${NC}"
}

# Kill any existing processes
echo "Cleaning up any existing processes..."
for pid_file in .*.pid; do
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        kill $pid 2>/dev/null || true
        rm "$pid_file"
    fi
done

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Start the main app
start_process "main" "npx nx serve main-frontend-app"

# Wait a bit to let the server start (optional but recommended)
sleep 5

# Open browser at /sign-in
xdg-open "http://localhost:4200/sign-in" >/dev/null 2>&1 &

echo -e "\n${GREEN}Main application started!${NC}"
echo -e "Main app: ${BLUE}http://localhost:4200/sign-in${NC}"

echo -e "\n${GREEN}Main application started!${NC}"
echo -e "Main app: ${BLUE}http://localhost:4200${NC}"

# Function to handle script termination
cleanup() {
    echo -e "\n${BLUE}Stopping all applications...${NC}"
    for pid_file in .*.pid; do
        if [ -f "$pid_file" ]; then
            pid=$(cat "$pid_file")
            kill $pid 2>/dev/null || true
            rm "$pid_file"
        fi
    done
    echo -e "${GREEN}All applications stopped${NC}"
    exit 0
}

# Register the cleanup function for script termination
trap cleanup SIGINT SIGTERM

# Keep the script running
echo -e "\n${BLUE}Press Ctrl+C to stop all applications${NC}"
while true; do
    sleep 1
done 