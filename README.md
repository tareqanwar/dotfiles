# dotfiles-win
My ~~Bash~~ Zsh on Ubuntu on Windows configuration files. (See my arch linux configuration files [here](https://github.com/jieverson/dotfiles))

> Windows 10 can now officially run native Ubuntu subsystem. Its default settings comes with Bash, but it's possible to install different shells (my settings are using Zsh). If you need to learn how to install Ubuntu on Windows, take a look at this [Microsoft Guide](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide).

### usage
Just run `install.sh` to install zsh (including oh-my-zsh and other important stuff) and symlink all dotfiles.

```
$ git clone https://github.com/trqnwr/dotfiles.git ~/.dotfiles
$ sudo ~/.dotfiles/install.sh
```

To keep up to date, you can just `pull` this repo, and re-run `install.sh`.

### screenshots
<p align="center">
  <img src="screenshots/screenfetch.png" />
</p>
<p align="center">
  <img src="screenshots/fun.png" />
</p>
<p align="center">
  <img src="screenshots/midia.png" />
</p>
<p align="center">
  <img src="screenshots/working.png" />
</p>
<p align="center">
  <img src="screenshots/lol.gif" />
</p>


### About My Terminal Emulator

As you can see at screenshots, I'm not using Windows default console emulator.
I'm using [Hyper](https://hyper.is). It's a customizable Terminal Emulator built in js. 
To use my settings, just copy [.hyper.js](https://rawgit.com/jieverson/dotfiles-win/master/.hyper.js) to your Windows home directory
