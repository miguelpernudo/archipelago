{ config, ... }: {
  environment.etc."k3s-manifests/gitea.yaml".text = ''
    apiVersion: v1
    kind: Namespace
    metadata:
      name: gitea
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: gitea
      namespace: gitea
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: gitea
      template:
        metadata:
          labels:
            app: gitea
        spec:
          containers:
          - name: gitea
            image: gitea/gitea:latest
            env:
            - name: USER_UID
              value: "1000"
            - name: USER_GID
              value: "1000"
            ports:
            - containerPort: 3000
            - containerPort: 22
            volumeMounts:
            - name: data
              mountPath: /data
          volumes:
          - name: data
            hostPath:
              path: /var/lib/gitea
              type: DirectoryOrCreate
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: gitea
      namespace: gitea
    spec:
      type: NodePort
      ports:
      - name: http
        port: 3000
        targetPort: 3000
        nodePort: 30300
      - name: ssh
        port: 22
        targetPort: 22
        nodePort: 30220
      selector:
        app: gitea
  '';

  services.traefik.dynamicConfigOptions.http = {
    routers.gitea = {
      rule    = "Host(`gitea.angler`)";
      service = "gitea";
    };
    services.gitea.loadBalancer.servers = [{
      url = "http://127.0.0.1:30300";
    }];
  };
}
