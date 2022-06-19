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
async function createCLP(className) {
  clp = new Parse.CLP();
  if(className !== "_User" && className !== "User") {
    clp.setGetRequiresAuthentication(true);
    clp.setFindRequiresAuthentication(true);
    clp.setCountRequiresAuthentication(true);
    clp.setCreateRequiresAuthentication(true);
    clp.setUpdateRequiresAuthentication(true);
    clp.setDeleteRequiresAuthentication(true);
    clp.setAddFieldRequiresAuthentication(true);
  }
  return clp;
};
export async function createSchema() {
  await initializeParse();


  var health = await Parse.getServerHealth();
  console.log({health});
  const user = new Parse.User();
  user.set("username","temp@copblock.app");
  user.set("password","noe");
  user.set("email","temp@copblock.app");
  await user.save(null,{useMasterKey: true});
  await user.destroy({useMasterKey: true});
  var health = await Parse.getServerHealth();
  console.log({health});

  var skipFields = [
    "objectId",
    "createdAt",
    "updatedAt",
    "_hashed_password",
  ];
  const names = Object.keys(converters);
  for(var i=0;i<names.length;i++) {
    const converter=converters[names[i]];
    console.dump({converter});
    const newSchema=await new Parse.Schema(converter.newClassName);
    console.dump({newSchema});
    //newSchema.setCLP(createCLP(converter.newClassSchema));
    const fields = converter.fields;
    const relations = converter.relations;
    for( var key in converter.fields ) {
      if(skipFields.includes(key))
        continue;
      var field = fields[key];
      newSchema.addField(key,field.type,field);
      if(field.type=="Pointer"){
        constraints.push({
          type: field.type,
          owningTable: names[i],
          owningField: key,
          relatedTable: field.targetClass,
          relatedField: "objectId",
          deleteAction: "on delete cascade",
        });
      };
    };
    for( var key in converter.relations ) {
      newSchema.addRelation(key,converter.relations[key].targetClass);
      const join= "_Join:"+key+":"+names[i];
      constraints.push({
        type: "Relation",
        owningTable: names[i],
        relationName: key,
        relatedTable: relations[key].targetClass,
        joinTable: join,
        deleteAction: "on delete cascade",
      });
    };
    if(newSchema.className.startsWith("_")) {
      await newSchema.update();
    } else {
      await newSchema.save();
    }
  };
  {
    const schema = await new Parse.Schema("RelationshipUpdate");
    schema.addPointer("owner", "_User");
    schema.addField("op","String");
    schema.addField("owningClass", "String");
    schema.addField("relatedClass", "String");
    schema.addField("owningId", "String");
    schema.addField("relatedId", "String");
//    schema.setCLP(clp);
    await schema.save();
  };
  
  constraints.push({
    type: "Pointer",
    owningTable: "_Session",
    owningField: "user",
    relatedTable: "_User",
    relatedField: "objectId",
    deleteAction: "on delete cascade",
  });

  execSync("mkdir -p newSchema");
  dumpJson('newSchema/constraints.json',constraints);
};
createSchema();
