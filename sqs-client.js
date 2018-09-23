
const AWS_REGION_STRING = process.env.AWS_REGION || 'us-east-1';
const AWS_ACCOUNT_ID = process.env.AWS_ACCOUNT_ID;
const SQS_QUEUE_NAME = process.env.SQS_QUEUE_NAME;

const AWS = require('aws-sdk');
AWS.config.update({
  region: AWS_REGION_STRING
});
const sqs = new AWS.SQS();

let params = {
  QueueUrl: `https://sqs.${AWS_REGION_STRING}.amazonaws.com/${AWS_ACCOUNT_ID}/${SQS_QUEUE_NAME}`
}

sqs.receiveMessage(params, function (err, response) {
  if (err) {
    console.log(err, err.stack);
    return;
  }

  try {
    let messageBody = response.Messages[0].Body;
    let notification = JSON.parse(messageBody);
    let messageAttributes = notification.MessageAttributes;
    let notificationMessage = JSON.parse(notification.Message);

    console.log('messageAttributes', JSON.stringify(messageAttributes, null, 2));
    console.log('notificationMessage.s3.bucket.name', notificationMessage.s3.bucket.name)
    console.log('notificationMessage.s3.object.key', notificationMessage.s3.object.key);
  } catch (error) {
    console.log("no messages yet");
  }
});
