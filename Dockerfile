# ==========================================
# STAGE 1: Builder
# ==========================================
FROM rust:1.92-slim AS builder

# Install build dependencies
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

# Install cargo tools
RUN cargo install --locked cargo-audit cargo-tarpaulin

# Add rustup components
RUN rustup component add clippy rustfmt

# ==========================================
# STAGE 2: Final Runtime Image
# ==========================================
FROM rust:1.92-slim

# 1. Install only the necessary runtime dependencies
# (Retaining clang/llvm for tarpaulin's instrumentation)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl-dev \
    pkg-config \
    clang \
    llvm \
    git \
    procps \
    && rm -rf /var/lib/apt/lists/*

# 2. Copy the compiled binaries from the builder stage
COPY --from=builder /usr/local/cargo/bin /usr/local/cargo/bin

# 3. Add rustup components to the final image
RUN rustup component add clippy rustfmt

# Set the working directory for CI tasks
WORKDIR /app

# Default command
CMD ["cargo", "--version"]
