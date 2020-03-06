# SySy - System Synchronization scripts

This is a set of scripts for synchronizing configuration, dotfiles, and packages between systems. Its main advantage over other similar programs is its focus on tags.

Each machine requires a `$HOME/sysy.d/tags` file with a tag per line for the current machine. Each tag corresponds to a folder of the same name in a folder `$SYSYPATH/tags` (when `$SYSYPATH` is the cloned `sysy` repository).

Each tag then has a subfolder for system configuration, dotfiles, and packages, which is used by the corresponding script (see below) prioritized by the order of appearance in the `tags` file (later tags have higher priority).

The most important subcommand for each script is `sync` to check for unsynced files/folders/packages and sync if needed.

## Configuration Sync (`cosy` script, `system` subfolder)

System configuration in the `system` subfolder is relative to the filesystem root path and files are synced by content (no links), e.g. `$SYSYPATH/tags/main/system/etc/rc.local` will be synced to `/etc/rc.local`). If the executable bit is set on a file to sync so will it for the corresponding file on the system.

See the `cosy` command for information on parameters.

## Dotfile Sync (`dosy` script, `dotfiles` subfolder)

Dotfiles in the `dotfiles` subfolder are relative to the user homer folder and are synced as symlinks (with the files to sync missing the "." prefix), e.g. `$HOME/.profile` will be linked to `$SYSYPATH/tags/main/dotfiles/profile`. Subfolders can be marked to be synced by content, i.e. each file/folder inside them is symlinked instead of the whole folder, by creating an (empty) `.sub` file in the folder to sync, e.g. `$SYSYPATH/tags/main/dotfiles/config/.sub`.

See the `dosy` command for information on parameters.

## Package Sync (`pasy` script, `packages` subfolder)

The `pasy` script makes sure packages are installed on the synced system. Currently it supports the package managers:

- `apt` (Debian, Ubuntu, and similar distributions)
- `cabal` (Haskell)
- `cargo` (Rust)
- `go` (Go)
- `npm` (JavaScript)
- `pip` (Python)

You, for instance, mark package `git` as to-be-installed for tag `main` by running `pasy install apt main git`.

See the `pasy` command for information on parameters.

## Overall Sync (`sysy` script)

The `sysy` script is an overarching script, for instance, syncing all three categories when running `sysy sync`.

**TODO** Documentation on bootstrapping, repository, and server syncing.
