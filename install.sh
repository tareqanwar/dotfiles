echo "apt update..."
sudo apt -y update
echo "✔ update done!"

sudo apt -y install curl zsh git
echo "✔ to make sure base packeges are installed"

ln -sf $(pwd)/.dotfiles//bashrc ~/.bashrc
echo "✔ zsh as default shell"

# Run ZSH Automatically
chsh -s /usr/bin/zsh

# install oh-my-zsh
[ -d ~/.oh-my-zsh ] || git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
[ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
echo "✔ oh my zsh configured!"

ln -sf ~/.dotfiles/zshrc ~/.zshrc
echo "✔ .zshrc symlinked"

ln -sf ~/.dotfiles/gitconfig ~/.gitconfig
echo "✔ .gitconfig symlinked"

mkdir -p ~/.config

sudo apt -y install nodejs
sudo apt -y install npm
sudo npm install -g nodemon
echo "✔ installed nodejs, npm, nodemon"

sudo apt install -y software-properties-common
echo "✔ installed install software-properties-common to be able to add external repo"

sudo apt -y install mongodb
echo "✔ installed mongodb"

