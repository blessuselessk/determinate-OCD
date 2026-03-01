{ den, ... }:
{
  den.aspects.mclovin = {
    darwin = {
      system.stateVersion = 6;
      security.pam.services.sudo_local.touchIdAuth = true;
    };
  };

  den.aspects.lessuseless = {
    includes = [
      den.provides.primary-user
    ];
  };
}
