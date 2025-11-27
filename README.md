# ccd

customized cd

## Features

- change directory from selected by fzf
- do not change basic cd behavior
- cd to specific subdirs
- allow file path
- accept stdin
- cd to parent directories
- cd to histories directories

## Requirements

- bash (4.2+) or zsh
- fzf (or other fuzzy finder)

## Usage

```
ccd /path/to/dir/.                select from subdirs
ccd /path/to/dir/..               select from subdirs (recursive)
ccd /path/to/dir/file             cd to /path/to/dir
find /path/to/dir/ -type d | ccd  select from stdin
ccd ...                           select from parent directories
ccd --                            select from histories
```

## Configuration

$CCD_FINDER set fuzzy finder (default fzf).

## Installation

### bash

```
$ git clone https://github.com/yosugi/ccd.zsh.git ~/.local/share/ccd
$ echo '[ -f ~/.local/share/ccd/ccd.sh ] && source ~/.local/share/ccd/ccd.sh' >> ~/.bashrc
$ exec $SHELL -l
```

### zsh

```
$ git clone https://github.com/yosugi/ccd.zsh.git ~/.local/share/ccd
$ echo '[ -f ~/.local/share/ccd/ccd.sh ] && source ~/.local/share/ccd/ccd.sh && setopt AUTO_PUSHD' >> ~/.zshrc
$ exec $SHELL -l
```

## License

MIT License

## Version

0.2.0
