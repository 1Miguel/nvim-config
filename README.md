# Cloning This Repo
This is a Neovim configuration. Clone it to `~/.config/nvim`:
```bash
git clone git@github.com:1Miguel/nvim-config.git "$HOME/.config/nvim"
```

# TMUX setup
----
## Installation
• Ubuntu / Debian Run
```bash
sudo apt install tmux
```
• Fedora: Run 
```bash
sudo dnf install tmux
```
• Arch Linux: Run 
```bash
sudo pacman -S tmux
```
• RHEL / CentOS: Run 
```bash
sudo yum install tmux
```

# Copy all config files to appropriate location
``` bash
cp .tmux.conf $HOME
```

## Install Package Manager
1. Clone TPM
``` bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
2. Either restart `tmux` by killing the server and rerun `tmux`
``` bash
tmux kill-server
```
or in existing `tmux` session, run
```
tmux source ~/.tmux.conf
```
then install plugins via `<Ctlr-B> + I`

# Alacritty Setup
-----
## Installation
* Using Winget:
```bash
  powershell winget install -e --id Alacritty.Alacritty   
```
* You can also download the installer (.msi or .exe) directly from the [Alacritty GitHub Releases page.](https://github.com/alacritty/alacritty/releases)

## Configuring
Copy [alacritty.toml](./alacritty.toml)
  * In Windows : `%APPDATA%/alacritty/alacritty.toml`
  * In Linux : `~/.config/alacritty/alacritty.toml`

# ZSH setup
-----

## Installation
In `Ubuntu`
```bash
sudo apt install zsh
```

## Oh-my-zsh installation
* Using wget
  ```bash
  sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
  ```

* Using curl:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Then test by running
``` bash
zsh
```

## Installing powerlevel10k
1. Clone powerlevel10k
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

[!NOTE] .zshrc
> At this point you could either copy the .zshrc to home and souce install
> ```bash
>   cp .zshrc $HOME
>   source .zshrc
> ```
> or do the step below

2. Then trigger p10klevel configuraton via
``` bash
p10k configure
```

# Neovim Setup
----
1. Install latest rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
2. After installation finish
``` bash
source "$HOME/.cargo/env"
```
3. Verify via:
```bash
rustc --version
cargo --version
```
4. Install latest tree-sitter
```bash
cargo install tree-sitter-cli --locked
```

## Build from source
1. Install dependencies
```bash
sudo apt update
sudo apt install build-essential cmake curl gettext ninja-build git \
  libtool libtool-bin autoconf automake pkg-config unzip
```
2. Clone source code
``` bash
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout stable
```
3. Build and compile
```bash
make CMAKE_BUILD_TYPE=RelWithDebInfo
```
4. Then install
```bash
sudo make install
```
5. Validate
```bash
nvim --version
nvim -c checkhealth
```

# Installing Font via Shell
----
1. Download NerdFonts
2. Extract
3. Put the font in `~/.local/share/fonts`
4. Rebuild font cache by running fc-cache -f -v

## Example
```bash
wget -P ~/.local/share/fonts/ https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/RobotoMono.zip \
&& cd ~/.local/share/fonts/ \
&& unzip RobotoMono.zip \
&& rm RobotoMono.zip \
&& fc-cache -fv \
&& cd -
```

# nvim-tree tips
1. <C-T> points tree to parent dir
2. <C-]> points tree to child dir

# LSP tips
1. When running python venv, make sure to run venv first before running nvim.
