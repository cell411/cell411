#!node
require("global");
if(global.Parse==null){
  const Parse = require('parse/node');
  global.Parse=Parse;
}
global.verbose=global.verbose;
global.now=function(){ DateTime.now().toISO() };
global.isNoE=function(str) {
  return str==null || str.length==0;
};
global.configFile="";
global.parseConfig=global.ParseConfig;
global.pf=function pf(obj){return JSON.stringify(obj,null,2);};
global.pp=function pp(obj){console.log(pf(obj));}
console.dump=function(obj){this.log(JSON.stringify(obj,null,2));};
global.configDir=process.env.HOME+"/.parse";
const base = configDir+"/config";
if ( !isNoE(process.env.PARSE_FLAVOR ) ) {
    global.configFile=base+"-"+process.env.PARSE_FLAVOR+".json";
} else {
  throw new Error("No arg, and PARSE_FLAVOR is not set.  WTF?");
};

global.findFully=async function findFully(query) {
  try {
    var skip=0;
    var limit=100;
    var res=[];
    var temp=await query.find();
    while(temp.length==limit){
      for(var i=0;i<limit;i++)
        res.push(temp[i]);
      skip+=limit;
      query.skip(skip);
      temp=await query.find();
    };
    for(var i=0;i<temp.length;i++)
      res.push(temp[i]);
    return res;
  } catch ( err ) {
    console.trace({
      query: query,
      error: err
    });
    throw err;
  };
};
global.loadParseConfig=async function loadConfig(){
  if(parseConfig)
    return parseConfig;
  const parseText = fs.readFileSync(global.configFile);
  global.parseConfig =JSON.parse(parseText);
  parseConfig.flavor=global.process.env.PARSE_FLAVOR;
  return parseConfig;
};
var parseInitialized=false;
global.initializeParse=async function initializeParse() {
  if(parseInitialized)
    return;
  parseConfig=await loadParseConfig();
  Parse.serverURL=parseConfig.serverURL; 
  await Parse.initialize(
    parseConfig.appId,
    parseConfig.javascriptKey,
    parseConfig.masterKey
  );
  return;
};

global.Request = Parse.Object.extend("Request");
Parse.Object.registerSubclass('Request', Request);
const User = Parse.Object.extend(Parse.User, 
  {
    getName: function getName() {
      return this.get("firstName")+" "+this.get("lastName");
    },
    findFriends: function findFriends() {
      console.trace("findFriends");
    }
  }
);
global.User=User;
Parse.Object.registerSubclass("User",User);
global.User.prototype.toString=function toString(){
  return "User{"+this.id+","+this.get("firstName")+" "+this.get("lastName")+"}";
};

global.Request = Parse.Object.extend("Request");
Parse.Object.registerSubclass('Request',Request);
global.Request.prototype.toString=function toString(){
  return "Request{"+this.id+"}";
};

global.Response = Parse.Object.extend("Response");
Parse.Object.registerSubclass('Response',Response);

global.Alert = Parse.Object.extend("Alert");
Parse.Object.registerSubclass('Alert',Alert);

global.PublicCell = Parse.Object.extend("PublicCell");
global.PublicCell.prototype.toString=function toString(){
  return "PublicCell{"+this.id+","+this.get("name")+"}";
};
Parse.Object.registerSubclass('PublicCell',PublicCell);

global.PrivateCell = Parse.Object.extend("PrivateCell");
Parse.Object.registerSubclass('PrivateCell',PrivateCell);

global.Role = Parse.Object.extend("_Role");
Parse.Object.registerSubclass('_Role',Role);

global.ChatMsg = Parse.Object.extend("ChatMsg");
Parse.Object.registerSubclass("ChatMsg",ChatMsg);

global.ChatRoom = Parse.Object.extend("ChatRoom");
Parse.Object.registerSubclass("ChatRoom",ChatRoom);

global.PrivacyPolicy = Parse.Object.extend("PrivacyPolicy");
Parse.Object.registerSubclass("PrivacyPolicy",PrivacyPolicy);

global.Friendship = Parse.Object.extend("Friendship");
Parse.Object.registerSubclass("Friendship",Friendship);
