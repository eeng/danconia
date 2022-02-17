with import <nixpkgs> {};
mkShell {
  nativeBuildInputs = [
    ruby
    sqlite
  ];
  shellHook = ''
    gem list -i '^bundler$' -v 1.17.3 >/dev/null || gem install bundler --version=1.17.3 --no-document
  '';
}