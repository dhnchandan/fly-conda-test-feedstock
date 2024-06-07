#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Build the Rust extension using maturin
maturin develop --release

# Install the built package
$PYTHON -m pip install target/wheels/*.whl
