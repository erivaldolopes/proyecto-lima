# Aplicação Kubernetes com MySQL e Flask

Este repositório contém uma aplicação Kubernetes simples com um banco de dados MySQL e uma aplicação Flask rodando no Nginx. O objetivo é ensinar o uso de recursos do Kubernetes, como ConfigMaps, Secrets, Persistent Volumes e Services.

## Estrutura

- `app`: Flask com uma página para listar usuários e um formulário para adicionar novos.
- `MySQL`: Banco de dados com exemplo de tabela e dados iniciais.
- `ConfigMap`: Define arquivos HTML para o frontend da aplicação.
- `Secret`: Armazena as credenciais do banco de dados.
- `PersistentVolume`: Armazena dados do MySQL de forma persistente.

## Como rodar

1. Crie o namespace:

   ```
   kubectl apply -f manifests/namespace.yaml
   ```

2. Aplique o Secret para credenciais do MySQL:

    ```
    kubectl apply -f manifests/mysql-secret.yaml
    ```

3. Crie o PersistentVolume e PersistentVolumeClaim:

    ```
    kubectl apply -f manifests/mysql-pv.yaml
    ```

4. Importe os dados iniciais:

    ```
    kubectl apply -f manifests/mysql-initdb-configmap.yaml
    ```

5. Crie o deployment e service do MySQL:

    ```
    kubectl apply -f manifests/mysql-deployment.yaml
    ```

6. Crie o ConfigMap para a aplicação:

    ```
    kubectl apply -f manifests/app-configmap.yaml
    ```

7. Crie o deployment da aplicação Flask:

    ```
    kubectl apply -f manifests/app-deployment.yaml
    ```

8. Exponha a aplicação com o Service:

    ```
    kubectl apply -f manifests/app-service.yaml
    ```

9. Acesse a aplicação via NodePort no IP do cluster, porta 30007.

### 5. Conclusão

Essa aplicação Kubernetes completa oferece uma maneira prática de ensinar conceitos como volumes persistentes, secrets, configmaps, e interação com um banco de dados em um cluster Kubernetes.