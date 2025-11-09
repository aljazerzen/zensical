{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      fenix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fenix_pkgs = fenix.packages.${system};
        rust_toolchain = fenix_pkgs.stable;
      in
      {
        devShells.default = pkgs.mkShell {
          venvDir = "./venv";

          buildInputs = with pkgs; [
            python312Packages.python
            python312Packages.venvShellHook
            python312Packages.python-lsp-server
            python312Packages.python-lsp-ruff
            uv

            (rust_toolchain.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
              "rust-analyzer"
            ])

          ];
        };
      }
    );
}
