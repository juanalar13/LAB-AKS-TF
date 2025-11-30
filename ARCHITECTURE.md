# Arquitectura del Laboratorio AKS

## 📐 Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                         Azure Cloud                              │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │           Resource Group: rg-aks-lab                       │ │
│  │                                                             │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │     Azure Kubernetes Service (AKS)                   │  │ │
│  │  │     Cluster: aks-lab-cluster                         │  │ │
│  │  │                                                       │  │ │
│  │  │  ┌─────────────────────────────────────────────┐     │  │ │
│  │  │  │         Default Node Pool                   │     │  │ │
│  │  │  │                                              │     │  │ │
│  │  │  │  ┌──────────┐      ┌──────────┐            │     │  │ │
│  │  │  │  │  Node 1  │      │  Node 2  │            │     │  │ │
│  │  │  │  │ (VM DS2) │      │ (VM DS2) │            │     │  │ │
│  │  │  │  │          │      │          │            │     │  │ │
│  │  │  │  │ ┌──────┐ │      │ ┌──────┐ │            │     │  │ │
│  │  │  │  │ │ Pod  │ │      │ │ Pod  │ │            │     │  │ │
│  │  │  │  │ │NGINX │ │      │ │NGINX │ │            │     │  │ │
│  │  │  │  │ └──────┘ │      │ └──────┘ │            │     │  │ │
│  │  │  │  │ ┌──────┐ │      │          │            │     │  │ │
│  │  │  │  │ │ Pod  │ │      │          │            │     │  │ │
│  │  │  │  │ │NGINX │ │      │          │            │     │  │ │
│  │  │  │  │ └──────┘ │      │          │            │     │  │ │
│  │  │  │  └──────────┘      └──────────┘            │     │  │ │
│  │  │  └─────────────────────────────────────────────┘     │  │ │
│  │  │                                                       │  │ │
│  │  │  ┌─────────────────────────────────────────────┐     │  │ │
│  │  │  │      Kubernetes Service (LoadBalancer)      │     │  │ │
│  │  │  │          nginx-service                      │     │  │ │
│  │  │  │          Port: 80                           │     │  │ │
│  │  │  └─────────────────────────────────────────────┘     │  │ │
│  │  │                       │                               │  │ │
│  │  └───────────────────────┼───────────────────────────────┘  │ │
│  │                          │                                  │ │
│  │  ┌───────────────────────▼───────────────────────────────┐  │ │
│  │  │         Azure Load Balancer                          │  │ │
│  │  │         Public IP: x.x.x.x                           │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  │                          │                                  │ │
│  └──────────────────────────┼──────────────────────────────────┘ │
│                             │                                    │
└─────────────────────────────┼────────────────────────────────────┘
                              │
                              │ HTTP (Port 80)
                              │
                    ┌─────────▼──────────┐
                    │   Internet Users   │
                    │   Web Browsers     │
                    └────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Management Tools                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Terraform   │  │   kubectl    │  │     Lens     │          │
│  │              │  │              │  │              │          │
│  │  Provision   │  │   Manage     │  │   Visualize  │          │
│  │ Infrastructure│  │  Workloads   │  │   Cluster    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Flujo de Trabajo

### 1. Provisión de Infraestructura (Terraform)
```
Developer → Terraform → Azure API → AKS Cluster Created
```

### 2. Despliegue de Aplicación (kubectl)
```
Developer → kubectl → Kubernetes API → Pods Created → Service Exposed
```

### 3. Acceso de Usuario
```
User → Public IP → Load Balancer → Service → Pods → NGINX Response
```

## 🏗️ Componentes Principales

### Azure Resources
| Recurso | Nombre | Propósito |
|---------|--------|-----------|
| Resource Group | `rg-aks-lab` | Contenedor lógico de recursos |
| AKS Cluster | `aks-lab-cluster` | Cluster de Kubernetes administrado |
| Virtual Network | Auto-generado | Red para comunicación de nodos |
| Load Balancer | Auto-generado | Distribuye tráfico a los pods |
| Public IP | Auto-generado | IP pública para acceso externo |
| Node Pool | `default` | Pool de VMs para ejecutar workloads |

