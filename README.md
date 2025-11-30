# Lab: Despliegue de AKS con Terraform y NGINX

Este laboratorio demuestra cómo desplegar un cluster de Azure Kubernetes Service (AKS) utilizando Terraform, desplegar una aplicación NGINX simple, y conectarse al cluster usando kubectl y Lens.

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

1. **Azure CLI** - [Descargar aquí](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform** (v1.0+) - [Descargar aquí](https://www.terraform.io/downloads)
3. **kubectl** - [Descargar aquí](https://kubernetes.io/docs/tasks/tools/)
4. **Lens** (opcional) - [Descargar aquí](https://k8slens.dev/)
5. **Suscripción activa de Azure**

## 🏗️ Estructura del Proyecto

```
Lab AKS Terraform/
├── terraform/
│   ├── main.tf              # Configuración principal de Terraform
│   ├── variables.tf         # Variables de entrada
│   ├── outputs.tf           # Outputs del cluster
│   └── terraform.tfvars     # Valores de las variables (crear manualmente)
├── kubernetes/
│   ├── nginx-deployment.yaml    # Deployment de NGINX
│   └── nginx-service.yaml       # Service de NGINX
└── README.md                # Este archivo
```

## 🚀 Paso a Paso

### 1. Configurar Azure CLI

Primero, inicia sesión en Azure:

```bash
az login
```

Verifica tu suscripción activa:

```bash
az account show
```

Si tienes múltiples suscripciones, selecciona la que deseas usar:

```bash
az account set --subscription "TU_SUBSCRIPTION_ID"
```

### 2. Configurar Variables de Terraform

Crea el archivo `terraform/terraform.tfvars` con tus valores:

```hcl
resource_group_name = "rg-aks-lab"
location           = "East US"
cluster_name       = "aks-lab-cluster"
node_count         = 2
vm_size            = "Standard_DS2_v2"
```

**Nota:** Puedes ajustar estos valores según tus necesidades y presupuesto.

### 3. Desplegar el Cluster AKS con Terraform

Navega al directorio de Terraform:

```bash
cd terraform
```

Inicializa Terraform:

```bash
terraform init
```

Revisa el plan de ejecución:

```bash
terraform plan
```

Aplica la configuración (esto tomará varios minutos):

```bash
terraform apply
```

Escribe `yes` cuando se te solicite confirmar.

### 4. Configurar kubectl

Una vez que el cluster esté creado, obtén las credenciales:

```bash
az aks get-credentials --resource-group rg-aks-lab --name aks-lab-cluster
```

Verifica la conexión:

```bash
kubectl get nodes
```

Deberías ver 2 nodos en estado `Ready`.

### 5. Desplegar NGINX en el Cluster

Navega al directorio raíz del proyecto y aplica los manifiestos de Kubernetes:

```bash
cd ..
kubectl apply -f kubernetes/nginx-deployment.yaml
kubectl apply -f kubernetes/nginx-service.yaml
```

Verifica el despliegue:

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

Espera a que el servicio obtenga una IP externa:

```bash
kubectl get service nginx-service --watch
```

Presiona `Ctrl+C` cuando veas la `EXTERNAL-IP` asignada.

### 6. Acceder a la Aplicación NGINX

Una vez que el servicio tenga una IP externa, accede a ella desde tu navegador:

```
http://<EXTERNAL-IP>
```

Deberías ver la página de bienvenida de NGINX.

### 7. Conectarse con Lens (Opcional)

1. Abre **Lens**
2. Lens detectará automáticamente tu configuración de kubectl
3. Haz clic en el cluster `aks-lab-cluster`
4. Explora los recursos del cluster visualmente

## 🔍 Comandos Útiles

### Ver logs de un pod:
```bash
kubectl logs <pod-name>
```

### Ejecutar comandos dentro de un pod:
```bash
kubectl exec -it <pod-name> -- /bin/bash
```

### Ver detalles de un recurso:
```bash
kubectl describe pod <pod-name>
kubectl describe service nginx-service
```

### Escalar el deployment:
```bash
kubectl scale deployment nginx-deployment --replicas=5
```

### Ver eventos del cluster:
```bash
kubectl get events --sort-by='.lastTimestamp'
```

## 🧹 Limpieza de Recursos

Para evitar cargos innecesarios, elimina todos los recursos cuando termines:

### 1. Eliminar recursos de Kubernetes:
```bash
kubectl delete -f kubernetes/nginx-service.yaml
kubectl delete -f kubernetes/nginx-deployment.yaml
```

### 2. Destruir el cluster con Terraform:
```bash
cd terraform
terraform destroy
```

Escribe `yes` cuando se te solicite confirmar.

## 📊 Recursos Creados

Este laboratorio crea los siguientes recursos en Azure:

- **Resource Group**: Contenedor lógico para todos los recursos
- **AKS Cluster**: Cluster de Kubernetes administrado
- **Virtual Network**: Red virtual para el cluster
- **Node Pool**: Pool de nodos (VMs) para ejecutar workloads
- **Load Balancer**: Balanceador de carga para el servicio NGINX

## 🎓 Conceptos Aprendidos

1. **Infrastructure as Code (IaC)**: Uso de Terraform para provisionar infraestructura
2. **Kubernetes**: Despliegue de aplicaciones en contenedores
3. **Azure AKS**: Servicio de Kubernetes administrado
4. **kubectl**: Herramienta de línea de comandos para Kubernetes
5. **Deployments y Services**: Recursos fundamentales de Kubernetes

## 🐛 Troubleshooting

### Error: "Insufficient permissions"
- Verifica que tu cuenta de Azure tenga permisos de Contributor en la suscripción

### Error: "Quota exceeded"
- Verifica los límites de tu suscripción de Azure
- Intenta con un `vm_size` más pequeño o reduce el `node_count`

### El servicio no obtiene IP externa
- Espera unos minutos más (puede tomar 3-5 minutos)
- Verifica que el servicio sea de tipo `LoadBalancer`

### No puedo conectarme con kubectl
- Ejecuta nuevamente: `az aks get-credentials --resource-group rg-aks-lab --name aks-lab-cluster --overwrite-existing`

## 📚 Referencias

- [Documentación de Azure AKS](https://docs.microsoft.com/en-us/azure/aks/)
- [Documentación de Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Documentación de Kubernetes](https://kubernetes.io/docs/home/)

## 📝 Notas

- Este laboratorio está diseñado para propósitos educativos
- Los recursos de Azure pueden generar costos
- Se recomienda eliminar todos los recursos después de completar el laboratorio
- El despliegue completo toma aproximadamente 10-15 minutos

---

**¡Feliz aprendizaje! 🚀**
