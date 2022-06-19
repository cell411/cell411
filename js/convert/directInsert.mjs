import 'parse-global';
await loadParseConfig();
import { execSync } from 'child_process';
import { converters } from './converters.mjs';
import fs from 'fs';
import './util.mjs';
import pgpFn from "pg-promise";
const opts={};
console.inspect=function(obj){this.log(util.inspect(obj,opts));};

async function connect() {
  const promise1 = postgresCon().then((pgc)=>{
    console.log("pg done");
    return pgc;
  });
  const promise2 = mongoCon().then((mgc)=>{
    console.log("mg done");
    return mgc;
  });

  return Promise.all([promise1,promise2]);
};
const conns = await connect();
const pgc=conns[0];
const mgc=conns[1];

function done() {
  pgDone();
  mgDone();
}

dumpKeys(mgc);
const collect=await mgc.collection("_User");
const cursor=await collect.find();
function dumpKeys(obj){
  console.log(JSON.stringify(Object.keys(obj)));
};
cursor.forEach((user)=>{
  console.log(user);
});
//     const db=await pgp(pg_cred);
//     timeStamp("connect");
//     const con=await db.connect();
//     timeStamp("got con");
//     await db.none('delete from "_User"');
//     const query=await db.any('select * from "_UserRaw"');
//     var report=0; 
//     var start=new Date().getTime();
//     for(var i=0;i<query.length;i++){
//       const obj=query[i];
//       //obj.location="POINT("+obj.location.x+","+obj.location.y+")";
//       delete obj.location;
//       if(i-report==5000){
//         report=i;
//         var elap=new Date().getTime()-start;
//         console.log({i,elap});
//       };
//       await db.none('insert into "_User"(${this:name}) values ( ${this:csv} )', obj);
//     };
//     timeStamp("queryBack");
//     console.dump(query);
//     timeStamp("done");
//   async function postgresCon() {
//     timeStamp(
//   };
//   const promise=mongoCon();
//   
//   timeStamp("cursor");
//   async function useArray() {
//     const mongoCur = await mongoDB.collection(className).find();
//     timeStamp("objects - array");
//     const array = await mongoCur.toArray();
//     const count=array.length;
//     console.log({array1: count});
//     timeStamp("array");
//   };
//   async function useCursor() {
//     const mongoCur = await mongoDB.collection(className).find();
//     timeStamp("count 'em");
//     const array=[];
//     await mongoCur.forEach((rec)=>{ array.push(rec); });
//     const count=array.length;
//     console.log({array2: count});
//     timeStamp("cursor");
//   }
//   //const promise1=useArray().then(()=>{timeStamp("promise1 done");});;
//   const promise1=new Promise((resolve,reject)=>{resolve()});
//   promise1.then(()=>{timeStamp("promise1 done");});;
//   const promise2=useCursor();
//   promise2.then(()=>{timeStamp("promise2 done");});;
//   
//   Promise.all([promise1,promise2]).then(async ()=>{
//     timeStamp("done");
//     await mongoConnect.close();
//     timeStamp("closed");
//   });
function time() {
  return new Date().getTime();
};
function makeTime(str) {
  const start=time();
  var last=start;
  function timeStamp(msg){
    const now=time();
    const curr=now-last;
    const total=now-start;
    console.log({str,now,total ,msg});
    last=curr;
  };
  return timeStamp;
};

async function postgresCon() {
  const pg_cred = readJson("/home/parse/.parse/pg_admin.json");
  pg_cred.database="parse";
  const pgp = pgpFn({});
  const db = await pgp(pg_cred);
  global.pgDone=function(){
    console.log("Done with pg");
    pgp.end();
  };
  return db;
};

async function mongoCon() {
  const mongodb = await import('mongodb');
  const MongoClient = mongodb.default;
  const mongoConfig=await readJson(configDir+"/production.config.json");
  const url=mongoConfig.mongoURL;
  const opts={
    useUnifiedTopology: true
  };
  const mongoConnect = await new MongoClient.connect(url,opts);
  const mongoDB = mongoConnect.db();
  global.mgDone=function() {
    console.log("Done with mg");
    mongoConnect.close();
  };
  return mongoDB;
};
