#!node
import 'parse-global';
await loadParseConfig();
import { execSync } from 'child_process';
import fs from 'fs';
import { converters } from './converters.mjs';
import './util.mjs';
const constraints=[];
function q(x) {
  return "\""+x+"\"";
};
async function createRelationshipUpdateClass()
{
  const schema = await new Parse.Schema("RelationshipUpdate");
  schema.addPointer("owner", "_User");
  schema.addField("op","String");
  schema.addField("owningClass", "String");
  schema.addField("relatedClass", "String");
  schema.addField("owningId", "String");
  schema.addField("relatedId", "String");
  await schema.save();
};
export async function createSchema() {
  await initializeParse();
  try {
    Parse.getServerHealth()
    .then((res)=>{
      console.log(res);
    }).catch((err)=>{
      console.err(err);
    });
  } catch ( err ) {
    console.log(`catch block: ${err}`);
  };
  const user = Parse.User.logIn("dev4@copblock.app","asdf");  
  console.dump(user);
  const schema = await new Parse.Schema("LocationRec");
  schema.addPointer("user","_User");
  schema.addGeoPoint("location");
  schema.save();

};
createSchema();
