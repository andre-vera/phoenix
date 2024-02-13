#!/bin/bash

# Check if a URL was providen
if [ -z "$1" ]; then
    echo "Use: $0 <URL>"
    exit 1
fi

# Solve IPv4 Address
ipv4=$(dig +short $1 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)

if [ -z "$ipv4" ]; then
    echo "It's not possible to solve IPv4 Address for $1"
    exit 1
else
    echo $ipv4
fi
