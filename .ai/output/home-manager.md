## Context: home-manager-ctx
| Key | Value |
| --- | ----- |
| input | github:nix-community/home-manager, inputs.nixpkgs.follows = nixpkgs |
| default-includes | den._.home-manager, den._.inputs', den._.self' |
| pattern | Takes `den` argument; den.default.includes adds HM support to all hosts |