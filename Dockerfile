FROM ubuntu:latest

# Instalar pacotes necessários
RUN apt-get update && apt-get install -y \
    curl \
    apt-transport-https \
    gnupg \
    lsb-release \
    ssh \
    iproute2 \
    && apt-get clean

# Instalar kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Copiar o script para a imagem
COPY upgrade.sh /scripts/upgrade.sh
RUN chmod +x /scripts/upgrade.sh

# Comando padrão para o contêiner
CMD ["/bin/bash", "/scripts/upgrade.sh"]