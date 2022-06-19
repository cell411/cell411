import fs from 'fs';
global.fs=fs;

import child_process from 'child_process';
global.execSync=child_process.execSync;
global.format={};

global.arrayOut=function arrayOut(args) {
  for(var i=0;i<args.length;i++) {
    const arg=args[i];
    const type=typeof(arg);
    const func=format[type];
    if(func == null)
      throw new Error("No formatter for: "+type+" ["+arg+"]");
    process.stdout.write(func(arg));
  };
};
format[typeof([])]=format[typeof({})]=function(arg){return JSON.stringify(arg,null,2);};
format[typeof("")]=function(arg){return arg;};
format[typeof(undefined)]=function(arg){return "<undefined> ("+arg+")";};
format[typeof(0)]=function(arg){return ""+arg;};

global.out=function out(...args) {
  arrayOut(args);
};
global.outln=function outln(...args) {
  args.push("\n");
  arrayOut(args);
};
global.brief=function brief(...arg) {
  for(var i=0;i<arg;i++){
    if(typeof(arg[i])==typeof([])) {
      arg[i]=JSON.stringify(arg[i]);
    } else if ( typeof(arg[i])==typeof({}) ) {
      arg[i]=JSON.stringify(arg[i]);
    };
  };
  return arrayOut(arg);
}
global.briefln=function briefln(...arg){
  for(var i=0;i<arg;i++){
    if(typeof(arg[i])==typeof([])) {
      arg[i]=JSON.stringify(arg[i]);
    } else if ( typeof(arg[i])==typeof({}) ) {
      arg[i]=JSON.stringify(arg[i]);
    };
  };
  return arrayOut(arg);
};
