#!/usr/bin/env node
console.stdlog=console.log;
//console.log=console.trace;
const fs = require("fs");
const path = require("path");
const AWS = require('aws-sdk');
const AWScred = JSON.parse(fs.readFileSync(process.env.HOME+"/.parse/aws.cred.json"));
const S3Options = {
  params: { Bucket: "cell411" },
  accessKeyId:AWScred.aws.accessKey,
  secretAccessKey:AWScred.aws.secretKey
};
const S3Client = new AWS.S3(S3Options);

async function createFile(fileName) {
  const params = {
    Key: fileName,
    Body: fs.readFileSync(fileName),
  };
  params.ACL = 'public-read';
  params.ContentType = "image/png";
  S3Client.upload(params, (err,response) => {
    if(err!=null) {
      console.log({err});
    } else {
      console.log({response});
    }
  });
};
async function main() {
  await createFile("avatar.png");
  console.log("did it!");
};
main();
