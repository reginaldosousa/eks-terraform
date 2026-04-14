# Instalação do Traefik usando Helm
# O Traefik é um popular Ingress Controller para Kubernetes, 
# que facilita a gestão de tráfego de entrada para as aplicações rodando no cluster. 
# Ele suporta diversas funcionalidades, como roteamento baseado em regras, TLS, 
# autenticação e integração com diversos provedores de serviços.
resource "helm_release" "traefik" {
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  name             = "traefik"
  namespace        = "traefik"
  create_namespace = true
  values = [
    yamlencode(
      {
        service : {
          # Configura o Traefik para usar um Load Balancer do tipo NLB (Network Load Balancer) da AWS,
          # que é mais eficiente para lidar com tráfego de alta performance e suporta IPs como targets, 
          # ideal para clusters EKS.
          annotations : {
            "service.beta.kubernetes.io/aws-load-balancer-type" : "external"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "ip"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internet-facing"
          }
        }
    })
  ]
}