const model=require('./lib/parse.js');

async function beforeSave_User(req) {
  const user = req.object;
  console.log("calling storeRU");
  await storeRelationshipUpdates(req,user.id,"_User","friends");
  console.log("calling storeRU");
  await storeRelationshipUpdates(req,user.id,"_User","spamUsers");
  const avatarFile = user.get("avatarFile");
  const avatar = user.get("avatar");
  if(avatarFile!=null && avatar==null){
    user.set("avatar",avatarFile.url());
    user.set("thumbNail",avatarFile.url());
  };
};
Parse.Cloud.beforeSave("_User",beforeSave_User);
