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

ln -sf $(pwd)/.dotfiles//zshrc ~/.zshrc
echo "✔ .zshrc symlinked"

ln -sf $(pwd)/.dotfiles//gitconfig ~/.gitconfig
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

echo "✔ staring lamp stack installation"

sudo apt install -y apache2 apache2-utils
echo "✔ apache installed"

sudo chown www-data:www-data /var/www/html/ -R
echo "✔ changed owner of the html folder to www-data"

sudo apt install -y mariadb-server mariadb-client
echo "✔ mariadb installed. we will install mysql setting later"

sudo apt install apt-transport-https lsb-release ca-certificates
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sudo sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
sudo apt update && apt upgrade
sudo apt install -y php7.2
sudo apt install -y php-pear php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml
echo "✔ php installed"

sudo a2enmod php7.2

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
echo "✔ installed composer"

sudo mysql_secure_installation
mariadb --version
echo "✔ mysql installation successful"

sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl start apache2
sudo systemctl enable apache2
echo "✔ started apache and mariadb"
