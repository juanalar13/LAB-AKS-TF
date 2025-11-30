# Lab AKS Terraform - Proyecto Completo

## 📁 Estructura del Proyecto

```
Lab AKS Terraform/
│
├── 📄 README.md                      # Documentación principal completa
├── 📄 QUICKSTART.md                  # Guía de inicio rápido (5 pasos)
├── 📄 ARCHITECTURE.md                # Diagramas y arquitectura detallada
├── 📄 TROUBLESHOOTING.md             # Guía de resolución de problemas
├── 📄 COMMANDS.md                    # Referencia de comandos útiles
├── 📄 .gitignore                     # Archivos a ignorar en Git
│
├── 📂 terraform/                     # Configuración de Terraform
│   ├── main.tf                       # Configuración principal de AKS
│   ├── variables.tf                  # Variables de entrada
│   ├── outputs.tf                    # Outputs del cluster
│   ├── terraform.tfvars.example      # Ejemplo de variables
│   └── .gitignore                    # Ignora archivos sensibles
│
├── 📂 kubernetes/                    # Manifiestos de Kubernetes
│   ├── nginx-deployment.yaml         # Deployment de NGINX (3 réplicas)
│   └── nginx-service.yaml            # Service LoadBalancer
│
└── 📂 scripts/                       # Scripts de utilidad
    ├── validate-prerequisites.sh     # Validación para Linux/Mac
    └── validate-prerequisites.ps1    # Validación para Windows
```

## 🎯 Objetivo del Proyecto

Demostrar cómo:
1. ✅ Desplegar un cluster AKS usando Terraform (Infrastructure as Code)
2. ✅ Desplegar una aplicación NGINX en Kubernetes
3. ✅ Conectarse al cluster con kubectl
4. ✅ Visualizar el cluster con Lens
5. ✅ Gestionar y escalar aplicaciones en Kubernetes

## 🚀 Inicio Rápido

### Prerequisitos
- Azure CLI instalado y configurado
- Terraform >= 1.0
- kubectl instalado
- Suscripción activa de Azure
- Lens (opcional, para visualización)

### Pasos Básicos

1. **Clonar/Descargar el proyecto**
2. **Configurar variables**: Copiar `terraform/terraform.tfvars.example` a `terraform/terraform.tfvars`
3. **Desplegar AKS**: 
   ```powershell
   cd terraform
   terraform init
   terraform apply
   ```
4. **Conectar kubectl**:
   ```powershell
   az aks get-credentials --resource-group rg-aks-lab --name aks-lab-cluster
   ```
5. **Desplegar NGINX**:
   ```powershell
   kubectl apply -f kubernetes/
   ```

## 📚 Documentación

| Archivo | Descripción | Cuándo Usar |
|---------|-------------|-------------|
| **README.md** | Guía completa paso a paso | Primera vez, tutorial completo |
| **QUICKSTART.md** | Inicio rápido (5 pasos) | Ya conoces Terraform/Kubernetes |
| **ARCHITECTURE.md** | Diagramas y arquitectura | Entender la infraestructura |
| **TROUBLESHOOTING.md** | Solución de problemas | Cuando algo no funciona |
| **COMMANDS.md** | Referencia de comandos | Consulta rápida de comandos |

## 🔑 Características Principales

### Terraform
- ✅ Configuración modular y reutilizable
- ✅ Variables parametrizadas
- ✅ Outputs informativos
- ✅ Gestión de estado local
- ✅ Validación de variables

### Kubernetes
- ✅ Deployment con 3 réplicas
- ✅ Health checks (liveness y readiness)
- ✅ Resource limits y requests
- ✅ LoadBalancer service
- ✅ Labels y selectors apropiados

### Documentación
- ✅ README completo en español
- ✅ Guía de inicio rápido
- ✅ Diagramas de arquitectura
- ✅ Troubleshooting detallado
- ✅ Referencia de comandos

## 🛠️ Tecnologías Utilizadas

- **Azure Kubernetes Service (AKS)** - Cluster de Kubernetes administrado
- **Terraform** - Infrastructure as Code
- **kubectl** - CLI de Kubernetes
- **NGINX** - Servidor web de ejemplo
- **Azure CLI** - Gestión de recursos Azure
- **Lens** - Visualización de Kubernetes (opcional)

## 📊 Recursos Creados

El laboratorio crea los siguientes recursos en Azure:

1. **Resource Group** (`rg-aks-lab`)
2. **AKS Cluster** (`aks-lab-cluster`)
   - 2 nodos Standard_DS2_v2
   - Network plugin: Azure CNI
   - Load Balancer: Standard
3. **Virtual Network** (auto-generado)
4. **Load Balancer** (auto-generado)
5. **Public IP** (auto-generado)

