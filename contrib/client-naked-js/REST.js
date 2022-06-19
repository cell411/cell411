console.log("REST.js.out:1:output");
const http = require('http');
const https = require('https');
const config = require(process.env.HOME+"/.parse/config.dev.json");
const fs = require('fs');
const users=["dPo0Nd78HA","SA51DpIrWp"];
const options = {
  baseUrl: config.pubServerURL,
  method: 'GET',
  headers: {
  "X-Parse-Application-Id": config.appId,
  "X-Parse-REST-API-Key": config.restAPIKey,
  "X-Parse-Revocable-Session": 1,
  "X-Parse-Master-Key": config.masterKey,
  "Content-Type": "application/json" 
  },
};
var token;
try {
  token=require('./key.json');
  if(typeof token === "object"){
    token=token.token;
  };
} catch ( err ) {
  console.log(err);
};
if(token!=null){
  options.headers["X-Parse-Session-Token"]=token;
};
options.host = new URL(options.baseUrl).host;
var name="_User";
async function funcCall(name,params) {
  console.log("funcCall");
  var reqOpts={ ...options };
  url=new URL(reqOpts.baseUrl+"/functions/"+name);
  reqOpts.method="POST";
  reqOpts.host=url.host;
  reqOpts.path=url.pathname;
  return runQuery(reqOpts,params);
}
async function login(username,password)
{
  console.log("login");
  if(token!=null)
    return null;
  var reqOpts={ ...options };
  url=new URL(reqOpts.baseUrl+"/login");
  reqOpts.host=url.host;
  reqOpts.method="POST";
  reqOpts.path=url.pathname;
  return runQuery(reqOpts, {username: username, password: password});
};
async function sendAlert() {
  console.log("classread");

  var params = {
    "where": { "user": users[0] },
    "data": {
      "cell411AlertId": "GWFqvBRK1Y",
      "createdAt": "1636573560730112233",
      "time": "",
      "userId": "dPo0Nd78HA",
      "firstName": "rich paul",
      "alertRegarding": "Car Broken",
      "alertType": "NEEDY",
      "alert": "Test",
      "badge": 1,
      "sound": "default"
    },
    "channel": "emergency_alert"
  };
  var reqOpts={ ...options };
  url=new URL(reqOpts.baseUrl+"/push");
  reqOpts.host=url.host;
  reqOpts.method="POST";
  reqOpts.path=url.pathname;
  return runQuery(reqOpts,params);
}
async function classRead(name,search) {
  console.log("classread");
  var reqOpts={ ...options };
  url=new URL(reqOpts.baseUrl+"/classes/"+name+"?"+postData);
  if(search != null)
    reqOpts.search="?"+postData;
  reqOpts.host=url.host;
  reqOpts.path=url.pathname+reqOpts.search;
  return runQuery(reqOpts, search);
}
async function runQuery(reqOpts, sendText) {
  console.log("runQuery");
  return new Promise((resolve,reject)=>{
    var data="";
    function handle(res) {
      res.setEncoding('utf8');
      res.on('data', (chunk) => {
        data=data+chunk;
      });
      res.on('end', () => {
        if(res.statusCode >= 200 && res.statusCode<300) {
          data=JSON.parse(data);
          resolve(data);
        } else {
          console.log("failed to load: "+reqOpts.path);
          reject(data);
        };
      });
    };
    const req = https.request(reqOpts, handle);
    req.on('error', (e) => {
      reject(`problem with request: ${e.message}`);
    });
    if(typeof sendText === "object")
      sendText=JSON.stringify(sendText);
    console.log(sendText);
    if(!(typeof sendText === "undefined"))
      req.write(sendText);
    req.end();
  });
};
async function doit() {
  console.log("doit");
  const userQuery = 'where='+JSON.stringify({ "objectId":users[0] });
  const postData={param: "param"};
  login("dev1@copblock.app","XXX").then((res)=>{
    if(res!=null) {
      token=res.sessionToken;
      if(token !=null) {
        const fd = fs.openSync("key.json","w");
        fs.writeSync(fd,JSON.stringify({token:token}));
        fs.closeSync(fd);
        options.headers["X-Parse-Session-Token"]=token;
      };
    };
    sendAlert().then((res)=>{
      console.log(res);
    }).catch((err)=>{
      console.error({err: err});
    });
//    funcCall("hello").then((hRes)=>{console.log(hRes);}).then(()=>{
//           funcCall("sendPush",{test: "good"}).then((spRes)=>{
//             console.log(spRes);
//           }).catch((err)=>{
//             console.log({err: err});
//           });
//       }).catch((err)=>{
//         console.log({err: err});
//       });
  }).catch((err)=>{
    console.log({err: err});
  });
}
doit();
