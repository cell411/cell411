const fs = require("fs");
async function load_fetch() {
  const module = await import('node-fetch');
  global.fetch=module.default;
};
load_fetch();
const pg_config = JSON.parse(fs.readFileSync(process.env.HOME+"/.parse/postgres-cred-unix.json"));
const api_creds=JSON.parse(fs.readFileSync(process.env.HOME+"/.parse/geoapify-cred.json"));
const apiKey=api_creds.key;
const City = Parse.Object.extend("city");
const Address = Parse.Object.extend("address");
const Input = Parse.Object.extend("input");

function obj_to_query(obj) {
  const keys = Object.keys(obj);
  const vals = [];
  keys.forEach((key)=>{ vals.push([ key, obj[key]].join("=")) });
  return vals.join("&");
};
const guesses = { 
  city: [ "city", "town", "villiage", "township", "hamlet", "municipality", "county", "area", "place" ],
  state: [ "state_code", "state", "province", "postcode" ], // Ok, the last one there really sucks.
  country: [ "country_code", "country", "nation", "empire", "continent" ]
};

async function first_match(array,map){
  for(var i=0;i<array.length;i++){
    const val =map[array[i]];
    if(val)
      return val;
  }
};
async function find_address_keys(res) {
  const city= await first_match(guesses.city, res);
  const state= await first_match(guesses.state, res);
  const country= await first_match(guesses.country, res);
  return { city, state, country };
};
async function process_result(type,res,input) {
  if(type=="city"){
    console.dump(res);
    if(res.Feature) {
      res=res.features;
      console.log("Feature");
    } else if(res.features) {
      res=res.features;
      console.log("features");
    }
    if(Array.isArray(res)) {
      console.log("array");
      res=res[0];
    } else {
      console.loog("no array");
    };

    const bbox=res.bbox;
    console.log({line: 56, bbox});
    if(res.properties) {
      res=res.properties;
      console.log("properties");
    };
    const result = await find_address_keys( res );
    console.log({line: 60, result });
    const city = result.city;
    const state = result.state;
    const country = result.country;
    if(
      bbox == null || 
      ( city == null && state == null ) ||
      ( state == null && country == null ) 
    ) {
      console.log( {line: 72, res,bbox,city,state,country} );
      throw new Error("failed to geocache those coordinates (1)\n\n"+JSON.stringify(res,null,2));
    };
    var location = null;
    var minLat,maxLat,minLng,maxLng;

    if( bbox == null ) {
      console.log("WARNING:  this city is a point.");
      var lat=res.lat;
      var lng=res.lon;
      location = new Parse.GeoPoint(lat,lng);
    } else {
       minLat = Math.min(bbox[1],bbox[3]);
       maxLat = Math.max(bbox[1],bbox[3]);
       minLng = Math.min(bbox[0],bbox[2]);
       maxLng = Math.max(bbox[0],bbox[2]);
       avgLat = (minLat+maxLat)/2;
       avgLng = (minLng+maxLng)/2;
      location = new Parse.GeoPoint(avgLat,avgLng);
    };

    var cache;
    const query = new Parse.Query("city");
    query.equalTo("location",location);
    query.limit(1);
    const cities = await query.find();
    if(cities.length>0){
      console.log("last chance hit (city)");
      cache=cities[0];
    } else {
      console.log("last chance miss (city)");
      const result={city,state,country,location,minLat,minLng,maxLat,maxLng,fromCache:false};
      if(result.city==null)
        result.city="";
      if(result.state==null)
        result.state="";
      if(result.country==null)
        result.country="";
      result.city=result.city.toLowerCase();
      result.state=result.state.toLowerCase();
      result.country=result.country.toLowerCase();
      cache = new City(result);
      cache.save(null,{useMasterKey: true});
    };
    if(input != null){
      const xinput = new Input({input: input, city: cache});
      await xinput.save(null,{useMasterKey: true});
    };
    setTimeout(()=>{ cache.set("fromCache",true); cache.save(null,{useMasterKey: true}); }, 100);
    return cache;
  } else if ( type === 'address' ) {
    res=res.features;
    res=res[0];
    if(
      res==null || 
      res.properties.city == null || 
      res.properties.state_code == null ||
      res.properties.country_code == null ||
      res.properties.lat == null ||
      res.properties.lon == null
    )
      throw new Error("failed to geocache those coordinates (2)\n\n"+JSON.stringify(res,null,2));
    res=res.properties;
    var lat=res.lat;
    var lng=res.lon;
    const location = new Parse.GeoPoint(lat,lng);
    var cache;
    const query = new Parse.Query("address");
    query.equalTo("location",location);
    query.limit(1);
    const addresses = await query.find(); 
    if(addresses.length>0){
      console.log("last chance hit (address)");
      cache=addresses[0];
    } else {
      console.log("last chance miss (address)");
      const city=res.city.toLowerCase();
      const state=res.state_code.toLowerCase();
      const country=res.country_code.toLowerCase();
      var address = [ res.address_line1.toLowerCase(),city,state,country ].join(", ");
      const result = { city, state, country, address, location, fromCache: false };
      cache = new Address(result);
      cache.save(null,{useMasterKey: true});
    };
    if(input != null){
      const xinput = new Input({input: input, address: cache});
      await xinput.save(null,{useMasterKey: true});
    };
    setTimeout(()=>{ cache.set("fromCache",true); cache.save(null,{useMasterKey: true}); }, 100);
    return cache;
  } else {
    throw new Error("cannot handle type: '"+type+"'");
  };
}
async function reverseGeocode(req) {
  const reverse_url="https://api.geoapify.com/v1/geocode/reverse?";
  var lat=req.params.lat;
  var lng=req.params.lng;
  if(typeof lat === 'string')
    lat=JSON.parse(lat);
  if(typeof lng === 'string')
    lng=JSON.parse(lng);
  var type=req.params.type;
  if(type==null)
    type='city';
  if(type==='city'){
    if(true){
      console.log("doing city lookup on coords");
      const query=new Parse.Query(City);
      query.lessThanOrEqualTo("minLat",lat);
      query.greaterThanOrEqualTo("maxLat",lat);
      query.lessThanOrEqualTo("minLng",lng);
      query.greaterThanOrEqualTo("maxLng",lng);
      const location = new Parse.GeoPoint(lat,lng);
      // causes the results to be sorted.
      query.withinMiles("location",location,50,true);
      query.limit(1);
      const caches = await query.find();
      if(caches.length>0){
        console.log("cacheHit (city)");
        const cache=caches[0];
        const result = JSON.parse(JSON.stringify(caches[0]));
        return result;
      } else {
        console.log("cacheMiss (city)");
      };
    };
    const lon=lng;
    const data = {lat,lon, apiKey,limit:1 };
    if(req.params.type!=null)
      data.type=req.params.type;
    const query=obj_to_query(data);
    const requestOptions={};
    var url = reverse_url+query;
    var res = await fetch(url, requestOptions);
    var json = await res.json();
    var result= await process_result(type,json);
    console.dump({url,result});
    return result;
  } else if(type=="address") {
    if(true){
      console.log("doing address lookup on coords");
      const query=new Parse.Query(Address);
      const location = new Parse.GeoPoint(lat,lng);
      // causes the results to be sorted.
      query.withinMiles("location",location,0.01,true);
      query.limit(1);
      const caches = await query.find();
      if(caches.length>0){
        console.log("cacheHit (address)");
        const cache=caches[0];
        const result = JSON.parse(JSON.stringify(cache));
        return result;
      } else {
        console.log("cacheMiss (address)");
      };
    }
    const lon=lng;
    const data = {lat,lon, apiKey,limit:1 };
    const query=obj_to_query(data);
    const requestOptions={};
    var url = reverse_url+query;
    var res = await fetch(url, requestOptions);
    var json = await res.json();
    var result= await process_result(type,json);
    console.dump({url,result});
    return result;
  } else {
    throw new Error("cannot handle type '"+type+"'");
  };
};
global.reverseGeocode=reverseGeocode;
async function geocode(req) {
  const input = req.params.address.toLowerCase();
  const type = req.params.type;
  const data = { text: input, apiKey: apiKey, limit: 1 };
  if(data.text==null || type==null)
    throw new Error("You must supply 'address' and 'type' for geocode.");
  if(type=="city") {
    var city;
    {
      console.log("doing input lookup");
      const query = new Parse.Query(Input);
      query.equalTo("input",input);
      query.limit(1);
      query.include("city");
      const inputs = await query.find();
      if(inputs.length>0)
        city=inputs[0].get("city");
    }
    if(city==null){
      console.log("doing city lookup");
      data.type=type;
      var parts = input.split(",");
      const query = new Parse.Query(City);
      if(parts.length>2)
        query.equalTo("country",parts[2]);
      query.equalTo("state",parts[1]);
      query.equalTo("city",parts[0]);
      query.limit(1);
      const cities = await query.find();
      if(cities.length>0){
        city=cities[0];
        const xinput = new Input({input,city});
        await xinput.save(null,{useMasterKey: true});
      };
    };
    if(city!=null) {
      const result = JSON.parse(JSON.stringify(city));
      return result;
    };
  } else if (type=="address") {
    var address;
    var fromInput=false;
    {
      console.log("doing input lookup");
      const query = new Parse.Query(Input);
      query.equalTo("input",input);
      query.limit(1);
      query.include("address");
      const inputs = await query.find();
      if(inputs.length>0) {
        console.log("input cache hit");
        address=inputs[0].get("address");
      } else {
        console.log("input cache miss");
      };
    }
    if(address==null){
      console.log("doing address lookup");
      const query = new Parse.Query(Address);
      query.equalTo("address",input);
      query.limit(1);
      const addresses = await query.find();
      if(addresses.length>0) {
        console.log("address cache hit");
        address=addresses[0];
        const xinput = new Input({input,address});
        await xinput.save(null,{useMasterKey: true});
      } else {
        console.log("address cache miss");
      };
    }
    if(address!=null){
      const result = JSON.parse(JSON.stringify(address));
      return result;
    }
  }
  const query=obj_to_query(data);
  const forward_url="https://api.geoapify.com/v1/geocode/search?";
  const requestOptions = {
    method: 'GET',
  };
  var url = forward_url+query;
  var res = await fetch(url, requestOptions);
  var json = await res.json();
  var result= await process_result(type,json,input);
  console.dump({input,url,result});
  return result;
};
global.geocode=geocode;
Parse.Cloud.define("reverseGeocode", reverseGeocode);
Parse.Cloud.define("geocode", geocode);
