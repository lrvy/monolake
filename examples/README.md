# MonoLake Examples

Quick start examples for MonoLake HTTP/HTTPS proxy with URI, Socket, and Unix Domain Socket upstreams.

## Quick Start

1. **Start MonoLake**:
   ```bash
   cargo run -- --config examples/config.toml
   ```

2. **Test different endpoints**:
   ```bash
   curl http://localhost:8080/          # URI upstream
   curl http://localhost:8080/socket    # TCP socket upstream (port 6153)
   curl http://localhost:8080/unix      # Unix Domain Socket upstream
   curl http://localhost:8080/balance   # Load balancing (mixed types)
   ```

## Upstream Types

- **URI**: HTTP/HTTPS endpoints (e.g., `http://httpbin.org`)
- **Socket**: TCP socket addresses (e.g., `127.0.0.1:6153`)
- **Unix**: Unix Domain Socket paths (e.g., `/tmp/test.sock`)

## HTTPS Support

1. **Generate certificates**:
   ```bash
   ./examples/gen_cert.sh
   ```

2. **Test HTTPS**:
   ```bash
   curl -k https://localhost:8081/
   ```

## Docker Usage

**Build**:
```bash
docker build -f examples/Dockerfile -t monolake:latest .
```

**Run with host networking** (recommended):
```bash
docker run --network host \
  -v $(pwd)/examples/config.toml:/app/config.toml:ro \
  -v $(pwd)/examples/certs:/app/certs:ro \
  monolake:latest
```

**Run with port mapping**:
```bash
docker run -p 8080:8080 -p 8081:8081 \
  -v $(pwd)/examples/config.toml:/app/config.toml:ro \
  -v $(pwd)/examples/certs:/app/certs:ro \
  monolake:latest
```

## Testing

- `./test_http_proxy.sh` - HTTP/HTTPS proxy tests
- `./test_thrift_proxy.sh` - Thrift proxy tests  
- `./test_docker.sh` - Docker integration tests

## Configuration Files

- `config.toml` - Main HTTP/HTTPS proxy configuration
- `thrift.toml` - Thrift proxy configuration