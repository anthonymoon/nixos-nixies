{
  default = {
    path = ./default;
    description = "Default NixOS Unified configuration template";
    welcomeText = ''
      Welcome to NixOS Unified!
      This template provides a complete NixOS configuration framework with:
      - Security-first defaults
      - Modular architecture
      - Performance optimizations
      - Multiple deployment profiles
      Edit flake.nix to customize your configuration.
    '';
  };
}
