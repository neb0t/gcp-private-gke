apiVersion: v1
clusters:
- cluster:
    proxy-url: http://${bastion_proxy_user}:${bastion_proxy_pass}@${bastion_proxy_ip}:${bastion_proxy_port}
    certificate-authority-data: ${cluster_ca_certificate}
    server: https://${endpoint}
  name: ${context}
contexts:
- context:
    cluster: ${context}
    user: ${context}
  name: ${context}
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${context}
  user:
    token: ${token}
