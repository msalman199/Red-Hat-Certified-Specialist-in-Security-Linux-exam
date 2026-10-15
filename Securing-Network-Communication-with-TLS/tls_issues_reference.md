# TLS Troubleshooting Reference Guide

## Common Issues and Solutions

### 1. Certificate Issues

**Problem**: "certificate verify failed" or "self signed certificate"
**Solution**: 
- For testing: Use `-k` flag with curl or add certificate to trusted store
- For production: Use certificates from trusted CA

**Problem**: "certificate has expired"
**Solution**: 
- Generate new certificate with longer validity period
- Set up automatic certificate renewal

### 2. Connection Issues

**Problem**: "Connection refused" on port 443
**Solution**:
- Check if web server is running: `systemctl status httpd/nginx`
- Verify port is listening: `netstat -tlnp | grep :443`
- Check firewall rules: `firewall-cmd --list-ports`

**Problem**: "SSL handshake failed"
**Solution**:
- Check SSL configuration syntax
- Verify certificate and key files exist and are readable
- Check for cipher suite mismatches

### 3. Configuration Issues

**Problem**: "SSL_ERROR_RX_RECORD_TOO_LONG"
**Solution**:
- Usually indicates HTTP traffic on HTTPS port
- Check virtual host configuration
- Ensure SSL is properly enabled

**Problem**: Mixed content warnings
**Solution**:
- Ensure all resources (CSS, JS, images) use HTTPS
- Use relative URLs or protocol-relative URLs
- Implement proper redirects from HTTP to HTTPS

### 4. Performance Issues

**Problem**: Slow SSL handshakes
**Solution**:
- Enable SSL session caching
- Use ECDHE cipher suites
- Implement HTTP/2
- Consider SSL session tickets

## Testing Commands Quick Reference

```bash
# Basic connection test
openssl s_client -connect hostname:443

# Test specific TLS version
openssl s_client -connect hostname:443 -tls1_2

# Test with SNI
openssl s_client -connect hostname:443 -servername hostname

# Check certificate expiration
echo | openssl s_client -connect hostname:443 2>/dev/null | openssl x509 -noout -dates

# Test cipher suites
nmap --script ssl-enum-ciphers -p 443 hostname
