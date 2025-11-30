#!/bin/bash

# Script de validación para el laboratorio AKS
# Este script verifica que todos los prerequisitos estén instalados

echo "🔍 Verificando prerequisitos para el Lab AKS..."
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de errores
ERRORS=0

# Función para verificar comandos
check_command() {
    if command -v $1 &> /dev/null; then
        VERSION=$($1 --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓${NC} $1 está instalado: $VERSION"
    else
        echo -e "${RED}✗${NC} $1 NO está instalado"
        ERRORS=$((ERRORS + 1))
    fi
}

# Verificar Azure CLI
echo "Verificando Azure CLI..."
check_command az

# Verificar Terraform
echo "Verificando Terraform..."
check_command terraform

# Verificar kubectl
echo "Verificando kubectl..."
check_command kubectl

# Verificar login de Azure
echo ""
echo "Verificando sesión de Azure..."
if az account show &> /dev/null; then
    SUBSCRIPTION=$(az account show --query name -o tsv)
    echo -e "${GREEN}✓${NC} Sesión activa en Azure"
    echo "  Suscripción: $SUBSCRIPTION"
else
    echo -e "${RED}✗${NC} No hay sesión activa en Azure"
    echo "  Ejecuta: az login"
    ERRORS=$((ERRORS + 1))
fi

# Verificar archivo terraform.tfvars
echo ""
echo "Verificando configuración de Terraform..."
if [ -f "terraform/terraform.tfvars" ]; then
    echo -e "${GREEN}✓${NC} terraform.tfvars existe"
else
    echo -e "${YELLOW}⚠${NC} terraform.tfvars no existe"
    echo "  Copia terraform.tfvars.example a terraform.tfvars y edítalo"
fi

# Resumen
echo ""
echo "================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Todos los prerequisitos están listos!${NC}"
    echo "Puedes proceder con el laboratorio."
else
    echo -e "${RED}✗ Encontrados $ERRORS errores${NC}"
    echo "Por favor, instala las herramientas faltantes antes de continuar."
fi
echo "================================"

exit $ERRORS
