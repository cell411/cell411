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
export async function dumpSchemas() {
  await initializeParse();
  console.log("dumpSchemas");
  var health = await Parse.getServerHealth();
  console.log({health: health});
  if(!fs.existsSync("newSchema")) {
    fs.mkdirSync("newSchema");
  };
  const schemas = await Parse.Schema.all();
  for(var i=0;i<schemas.length;i++) {
    const schema=schemas[i];
    const name=schema.className;
    const json = JSON.stringify(schema,null,2);
    fs.writeFileSync("newSchema/"+name+".json",json);
  };
  console.log("dumpSchemas done");
};
dumpSchemas();
