# Comandos Útiles - Lab AKS Terraform

Esta es una referencia rápida de comandos útiles para trabajar con el laboratorio.

## 📦 Azure CLI

### Gestión de Cuenta
```powershell
# Login
az login

# Ver cuenta actual
az account show

# Listar todas las suscripciones
az account list --output table

# Cambiar suscripción
az account set --subscription "SUBSCRIPTION_ID"

# Ver información de la región
az account list-locations --output table
```

### Gestión de AKS
```powershell
# Listar clusters AKS
az aks list --output table

# Ver detalles del cluster
az aks show --resource-group rg-aks-lab --name aks-lab-cluster

# Obtener credenciales
az aks get-credentials --resource-group rg-aks-lab --name aks-lab-cluster

# Ver versiones disponibles de Kubernetes
az aks get-versions --location eastus --output table

# Actualizar cluster (cambiar versión)
az aks upgrade --resource-group rg-aks-lab --name aks-lab-cluster --kubernetes-version 1.28.0

# Escalar node pool
az aks scale --resource-group rg-aks-lab --name aks-lab-cluster --node-count 3

# Ver logs del cluster
az aks show --resource-group rg-aks-lab --name aks-lab-cluster --query "agentPoolProfiles[0]"

# Abrir dashboard de Kubernetes (deprecado pero útil)
az aks browse --resource-group rg-aks-lab --name aks-lab-cluster
```

### Gestión de Resource Groups
```powershell
# Listar resource groups
az group list --output table

# Ver recursos en un resource group
az resource list --resource-group rg-aks-lab --output table

# Eliminar resource group (¡CUIDADO!)
az group delete --name rg-aks-lab --yes --no-wait
```

## 🔧 Terraform

### Comandos Básicos
```powershell
# Inicializar Terraform
terraform init

# Validar configuración
terraform validate

# Formatear archivos
terraform fmt

# Ver plan de ejecución
terraform plan

# Aplicar cambios
terraform apply

# Aplicar sin confirmación
terraform apply -auto-approve

# Destruir infraestructura
terraform destroy

# Destruir sin confirmación
terraform destroy -auto-approve

# Ver estado actual
terraform show

# Listar recursos en el estado
terraform state list

# Ver outputs
terraform output

# Ver output específico
terraform output cluster_name

# Refrescar estado
terraform refresh
```

### Comandos Avanzados
```powershell
# Importar recurso existente
terraform import azurerm_resource_group.aks_rg /subscriptions/SUBSCRIPTION_ID/resourceGroups/rg-aks-lab

# Ver gráfico de dependencias
terraform graph | dot -Tpng > graph.png

# Aplicar con variables específicas
terraform apply -var="node_count=3"

# Aplicar con archivo de variables diferente
terraform apply -var-file="production.tfvars"

# Limpiar estado corrupto
terraform state rm azurerm_kubernetes_cluster.aks
```

## ☸️ kubectl

### Información del Cluster
```powershell
# Ver información del cluster
kubectl cluster-info

# Ver versión
kubectl version

# Ver nodos
kubectl get nodes

# Ver nodos con detalles
kubectl get nodes -o wide

# Describir nodo
kubectl describe node <node-name>

# Ver contextos
kubectl config get-contexts

# Cambiar contexto
kubectl config use-context aks-lab-cluster

# Ver configuración actual
kubectl config view
```

### Gestión de Pods
```powershell
# Listar pods
kubectl get pods

# Listar pods en todos los namespaces
kubectl get pods -A

# Listar pods con más detalles
kubectl get pods -o wide

# Describir pod
kubectl describe pod <pod-name>

# Ver logs de un pod
kubectl logs <pod-name>

# Ver logs en tiempo real
kubectl logs -f <pod-name>

# Ver logs de todos los contenedores
kubectl logs <pod-name> --all-containers=true

# Ver logs previos (si el pod crasheó)
kubectl logs <pod-name> --previous

# Ejecutar comando en pod
kubectl exec <pod-name> -- ls -la

# Abrir shell en pod
kubectl exec -it <pod-name> -- /bin/bash

# Copiar archivos desde/hacia pod
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file

# Eliminar pod
kubectl delete pod <pod-name>

# Eliminar pods por label
kubectl delete pods -l app=nginx
```

### Gestión de Deployments
```powershell
# Listar deployments
kubectl get deployments

# Describir deployment
kubectl describe deployment nginx-deployment

# Escalar deployment
kubectl scale deployment nginx-deployment --replicas=5

# Ver estado del rollout
kubectl rollout status deployment nginx-deployment

# Ver historial de rollout
kubectl rollout history deployment nginx-deployment

# Hacer rollback
kubectl rollout undo deployment nginx-deployment

# Rollback a revisión específica
kubectl rollout undo deployment nginx-deployment --to-revision=2

# Pausar rollout
kubectl rollout pause deployment nginx-deployment

# Reanudar rollout
kubectl rollout resume deployment nginx-deployment

# Actualizar imagen
kubectl set image deployment/nginx-deployment nginx=nginx:1.25

# Editar deployment
kubectl edit deployment nginx-deployment

# Eliminar deployment
kubectl delete deployment nginx-deployment
```

### Gestión de Services
```powershell
# Listar services
kubectl get services
kubectl get svc

# Describir service
kubectl describe service nginx-service

# Ver endpoints del service
kubectl get endpoints nginx-service

# Eliminar service
kubectl delete service nginx-service

# Port forward (acceso local)
kubectl port-forward service/nginx-service 8080:80
```

