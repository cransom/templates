{
  description = "process a pcb!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

      ];
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
      ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          pcbproc = pkgs.writeShellApplication {
            name = "pcbproc";
            runtimeInputs = [ pkgs.pcb2gcode pkgs.coreutils ];
            text = ''
              set -euo pipefail
              if [ -z "''${1:-}" ]; then
                base="$(basename "$PWD")"
              else
                base="''${1:-}"
              fi
              # Post process in kicad selecting at least a back and edge cuts layer. also generate a drill file.
              pcb2gcode --drill "$base.drl" --back "$base-B_Cu.gbr" --outline "$base-Edge_Cuts.gbr"

              # Combine to a single file. Don't do this if you have tool changes.
              cat back.ngc milldrill.ngc outline.ngc > all.ngc
              # Strips tool changes from the main file.
              sed -i 's/M0.*//; s/M6.*//' all.ngc
            '';
          };

        in
        {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          checks = { };

          devShells.default = pkgs.mkShell {
            name = "pcb2gcode";
            nativeBuildInputs = with pkgs; [
              pcb2gcode
              pcbproc
            ];
          };
        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
