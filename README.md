# My Dotfiles

These are my personal dotfiles managed with [Dotbot](https://github.com/anishathalye/dotbot).


## Structure

```yaml
dotfiles/
├── bootstrap.sh          # Full setup for a new machine
├── install.sh            # Day-to-day: re-link dotfiles only
├── install.conf.yaml     # Dotbot config (public)
├── .dotbot/              # Dotbot submodule
:
├── packages/
│   ├── apt.sh
│   └── pacman.sh
└── private/              # dotfiles-private repo (gitignored)
    :
    └── install.conf.yaml
```

## On a fresh machine
Make sure you have `git` and `python` installed.

First clone the repository to your local machine
```bash
git clone --recurse-submodules https://github.com/markusritschel/dotfiles ~/.dotfiles
```
<!-- Use the `--recursive` flag to ensure all submodules are included: -->

Inside the `.dotfiles/`  directory you may clone a repository with private dotfiles into `private/`.


Then , link all the dotfiles to their determined location, specified in `install.conf.yaml` by running
```bash
./install.sh
```
inside `~/.dotfiles/`.

## Day-to-day Usage

To re-link dotfiles after making changes (without reinstalling packages):
```bash
cd ~/.dotfiles && ./install.sh
```


## Notes
- `bootstrap.sh` is safe to re-run — package managers skip already-installed packages.
- Private dotfiles (SSH config, autofs mounts) live in `private/`, which is gitignored in this repo.
- `autofs` config files are symlinked into `/etc` via `sudo` in the private Dotbot config.
- Sensitive files like KeePassXC's `.kdbx` database files should **never** be stored in any repository!
