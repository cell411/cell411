#!node

const sums={};
var MD5 = require('md5.js')

function calcTextMD5(text) {
  const md5stream=new MD5();
  md5stream.end(text);
  return md5stream.read().toString('hex');
};
function calcFileMD5(dir,file){
  console.log("opening "+dir+"/"+file);
  const md5sum=calcTextMD5(fs.readFileSync(dir+"/"+file));
  return md5sum+"  "+file;
};
function calcListMD5(dir,list)
{
  list=list.sort(lengthFirstCompare);
  for(var i=0;i<list.length;i++){
    list[i]=calcFileMd5(dir+list[i])+"  "+list[i];
  };
  return list;
};

function pp(...args) {
  return JSON.stringify.apply(null, [args,null,2]);
}
function lenFirstCompare(a,b){
  const la=a.length;
  const lb=b.length;
  if(la!=lb) {
    if(la<lb)
      return -1;
    else
      return 1;
  } else if ( a==b ) {
    return 0;
  } else {
    if(a<b)
      return -1;
    else
      return 1;
  };
};

global.calcTextMD5=calcTextMD5;
global.calcFileMD5=calcFileMD5;
global.calcListMD5=calcListMD5;

global.lenFirstCompare=lenFirstCompare;
global.pp=pp;
