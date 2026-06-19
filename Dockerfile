# ==========================================
# Optimized CI Environment Image
# ==========================================
FROM rust:1.92-slim

# 1. Set environment variables to speed up Rust builds in CI
ENV CARGO_INCREMENTAL=0 \
    CARGO_REGISTRY_SCHEMAS=1 \
    RUST_BACKTRACE=1

# 2. Install all system dependencies in a single layer to reduce image size
# We combine everything needed for building, linting, and coverage (tarpaulin)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    lld \
    libssl-dev \
    pkg-config \
    clang \
    llvm \
    git \
    procps \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Rust components and cargo tools in a single layer
# Adding them together prevents creating multiple heavy intermediate layers
RUN rustup component add clippy rustfmt && \
    cargo install --locked cargo-audit cargo-tarpaulin

# 4. Set the working directory for CI tasks
WORKDIR /app

# Default command to verify environment integrity
CMD ["cargo", "--version"]
