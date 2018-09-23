'use strict';

// ENV vars
const AWS_REGION_STRING = process.env.AWS_REGION || 'us-east-1';
const AWS_ACCOUNT_ID = process.env.AWS_ACCOUNT_ID;
const SNS_TOPIC_NAME = process.env.SNS_TOPIC_NAME;
const SNS_TOPIC_ARN = `arn:aws:sns:${AWS_REGION_STRING}:${AWS_ACCOUNT_ID}:${SNS_TOPIC_NAME}`;

const AWS = require('aws-sdk');
AWS.config.update({
  region: AWS_REGION_STRING
});

const s3 = new AWS.S3();
const sns = new AWS.SNS();

exports.handler = (message, context, callback) => {
  return main(message).then(function (result) {
    callback(null, result);
  }).catch(function (error) {
    callback(error);
  });
};

const main = async (notification) => {
  let record = notification.Records[0];
  let pathAttributes = getS3PathAttributes(record);
  let s3MetaData = await fetchS3MetaData(record);
  let metaData = {
    ...pathAttributes,
    ...s3MetaData
  };
  let messageAttributes = getMessageAttributes(metaData);
  let sendSnsResponse = await sendSns(record, messageAttributes);
  return sendSnsResponse.MessageId;
}

const getS3PathAttributes = function (record) {
  let attributes = {}

  try {
    attributes.bucket_name = record.s3.bucket.name;
    attributes.object_key = record.s3.object.key;
  } catch (error) {
    console.log(error);
  }

  return attributes;
}

const fetchS3MetaData = async (record) => {
  try {
    let params = {
      Bucket: record.s3.bucket.name,
      Key: record.s3.object.key
    }
    let response = await s3.headObject(params).promise();
    return response.Metadata;
  } catch (error) {
    console.log(error);
    return {};
  }
}

const getMessageAttributes = function (metaData) {
  let messageAttributes = {};
  Object.entries(metaData).forEach(
    ([key, value]) => {
      messageAttributes[key] = {
        DataType: 'String',
        StringValue: value
      }
    }
  );
  return messageAttributes;
}

const sendSns = async (record, messageAttributes) => {
  let params = {
    TopicArn: SNS_TOPIC_ARN,
    Message: JSON.stringify(record),
    MessageStructure: 'string',
    MessageAttributes: messageAttributes
  }
  return await sns.publish(params).promise();
}
