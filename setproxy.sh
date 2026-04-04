#!/bin/zsh

SERVICE="Wi-Fi"
HTTP_HOST="192.168.2.223"
HTTP_PORT="8899"
SOCKS_HOST="192.168.2.201"
SOCKS_PORT="7788"

clear_all_proxies() {
  networksetup -setwebproxy "$SERVICE" "" 0
  networksetup -setsecurewebproxy "$SERVICE" "" 0
  networksetup -setsocksfirewallproxy "$SERVICE" "" 0

  networksetup -setwebproxystate "$SERVICE" off
  networksetup -setsecurewebproxystate "$SERVICE" off
  networksetup -setsocksfirewallproxystate "$SERVICE" off
}

show_status() {
  echo "=== $SERVICE Proxy Status ==="
  echo "HTTP Proxy"
  networksetup -getwebproxy "$SERVICE"
  echo
  echo "HTTPS Proxy"
  networksetup -getsecurewebproxy "$SERVICE"
  echo
  echo "SOCKS5 Proxy"
  networksetup -getsocksfirewallproxy "$SERVICE"
}

case "$1" in
  http)
    networksetup -setwebproxy "$SERVICE" "$HTTP_HOST" "$HTTP_PORT"
    networksetup -setsecurewebproxy "$SERVICE" "$HTTP_HOST" "$HTTP_PORT"
    networksetup -setwebproxystate "$SERVICE" on
    networksetup -setsecurewebproxystate "$SERVICE" on
    echo "HTTP proxy ON -> $HTTP_HOST:$HTTP_PORT"
    ;;
  sock)
    networksetup -setsocksfirewallproxy "$SERVICE" "$SOCKS_HOST" "$SOCKS_PORT"
    networksetup -setsocksfirewallproxystate "$SERVICE" on
    echo "SOCKS5 proxy ON -> $SOCKS_HOST:$SOCKS_PORT"
    ;;
  off)
    clear_all_proxies
    echo "All proxy settings cleared"
    ;;
  "" )
    show_status
    ;;
  *)
    echo "Usage: $0 [http|sock|off]"
    ;;
esac
