# Atualização Automatizada de Nodes Kubernetes

Este projeto fornece uma solução automatizada para atualizar os nodes de um cluster Kubernetes. Utiliza um `CronJob` Kubernetes para executar um script de atualização em cada node do cluster, um de cada vez.

## Arquivos do Projeto

- **`cronjob.yaml`**: Define o `CronJob` responsável por disparar a atualização nos nodes.
- **`Dockerfile`**: Cria uma imagem Docker que contém o script e ferramentas necessárias para a atualização.
- **`rbac.yaml`**: Configura permissões RBAC para permitir que o `CronJob` execute operações nos nodes.
- **`upgrade.sh`**: Script executado no container que realiza a atualização do sistema operacional e lida com o gerenciamento de nodes.