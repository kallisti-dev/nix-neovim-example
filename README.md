# nix-neovim-example

This is a self-contained version of my Neovim config, built with Nix. It has
completion, file and text search, a directory editor, syntax highlighting,
language servers, Git tools, and a few editing conveniences.

It runs on its own, without Home Manager or a system rebuild.

It's also tested. `nix flake check` runs the packaged editor against sample
files and checks what the config does, not just that it starts: language
servers format and complete code, Git hunks reach the index, note templates
fill in, and mappings select and jump to the right lines. See
[What the tests check](#what-the-tests-check).

## Give it a try

You'll need Nix with flakes enabled. If they aren't enabled already, add
`experimental-features = nix-command flakes` to your Nix configuration.
From a checkout of this repo:

```sh
nix run . -- .
```

That opens the current directory in Oil. You can also open a file directly:

```sh
nix run . -- checks/fixtures/sample.py
```

The executable is called `nvim-example`. It uses its own config and separate
state/cache directories, so you can try it alongside your normal Neovim setup.

## What's in here, and why

This is my Neovim setup from my dotfiles, packaged so it can run on its own.

| Piece | Why it's here |
| --- | --- |
| **lz.n** | Loads each plugin when it's first needed: on a command, key, event, filetype, or colorscheme. |
| **nvim-cmp** and its sources | Completion from language servers, buffers, paths, and the command line. Snippets use Neovim's builtin support. |
| **Telescope** and **Plenary** | Search files, project text, buffers, and help. Uses ripgrep for text search and Plenary for Lua utilities. |
| **Oil** | Edit directories as buffers and open files from them. It's also the directory browser when starting the editor on a folder. |
| **nvim-tree** | A sidebar for browsing the project while keeping the current file open. |
| **Telescope UI Select / Oil** | Use Telescope for selection prompts and finding directories to open in Oil. |
| **nvim-treesitter** and selected parsers | Syntax highlighting and indentation. **nvim-treesitter-textobjects** adds selections and motions for functions, classes, and arguments. |
| **nvim-lspconfig** | Server definitions for Neovim's native LSP client. |
| **Gitsigns** | Changed-line signs, hunk previews, staging, resets, and line blame while editing. |
| **Fugitive** | Repository-level commands and a Git status buffer. It complements Gitsigns' work on individual hunks. |
| **Rhubarb**, **Octo**, **cmp-git**, **Unception** | Open GitHub links, work on issues and pull requests, complete Git references, and reuse the current editor for nested Git edit sessions. |
| **vim-matchup** | Makes `%` work on language keywords as well as brackets. Builtin matchit is disabled so the mappings don't compete. |
| **nvim-surround** | Add, change, and remove surrounding quotes or brackets with motions. |
| **Undotree** | Browse branching undo history, rather than just stepping backward through edits. |
| **Sleuth**, **indent-blankline**, **Colorizer** | Detect indentation, show indent guides, and preview color values. |
| Programming spell list and **Precognition** | Programming vocabulary for spellcheck, from vim-dirtytalk's word lists, and hints for Vim motions. |
| **Fidget** | LSP progress and notifications in a small floating window. |
| **Obsidian** and **image.nvim** | Notes, templates, backlinks, and inline Markdown images. |
| **Nightfox**, alternate themes, and **lualine** | Nightfox is the default; `:colorscheme` switches themes. The status line includes Git and LSP information. |

Language servers:

| Language | Tools |
| --- | --- |
| Python | Basedpyright for types, completion and navigation; Ruff for linting and formatting |
| Lua | lua-language-server, with Neovim's `vim` global recognized |
| Nix | nixd and nixfmt |
| Rust | rust-analyzer, with all Cargo features and full function signatures in completion |
| Markdown | Marksman |
| Shell | bash-language-server and ShellCheck |
| TOML / YAML | Taplo / yaml-language-server |
| JavaScript / TypeScript | typescript-language-server |
| JSON / Jsonnet | vscode-json-language-server / jsonnet-language-server |
| Go | gopls |
| Protobuf | Buf |
| Perl | PLS |

Rust uses the toolchain on PATH. Enter your project's development shell before
launching the editor, or use rustup with `rust-src` and `rustfmt` installed for
the selected toolchain. `:ExpandMacro` opens the macro under the cursor in a
split. Go projects similarly need their Go toolchain available.

The parser list also covers C/C++, SQL, HTML/CSS, Dockerfiles, and other file
formats I edit. A parser adds highlighting and indentation; it doesn't imply
that a language server is configured.

## Notes and terminal setup

Use a Nerd Font for the file icons. Inline images need a terminal supporting
Kitty's graphics protocol; the image plugin skips headless sessions.

To enable the notes integration, point `NVIM_VAULT` at your vault:

```sh
NVIM_VAULT="$HOME/Notes" nix run . -- "$HOME/Notes"
```

The layout is `notebox/` for new notes, `daily/` for daily notes, `templates/`
for templates, and `assets/imgs/` for attachments. Daily notes use
`templates/today.md`; add that template to your vault. Templates can use
week-date substitutions such as `{{start_of_week}}`, and notes made from
`templates/weekly.md` go in `weekly/`, named after the week's Monday. Both are
set in `config/lua/plugins/obsidian.lua`. No vault content is bundled.

Octo and Git completion use `gh`; authenticate with `gh auth login` before
using GitHub features.

## Everyday keys

The leader key is Space.

| Keys | Action |
| --- | --- |
| Space `f` / `s` | Find files / search project text |
| Space `b` / `h` | Find open buffers / search help |
| Space `?` | Search all mappings |
| Space `o` | Edit the current directory in Oil |
| Space `d` / `t` / `T` | Find a directory / find current file in tree / toggle tree |
| Space `u` | Toggle Undotree |
| Tab / Ctrl-Space / Ctrl-E | Accept a completion / request completion / dismiss it |
| `gd` / `grr` / `K` | Definition / references / hover, with a language server |
| `grn` / `gra` / Space `cf` | Rename / code action / format |
| `]d` / `[d` / Ctrl-W `d` | Next / previous diagnostic / show the diagnostic under the cursor |
| `af` / `ac` / `aa` | Select a function / class / argument (`if` / `ic` / `ia` select inside) |
| `]f` / `[f` / `]c` / `[c` | Next / previous function / class |
| Space `ghp` / `ghs` / `ghr` | Preview / stage / reset a Git hunk |
| Space `gb` / `gD` | Blame the current line / diff the file |
| `:Git` | Open Fugitive's status buffer |
| `:GBrowse` / `:Octo` | Open on GitHub / GitHub issues and pull requests |
| Space `nn` / `nd` / `nf` / `nt` | New note / today's note / find note / new note from template |
| Space `ig` | Toggle indent guides |

Most of the LSP keys are Neovim's defaults: `K`, the `gr` keys, `]d` and
Ctrl-W `d`. The config adds `gd` and `gD` for servers that support them, and
Space `cf`.

For a quick editing example, open `checks/fixtures/sample-match.sh`. Put the
cursor on `if` at line 4 and press `%` to jump to `fi`. Inside `"hello"` on
line 5, type `cs"'` to change the quotes. Open `sample.py` and use Space `cf`
after the servers attach to format it.

## How Nix and Lua fit together

| File | Job |
| --- | --- |
| `flake.nix`, `flake.lock` | Pin nixpkgs and expose the package, checks, and dev shell per platform |
| `package.nix` | List the plugins, build the package directory, and wrap Neovim with the tools on PATH |
| `config/init.lua` | Set options and runtime paths, and start lz.n |
| `config/lua/plugins/` | Plugin specs: load triggers, mappings, and setup |
| `checks/` | Run the packaged editor against writable fixtures in a fresh HOME |

The package installs `config/` with a `pack/` directory beside `init.lua`, laid
out the way Neovim expects packages:

```text
share/nvim-example/
├── init.lua
├── lua/
├── after/
└── pack/nix/
    ├── start/lz.n -> /nix/store/…-lz.n
    └── opt/
        ├── telescope.nvim -> /nix/store/…-telescope.nvim
        └── …
```

At startup:

1. The `nvim-example` wrapper puts the language servers and tools on PATH and
   starts Neovim with `-u` pointing at this `init.lua`.
2. `init.lua` sets `'runtimepath'` and `'packpath'` to this directory and
   Neovim's own runtime, so nothing from HOME loads. It sets the options, then
   `require("lz.n").load("plugins")` reads every spec in `lua/plugins/`.
   Plugins without triggers load right away.
3. Neovim runs the plugin scripts of everything loaded so far.
4. Opening a file, pressing a mapped key, or running a command fires the
   matching triggers, and lz.n loads those plugins with `:packadd`.

Nothing is downloaded or installed at runtime: lz.n only loads what Nix built.
Packages load ahead of Neovim's runtime, so plugin files win over the ones
Neovim bundles.

Each spec names its plugin by the package's `pname`, for example
`{ "telescope.nvim", cmd = "Telescope" }`. lz.n has no `opts` or
`dependencies` fields: a spec calls the plugin's `setup()` in its `after` hook,
and loads the plugins it uses with `require("lz.n").trigger_load` in its
`before` hook. `init.lua` also gives lz.n a load function, because `:packadd`
after startup skips a plugin's `after/plugin` scripts, which is where nvim-cmp's
sources register.

Nightfox and Oil load at startup. Completion waits for insert/command-line
mode, Telescope and Fugitive wait for commands or keys, and LSP and syntax
setup wait for the first file. Surround, the status line, and the programming
spell list load on lz.n's `DeferredUIEnter` event, once the UI is up.

Treesitter needs a little extra care: `withPlugins` declares each parser and
its queries as a separate dependency of nvim-treesitter instead of adding them
to its directory. `symlinkJoin` collects them into one package,
`treesitter-grammars`, which loads just before nvim-treesitter.

Telescope–Oil isn't in nixpkgs, so `package.nix` builds it from GitHub. The
programming spell list is compiled from vim-dirtytalk's word lists during the
build.

To add a plugin, add its package to `plugins` in `package.nix` and a spec under
`config/lua/plugins/`. For a language server, add its package to the wrapper's
PATH and enable it in `plugins/lsp.lua`. Parsers are listed in `package.nix`.

## Work on the config

```sh
nix develop
nvim-example .
nix fmt
nix flake check --print-build-logs
nix build
./result/bin/nvim-example
```

The dev shell includes the editor, nixfmt, and StyLua. With direnv installed,
review `.envrc` and run `direnv allow` to enter it automatically. New files need
to be staged with `git add` before a Git-backed flake can see them.

## What the tests check

Each scenario gets a fresh HOME and a writable copy of the fixtures. It runs
the packaged editor and fails on any warning or error, including errors from a
plugin's setup. A scenario is stopped after 30 seconds, or two minutes for the
Rust and language checks. The shared [Probe helpers](checks/probe.lua) handle
assertions and exit status.

| Check | What it exercises |
| --- | --- |
| `startup` | Theme, which plugins load at startup, and runtime paths that all come from Nix |
| `load-all` | Every plugin loads cleanly, and each command that loads a plugin exists afterwards |
| `filetypes` | Filetype detection, syntax trees and highlighting for existing and new files, and the status line |
| `python`, `new-python` | Both Python servers, real formatting, and LSP completion |
| `lsp-keymaps` | `gd` and `gD` only where the server supports them, and Neovim's own LSP keys |
| `nix` | nixd attachment and formatting through nixfmt |
| `lua` | Lua language-server initialization and attachment |
| `rust` | rust-analyzer attachment, field completion, macro expansion, and rustfmt |
| `editing` | Indent guides, the programming spell list, the file tree, an alternate theme, and GitHub commands |
| `textobjects` | Selecting and moving by function and class |
| `sleuth` | Indentation detected for the first file opened |
| `notes` | Daily notes and linked notes from templates, checkboxes, note mappings, and Telescope pickers in a temporary vault |
| `languages` | Executables for every configured server and attachment for the remaining languages |
| `completion` | Completion sources, buffer-source results, and builtin snippet expansion |
| `telescope` | A real file search and opening its selected result |
| `oil` | Listing a directory and opening a file |
| `git` | Staging a hunk, Fugitive's status buffer, and `:GBrowse` URLs |
| `undotree` | Opening and closing the undo-tree window |
| `match-and-surround` | Actual matching motions and surround edits |

These are headless checks. They emit lz.n's `DeferredUIEnter` event explicitly
because there's no UI, and they don't check terminal rendering or completion
popup input. Language servers can't watch files in the test process
([sandbox.lua](checks/sandbox.lua)) because recursive watchers can exhaust the
Darwin sandbox's file descriptors. Normal editor runs keep file watching
enabled.

GitHub authentication and remote operations, clipboard access, and terminal
image rendering need an interactive session; the headless checks don't cover
them. The Rust check uses a dependency-free crate and an explicit test toolchain.

### Updating a snapshot

The startup snapshot records which plugins loaded. Behavioral assertions check
what they actually do; keep those separate when accepting a snapshot change.

```sh
nix build .#snapshot-startup --out-link result-snapshot
diff -u checks/expected/startup.expected result-snapshot/report.txt
# Check that the load-state changes are intentional before copying.
cp result-snapshot/report.txt checks/expected/startup.expected
git diff -- checks/expected/startup.expected
nix flake check --print-build-logs
```

Regeneration still runs the assertions and health checks. It only skips the
snapshot comparison. Copy `report.txt` directly; `nix log` can add prefixes.

## Platforms

| Target | Validation |
| --- | --- |
| `aarch64-darwin` | Package and integration checks run locally |
| `x86_64-linux` | Package and integration checks run on a Linux build server |
| `aarch64-linux` | Package and integration checks run in CI |

The [CI workflow](.github/workflows/check.yml) builds the package and runs the
checks and dev-shell smoke test on all three targets.
