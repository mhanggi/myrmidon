{
  description = "myrmidon - task launcher using rofi";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: 
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config = { allowUnfree = "true";};
    };
  in rec {
    packages.x86_64-linux.myrmidon = pkgs.runCommandLocal "myrmidon" {
      script = ./myrmidon.sh;
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      makeWrapper $script $out/bin/myrmidon \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.bash pkgs.inotify-tools pkgs.libnotify ]}
    '';

    defaultPackage.x86_64-linux = packages.x86_64-linux.myrmidon;

    overlay = (final: prev: {
      myrmidon = packages.x86_64-linux.myrmidon;
    });

    apps.x86_64-linux = {
      myrmidon = {
        type = "app";
        program = "${defaultPackage}/result/myrmidon.sh";
      };
    };


    defaultApp = apps.x86_64-linux.myrmidon;
  };
}
