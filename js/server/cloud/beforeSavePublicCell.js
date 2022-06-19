const model=require('./lib/parse.js');

async function beforeSavePublicCell(req) {
  const cell = req.object;
  const user = req.user;
  await storeRelationshipUpdates(req,cell.id,"PublicCell","members");
};
Parse.Cloud.beforeSave("PublicCell",beforeSavePublicCell);
