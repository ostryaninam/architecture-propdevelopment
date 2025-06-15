#!/bin/bash
set -e
trap 'echo "❌ Ошибка на строке $LINENO. Нажми Enter для выхода..."; read' ERR

# === Настройки ===
CLUSTER_NAME="minikube"
NAMESPACE="default"

# === Привязки к ClusterRole ===
echo "🔗 Создаю ClusterRoleBindings..."

kubectl create clusterrolebinding devops-cluster-manage-binding \
  --clusterrole=cluster-manage \
  --user=user-devops || true

kubectl create clusterrolebinding devops-secret-viewer-binding \
  --clusterrole=secret-viewer \
  --user=user-devops || true

# === Привязки к Role ===
echo "🔗 Создаю RoleBindings в namespace $NAMESPACE..."

kubectl create rolebinding dev-namespace-viewer-binding \
  --role=namespace-viewer \
  --user=user-dev \
  --namespace=$NAMESPACE || true

echo "✅ Все привязки созданы."
