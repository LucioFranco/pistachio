{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
         # 1) devShell: jupyter & friends on your PATH
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs.python312Packages; [
              numpy
              pandas
              jinja2
              jupyter
            ] ++ [
              pkgs.pyright
              pkgs.nbstripout
            ];
            shellHook = ''
            # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
            # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
            export PIP_PREFIX=$(pwd)/_build/pip_packages
            export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
            export PATH="$PIP_PREFIX/bin:$PATH"
            unset SOURCE_DATE_EPOCH
          '';
          };

          # # 2) default package → a small script that runs notebook
          # packages.default = pkgs.writeShellScriptBin "jupyter-notebook" ''
          #   exec ${pkgs.python312.withPackages (ps: [
          #     ps.numpy
          #     ps.pandas
          #   ])}/bin/jupyter-lab \
          #     --ip=0.0.0.0 --no-browser --port 8888
          # '';
      };
    };
}
