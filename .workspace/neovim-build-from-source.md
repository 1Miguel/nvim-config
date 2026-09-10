# Build Neovim from Source

## 1. Install dependencies

On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake ninja-build gettext libtool libtool-bin autoconf automake pkg-config unzip curl
```

If the build later complains about missing libraries, add:

```bash
sudo apt-get install -y libuv1-dev libluajit-5.1-dev libvterm-dev libmsgpack-dev libtermkey-dev libunibilium-dev libutf8proc-dev liblua5.3-dev
```

## 2. Clone the source

```bash
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout stable
```

You can also use a release tag instead of `stable`:

```bash
git checkout v0.10.4
```

## 3. Build with make

```bash
make CMAKE_BUILD_TYPE=Release
```

Or build in parallel:

```bash
make -j"$(nproc)"
```

## 4. Install

```bash
sudo make install
```

## 5. Verify

```bash
nvim --version
```

## Alternative: build with CMake + Ninja

```bash
mkdir -p build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
ninja
sudo ninja install
```

## Notes

- `stable` gives the latest stable release branch.
- Use a release tag if you want reproducibility.
- If you are on Arch/Fedora, use the equivalent package manager commands instead of `apt-get`.
