import 'parse-global';
await loadParseConfig();
import { execSync } from 'child_process';
import { mongoClose } from './fromMongo.mjs';
import { loadWithCache } from './fromMongo.mjs';
import { converters } from './converters.mjs';
import { toSql } from './toSql.mjs';
import fs from 'fs';
import './util.mjs';

const userIndex={};
var dropped;
async function loadClass(converter) {
  const className = converter.oldClassName;
  outln("    Loading: "+className+" ...");
  const objectA = await loadWithCache(className, null);
  outln("        ... complete");
  const ids = [];
  converter.oldObjects=[];
  for(var i=0;i<objectA.length;i++) {
    const object=objectA[i];
    ids.push(object._id);
    converter.oldObjects.push(object);
  };
  outln("  loaded ", objectA.length," objects");
  const relNames = Object.keys(converter.relations);
  for(var i=0;i<relNames.length;i++) {
    const relName=relNames[i];
    const relConv=converter.relations[relName];
    const oldRelationName=relConv.oldRelationName;
    const newData={};
    if(relConv.wasArray) {
      for( var j=0;j<objectA.length;j++) {
        const oldObject = objectA[j];
        const oldArray = oldObject[relName];
        if(oldArray==null)
          continue;
        for(var k=0;k<oldArray.length;k++) {
          if(oldArray[k]==null)
            continue;
          const owningId=oldObject["_id"];
          const relatedId=oldArray[k].objectId;
          if(newData[oldObject["_id"]]==null)
            newData[oldObject["_id"]]={};
          newData[oldObject["_id"]][oldArray[k].objectId]=1;
        };
      };
      outln("  Copied Array: "+className+" -- "+relName);
    } else {
      briefln({name: relName, wasArray: false});
      const relTable="_Join:"+relName+":"+className;
      const relObjs = await loadWithCache(relTable, {owningId: { $in: ids}});
      for(var j=0;j<relObjs.length;j++) {
        if(newData[relObjs[j].owningId]==null)
          newData[relObjs[j].owningId]={};
        newData[relObjs[j].owningId][relObjs[j].relatedId]=1;
      };
      outln("  Loaded join table: "+className+" -- "+relName);
    };
    const array=[];
    const owningIds = Object.keys(newData);
    for(var j=0;j<owningIds.length;j++){
      const owningId=owningIds[j];
      const relatedIds = Object.keys(newData[owningId]);
      for(var k=0;k<relatedIds.length;k++) {
        const relatedId=relatedIds[k];
        array.push( { owningId: owningId, relatedId: relatedId });
      }
    };
    relConv.newObjects=array;
  };
  outln("  Loaded: "+converter.oldObjects.length+" "+className+"s");
  for(var i=0;i<relNames.length;i++) {
    const newObjects = converter.relations[relNames[i]].newObjects;
    outln("    "+relNames[i]+": "+newObjects.length);
  };
}


async function convertObject(converter, oldObject) {
  try {
    const newNames=Object.keys(converter.fields);
    const newObject = {};
    var list=converter.abortUnlessNull;
    if(list != null) {
      for(var i=0;i<list.length;i++) {
        if(oldObject[list[i]]!=null) {
          return null;
        };
      };
    };
    for(var i=0;i<newNames.length;i++){
      const newName=newNames[i];
      const field=converter.fields[newName];
      const convert=field['source'];
      const rejectIfNull=!!field.rejectIfNull;
      const defaultValue=field.defaultValue;
      var newVal;
      if(convert == undefined) {
        newVal=defaultValue;
      } else if ( typeof convert === 'boolean' ) {
        newVal=convert;
      } else if(typeof convert === 'string'){
        newVal=oldObject[convert];
      } else if ( typeof convert === 'function' ){
        newVal=convert(oldObject);
      } else {
        throw "WTF?";
      };
      if(rejectIfNull && newVal==null)
        return null;
      if(univConv[newVal]!=null){
        newVal=univConv[newVal];
      };
      newObject[newName]=newVal;
    }
    return newObject;
  } catch ( err ) {
    console.error(err);
    return null;
  };
};

