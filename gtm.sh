#!/bin/bash

# Your DNSTT Nameservers & Domain `A` Records
NS='sdns.art1.bagito.tech'
A='art1.bagito.tech'
NS1='sdns.jkim.bagito.tech'
A1='jkim.bagito.tech'

# Repeat dig cmd loop time (seconds) (positive integer only)
LOOP_DELAY=5

# Add your DNS server IP addresses here
declare -a HOSTS=('112.198.115.44' '124.6.181.20' '124.6.181.36' '112.198.115.36')

# Linux' dig command executable filepath
# Select value: "CUSTOM|C" or "DEFAULT|D"
DIG_EXEC="DEFAULT"

# If set to CUSTOM, enter your custom dig executable path here
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig

# Function to set the DNS environment variables
set_dns() {
    export RESOLV_CONF_BACKUP="$HOME/resolv.conf.bak"
    cp /etc/resolv.conf "$RESOLV_CONF_BACKUP"
    echo "nameserver $1" | sudo tee /etc/resolv.conf
}

# Function to restore the original DNS settings
restore_dns() {
    sudo cp "$RESOLV_CONF_BACKUP" /etc/resolv.conf
    unset RESOLV_CONF_BACKUP
}

# Function to perform the DNS queries and display results
check_dns() {
    local result
    for host in "${HOSTS[@]}"; do
        for record in "$NS" "$A" "$NS1" "$A1"; do
            result=$(_DIG +short +time=3 +tries=1 "@$host" "$record")
            if [ -n "$result" ]; then
                echo -e "\e[1;32m\$ R: $record D: $host\e[0m"
            else
                echo -e "\e[1;31m\$ R: $record D: $host\e[0m"
            fi
        done
    done
}

# Function to execute DNS queries repeatedly
loop_dns_check() {
    echo "Script loop: $LOOP_DELAY seconds"
    while true; do
        check_dns
        echo '.--. .-.. . .- ... .     .-- .- .. -'
        sleep "$LOOP_DELAY"
    done
}

# Main script
echo "DNSTT Keep-Alive script <Discord @civ3>"
echo "DNS List:"

for host in "${HOSTS[@]}"; do
    echo -e "\e[1;34m$NS => $host\e[0m"
    echo -e "\e[1;34m$A => $host\e[0m"
    echo -e "\e[1;34m$NS1 => $host\e[0m"
    echo -e "\e[1;34m$A1 => $host\e[0m"
done

echo "CTRL + C to close script"

# Check the dig command availability
case "${DIG_EXEC}" in
    DEFAULT|D)
        _DIG="$(command -v dig)"
        ;;
    CUSTOM|C)
        _DIG="${CUSTOM_DIG}"
        ;;
esac

if [ -z "$_DIG" ]; then
    echo "Dig command failed to run. Please install dig (dnsutils) or check DIG_EXEC & CUSTOM_DIG variables."
    exit 1
fi

# Set the DNS to the first DNS server in the HOSTS array
set_dns "${HOSTS[0]}"

# Trap to restore original DNS settings upon script termination
trap 'restore_dns' EXIT

# Check if the script should run in a loop or a single check
if [ "$1" = "loop" ] || [ "$1" = "l" ]; then
    loop_dns_check
else
    check_dns
fi

exit 0

