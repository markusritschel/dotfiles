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

### Linking only, without side effects

`install.sh` also runs the `shell:` section of `install.conf.yaml`, which is *not*
idempotent in the harmless sense: it wipes and re-clones the tmux plugin manager
(`rm -r ~/.tmux/plugins/tpm`) and asks for `sudo` to symlink the Docker daemon config.
When you only added or changed a link entry, skip all of that:

```bash
cd ~/.dotfiles
./.dotbot/bin/dotbot -c install.conf.yaml         --only link   # public
./.dotbot/bin/dotbot -c private/install.conf.yaml --only link   # private
```

Note that `--only link` also skips the `clean:` directive, so dead symlinks from
removed entries are not pruned — run the full `./install.sh` for that.


## Notes
- `bootstrap.sh` is safe to re-run — package managers skip already-installed packages.
- Private dotfiles (SSH config, autofs mounts) live in `private/`, which is gitignored in this repo.
- `autofs` config files are symlinked into `/etc` via `sudo` in the private Dotbot config.
- Sensitive files like KeePassXC's `.kdbx` database files should **never** be stored in any repository!
