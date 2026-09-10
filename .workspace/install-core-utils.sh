##!/usr/bin/env bash
#
# Embedded / C Development Environment Bootstrap
#
# Tested/targeted at:
#   Ubuntu 24.04 x86-64
#
# Installs:
#   - GCC / G++ / Make / CMake / Ninja
#   - Clang / LLVM
#   - ARM GNU Toolchain
#   - GDB / OpenOCD
#   - FreeRTOS source
#   - Zephyr + west + Zephyr SDK
#   - Renode
#   - QEMU
#   - Verilator (built from Git source)
#   - GTKWave
#   - useful embedded development utilities
#

set -euo pipefail

# ----------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------

INSTALL_ROOT="${HOME}/tools"
SRC_ROOT="${HOME}/src"

VERILATOR_SRC="${SRC_ROOT}/verilator"
FREERTOS_SRC="${SRC_ROOT}/FreeRTOS"
ZEPHYR_ROOT="${HOME}/zephyrproject"

# Verilator install location.
# Keeping it under ~/tools avoids modifying /usr/local.
VERILATOR_INSTALL="${INSTALL_ROOT}/verilator"

# ARM GNU toolchain installation.
ARM_TOOLCHAIN_DIR="${INSTALL_ROOT}/arm-gnu-toolchain"

# ----------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------

