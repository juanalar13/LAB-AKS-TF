# Script de Despliegue Automatizado - Lab AKS Terraform
# Este script automatiza el despliegue completo del laboratorio

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-aks-lab",
    
    [Parameter(Mandatory=$false)]
    [string]$ClusterName = "aks-lab-cluster",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false)]
    [int]$NodeCount = 2,
    
    [Parameter(Mandatory=$false)]
    [string]$VMSize = "Standard_DS2_v2",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipValidation,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove
)

# Colores para output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "`n🚀 Lab AKS Terraform - Script de Despliegue Automatizado`n" "Cyan"

# Paso 1: Validar prerequisitos
if (-not $SkipValidation) {
    Write-ColorOutput "📋 Paso 1: Validando prerequisitos..." "Yellow"
    
    if (Test-Path ".\scripts\validate-prerequisites.ps1") {
        & .\scripts\validate-prerequisites.ps1
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "`n❌ Validación fallida. Por favor, instala los prerequisitos faltantes." "Red"
            exit 1
        }
    }
    Write-ColorOutput "✅ Prerequisitos validados`n" "Green"
}

# Paso 2: Crear archivo terraform.tfvars
Write-ColorOutput "📝 Paso 2: Configurando variables de Terraform..." "Yellow"

$tfvarsContent = @"
resource_group_name = "$ResourceGroupName"
location           = "$Location"
cluster_name       = "$ClusterName"
node_count         = $NodeCount
vm_size            = "$VMSize"
"@

Set-Content -Path ".\terraform\terraform.tfvars" -Value $tfvarsContent
Write-ColorOutput "✅ Variables configuradas en terraform\terraform.tfvars`n" "Green"

# Paso 3: Inicializar Terraform
Write-ColorOutput "🔧 Paso 3: Inicializando Terraform..." "Yellow"
Push-Location terraform

terraform init
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "`n❌ Error al inicializar Terraform" "Red"
    Pop-Location
    exit 1
}
Write-ColorOutput "✅ Terraform inicializado`n" "Green"

# Paso 4: Validar configuración
Write-ColorOutput "🔍 Paso 4: Validando configuración de Terraform..." "Yellow"
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "`n❌ Error en la validación de Terraform" "Red"
    Pop-Location
    exit 1
}
Write-ColorOutput "✅ Configuración validada`n" "Green"

# Paso 5: Mostrar plan
Write-ColorOutput "📊 Paso 5: Generando plan de ejecución..." "Yellow"
terraform plan
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "`n❌ Error al generar el plan" "Red"
    Pop-Location
    exit 1
}

# Paso 6: Aplicar configuración
Write-ColorOutput "`n🚀 Paso 6: Desplegando cluster AKS..." "Yellow"
Write-ColorOutput "⏱️  Esto puede tomar 10-15 minutos...`n" "Cyan"

if ($AutoApprove) {
    terraform apply -auto-approve
} else {
    terraform apply
}

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "`n❌ Error al desplegar el cluster" "Red"
    Pop-Location
    exit 1
}

Write-ColorOutput "`n✅ Cluster AKS desplegado exitosamente`n" "Green"

# Obtener outputs
$clusterNameOutput = terraform output -raw cluster_name
$resourceGroupOutput = terraform output -raw resource_group_name

Pop-Location

# Paso 7: Configurar kubectl
Write-ColorOutput "🔐 Paso 7: Configurando kubectl..." "Yellow"

az aks get-credentials --resource-group $resourceGroupOutput --name $clusterNameOutput --overwrite-existing

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "`n❌ Error al configurar kubectl" "Red"
    exit 1
}

Write-ColorOutput "✅ kubectl configurado`n" "Green"

# Paso 8: Verificar conexión
Write-ColorOutput "🔍 Paso 8: Verificando conexión al cluster..." "Yellow"

kubectl get nodes

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "`n❌ Error al conectar con el cluster" "Red"
    exit 1
}

Write-ColorOutput "`n✅ Conexión al cluster verificada`n" "Green"

