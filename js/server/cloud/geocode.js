//import fs from 'fs';
const fs = require("fs");
//   import pgpp from 'pg-promise';
//   import monitor from 'pg-monitor';
//   const opts ={};
//   const pgp=pgpp(opts);
//   monitor.attach(opts);
async function load_fetch() {
  const module = await import('node-fetch');
  global.fetch=module.default;
};
load_fetch();
const pg_config = JSON.parse(fs.readFileSync(process.env.HOME+"/.parse/postgres-cred-unix.json"));
//const db = pgp(pg_config);
const api_creds=JSON.parse(fs.readFileSync(process.env.HOME+"/.parse/geoapify-cred.json"));
const apiKey=api_creds.key;
const RevGeoCache = Parse.Object.extend("RevGeoCache");

function obj_to_query(obj) {
  const keys = Object.keys(obj);
  const vals = [];
  keys.forEach((key)=>{ vals.push([ key, obj[key]].join("=")) });
  return vals.join("&");
};
async function reverseGeocode(req) {
  var reverse_url="http://localhost:1336/reverseGeocode?";
  const point = req.params.location;
  const lat=point.latitude;
  const lng=point.longitude;
  const data = { lat, lng };
  if(req.params.type!=null)
    data.type=req.params.type;
  const query=obj_to_query(data);
  console.log(reverse_url+query);
  const requestOptions = {
    method: 'GET',
  };
  var res = await fetch(reverse_url+query, requestOptions);
  res=await res.json();
  console.dump(res);
  return res;
};
global.reverseGeocode=reverseGeocode;
async function geocode(req) {
  const data = { address: req.params.address, type: req.params.type };
  if(data.address==null || data.type==null)
    throw new Error("You must supply 'address' and 'type' for geocode.");
  const query=obj_to_query(data);
  const forward_url="http://localhost:1336/geocode?";
  const requestOptions = {
    method: 'GET',
  };
  var res = await fetch(forward_url+query, requestOptions);
  res = await res.json();
  console.dump(res);
  return res;
};
Parse.Cloud.define("reverseGeocode", reverseGeocode);
Parse.Cloud.define("geocode", geocode);
