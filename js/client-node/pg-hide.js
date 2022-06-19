#!node
require("global");
const Parse = require('parse/node');
global.verbose=global.verbose;
global.isNoE=function(str) {
  return str==null || str.length==0;
};
global.Parse=Parse;
console.dump=function(obj){this.log(JSON.stringify(obj,null,2));};

const base = process.env.HOME+"/.parse/config";
if(!isNoE(process.argv[2])) {
  global.configFile=process.argv[2];
} else if ( !isNoE(process.env.PARSE_CONFIG) ) {
  global.configFile=process.env.PARSE_CONFIG;
} else if ( !isNoE(process.env.PARSE_FLAVOR ) ) {
    global.configFile=base+"-"+process.env.PARSE_FLAVOR+".json";
} else {
  throw new Error("No arg, PARSE_CONFIG is not set, and PARSE_FLAVOR is not set.  WTF?");
};

global.initializeParse=async function initializeParse() {
  console.log(config);
  const parseText = fs.readFileSync(global.configFile);
  global.config =JSON.parse(parseText);
  console.log(config);
  Parse.serverURL=config.serverURL; 
  Parse.initialize(
    config.appId,
    config.javascriptKey,
    config.masterKey
  );
};

global.Request = Parse.Object.extend("Request");
Parse.Object.registerSubclass('Request', Request);

global.User = Parse.Object.extend("_User", {
  getName() { return this.get("firstName")+" "+this.get("lastName"); }
});
Parse.Object.registerSubclass('_User',User);

global.Request = Parse.Object.extend("Request");
Parse.Object.registerSubclass('Request',Request);

global.Response = Parse.Object.extend("Response");
Parse.Object.registerSubclass('Response',Response);

global.Alert = Parse.Object.extend("Alert");
Parse.Object.registerSubclass('Alert',Alert);

global.PublicCell = Parse.Object.extend("PublicCell");
Parse.Object.registerSubclass('PublicCell',PublicCell);

global.PrivateCell = Parse.Object.extend("PrivateCell");
Parse.Object.registerSubclass('PrivateCell',PrivateCell);

global.Role = Parse.Object.extend("_Role");
Parse.Object.registerSubclass('_Role',Role);

global.ChatMsg = Parse.Object.extend("ChatMsg");
Parse.Object.registerSubclass("ChatMsg",ChatMsg);

global.ChatRoom = Parse.Object.extend("ChatRoom");
Parse.Object.registerSubclass("ChatRoom",ChatRoom);


