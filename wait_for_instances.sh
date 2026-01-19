#!/bin/bash

echo "⏳ Aguardando instâncias ficarem InService..."
echo ""

MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  ATTEMPT=$((ATTEMPT + 1))
  
  # Pegar status das instâncias
  INSTANCES=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "cmtr-k5vl9gpq-asg" \
    --query 'AutoScalingGroups[0].Instances[*].[LifecycleState,HealthStatus,InstanceId]' \
    --output text)
  
  # Contar instâncias InService
  INSERVICE_COUNT=$(echo "$INSTANCES" | grep -c "InService")
  TOTAL_COUNT=$(echo "$INSTANCES" | wc -l)
  
  echo "[$ATTEMPT/$MAX_ATTEMPTS] InService: $INSERVICE_COUNT/2"
  echo "$INSTANCES"
  echo ""
  
  # Verificar se temos 2 InService
  if [ "$INSERVICE_COUNT" -eq 2 ]; then
    echo "✅ Todas as instâncias estão InService!"
    break
  fi
  
  if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
    echo "Aguardando 20 segundos..."
    sleep 20
  fi
done

if [ "$INSERVICE_COUNT" -eq 2 ]; then
  echo ""
  echo "🎉 Pronto! Verificando health check do Target Group..."
  sleep 10
  
  aws elbv2 describe-target-health \
    --target-group-arn $(aws elbv2 describe-target-groups \
      --names "cmtr-k5vl9gpq-asg-tg" \
      --query 'TargetGroups[0].TargetGroupArn' \
      --output text) \
    --output table
else
  echo ""
  echo "⚠️  Timeout: nem todas as instâncias ficaram InService em 10 minutos"
fi
