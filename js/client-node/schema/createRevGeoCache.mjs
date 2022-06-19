#!node
async function main() {
  await import("parse-global");
  await import("../parse-login.mjs");
  var user=await parseLogin();
  const schema = await new Parse.Schema("RevGeoCache");
  //schema.deleteField("relatedId");
  const fields = {
    "city": { "type": "String" },
    "state": { "type": "String" },
    "center": { "type": "GeoPoint" },
    "maxLat": { "type": "Number" },
    "maxLng": { "type": "Number" },
    "minLat": { "type": "Number" },
    "minLng": { "type": "Number" },
    "address": { "type": "String" },
    "country": { "type": "String" }
  };
  const keys = Object.keys(fields);
  for(var i=0;i<keys.length;i++){
    schema.addField(keys[i],fields[keys[i]].type);
  };
  try {
    schema.save();
  } catch ( err ) {
    schema.update();
  };
};
main()
