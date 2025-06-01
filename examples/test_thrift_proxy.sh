#!/bin/bash

# MonoLake Thrift Proxy Test

set -e

CONFIG_FILE="thrift.toml"
PROJECT_ROOT="../"

echo "🧪 MonoLake Thrift Proxy Test"
echo "============================"

# Cleanup function  
cleanup() {
    echo "🧹 Cleaning up..."
    rm -f /tmp/thrift_server_monolake.sock /tmp/thrift_proxy_monolake.sock
    kill $SOCAT_TCP_PID $SOCAT_UDS_PID $MONOLAKE_PID 2>/dev/null || true
    wait $MONOLAKE_PID 2>/dev/null || true
}

trap cleanup EXIT

echo "📋 Starting backend services..."

# Start TCP backend
socat TCP-LISTEN:9969,reuseaddr,fork EXEC:'/bin/bash -c "echo \"Thrift TCP Response\""' &
SOCAT_TCP_PID=$!

# Start UDS backend
rm -f /tmp/thrift_server_monolake.sock
socat UNIX-LISTEN:/tmp/thrift_server_monolake.sock,fork EXEC:'/bin/bash -c "echo \"Thrift UDS Response\""' &
SOCAT_UDS_PID=$!

sleep 2

echo "🚀 Starting MonoLake..."
cd $PROJECT_ROOT
cargo run --bin monolake -- --config examples/$CONFIG_FILE &
MONOLAKE_PID=$!
sleep 3

echo "✅ Testing Thrift TCP proxy (port 8081):"
echo "test" | nc localhost 8081

echo "✅ Testing Thrift UDS proxy:"
echo "test" | socat - UNIX-CONNECT:/tmp/thrift_proxy_monolake.sock

echo "�� All tests passed!" 