# Secret para armazenar o token de API do Cloudflare, que é necessário para que 
# o ExternalDNS possa autenticar e gerenciar os registros DNS no Cloudflare.
resource "kubernetes_secret_v1" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "kube-system"
  }

  data = {
    apiKey = var.cloudflare_api_token
  }
}

# Recurso Helm para instalar o ExternalDNS no cluster EKS. O ExternalDNS é uma ferramenta que permite
# que o Kubernetes gerencie automaticamente os registros DNS em provedores de DNS como o Cloudflare. 
# Neste caso, estamos configurando o ExternalDNS para usar o provedor Cloudflare e fornecendo o 
# token de API do Cloudflare através de um segredo Kubernetes. 
# Isso permite que o ExternalDNS autentique e gerencie os registros DNS no Cloudflare 
# com base nas mudanças no cluster Kubernetes, como a criação ou exclusão de serviços e ingressos.
resource "helm_release" "external_dns" {
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  name       = "external-dns"
  version    = "1.20.0"
  namespace  = "kube-system"

  values = [
    yamlencode({
      provider : {
        name : "cloudflare"
      }
      env : [
        { name : "CF_API_TOKEN"
          valueFrom : {
            secretKeyRef : {
              name : kubernetes_secret_v1.cloudflare_api_token.metadata[0].name
              key : "apiKey"
            }
          }
      }]
    })
  ]
}