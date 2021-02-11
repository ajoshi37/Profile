#!/bin/bash

# Create S3 bucket
aws s3 mb s3://${12} --region us-east-1


echo "Created RAW Bucket"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

echo "Creating S3 Finish Bucket"

echo "***********************************************************"

aws s3 mb s3://${15} --region us-east-1

echo "*****************************************************"

echo "Created S3 Finish Bucket"



echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "Creating Load balancer"


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


# Creating load Balancer
aws elbv2 create-load-balancer --name ${6} --subnets ${3} ${4} --security-groups ${5}


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"



printf "load balancer created"



printf "Using ELBV2 wait command for load-balancer to be available"


echo "load balancer created"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

echo "Using ELBV2 wait command for load-balancer to be available"



echo "************************************************************"


echo "Hold on"


#Using  an ELBv2 wait command to wait for the load balancer to be available and Exits


aws elbv2 wait load-balancer-available \
	--load-balancer-arns $(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn[]" --output text)



echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"



echo "Load balancers are avaliable"


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "Creating target Group"


#Create a target-group
aws elbv2 create-target-group \
	            --name ${7} \
		                    --protocol HTTP \
				                        --port 3300 \
							                        --target-type instance \
										                            --vpc-id ${11}



echo "**********************************************************************"


printf "Created target group"






echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


printf "Creating listeners"




# create Listners

aws elbv2 create-listener \
	    --load-balancer-arn $(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn[]" --output text) \
	        --protocol HTTP \
		    --port 3300 \
		        --default-actions Type=forward,TargetGroupArn=$(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn[]" --output text)




echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"



printf "Created Listeners "



echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"



echo "Creating Launch Configuration"




# Create Launch Configuration

aws autoscaling create-launch-configuration --launch-configuration-name ${10} --image-id ${1} --instance-type t2.micro --security-groups ${5} --key-name ${8} --iam-instance-profile ${13} --user-data file://create-env.sh



echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"




printf "Created launch Configuration"


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "Creating Auto Scaling Group" 

# create-auto-scaling-group


#aws autoscaling create-auto-scaling-group --auto-scaling-group-name ${9} --launch-configuration-name ${10} --min-size 1 --max-size 1 --vpc-zone-identifier "${3},${4}" --desired-capacity 1 --target-group-arns $(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn[]" --output text)


aws autoscaling create-auto-scaling-group --auto-scaling-group-name ${9} --launch-configuration-name ${10} --min-size 2 --max-size 6 --vpc-zone-identifier "${3},${4}" --desired-capacity 3 --target-group-arns $(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn[]" --output text)


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


printf "Auto scaling group created"


echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "Attaching load-balancer to target group"


aws autoscaling attach-load-balancer-target-groups \
--auto-scaling-group-name ${9} \
--target-group-arn $(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn[]" --output text)



echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


# To create a table with tags

echo "Creating table"

echo "*********************************************"

aws dynamodb create-table \
	            --table-name ${14} \
		                    --attribute-definitions AttributeName=Email,AttributeType=S AttributeName=RecordNumber,AttributeType=S \
				                        --key-schema AttributeName=Email,KeyType=HASH AttributeName=RecordNumber,KeyType=RANGE \
							                        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
										                            --tags Key=Owner,Value=blueTeam \
													    --stream-specification StreamEnabled=TRUE,StreamViewType=NEW_AND_OLD_IMAGES


echo "Table created"

echo "*************************************************"

echo "*************************************************"


echo "Wait till table Exists"

echo "************************************************"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

echo "Waiting"

aws dynamodb wait table-exists --table-name ${14}

echo "Table exists"


echo "********************************************************"

echo "Creating SQS queue"

# SQS message queue

aws sqs create-queue --queue-name joshi-queue

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

echo "SQS Message Queue Created"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

declare -A q_urlss

echo "Getting Queue URL"

# Get queue URL

q_urlss=$(aws sqs get-queue-url --queue-name joshi-queue)

echo "****************************************************************************************"

echo ${q_urlss}

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

echo "Sending Message"


# Send Message

aws sqs send-message --queue-url $q_urlss --message-body "Did you getting any message from amazon AI bot..?." --delay-seconds 10

echo "Message Sent "

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


echo "Creating SNS Topic"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"


#To create an SNS topic

aws sns create-topic \
	    --name joshi-topic

echo "***************************************************************************"

echo "Created SNS Topic "



echo "*************************************************************"

echo "To creating a Lambda Function"


echo "****************************************************"


aws lambda create-function \
	    --function-name EditorFunction \
	        --runtime python3.8 \
		    --zip-file fileb://editor.zip \
		        --handler editor.handler \
			    --role ${16} \
			     



echo "**********************************************************"

echo "Created Lambda Function"

echo "************************************************************"


echo "Creating Event Source"


declare -A event_arn

event_arn=$(aws dynamodb describe-table --table-name db-table-joshi | awk '{print $4}' | head -n 1)

echo "*************************************************************"

echo "Getting Stream ARN"

echo "**************************************************************"

aws lambda create-event-source-mapping \
	    --function-name EditorFunction \
	        --batch-size 5 \
                --event-source-arn $event_arn \
	       --starting-position TRIM_HORIZON		


echo "*******************************"



echo "Steps Completed"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

printf "Displaying"

echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

printf "VPC for my subnet is"

# VPC
aws ec2 describe-subnets --query 'Subnets[0].[VpcId]' --output text




echo "DONE"


echo "Required Script Created"


echo "Required Script Created"

