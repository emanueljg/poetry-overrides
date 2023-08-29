{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [(
        { lib, flake-parts-lib, ... }:
          let
            inherit (lib)
              mkOption
              types
              ;
            inherit (flake-parts-lib)
              mkTransposedPerSystemModule
              ;
          in mkTransposedPerSystemModule {
            name = "overrides";
            option = mkOption {
              type =  types.lazyAttrsOf types.anything;
              default = { };
              description = "";
            };
            file = ./overrides.nix;
          }
      )];

      systems = [ 
        "x86_64-linux" 
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        formatter = pkgs.alejandra;
        overrides = import ./overrides.nix { inherit pkgs; };
      };

      flake = {
      };

    };
}
