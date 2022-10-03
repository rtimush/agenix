{
  description = "Secret management with age";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin }:
  let
    agenix = system: nixpkgs.legacyPackages.${system}.callPackage ./pkgs/agenix.nix {};
  in {

    nixosModules.age = import ./modules/age.nix;
    nixosModule = self.nixosModules.age;

    darwinModules.age = import ./modules/age.nix;
    darwinModule = self.darwinModules.age;

    overlay = import ./overlay.nix;

    packages."aarch64-linux".agenix = agenix "aarch64-linux";
    defaultPackage."aarch64-linux" = self.packages."aarch64-linux".agenix;

    packages."i686-linux".agenix = agenix "i686-linux";
    defaultPackage."i686-linux" = self.packages."i686-linux".agenix;

    packages."x86_64-darwin".agenix = agenix "x86_64-darwin";
    defaultPackage."x86_64-darwin" = self.packages."x86_64-darwin".agenix;

    packages."aarch64-darwin".agenix = agenix "aarch64-darwin";
    defaultPackage."aarch64-darwin" = self.packages."aarch64-darwin".agenix;

    packages."x86_64-linux".agenix = agenix "x86_64-linux";
    defaultPackage."x86_64-linux" = self.packages."x86_64-linux".agenix;
    checks."x86_64-linux".integration = import ./test/integration.nix {
      inherit nixpkgs; pkgs = nixpkgs.legacyPackages."x86_64-linux"; system = "x86_64-linux";
    };
    checks."aarch64-darwin".integration = (darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ ./test/integration_darwin.nix "${darwin.outPath}/pkgs/darwin-installer/installer.nix" ];
    }).system;
    checks."x86_64-darwin".integration = (darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [ ./test/integration_darwin.nix "${darwin.outPath}/pkgs/darwin-installer/installer.nix" ];
    }).system;

    darwinConfigurations.integration.system = self.checks."x86_64-darwin".integration;
  };

}
