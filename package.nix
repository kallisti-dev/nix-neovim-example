# Package the Lua config with the plugins it loads, and wrap Neovim with the
# language servers and tools the config uses on PATH.
{
  lib,
  stdenvNoCC,
  makeWrapper,
  neovim-unwrapped,
  vimPlugins,
  symlinkJoin,
  basedpyright,
  lua-language-server,
  nixd,
  nixfmt,
  ruff,
  diffutils,
  git,
  ripgrep,
  fd,
  gh,
  tmux,
  imagemagick,
  curl,
  pngpaste,
  wl-clipboard,
  xclip,
  xdg-utils,
  marksman,
  taplo,
  yaml-language-server,
  typescript-language-server,
  vscode-langservers-extracted,
  jsonnet-language-server,
  gopls,
  buf,
  perlPackages,
  shellcheck,
  bash-language-server,
  rust-analyzer,
  runCommand,
  vimUtils,
  fetchFromGitHub,
}:
let
  # typescript-language-server 6.0.2 landed with a stale pnpm dependency hash.
  # NixOS/nixpkgs#572951 corrects it to the hash of a fetch on Linux. On macOS,
  # pnpm also leaves an empty v11/links directory in its store, which the
  # fetcher packs; without it, a fetch on a Mac matches that hash too. Once
  # nixpkgs has the corrected hash, the guard makes this a no-op.
  typescriptServer = typescript-language-server.overrideAttrs (old: {
    pnpmDeps =
      if old.pnpmDeps.outputHash == "sha256-MUSxDMlbG21KSesGdEvqa2kEpuVfLlXRUX1qV/FGsSo=" then
        old.pnpmDeps.overrideAttrs (deps: {
          outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
          preFixup = (deps.preFixup or "") + ''
            rm -rf "$storePath/v11/links"
          '';
        })
      else
        old.pnpmDeps;
  });
  treesitter = vimPlugins.nvim-treesitter.withPlugins (
    parsers: with parsers; [
      tree-sitter-bash
      tree-sitter-c
      tree-sitter-cmake
      tree-sitter-cpp
      tree-sitter-css
      tree-sitter-dockerfile
      tree-sitter-gitcommit
      tree-sitter-gitignore
      tree-sitter-go
      tree-sitter-html
      tree-sitter-http
      tree-sitter-javascript
      tree-sitter-json
      tree-sitter-jsonnet
      tree-sitter-llvm
      tree-sitter-lua
      tree-sitter-make
      tree-sitter-markdown
      tree-sitter-markdown-inline
      tree-sitter-nix
      tree-sitter-promql
      tree-sitter-proto
      tree-sitter-python
      tree-sitter-query
      tree-sitter-readline
      tree-sitter-regex
      tree-sitter-rust
      tree-sitter-sql
      tree-sitter-toml
      tree-sitter-tsx
      tree-sitter-typescript
      tree-sitter-vim
      tree-sitter-vimdoc
      tree-sitter-yaml
      tree-sitter-zig
    ]
  );
  # withPlugins declares each parser and its queries as a separate dependency
  # instead of putting them in nvim-treesitter's directory. Join them into one
  # runtime directory, which the syntax spec loads before nvim-treesitter.
  treesitterGrammars = symlinkJoin {
    name = "treesitter-grammars";
    paths = treesitter.dependencies;
  };
  # Programming vocabulary for spellcheck: vim-dirtytalk's wordlists, compiled
  # into a regular spell file at build time. Adding "programming" to
  # 'spelllang' uses it.
  programmingSpell =
    let
      dirtytalk = fetchFromGitHub {
        owner = "benelan";
        repo = "vim-dirtytalk";
        rev = "618f7f6";
        hash = "sha256-URkb9E1Vx4ht1IOrSaT7i2B/fc1sHz7wJnp1W8QYBNs=";
      };
    in
    runCommand "programming-spell" { nativeBuildInputs = [ neovim-unwrapped ]; } ''
      mkdir -p "$out/spell"
      cat ${dirtytalk}/wordlists/*.words > words
      nvim --headless -u NONE -i NONE -c "mkspell! $out/spell/programming words" -c qa
    '';
  # Not in nixpkgs.
  telescopeOil = vimUtils.buildVimPlugin {
    pname = "telescope-oil.nvim";
    version = "2026-05-23";
    src = fetchFromGitHub {
      owner = "albenisolmos";
      repo = "telescope-oil.nvim";
      rev = "997f0bcc2ec5237b9ad5a1e73d5baf4dfca3a687";
      hash = "sha256-4Bdcr7P0I/SPMdfFD0x5VlxrSkTbCpJ0BnqklOsPs38=";
    };
    dependencies = with vimPlugins; [
      telescope-nvim
      plenary-nvim
      oil-nvim
    ];
  };
  # Every plugin the specs in config/lua/plugins/ can load. A spec names its
  # plugin by the package's pname, such as "telescope.nvim".
  plugins = with vimPlugins; [
    # Appearance
    nightfox-nvim
    lualine-nvim
    tokyonight-nvim
    oceanic-next
    palenight-vim
    onehalf
    rose-pine
    iceberg-vim
    nord-nvim
    tender-vim
    catppuccin-nvim
    melange-nvim
    kanagawa-nvim
    seoul256-vim
    srcery-vim
    gruvbox
    dracula-nvim

    # Completion
    nvim-cmp
    cmp-nvim-lsp
    cmp-path
    cmp-buffer
    cmp-cmdline
    cmp-git

    # Editing
    vim-sleuth
    precognition-nvim
    nvim-colorizer-lua
    indent-blankline-nvim
    nvim-surround
    vim-matchup
    undotree
    programmingSpell

    # Git and GitHub
    gitsigns-nvim
    vim-fugitive
    vim-rhubarb
    nvim-unception
    octo-nvim

    # Language servers
    nvim-lspconfig
    fidget-nvim

    # Navigation
    oil-nvim
    telescope-nvim
    telescope-ui-select-nvim
    telescopeOil
    nvim-tree-lua
    plenary-nvim
    nvim-web-devicons

    # Notes
    obsidian-nvim
    image-nvim

    # Syntax
    treesitter
    treesitterGrammars
    nvim-treesitter-textobjects
  ];
in
stdenvNoCC.mkDerivation {
  pname = "nix-neovim-example";
  version = "0.1.0";
  src = ./config;
  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;
  # The config directory doubles as a Neovim package directory. lz.n is the
  # one start package, so init.lua can require it; every other plugin is an
  # optional package that lz.n loads with :packadd when its spec asks for it.
  installPhase = ''
    runHook preInstall
    config="$out/share/nvim-example"
    mkdir -p "$config/pack/nix/start" "$config/pack/nix/opt" "$out/bin"
    cp -r . "$config/"
    ln -s ${vimPlugins.lz-n} "$config/pack/nix/start/lz.n"
    ${lib.concatMapStrings (plugin: ''
      ln -s ${plugin} "$config/pack/nix/opt/${plugin.pname or plugin.name}"
    '') plugins}
    makeWrapper ${neovim-unwrapped}/bin/nvim "$out/bin/nvim-example" \
      --set NVIM_APPNAME nix-neovim-example \
      --prefix PATH : ${
        lib.makeBinPath (
          [
            ruff
            basedpyright
            lua-language-server
            nixd
            nixfmt
            diffutils
            git
            ripgrep
            fd
            gh
            tmux
            imagemagick
            curl
            marksman
            taplo
            yaml-language-server
            typescriptServer
            vscode-langservers-extracted
            jsonnet-language-server
            gopls
            buf
            perlPackages.PLS
            shellcheck
            bash-language-server
            rust-analyzer
          ]
          ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [ pngpaste ]
          ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
            wl-clipboard
            xclip
            xdg-utils
          ]
        )
      } \
      --add-flags '-u' \
      --add-flags "$config/init.lua"
    runHook postInstall
  '';
  meta = {
    description = "Neovim config with completion, navigation, LSP, and Git integration";
    license = lib.licenses.bsd0;
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "nvim-example";
  };
}
