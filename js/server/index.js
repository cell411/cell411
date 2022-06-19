#!/usr/bin/env node
console.stdlog=console.log;
console.log=console.trace;
const ParseServer = require("parse-server").ParseServer;
const express = require("express");
const fs = require("fs");
const path = require("path");
require("global");
const config=loadConfig();
const app = express();
// Serve static assets from the /public folder
const pwd=process.env.PWD;
app.use('/public', express.static(path.join(pwd, '/public')));

app.use(config.mountPath, new ParseServer(config));

app.get('/', function (req, res) {
  console.log("connection to root");
  res.status(200).send(
    "Who ya gonna call?  The cops might well shoot YOU!\n"
  );
});

const httpServer = require('http').createServer(app);
httpServer.listen(config.port, function () {
  console.stdlog('cell411 server running on port ' + 
    config.port + '.');
});
// This will enable the Live Query real-time server
ParseServer.createLiveQueryServer(httpServer);

module.exports = {
  app,
  config,
}
function loadConfig() {
  const flavor = process.env.PARSE_FLAVOR;
  if(flavor==null || flavor.length==0)
    die("missing flavor");
  const home=process.env.HOME;
  const configFile = home+"/.parse/config-"+flavor+".json";
  const configText = fs.readFileSync(configFile).toString();
  const config = JSON.parse(configText);
  const env=process.env;
  if(Object.hasOwn(config,"filesAdapter")) {
    const filesAdapter=config.filesAdapter;
    const options=filesAdapter.options;
    if(filesAdapter.module=="@parse/s3-files-adapter"){
      const s3ConfigFile = home+"/.parse/aws.cred.json";
      const s3ConfigText = fs.readFileSync(s3ConfigFile).toString();
      const s3Config = JSON.parse(s3ConfigText);
      const overrides={
      };
      overrides.accessKey=s3Config.aws.accessKey;
      overrides.secretKey=s3Config.aws.secretKey;
      config.filesAdapter.options.s3overrides=overrides;
    };
  };

  config || die("failed to read: "+configFile);

  if(env['PARSE_SERVER_LOGS_FOLDER']){
    config.logsFolder=env['PROCESS_SERVER_LOGS_FOLDER'];
  } else if(Object.prototype.hasOwnProperty(config,"logFolder")) {
    env['PARSE_SERVER_LOGS_FOLDER']=config.logsFolder;
  };
  return config;
};
function die(msg) {
  console.error("FATAL ERROR: "+msg);
  process.exit(1);
};
