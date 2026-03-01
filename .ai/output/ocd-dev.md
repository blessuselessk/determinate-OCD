## Context: ocd-dev-ctx
| Key | Value |
| --- | ----- |
| ocd-dev-aspect | den.aspects.ocd-dev — includes tty-autologin for admin, grub disabled, fake root filesystem |
| admin-aspect | den.aspects.admin — includes den.provides.primary-user |
| boot | boot.loader.grub.enable = false (no real bootloader) |
| filesystem | fileSystems."/".device = "/dev/fake" (satisfies NixOS eval, not bootable) |
| pattern | Takes `den` argument; defines two den.aspects (ocd-dev host + admin user) |