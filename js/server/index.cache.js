#!/usr/bin/env node
const flavor = process.env.PARSE_FLAVOR || "geocache";
require("global");
//console.log=console.trace;
const ParseServer = require("parse-server").ParseServer;
const express = require("express");
const fs = require("fs");
const path = require("path");
const fileUpload = require("express-fileupload");
const pwd=process.env.PWD;
const uploadDir = pwd+"/uploads/";

// ----- This is the aws shit.
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
    Body: fs.readFileSync("uploads/"+fileName),
  };
  params.ACL = 'public-read';
  params.ContentType = "image/png";
  global.ret = global.ret;
  const promise = new Promise((resolve,reject)=>{
    S3Client.upload(params, (err,res) => {
      if(err!=null) {
        reject({err});
      } else {
        const url=res.Location;
        resolve({url});
      }
    });
  });
  const ret = await promise;
  console.log(ret);
  return ret;
};
// --- End of AWS shit.
async function main() {
  global.config=await loadConfig();

  await setupExpress();


  const startTime=new Date().getTime();
  setTimeout(checkFiles,5000);
  function checkFiles() {
    const list = [ './index.cache.js', './cache/main.js' ];
    for(var i=0;i<list.length;i++){
      const file=list[i];
      if(!file.endsWith(".js"))
        continue;
      const stat=fs.statSync(file);
      if(stat.mtime.getTime()>startTime){
        console.warn("Exiting due to cloud code update");
        process.exit(0);
      };
    };
    setTimeout(checkFiles,5000);
  };
}

/// FUNCTIONS DOWN HERE.


async function makeUploadDir(uploadDir) {
  console.log(`making upload dir: '${uploadDir}'`);
  try {
    fs.mkdirSync(uploadDir,{recursive:true});
  } catch ( err ) {
    console.error(err);
  };
};

async function fileUploadHandler (req, res) {
  let sampleFile;
  console.log("Here we are!");
  if (!req.files || Object.keys(req.files).length === 0) {
    return res.status(400).send('No files were uploaded.');
  }
  // The name of the input field (i.e. "sampleFile") is used to retrieve the uploaded file
  sampleFile = req.files.sampleFile;
  console.log({sampleFile}); 
  const uploadPath = uploadDir + sampleFile.name;


  console.log({uploadPath});
  // Use the mv() method to place the file somewhere on your server
  const xxx = sampleFile.mv(uploadPath, async function(err) {
    if (err)
      return res.status(500).send(err);

    const response = await createFile(sampleFile.name);
    response.message="File Uploaded";
    return res.status(200).contentType("application/json").send(JSON.stringify(response));
  });
  console.log({xxx});
};
//   const fileUploadPageText = fs.readFileSync("index.html");
//   async function fileUploadPage(req,res){
//     res.status(200).send(fileUploadPageText);  
//   };
async function citiesHandler(req,res) {
  const query = Parse.Query("city");
  const cities = readFully(query);
  return res.status(200).send(JSON.stringify({cities}));
};
async function reverseGeocodeHandler(req, res) {
  try {
    const query=req.query;
    const request={};
    request.params=query;
    console.dump(request);
    const result=await reverseGeocode(request);
    return res.status(200).send( JSON.stringify(result,null,2) );
  } catch ( err ) {
    console.error(err);
    return res.status(400).send( err );
  };
};
async function geocodeHandler(req, res) {
  try {
    const query=req.query;
    const request={};
    request.params=query;
    console.dump(request);
    const result=await geocode(request);
    return res.status(200).send( JSON.stringify(result,null,2) );
  } catch ( err ) {
    console.error(err);
    return res.status(400).send( err );
  };
};
async function die(msg) {
  console.error(msg);
  process.exit(1);
};
async function loadConfig() {
  const home=process.env.HOME;
  const configFile = home+"/.parse/config-"+flavor+".json";
  const configText = fs.readFileSync(configFile);
  const config = JSON.parse(configText);
  const env=process.env;

  config || await die("failed to read: "+configFile);

  if(env['PARSE_SERVER_LOGS_FOLDER']){
    console.log("overriding conf log folder from environment");
    config.logsFolder=env['PROCESS_SERVER_LOGS_FOLDER'];
  } else if(Object.prototype.hasOwnProperty(config,"logFolder")) {
    env['PARSE_SERVER_LOGS_FOLDER']=config.logsFolder;
  };

  return config;
};
async function setupExpress() {
  const fileUploadObj=fileUpload();
  const app = express();
  app.use(fileUploadObj);
  app.post('/upload/index.html', fileUploadHandler);
  app.use(config.mountPath, new ParseServer(config));
  app.get('/cities', citiesHandler);
  app.get('/reverseGeocode', reverseGeocodeHandler);
  app.get('/geocode', geocodeHandler);
  const httpServer = require('http').createServer(app);
  httpServer.listen(config.port, function () {
    console.log('geocache server running on port ' + 
      config.port + '.');
  });
};
main().then((res)=>{console.log("main returned");})
.catch((err)=>{console.error("error:",err)});