const noOwner = {
  "_User": 1,
  "PrivacyPolicy": 1,
  "_Role": 1,
  "Friendship": 1
};
export async function convertClass(converter) {
  const newClassName=converter.newClassName;
  const oldObjects = converter.oldObjects;
  if(oldObjects==null)
    return;
  const newObjects = converter.newObjects = [];
  if(!converter.noCopy) { 
    for(var i=0;i<oldObjects.length;i++) {
      const oldObject = oldObjects[i];
      const newObject = await convertObject(converter, oldObject);
      if(newClassName==="PrivateCell"){
        console.log(newObject);
      };
      if(newObject==null) {
        dropped.push({pos: 1, class: newClassName, old: oldObject, new: newObject});
        continue;
      };
      if(!noOwner[converter.newClassName] && !userIndex[newObject.owner]) {
        if(newClassName=="PrivateCell") {
        };
        dropped.push({pos: 2, class: newClassName, old: oldObject, new: newObject});
        continue;
      };
      newObjects.push(newObject);
    };
  };
  if(!fs.existsSync("sql"))
    fs.mkdirSync("sql");
  const relNames = Object.keys(converter.relations);
  briefln({className: newClassName, relNames: relNames});
  for(var i=0;i<relNames.length;i++) {
    const relName = relNames[i];
    const relConv = converter.relations[relName];
    relConv.fields={};
    relConv.fields.owningId={
      type: "String",
      source: 'owningId',
    };
    relConv.fields.relatedId={
      type: "String",
      source: 'relatedId',
    };
    relConv.newClassName="_Join:"+relName+":"+newClassName;
    const array=[];
    if(!converter.noCopy) {
      for(var j=0;j<relConv.newObjects.length;j++) {
        const newObject=await convertObject(relConv,relConv.newObjects[j]);
        if(relConv.targetClass == "_User" && !userIndex[newObject['relatedId']]) {
          dropped.push({pos: 3, class: relConv.newClassName, field: "relatedId", object: newObject});
          continue;
        };
        if(relConv.owningClass == "_User" && !userIndex[newObject["owningId"]]) {
          dropped.push({pos: 4, class: relConv.newClassName, field: "owningId", object: newObject});
          continue;
        };
        array.push(newObject);
      }
    }
    relConv.newObjects=array;
  };
};
export async function saveClass(converter) {
  const sql = await toSql(converter);
  const newClassName = converter.newClassName;
  fs.writeFileSync("sql/"+newClassName+".sql", sql);
  const relConvs = converter.relations;
  const relNames = Object.keys(relConvs);
  for(var i=0;i<relNames.length;i++) {
    const relName=relNames[i];
    const relConv=relConvs[relName];
    const sql = await toSql(relConv);
    const file="sql/"+relConv.newClassName+".sql";
    outln("  writing "+file);
    fs.writeFileSync(file , sql);
  };
};
export async function saveData() {
  const classes = Object.keys(converters);
  outln("saving data");
  for(var i=0;i<classes.length;i++) {
    outln("  "+classes[i]);
    const converter=converters[classes[i]];
    await saveClass(converter);
  };
};
export async function convertData() {
  if(dropped)
    throw new Error("WTF?");
  dropped=[];
  const classes = Object.keys(converters);
  outln("converting data");
  for(var i=0;i<classes.length;i++) {
    outln("  "+classes[i]);
    const converter=converters[classes[i]];
    await convertClass(converter);
  };
  outln("done\n");
  dumpJson('dropped.json',dropped);
};

async function loadUsers() {
  const converter=converters["_User"];
  outln("load _User");
  await loadClass(converter,null);
  const array = converter.oldObjects;
  const userNames = {};
  const emails = {};
  const dups = {};
  const copy = [];
  for(var i=0;i<array.length;i++) {
    const user=array[i];
    var username=user.username;
    if(typeof(username)!='undefined') {
      userAliasIndex[username]=user._id;
      if(userNames[username]) {
        if(dups[username]) {
          dups[username]++;
        } else {
          dups[username]=1
        };
        continue;
      };
      userNames[username]=1;
    }
    var email=user.email;
    if(typeof(email)!='undefined') {
      userAliasIndex[email]=user._id;
      if(emails[email]) {
        if(dups[email])
          dups[email]++;
        else
          dups[email]=1;
        continue;
      };
      emails[email]=1;
    };
    var mobileNumber = user.mobileNumber;
    if(typeof(mobileNumber)!='undefined'){
      userAliasIndex[mobileNumber]=user._id;
    };
    userAliasIndex[user._id]=user._id;
    var objectId=user['_id'];
    userIndex[objectId]=1;
    if(username != null) {
      if(username.match('@copblock.app$')) {
        var prefix=user['username'].substr(0,username.length-13);
        univConv[objectId]=prefix;
        // we don't know *when* userIndex will be accessed, so pass old and new
        // objectIds
        userIndex[prefix]=1;
      } else if ( username.match("ian@freetalklive.com")) {
        var prefix='ian';
        univConv[objectId]=prefix;
        userIndex[prefix]=1;
      }
    }
  };
}
async function loadData(){
  outln("loadData");
  if(!fs.existsSync('cache')) 
    fs.mkdirSync('cache');

  if(converters["_User"]!=null){
    loadUsers();
  };
  const classes = Object.keys(converters);

  for(var i=0;i<classes.length;i++){
    const cname = classes[i];
    outln("    load "+cname);
    const converter=converters[cname];
    await loadClass(converter);
    outln("    load "+cname+" done");
  };
  outln("done\n");

};
console.log("FLAVOR: "+parseConfig.flavor);
if(parseConfig.flavor!=="empty"){
  await loadData().then(()=>console.log("loadData done"));;
  await convertData().then(()=>console.log("convData done"));;
  await saveData().then(()=>console.log("saveData done"));;
};
console.log("closing mongo");
await mongoClose();
console.log("mongo closed");
