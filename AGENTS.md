# AGENTS.md — Kamil Cukrowski's dotfiles & scripts repo

Personal dotfiles, bash scripts, Neovim config, and Arch Linux packaging.

## Repo layout

| Dir         | Contents                                                |
|-------------|----------------------------------------------------------|
| `bin/`      | ~210 bash/python scripts — the bulk of the repo        |
| `nvim/`     | AstroNvim-based config (Lua), managed by lazy.nvim     |
| `vim/`      | Legacy Vim config (vimrc, plugins, syntax, ftdetect)   |
| `chezmoi/`  | Chezmoi dotfile source (applied via `provision.sh`)    |
| `dotfiles/` | Raw dotfile symlinks / stow targets                    |
| `etc/`      | System config: bash.d, profile.d, pacman.d, terminfo   |
| `pkg/`      | Arch Linux packaging (PKGBUILD, docker_build)          |
| `awk/`      | Awk utility scripts                                      |
| `python/`   | Python utility scripts                                   |
| `provision.sh` | Entry point — installs chezmoi and runs `chezmoi apply` |

## Bash script conventions

- **Comma-prefix naming**: scripts that are meant to be on PATH use a leading comma (e.g. `bin/,hextodectobin`, `bin/,lib_lib`, `bin/,ccrun`) to avoid collisions with system tools. Scripts without a prefix (e.g. `blockinfile.sh`, `alias_complete.sh`) are typically sourced libraries or wrappers.
- **Shared library**: scripts source `,lib_lib` for common utilities: `. ,lib_lib -q` (quiet/load-only) or `. ,lib_lib -L <prefix>` (drop `L_` prefix). The library file is at `bin/,lib_lib`.
- **Test modes differ per script**: `--unittest` (most bash), `--test` (some bash), `+unittest` (`,lib_lib` and `,ccrun`).
- **Shellcheck is the only linter** (`.shellcheckrc` at repo root: `source-path=bin`, `external-sources=true`, disables SC1090/SC2001).
- **Always `set -euo pipefail`** at the top of bash scripts.

## Running tests locally

There's no Makefile or task runner. Tests are individual script invocations:

```bash
# Run a single script's tests
bin/,hextodectobin --test
bin/,lib_lib --test       # or: bin/,lib_lib +unittest
bin/,ccrun +unittest
bin/alias_complete.sh --unittest
bin/blockinfile.sh --unittest
bin/,fnmatch --test

# Full shellcheck pass (mirrors CI)
find . '(' -path './.git' -o -path './notes' ')' -prune -o \
    -type f ! -name '=template=*' \
    -exec awk '/^#!.*sh/{print FILENAME};{nextfile}' {} + |
    tr '\n' '\0' | xargs -0t -P$(nproc) -n20 shellcheck -x
```

## CI: GitLab CI (`.gitlab-ci.yml`)

- **Docker image**: all jobs use `$CI_REGISTRY_IMAGE:latest` (built from `Dockerfile`).
- **`shellcheck` job**: `allow_failure: true`; scans every file with a bash shebang.
- **Test jobs**: each script has a dedicated `test_*` job, e.g. `test_hextodectobin`, `test_lib_lib`, `test_ccrun`.
- **`build` job**: builds the Arch package via kaniko (`Dockerfile` + `pkg/archlinux/PKGBUILD`).
- **`pages` job**: runs only on `master`; builds the Arch repo and generates an HTML index.
- **No local test runner** — tests must be run manually as shown above.

## Arch Linux packaging (`pkg/archlinux/`)

- `PKGBUILD` derives `pkgver` from `git describe --tags`.
- `post_install` / `post_upgrade` / `pre_remove` hooks in `kamilscripts.install`.
- Scripts are symlinked into `/usr/lib/kamilscripts/` on install.
- The repo is cloned to `/usr/lib/kamilscripts` on install; `kamil_edit.sh` is a dev helper for editing in-place after install.

## Neovim config

- **AstroNvim v6** — `nvim/lazy_setup.lua` sets up `lazy.nvim` and imports AstroNvim with custom `mapleader` = `<Space>`, `maplocalleader` = `,`.
- **Plugin specs** live in `lua/plugins.lua` (main), `lua/plugins_home.lua` (home-only, disabled for user `cukrowsk`), `lua/disabled_plugins.lua` (disabled), and `lua/local.lua` (personal override — e.g. Rust).
- **Which-key** is not explicitly configured; it comes from AstroNvim defaults. References to `which-key` only appear in disabled plugin configs.
- **Lua formatting**: `nvim/.stylua.toml` — 2-space indent, 120 col, double quotes, no call parentheses, `Always` collapse. Run `stylua` to format.
- **LSPs**: managed via AstroNvim/`astrolsp`. Auto-installation is disabled (`mason-nvim-lspconfig` with `automatic_installation = false`). Manual install needed for new LSPs.
- **Lazy health check**: run `:Lazy` to check plugin status. `:checkhealth` for diagnostics.
- Key user command: `:KcInstall` — bootstraps lazy.nvim if missing.

## Chezmoi / dotfiles provisioning

- Run `./provision.sh -k` to actually apply (dry-run by default).
- Dry-run mode (`-n` passed to chezmoi) is the default — **add `-k` or `--ok` to make changes**.
- `provision.sh` auto-installs chezmoi via `pacman` (Arch) or the official installer script.
- `autocommit.sh` is a quick-and-dirty git auto-commit helper (`git pull --rebase`, commit all, push).

## Git workflow

- Primary remote: `git@gitlab.com:Kamcuk/kamilscripts.git` (mirrored to GitHub `kamilcuk/kamilscripts`).
- `gitmodules_links_change.sh` toggles `.gitmodules` URLs between ssh and https.
- Submodules: update with `submodules_update.sh` (uses `--remote --merge` if supported).
- License: GPL-3.0. Author: Kamil Cukrowski.