# Paso 9: Desplegar NGINX
Write-ColorOutput "🌐 Paso 9: Desplegando aplicación NGINX..." "Yellow"

kubectl apply -f .\kubernetes\nginx-deployment.yaml
kubectl apply -f .\kubernetes\nginx-service.yaml

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "`n❌ Error al desplegar NGINX" "Red"
    exit 1
}

Write-ColorOutput "✅ NGINX desplegado`n" "Green"

# Paso 10: Esperar a que los pods estén listos
Write-ColorOutput "⏳ Paso 10: Esperando a que los pods estén listos..." "Yellow"

$maxAttempts = 30
$attempt = 0
$podsReady = $false

while (-not $podsReady -and $attempt -lt $maxAttempts) {
    $attempt++
    Start-Sleep -Seconds 5
    
    $pods = kubectl get pods -l app=nginx -o json | ConvertFrom-Json
    $readyPods = ($pods.items | Where-Object { 
        $_.status.conditions | Where-Object { $_.type -eq "Ready" -and $_.status -eq "True" }
    }).Count
    
    $totalPods = $pods.items.Count
    
    Write-ColorOutput "  Pods listos: $readyPods/$totalPods (intento $attempt/$maxAttempts)" "Cyan"
    
    if ($readyPods -eq $totalPods -and $totalPods -gt 0) {
        $podsReady = $true
    }
}

if ($podsReady) {
    Write-ColorOutput "✅ Todos los pods están listos`n" "Green"
} else {
    Write-ColorOutput "⚠️  Timeout esperando pods. Verifica manualmente con: kubectl get pods`n" "Yellow"
}

# Paso 11: Esperar IP externa
Write-ColorOutput "🌍 Paso 11: Esperando IP externa del servicio..." "Yellow"

$maxAttempts = 60
$attempt = 0
$externalIP = $null

while (-not $externalIP -and $attempt -lt $maxAttempts) {
    $attempt++
    Start-Sleep -Seconds 5
    
    $service = kubectl get service nginx-service -o json | ConvertFrom-Json
    $externalIP = $service.status.loadBalancer.ingress[0].ip
    
    if ($externalIP) {
        Write-ColorOutput "  IP externa obtenida: $externalIP" "Cyan"
    } else {
        Write-ColorOutput "  Esperando IP externa... (intento $attempt/$maxAttempts)" "Cyan"
    }
}

Write-ColorOutput ""

# Resumen final
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
Write-ColorOutput "🎉 ¡DESPLIEGUE COMPLETADO EXITOSAMENTE!" "Green"
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "📊 Información del Cluster:" "White"
Write-ColorOutput "  • Resource Group: $resourceGroupOutput" "White"
Write-ColorOutput "  • Cluster Name: $clusterNameOutput" "White"
Write-ColorOutput "  • Location: $Location" "White"
Write-ColorOutput "  • Nodes: $NodeCount x $VMSize" "White"
Write-ColorOutput ""

if ($externalIP) {
    Write-ColorOutput "🌐 Aplicación NGINX:" "White"
    Write-ColorOutput "  • URL: http://$externalIP" "Green"
    Write-ColorOutput "  • Abre esta URL en tu navegador para ver NGINX" "White"
} else {
    Write-ColorOutput "⚠️  IP externa aún no asignada. Ejecuta:" "Yellow"
    Write-ColorOutput "  kubectl get service nginx-service --watch" "Cyan"
}

Write-ColorOutput ""
Write-ColorOutput "📝 Comandos útiles:" "White"
Write-ColorOutput "  • Ver pods:        kubectl get pods" "Cyan"
Write-ColorOutput "  • Ver servicios:   kubectl get services" "Cyan"
Write-ColorOutput "  • Ver nodos:       kubectl get nodes" "Cyan"
Write-ColorOutput "  • Ver logs:        kubectl logs -l app=nginx" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "🧹 Para limpiar recursos:" "White"
Write-ColorOutput "  .\scripts\cleanup.ps1" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
Write-ColorOutput "⏱️  Tiempo total: Aproximadamente $(Get-Date)" "White"
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
