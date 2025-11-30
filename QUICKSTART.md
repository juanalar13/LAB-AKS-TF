# Quick Start Guide - AKS Lab

Este es un resumen rápido para ejecutar el laboratorio. Para detalles completos, consulta el README.md principal.

## ⚡ Inicio Rápido (5 pasos)

### 1️⃣ Login en Azure
```powershell
az login
az account show
```

### 2️⃣ Configurar Variables
Copia y edita el archivo de variables:
```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
# Edita terraform.tfvars con tus valores preferidos
```

### 3️⃣ Desplegar AKS
```powershell
terraform init
terraform plan
terraform apply -auto-approve
```
⏱️ Esto toma ~10 minutos

### 4️⃣ Conectar kubectl
```powershell
az aks get-credentials --resource-group rg-aks-lab --name aks-lab-cluster
kubectl get nodes
```

### 5️⃣ Desplegar NGINX
```powershell
cd ..
kubectl apply -f kubernetes/nginx-deployment.yaml
kubectl apply -f kubernetes/nginx-service.yaml
kubectl get service nginx-service --watch
```

Espera la EXTERNAL-IP y ábrela en tu navegador! 🎉

## 🧹 Limpieza Rápida

```powershell
kubectl delete -f kubernetes/
cd terraform
terraform destroy -auto-approve
```

## 📊 Comandos Útiles

```powershell
# Ver estado del cluster
kubectl get all

# Ver logs
kubectl logs -l app=nginx

# Escalar
kubectl scale deployment nginx-deployment --replicas=5

# Dashboard de Kubernetes (opcional)
az aks browse --resource-group rg-aks-lab --name aks-lab-cluster
```

## 🔗 Conectar con Lens

1. Instala Lens desde https://k8slens.dev/
2. Abre Lens - detectará automáticamente tu cluster
3. Haz clic en "aks-lab-cluster"
4. ¡Explora visualmente! 🎨

---

**Tiempo total estimado: 15-20 minutos** ⏱️