info()
{
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

command_exists()
{
    command -v "$1" >/dev/null 2>&1
}

# ----------------------------------------------------------------------
# Sanity checks
# ----------------------------------------------------------------------

info "Checking operating system"

if [[ ! -f /etc/os-release ]]; then
    die "Cannot determine operating system."
fi

source /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "WARNING: This script was written for Ubuntu."
    echo "Detected: ${PRETTY_NAME:-unknown}"
    echo
    read -r -p "Continue anyway? [y/N] " answer

    if [[ ! "${answer}" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

if [[ "${EUID}" -eq 0 ]]; then
    die "Do not run this script as root. Run it as your normal user."
fi

# ----------------------------------------------------------------------
# Directories
# ----------------------------------------------------------------------

info "Creating development directories"

mkdir -p "${INSTALL_ROOT}"
mkdir -p "${SRC_ROOT}"

# ----------------------------------------------------------------------
# APT repositories
# ----------------------------------------------------------------------

info "Enabling Ubuntu repositories"

sudo add-apt-repository -y universe
sudo add-apt-repository -y multiverse

sudo apt-get update

# ----------------------------------------------------------------------
# Core development tools
# ----------------------------------------------------------------------

info "Installing C/C++ development environment"

sudo apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    ninja-build \
    pkg-config \
    autoconf \
    automake \
    libtool \
    m4 \
    ccache \
    clang \
    llvm \
    lldb \
    clang-format \
    clang-tidy \
    gdb \
    gdb-multiarch \
    git \
    git-lfs \
    curl \
    wget \
    unzip \
    zip \
    tar \
    xz-utils \
    bzip2 \
    rsync \
    file \
    tree \
    jq \
    bc \
    bison \
    flex \
    help2man \
    texinfo

# ----------------------------------------------------------------------
# Embedded development libraries/tools
# ----------------------------------------------------------------------

info "Installing embedded development dependencies"

sudo apt-get install -y \
    device-tree-compiler \
    libusb-1.0-0-dev \
    libusb-1.0-0 \
    libhidapi-dev \
    libncurses-dev \
    libreadline-dev \
    libelf-dev \
    libdw-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libfl-dev \
    libjemalloc-dev \
    libsdl2-dev \
    libmagic1 \
    libxml2-dev \
    libyaml-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-setuptools \
    python3-wheel \
    python3-tk

# ----------------------------------------------------------------------
# ARM GCC
# ----------------------------------------------------------------------

info "Installing ARM GCC toolchain"

sudo apt-get install -y \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib

echo
echo "ARM GCC:"
arm-none-eabi-gcc --version | head -n 1

# ----------------------------------------------------------------------
# OpenOCD
# ----------------------------------------------------------------------

info "Installing OpenOCD"

sudo apt-get install -y openocd

echo
echo "OpenOCD:"
openocd --version || true

# ----------------------------------------------------------------------
# GTKWave
# ----------------------------------------------------------------------

info "Installing waveform viewer"

sudo apt-get install -y gtkwave

# ----------------------------------------------------------------------
# QEMU
# ----------------------------------------------------------------------

info "Installing QEMU"

sudo apt-get install -y \
    qemu-system \
    qemu-system-arm \
    qemu-system-x86 \
    qemu-system-misc \
    qemu-utils \
    qemu-user \
    qemu-user-static

echo
echo "QEMU:"
qemu-system-arm --version | head -n 1

# ----------------------------------------------------------------------
# Verilator - BUILD FROM SOURCE
# ----------------------------------------------------------------------

info "Building Verilator from Git source"

if [[ -d "${VERILATOR_SRC}/.git" ]]; then
    echo "Verilator repository already exists."
    echo "Updating..."

    git -C "${VERILATOR_SRC}" fetch --all --tags
    git -C "${VERILATOR_SRC}" pull --ff-only
else
    echo "Cloning Verilator..."

    git clone \
        https://github.com/verilator/verilator.git \
        "${VERILATOR_SRC}"
fi

cd "${VERILATOR_SRC}"

echo "Verilator source:"
git remote -v | head -n 1
echo "Commit:"
git rev-parse --short HEAD

# Clean configure/build state if necessary.
#
# Verilator's documented source build uses:
#   autoconf
#   ./configure
#   make
#
autoconf

./configure \
    --prefix="${VERILATOR_INSTALL}"

make -j"$(nproc)"

make install

echo
echo "Verilator installed:"
"${VERILATOR_INSTALL}/bin/verilator" --version

# ----------------------------------------------------------------------
# FreeRTOS
# ----------------------------------------------------------------------

info "Installing FreeRTOS source"

if [[ -d "${FREERTOS_SRC}/.git" ]]; then
    echo "FreeRTOS repository already exists."
    git -C "${FREERTOS_SRC}" pull --ff-only
else
    git clone \
        https://github.com/FreeRTOS/FreeRTOS.git \
        "${FREERTOS_SRC}"
fi

# FreeRTOS is source code rather than a conventional system package.
#
# The repository contains the kernel and examples/projects.
#
echo
echo "FreeRTOS source:"
echo "  ${FREERTOS_SRC}"

# ----------------------------------------------------------------------
# Python virtual environment for Zephyr
# ----------------------------------------------------------------------

info "Setting up Zephyr Python environment"

if [[ ! -d "${ZEPHYR_ROOT}" ]]; then
    mkdir -p "${ZEPHYR_ROOT}"
fi

if [[ ! -d "${ZEPHYR_ROOT}/.venv" ]]; then
    python3 -m venv "${ZEPHYR_ROOT}/.venv"
fi

source "${ZEPHYR_ROOT}/.venv/bin/activate"

python -m pip install --upgrade pip setuptools wheel

# west is Zephyr's workspace manager.
python -m pip install --upgrade west

echo
echo "west:"
west --version

# ----------------------------------------------------------------------
# Zephyr source
# ----------------------------------------------------------------------

info "Installing Zephyr"

if [[ ! -d "${ZEPHYR_ROOT}/.west" ]]; then

    west init \
        -m https://github.com/zephyrproject-rtos/zephyr \
        "${ZEPHYR_ROOT}"

else
    echo "Existing Zephyr west workspace found."
fi

cd "${ZEPHYR_ROOT}"

west update

# Install Python dependencies corresponding to the checked-out
# Zephyr version and modules.
west packages pip --install

# Register Zephyr as a CMake package.
west zephyr-export

# ----------------------------------------------------------------------
# Zephyr SDK
# ----------------------------------------------------------------------

info "Installing Zephyr SDK"

cd "${ZEPHYR_ROOT}/zephyr"

#
# Install the SDK through west.
#
# This gives Zephyr its supported compiler/toolchain and host tools.
#
west sdk install

# ----------------------------------------------------------------------
# Renode
# ----------------------------------------------------------------------

info "Installing Renode"

RENODE_DIR="${INSTALL_ROOT}/renode"

mkdir -p "${RENODE_DIR}"

#
# Renode publishes Linux packages/releases through GitHub.
#
# We install the current .deb release automatically.
#

RENODE_API="https://api.github.com/repos/renode/renode/releases/latest"

RENODE_URL="$(
    curl -fsSL "${RENODE_API}" |
    python3 -c '
import json
import sys

data = json.load(sys.stdin)

for asset in data.get("assets", []):
    name = asset.get("name", "")
    url = asset.get("browser_download_url", "")

    if name.endswith(".deb") and "linux" in name.lower():
        print(url)
        break
'
)"

if [[ -z "${RENODE_URL}" ]]; then
    echo "WARNING: Could not automatically find Renode .deb."
    echo "Install it manually from the Renode releases page."
else

    RENODE_DEB="/tmp/renode.deb"

    echo "Downloading:"
    echo "${RENODE_URL}"

    curl -fL \
        "${RENODE_URL}" \
        -o "${RENODE_DEB}"

    sudo apt-get install -y "${RENODE_DEB}"

    rm -f "${RENODE_DEB}"
fi

# ----------------------------------------------------------------------
# Shell environment
# ----------------------------------------------------------------------

info "Configuring shell environment"

BASHRC="${HOME}/.bashrc"

# Add development tools to PATH.
cat >> "${BASHRC}" <<EOF

# ============================================================
# Embedded development environment
# ============================================================

export PATH="\$HOME/tools/verilator/bin:\$PATH"

# ARM GNU toolchain
if [ -d "\$HOME/tools/arm-gnu-toolchain/bin" ]; then
    export PATH="\$HOME/tools/arm-gnu-toolchain/bin:\$PATH"
fi

# Zephyr
if [ -d "\$HOME/zephyrproject/.venv/bin" ]; then
    export PATH="\$HOME/zephyrproject/.venv/bin:\$PATH"
fi

EOF

# ----------------------------------------------------------------------
# Verification
# ----------------------------------------------------------------------

info "Verifying installation"

echo
echo "C compiler:"
gcc --version | head -n 1

echo
echo "C++ compiler:"
g++ --version | head -n 1

echo
echo "Clang:"
clang --version | head -n 1

echo
echo "CMake:"
cmake --version | head -n 1

echo
echo "Ninja:"
ninja --version

echo
echo "ARM GCC:"
arm-none-eabi-gcc --version | head -n 1

echo
echo "GDB:"
gdb --version | head -n 1

echo
echo "OpenOCD:"
openocd --version 2>&1 | head -n 1 || true

echo
echo "QEMU:"
qemu-system-arm --version | head -n 1

echo
echo "Verilator:"
"${VERILATOR_INSTALL}/bin/verilator" --version

echo
echo "West:"
"${ZEPHYR_ROOT}/.venv/bin/west" --version

if command_exists renode; then
    echo
    echo "Renode:"
    renode --version || true
fi

# ----------------------------------------------------------------------
# Docker Engine
# ----------------------------------------------------------------------

info "Installing Docker Engine"

# Remove conflicting/old Docker packages if present.
sudo apt-get remove -y \
    docker.io \
    docker-doc \
    docker-compose \
    podman-docker \
    containerd \
    runc \
    2>/dev/null || true

# Docker's official repository prerequisites.
sudo apt-get install -y \
    ca-certificates \
    curl

# Install Docker's official GPG key.
sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

# Configure Docker apt repository.
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# Install Docker Engine + CLI + Buildx + Compose.
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Enable/start Docker.
sudo systemctl enable --now docker

# Allow current user to use Docker without sudo.
sudo usermod -aG docker "${USER}"

echo
echo "Docker:"
sudo docker --version

echo
echo "Docker Compose:"
sudo docker compose version

echo
echo "Docker Buildx:"
sudo docker buildx version

echo
echo "NOTE:"
echo "You have been added to the 'docker' group."
echo "Log out and back in (or reboot) before using docker without sudo."
