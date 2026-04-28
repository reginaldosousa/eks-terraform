resource "kubernetes_ingress_class_v1" "ingress_class" {
  metadata {
    name = "alb"
    labels = {
      "app.kubernetes.io/name" : "LoadBalancerController"
    }
  }
  spec {
    controller = "eks.amazonaws.com/alb"
  }
}