{ pkgs }: pkgs.poetry2nix.defaultPoetryOverrides.extend (self: super: let

  extraBuildInputs = with super; {
    taskipy = [ poetry ];
    pytest-base-url = [ poetry setuptools ];
    pytest-playwright = [ setuptools setuptools-scm ];
    urllib3 = [ hatchling ];
  };

in builtins.mapAttrs 
  (packageName: buildInputs: 
    super.${packageName}.overridePythonAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ buildInputs;
    })
  )
  extraBuildInputs
)