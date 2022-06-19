const model=require('./lib/parse.js');

async function beforeSavePrivateCell(req) {
  const cell = req.object;
  const user = req.user;
  await storeRelationshipUpdates(req,cell.id,"PrivateCell","members");
};
Parse.Cloud.beforeSave("PrivateCell",beforeSavePrivateCell);
