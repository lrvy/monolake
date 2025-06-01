# MonoLake HTTP Proxy - Simplified Dockerfile for Host Network Mode
# Based on Debian 12 (bookworm)
# Build from project root: docker build -f examples/Dockerfile -t monolake:latest .

FROM rustlang/rust:nightly-slim AS builder

# Build arguments
ARG RUST_PROFILE=release

# Install system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ca-certificates \
    clang \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Copy source code (build context should be project root)
COPY . .

# Build MonoLake
RUN cargo build --profile $RUST_PROFILE --package monolake

# Determine binary location and copy
RUN if [ "$RUST_PROFILE" = "dev" ]; then \
        cp target/debug/monolake /usr/local/bin/monolake; \
    else \
        cp target/$RUST_PROFILE/monolake /usr/local/bin/monolake || \
        cp target/release/monolake /usr/local/bin/monolake; \
    fi

# Runtime environment
FROM debian:12-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
RUN mkdir -p /app/certs

# Copy binary from builder
COPY --from=builder /usr/local/bin/monolake /usr/local/bin/monolake
RUN chmod +x /usr/local/bin/monolake

# Set working directory
WORKDIR /app

# Expose standard ports (will use host networking)
EXPOSE 8080 8081

# Health check using localhost (host network mode)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://127.0.0.1:8080/ || exit 1

# Default command
CMD ["/usr/local/bin/monolake", "--config", "/app/config.toml"] 