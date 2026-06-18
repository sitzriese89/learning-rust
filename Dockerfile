# ------------------------------------------------------------
# 1️⃣  Base image – official Rust toolchain (stable)
# ------------------------------------------------------------
FROM rust:1.92-slim

# ------------------------------------------------------------
# 2️⃣  Install OS‑level dependencies
# ------------------------------------------------------------
#   * ca‑certificates – needed for HTTPS downloads
#   * libssl-dev & pkg-config – required by many crates (including tarpaulin)
#   * clang & llvm – tarpaulin uses LLVM for instrumentation
#   * git – Cargo sometimes needs it for fetching git dependencies
# ------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    lld \
    libssl-dev \
    pkg-config \
    clang \
    llvm \
    git \
    sudo \
    procps \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 3️⃣  Install extra Cargo tools and Rust components
# ------------------------------------------------------------
# Combining these reduces the number of image layers.
RUN cargo install --locked cargo-audit cargo-tarpaulin && \
    rustup component add clippy rustfmt