### Aplicar Manifiestos
```powershell
# Aplicar archivo
kubectl apply -f nginx-deployment.yaml

# Aplicar directorio
kubectl apply -f kubernetes/

# Aplicar con validación estricta
kubectl apply -f nginx-deployment.yaml --validate=true

# Ver diferencias antes de aplicar
kubectl diff -f nginx-deployment.yaml

# Eliminar recursos de archivo
kubectl delete -f nginx-deployment.yaml

# Eliminar recursos de directorio
kubectl delete -f kubernetes/
```

### Debugging
```powershell
# Ver eventos
kubectl get events

# Ver eventos ordenados por tiempo
kubectl get events --sort-by='.lastTimestamp'

# Ver eventos de un namespace
kubectl get events -n default

# Ver eventos en tiempo real
kubectl get events --watch

# Ejecutar pod temporal para debugging
kubectl run debug --image=busybox --rm -it -- sh

# Ejecutar pod con curl
kubectl run curl --image=curlimages/curl --rm -it -- sh

# Ver uso de recursos
kubectl top nodes
kubectl top pods

# Ver recursos con formato JSON
kubectl get pods -o json

# Ver recursos con formato YAML
kubectl get pods -o yaml

# Usar JSONPath para filtrar
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Ver labels
kubectl get pods --show-labels

# Filtrar por label
kubectl get pods -l app=nginx

# Ver recursos en todos los namespaces
kubectl get all -A
```

### Namespaces
```powershell
# Listar namespaces
kubectl get namespaces
kubectl get ns

# Crear namespace
kubectl create namespace dev

# Eliminar namespace
kubectl delete namespace dev

# Ver recursos en namespace específico
kubectl get all -n kube-system

# Cambiar namespace por defecto
kubectl config set-context --current --namespace=dev
```

### ConfigMaps y Secrets
```powershell
# Crear ConfigMap desde literal
kubectl create configmap my-config --from-literal=key1=value1

# Crear ConfigMap desde archivo
kubectl create configmap my-config --from-file=config.txt

# Ver ConfigMaps
kubectl get configmaps

# Crear Secret
kubectl create secret generic my-secret --from-literal=password=secret123

# Ver Secrets
kubectl get secrets

# Ver contenido de Secret (base64)
kubectl get secret my-secret -o yaml
```

### Autoscaling
```powershell
# Crear HPA (Horizontal Pod Autoscaler)
kubectl autoscale deployment nginx-deployment --min=3 --max=10 --cpu-percent=80

# Ver HPA
kubectl get hpa

# Describir HPA
kubectl describe hpa nginx-deployment

# Eliminar HPA
kubectl delete hpa nginx-deployment
```

## 🔍 Comandos de Monitoreo

### Métricas en Tiempo Real
```powershell
# Watch pods
kubectl get pods --watch

# Watch services
kubectl get services --watch

# Watch events
kubectl get events --watch

# Ver logs de múltiples pods
kubectl logs -l app=nginx --all-containers=true -f

# Ver uso de recursos continuamente
watch kubectl top pods
```

### Troubleshooting Avanzado
```powershell
# Ver API resources disponibles
kubectl api-resources

# Ver versiones de API
kubectl api-versions

# Explicar recurso
kubectl explain pod
kubectl explain deployment.spec

# Ver certificados
kubectl get certificates -A

# Ver CRDs (Custom Resource Definitions)
kubectl get crds

# Verificar RBAC
kubectl auth can-i create pods
kubectl auth can-i delete deployments

# Ver service accounts
kubectl get serviceaccounts
```

## 🎯 Flujos de Trabajo Comunes

### Desplegar Nueva Versión
```powershell
# 1. Actualizar imagen en deployment.yaml
# 2. Aplicar cambios
kubectl apply -f kubernetes/nginx-deployment.yaml

# 3. Ver progreso
kubectl rollout status deployment nginx-deployment

# 4. Verificar
kubectl get pods
```

### Debugging de Pod que No Inicia
```powershell
# 1. Ver estado
kubectl get pods

# 2. Describir pod
kubectl describe pod <pod-name>

# 3. Ver logs
kubectl logs <pod-name>

# 4. Ver eventos
kubectl get events --sort-by='.lastTimestamp' | grep <pod-name>
```

### Verificar Conectividad
```powershell
# 1. Crear pod de prueba
kubectl run test --image=busybox --rm -it -- sh

# 2. Dentro del pod, probar DNS
nslookup nginx-service

# 3. Probar conectividad HTTP
wget -O- http://nginx-service
```

## 📊 Comandos de Limpieza

```powershell
# Eliminar pods terminados
kubectl delete pods --field-selector=status.phase=Succeeded

# Eliminar pods en error
kubectl delete pods --field-selector=status.phase=Failed

# Limpiar recursos no utilizados
kubectl delete all --all -n default

# Forzar eliminación de pod
kubectl delete pod <pod-name> --force --grace-period=0
```

## 💡 Tips y Trucos

### Aliases Útiles (PowerShell)
```powershell
# Agregar a tu $PROFILE
Set-Alias -Name k -Value kubectl

function kgp { kubectl get pods $args }
function kgs { kubectl get services $args }
function kgd { kubectl get deployments $args }
function kl { kubectl logs $args }
function kd { kubectl describe $args }
function ke { kubectl exec -it $args }
```

### Aliases Útiles (Bash/Zsh)
```bash
# Agregar a ~/.bashrc o ~/.zshrc
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kl='kubectl logs'
alias kd='kubectl describe'
alias ke='kubectl exec -it'
```

### Autocompletado
```powershell
# PowerShell
kubectl completion powershell | Out-String | Invoke-Expression

# Bash
source <(kubectl completion bash)

# Zsh
source <(kubectl completion zsh)
```

---

**¡Guarda esta referencia para uso rápido!** 🚀
