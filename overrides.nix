{
  poetry2nix,
  maturin,
  rustPlatform,
  fetchFromGitHub,
}:
poetry2nix.defaultPoetryOverrides.extend (
  self: super: let
    extraBuildInputs = with super; {
      taskipy = [poetry];
      pytest-base-url = [poetry setuptools];
      pytest-playwright = [setuptools setuptools-scm];
      urllib3 = [hatchling];
      annotated-types = [hatchling];
      pycparser = [maturin];
      pydantic = [hatchling hatch-fancy-pypi-readme];
      fastapi-crudrouter = [setuptools];
      sqlalchemy-database = [flit-core];
      fastapi-sqlmodel-crud = [flit-core];
    };
  in
    (builtins.mapAttrs
      (
        packageName: buildInputs:
          super.${packageName}.overridePythonAttrs (old: {
            buildInputs = (old.buildInputs or []) ++ buildInputs;
          })
      )
      extraBuildInputs)
    // {
      pydantic-core = with rustPlatform;
        super.pydantic-core.overridePythonAttrs (old: rec {
          src = fetchFromGitHub {
            owner = "pydantic";
            repo = "pydantic-core";
            rev = "v${old.version}";
            sha256 = "sha256-bEVACTlzELXPoCtEHMR1s87KJn/qnE0lO1O4RmdjmPM=";
          };

          cargoDeps = importCargoLock {
            lockFile = "${src}/Cargo.lock";
          };

          nativeBuildInputs =
            (old.nativeBuildInputs or [])
            ++ [
              cargoSetupHook
              maturinBuildHook
            ];
        });
    }
)
