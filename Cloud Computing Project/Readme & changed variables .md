Create-env.sh (Creates the whole infrastructure)
Created Lambda function with help of DynamoDB. As it creates lambda it sent SMS to the provided phone number about it's Status, Provided Name and details about the job.
It includes 4 EC2, 3 auto-scaling groups and required things to launch all computing, such as security groups, target group, listeners etc.

Destroy-env..sh (Destory the whole infrastructure)

App.js
Take input from user such as name, phone number, email address and image and put the data in the database servers which is dynamodb.

Editor.py
Includes python code do deploy the backend of the server.

Index.html
Includes the HTML page desgin. 

Skipped 5 Number.
Subnet for Ec2 launch. 

SO rest is 1 less after 5. 
Like this. To be sure :)


5)  Security Group ID
6)  Load balancer name
7)  Target Group name
8)  Key-pair name
9) auto-scaling-group-name
10) launch-configuration-name
11) vpc-id You can have the user prompt this or you can retrieve it
12) S3 bucket name
13) IAM profile name
14) RDS db-instance-identifier
15) S3 Bucket Name for Thumbnail Image
16) AWS Lambda Role (arn:aws:iam::314979480072:role/lambda-role)


************************************************************************************************************

install-env-image-editor-env.sh

My install-env-image-editor-env.sh includes the Image for custom AMI and do the sending message process.

1)	ImageID - use your custom AMI from week-07
2)	subnet-id for EC2 launch instance (availability zone a) (may or may not be used depending on your design)
3)	Security Group ID
4)	Key-pair name
5)	IAM profile name


Not used 5 option in create-env.sh so, it was messing the whole process when the run through as a whole
That's have to provide different SCRIPT.


*******************************************************************************************************

********************************************************************************************************

Steps 

1. Used create-env.sh script which creates everthing required. Except Image processing Ec2.

2. install-env-image-editor-env.sh Which creates the Ec2 image processing and use to Send Message.

3. sh ./install-env.sh to install required packages.
 


4. 

APP.JS

Hardcoded Values: In APP.JS

1)   Queue:  joshi-queue (Hardcoded queue name which include in the Create script also.)

Queue url = https://sqs.us-east-1.amazonaws.com/314************0/joshi-queue

2)   Line 35:  It Selects the buckets which starts from "raw" (mine was raw-bucket-joshi)


Editor.py

1)

raw bucket = raw (Which selects buckets which starts from RAW)

finish bucket = finish (Which Selects bucket which start from finish)



