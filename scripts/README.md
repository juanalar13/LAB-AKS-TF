# Scripts - Lab AKS Terraform

Esta carpeta contiene scripts de utilidad para facilitar el despliegue y gestión del laboratorio.

## 📜 Scripts Disponibles

### 1. `deploy.ps1` (PowerShell - Windows)
Script de despliegue automatizado que ejecuta todo el proceso de configuración.

**Uso básico:**
```powershell
.\scripts\deploy.ps1
```

**Uso con parámetros:**
```powershell
.\scripts\deploy.ps1 `
    -ResourceGroupName "mi-rg" `
    -ClusterName "mi-cluster" `
    -Location "West US" `
    -NodeCount 3 `
    -VMSize "Standard_D4s_v3" `
    -AutoApprove
```

**Parámetros disponibles:**
- `-ResourceGroupName`: Nombre del Resource Group (default: "rg-aks-lab")
- `-ClusterName`: Nombre del cluster AKS (default: "aks-lab-cluster")
- `-Location`: Región de Azure (default: "East US")
- `-NodeCount`: Número de nodos (default: 2)
- `-VMSize`: Tamaño de VM (default: "Standard_DS2_v2")
- `-SkipValidation`: Saltar validación de prerequisitos
- `-AutoApprove`: No pedir confirmación en Terraform

**Lo que hace:**
1. ✅ Valida prerequisitos
2. ✅ Configura variables de Terraform
3. ✅ Inicializa Terraform
4. ✅ Despliega cluster AKS
5. ✅ Configura kubectl
6. ✅ Despliega NGINX
7. ✅ Espera a que todo esté listo
8. ✅ Muestra la URL de acceso

---

### 2. `cleanup.ps1` (PowerShell - Windows)
Script de limpieza que elimina todos los recursos del laboratorio.

**Uso básico:**
```powershell
.\scripts\cleanup.ps1
```

**Uso sin confirmación:**
```powershell
.\scripts\cleanup.ps1 -Force
```

**Parámetros disponibles:**
- `-Force`: Eliminar sin pedir confirmación

**Lo que hace:**
1. ✅ Elimina recursos de Kubernetes
2. ✅ Destruye infraestructura con Terraform
3. ✅ Limpia archivos locales
4. ✅ Elimina contexto de kubectl

---

### 3. `validate-prerequisites.ps1` (PowerShell - Windows)
Valida que todos los prerequisitos estén instalados.

**Uso:**
```powershell
.\scripts\validate-prerequisites.ps1
```

**Verifica:**
- ✅ Azure CLI instalado
- ✅ Terraform instalado
- ✅ kubectl instalado
- ✅ Sesión activa en Azure
- ✅ Archivo terraform.tfvars existe

---

### 4. `validate-prerequisites.sh` (Bash - Linux/Mac)
Versión Bash del script de validación.

**Uso:**
```bash
chmod +x scripts/validate-prerequisites.sh
./scripts/validate-prerequisites.sh
```

**Verifica lo mismo que la versión PowerShell**

---

## 🚀 Flujo de Trabajo Recomendado

### Opción 1: Despliegue Automatizado (Recomendado)
```powershell
# 1. Validar prerequisitos
.\scripts\validate-prerequisites.ps1

# 2. Desplegar todo automáticamente
.\scripts\deploy.ps1

# 3. Cuando termines, limpiar recursos
.\scripts\cleanup.ps1
```

### Opción 2: Despliegue Manual
Sigue las instrucciones del README.md principal.

---

## 💡 Tips

### Despliegue Rápido (sin confirmaciones)
```powershell
.\scripts\deploy.ps1 -AutoApprove -SkipValidation
```

### Limpieza Rápida (sin confirmaciones)
```powershell
.\scripts\cleanup.ps1 -Force
```

### Despliegue con Configuración Personalizada
```powershell
.\scripts\deploy.ps1 `
    -ResourceGroupName "rg-produccion" `
    -ClusterName "aks-prod" `
    -Location "Brazil South" `
    -NodeCount 5 `
    -VMSize "Standard_D8s_v3"
```

---

## 🐛 Troubleshooting

### Error: "No se puede ejecutar scripts"
```powershell
# Cambiar política de ejecución (ejecutar como Administrador)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "Az no reconocido"
- Instala Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli
- Reinicia PowerShell después de instalar

### Error: "Terraform no reconocido"
- Instala Terraform: https://www.terraform.io/downloads
- Asegúrate de que esté en el PATH

### El script se queda esperando
- Presiona Ctrl+C para cancelar
- Revisa los logs para ver dónde falló
- Ejecuta los comandos manualmente siguiendo el README.md

---

## 📊 Tiempo Estimado

| Script | Tiempo |
|--------|--------|
| `validate-prerequisites.ps1` | ~10 segundos |
| `deploy.ps1` | ~15-20 minutos |
| `cleanup.ps1` | ~5-10 minutos |

---

## 🔒 Seguridad

- ⚠️ Los scripts NO guardan credenciales
- ⚠️ Usa las credenciales de tu sesión actual de Azure CLI
- ⚠️ El archivo `terraform.tfvars` se crea localmente (no lo subas a Git)
- ⚠️ Los scripts requieren permisos de Contributor en Azure

---

## 📝 Notas

- Los scripts están diseñados para Windows PowerShell
- Para Linux/Mac, usa los comandos del README.md manualmente
- Los scripts incluyen manejo de errores y validaciones
- Los scripts muestran progreso en tiempo real
- Los scripts usan colores para mejor legibilidad

---

**¡Usa estos scripts para agilizar tu experiencia con el laboratorio!** 🚀
