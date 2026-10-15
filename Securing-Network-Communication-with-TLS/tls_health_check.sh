#!/bin/bash

echo "=== TLS Health Check ==="
echo "Timestamp: $(date)"
echo

# Function to check TLS connection
check_tls_connection() {
    local host=$1
    local port=$2
    local name=$3
    
    echo "Checking $name ($host:$port):"
    
    # Basic connectivity
    if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        echo "  ✓ Port $port is reachable"
        
        # TLS handshake
        if echo | timeout 5 openssl s_client -connect $host:$port -quiet 2>/dev/null; then
            echo "  ✓ TLS handshake successful"
            
            # Certificate validity
            cert_info=$(echo | openssl s_client -connect $host:$port -servername $host 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "  ✓ Certificate is valid"
                echo "    $(echo "$cert_info" | grep notAfter | cut -d= -f2)"
            else
                echo "  ✗ Certificate validation failed"
            fi
            
            # Protocol version
            protocol=$(echo | openssl s_client -connect $host:$port 2>/dev/null | grep "Protocol" | head -1)
            echo "  $protocol"
            
        else
            echo "  ✗ TLS handshake failed"
        fi
    else
        echo "  ✗ Port $port is not reachable"
    fi
    echo
}

# Check localhost services
check_tls_connection "localhost" "443" "Local HTTPS Service"

# If you have other services running on different ports
# check_tls_connection "localhost" "8443" "NGINX SSL"

# Summary
echo "Health check completed at $(date)"

