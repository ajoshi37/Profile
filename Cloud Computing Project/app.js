// Install these packages via npm: npm install express aws-sdk multer multer-s3

var express = require('express'),
    aws = require('aws-sdk'),
    bodyParser = require('body-parser'),
    multer = require('multer'),
    multerS3 = require('multer-s3');

// needed to include to generate UUIDs
// https://www.npmjs.com/package/uuid

const { v4: uuidv4 } = require('uuid');

//Set region to us-east-1

aws.config.update({
    region: 'us-east-1'
});

// initialize an s3 connection object
var app = express(),
    s3 = new aws.S3();

// configure S3 parameters to send to the connection object
app.use(bodyParser.json());

// I hardcoded my S3 bucket getting name this you need to determine dynamically
s3.listBuckets(function(err, data) {
    if (err) console.log(err, err.stack); // an error occurred
    else     console.log(data.Buckets);           // successful response

    var getting_bucket_name = '1';

	 for (let i=0;i<data.Buckets.length;i++){
		         if(data.Buckets[i]['Name'].includes('raw')){
				           getting_bucket_name = data.Buckets[i]['Name'];
				         }
		     }

var upload = multer({
    storage: multerS3({
        s3: s3,
        bucket: getting_bucket_name,
        key: function (req, file, cb) {
            cb(null, file.originalname);
            }
    })
});


//Get SQS config
var sqs = new aws.SQS();

//Get Queue URL
var paramsSQS = {
    QueueName: 'joshi-queue'
};

var sqsQueueUrl = '';
sqs.getQueueUrl(paramsSQS, function(err, data) {
    if (err) {
        console.log("Error", err);
      } else {
          sqsQueueUrl = data.QueueUrl;
      }
    });

// initialize an dynamodb connection object
var dynamodb = new aws.DynamoDB();
var putItems = {
};

var myTableName="";
dynamodb.listTables(putItems, function(err, data) {
  if (err) console.log(err, err.stack); // an error occurred
  else    
  {
    console.log(data,"in list ");           // successful response
    myTableName=data.TableNames[0];
  }

});

//When user make a request to the ELB

app.get('/', function (req, res) {
    res.sendFile(__dirname + '/index.html');
});

//After the user upload information, insert information to the database
app.post('/upload', upload.array('uploadFile',1), function (req, res, next) {

// generate a UUID for this action
var id = uuidv4();

//Getting Name from the user in the index.html
var file_name = req.files[0].originalname;

//Getting bucket name and file name
var s3url = "https://"+getting_bucket_name+".s3.amazonaws.com/" + file_name;

//Getting Name from the user with the bucket name from the index.html
var username = req.body['name'];

//Getting Email from the user in the index.html
var email = req.body['email'];

 //Get the file name from user
var phone = req.body['phone'];


var sns = new aws.SNS({apiVersion: '2010-03-31'});

        var putItems = {};
        sns.listTopics(putItems, function(err, data) {
          if (err) console.log(err, err.stack); // an error occurred
          else     {
                var putItems = {
                    Protocol: 'sms', // required
                    TopicArn: data.Topics[0]['TopicArn'], // required
                    Endpoint: phone,
                };
                sns.subscribe(putItems, function(err, data) {
                if (err) console.log(err, err.stack); // an error occurred
                else     console.log(data);           // successful response
                });
                }
        });


//INSERT STATEMENT to insert the values from the POST

var putItems = {
    Item: {
     "RecordNumber": {
       S: id
      }, 
     "CustomerName": {
       S: username
      }, 
     "Email": {
       S: email
      },
      "Phone": {
        S: phone
       },
       "Stats": {
        S: "0"
       },
    "S3URL": {
        S: s3url
       }
    }, 
    ReturnConsumedCapacity: "TOTAL",
    TableName: myTableName
};

dynamodb.putItem(putItems, function(err, data) {
     if (err) console.log(err, err.stack); // an error occurred
     else     console.log(data); 
});
console.log('after put',myTableName);
var putItems = {
	   
	    TableName: myTableName
};
var dynamoData=[];

dynamodb.scan(putItems,function(err,data){
	    if (err) console.log(err, err.stack); // an error occurred
	    else{
		            dynamoData = data.Items;

console.log('after scsn',dynamoData);
res.write("UPLOAD PAGE".fontcolor("green") + "<br />");
res.write("--------------------------------------------------------------------------------" + "<br />");
 res.write("S3 Bucket Url:".fontcolor("Blue") + "<br />");		    
 res.write(s3url + "<br />");
 res.write("--------------------------------------------------------------------------------" + "<br />");

	res.write("User Name".fontcolor("Blue") + "<br />");	    
        res.write(username + "<br />")
        res.write("--------------------------------------------------------------------------------" + "<br />");
	
	res.write("File Name".fontcolor("Blue") + "<br />");	    
        res.write(file_name + "<br />");
        res.write("--------------------------------------------------------------------------------" + "<br />");
	
	res.write("User Email Address".fontcolor("Blue") + "<br />");
        res.write(email + "<br />");
        res.write("--------------------------------------------------------------------------------" + "<br />");
        
        res.write("User Phone Number".fontcolor("Blue") + "<br />");
        res.write(phone + "<br />");
        res.write("--------------------------------------------------------------------------------" + "<br />");
	
	res.write("Random UUID".fontcolor("Blue") + "<br />");	    
        res.write(id + "<br />");
        res.write("--------------------------------------------------------------------------------" + "<br />");

    
    res.write("File successfully uploaded to Amazon S3 Server".fontcolor("red") + "\n");
    
    var i;
	console.log(dynamoData,'data');

        res.end();
	}
});
var sqs = new aws.SQS();
var sqsQueueUrl= '';
var params= {
    QueueNamePrefix:'joshi-queue'
};

//Write Email and ID to sqs
var paramsMessage = {

    MessageAttributes: {
      "Title": {
        DataType: "String",
        StringValue: "Form submission"
      },
      "Author": {
        DataType: "String",
        StringValue: username
      },
    },
    MessageBody: email + "|" + id,
    QueueUrl: sqsQueueUrl
  };

  sqs.sendMessage(paramsMessage, function(err, data) {
     if (err) {
       console.log("SQSError", err);
     }
   });
});

app.listen(3300, function () {
    console.log('Amazon s3 file upload app listening on port 3300');
});

app.get('/gallery', function (req, res) {

    /* List Content of the DyanmoDB database here or you can list the objects in S3 Bucket*/
    var dynamoData=[];
    var putItems = {
        TableName: myTableName
    };
    res.write("Gallery Page".fontcolor("Green") + "<br />");
    dynamodb.scan(putItems,function(err,data){
            if (err) console.log(err, err.stack); // an error occurred
            else{
                        dynamoData = data.Items;
                        console.log('in gallery',dynamoData);
        console.log("--------------------------------------------------");
        var i;
        console.log(dynamoData,'data');
         for (i=0;i<dynamoData.length;i++){
            res.write("Customer Name:".fontcolor("Blue") + dynamoData[i].CustomerName["S"]+ "<br />");
		 	res.write("RecordNumber:" + dynamoData[i].RecordNumber["S"]+ "<br />");
                     res.write("Email:" + dynamoData[i].Email["S"]+ "<br />");
                 res.write("Phone:" + dynamoData[i].Phone["S"]+ "<br />");
		   res.write("Status" + dynamoData[i].Stats["S"]+ "<br />");
                     res.write("S3 link" + dynamoData[i].S3URL["S"]+ "<br />");
             res.write("-------------------------------------------------------------------------------------"+"\n" + "<br />" );
                 }

             res.end();
         }
     });

 });
    

 }); 


