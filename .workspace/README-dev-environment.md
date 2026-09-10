# Zephyr, ARM Bare-Metal, and SystemVerilog Development Setup

This guide targets Ubuntu/Debian systems and installs tools for:

- Zephyr RTOS development
- ARM AArch32 bare-metal (`arm-none-eabi`)
- ARM AArch64 bare-metal and Linux cross-compilation
- C/C++ development and debugging
- SystemVerilog simulation with Verilator and Icarus Verilog
- Cocotb, GTKWave, PeakRDL, and related Python tools
- Docker and Docker Compose
- Rust using the official `rustup` installer

The installer is intentionally written as a Bash script inside this Markdown
file. It uses `apt` for system packages, `rustup` for the latest Rust toolchain,
and a Python virtual environment for Python packages.

## Run the installer

Review the script before running it. Extract it to a temporary file and execute
it with:

```bash
awk '/^## Installer$/{section=1} section && /^```bash$/{capture=1; next} \
  capture && /^```$/{exit} capture' \
  ~/.workspace/README-dev-environment.md > /tmp/install-dev-environment.sh
chmod +x /tmp/install-dev-environment.sh
/tmp/install-dev-environment.sh
```

The script does not require an existing Zephyr checkout. By default it creates
`~/zephyrproject` and installs the Zephyr Python environment there.

## Installer

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

readonly ZEPHYR_WORKSPACE="${ZEPHYR_WORKSPACE:-$HOME/zephyrproject}"
readonly ZEPHYR_VENV="${ZEPHYR_VENV:-$ZEPHYR_WORKSPACE/.venv}"

if [[ "${EUID}" -eq 0 ]]; then
  echo "Run this script as a normal user with sudo access, not as root." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required." >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This installer supports Debian/Ubuntu systems with apt-get." >&2
  exit 1
fi

echo "Updating package indexes..."
sudo apt-get update

echo "Installing compilers, build tools, simulators, and utilities..."
sudo apt-get install -y --no-install-recommends \
  build-essential \
  gcc \
  g++ \
  clang \
  clang-format \
  clang-tidy \
  clangd \
  lldb \
  gdb \
  cmake \
  ninja-build \
  make \
  ccache \
  pkg-config \
  git \
  curl \
  wget \
  unzip \
  zip \
  tar \
  xz-utils \
  file \
  rsync \
  jq \
  tree \
  ripgrep \
  shellcheck \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  python3-setuptools \
  python3-wheel \
  device-tree-compiler \
  libusb-1.0-0-dev \
  libudev-dev \
  libncurses-dev \
  libyaml-dev \
  zlib1g-dev \
  libffi-dev \
  libssl-dev \
  openocd \
  minicom \
  picocom

echo "Installing AArch32 bare-metal tools..."
sudo apt-get install -y --no-install-recommends \
  gcc-arm-none-eabi \
  binutils-arm-none-eabi \
  libnewlib-arm-none-eabi \
  libstdc++-arm-none-eabi-newlib

echo "Installing AArch64 cross-compilation tools..."
sudo apt-get install -y --no-install-recommends \
  gcc-aarch64-linux-gnu \
  g++-aarch64-linux-gnu \
  binutils-aarch64-linux-gnu \
  libc6-dev-arm64-cross

echo "Installing SystemVerilog and waveform tools..."
sudo apt-get install -y --no-install-recommends \
  verilator \
  iverilog \
  gtkwave \
  yosys

echo "Installing Docker..."
sudo apt-get install -y --no-install-recommends \
  docker.io \
  docker-compose-v2

sudo systemctl enable --now docker
sudo usermod -aG docker "${USER}"

echo "Installing Rust using rustup..."
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# rustup installs cargo under ~/.cargo/bin. Do not rely on the caller's PATH.
export PATH="$HOME/.cargo/bin:$PATH"
rustup toolchain install stable
rustup default stable
rustup component add rustfmt clippy

echo "Creating the Zephyr Python environment..."
mkdir -p "${ZEPHYR_WORKSPACE}"
python3 -m venv "${ZEPHYR_VENV}"
# shellcheck disable=SC1091
source "${ZEPHYR_VENV}/bin/activate"
python -m pip install --upgrade pip setuptools wheel
python -m pip install --upgrade west

