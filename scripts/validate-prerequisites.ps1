# Script de validación para el laboratorio AKS (PowerShell)
# Este script verifica que todos los prerequisitos estén instalados

Write-Host "🔍 Verificando prerequisitos para el Lab AKS..." -ForegroundColor Cyan
Write-Host ""

$errors = 0

# Función para verificar comandos
function Test-Command {
    param($CommandName)
    
    try {
        $version = & $CommandName --version 2>&1 | Select-Object -First 1
        Write-Host "✓ $CommandName está instalado: $version" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ $CommandName NO está instalado" -ForegroundColor Red
        $script:errors++
        return $false
    }
}

# Verificar Azure CLI
Write-Host "Verificando Azure CLI..."
Test-Command "az"

# Verificar Terraform
Write-Host "Verificando Terraform..."
Test-Command "terraform"

# Verificar kubectl
Write-Host "Verificando kubectl..."
Test-Command "kubectl"

# Verificar login de Azure
Write-Host ""
Write-Host "Verificando sesión de Azure..."
try {
    $subscription = az account show --query name -o tsv 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Sesión activa en Azure" -ForegroundColor Green
        Write-Host "  Suscripción: $subscription"
    }
    else {
        throw
    }
}
catch {
    Write-Host "✗ No hay sesión activa en Azure" -ForegroundColor Red
    Write-Host "  Ejecuta: az login"
    $errors++
}

# Verificar archivo terraform.tfvars
Write-Host ""
Write-Host "Verificando configuración de Terraform..."
if (Test-Path "terraform\terraform.tfvars") {
    Write-Host "✓ terraform.tfvars existe" -ForegroundColor Green
}
else {
    Write-Host "⚠ terraform.tfvars no existe" -ForegroundColor Yellow
    Write-Host "  Copia terraform.tfvars.example a terraform.tfvars y edítalo"
}

# Resumen
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
if ($errors -eq 0) {
    Write-Host "✓ Todos los prerequisitos están listos!" -ForegroundColor Green
    Write-Host "Puedes proceder con el laboratorio."
}
else {
    Write-Host "✗ Encontrados $errors errores" -ForegroundColor Red
    Write-Host "Por favor, instala las herramientas faltantes antes de continuar."
}
Write-Host "================================" -ForegroundColor Cyan

exit $errors
