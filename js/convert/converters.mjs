import 'parse-global';
await loadParseConfig();
import { execSync } from 'child_process';
import { loadWithCache } from './fromMongo.mjs';
import fs from 'fs';

global.userAliasIndex={};
export var converters=[];
global.univConv={};

function makeConverter(oldName,newName) {
  const schema = new Object(JSON.parse(fs.readFileSync('oldSchema/'+oldName+'.json')));
  if(newName==null)
    newName=schema.className;
  var converter = {
    fields: JSON.parse(JSON.stringify(schema['fields'])),
    relations: {},
    oldClassName: schema.className,
    newClassName: newName,
  };
  delete converter.fields["ACL"];
  for(var key in converter.fields) {
    if(typeof(converter.fields[key].source)=='undefined')
      converter.fields[key].source=key;
    if(converter.fields[key].type == "Relation"){
      converter.relations[key]=converter.fields[key];
      converter.relations[key].owningClass=newName;
      delete converter.fields[key];
    };
  };
  converter.fields.objectId.source="_id";
  converter.fields.createdAt.source="_created_at";
  converter.fields.updatedAt.source="_updated_at";
  if(converter.fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
function makeChatRoomConverter() {
  const converter = makeConverter("ChatRoom");
  return converter;
};
converters['ChatRoom']=makeChatRoomConverter();
function makeChatMsgConverter() {
  const converter = makeConverter("ChatMsg");
  converter.fields.owner={
    "type": "Pointer",
    "targetClass": "_User",
  };
  converter.fields.text={
    "type": "String"
  };
  converter.fields.image={
    "type": "File"
  };
  converter.fields.location={
    "type": "GeoPoint"
  };
  return converter;
};
converters['ChatMsg']=makeChatMsgConverter();
function makePrivacyPolicyConverter() {
  const converter = makeConverter("PrivacyPolicy");
  return converter;
};
converters.PrivacyPolicy=makePrivacyPolicyConverter();
//   function makePushLogConverter() {
//     const converter = makeConverter("PushLog");
//     function owner() {
//       return "IPn0alWZ9a";
//     };
//     const fields = converter.fields;
//     fields.owner.type="Pointer";
//     fields.owner.targetClass="_User";
//     fields.owner.source=owner;
//     if(fields["objectId"]==null)
//       throw new Error("Need an objectId field");
//     return converter;
//   };
//   converters.PushLog=makePushLogConverter();
function makeRoleConverter() {
  const converter = makeConverter("_Role");
  const fields = converter.fields;
  for(var key in fields) {
    if(typeof(fields[key].source)=='undefined')
      fields[key].source=key;
    if(fields[key].type == "Relation"){
      relations[key]=fields[key];
      relations[key].owningClass=converter.newClassName;
      delete fields[key];
    };
  };
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
function makePrivateCellConverter() {
  function owner(user) {
    var objectId = user["_p_createdBy"];
    if(objectId==null)
      return null;
    if(objectId.startsWith("_User$"))
      objectId = objectId.substr(6);
    return objectId;
  };
  const converter = makeConverter("Cell","PrivateCell");
  const fields = converter.fields;
  const relations = converter.relations;
  delete fields["nauMembers"];
  fields["members"].type="Relation";
  fields["members"].targetClass="_User";
  fields["members"].wasArray=true;
  fields["members"].relationName="members";
  for(var key in fields) {
    if(typeof(fields[key].source)=='undefined')
      fields[key].source=key;
    if(fields[key].type == "Relation"){
      relations[key]=fields[key];
      relations[key].owningClass=converter.newClassName;
      delete fields[key];
    };
  };
  fields.objectId.source="_id";
  fields.createdAt.source="_created_at";
  fields.updatedAt.source="_updated_at";
  fields.owner=fields.createdBy;
  delete fields.createdBy;
  fields.owner.source=owner;
  fields.owner.required=true;
  fields.chatRoom={
    type: "Pointer",
    targetClass: "ChatRoom",
  };
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
//export const cellConverter=makeCellConverter();
function makeUserConverter() {
  function email(user) {
    var val=user['email'];
    if(val==null) {
      return user['username'];
    } else {
      return val;
    };
  };
  function doUsername(user) {
    var val=user['username'];
    if(val==null)
      val=user['email'];
    if(!val.match('@')) {
      return user["email"];
    } else if ( val.match('@.*@') ) {
      return user["email"];
    } else {
      return val;
    }
  };
  function username(user) {
    var res = doUsername(user);
    var username=user['username'];
    if(!username.match('@')) {
      username=user.email;
    };
    return res;
  };
  function newPublicCellAlert(user) {
    var res=user.newPublicCellAlert;
    return res==1;
  };
  function avatar(user) {
    var res= user.imageName;
    if(res==null)
      return null;
    return "https://s3.amazonaws.com/cell411/profile_pic/"+user._id+res+".png";
  };
  function thumbNail(user){
    var res= user.imageName;
    if(res==null)
      return null;
    return "https://s3.amazonaws.com/cell411/profile_pic/"+user._id+res+".png";
//    return "https://s3.amazonaws.com/cell411/profile_pic/"+user._id+res+".thumb.png";
  };
  function patrolMode(user) {
    var res=user.PatrolMode;
    if(res) {
      return true;
    } else {
      return false;
    };
  };
  var converter = makeConverter("_User");
  converter['abortUnlessNull']=[ 'isDeleted'];
  
  const fields=converter.fields;
  const relations=converter.relations;
  delete fields["password"];
  delete fields["rideRequestAlert"];
  delete fields["carImageName"];
  delete fields["syncContacts"];
  delete fields["authData"];
  delete fields["roleId"];
  delete fields["clientFirmId"];
  delete fields["tag"];
  delete fields['city'];
  delete fields['isDeleted'];
  delete relations['spammedBy'];
  delete fields["imageName"];
  fields["_hashed_password"]={ type: "String" };
  fields['patrolMode']=fields['PatrolMode'];
  delete fields['PatrolMode'];
  fields["patrolMode"].type="Boolean";
  fields['patrolMode'].source=patrolMode;
  fields.newPublicCellAlert.type="Boolean";
  fields.newPublicCellAlert.source=newPublicCellAlert;
  for(var key in fields) {
    if(typeof(fields[key].source)=='undefined')
      fields[key].source=key;
    if(fields[key].type == "Relation"){
      relations[key]=fields[key];
      relations[key].owningClass=converter.newClassName;
      delete fields[key];
    } else if (fields[key].type=="Boolean"){
      fields[key].required=true;
      fields[key].defaultValue=false;
    };
  };
  delete fields.emailVerified.defaultValue;
  fields.emailVerified.required=false;
  fields.email.source=email;
  fields.username.source=username;
  fields.thumbNail={
    type:"String",
    source: thumbNail
  };
  fields.avatar={
    type:"String",
    source: avatar
  };
  fields.consented={
    type: "Boolean",
    required: true,
    defaultValue: false
  };
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
function makeRequestConverter() {
  function cellPointer(alert){
    var objectId = alert["cellId"];
    if(objectId==null)
      return null;
    if(objectId.startsWith("PublicCell$"))
      objectId=objectId.substr(11);
    return objectId;
  };
  function owner(alert) {
    var objectId = alert["_p_issuedBy"];
    if(objectId==null)
      return null;
    if(objectId.startsWith("_User$"))
      objectId = objectId.substr(6);
    return objectId;
  };
  function sentTo(alert) {
    return userAliasIndex[alert.to];
  };
  const converter = makeConverter("Cell411Alert","Request");
  const fields = converter.fields;
  const relations = converter.relations;
  converter['abortUnlessNull']=[ 'alertId', 'alertType' ];


  var deadKeys = [ "additionalNote", "alertId", "alertType", "audience",
    "audienceAU", "audienceNAU", "cellId", "cellMembers", "cellName", "city",
    "country", "dispatchMode", "entryFor", "forwardedAlert", "forwardedBy",
    "forwardedToMembers", "fullAddress", "initiatedBy",
    "issuerFirstName", "issuerId", "location", "photo", "rejectedBy", "seenBy",
    "targetMembers", "targetNAUMembers", 'to', "totalPatrolUsers", "isGlobal"
  ];
  for(var key of deadKeys){
    delete fields[key];
    delete relations[key];
  };
  const keys = Object.keys(fields);
  for(var key in fields) {
    if(key.startsWith("totalA"))
      delete fields[key];
  };
  fields.sentTo = {
    source: sentTo,
    type: "Pointer",
    targetClass: "_User",
    rejectIfNull: true
  };
  fields.owner=fields.issuedBy;
  delete fields.issuedBy;
  fields.owner.source=owner;
  fields.owner.required=true;
  fields.owner.rejectIfNull=true;
  fields["cell"]={
    type: "Pointer",
    targetClass: "PublicCell",
    source: cellPointer
  };
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
function makeAlertConverter() {
  function forwardedAlert(alert) {
    var objectId = alert["_p_forwardedAlert"];
    if(objectId==null)
      return null;
    if(objectId.startsWith("Cell411Alert$"))
      objectId = objectId.substr(13);
    return objectId;
  };
  function forwardedBy(alert) {
    var objectId = alert["_p_forwardedBy"];
    if(objectId==null)
      return null;
    if(objectId.startsWith("_User$"))
      objectId = objectId.substr(6);
    return objectId;
  };
  function owner(alert) {
    var objectId = alert["_p_issuedBy"];
    if(objectId==null)
      return null;
    if(objectId.startsWith("_User$"))
      objectId = objectId.substr(6);
    return objectId;
  };
  function translateProblemType(alert) {
    var problemType = alert.alertType;
    if(problemType==null)
      return null;
    console.log(problemType);
    problemType=problemType.split(/ /).join("");
    console.log(problemType);
    if(problemType=="VehiclePulled")
      return "PulledOver";
    if(problemType=="VehicleBroken")
      return "BrokenCar";
    return problemType;
  }
  function isGlobal(alert) {
    return !!alert['isGlobal'];
  };
  const converter = makeConverter("Cell411Alert","Alert");
  const fields = converter.fields;
  const relations = converter.relations;
  converter.abortUnlessNull=['entryFor','cellId'];
  const keys = Object.keys(fields);
 
  const deadKeys=[
    "alertId",          "audience",            "audienceAU",   "audienceNAU",
    "cellId",           "cellMembers",         "cellName",     "city",
    "country",          "dispatchMode",        "entryFor",     "forwardedAlert",
    "forwardedBy",      "forwardedToMembers",  "fullAddress",  "initiatedBy",
    "issuerFirstName",  "issuerId",            "rejectedBy",   "seenBy",
    "targetMembers",    "targetNAUMembers",    "to",
  ];
  for(var key of deadKeys) {
    delete fields[key];
    delete relations[key];
  };
  for(var key in fields) {
    if(key.startsWith("totalA"))
      delete fields[key];
  };
  fields.isGlobal={
    source:isGlobal,
    type:'Boolean',
    required:true,
    defaultValue:false
  };
  fields.status={
    type: "String",
    required: true,
    defaultValue: "ACTIVE"
  };
  fields.chatRoom={ type: "Pointer", targetClass: "ChatRoom" };
  fields.address = { type: 'String' };
  fields.problemType=fields.alertType;
  fields.problemType.source=translateProblemType;
  delete fields.alertType;
  fields.media={ type: "String" };
  fields.note=fields.additionalNote;
  delete fields.additionalNote;
  fields.owner=fields.issuedBy;
  delete fields.issuedBy;
  fields.owner.source=owner;
  fields.owner.required=true;
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
function makePublicCellConverter() {
  function verified(publicCell) {
    return !!publicCell["isVerified"];
  };
  function owner(cell) {
    var objectId = cell["_p_createdBy"];
    if(objectId==null)
      return null;
    if(objectId.startsWith("_User$"))
      objectId = objectId.substr(6);
    return objectId;
  };
  const schema = new Object(JSON.parse(fs.readFileSync('oldSchema/PublicCell.json')));
  const fields = JSON.parse(JSON.stringify(schema['fields']));
  const relations = {};
  var converter = { fields: fields, relations: relations };
  converter.oldClassName=schema.className;
  converter.newClassName=schema.className;
  const keys = Object.keys(fields);
  delete fields["ACL"];
  delete fields["fullAddress"];
  delete fields["city"];
  delete fields["country"];
  delete fields["PublicCell"];
  delete fields["totalMembers"];
  fields.isVerified.type="Boolean";
  fields.isVerified.source=verified;
  for(var key in fields) {
    if(typeof(fields[key].source)=='undefined')
      fields[key].source=key;
    if(fields[key].type == "Relation"){
      relations[key]=fields[key];
      relations[key].owningClass=converter.newClassName;
      delete fields[key];
    } else if (fields[key].type=="Boolean"){
      fields[key].required=true;
      fields[key].defaultValue=false;
    };
  };
  fields.chatRoom={
    type: "Pointer",
    targetClass: "ChatRoom",
  };
  fields.location=fields.geoTag;
  delete fields.geoTag;
  fields.objectId.source="_id";
  fields.createdAt.source="_created_at";
  fields.updatedAt.source="_updated_at";
  fields.owner=fields.createdBy;
  delete fields.createdBy;
  fields.owner.source=owner;
  fields.owner.required=true;
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
//export const publicCellConverter = makePublicCellConverter();

converters["_User"]=makeUserConverter();
converters["Alert"]=makeAlertConverter();
converters["PrivateCell"]=makePrivateCellConverter();
converters["PublicCell"]=makePublicCellConverter();
converters["Request"]=makeRequestConverter();
converters["_Role"]=makeRoleConverter();

function makeResponseConverter() {
  const schema = new Object(JSON.parse(fs.readFileSync('oldSchema/AdditionalNote.json')));
  const fields = JSON.parse(JSON.stringify(schema['fields']));
  const relations = {};
  var converter = { fields: fields, relations: relations };
  converter.oldClassName=schema.className;
  converter.newClassName="Response";
  delete fields["ACL"];
  delete fields["seen"];
  for(var key in fields) {
    if(typeof(fields[key].source)=='undefined')
      fields[key].source=key;
    if(fields[key].type == "Relation"){
      relations[key]=fields[key];
      relations[key].owningClass=converter.newClassName;
      delete fields[key];
    };
  };
  fields['travelTime']=fields['writerDuration'];
  delete fields['writerDuration'];
  delete fields['writerName'];
  delete fields['alertType'];
  delete fields['cellId'];
  delete fields['cellName'];
  delete fields['userType'];
  fields['received']={
    type: "Boolean",
    required: true,
    defaultValue: false
  };
  fields['seen']={
    type: "Boolean",
    required: true,
    defaultValue: false
  };
  fields['canHelp']={
    type: 'Boolean',
    required: false
  }

  fields['forwardedBy'].type='Pointer';
  fields['forwardedBy'].targetClass='_User';
  fields['alert']=fields["cell411AlertId"];
  fields['alert'].type="Pointer";
  fields['alert'].targetClass='Alert';
  delete fields["cell411AlertId"];
  fields['owner']=fields["writerId"];
  fields['owner'].type="Pointer";
  fields['owner'].targetClass='_User';
  delete fields["writerId"];
  fields.objectId.source="_id";
  fields.createdAt.source="_created_at";
  fields.updatedAt.source="_updated_at";
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
converters["Response"]=makeResponseConverter();
//   converters["Friendship"]=makeFriendshipConverter();
