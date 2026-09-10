make me a single shell file that 

1. make a $HOME/dev directory
1. sudo apt upgrade and install basic c developer tool requirements i.e:
  * git
  * python3
  * linux-headers
  * build-essentials
  * ... all other c/c++ dev requirements
3. make sure gcc is install also install
  * gcc-arm
  * aarch64 (for compiling cortex-a)
  * gdb
  * openocd
  * qemu
  * renode
4. install zsh + ohmyzsh
5. then make zsh default shell file
6. install alacritty
7. if rust is not install, install latest rustc compiler
8. ...
9. install tree-sitter-cli via cargo (cargo install --locked tree-sitter-cli)
10. check if tmux is installed, if not then install tmux then install tpm (git pull)
11. check if neovim is installed, if not then install neovim from source (git)
12. check if docker is installed, if not make sure to install it
13. check if verilator is installed, if not then install from git source
14. install gtkwaveform
15. install UVM, git clone it to $HOME
16. docker pull openroad/orfs
17. install latest zephyr
