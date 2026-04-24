# Cria o Cert-Manager no cluster EKS usando o Helm. 
# O Cert-Manager é uma ferramenta que automatiza a gestão de certificados TLS no Kubernetes,
# facilitando a obtenção, renovação e gerenciamento de certificados para aplicações que exigem comunicação segura.
resource "helm_release" "cert_manager" {
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

# Cria o segredo para o token da API da Cloudflare no namespace do cert-manager.
# Este segredo é necessário para que o Cert-Manager possa autenticar e gerenciar os registros DNS no Cloudflare, 
# especialmente para o desafio DNS-01 usado na validação de certificados com o Let's Encrypt.
resource "kubernetes_secret_v1" "cloudflare_api_token_cm" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "cert-manager"
  }

  data = {
    apiKey = var.cloudflare_api_token
  }
}

# Cria um recurso Kubernetes do tipo ClusterIssuer para o Cert-Manager, 
# configurado para usar o ACME com o Let's Encrypt.
# O ClusterIssuer define como o Cert-Manager deve obter e renovar certificados TLS.
# Neste caso, estamos configurando o ClusterIssuer para usar o desafio DNS-01 com o provedor Cloudflare, 
# permitindo que o Cert-Manager gerencie os registros DNS necessários para validar a propriedade do domínio 
# e obter os certificados TLS de forma automatizada.
resource "kubernetes_manifest" "cluster_issuer" {
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
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "cloudflare-api-token"
                  key  = "apiKey"
                }
              }
            }
          }
        ]
      }
    }
  }
}