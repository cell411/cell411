import fs from 'fs';
import pgpp from 'pg-promise';
import monitor from 'pg-monitor';
import './parse-login.mjs';
import 'moment';
async function load_fetch() {
  var module = await import('node-fetch');
  global.fetch=module.default;
};
await load_fetch();
const opts ={};
const current = await parseLogin();
const tok = {sessionToken: current.getSessionToken()};
async function reverseGeocode(location,type) {
  if(location==null)
    return null;
  return Parse.Cloud.run("reverseGeocode",{location,type},tok);
};
global.navigator=global.navigator;
async function rand_users(query) {
  var count=await query.count();
  console.log({count});
  while(true) {
    let rank=Math.round(count*Math.random());
    query.skip(rank);
    query.limit(100);
    const users = await query.find();
    const copy=[];
    for(var i=0;i<users.length;i++) {
      if(users[i]!=null)
        copy.push(users[i]);
    };
    return copy;
  };
};

async function main() {
  if(process.argv.length>2) {
    var loc;
    var parts;
    console.log("got args");
    const argv=process.argv;
    if(process.argv.length==3) {
      parts = argv[2].split(/,/);
      console.dump(parts);
    } else if (process.argv.length==4) {
      parts = [ argv[2], argv[3] ];
    }
    if(parts.length!=2) {
      console.log("expected lat and lon, got: ", parts);
    } else {
      const point = new Parse.GeoPoint(parseFloat(parts[0]), parseFloat(parts[1]));
      const result = await Parse.Cloud.run("reverseGeocode",{location: point,type: "city"}, tok);
      console.dump(result);
    };
    process.exit(0);
  }

  console.log("loading 100 new locations");
  const query = new Parse.Query(Parse.User);
  var newLocation=0;
  var total=0;
  while(newLocation<100) {
    const randUsers = await rand_users(query);
    console.log(randUsers.length);
    for(var i=0;i<randUsers.length;i++) {
      total++;
      console.log({newLocation,i,total});
      const randUser=randUsers[i];
      var location = randUser.get("location");
      if(location==null)
        continue;
      const result = await Parse.Cloud.run("reverseGeocode", { location, type:"city" }, tok);
      if(!result.fromCache)
        newLocation++;
      if(newLocation>=100)
        break;
    };
  };
};
console.log("gonna run main");
await main();
