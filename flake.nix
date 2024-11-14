{
  outputs = { nixpkgs, rust, ... }:
    let
      systems = [ "x86_64-linux" ];
      eachSystem = fn: nixpkgs.lib.genAttrs systems (system: fn system);
    in {
      devShells = eachSystem (system:
        let
          overlays = [ (import rust) ];
          pkgs = import nixpkgs { inherit system overlays; };
          toolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile
            ./rust-toolchain.toml;
          languageTools = with pkgs; [ nil nixfmt-classic taplo ];
        in {
          default = pkgs.mkShell {
            packages = [ toolchain pkgs.bacon ] ++ languageTools;
          };
        });
    };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    rust = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
