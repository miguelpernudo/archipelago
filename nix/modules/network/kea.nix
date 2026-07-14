{ config, ... }:

{
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [ "/enx.*/" ];

      lease-database = {
        type = "memfile";
        persist = true;
        name = "/var/lib/kea/dhcp4.leases";
      };

      subnet4 = [{
        id = 1;
        subnet = "10.10.0.0/24";
        pools = [{ pool = "10.10.0.100 - 10.10.0.200"; }];

        option-data = [
          { name = "routers";             data = "10.10.0.1"; }
          { name = "domain-name-servers"; data = "10.10.0.1, 9.9.9.9"; }
        ];
      }];

      valid-lifetime = 86400;
      renew-timer    = 3600;
    };
  };
}
