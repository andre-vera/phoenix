#!/bin/bash

# Check if a URL was providen
if [ -z "$1" ]; then
    echo "Uso: $0 <URL>"
    exit 1
fi

# Resolve o endereço IPv4
ipv4=$(dig +short $1 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)

if [ -z "$ipv4" ]; then
    echo "Não foi possível resolver o endereço IPv4 para $1"
    exit 1
else
    echo $ipv4
fi