if [[ ! -d "${ZEPHYR_WORKSPACE}/.west" ]]; then
  west init "${ZEPHYR_WORKSPACE}"
fi

if [[ ! -d "${ZEPHYR_WORKSPACE}/zephyr" ]]; then
  (
    cd "${ZEPHYR_WORKSPACE}"
    west update
  )
fi

if [[ -f "${ZEPHYR_WORKSPACE}/zephyr/scripts/requirements.txt" ]]; then
  python -m pip install --upgrade \
    -r "${ZEPHYR_WORKSPACE}/zephyr/scripts/requirements.txt"
fi

echo "Installing PeakRDL and Cocotb Python packages..."
python -m pip install --upgrade \
  cocotb \
  cocotb-test \
  peakrdl \
  peakrdl-cheader \
  peakrdl-regblock \
  peakrdl-html \
  pytest

echo "Exporting the Zephyr environment..."
(
  cd "${ZEPHYR_WORKSPACE}"
  west zephyr-export
)

echo
echo "Installation complete."
echo
echo "Activate the Zephyr/Python environment with:"
echo "  source ${ZEPHYR_VENV}/bin/activate"
echo
echo "If Docker commands fail with permission errors, log out and back in,"
echo "or run: newgrp docker"
echo
echo "Install the Zephyr SDK after activating the environment with:"
echo "  cd ${ZEPHYR_WORKSPACE}"
echo "  west sdk install"
```

## Zephyr SDK

The SDK contains Zephyr's supported cross-compilers, host tools, and
toolchain metadata. Install it after the script completes:

```bash
source ~/zephyrproject/.venv/bin/activate
cd ~/zephyrproject
west sdk install
```

To install a specific SDK version instead of the current version selected by
the installed Zephyr manifest:

```bash
west sdk install --version <version>
```

The Debian packages above install the GNU ARM embedded toolchain separately,
which is useful for standalone bare-metal projects. For Zephyr builds, prefer
the Zephyr SDK selected by `west`.

## Rust latest toolchain

The Ubuntu/Debian `rustc` package can lag behind upstream. The installer uses
the official `rustup` method:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup toolchain install stable
rustup default stable
rustup component add rustfmt clippy
```

Check the installed versions:

```bash
rustc --version
cargo --version
rustup show
```

## Useful verification commands

```bash
gcc --version
g++ --version
clang --version
clang-format --version
cmake --version
ninja --version

arm-none-eabi-gcc --version
aarch64-linux-gnu-gcc --version

verilator --version
iverilog -V
gtkwave --version
yosys --version

docker --version
docker compose version

source ~/zephyrproject/.venv/bin/activate
west --version
python --version
python -c 'import cocotb, peakrdl; print("cocotb and PeakRDL import successfully")'
```

## Example compiler checks

```bash
# Strict C syntax and warning check
gcc -std=c11 -Wall -Wextra -Wpedantic -Werror \
  -fsyntax-only path/to/file.c

# Strict C++ syntax and warning check
g++ -std=c++17 -Wall -Wextra -Wpedantic -Werror \
  -fsyntax-only path/to/file.cpp

# Check a header as C
gcc -std=c11 -Wall -Wextra -Werror \
  -fsyntax-only -x c path/to/header.h

# Check a header as C++
g++ -std=c++17 -Wall -Wextra -Werror \
  -fsyntax-only -x c++ path/to/header.h

# Check formatting without modifying files
clang-format --dry-run --Werror path/to/file.c
clang-format --dry-run --Werror path/to/file.cpp
```

## Docker post-install

The installer adds the current user to the `docker` group. Apply that group
membership by logging out and back in, or use:

```bash
newgrp docker
docker run --rm hello-world
```

Adding a user to the Docker group grants root-equivalent access to the host.
Only do this on a machine where that trust level is acceptable.

## Notes

- `apt` package versions depend on the Ubuntu/Debian release.
- `verilator`, `rustc`, and Python packages from distribution repositories may
  be older than upstream releases; the script uses `pip` and `rustup` where
  current upstream tooling is more useful.
- For reproducible projects, pin Python package versions in a requirements
  file and pin Rust versions with `rust-toolchain.toml`.
- The script intentionally does not add third-party apt repositories or run
  unverified installation scripts beyond the official Rust `rustup` installer.
