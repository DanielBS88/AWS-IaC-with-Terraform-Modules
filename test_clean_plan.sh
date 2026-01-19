#!/bin/bash

echo "=== SIMULANDO VALIDADOR AWS ==="
echo ""

# Criar diretório limpo
TEST_DIR="/tmp/terraform-aws-validation-$(date +%s)"
mkdir -p $TEST_DIR
cd $TEST_DIR

echo "1. Copiando arquivos do projeto..."
cp -r /home/dansanto/Courses/Terraform/AWS_IaC_with_Terraform_Modules1/* .

echo ""
echo "2. Removendo qualquer state/cache..."
rm -rf .terraform* terraform.tfstate*

echo ""
echo "3. Listando arquivos copiados..."
find . -name "*.tf" -o -name "*.tfvars" | grep -v .terraform | sort

echo ""
echo "4. Verificando terraform.tfvars..."
if [ -f terraform.tfvars ]; then
    echo "✓ terraform.tfvars existe"
    cat terraform.tfvars
else
    echo "✗ terraform.tfvars NÃO existe!"
fi

echo ""
echo "5. Inicializando Terraform..."
terraform init -no-color

echo ""
echo "6. Validando configuração..."
terraform validate -no-color
VALIDATE_EXIT=$?
echo "Validate exit code: $VALIDATE_EXIT"

echo ""
echo "7. Executando PLAN (comando do validador)..."
terraform plan -no-color 2>&1 | tee plan-output.txt
PLAN_EXIT=${PIPESTATUS[0]}

echo ""
echo "================================"
echo "RESULTADO FINAL:"
echo "Validate Exit Code: $VALIDATE_EXIT (esperado: 0)"
echo "Plan Exit Code: $PLAN_EXIT (esperado: 0)"
echo "================================"

if [ $PLAN_EXIT -ne 0 ]; then
    echo ""
    echo "!!! ERRO DETECTADO NO PLAN !!!"
    echo ""
    echo "Mostrando erro completo:"
    cat plan-output.txt
fi

echo ""
echo "Diretório de teste: $TEST_DIR"
echo "Para investigar manualmente: cd $TEST_DIR"
