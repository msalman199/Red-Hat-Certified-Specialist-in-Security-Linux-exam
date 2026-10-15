#!/bin/bash

echo "=== TLS Troubleshooting Toolkit ==="
echo

# Check if services are running
echo "1. Service Status Check:"
services=("httpd" "apache2" "nginx")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        echo "  ✓ $service is running"
        echo "    Listening ports:"
        sudo netstat -tlnp | grep $(systemctl show -p MainPID --value $service) 2>/dev/null | sed 's/^/      /'
    else
        echo "  ✗ $service is not running"
    fi
done

echo
echo "2. Port Availability Check:"
ports=(80 443 8080 8443)
for port in "${ports[@]}"; do
    if netstat -tln | grep -q ":$port "; then
        echo "  ✓ Port $port is in use"
        netstat -tlnp | grep ":$port " | sed 's/^/    /'
    else
        echo "  ✗ Port $port is not in use"
    fi
done

echo
echo "3. Certificate File Check:"
cert_files=(
    "/etc/ssl/certs/apache-selfsigned.crt"
    "/etc/ssl/private/apache-selfsigned.key"
    "/etc/ssl/certs/nginx-selfsigned.crt"
    "/etc/ssl/private/nginx-selfsigned.key"
)

for file in "${cert_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file exists"
        echo "    Permissions: $(ls -l "$file" | awk '{print $1, $3, $4}')"
        if [[ "$file" == *.crt ]]; then
            echo "    Expires: $(openssl x509 -in "$file" -noout -enddate 2>/dev/null | cut -d= -f2)"
        fi
    else
        echo "  ✗ $file does not exist"
    fi
done

echo
echo "4. Firewall Status:"
if command -v firewall-cmd &> /dev/null; then
    echo "  Firewall service: $(systemctl is-active firewalld)"
    if systemctl is-active --quiet firewalld; then
        echo "  Open ports:"
        sudo firewall-cmd --list-ports | sed 's/^/    /'
        echo "  Open services:"
        sudo firewall-cmd --list-services | sed 's/^/    /'
    fi
elif command -v ufw &> /dev/null; then
    echo "  UFW status: $(sudo ufw status | head -1)"
fi

echo
echo "5. Configuration File Syntax Check:"
# Check Apache configuration
if command -v httpd &> /dev/null; then
    echo -n "  Apache config: "
    if sudo httpd -t &>/dev/null; then
        echo "✓ Valid"
    else
        echo "✗ Invalid"
        sudo httpd -t 2>&1 | sed 's/^/    /'
    fi
elif command -v apache2ctl &> /dev/null; then
    echo -n "  Apache config: "
    if sudo apache2ctl configtest &>/dev/null; then
        echo "✓ Valid"
    else
        echo "✗ Invalid"
        sudo apache2ctl configtest 2>&1 | sed 's/^/    /'
    fi
fi

# Check NGINX configuration
if command -v nginx &> /dev/null; then
    echo -n "  NGINX config: "
    if sudo nginx -t &>/dev/null; then
        echo "✓ Valid"
    else
        echo "✗ Invalid"
        sudo nginx -t 2>&1 | sed 's/^/    /'
    fi
fi

