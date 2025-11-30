# Troubleshooting Guide - AKS Lab

Esta guía te ayudará a resolver problemas comunes que puedes encontrar durante el laboratorio.

## 🔧 Problemas Comunes

### 1. Error: "Insufficient permissions" al ejecutar Terraform

**Síntoma:**
```
Error: authorization.RoleAssignmentsClient#Create: Failure responding to request
```

**Solución:**
- Verifica que tu cuenta tenga rol de **Contributor** o **Owner** en la suscripción
- Ejecuta: `az role assignment list --assignee $(az account show --query user.name -o tsv)`
- Si no tienes permisos, contacta al administrador de Azure

### 2. Error: "Quota exceeded" al crear el cluster

**Síntoma:**
```
Error: creating Managed Kubernetes Cluster: compute.VirtualMachinesClient#CreateOrUpdate: 
Failure sending request: StatusCode=0 -- Original Error: autorest/azure: 
Service returned an error. Status=<nil> Code="OperationNotAllowed" 
Message="Operation could not be completed as it results in exceeding approved quota."
```

**Soluciones:**
1. Reduce el tamaño de VM en `terraform.tfvars`:
   ```hcl
   vm_size = "Standard_B2s"  # Más económico
   ```

2. Reduce el número de nodos:
   ```hcl
   node_count = 1
   ```

3. Cambia la región:
   ```hcl
   location = "West US"
   ```

4. Solicita aumento de cuota en Azure Portal

### 3. El servicio NGINX no obtiene IP externa

**Síntoma:**
```
kubectl get service nginx-service
NAME            TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
nginx-service   LoadBalancer   10.0.37.123   <pending>     80:30123/TCP   5m
```

**Soluciones:**
1. **Espera más tiempo** - Puede tomar 3-5 minutos
2. Verifica los eventos:
   ```bash
   kubectl describe service nginx-service
   kubectl get events --sort-by='.lastTimestamp'
   ```

3. Verifica que el tipo sea LoadBalancer:
   ```bash
   kubectl get service nginx-service -o yaml | grep type
   ```

4. Verifica los pods:
   ```bash
   kubectl get pods -l app=nginx
   ```

### 4. No puedo conectarme con kubectl

**Síntoma:**
```
Unable to connect to the server: dial tcp: lookup aks-lab-cluster-dns-xxxxx.hcp.eastus.azmk8s.io
```

**Soluciones:**
1. Obtén las credenciales nuevamente:
   ```bash
   az aks get-credentials --resource-group rg-aks-lab --name aks-lab-cluster --overwrite-existing
   ```

2. Verifica que el cluster existe:
   ```bash
   az aks list -o table
   ```

3. Verifica tu contexto de kubectl:
   ```bash
   kubectl config get-contexts
   kubectl config use-context aks-lab-cluster
   ```

### 5. Error: "Terraform state lock"

**Síntoma:**
```
Error: Error acquiring the state lock
```

**Solución:**
1. Espera unos minutos - puede ser que otro proceso esté usando el estado
2. Si estás seguro de que no hay otro proceso:
   ```bash
   terraform force-unlock <LOCK_ID>
   ```

### 6. Los pods están en estado "ImagePullBackOff"

**Síntoma:**
```bash
kubectl get pods
NAME                               READY   STATUS             RESTARTS   AGE
nginx-deployment-xxxxx-xxxxx       0/1     ImagePullBackOff   0          2m
```

**Soluciones:**
1. Verifica los detalles del pod:
   ```bash
   kubectl describe pod <pod-name>
   ```

2. Verifica la conectividad a internet del cluster:
   ```bash
   kubectl run test --image=busybox --rm -it -- ping google.com
   ```

3. Usa una imagen específica en lugar de `latest`:
   ```yaml
   image: nginx:1.25
   ```

### 7. Error al ejecutar "terraform destroy"

**Síntoma:**
```
Error: deleting Resource Group: resources.GroupsClient#Delete: 
Failure sending request: StatusCode=0
```

**Soluciones:**
1. Primero elimina los recursos de Kubernetes:
   ```bash
   kubectl delete -f kubernetes/
   ```

2. Espera a que el LoadBalancer se elimine completamente:
   ```bash
   az network lb list --resource-group MC_rg-aks-lab_aks-lab-cluster_eastus
   ```

3. Intenta destroy nuevamente:
   ```bash
   terraform destroy
   ```

4. Si persiste, elimina manualmente desde Azure Portal

### 8. Lens no detecta mi cluster

**Soluciones:**
1. Verifica que kubectl funcione:
   ```bash
   kubectl get nodes
   ```

2. Verifica la ubicación del kubeconfig:
   ```bash
   echo $KUBECONFIG  # Linux/Mac
   echo $env:KUBECONFIG  # Windows PowerShell
   ```

3. En Lens, ve a File → Add Cluster → Paste as Text
4. Copia el contenido de tu kubeconfig:
   ```bash
   kubectl config view --raw
   ```

### 9. Error de autenticación en Azure

**Síntoma:**
```
ERROR: AADSTS50058: A silent sign-in request was sent but no user is signed in.
```

**Solución:**
```bash
az logout
az login
az account set --subscription "TU_SUBSCRIPTION_ID"
```

### 10. El deployment no escala

**Síntoma:**
Al ejecutar `kubectl scale`, los pods no se crean.

**Soluciones:**
1. Verifica recursos disponibles:
   ```bash
   kubectl describe nodes
   kubectl top nodes  # Requiere metrics-server
   ```

2. Verifica eventos del deployment:
   ```bash
   kubectl describe deployment nginx-deployment
   ```

3. Reduce los recursos solicitados en `nginx-deployment.yaml`

## 🔍 Comandos de Diagnóstico Útiles

```bash
# Ver todos los recursos
kubectl get all -A

# Ver logs de todos los pods de nginx
kubectl logs -l app=nginx --all-containers=true

# Ver eventos recientes
kubectl get events --sort-by='.lastTimestamp' | tail -20

# Ver uso de recursos
kubectl top nodes
kubectl top pods

# Ver configuración del cluster
kubectl cluster-info
kubectl config view

# Ver detalles de un recurso
kubectl describe pod <pod-name>
kubectl describe node <node-name>

# Ejecutar shell en un pod
kubectl exec -it <pod-name> -- /bin/bash

# Ver logs en tiempo real
kubectl logs -f <pod-name>

# Ver información de Azure
az aks show --resource-group rg-aks-lab --name aks-lab-cluster
az aks get-versions --location eastus -o table
```

## 📞 Obtener Ayuda Adicional

Si ninguna de estas soluciones funciona:

1. **Documentación oficial:**
   - [Azure AKS Troubleshooting](https://docs.microsoft.com/en-us/azure/aks/troubleshooting)
   - [Terraform Azure Provider Issues](https://github.com/hashicorp/terraform-provider-azurerm/issues)
   - [Kubernetes Troubleshooting](https://kubernetes.io/docs/tasks/debug/)

2. **Comunidades:**
   - [Stack Overflow - AKS tag](https://stackoverflow.com/questions/tagged/azure-kubernetes-service)
   - [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-providers/tf-azure/)

3. **Logs detallados:**
   ```bash
   # Terraform con logs detallados
   TF_LOG=DEBUG terraform apply
   
   # kubectl con verbosidad
   kubectl get pods -v=8
   ```

---

**Recuerda:** La mayoría de los problemas se resuelven esperando unos minutos o verificando los logs detallados. ¡No te desanimes! 💪