En Kubernetes:
1. **Deployment** (`nginx-deployment`) - 3 réplicas
2. **Service** (`nginx-service`) - LoadBalancer
3. **Pods** - 3 pods de NGINX

## 💰 Costos Estimados

- **Costo por hora**: ~$0.22 USD
- **Costo por día**: ~$5.28 USD
- **Costo por mes**: ~$302 USD

**⚠️ IMPORTANTE**: Elimina todos los recursos después de completar el lab para evitar cargos.

## 🧹 Limpieza de Recursos

```powershell
# 1. Eliminar recursos de Kubernetes
kubectl delete -f kubernetes/

# 2. Destruir infraestructura con Terraform
cd terraform
terraform destroy
```

## 🎓 Conceptos Aprendidos

1. **Infrastructure as Code (IaC)** con Terraform
2. **Kubernetes Deployments** y Services
3. **Azure Kubernetes Service (AKS)**
4. **Container Orchestration**
5. **Load Balancing** en Kubernetes
6. **Health Checks** y Resource Management
7. **kubectl** - Gestión de clusters
8. **Lens** - Visualización de Kubernetes

## 🔧 Personalización

### Cambiar Número de Nodos
En `terraform/terraform.tfvars`:
```hcl
node_count = 3  # Cambiar de 2 a 3
```

### Cambiar Tamaño de VM
En `terraform/terraform.tfvars`:
```hcl
vm_size = "Standard_D4s_v3"  # VM más potente
```

### Cambiar Número de Réplicas
En `kubernetes/nginx-deployment.yaml`:
```yaml
spec:
  replicas: 5  # Cambiar de 3 a 5
```

## 📖 Flujo de Trabajo Recomendado

1. **Día 1**: Leer README.md completo, entender arquitectura
2. **Día 2**: Ejecutar QUICKSTART.md, desplegar infraestructura
3. **Día 3**: Experimentar con kubectl, escalar aplicaciones
4. **Día 4**: Probar Lens, explorar visualización
5. **Día 5**: Limpiar recursos, revisar costos

## 🐛 Problemas Comunes

| Problema | Solución Rápida |
|----------|-----------------|
| "Insufficient permissions" | Verificar rol en Azure |
| "Quota exceeded" | Reducir node_count o vm_size |
| Service sin IP externa | Esperar 3-5 minutos |
| kubectl no conecta | Ejecutar `az aks get-credentials` nuevamente |

Ver **TROUBLESHOOTING.md** para más detalles.

## 📞 Soporte

- **Documentación Azure AKS**: https://docs.microsoft.com/azure/aks/
- **Documentación Terraform**: https://registry.terraform.io/providers/hashicorp/azurerm/
- **Documentación Kubernetes**: https://kubernetes.io/docs/

## ✅ Checklist de Validación

Antes de considerar el lab completo, verifica:

- [ ] Azure CLI instalado y login exitoso
- [ ] Terraform instalado
- [ ] kubectl instalado
- [ ] Cluster AKS desplegado exitosamente
- [ ] kubectl puede conectarse al cluster
- [ ] Pods de NGINX en estado Running
- [ ] Service tiene IP externa asignada
- [ ] NGINX accesible desde navegador
- [ ] Lens puede visualizar el cluster (opcional)
- [ ] Recursos eliminados al finalizar

## 🎉 Próximos Pasos

Después de completar este lab, considera:

1. **Implementar HTTPS** con cert-manager
2. **Agregar Ingress Controller**
3. **Implementar CI/CD** con GitHub Actions
4. **Agregar Monitoring** con Prometheus/Grafana
5. **Usar Helm** para gestión de aplicaciones
6. **Implementar Azure Container Registry**
7. **Configurar Network Policies**
8. **Agregar Persistent Storage**

## 📝 Notas Importantes

- ⚠️ Este es un laboratorio educativo
- ⚠️ No usar en producción sin ajustes de seguridad
- ⚠️ Eliminar recursos después de usar
- ⚠️ Monitorear costos en Azure Portal
- ⚠️ Mantener credenciales seguras

## 🌟 Características del Proyecto

- ✅ **Sencillo**: Configuración mínima necesaria
- ✅ **Práctico**: Ejemplo funcional end-to-end
- ✅ **Efectivo**: Demuestra conceptos clave
- ✅ **Bien Documentado**: 5 archivos de documentación
- ✅ **Listo para Usar**: Copiar y ejecutar
- ✅ **Educativo**: Comentarios y explicaciones

---

**Creado para demostrar AKS con Terraform de manera sencilla, práctica y efectiva** 🚀

**Tiempo estimado de completación**: 15-20 minutos

**Nivel**: Principiante a Intermedio

**Última actualización**: Noviembre 2025
