#!/bin/bash

declare -A loa_ar

declare -A lis_ar

declare -A inst_ar


declare -A q_urlss

loa_ar=$(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn[]" --output text)

echo ${loa_ar}


echo "Getting Load balancer ARN"


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


lis_ar=$(aws elbv2 describe-listeners --load-balancer-arn $loa_ar | grep LISTENERS |  awk '{print $2}')

echo "Getting listner ARN"

echo $lis_ar;


echo "\\\\\\\\\\"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"




arr=($(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text )); for i in ${arr[@]}; do  aws elbv2 deregister-targets --target-group-arn $(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn[]" --output text) --targets Id=$i ; done ; rm -f arr


echo "Target Deregister"
echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


# Wait for target to be deregistered
#aws elbv2 wait target-deregistered \
#--target-group-arn $(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn[]" --output text)



# Delete Listner
aws elbv2 delete-listener \
--listener-arn ${lis_ar}



echo "Deleted Listner"
echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"




#Detach a target group from auto-scaling
aws autoscaling detach-load-balancer-target-groups --auto-scaling-group-name ${9} --target-group-arns $(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn[]" --output text)




echo "Detached target group from autoscaling"
echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"





#Delete target-group
aws elbv2 delete-target-group \
        --target-group-arn $(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn[]" --output text)



echo "Deleted target group"

#Delete Load-balancer


aws elbv2 delete-load-balancer \
                --load-balancer-arn $(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn[]" --output text)



echo "Delted load-balancer"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\"


#Use elbv2 wait command for load-balancers to be deleted
#aws elbv2 wait load-balancers-deleted \
#       --load-balancer-arn $(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn[]" --output text)




# Terminate Instance

aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text)



echo "Terminate Instance"
echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

echo "Wait-Instance-termenating"
echo "Hold on"

# Wait- Instance terminated
aws ec2 wait instance-terminated \
--instance-ids $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  --query "Reservations[*].Instances[*].[InstanceId]" --output text)



echo "Wait- Terminate Instance"
echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "Deleting auto-scaling group"

# Delete auto-scaling-group

aws autoscaling delete-auto-scaling-group --auto-scaling-group-name ${9} --force-delete


echo "****************************************************"

echo "Auto scaling group deleted"


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


# Delete launch-config

aws autoscaling delete-launch-configuration --launch-configuration-name ${10}


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "Deleted launch configuration"



echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "Deleting Table"


aws dynamodb delete-table --table-name ${14}


echo "*************************************"

echo "Table Deleted"


echo "Wait till table Deleted"

echo "**************************************"

echo "Waiting for table to be Deleted"


aws dynamodb wait table-not-exists --table-name ${14}

echo "************************************"



echo "Deletion Completed"



# Get queue URL

q_urlss=$(aws sqs get-queue-url --queue-name joshi-queue)


echo ${q_urlss}

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

echo "Deleting SQS queue"


# Delete SQS  QUEUE


aws sqs delete-queue --queue-url $q_urlss


echo "SQS Queue Deleted"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "Deleting SNS Topic"

echo "**********************************************"

aws sns delete-topic \
	    --topic-arn arn:aws:sns:us-east-1:314979480072:joshi-topic


echo "************************************************"

echo "Deleted SNS Topic"


echo "Deleting Lambda"

echo "**************************************************"

aws lambda delete-function \
	    --function-name EditorFunction


echo "***************************************************"

declare -A uids


echo "******************************************"

echo "*****************************************"
echo "Deleting bucket Raw"


uids=$(aws lambda list-event-source-mappings --function-name EditorFunction | awk '{print $9}')


echo ${uids}

aws lambda delete-event-source-mapping \
	                    --uuid  $uids



aws s3 rb s3://${13} --force

echo "*******************************************"

echo "Bucket Deleted Raw"

echo "********************************************"

echo "Deleting Finished Bucket"


aws s3 rb s3://${15} --force

echo "******************************************"


echo "*********************************************************"


echo "*******************************************************"




echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "DONE"
echo "Everthing is Deleted"

