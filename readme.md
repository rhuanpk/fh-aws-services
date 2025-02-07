# fh-aws-services

Este repositório contém a configuração do Terraform para provisionar um cluster EKS na AWS, juntamente com vários serviços Kubernetes, incluindo MySQL RDS, e serviços de usuário, rastreamento de status e upload de vídeo.

## Estrutura do Repositório

- `main.tf`: Arquivo principal que define os recursos e módulos do Terraform.
- `variables.tf`: Define as variáveis de entrada para o Terraform.
- `outputs.tf`: Define os outputs do Terraform.
- `terraform.tfvars`: Arquivo que contém os valores das variáveis de entrada.
- `modules/`: Diretório que contém os módulos do Terraform para diferentes componentes.

## Pré-requisitos

- Terraform instalado na sua máquina.
- Credenciais da AWS configuradas na sua máquina.

## Configuração

### Variáveis

As variáveis necessárias estão definidas no arquivo `variables.tf`. Você pode fornecer os valores dessas variáveis no arquivo `terraform.tfvars`.

Exemplo de `terraform.tfvars`:

```hcl
AWS_ACCESS_KEY_ID                   = "seu_access_key_id"
AWS_SECRET_KEY                      = "seu_secret_key"
AWS_SESSION_TOKEN                   = "seu_session_token"
AWS_COGNITO_USER_POOL_ID            = "seu_user_pool_id"
AWS_COGNITO_USER_POOL_CLIENT_ID     = "seu_user_pool_client_id"
AWS_COGNITO_USER_POOL_CLIENT_SECRET = "seu_user_pool_client_secret"
AWS_REGION                          = "us-east-1"
STATUS_TRACKER_DATASOURCE_USERNAME  = "usuario_banco"
STATUS_TRACKER_DATASOURCE_PASSWORD  = "senha_banco"
AWS_S3_BUCKET_NAME                  = "seu_bucket_name"
```

## Módulos

- `eks-cluster`: Provisiona o cluster EKS.
- `service-user`: Provisiona o serviço de usuário no Kubernetes.
- `service-status-tracker`: Provisiona o serviço de rastreamento de status no Kubernetes.
- `service-video-upload`: Provisiona o serviço de upload de vídeo no Kubernetes.
- `namespaces`: Cria namespaces no Kubernetes.

## Outputs

Os outputs definidos no arquivo `outputs.tf` incluem:

- `mysql_endpoint`: Endpoint do banco de dados MySQL.
- `mysql_db_name`: Nome do banco de dados MySQL.
- `service_user_load_balancer_hostname`: Hostname do load balancer do serviço de usuário.
- `service_status_tracker_load_balancer_hostname`: Hostname do load balancer do serviço de rastreamento de status.

## Uso

Inicialize o Terraform:

```bash
terraform init
```

Planeje a execução:

```bash
terraform plan
```

Aplique a configuração:

```bash
terraform apply
```

## Estrutura dos Arquivos

### `main.tf`

Define os recursos principais, incluindo o cluster EKS, sub-redes, grupos de segurança e instância RDS MySQL.

### `variables.tf`

Define as variáveis de entrada para o Terraform.

### `outputs.tf`

Define os outputs do Terraform.

### `eks-cluster`

Define o módulo para provisionar o cluster EKS.

### `service-user`

Define o módulo para provisionar o serviço de usuário no Kubernetes.

### `service-status-tracker`

Define o módulo para provisionar o serviço de rastreamento de status no Kubernetes.

### `service-video-upload`

Define o módulo para provisionar o serviço de upload de vídeo no Kubernetes.

### `namespaces`

Define o módulo para criar namespaces no Kubernetes.

## Contribuição

Sinta-se à vontade para abrir issues e pull requests para melhorias e correções.

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.
