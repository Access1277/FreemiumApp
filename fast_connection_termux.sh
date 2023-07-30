#!/bin/bash

# Array to store the list of IP addresses or hosts
HOSTS=('178.128.211.108' '159.223.61.171')

# Function to test the connection and find the fastest IP address
find_fastest_connection() {
    local fastest_host=""
    local fastest_response_time=999999

    for host in "${HOSTS[@]}"; do
        local response_time=$(ping -c 5 -i 0.2 -q "$host" | grep -oP '(?<=time=)\d+\.\d+')
        echo "Response time to $host: ${response_time} ms"

        if (( $(bc <<< "$response_time < $fastest_response_time") )); then
            fastest_host="$host"
            fastest_response_time="$response_time"
        fi
    done

    echo "Fastest host: $fastest_host with response time $fastest_response_time ms"
}

find_fastest_connection
