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
  * In Linux : `./config/alacritty/alacritty.toml`

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

# Installing Font via Shell
----
1. Download NerdFonts
2. Extract
3. Put the font in usr/.local/share/fonts
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
