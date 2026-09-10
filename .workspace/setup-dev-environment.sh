#!/usr/bin/env bash
#
# Debian/Ubuntu developer workstation setup.
# Run as the normal user, not as root:
#   chmod +x setup-dev-environment.sh
#   ./setup-dev-environment.sh
#
# The script is intentionally idempotent. It may be re-run after an interrupted
# installation.

set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

if [[ "${EUID}" -eq 0 ]]; then
  echo "Run this script as your normal user; it will use sudo when required." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required." >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This script supports Debian/Ubuntu systems with apt-get." >&2
  exit 1
fi

readonly DEV_DIR="${HOME}/dev"
readonly BUILD_DIR="${DEV_DIR}/src"
readonly OPT_DIR="${HOME}/.local/opt"
readonly BIN_DIR="${HOME}/.local/bin"
readonly VENV_DIR="${HOME}/.venvs/zephyr"

mkdir -p "${DEV_DIR}" "${BUILD_DIR}" "${OPT_DIR}" "${BIN_DIR}"

sudo dpkg --configure -a
sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get install -y \
  apt-transport-https \
  autoconf automake autotools-dev \
  bc bison build-essential \
  ca-certificates ccache clang clang-format clang-tidy cmake \
  curl device-tree-compiler flex g++ gcc gcc-multilib \
  gcc-arm-none-eabi gcc-aarch64-linux-gnu gdb gdb-multiarch \
  gettext git git-lfs \
  libarchive-tools libasound2-dev libboost-all-dev libbz2-dev \
  libc6-dev-i386 libclang-dev libcurl4-openssl-dev libffi-dev \
  libfdt-dev libfontconfig1-dev libfreetype6-dev libglib2.0-dev \
  libgtk-3-dev liblzma-dev libncurses-dev libpixman-1-dev \
  libreadline-dev libssl-dev libtool libusb-1.0-0-dev libx11-xcb-dev \
  linux-headers-generic make meson ninja-build pkg-config \
  python3 python3-dev python3-pip python3-venv \
  qemu-system-arm qemu-system-x86 qemu-user \
  rsync software-properties-common unzip uuid-dev \
  wget xz-utils zlib1g-dev zsh tmux openocd \
  gtkwave podman

if apt-cache show "linux-headers-$(uname -r)" >/dev/null 2>&1; then
  sudo apt-get install -y "linux-headers-$(uname -r)"
fi

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if ! command -v rustc >/dev/null 2>&1 || ! command -v cargo >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --profile default
  # shellcheck disable=SC1091
  source "${HOME}/.cargo/env"
fi

export PATH="${HOME}/.cargo/bin:${BIN_DIR}:${PATH}"

if ! command -v alacritty >/dev/null 2>&1; then
  sudo apt-get install -y alacritty || cargo install --locked alacritty
fi

if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ "$(getent passwd "${USER}" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
fi

if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
else
  git -C "${HOME}/.tmux/plugins/tpm" pull --ff-only
fi

if ! command -v nvim >/dev/null 2>&1; then
  if [[ ! -d "${BUILD_DIR}/neovim" ]]; then
    git clone --depth 1 https://github.com/neovim/neovim.git "${BUILD_DIR}/neovim"
  else
    git -C "${BUILD_DIR}/neovim" pull --ff-only
  fi
  cmake -S "${BUILD_DIR}/neovim" -B "${BUILD_DIR}/neovim/build" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${HOME}/.local"
  cmake --build "${BUILD_DIR}/neovim/build" --parallel
  cmake --install "${BUILD_DIR}/neovim/build"
fi

if ! command -v docker >/dev/null 2>&1; then
  sudo apt-get install -y docker.io
  if apt-cache show docker-compose-plugin >/dev/null 2>&1; then
    sudo apt-get install -y docker-compose-plugin
  fi
  sudo systemctl enable --now docker
  sudo usermod -aG docker "${USER}"
fi

if ! command -v verilator >/dev/null 2>&1; then
  if [[ ! -d "${BUILD_DIR}/verilator" ]]; then
    git clone --depth 1 https://github.com/verilator/verilator.git "${BUILD_DIR}/verilator"
  else
    git -C "${BUILD_DIR}/verilator" pull --ff-only
  fi
  (
    cd "${BUILD_DIR}/verilator"
    autoconf
    ./configure --prefix="${HOME}/.local"
    make -j"$(nproc)"
    make install
  )
fi

if ! command -v renode >/dev/null 2>&1; then
  if command -v snap >/dev/null 2>&1; then
    sudo snap install renode --edge
  else
    renode_asset="$(
      curl -fsSL https://api.github.com/repos/renode/renode/releases/latest |
        python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((a["browser_download_url"] for a in d["assets"] if "linux-portable" in a["name"] and a["name"].endswith(".tar.gz")), ""))'
    )"
    if [[ -z "${renode_asset}" ]]; then
      echo "Could not find a Renode Linux release asset." >&2
      exit 1
    fi
    rm -rf "${OPT_DIR}/renode"
    mkdir -p "${OPT_DIR}/renode"
    curl -fL "${renode_asset}" | tar -xz -C "${OPT_DIR}/renode" --strip-components=1
    ln -sf "${OPT_DIR}/renode/renode" "${BIN_DIR}/renode"
  fi
fi

if ! command -v tree-sitter >/dev/null 2>&1; then
  cargo install --locked tree-sitter-cli
fi

if [[ ! -d "${HOME}/uvm" ]]; then
  git clone https://github.com/accellera-official/uvm.git "${HOME}/uvm"
else
  git -C "${HOME}/uvm" pull --ff-only
fi

if ! command -v drawio >/dev/null 2>&1 && ! command -v draw.io >/dev/null 2>&1; then
  drawio_asset="$(
    curl -fsSL https://api.github.com/repos/jgraph/drawio-desktop/releases/latest |
      python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((a["browser_download_url"] for a in d["assets"] if a["name"].endswith(".deb") and "amd64" in a["name"]), ""))'
  )"
  if [[ -z "${drawio_asset}" ]]; then
    echo "Could not find a Draw.io Debian release asset." >&2
    exit 1
  fi
  curl -fL "${drawio_asset}" -o /tmp/drawio.deb
  sudo apt-get install -y /tmp/drawio.deb
  rm -f /tmp/drawio.deb
fi

if command -v docker >/dev/null 2>&1; then
  sudo docker pull openroad/orfs
fi

if [[ ! -x "${VENV_DIR}/bin/python" ]]; then
  uv venv --python 3 "${VENV_DIR}"
fi

if [[ ! -d "${HOME}/zephyrproject" ]]; then
  # shellcheck disable=SC1091
  source "${VENV_DIR}/bin/activate"
  uv pip install west
  west init -m https://github.com/zephyrproject-rtos/zephyr.git "${HOME}/zephyrproject"
else
  # shellcheck disable=SC1091
  source "${VENV_DIR}/bin/activate"
  uv pip install west
  (
    cd "${HOME}/zephyrproject"
    west update
  )
fi

(
  cd "${HOME}/zephyrproject"
  west update
  west zephyr-export
  uv pip install -r zephyr/scripts/requirements.txt
)

echo
echo "Development environment setup complete."
echo "If Docker was newly installed, log out and back in for group membership to apply."
echo "Restart your shell or run: source ~/.cargo/env"
