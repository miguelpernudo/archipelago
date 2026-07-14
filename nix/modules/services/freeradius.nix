{ config, pkgs, lib, ... }:

let
  raddb = pkgs.runCommand "freeradius-config" {
    buildInputs = [ pkgs.openssl ];
  } ''
    cp -r ${pkgs.freeradius}/etc/raddb/* $out/
    chmod -R +w "$out/"

    # Generate self-signed certificates.
    cd "$out/certs"
    cat > ca.cnf << CNFEOF
    [ ca ]
    default_ca = CA_default

    [ CA_default ]
    database    = index.txt
    serial      = serial
    new_certs_dir = newcerts
    default_md  = sha256
    policy      = policy_loose

    [ req ]
    default_bits       = 2048
    distinguished_name = req_distinguished_name
    x509_extensions    = v3_ca
    prompt             = no

    [ req_distinguished_name ]
    CN = Archipelago CA

    [ v3_ca ]
    basicConstraints       = critical, CA:TRUE
    keyUsage               = keyCertSign, cRLSign
    subjectKeyIdentifier   = hash
    authorityKeyIdentifier = keyid:always,issuer:always

    [ policy_loose ]
    CN = supplied
    CNFEOF

    touch index.txt
    echo 01 > serial
    mkdir -p newcerts

    openssl req -x509 -new -nodes -config ca.cnf \
      -out ca.pem -keyout ca.key -days 3650

    openssl req -new -nodes -newkey rsa:2048 \
      -keyout server.key -out server.csr \
      -subj "/CN=angler.lan"

    openssl ca -batch -config ca.cnf \
      -in server.csr -out server.pem -days 3650

    openssl dhparam -out dh 2048 2>/dev/null

    rm -rf newcerts
    rm -f server.csr index.txt* serial* ca.cnf
    cd "$out"

    sed -i 's/default_eap_type = md5/default_eap_type = peap/' "$out/mods-available/eap"

    cat > "$out/clients.conf" << EOF
    \$INCLUDE /run/freeradius/clients.conf
    EOF

    echo '\$INCLUDE /run/freeradius/users.conf' >> "$out/mods-config/files/authorize"
  '';
in {
  services.freeradius = {
    enable = true;
    configDir = raddb;
  };

  sops.secrets = {
    radius_secret = { };
    wifi_password  = { };
  };

  systemd.services.freeradius = {
    after = [ "sops-activation.service" ];
    wants = [ "sops-activation.service" ];
    preStart = lib.mkBefore ''
      cat > /run/freeradius/clients.conf << EOF
      client localhost {
        ipaddr = 127.0.0.1
        secret = testing123
      }
      client lan {
        ipaddr = 10.10.0.0/24
        secret = $(< ${config.sops.secrets.radius_secret.path})
        shortname = lan
      }
      EOF

      cat > /run/freeradius/users.conf << EOF
      client   Cleartext-Password := "$(< ${config.sops.secrets.wifi_password.path})"
      EOF
    '';
    serviceConfig = {
      RuntimeDirectory = "freeradius";
      RuntimeDirectoryMode = "755";
    };
  };
}