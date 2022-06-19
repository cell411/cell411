const util = await import('util');
const net = await import("net");
import './util.mjs';
import 'parse-global';
await loadParseConfig();
function dumpQuery(obj)
{
  console.log("\n\n");
  console.log("---------------------------------------");
  console.log("|", JSON.stringify(obj['query']), "|");
  console.log("---------------------------------------");
  console.log("\n\n");
};
const initOptions = {
  query: dumpQuery
};
const pgxxx = await import('pg-promise');
const pgp = pgxxx.default(initOptions);
async function pgCon(name, func){
  const pgp_cred=await readJson(configDir+'/pg_admin.json');
  pgp_cred.database=name;
  const db = pgp(pgp_cred);
  try {
    return await func(db).catch(async err=>{console.error("catch2",err);});
  } catch (err) {
    console.error(err);
  } finally {
    await pgp.end();
  };
};
const flavor=parseConfig.flavor;
async function createDB(db)  {
  console.log(`create DB "${flavor}"`);
  return await db.none("create database $1~",flavor);
};
async function dropDB(db) {
  console.log(`drop DB "${flavor}" if it exists`);
  await db.none("drop database if exists $1~",flavor);
};
async function isParseUp(){
  const promise = new Promise((resolve,reject)=>{
    const port = parseConfig.port;
    console.log(`   trying port ${port}`);
    const socket=net.createConnection({
      port
    },(c)=>{
      socket.end();
      console.log(`   parse ${flavor} is up`);
      resolve(true);
    });
    socket.on('error',(error)=>{
      if(error.code == "ECONNREFUSED") {
        console.log(`   parse ${flavor} is down`);
        resolve(false);
      } else {
        reject("got error "+error.code);
      }
    });
  });
  return await promise;
};
async function doEnsureParseDown(resolve,reject){
  console.log("ensureParseDown");
  if(await isParseUp()){
    console.log("  parse is up");
    await killParse();
    setTimeout(()=>{doEnsureParseDown(resolve,reject);},1000);
  } else {
    console.log("  parse is down");
    resolve(true);
  };
};
async function doEnsureParseUp(resolve,reject){
  console.log("ensureParseUp");
  if(await isParseUp()){
    console.log("  parse is up");
    resolve(true);
  } else {
    console.log("  parse is down");
    await startParse();
    setTimeout(()=>{doEnsureParseUp(resolve,reject);},1000);
  };
};
async function ensureParseDown() {
  const promise = new Promise(doEnsureParseDown);
  await promise; 
};
async function ensureParseUp() {
  const promise = new Promise(doEnsureParseUp);
  await promise; 
};
async function killParse() {
  console.log(`killing parse ${flavor}`);
  execSync(`svstat /var/cell411/cell411-${flavor}/`, {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
  execSync(`svc -d /var/cell411/cell411-${flavor}/`, {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
  execSync(`svc -t /var/cell411/cell411-${flavor}/`, {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
  execSync(`svstat /var/cell411/cell411-${flavor}/`, {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
};
async function startParse() {
  console.log(`starting parse ${flavor}`);
  execSync(`svstat /var/cell411/cell411-${flavor}/`, {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
  execSync(`svc -u /var/cell411/cell411-${flavor}/`, {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
  execSync(`svstat /var/cell411/cell411-${flavor}/`, {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
};
async function createExtensions(db)
{
  console.log("installing extensions");
  await db.none("create extension pgcrypto");
  await db.none("create extension postgis");
  await db.none("create extension postgis_topology");
  console.log("installing extensions ... done");
}
async function destroyAndCreate() {
  await ensureParseDown();
  await new Promise((resolve,reject)=>{
    setTimeout(resolve,2000);
  });
  await pgCon('admin',dropDB);
  await pgCon('admin',createDB);
  await pgCon(flavor,createExtensions);
  await ensureParseUp();
  console.log(await isParseUp());
};
await destroyAndCreate();
console.log("destroyAndCreate complete");
