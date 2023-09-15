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
      fastapi-amis-admin = [flit-core];
      aiofiles = [hatchling];
      httpcore = [hatchling];
      sqlalchemy = [hatchling];
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

      # ruff v.287
      ruff = with rustPlatform;
        super.ruff.overridePythonAttrs (old: rec {
          src = fetchFromGitHub {
            owner = "astral-sh";
            repo = "ruff";
            rev = "v${old.version}";
            sha256 = "sha256-T7PuhQnb7Ae9mYdaxDBltJWx5ODTscvEP3LcSEcSuLo=";
            # sha256 = "sha256-bEVACTlzELXPoCtEHMR1s87KJn/qnE0lO1O4RmdjmPM=";
          };

          cargoDeps = importCargoLock {
            lockFile = "${src}/Cargo.lock";
            outputHashes = {
              "libcst-0.1.0" = "sha256-FgQE8ofRXQs/zHh7AKscXu0deN3IG+Nk/h+a09Co5R8=";
              # "ruff_text_size-0.0.0" = "sha256-5CjNHj5Rz51HwLyXtUKJHmEKkAC183oafdqKDem69oc=";
              "unicode_names2-0.6.0" = "sha256-eWg9+ISm/vztB0KIdjhq5il2ZnwGJQCleCYfznCI3Wg=";
            };
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
