import boto3
from PIL import Image, ImageFilter
from boto3.dynamodb.conditions import Key


# Getting all service resources

sqs = boto3.resource('sqs',region_name='us-east-1')
s3 = boto3.client('s3',region_name='us-east-1')
s3_resource = boto3.resource('s3',region_name='us-east-1')
dynamodb = boto3.client('dynamodb',region_name='us-east-1')
sns = boto3.client('sns',region_name='us-east-1')




#Get DynamoDB table name
response = dynamodb.list_tables(
        )
myTableName = response['TableNames'][0]



def handler(event,context):
    
    client = boto3.client('dynamodb',region_name='us-east-1')
    responseList = client.list_tables()
    myTableName = responseList['TableNames'][0]

    dbResponse = client.scan(
        TableName=myTableName,
        Limit=50,
        Select='ALL_ATTRIBUTES',
        ScanFilter={
            'Stats': {
                'AttributeValueList': [
                    {
                        'S': '0',
    responseList = client.scan(
    TableName='myTableName',
    IndexName='string',
    AttributesToGet=[
        'string',
    ],
    Limit=100,
    Select='ALL_ATTRIBUTES'|'ALL_PROJECTED_ATTRIBUTES'|'SPECIFIC_ATTRIBUTES'|'COUNT',
    ScanFilter={
        'string': {
            'AttributeValueList': [
                {
                    'S': 'string',
                    'N': 'string',
                    'B': b'bytes',
                    'SS': [
                        'string',
                    ],
                    'NS': [
                        'string',
                    ],
                    'BS': [
                        b'bytes',
                    ],
                    'M': {
                        'string': {'... recursive ...'}
                    },
                    'L': [
                        {'... recursive ...'},
                    ],
                    'NULL': True|False,
                    'BOOL': True|False
                },
            ],
            'ComparisonOperator': 'EQ'|'NE'|'IN'|'LE'|'LT'|'GE'|'GT'|'BETWEEN'|'NOT_NULL'|'NULL'|'CONTAINS'|'NOT_CONTAINS'|'BEGINS_WITH'
        }
    },
    ConditionalOperator='AND'|'OR',
    ExclusiveStartKey={
        'string': {
            'S': 'string',
            'N': 'string',
            'B': b'bytes',
            'SS': [
                'string',
            ],
            'NS': [
                'string',
            ],
            'BS': [
                b'bytes',
            ],
            'M': {
                'string': {'... recursive ...'}
            },
            'L': [
                {'... recursive ...'},
            ],
            'NULL': True|False,
            'BOOL': True|False
        }
    },
    ReturnConsumedCapacity='INDEXES'|'TOTAL'|'NONE',
    TotalSegments=123,
    Segment=123,
    ProjectionExpression='string',
    FilterExpression='string',
    ExpressionAttributeNames={
        'string': 'string'
    },
    ExpressionAttributeValues={
        'string': {
            'S': 'string',
            'N': 'string',
            'B': b'bytes',
            'SS': [
                'string',
            ],
            'NS': [
                'string',
            ],
            'BS': [
                b'bytes',
            ],
            'M': {
                'string': {'... recursive ...'}
            },
            'L': [
                {'... recursive ...'},
            ],
            'NULL': True|False,
            'BOOL': True|False
        }
    },
    ConsistentRead=True|False
)

    rangeKey = str(dbResponse['Items'][0]['RecordNumber']['S'])
    hashKey = str(dbResponse['Items'][0]['Email']['S'])

    print(rangeKey,hashKey)

    
    print("Table NAme::",myTableName)

    data = client.get_item(
        TableName= myTableName, 
        Key={
            'Email': {'S': hashKey
            }, 
        'RecordNumber': {'S': rangeKey
        }
        }
    )



    print("s3 url")
    print(data['Item']['S3URL']['S'])

# Putting 
    client = boto3.client('s3',region_name='us-east-1')
    response = client.list_buckets()
    rawBucket = ""
    finishedBucket = ""
    for res in response.get('Buckets'):
        if "raw" in res['Name']:
            rawBucket= res['Name']
        elif "finish" in res['Name']:
            finishedBucket = res['Name']
        else:
            print("bucket list",response)
 

    print("first Bucket:",rawBucket)


    print("finishedBucket Bucket:",finishedBucket)

    bucketMsg = data['Item']['S3URL']['S']
    s3Url = bucketMsg.split('/')
    FileName = s3Url[3]

    print("file name:",FileName)
    s3.download_file(rawBucket, FileName, '/tmp/current-image.jpg')



#Read image and create a thumbnail


    def create_thumbnail(download_image, upload_image):
        im = Image.open( '/tmp/current-image.jpg' )
    size = (100, 100)
    im.thumbnail(size, Image.ANTIALIAS)
    background = Image.new('RGBA', size, (150, 150, 150, 0))
    background.paste(
        im, (int((size[0] - im.size[0]) / 1), int((size[1] - im.size[1]) / 1))
    )      
    uids = uuid.uuid4()
    thumbnail = str(uids)+'.png'
    background.save("/tmp/"+thumbnail)



#Updating the Status in DynamoDB

client = boto3.client('dynamodb',region_name='us-east-1')
response = client.update_item(
    ExpressionAttributeNames={
                    '#status': 'Status',
                },
                ExpressionAttributeValues={
                ':status': {
                    'S': '1',
                },
            },
                Key={
                'Email': {
                    'S': hashKey,
                },
                'RecordNumber': {
                    'S': rangeKey,
                },
            },
                ReturnValues='ALL_NEW',
                TableName=myTableName,
                UpdateExpression='SET #status = :status',
            )

customerName = dbResponse['Items'][0]['CustomerName']['S']
phoneNumber = str(dbResponse['Items'][0]['Phone']['S'])


# Publish Message to the Customer about job being done.
client = boto3.client('dynamodb',region_name='us-east-1')
response = client.publish(
    TopicArn='string',
    TargetArn='string',
    PhoneNumber='phoneNumber',
    Message='Hello' + customerName + '. Your image has been rendered',
    Subject='string',
    MessageStructure='string',
    MessageAttributes={
        'string': {
            'DataType': 'string',
            'StringValue': 'string',
            'BinaryValue': b'bytes'
        }
    },
    MessageDeduplicationId='string',
    MessageGroupId='string'
)
