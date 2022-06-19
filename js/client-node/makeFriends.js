#!node
global.user=global.user;

const users=[];
users.push([]);

async function main() {
  await import("./parse-login.mjs");
  const user = await parseLogin();
  if(false) {
    const schema = new Parse.Schema("RelationshipUpdate");
    schema.addField("op","String");
    schema.addField("owningClass","String");
    schema.addField("relatedClass","String");
    schema.addField("owningField","String");
    schema.addField("relatedField","String");
    schema.addField("owningId","String");
    schema.addField("relatedId","String");
    schema.save();
    return;
  }
  {
    const query = new Parse.Query("PublicCell");
    const count = await query.count();
    query.skip(count*Math.random());
    query.limit(1);
    const cell=(await query.find())[0];
    console.log({cell});
    cell.relation("members").add(user);
    cell.save(null,{sessionToken: user.getSessionToken()});
  }
  {
    const query = new Parse.Query("PrivateCell");
    const count = await query.count();
    query.skip(count*Math.random());
    query.limit(1);
    const cell=(await query.find())[0];
    console.log({cell});
    cell.relation("members").add(user);
    cell.save(null,{sessionToken: user.getSessionToken()});
  }
  {
    const query = new Parse.Query("_User");
    const count = await query.count();
    query.skip(count*Math.random());
    query.limit(1);
    const cell=(await query.find())[0];
    console.log({cell});
    cell.relation("friends").add(user);
    cell.save(null,{sessionToken: user.getSessionToken()});
  };
}
main();
