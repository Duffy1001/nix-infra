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
        root-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/root
            ./profiles/vm/test.nix
            { networking.hostName = nixpkgs.lib.mkForce "root-vm"; }
          ];
        };
        app01-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/app01 ./profiles/vm/test.nix { networking.hostName = nixpkgs.lib.mkForce "app01"; } ];
        };
        app02-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/app02 ./profiles/vm/test.nix { networking.hostName = nixpkgs.lib.mkForce "app02"; } ];
        };
        desktop01-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/desktop01 ./profiles/vm/test.nix { networking.hostName = nixpkgs.lib.mkForce "desktop01"; } ];
        };
      };

      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        import ./pkgs { inherit pkgs; }
      );



      apps = forAllSystems (system: {
        root-vm = {
          type = "app";
          program = "${self.nixosConfigurations.root-vm.config.system.build.vm}/bin/run-root-vm-vm";
          meta.description = "Boot the root storage-node smoke-test VM";
        };
        app01-vm = {
          type = "app";
          program = "${self.nixosConfigurations.app01-vm.config.system.build.vm}/bin/run-app01-vm";
          meta.description = "Boot the app01 compute smoke-test VM";
        };
        app02-vm = {
          type = "app";
          program = "${self.nixosConfigurations.app02-vm.config.system.build.vm}/bin/run-app02-vm";
          meta.description = "Boot the app02 compute smoke-test VM";
        };
        desktop01-vm = {
          type = "app";
          program = "${self.nixosConfigurations.desktop01-vm.config.system.build.vm}/bin/run-desktop01-vm";
          meta.description = "Boot the desktop01 smoke-test VM";
        };
      });

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
