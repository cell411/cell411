const mongodb = await import('mongodb');
const MongoClient = mongodb.default;
import fs from 'fs';
import './util.mjs';
import 'parse-global';

const config=await readJson(configDir+"/production.config.json");
var connection;
var srcDB;

async function mongoOpen() {
  if(!connection)
    connection = await new MongoClient(config.mongoURL);
  return connection;
};
export async function mongoClose() {
  console.log({connection});
  if(connection)
    await connection.close();
};
var stime=0;
function elapsed(text){
  const ctime=new Date().getTime();
  if(!stime)
    stime=ctime;
  const res=ctime-stime;
  outln(text+" etime: "+res);
  return res;
};
export async function loadWithCache(oldClassName,query) {
  elapsed("starting etime: "+oldClassName);
  
  const file = "cache/"+oldClassName+".json";
  if(!fs.existsSync(file)){
    console.log("creating "+file);
    var srcCon=await mongoOpen();
    if(!srcDB)
      srcDB = await srcCon.db();
    var srcCursor = await srcDB.collection(oldClassName).find(query);
    var objects = await srcCursor.toArray();
    fs.writeFileSync(file,JSON.stringify(objects,null,2));
  } else {
    outln("    using cached "+file);
  };
  outln("     reading "+file);
  var res= JSON.parse(fs.readFileSync(file));
  outln(" ... ");
  outln("     "+res.length+" items in "+elapsed());
  return res;
};
