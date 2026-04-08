module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.17"

  name = "${var.project_name}-eks"

  # A versão do Kubernetes a ser usada no cluster. É importante escolher uma versão
  # que seja compatível com os recursos e funcionalidades que você planeja usar
  kubernetes_version = "1.35"
  # A opção endpoint_public_access controla se o endpoint do cluster EKS será acessível publicamente.
  endpoint_public_access = true

  # Habilita permissões administrativas para o criador do cluster, 
  # permitindo que o usuário que criou o cluster tenha acesso total ao cluster EKS. 
  # Isso é útil para facilitar a administração do cluster, 
  # especialmente durante a fase de configuração e testes iniciais
  enable_cluster_creator_admin_permissions = true

  # Configurações para o pool de nós do cluster EKS. 
  # Neste caso, estamos habilitando um pool de nós chamado "general-purpose", que é o pool de nós padrão para computação. 
  # Isso significa que os nós do cluster serão configurados para executar cargas de trabalho gerais, 
  # e o EKS gerenciará automaticamente a escalabilidade e a disponibilidade dos nós com base na demanda do cluster.
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = local.default_tags
}