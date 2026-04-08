# Recupera as zonas de disponibilidade disponíveis na região especificada 
# apenas para validar a configuração do provedor e garantir que a região 
# está correta. Isso é útil para evitar erros de configuração e garantir 
# que os recursos sejam criados na região desejada.
data "aws_availability_zones" "available" {
  state = "available"
  region = var.region
}