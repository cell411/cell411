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
const allRels=[];
allRels.push(`select * from (`);
allRels.push(`select null as otype, null as oid, null as rtype, null as rid, null as extra`);
async function examineRelations(className,relations) {
  const names = Object.keys(relations);
  for(var i=0;i<names.length;i++) {
    const name=names[i];
    const type=relations[name].type;
    const target=relations[name].targetClass;
    const owning=relations[name].owningClass;
    const table='_Join:'+name+":"+owning;
    if(type == "Relation") {
      allRels.push(`select '${owning}', "owningId", '${target}', "relatedId", '${table}' from "${table}"`);
    };
  };
};
async function examineFields(className,fields) {
  const names = Object.keys(fields);
  for(var i=0;i<names.length;i++) {
    const name=names[i];
    const type=fields[name].type;
    const target=fields[name].targetClass;
    if(type == "Pointer")
      allRels.push(`select '${className}', "objectId", '${target}', "${name}", '' from "${className}"`);
  };
};
async function examineConv(converter) {
  const names = Object.keys(converter)
  const className = converter.newClassName;
  console.log("");
  console.log(className);
  examineFields(className, converter.fields);
  examineRelations(className, converter.relations);

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
  
  const typeIds = Object.keys(converters);
  for(var i=0;i<typeIds.length;i++) {
    const typeId = typeIds[i];
    const converter=converters[typeId];
    await examineConv(converter);
  };
};
await createSchema();
var text=[];
text.push("create or replace view relview");
text.push("  as");
var i=0;
text.push(allRels[i++]);
text.push(allRels[i++]);
for(;i<allRels.length;i++){
  text.push("union");
  text.push(allRels[i]);
};
text = text.join("\n");
text=text+(`) foo where oid is not null and rid is not null`);
fs.writeFileSync("views/relview.sql",text);
