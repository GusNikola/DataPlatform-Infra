# Deploys ingress-nginx via Helm with an AWS NLB in TCP passthrough mode.
# TLS is terminated by nginx — cert-manager issues Let's Encrypt certs via Cloudflare DNS-01.
# Port 80 is open so nginx can redirect HTTP to HTTPS.

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.11.3"
  namespace        = "ingress-nginx"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true

  values = [file("${path.module}/values.yaml")]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.17.1"
  namespace        = "cert-manager"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true

  set = [
    { name = "crds.enabled", value = "true" },
    { name = "nodeSelector.role", value = "core" },
    { name = "tolerations[0].key", value = "role" },
    { name = "tolerations[0].value", value = "core" },
    { name = "tolerations[0].effect", value = "NoSchedule" },
    { name = "tolerations[0].operator", value = "Equal" },
    { name = "cainjector.nodeSelector.role", value = "core" },
    { name = "cainjector.tolerations[0].key", value = "role" },
    { name = "cainjector.tolerations[0].value", value = "core" },
    { name = "cainjector.tolerations[0].effect", value = "NoSchedule" },
    { name = "cainjector.tolerations[0].operator", value = "Equal" },
    { name = "webhook.nodeSelector.role", value = "core" },
    { name = "webhook.tolerations[0].key", value = "role" },
    { name = "webhook.tolerations[0].value", value = "core" },
    { name = "webhook.tolerations[0].effect", value = "NoSchedule" },
    { name = "webhook.tolerations[0].operator", value = "Equal" },
    { name = "resources.requests.cpu", value = "50m" },
    { name = "resources.requests.memory", value = "64Mi" },
    { name = "resources.limits.cpu", value = "100m" },
    { name = "resources.limits.memory", value = "128Mi" },
    { name = "cainjector.resources.requests.cpu", value = "50m" },
    { name = "cainjector.resources.requests.memory", value = "64Mi" },
    { name = "cainjector.resources.limits.cpu", value = "100m" },
    { name = "cainjector.resources.limits.memory", value = "128Mi" },
    { name = "webhook.resources.requests.cpu", value = "50m" },
    { name = "webhook.resources.requests.memory", value = "64Mi" },
    { name = "webhook.resources.limits.cpu", value = "100m" },
    { name = "webhook.resources.limits.memory", value = "128Mi" },
  ]

  depends_on = [helm_release.ingress_nginx]
}
