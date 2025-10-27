#!/bin/bash

# Week 5 ArgoCD Deployment Script
# This script sets up ArgoCD applications for the simple-app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ARGOCD_NAMESPACE="argocd"
REPO_URL="https://github.com/tamngo179/BT-PTUDDN.git"
ARGOCD_SERVER="${ARGOCD_SERVER:-localhost:8080}"

echo -e "${BLUE}🚀 Week 5 ArgoCD Setup Script${NC}"
echo "=================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command_exists kubectl; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

if ! command_exists argocd; then
    echo -e "${YELLOW}⚠️  ArgoCD CLI not found. Installing...${NC}"
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
    echo -e "${GREEN}✅ ArgoCD CLI installed${NC}"
fi

# Check if ArgoCD is installed in cluster
echo -e "${YELLOW}🔍 Checking ArgoCD installation...${NC}"
if ! kubectl get namespace $ARGOCD_NAMESPACE >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  ArgoCD not found. Installing ArgoCD...${NC}"
    
    # Install ArgoCD
    kubectl create namespace $ARGOCD_NAMESPACE
    kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    echo -e "${YELLOW}⏳ Waiting for ArgoCD to be ready...${NC}"
    kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $ARGOCD_NAMESPACE
    
    # Get admin password
    ADMIN_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo -e "${GREEN}✅ ArgoCD installed successfully${NC}"
    echo -e "${BLUE}🔐 Admin password: $ADMIN_PASSWORD${NC}"
    
    # Expose ArgoCD server (for local development)
    echo -e "${YELLOW}🌐 Exposing ArgoCD server...${NC}"
    kubectl patch svc argocd-server -n $ARGOCD_NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'
else
    echo -e "${GREEN}✅ ArgoCD already installed${NC}"
fi

# Login to ArgoCD
echo -e "${YELLOW}🔐 Logging in to ArgoCD...${NC}"
if [[ -n "${ARGOCD_TOKEN}" ]]; then
    argocd login $ARGOCD_SERVER --auth-token $ARGOCD_TOKEN --insecure --grpc-web
else
    echo -e "${BLUE}Please login to ArgoCD manually:${NC}"
    echo "argocd login $ARGOCD_SERVER"
    echo -e "${YELLOW}Press Enter after logging in...${NC}"
    read -r
fi

# Create ArgoCD Project
echo -e "${YELLOW}📁 Creating ArgoCD Project...${NC}"
if kubectl apply -f week\ 5/argocd/project.yaml; then
    echo -e "${GREEN}✅ Project created/updated${NC}"
else
    echo -e "${RED}❌ Failed to create project${NC}"
    exit 1
fi

# Create ArgoCD Applications
echo -e "${YELLOW}🚀 Creating ArgoCD Applications...${NC}"
if kubectl apply -f week\ 5/argocd/applications.yaml; then
    echo -e "${GREEN}✅ Applications created/updated${NC}"
else
    echo -e "${RED}❌ Failed to create applications${NC}"
    exit 1
fi

# Setup notifications (optional)
echo -e "${YELLOW}📢 Setting up notifications...${NC}"
if kubectl apply -f week\ 5/argocd/notifications.yaml; then
    echo -e "${GREEN}✅ Notifications configured${NC}"
else
    echo -e "${YELLOW}⚠️  Notifications setup failed (optional)${NC}"
fi

# Create namespaces
echo -e "${YELLOW}🏗️  Creating target namespaces...${NC}"
kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✅ Namespaces created${NC}"

# Sync applications
echo -e "${YELLOW}🔄 Syncing applications...${NC}"
argocd app sync simple-app-staging --prune || echo -e "${YELLOW}⚠️  Staging sync failed (may be normal on first run)${NC}"

# Check application status
echo -e "${YELLOW}📊 Checking application status...${NC}"
echo ""
echo -e "${BLUE}Staging Application:${NC}"
argocd app get simple-app-staging --show-params || echo -e "${YELLOW}⚠️  Application not ready yet${NC}"

echo ""
echo -e "${BLUE}Production Application:${NC}"
argocd app get simple-app-production --show-params || echo -e "${YELLOW}⚠️  Application not ready yet${NC}"

# Final instructions
echo ""
echo -e "${GREEN}🎉 ArgoCD Setup Complete!${NC}"
echo "=================================="
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Access ArgoCD UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Open: https://localhost:8080"
echo ""
echo "2. Configure GitHub Secrets:"
echo "   ARGOCD_SERVER: $ARGOCD_SERVER"
echo "   ARGOCD_TOKEN: <generate using 'argocd account generate-token --account github-actions'>"
echo ""
echo "3. Push changes to trigger CI/CD pipeline"
echo ""
echo -e "${BLUE}🔗 Useful Commands:${NC}"
echo "   argocd app list"
echo "   argocd app sync simple-app-staging"
echo "   kubectl get pods -n staging"
echo "   kubectl logs -n staging -l app=simple-app"
echo ""
echo -e "${GREEN}Happy deploying! 🚀${NC}"