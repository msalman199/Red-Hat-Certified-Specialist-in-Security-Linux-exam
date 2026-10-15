#!/bin/bash

echo "=== TLS Log Analysis ==="
echo

# Apache logs
apache_error_logs=(
    "/var/log/httpd/ssl_error_log"
    "/var/log/apache2/ssl_error.log"
    "/var/log/httpd/error_log"
    "/var/log/apache2/error.log"
)

echo "1. Apache SSL Error Logs (last 10 entries):"
for log in "${apache_error_logs[@]}"; do
    if [ -f "$log" ]; then
        echo "  From $log:"
        sudo tail -10 "$log" 2>/dev/null | sed 's/^/    /' || echo "    No recent entries"
        echo
    fi
done

# NGINX logs
nginx_error_logs=(
    "/var/log/nginx/ssl_error.log"
    "/var/log/nginx/error.log"
)

echo "2. NGINX SSL Error Logs (last 10 entries):"
for log in "${nginx_error_logs[@]}"; do
    if [ -f "$log" ]; then
        echo "  From $log:"
        sudo tail -10 "$log" 2>/dev/null | sed 's/^/    /' || echo "    No recent entries"
        echo
    fi
done

# System logs
echo "3. System Logs (SSL/TLS related, last 10 entries):"
sudo journalctl -u httpd -u apache2 -u nginx --no-pager -n 10 | grep -i ssl || echo "  No SSL-related entries found"

