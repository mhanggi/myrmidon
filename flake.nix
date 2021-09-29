{
  description = "myrmidon - task launcher using rofi";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachSystem ["x86_64-linux" "i686-linux" "aarch64-linux"] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packageName = "myrmidon";
      in {
        packages.${packageName} = pkgs.runCommandLocal "myrmidon" {
          script = ./myrmidon.sh;
          nativeBuildInputs = [ pkgs.makeWrapper ];
        } ''
          makeWrapper $script $out/bin/myrmidon.sh \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.bash pkgs.inotify-tools pkgs.libnotify ]}
        '';

        defaultPackage = self.packages.${system}.${packageName}; 
      });
}
