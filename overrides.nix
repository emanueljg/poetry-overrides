{
  poetry2nix,
  maturin,
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
  (self: super: let
    wheelPkgs = [
      "cryptography"
    ];
    in lib.genAttrs wheelPkgs (name: super.${name}.override { preferWheel = true; })) 
  (poetry2nix.defaultPoetryOverrides.extend (
    self: super: let
      extraBuildInputs = with super; {
        # taskipy = [poetry];
        # pytest-base-url = [poetry setuptools];
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
        httpcore = [hatchling hatch-fancy-pypi-readme];
        sqlalchemy = [hatchling hatch-fancy-pypi-readme];
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
  ))
]
