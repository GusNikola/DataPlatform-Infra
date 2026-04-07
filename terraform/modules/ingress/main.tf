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

  set = [{ name = "crds.enabled", value = "true" }]

  depends_on = [helm_release.ingress_nginx]
}
