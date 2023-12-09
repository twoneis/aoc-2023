{
  description = "Flake for zig development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      devShell.x86_64-linux = pkgs.mkShell {
        name = "zig-devel";
        packages = with pkgs; [
          zig
          zls
          lldb
        ];
        shellHook = ''
          export PS1="[\u@zig-aoc:\W]\$ "
          alias "run"="zig build run --"
          alias "benchmark"="zig build benchmark --"
          alias "test"="zig build test"
        '';
      };
    };
}
