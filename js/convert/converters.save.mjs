import 'parse-global';
await loadParseConfig();
import { execSync } from 'child_process';
import { loadWithCache } from './fromMongo.mjs';
import fs from 'fs';

global.userAliasIndex={};
export const converters=[];
global.univConv={};

function makeConverter(oldName) {
  const schema = new Object(JSON.parse(fs.readFileSync('oldSchema/'+oldName+'.json')));
  var converter = {
    fields: JSON.parse(JSON.stringify(schema['fields'])),
    relations: {},
    oldClassName: schema.className,
    newClassName: schema.className,
  };
  delete converter.fields["ACL"];
  for(var key in converter.fields) {
    if(typeof(converter.fields[key].source)=='undefined')
      converter.fields[key].source=key;
    if(converter.fields[key].type == "Relation"){
      converter.relations[key]=fields[key];
      converter.relations[key].owningClass=converter.converter.newClassName;
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
    "type": "String"
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
function makePushLogConverter() {
  const converter = makeConverter("PushLog");
  function owner() {
    return "IPn0alWZ9a";
  };
  const fields = converter.fields;
  fields.owner.type="Pointer";
  fields.owner.targetClass="_User";
  fields.owner.source=owner;
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
converters.PushLog=makePushLogConverter();
function makeRoleConverter() {
  const schema = new Object(JSON.parse(fs.readFileSync('oldSchema/_Role.json')));
  const fields = JSON.parse(JSON.stringify(schema['fields']));
  const relations = {};
  var converter = { fields: fields, relations: relations };
  converter.oldClassName=schema.className;
  converter.newClassName=schema.className;
  delete fields["ACL"];
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
  const schema = new Object(JSON.parse(fs.readFileSync('oldSchema/Cell.json')));
  const fields = JSON.parse(JSON.stringify(schema['fields']));
  const relations = {};
  var converter = { fields: fields, relations: relations };
  converter.oldClassName=schema.className;
  converter.newClassName="PrivateCell";
  delete fields["ACL"];
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
  var converter = {
    oldSchema: 'oldSchema/_User.json',
    newSchema: 'newSchema/_User.json',
    oldClassName: "_User",
    newClassName: "_User",
  };
  const schema = new Object(JSON.parse(fs.readFileSync(converter.oldSchema)));
  const fields=JSON.parse(JSON.stringify(schema['fields']));
  const relations={};
  converter.relations=relations;
  converter.fields=fields;
  delete fields["ACL"];
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
  delete fields['spammedBy'];
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
    if(fields[key].type == "Relation" || fields[key].type == 'Array'){
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
  fields.objectId.source="_id";
  fields.createdAt.source="_created_at";
  fields.updatedAt.source="_updated_at";
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
  fields.lastConsent={
    type: "Pointer",
    targetClass: "PrivacyPolicy",
    required:false,
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
  function isFriendRequest(alert){
    return alert["entryFor"]=="FR";
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
  const schema = new Object(JSON.parse(fs.readFileSync('oldSchema/Cell411Alert.json')));
  const fields = JSON.parse(JSON.stringify(schema['fields']));
  const relations = {};
  var converter = { fields: fields, relations: relations };
  converter['abortUnlessNull']=[ 'alertId', 'alertType' ];
  converter.oldClassName="Cell411Alert";
  converter.newClassName="Request";
  const keys = Object.keys(fields);

  delete fields["additionalNote"];
  delete fields["alertId"];
  delete fields["alertType"];
  delete fields["audience"];
  delete fields["audienceAU"];
  delete fields["audienceNAU"];
  delete fields["cellId"];
  delete fields["cellMembers"];
  delete fields["cellName"];
  delete fields["city"];
  delete fields["country"];
  delete fields["dispatchMode"];
  delete fields["entryFor"];
  delete fields["forwardedAlert"];
  delete fields["forwardedBy"];
  delete fields["forwardedToMembers"];
  delete fields["fullAddress"];
  delete fields["initiatedBy"];
  delete fields["isGlobal"];
  delete fields["issuerFirstName"];
  delete fields["issuerId"];
  delete fields["location"];
  delete fields["photo"];
  delete fields["rejectedBy"];
  delete fields["seenBy"];
  delete fields["targetMembers"];
  delete fields["targetNAUMembers"];
  delete fields['to'];
  delete fields["totalPatrolUsers"];
  for(var key in fields) {
    if(key.startsWith("totalA"))
      delete fields[key];
  };
  for(var key in fields) {
    if(typeof(fields[key].source)=='undefined')
      fields[key].source=key;
    fields[key].wasArray=(fields[key].type == "Array");
    if( fields[key].type == "Array" )
    {
      if(!fields[key].keepArray) {
        fields[key].type="Relation";
        relations[key]=fields[key];
        relations[key].owningClass=converter.newClassName;
        delete fields[key];
      }
    } else if( fields[key].type == "Relation" ) {
      fields[key].type="Relation";
      relations[key]=fields[key];
      relations[key].owningClass=converter.newClassName;
      delete fields[key];
    } else if (fields[key].type=="Boolean"){
      fields[key].required=true;
      fields[key].defaultValue=false;
    };
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
  fields.objectId.source="_id";
  fields.createdAt.source="_created_at";
  fields.updatedAt.source="_updated_at";
  fields["cell"]={};
  fields["cell"].type="Pointer";
  fields["cell"].targetClass="PublicCell";
  fields["cell"].source=cellPointer;
  fields["isFriendReq"]={
    type:"Boolean",
    source:function(alert){ return alert["entryFor"]=='FR'; },
    required:true
  };
  delete fields["ACL"];
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
  function isGlobal(alert) {
    return !!alert['isGlobal'];
  };
  const schema = new Object(JSON.parse(fs.readFileSync('oldSchema/Cell411Alert.json')));
  const fields = JSON.parse(JSON.stringify(schema['fields']));
  const relations = {};
  var converter = { fields: fields, relations: relations, abortUnlessNull: [] };
  converter.abortUnlessNull=['entryFor','cellId'];
  converter.oldClassName="Cell411Alert";
  converter.newClassName="Alert";
  const keys = Object.keys(fields);
  
  delete fields["alertId"];
  delete fields["audience"];
  delete fields["audienceAU"];
  delete fields["audienceNAU"];
  delete fields["cellId"];
  delete fields["cellMembers"];
  delete fields["cellName"];
  delete fields["city"];
  delete fields["country"];
  delete fields["dispatchMode"];
  delete fields["entryFor"];
  delete fields["forwardedAlert"];
  delete fields["forwardedBy"];
  delete fields["forwardedToMembers"];
  delete fields["fullAddress"];
  delete fields["initiatedBy"];
  delete fields["issuerFirstName"];
  delete fields["issuerId"];
  delete fields["rejectedBy"];
  delete fields["seenBy"];
  delete fields["targetMembers"];
  delete fields["targetNAUMembers"];
  delete fields["to"];
//     fields["targetMembers"]={
//       type: "Relation",
//       targetClass:"_User",
//       relationName: "targetMembers",
//       wasArray: true,
//     };
  for(var key in fields) {
    if(key.startsWith("totalA"))
      delete fields[key];
  };
  fields.isGlobal.source=isGlobal;
  fields.isGlobal.type='Boolean';
  for(var key in fields) {
    if(typeof(fields[key].source)=='undefined')
      fields[key].source=key;
    if(
      fields[key].type == "Relation" ||
      fields[key].type == "Array")
    {
      if(fields[key].type=="Array")
        fields[key].wasArray=true;
      fields[key].type="Relation";
      relations[key]=fields[key];
      relations[key].owningClass=converter.newClassName;
      delete fields[key];
    } else if (fields[key].type=="Boolean"){
      fields[key].required=true;
      fields[key].defaultValue=false;
    };
  };
  fields.chatRoom={ type: "Pointer", targetClass: "ChatRoom" };
  fields.address = { type: 'String' };
  fields.problemType=fields.alertType;
  delete fields.alertType;
  fields.media={ type: "String" };
  fields.note=fields.additionalNote;
  delete fields.additionalNote;
  fields.objectId.source="_id";
  fields.createdAt.source="_created_at";
  fields.updatedAt.source="_updated_at";
  fields.owner=fields.issuedBy;
  delete fields.issuedBy;
  fields.owner.source=owner;
  fields.owner.required=true;
//     fields.forwardedBy.source=forwardedBy;
//     fields.forwardedAlert.source=forwardedAlert;
//     fields.forwardedAlert.targetClass="Alert";
  delete fields["ACL"];
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  converter.noCopy=true;  
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
//export const cell411AlertConverter=makeAlertConverter();
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
  converter.noCopy=true;
  if(fields["objectId"]==null)
    throw new Error("Need an objectId field");
  return converter;
};
converters["Response"]=makeResponseConverter();
