with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    elixir_1_18
    pre-commit
    elixir_ls
    inotify-tools
    watchexec
  ];
}
