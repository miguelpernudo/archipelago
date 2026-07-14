{ config, ... }:

{
  services.unbound = {
    enable = true;
    settings = {
    
      server = {
        interface = [ "10.10.0.1" "127.0.0.1" ];
        access-control = [ "10.10.0.0/24 allow" "127.0.0.0/8 allow" ];
        module-config = "\"respip validator iterator\"";  # for rpz.
      };
      
      forward-zone = [{
        name = ".";
        forward-tls-upgrade = true;
        forward-addr = [
          "9.9.9.9@853#dns.quad9.net"
        ];
      }];
      
      rpz = [{
        name = "hageziPro";
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/rpz/pro.txt";
      }];
    };
  };
}
