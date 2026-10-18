# Flake entry point: expose the editor, checks and development tools per platform.
# Each platform's checks receive the same editor derivation as `nix run`.
{
  description = "A Nix-managed Neovim config with integration tests";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      project = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          editor = pkgs.callPackage ./package.nix { };
          tests = import ./checks { inherit pkgs editor; };
        in
        {
          inherit pkgs editor tests;
        }
      );
    in
    {
      packages = forAllSystems (system: {
        default = project.${system}.editor;
        snapshot-startup = project.${system}.tests.snapshot;
      });
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nvim-example";
          meta.description = "Run the example Neovim configuration";
        };
      });
      checks = forAllSystems (system: project.${system}.tests.checks);
      devShells = forAllSystems (
        system:
        let
          inherit (project.${system}) pkgs editor;
        in
        {
          default = pkgs.mkShell {
            packages = [
              editor
              pkgs.nixfmt
              pkgs.stylua
            ];
          };
        }
      );
      formatter = forAllSystems (system: project.${system}.pkgs.nixfmt-tree);
    };
}
