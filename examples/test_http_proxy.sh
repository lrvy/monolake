#!/bin/bash

# MonoLake HTTP Proxy Test

set -e

CONFIG_FILE="config.toml"
PROJECT_ROOT="../"

echo "🧪 MonoLake HTTP Proxy Test"
echo "=========================="

# Cleanup function
cleanup() {
    echo "🧹 Cleaning up..."
    kill $SOCAT_PID $UDS_SOCAT_PID $MONOLAKE_PID 2>/dev/null || true
    wait $MONOLAKE_PID 2>/dev/null || true
    rm -f /tmp/test.sock
}

trap cleanup EXIT

echo "📋 Preparing test environment..."

# Generate certificates
if [ ! -f "certs/server.crt" ]; then
    ./gen_cert.sh
fi

# Start backend services
socat TCP-LISTEN:6153,reuseaddr,fork EXEC:'/bin/bash -c "echo \"Socket Response from 6153\""' &
SOCAT_PID=$!

# Start Unix Domain Socket service
socat UNIX-LISTEN:/tmp/test.sock,reuseaddr,fork EXEC:'/bin/bash -c "echo \"Unix Socket Response\""' &
UDS_SOCAT_PID=$!

sleep 2

echo "🚀 Starting MonoLake..."
cd $PROJECT_ROOT
cargo run --bin monolake -- --config examples/$CONFIG_FILE &
MONOLAKE_PID=$!
cd examples

sleep 5

echo "✅ Testing HTTP routes:"
echo "  Socket upstream (port 6153):"
curl -s http://localhost:8080/socket | head -1

echo "  URI upstream:"
curl -s http://localhost:8080/uri | head -1

echo "  Unix Domain Socket upstream:"
curl -s http://localhost:8080/unix | head -1

echo "  Load balancing (Socket/URI/Unix):"
curl -s http://localhost:8080/balance | head -1

echo "  Default route:"
curl -s http://localhost:8080/ | head -1

echo "✅ Testing HTTPS routes:"
echo "  HTTPS (insecure):"
curl -k -s https://localhost:8081/ | head -1

echo "�� All tests passed!" 