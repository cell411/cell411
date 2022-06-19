console.dump=function(obj){console.log(JSON.stringify(obj,null,2));};
console.log("starting main.js");
var MD5 = require('md5.js')
require("parse-global");
require("global");
const xpp = require('./lib/util.js');
const model = require('./lib/modelUtils.js');
const sums = {};

const startTime = new Date().getTime();
setTimeout(checkFiles,5000);
function checkFiles() {
  const list = fs.readdirSync("cloud"); 
  for(var i=0;i<list.length;i++){
    const file=list[i];
    if(!file.endsWith(".js"))
      continue;
    const stat=fs.statSync("cloud/"+file);
    if(stat.mtime.getTime()>startTime){
      console.warn("Exiting due to cloud code update");
      process.exit(0);
    };
  };
  setTimeout(checkFiles,5000);
};
function firstTime() {
  const list = fs.readdirSync("cloud"); 
  for(var i=0;i<list.length;i++){
    const file=list[i];
    if(!file.endsWith(".js"))
      continue;
    require("./"+file);
  };
};
firstTime();
