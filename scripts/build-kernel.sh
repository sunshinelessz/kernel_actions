#!/usr/bin/env bash
set -euo pipefail

DEFCONFIG_FILE="${1:-arch/arm64/configs/defconfig}"
OUTNAME="${2:-kernel-sideload.zip}"
SIDELOAD_DIR="${3:-sideload}"

KERNEL_DIR=$(dirname "$DEFCONFIG_FILE")/..

export ARCH=${ARCH:-arm64}
export O=${KBUILD_OUTPUT:-out}

cd "$KERNEL_DIR"

# Aplicar defconfig
cp "$DEFCONFIG_FILE" .config
make olddefconfig O="$O"

# Compilar kernel
NPROC=$(nproc || echo 2)
make -j"$NPROC" O="$O"

ART_OUT_DIR="./$O"
mkdir -p out

# Gerar boot.img
if [ -f "$ART_OUT_DIR/arch/arm64/boot/Image.gz-dtb" ]; then
  echo "Gerando boot.img..."
  mkbootimg \
    --kernel "$ART_OUT_DIR/arch/arm64/boot/Image.gz-dtb" \
    --ramdisk ramdisk.img \
    --cmdline "console=ttyHSL0,115200,n8 androidboot.hardware=sm6225" \
    --base 0x80000000 \
    -o out/boot.img
fi

# Copiar dtbo.img se existir
[ -f "$ART_OUT_DIR/arch/arm64/boot/dtbo.img" ] && cp "$ART_OUT_DIR/arch/arm64/boot/dtbo.img" out/dtbo.img

# Criar sideload zip
mkdir -p out/META-INF/com/google/android
cp "$SIDELOAD_DIR/update-binary" out/META-INF/com/google/android/
cp "$SIDELOAD_DIR/updater-script" out/META-INF/com/google/android/

cd out
zip -r "../${OUTNAME}" *
cd ..

echo "Flashable sideload zip criado: ./out/${OUTNAME}"
ls -lah ./out
