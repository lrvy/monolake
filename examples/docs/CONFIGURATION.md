# Configuration Guide

## Basic HTTP Proxy

```toml
[runtime]
runtime_type = "legacy"
worker_threads = 2
entries = 512

[servers.http_proxy]
name = "monolake-demo"
proxy_type = "http"
listener = { type = "socket", value = "0.0.0.0:8080" }
upstream_http_version = "http11"

[[servers.http_proxy.routes]]
path = "/"
upstreams = [{ endpoint = { type = "uri", value = "http://httpbin.org" } }]
```

## HTTPS Proxy

```toml
[servers.https_proxy]
name = "secure-proxy"
proxy_type = "http"
listener = { type = "socket", value = "0.0.0.0:8081" }
tls = { chain = "certs/server.crt", key = "certs/server.pkcs8" }
upstream_http_version = "http2"

[[servers.https_proxy.routes]]
path = "/"
upstreams = [{ endpoint = { type = "uri", value = "https://httpbin.org" } }]
```

## Upstream Types

### Socket
```toml
{ endpoint = { type = "socket", value = "127.0.0.1:3001" } }
```

### Unix Domain Socket
```toml
{ endpoint = { type = "unix", value = "/tmp/backend.sock" } }
```

### URI
```toml
{ endpoint = { type = "uri", value = "http://example.com" } }
```

## Load Balancing

```toml
[[servers.http_proxy.routes]]
path = "/balance"
upstreams = [
    { endpoint = { type = "socket", value = "127.0.0.1:3001" }, weight = 70 },
    { endpoint = { type = "socket", value = "127.0.0.1:3002" }, weight = 30 }
]
load_balancer = "weighted_random"
```

## Timeouts

```toml
[servers.http_proxy.http_timeout]
server_keepalive_timeout_sec = 60
upstream_connect_timeout_sec = 5
upstream_read_timeout_sec = 10
```

## Thrift Proxy

```toml
[servers.thrift_proxy]
name = "thrift_proxy"
proxy_type = "thrift"
listener = { type = "socket", value = "0.0.0.0:8081" }
route.upstreams = [{ endpoint = { type = "socket", value = "127.0.0.1:9969" } }]
``` 