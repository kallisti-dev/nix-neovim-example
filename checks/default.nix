# Run scenarios against the packaged editor in an isolated HOME and project.
# Successful checks retain log.txt; startup also compares a sorted report.
{ pkgs, editor }:
let
  inherit (pkgs) lib;
  # Seconds before a check is killed. The Rust and language checks wait for
  # several language servers in turn, up to about a minute in all.
  timeouts = {
    rust = 120;
    languages = 120;
  };
  # Regeneration skips only the snapshot comparison, retaining all assertions.
  runScenario =
    {
      name,
      regenerate ? false,
    }:
    pkgs.runCommand "neovim-${name}${lib.optionalString regenerate "-snapshot"}"
      {
        nativeBuildInputs = [
          pkgs.coreutils
          pkgs.diffutils
          pkgs.git
          pkgs.gnugrep
        ]
        ++ lib.optionals (name == "rust") [
          pkgs.cargo
          pkgs.rustc
          pkgs.rustfmt
        ]
        ++ lib.optionals (name == "languages") [ pkgs.go ];
      }
      ''
        export HOME="$TMPDIR/home"
        export XDG_CONFIG_HOME="$HOME/.config"
        export XDG_DATA_HOME="$HOME/.local/share"
        export XDG_STATE_HOME="$HOME/.local/state"
        export XDG_CACHE_HOME="$HOME/.cache"
        export NVIM_VAULT=""
        unset TMUX
        mkdir -p "$HOME/project" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$out"
        cp -R ${./fixtures}/. "$HOME/project/"
        chmod -R u+w "$HOME/project"
        cd "$HOME/project"
        ${lib.optionalString (name == "rust") ''
          export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
        ''}
        ${lib.optionalString (name == "notes" || name == "load-all") ''
          export NVIM_VAULT="$HOME/project/vault"
        ''}
        ${lib.optionalString (name == "git") ''
          git init --quiet --initial-branch=main
          git add tracked.txt
          git -c user.name=Example -c user.email=example@example.invalid \
            -c commit.gpgsign=false commit --quiet -m "Initial fixture"
          git remote add origin https://github.com/example/project.git
        ''}
        export FIXTURE="$HOME/project/sample-match.sh"
        export PROBE_LIB=${./probe.lua}
        export REPORT="$out/report.txt"
        # Hook notifications and adjust Neovim for the sandbox before init.lua,
        # so startup failures cannot be hidden.
        rc=0
        timeout ${toString (timeouts.${name} or 30)} ${editor}/bin/nvim-example --headless -i NONE \
          --cmd "lua Probe = dofile(vim.env.PROBE_LIB)" \
          --cmd "luafile ${./sandbox.lua}" \
          -c "lua Probe.run('${./scenarios}/${name}.lua')" \
          > "$out/log.txt" 2>&1 || rc=$?
        cat "$out/log.txt"
        if [ "$rc" -ne 0 ]; then
          echo "${name}: editor exited $rc"
          exit 1
        fi
        # Neovim can print async errors yet exit 0. Inspect its actual output:
        # v:errmsg includes suppressed errors, while :messages can omit errors
        # in headless mode. Neither is a reliable substitute for this log.
        if grep -Eq '(^Error (in|executing)|(^|[[:space:]])E[0-9]+:|^(Lua|vim.schedule) callback:)' "$out/log.txt"; then
          echo "${name}: editor printed an error"
          exit 1
        fi
        ${lib.optionalString (name == "startup" && !regenerate) ''
          diff -u ${./expected/startup.expected} "$out/report.txt"
        ''}
      '';
in
{
  checks = lib.genAttrs [
    "startup"
    "load-all"
    "filetypes"
    "python"
    "new-python"
    "lsp-keymaps"
    "undotree"
    "match-and-surround"
    "textobjects"
    "sleuth"
    "completion"
    "telescope"
    "oil"
    "git"
    "nix"
    "lua"
    "rust"
    "editing"
    "notes"
    "languages"
  ] (name: runScenario { inherit name; });
  # Kept out of checks: regeneration still runs assertions but skips the diff.
  snapshot = runScenario {
    name = "startup";
    regenerate = true;
  };
}
