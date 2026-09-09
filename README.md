# TMOG for NixOS

Nix flake packaging for [TMOG](https://tmog.org/), the native system monitor and task manager.

TMOG is distributed as a proprietary prebuilt Linux AppImage. This repository does not contain TMOG source code.

## Requirements

- Nix with flakes enabled
- x86_64 Linux
- Permission to use TMOG under its upstream license
- Unfree packages enabled when integrating it into a NixOS configuration

The package currently supports only `x86_64-linux`, because the upstream download is `TMOG-Task-Manager-Linux-x86_64.AppImage`.

## Run without installing

```bash
nix run github:thomasPeelmanUCLL/nixos-tmog
```

## Install to a user profile

```bash
nix profile install github:thomasPeelmanUCLL/nixos-tmog
```

Then launch it with:

```bash
tmog
```

## Build locally

```bash
nix build github:thomasPeelmanUCLL/nixos-tmog
./result/bin/tmog
```

To inspect the flake outputs:

```bash
nix flake show github:thomasPeelmanUCLL/nixos-tmog
```

## NixOS flake integration

Add the package as an input in `/etc/nixos/flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    tmog.url = "github:thomasPeelmanUCLL/nixos-tmog";
  };

  outputs = inputs@{ nixpkgs, tmog, ... }:
    {
      nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ({ pkgs, inputs, ... }: {
            nixpkgs.config.allowUnfree = true;
            environment.systemPackages = [
              inputs.tmog.packages.${pkgs.system}.tmog
            ];
          })
        ];
      };
    };
}
```

Replace `hostname` with the name of your NixOS configuration.

If your configuration already passes flake inputs through `specialArgs`, only add the package to `environment.systemPackages`:

```nix
environment.systemPackages = [
  inputs.tmog.packages.${pkgs.system}.tmog
];
```

## NixOS without flakes

You can also install the package from a local checkout:

```bash
nix-env -f . -iA packages.x86_64-linux.tmog
```

Flakes are recommended because they pin the package dependencies through `flake.lock`.

## Desktop integration

The package installs the TMOG desktop entry and icon. If your desktop environment caches application metadata, refresh it or log out and back in after installing.

For KDE Plasma:

```bash
kbuildsycoca6 --noincremental
```

## Unfree software and licensing

TMOG is proprietary, closed-source software distributed as a prebuilt AppImage. The derivation marks it as `unfree`; review and accept the upstream TMOG license before using or redistributing it.

This repository packages the upstream binary; it is not affiliated with or endorsed by the TMOG author.

## Updating TMOG

When a new upstream AppImage is released:

1. Update `version` and the download URL in `package.nix`.
2. Fetch the new hash with `nix-prefetch-url <url>`.
3. Convert it to SRI format:

   ```bash
   nix hash convert --hash-algo sha256 --to sri <base32-hash>
   ```

4. Update the `hash` field.
5. Check the AppImage contents and update the desktop/icon paths if necessary.
6. Test with:

   ```bash
   nix build .#tmog --impure -L
   ./result/bin/tmog
   ```

## Clean-machine validation

Test the public interface from a directory outside this repository:

```bash
mkdir /tmp/test-tmog
cd /tmp/test-tmog
nix flake show github:thomasPeelmanUCLL/nixos-tmog
nix build github:thomasPeelmanUCLL/nixos-tmog
./result/bin/tmog
```

## CI

GitHub Actions runs `nix flake check` and builds the package on pushes and pull requests.
