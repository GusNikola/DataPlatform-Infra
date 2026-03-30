#!/bin/bash
# ArgoCD bootstrap — run once after EKS cluster and nginx ingress are up.
# Prerequisites: kubectl configured for the cluster, argocd CLI installed.
set -e

ARGOCD_HOST="argocd.gusnikola.com"

# kubectl create namespace argocd
# kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=180s

kubectl patch configmap argocd-cmd-params-cm -n argocd \
  --type merge -p '{"data":{"server.insecure":"true"}}'

helm install argocd-ingress ../../helm/argocd -n argocd
kubectl rollout restart deployment argocd-server -n argocd
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s

ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d)

argocd login "$ARGOCD_HOST" --username admin --password "$ARGOCD_PASSWORD" --grpc-web
argocd cluster add "$(kubectl config current-context)" --yes

# Register upstream Helm repos so ArgoCD can resolve chart dependencies at sync time
argocd repo add https://prometheus-community.github.io/helm-charts \
  --type helm --name prometheus-community
argocd repo add https://helm.elastic.co \
  --type helm --name elastic
argocd repo add https://fluent.github.io/helm-charts \
  --type helm --name fluent
argocd repo add https://open-telemetry.github.io/opentelemetry-helm-charts \
  --type helm --name opentelemetry
argocd repo add https://grafana.github.io/helm-charts \
  --type helm --name grafana

echo ""
echo "ArgoCD ready at: https://$ARGOCD_HOST"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
