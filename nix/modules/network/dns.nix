{ config, ... }:

{ 
  services.resolved = {
    enable = true;
     
    settings.Resolve = {
      DNSOverTLS = "true";
      DNSSEC = "true";
      
      FallbackDNS = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
        "1.1.1.1#cloudflare-dns.com" 
        "1.0.0.1#cloudflare-dns.com"
      ];
    };
  };
  
  networking.nameservers = [ "127.0.0.1" "9.9.9.9" ];
}
