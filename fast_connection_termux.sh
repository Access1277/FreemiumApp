#!/data/data/com.termux/files/usr/bin/bash

# Check if the script is invoked with the correct arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <HOST_OR_IP>"
    exit 1
fi

HOST_OR_IP="178.128.211.108"

# Function to test the connection
test_connection() {
    local response_time=$(ping -c 5 -i 0.2 -q "$HOST_OR_IP" | grep -oP '(?<=time=)\d+\.\d+')
    echo "Average response time to $HOST_OR_IP: ${response_time} ms"
}

# Run the test_connection function repeatedly
while true; do
    test_connection
    sleep 5
done

