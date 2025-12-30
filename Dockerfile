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
    libssl-dev \
    pkg-config \
    clang \
    llvm \
    git \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 3️⃣  Install the extra Cargo tools globally
# ------------------------------------------------------------
#   They end up in $HOME/.cargo/bin which we add to PATH later.
#   Using `--locked` guarantees reproducible builds of the tools.
# ------------------------------------------------------------
RUN cargo install --locked cargo-audit && \
    cargo install --locked cargo-tarpaulin

# ------------------------------------------------------------
# 4️⃣  Final lightweight image (optional)
# ------------------------------------------------------------
#    We could copy only the binaries into a smaller runtime image,
#    but keeping the full Rust toolchain makes it easy to compile
#    your own project inside the same container.
# ------------------------------------------------------------
FROM rust:1.92-slim

# Copy the Cargo binaries from the builder stage
COPY --from=builder /usr/local/cargo/bin /usr/local/cargo/bin

# Ensure the binary directory is on PATH (it already is, but be explicit)
ENV PATH="/usr/local/cargo/bin:${PATH}"

# Install the same OS libs that the builder needed (runtime deps only)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    clang \
    llvm \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------
# 5️⃣  Default command – a helpful hint for users of the image
# ----------------------------------------------------------------
CMD ["bash"]
