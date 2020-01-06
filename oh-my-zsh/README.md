# Oh My Zsh

### Basic Installation

#### via curl

```shell
curl -fsSL https://raw.githubusercontent.com/baileywickham/oh-my-zsh/master/tools/install.sh
./install.sh --all
```

Options:
- --unattended : do not change shell 
- --all : change shell


## Using Oh My Zsh

### Info

[plugins](https://github.com/baileywickham/oh-my-zsh/tree/master/plugins) 
[wiki](https://github.com/baileywickham/oh-my-zsh/wiki/Plugins)

#### Enabling Plugins
```shell
plugins=(
  git
  bundler
  dotenv
  osx
  rake
  rbenv
  ruby
)
```

_Note that the plugins are separated by whitespace. **Do not** use commas between them._

#### Using Plugins

Most plugins (should! we're working on this) include a __README__, which documents how to use them.

### Themes

_Note: many themes require installing the [Powerline Fonts](https://github.com/powerline/fonts) in order to render properly._


## License

Oh My Zsh is released under the [MIT license](LICENSE.txt).

