# Script de Limpieza - Lab AKS Terraform
# Este script elimina todos los recursos creados en el laboratorio

param(
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "`n🧹 Lab AKS Terraform - Script de Limpieza`n" "Cyan"

if (-not $Force) {
    Write-ColorOutput "⚠️  ADVERTENCIA: Este script eliminará TODOS los recursos del laboratorio." "Yellow"
    Write-ColorOutput "   Esto incluye:" "Yellow"
    Write-ColorOutput "   • Cluster AKS" "Yellow"
    Write-ColorOutput "   • Resource Group" "Yellow"
    Write-ColorOutput "   • Todos los recursos asociados`n" "Yellow"
    
    $confirmation = Read-Host "¿Estás seguro de que deseas continuar? (escribe 'SI' para confirmar)"
    
    if ($confirmation -ne "SI") {
        Write-ColorOutput "`n❌ Limpieza cancelada por el usuario." "Red"
        exit 0
    }
}

Write-ColorOutput ""

# Paso 1: Eliminar recursos de Kubernetes
Write-ColorOutput "🗑️  Paso 1: Eliminando recursos de Kubernetes..." "Yellow"

try {
    kubectl delete -f .\kubernetes\nginx-service.yaml --ignore-not-found=true
    kubectl delete -f .\kubernetes\nginx-deployment.yaml --ignore-not-found=true
    
    Write-ColorOutput "✅ Recursos de Kubernetes eliminados`n" "Green"
} catch {
    Write-ColorOutput "⚠️  Error al eliminar recursos de Kubernetes (puede que ya estén eliminados)`n" "Yellow"
}

# Esperar a que el LoadBalancer se elimine
Write-ColorOutput "⏳ Esperando a que el LoadBalancer se elimine completamente..." "Yellow"
Start-Sleep -Seconds 30
Write-ColorOutput "✅ Espera completada`n" "Green"

# Paso 2: Destruir infraestructura con Terraform
Write-ColorOutput "🗑️  Paso 2: Destruyendo infraestructura con Terraform..." "Yellow"
Write-ColorOutput "⏱️  Esto puede tomar 5-10 minutos...`n" "Cyan"

Push-Location terraform

if ($Force) {
    terraform destroy -auto-approve
} else {
    terraform destroy
}

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "`n❌ Error al destruir la infraestructura" "Red"
    Write-ColorOutput "   Intenta eliminar manualmente desde Azure Portal" "Yellow"
    Pop-Location
    exit 1
}

Pop-Location

Write-ColorOutput "`n✅ Infraestructura destruida exitosamente`n" "Green"

# Paso 3: Limpiar archivos locales
Write-ColorOutput "🧹 Paso 3: Limpiando archivos locales..." "Yellow"

if (Test-Path ".\terraform\terraform.tfvars") {
    Remove-Item ".\terraform\terraform.tfvars" -Force
    Write-ColorOutput "  • terraform.tfvars eliminado" "Cyan"
}

if (Test-Path ".\terraform\kubeconfig") {
    Remove-Item ".\terraform\kubeconfig" -Force
    Write-ColorOutput "  • kubeconfig eliminado" "Cyan"
}

if (Test-Path ".\terraform\.terraform") {
    Remove-Item ".\terraform\.terraform" -Recurse -Force
    Write-ColorOutput "  • .terraform/ eliminado" "Cyan"
}

if (Test-Path ".\terraform\.terraform.lock.hcl") {
    Remove-Item ".\terraform\.terraform.lock.hcl" -Force
    Write-ColorOutput "  • .terraform.lock.hcl eliminado" "Cyan"
}

Write-ColorOutput "✅ Archivos locales limpiados`n" "Green"

# Paso 4: Limpiar contexto de kubectl
Write-ColorOutput "🔧 Paso 4: Limpiando contexto de kubectl..." "Yellow"

try {
    kubectl config delete-context aks-lab-cluster 2>$null
    Write-ColorOutput "✅ Contexto de kubectl eliminado`n" "Green"
} catch {
    Write-ColorOutput "⚠️  Contexto de kubectl no encontrado (puede que ya esté eliminado)`n" "Yellow"
}

# Resumen final
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
Write-ColorOutput "✅ ¡LIMPIEZA COMPLETADA EXITOSAMENTE!" "Green"
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "📊 Recursos eliminados:" "White"
Write-ColorOutput "  ✓ Deployment de NGINX" "Green"
Write-ColorOutput "  ✓ Service de NGINX" "Green"
Write-ColorOutput "  ✓ Cluster AKS" "Green"
Write-ColorOutput "  ✓ Resource Group" "Green"
Write-ColorOutput "  ✓ Archivos locales de Terraform" "Green"
Write-ColorOutput "  ✓ Contexto de kubectl" "Green"
Write-ColorOutput ""
Write-ColorOutput "💡 Verifica en Azure Portal que todos los recursos fueron eliminados:" "White"
Write-ColorOutput "   https://portal.azure.com" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "🔄 Para volver a desplegar el laboratorio:" "White"
Write-ColorOutput "   .\scripts\deploy.ps1" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
