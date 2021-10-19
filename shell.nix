with import <nixpkgs> {};
let
  # Add nightly packages
  unstable = import <unstable> {};
in
stdenv.mkDerivation rec {
  name = "env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    # These aren't in the 21.05 release
    unstable.elixir_1_12
    unstable.pre-commit
    unstable.elixir_ls
    inotify-tools
    watchexec
  ];
}
