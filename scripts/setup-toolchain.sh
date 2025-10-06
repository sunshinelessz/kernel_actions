#!/usr/bin/env bash
set -euo pipefail

NDK_URL="${1:-}"

WORKDIR="$PWD/toolchain"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

NDK_FILE=$(basename "$NDK_URL")
if [ ! -f "$NDK_FILE" ]; then
  echo "Baixando Android NDK r25b..."
  wget -q --show-progress "$NDK_URL" -O "$NDK_FILE"
fi

unzip -q -o "$NDK_FILE"
NDK_DIR=$(find . -maxdepth 1 -type d -name "android-ndk*" -print -quit)
if [ -z "$NDK_DIR" ]; then
  echo "NDK não encontrado!"
  exit 1
fi

CLANG_PATH="$(realpath "$NDK_DIR"/toolchains/llvm/prebuilt/linux-x86_64/bin)"
echo "Clang encontrado em $CLANG_PATH"
echo "CLANG_PATH=$CLANG_PATH" >> "$GITHUB_ENV"
export PATH="$CLANG_PATH:$PATH"

# Configurar ccache
export CCACHE_DIR="$HOME/.ccache"
mkdir -p "$CCACHE_DIR"
export PATH="$HOME/.ccache:$PATH"

echo "Toolchain configurada com Clang 17 (NDK r25b)!"
