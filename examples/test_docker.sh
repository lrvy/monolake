#!/bin/bash

# MonoLake Docker Test Suite

set -e

MONOLAKE_IMAGE="monolake:latest"
DEFAULT_CONFIG="config.toml"

echo "🐳 MonoLake Docker Test Suite"
echo "============================"

# Cleanup function
cleanup() {
    echo "🧹 Cleaning up..."
    docker stop monolake-test 2>/dev/null || true
    docker rm monolake-test 2>/dev/null || true
}

trap cleanup EXIT

# Build or verify image
verify_image() {
    if ! docker images | grep -q "monolake.*latest"; then
        echo "📦 Building MonoLake image..."
        docker build -f Dockerfile -t "$MONOLAKE_IMAGE" ..
    fi
}

# Generate certificates if needed
if [ ! -f "certs/server.crt" ]; then
    ./gen_cert.sh
fi

# Test basic Docker functionality
test_basic() {
    echo "🚀 Testing basic Docker functionality..."
    
    verify_image
    
    echo "Starting MonoLake container..."
    docker run -d --name monolake-test \
        --network host \
        -v "$(pwd)/$DEFAULT_CONFIG:/app/config.toml:ro" \
        -v "$(pwd)/certs:/app/certs:ro" \
        "$MONOLAKE_IMAGE"
    
    sleep 5
    
    echo "Testing HTTP proxy:"
    if curl -s --max-time 5 http://127.0.0.1:8080/ | head -n1; then
        echo "✅ HTTP proxy working"
    else
        echo "❌ HTTP proxy failed"
    fi
    
    echo "Testing HTTPS proxy:"
    if curl -k -s --max-time 5 https://127.0.0.1:8081/ | head -n1; then
        echo "✅ HTTPS proxy working"
    else
        echo "❌ HTTPS proxy failed"
    fi
}

# Test with port mapping
test_port_mapping() {
    echo "🚀 Testing with port mapping..."
    
    cleanup
    
    docker run -d --name monolake-test \
        -p 8080:8080 -p 8081:8081 \
        -v "$(pwd)/$DEFAULT_CONFIG:/app/config.toml:ro" \
        -v "$(pwd)/certs:/app/certs:ro" \
        "$MONOLAKE_IMAGE"
    
    sleep 5
    
    echo "Testing HTTP proxy (port mapping):"
    if curl -s --max-time 5 http://127.0.0.1:8080/ | head -n1; then
        echo "✅ HTTP proxy working"
    else
        echo "❌ HTTP proxy failed"
    fi
}

# Main test execution
case "${1:-basic}" in
    "basic"|"b")
        test_basic
        ;;
    "port"|"p")
        test_port_mapping
        ;;
    "all"|*)
        test_basic
        test_port_mapping
        ;;
esac

echo "🎉 Docker tests completed!"
echo ""
echo "Usage:"
echo "  ./test_docker.sh         # Basic host network test"
echo "  ./test_docker.sh port    # Port mapping test"
echo "  ./test_docker.sh all     # All tests" 