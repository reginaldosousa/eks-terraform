# Cria o Cert-Manager no cluster EKS usando o Helm. 
# O Cert-Manager é uma ferramenta que automatiza a gestão de certificados TLS no Kubernetes,
# facilitando a obtenção, renovação e gerenciamento de certificados para aplicações que exigem comunicação segura.
resource "helm_release" "cert-manager" {
  repository       = "oci://quay.io/jetstack/charts"
  chart            = "cert-manager"
  name             = "cert-manager"
  version          = "1.20.0"
  namespace        = "cert-manager"
  create_namespace = true

  values = [
    yamlencode({
      crds : {
        enabled : true
      }
    })
  ]
}

resource "kubernetes_manifest" "cluster-issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = kubernetes_ingress_class_v1.ingress-class.metadata[0].name
              }
            }
          }
        ]
      }
    }
  }
}