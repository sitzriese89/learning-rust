# ------------------------------------------------------------
# 1️⃣  Base image – official Rust toolchain (stable)
# ------------------------------------------------------------
FROM rust:1.92-slim AS builder

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
# 3️⃣  Install the extra Cargo tools globally
# ------------------------------------------------------------
#   They end up in $HOME/.cargo/bin which we add to PATH later.
#   Using `--locked` guarantees reproducible builds of the tools.
# ------------------------------------------------------------
RUN cargo install --locked cargo-audit && \
    cargo install --locked cargo-tarpaulin

RUN rustup component add clippy

RUN rustup component add rustfmt
