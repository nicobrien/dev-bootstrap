# Developer workstation bootstrap

Ansible provisions the workstation once. After that, each application is
maintained independently using the upgrade approach described below. Versions
in `packages.yml` describe the initial installation and may differ from the
versions currently installed.

Configuration files remain in `dotfiles/` here, with symlinks from their usual
locations. Edit those files directly for ongoing configuration changes. Keep
this directory while those links are in use. The original installer bundle can
be discarded after installation.

## Go

### Where it lives

| Detail          | Go                                                            |
| ---             | ---                                                           |
| Install method  | Official Linux amd64 archive                                  |
| Initial version | `1.27.3`, pinned with its checksum in `packages.yml`          |
| Installation    | `/opt/dev-bootstrap/go-<version>/go/`                         |
| Stable symlink  | `/usr/local/go`                                               |
| Executable      | `/usr/local/go/bin/go`                                        |
| Download cache  | `~/.cache/dev-bootstrap/go-1.27.3.tar.gz`                     |
| Shell setup     | Adds `/usr/local/go/bin` and `~/go/bin` to PATH in `~/.zshrc` |
| User data       | `~/go` by default, preserved across Go upgrades               |

### How to upgrade

1. Download the required release's **Linux amd64** archive from the
   [official Go downloads page](https://go.dev/dl/). Verify the downloaded
   archive against the SHA-256 checksum published there. Run these commands
   from the download directory, setting the version and published checksum:

   ```sh
   go_release=1.27.3 # Replace with the version you downloaded.
   echo '<sha> <filename>' | sha256sum --check -
   ```

2. Create a fresh installation directory and extract the archive. Run these
   commands in the same shell:

   ```sh
   sudo mkdir "/opt/dev-bootstrap/go-$go_release"
   sudo tar -xzf "go$go_release.linux-amd64.tar.gz" \
     -C "/opt/dev-bootstrap/go-$go_release"
   ```

3. With sudo, point `/usr/local/go` at the new installation's `go/` directory.

   ```sh
   sudo ln -sfn "/opt/dev-bootstrap/go-$go_release/go" /usr/local/go
   ```

## Neovim

### Where it lives

| Detail          | Neovim                                                 |
| ---             | ---                                                    |
| Install method  | Official Linux x86_64 archive                          |
| Initial version | `0.12.4`                                               |
| Installation    | `/opt/dev-bootstrap/nvim-<version>/nvim-linux-x86_64/` |
| Stable symlink  | `/usr/local/bin/nvim`                                  |
| Configuration   | `~/.config/nvim` links to `dotfiles/nvim` here         |
| User data       | `~/.local/share/nvim`                                  |

### How to upgrade

1. Download `nvim-linux-x86_64.tar.gz` from the
   [Neovim releases](https://github.com/neovim/neovim/releases) page and verify
   its published checksum.
2. From the download directory, extract it into a new installation directory:

   ```sh
   nvim_release=0.12.4 # Replace with the version you downloaded.
   sudo mkdir "/opt/dev-bootstrap/nvim-$nvim_release"
   sudo tar -xzf nvim-linux-x86_64.tar.gz \
     -C "/opt/dev-bootstrap/nvim-$nvim_release"
   ```

3. Point the executable symlink at the new installation:

   ```sh
   sudo ln -sfn \
     "/opt/dev-bootstrap/nvim-$nvim_release/nvim-linux-x86_64/bin/nvim" \
     /usr/local/bin/nvim
   ```

Update plugins separately inside Neovim with `:lua vim.pack.update()`.
Use `:Mason` to manage installed language servers and formatting tools.

## Rust and Cargo

### Where it lives

| Detail          | Rust and Cargo                                                 |
| ---             | ---                                                            |
| Install method  | rustup                                                         |
| Initial channel | `stable`                                                       |
| Installation    | `~/.rustup/toolchains/`                                        |
| Executables     | `~/.cargo/bin/rustc` and `~/.cargo/bin/cargo`                  |
| User data       | `~/.cargo`, including downloaded crates and installed commands |

Paths use `RUSTUP_HOME` and `CARGO_HOME` if those are set.

### How to upgrade

Update the stable toolchain using [rustup](https://rust-lang.org/install):

```sh
rustup update stable
```

## rustup

### Where it lives

| Detail          | rustup                         |
| ---             | ---                            |
| Install method  | Official rustup-init installer |
| Initial version | `1.29.1`                       |
| Executable      | `~/.cargo/bin/rustup`          |
| Configuration   | `~/.rustup/settings.toml`      |

### How to upgrade

The bootstrap disables automatic self-updates. Update rustup explicitly:

```sh
rustup self update
```

## tree-sitter CLI

### Where it lives

| Detail          | tree-sitter CLI                          |
| ---             | ---                                      |
| Install method  | `cargo install tree-sitter-cli --locked` |
| Initial version | Latest available at installation time    |
| Executable      | `~/.cargo/bin/tree-sitter`               |
| Used by         | Neovim's tree-sitter parser tooling      |

### How to upgrade

[Cargo install](https://doc.rust-lang.org/cargo/commands/cargo-install.html)
also upgrades installed commands:

```sh
cargo install tree-sitter-cli --locked
```

## nvm

### Where it lives

| Detail          | nvm                                |
| ---             | ---                                |
| Install method  | Git checkout of a release tag      |
| Initial version | `v0.40.8`                          |
| Installation    | `~/.nvm`                           |
| Shell setup     | `~/.zshrc` sources `~/.nvm/nvm.sh` |

### How to upgrade

Choose a tag from the [nvm releases](https://github.com/nvm-sh/nvm/releases):

```sh
nvm_release=v0.40.8 # Replace with the target release.
git -C "$HOME/.nvm" fetch --tags origin
git -C "$HOME/.nvm" checkout "$nvm_release"
. "$HOME/.nvm/nvm.sh"
```

## Node.js and npm

### Where it lives

| Detail              | Node.js and npm                               |
| ---                 | ---                                           |
| Install method      | nvm, with npm bundled with Node.js            |
| Initial version     | Node.js `24.22.1`                             |
| Installation        | `~/.nvm/versions/node/v<version>/`            |
| Default selection   | `~/.nvm/alias/default`                        |
| Global npm packages | Installed separately for each Node.js version |

### How to upgrade

Install the target release and make it the default for new shells:

```sh
node_release=24.22.1 # Replace with the target release.
nvm install "$node_release" --reinstall-packages-from=current
nvm alias default "$node_release"
nvm use "$node_release"
```

## pnpm

### Where it lives

| Detail          | pnpm                                                   |
| ---             | ---                                                    |
| Install method  | Global npm package in the selected nvm Node.js version |
| Initial version | `12.16.1`                                              |
| Executable      | `~/.nvm/versions/node/v<version>/bin/pnpm`             |

### How to upgrade

Select the intended Node.js version, then update
[pnpm through npm](https://pnpm.io/installation):

```sh
nvm use default
npm install --global pnpm@latest
```

## Oh My Zsh

### Where it lives

| Detail         | Oh My Zsh                                                |
| ---            | ---                                                      |
| Install method | Git checkout of `master`                                 |
| Installation   | `~/.oh-my-zsh`                                           |
| Configuration  | `~/.zshrc` and `~/.zshenv` link into `dotfiles/zsh` here |

### How to upgrade

Run the [Oh My Zsh updater](https://github.com/ohmyzsh/ohmyzsh#updates)
from an interactive Zsh shell:

```sh
omz update
```

## Powerlevel10k

### Where it lives

| Detail         | Powerlevel10k                                        |
| ---            | ---                                                  |
| Install method | Git checkout of `master`                             |
| Installation   | `~/.oh-my-zsh/custom/themes/powerlevel10k`           |
| Configuration  | `~/.p10k.zsh` links to `dotfiles/zsh/.p10k.zsh` here |

### How to upgrade

Pull updates from the
[theme repository](https://github.com/romkatv/powerlevel10k#how-do-i-update):

```sh
git -C "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" pull --ff-only
```

Open a new shell to load the updated theme.

## Docker

### Where it lives

| Detail         | Docker                                                       |
| ---            | ---                                                          |
| Install method | apt from Docker's stable repository                          |
| Packages       | `docker-ce`, `docker-buildx-plugin`, `docker-compose-plugin` |
| Executable     | `/usr/bin/docker`                                            |
| Repository     | `/etc/apt/sources.list.d/dev-bootstrap-docker.list`          |
| User data      | `/var/lib/docker` by default                                 |

### How to upgrade

```sh
sudo apt update
sudo apt install --only-upgrade \
  docker-ce docker-buildx-plugin docker-compose-plugin
```

## .NET SDK

### Where it lives

| Detail          | .NET SDK                                           |
| ---             | ---                                                |
| Install method  | apt, with repository selected for the distribution |
| Initial package | `dotnet-sdk-10.0`                                  |
| Executable      | `/usr/bin/dotnet`                                  |
| User data       | `~/.dotnet` and `~/.nuget/packages`                |

The bootstrap uses Ubuntu's .NET backports PPA on Jammy and Noble, Microsoft's
repository on Debian, and distribution packages on other supported releases.

### How to upgrade

Update the installed SDK series:

```sh
sudo apt update
sudo apt install --only-upgrade dotnet-sdk-10.0
```

For a new major SDK, install its `dotnet-sdk-<major>.0` package alongside the
existing SDK. A project's `global.json` can select a specific SDK version.

## kubectl

### Where it lives

| Detail          | kubectl                                                 |
| ---             | ---                                                     |
| Install method  | apt from Kubernetes' per-minor repository               |
| Initial channel | `v1.37`                                                 |
| Executable      | `/usr/bin/kubectl`                                      |
| Repository      | `/etc/apt/sources.list.d/dev-bootstrap-kubernetes.list` |
| Configuration   | `~/.kube/config`, unless `KUBECONFIG` is set            |

### How to upgrade

Update within the configured minor release:

```sh
sudo apt update
sudo apt install --only-upgrade kubectl
```

For another minor release, follow the [repository instructions][kubectl-apt].
Update the minor version in the repository file above and install its signing
key before running the commands again. Keep kubectl within one minor version
of the API server.

[kubectl-apt]: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

