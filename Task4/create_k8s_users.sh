#!/bin/bash

set -e
trap 'echo "❌ Ошибка на строке $LINENO. Нажми Enter для выхода..."; read' ERR

# === Параметры ===
CLUSTER_NAME="minikube"
NAMESPACE="default"

# === Пути к CA Kubernetes (обычно в Minikube или kubeadm-кластере) ===
CA_CERT="$HOME/.minikube/ca.crt"
CA_KEY="$HOME/.minikube/ca.key"

# === Список пользователей ===
USERS=("user-dev" "user-devops")

for USER in "${USERS[@]}"; do
  echo "📌 Создаю пользователя: $USER"

  # Генерация ключа и CSR
  openssl genrsa -out "${USER}.key" 2048
  openssl req -new -key "${USER}.key" -out "${USER}.csr" -subj "//CN=${USER}"

  # Подпись сертификата
  openssl x509 -req -in "${USER}.csr" -CA "$CA_CERT" -CAkey "$CA_KEY" \
    -CAcreateserial -out "${USER}.crt" -days 365

  # Добавление в kubeconfig
  kubectl config set-credentials "$USER" \
    --client-certificate="${USER}.crt" \
    --client-key="${USER}.key"

  # Создание контекста
  kubectl config set-context "${USER}-context" \
    --cluster="$CLUSTER_NAME" \
    --namespace="$NAMESPACE" \
    --user="$USER"

  echo "✅ Пользователь $USER создан и добавлен в kubeconfig."
  echo
done

echo "✨ Все пользователи успешно созданы!"
