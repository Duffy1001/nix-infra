{
  description = "Ephemeral NixOS machines with remote per-service state";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      lib = import ./lib { lib = nixpkgs.lib; };

      nixosConfigurations = {
        root = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/root ];
        };
        app01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/app01 ];
        };
        app02 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/app02 ];
        };
        laptop01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/laptop01 ];
        };
        desktop01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/desktop01 ];
        };
      };

      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        import ./pkgs { inherit pkgs; }
      );

      checks = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          state-contract = pkgs.callPackage ./tests/eval/state-contract.nix { };
          names = pkgs.callPackage ./tests/eval/names.nix { };
          volume-select = pkgs.callPackage ./tests/eval/volume-select.nix { };
          zvol-plan = pkgs.callPackage ./tests/eval/zvol-plan.nix { };
          nvmet-plan = pkgs.callPackage ./tests/eval/nvmet-plan.nix { };
          service-deps = pkgs.callPackage ./tests/eval/service-deps.nix { };
        });
    };
}
