{ config, ... }:

{
  imports = [
    #./hardware.nix
    ./disko.nix
    ./networking.nix
    ./boot.nix

    ### Core
    ../../modules/core

    ### Users
    ../../modules/users/admin.nix

    ### Default
    ../../modules/security/apparmor.nix
    ../../modules/security/tools.nix

    ### Services
    ../../modules/services/ssh.nix
    ../../modules/services/observability.nix
    ../../modules/services/freeradius.nix
    ../../modules/services/goflow2.nix

    ### Profiles
    ../../modules/profiles/minimal.nix
    ../../modules/profiles/headless.nix
    
  ];

  specialisation."rescue".configuration = {
    imports = [
      ../../modules/specialisations/rescue.nix
    ];
  };

  sops.defaultSopsFile = ../../secrets/angler.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Change everything to your settings.
  mySettings = {
    locale   = "es_ES.UTF-8"; 
    timeZone = "Europe/Madrid";  
    keyMap   = "es";

    #rescueDisableServices = [ "podman" ];
      
    nix = {
      gcDates = "daily";
      deleteOlder = "4d";
      autoUpgrade = false;
      useNixld = false;
    };
  };    

  users.mutableUsers = true;
  nix.settings.trusted-users = [ "admin" ];

  # Change this at your own risk.
  system.stateVersion = "25.11";
}
