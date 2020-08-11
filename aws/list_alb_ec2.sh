#!/bin/bash

ALB_Name=$1
#TG_NAME=$2
CMD="aws --profile saml --region us-east-1"

echo "ALB_Name: $ALB_Name"

ALB_ARN=$($CMD elbv2 describe-load-balancers --names $ALB_Name --query 'LoadBalancers[0].LoadBalancerArn' --output text)

TG_NAME_ARN=$($CMD elbv2 describe-target-groups --load-balancer-arn $ALB_ARN --query 'TargetGroups[*].[TargetGroupName,TargetGroupArn]' --output text | tr '\t' ',')
#TG_NAME_ARN=$($CMD elbv2 describe-target-groups --names $TG_NAME --query 'TargetGroups[*].[TargetGroupName,TargetGroupArn]' --output text | tr '\t' ',')

for i in $TG_NAME_ARN; do
  name=`echo $i | cut -d ',' -f1`
  arn=`echo $i | cut -d ',' -f2`

  echo "# $name"
  instance_ids=`$CMD elbv2 describe-target-health --target-group-arn $arn --query 'TargetHealthDescriptions[*].Target.Id' --output text`
  for ii in $instance_ids; do
    $CMD ec2 describe-instances --filters "Name=instance-id,Values=$ii" --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0]]" --output text
  done
done
