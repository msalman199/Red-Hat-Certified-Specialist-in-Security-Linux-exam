#!/bin/bash

echo "=== TLS Configuration Testing ==="
echo

# Test different TLS versions
echo "Testing TLS Versions:"
for version in tls1 tls1_1 tls1_2 tls1_3; do
    echo -n "  $version: "
    if timeout 5 openssl s_client -connect localhost:443 -$version -quiet < /dev/null &>/dev/null; then
        echo "✓ Supported"
    else
        echo "✗ Not supported"
    fi
done

echo
echo "Testing Common Cipher Suites:"

# Test common cipher suites
ciphers=(
    "ECDHE-RSA-AES256-GCM-SHA384"
    "ECDHE-RSA-AES128-GCM-SHA256"
    "DHE-RSA-AES256-GCM-SHA384"
    "AES256-GCM-SHA384"
)

for cipher in "${ciphers[@]}"; do
    echo -n "  $cipher: "
    if timeout 5 openssl s_client -connect localhost:443 -cipher "$cipher" -quiet < /dev/null &>/dev/null; then
        echo "✓ Supported"
    else
        echo "✗ Not supported"
    fi
done

echo
echo "Certificate Information:"
echo | openssl s_client -connect localhost:443 -servername localhost 2>/dev/null | openssl x509 -noout -subject -issuer -dates

