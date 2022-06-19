#!node
global.fs=require('fs');
global.util=require('util');
global.Console=require("console").Console;
global.process=require("process");
global.stdout=process.stdout;
global.stderr=process.stderr;
global.stdin=process.stdin;
global.noe=function(str){return str==null || str.length==0};
global.pp=function(obj){return JSON.stringify(obj,null,2);};
global.show=function show(obj) { console.log(util.inspect(obj));};
global.keys=function keys(obj) { Object.prototype.keys(obj); }
global.readJson=function readJson(file){
  const text=fs.readFileSync(file);
  return JSON.parse(text);
};
global.dumpJson=function dumpJson(file, data) {
  fs.writeFileSync(file, JSON.stringify(data,null,2));
};
if(!console.dump){
  global.dump=console.dump=function dump(obj){this.log(JSON.stringify(obj,null,0));};
};
global.dumpKeys=function dumpKeys(obj,prefix){
  if(prefix==null)
    prefix="";
  const keys=Object.keys(obj);
  for(var i=0;i<keys.length;i++){
    console.log(prefix,keys[i]);
  };
};