### Kubernetes Resources
| Recurso | Nombre | Réplicas | Propósito |
|---------|--------|----------|-----------|
| Deployment | `nginx-deployment` | 3 | Gestiona pods de NGINX |
| Service | `nginx-service` | - | Expone pods externamente |
| Pods | `nginx-deployment-*` | 3 | Ejecutan contenedores NGINX |

## 🔐 Seguridad y Networking

### Network Policy
- **Plugin**: Azure CNI
- **Policy**: Azure Network Policy
- **Load Balancer**: Standard SKU

### Identity
- **Type**: System Assigned Managed Identity
- **Purpose**: Permite a AKS gestionar recursos de Azure automáticamente

### Resource Limits
Cada pod de NGINX tiene:
- **CPU Request**: 100m (0.1 cores)
- **CPU Limit**: 200m (0.2 cores)
- **Memory Request**: 64Mi
- **Memory Limit**: 128Mi

## 📊 Escalabilidad

### Horizontal Pod Autoscaling (Opcional)
```bash
kubectl autoscale deployment nginx-deployment --min=3 --max=10 --cpu-percent=80
```

### Node Pool Autoscaling (Opcional)
Descomentar en `main.tf`:
```hcl
min_count = 1
max_count = 3
```

## 🔄 Alta Disponibilidad

- **3 réplicas** de NGINX distribuidas entre nodos
- **Liveness probes** para detectar pods no saludables
- **Readiness probes** para controlar tráfico
- **Load Balancer** distribuye tráfico automáticamente

## 📈 Monitoreo

### Comandos de Monitoreo
```bash
# Estado general
kubectl get all

# Métricas de nodos
kubectl top nodes

# Métricas de pods
kubectl top pods

# Eventos
kubectl get events --watch
```

### Azure Monitor (Opcional)
Habilitar Container Insights en Azure Portal para:
- Métricas detalladas
- Logs centralizados
- Alertas automáticas
- Dashboards visuales

## 🌐 Flujo de Tráfico Detallado

1. **Usuario** hace request HTTP a `http://<PUBLIC-IP>`
2. **Azure Load Balancer** recibe el request
3. **Load Balancer** enruta a **nginx-service** (ClusterIP interno)
4. **Service** selecciona un pod usando round-robin
5. **Pod** procesa el request con NGINX
6. **Response** regresa por el mismo camino

## 💰 Estimación de Costos

Costos aproximados por hora (región East US):

| Recurso | Cantidad | Costo/hora | Costo/mes |
|---------|----------|------------|-----------|
| AKS Control Plane | 1 | Gratis | Gratis |
| VM Standard_DS2_v2 | 2 | ~$0.19 | ~$280 |
| Load Balancer | 1 | ~$0.025 | ~$18 |
| Public IP | 1 | ~$0.005 | ~$3.60 |
| **TOTAL** | - | **~$0.22** | **~$302** |

**Nota**: Estos son costos estimados. Elimina los recursos después del lab para evitar cargos.

## 🎯 Mejoras Futuras

1. **Implementar HTTPS** con cert-manager y Let's Encrypt
2. **Agregar Ingress Controller** (NGINX Ingress o Azure Application Gateway)
3. **Implementar CI/CD** con GitHub Actions o Azure DevOps
4. **Agregar Monitoring** con Prometheus y Grafana
5. **Implementar Helm Charts** para gestión de aplicaciones
6. **Configurar Azure Container Registry** (ACR)
7. **Implementar Network Policies** para seguridad
8. **Agregar Persistent Storage** con Azure Disks

---

**Diagrama creado para el Lab AKS Terraform** 🚀
