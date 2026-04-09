resource "kubernetes_ingress_class_v1" "ingress-class" {
  metadata {
    name = "alb"
    labels = {
      "app.kubernetes.io/name": "LoadBalancerController"
    }
  }
  spec {
    controller = "eks.amazonaws.com/alb"
  }
}

resource "helm_release" "grafana" {
  repository = "https://grafana-community.github.io/helm-charts"
  chart = "grafana"
  name = "grafana"

  set = [
    {
      name = "ingress.enabled"
      value = "true"
    },
    {
      name = "ingress.ingressClassName"
      value = kubernetes_ingress_class_v1.ingress-class.metadata[0].name
    },
    {
      name = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io\\/scheme"
      value = "internet-facing"
    },
    {
      name = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io\\/target-type"
      value = "ip"
    }
  ]
  set_list = [ {
    name = "ingress.hosts"
    value = ["grafana.reginaldosousa.com.br"]
  } ]
}