resource "helm_release" "grafana" {
  repository = "https://grafana-community.github.io/helm-charts"
  chart      = "grafana"
  name       = "grafana"

  values = [
    yamlencode({
      ingress : {
        enabled : true
        # Configura o Ingress para usar a classe de Ingress do Traefik, 
        # garantindo que o tráfego seja roteado corretamente para o Grafana.
        ingressClassName : "traefik"
        annotations : {
          # Configura o Ingress para usar o ClusterIssuer do cert-manager para obter certificados TLS automaticamente,
          # garantindo que o tráfego para o Grafana seja seguro usando HTTPS.
          "cert-manager.io/cluster-issuer" : "letsencrypt-prod"
        }
        hosts : ["grafana.reginaldosousa.com.br"]
        tls : [{
          # Especifica o nome do segredo TLS que o cert-manager deve criar para armazenar 
          # o certificado obtido para o domínio do Grafana.
          secretName : "grafana-tls"
          hosts : ["grafana.reginaldosousa.com.br"]
        }]
      }
    })
  ]
}