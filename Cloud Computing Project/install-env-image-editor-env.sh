#!/bin/bash

aws ec2 run-instances --image-id ${1} --instance-type t2.micro --count 1 --subnet-id ${2} --key-name ${4} --security-group-ids ${3} --user-data file://install-env-image-editor-env.sh --iam-instance-profile ${5}

echo "*************************************************************************************"


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

echo "*******************************************************************************"

