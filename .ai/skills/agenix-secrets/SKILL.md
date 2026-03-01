---
name: agenix-secrets
description: |
  Agenix secret management patterns — encrypting, wiring, and referencing
  secrets in NixOS aspects. Use when creating, modifying, or consuming
  encrypted secrets.
---

## When This Skill Triggers

You are creating, modifying, or wiring encrypted secrets via agenix.

## Quick Rules

1. **Encrypted at rest** — `.age` files in `modules/<user>/secrets/` are age-encrypted
2. **Decrypted at activation** — NixOS activation decrypts to `/run/agenix/<name>`
3. **Reference by path only** — use `config.age.secrets.<name>.path`, never inline secret values
4. **Key management** — age recipients (public keys) determine who can decrypt; add host and user keys
5. **Not yet wired** — agenix is in the stack reference but not yet added as a flake input; this skill documents the intended pattern

## Encryption Pattern

### Create a secret
```bash
# Encrypt a secret for specific recipients
age -r "ssh-ed25519 AAAA..." -r "age1..." secret.txt > modules/<user>/secrets/secret.age

# Or use agenix CLI with secrets.nix
cd modules/<user>/secrets
agenix -e secret.age
```

### Define secrets in a secrets aspect
```nix
# modules/<user>/secrets.nix
{ config, ... }:
{
  age.secrets.my-api-key = {
    file = ./secrets/my-api-key.age;
    owner = "<user>";
    group = "users";
    mode = "0400";
  };
}
```

## Wiring Pattern

### Consume a secret in another aspect
```nix
# modules/<user>/some-service.nix
{ config, ... }:
{
  <user>.some-service = {
    includes = [ <<user>.secrets> ];
    nixos = {
      services.some-service = {
        enable = true;
        environmentFile = config.age.secrets.my-api-key.path;
      };
    };
  };
}
```

Key points:
- Always use `includes` to declare the dependency on the secrets aspect
- Never hardcode `/run/agenix/...` paths — use `config.age.secrets.<name>.path`
- The secret file is only available at activation time, not at eval time

## Detailed References

- [Stack reference](../../context/stack.context.md)
