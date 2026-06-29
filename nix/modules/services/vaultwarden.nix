{ config, ... }: {
  environment.etc."k3s-manifests/vaultwarden.yaml".text = ''
    apiVersion: v1
    kind: Namespace
    metadata:
      name: vaultwarden
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: vaultwarden
      namespace: vaultwarden
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: vaultwarden
      template:
        metadata:
          labels:
            app: vaultwarden
        spec:
          containers:
          - name: vaultwarden
            image: vaultwarden/server:latest
            env:
            - name: ADMIN_TOKEN
              value: "changeme-admin-token"
            - name: SIGNUPS_ALLOWED
              value: "false"
            ports:
            - containerPort: 80
            volumeMounts:
            - name: data
              mountPath: /data
          volumes:
          - name: data
            hostPath:
              path: /var/lib/vaultwarden
              type: DirectoryOrCreate
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: vaultwarden
      namespace: vaultwarden
    spec:
      type: NodePort
      ports:
      - port: 80
        targetPort: 80
        nodePort: 30800
      selector:
        app: vaultwarden
  '';

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule    = "Host(`vaultwarden.angler`)";
      service = "vaultwarden";
    };
    services.vaultwarden.loadBalancer.servers = [{
      url = "http://127.0.0.1:30800";
    }];
  };
}
