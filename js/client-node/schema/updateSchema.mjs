#!node
async function main() {
  await import("parse-global");
  await import("./parse-login.mjs");
  var user=await parseLogin();
  const schema = await new Parse.Schema("RelationshipUpdate");
  //schema.deleteField("relatedId");
  schema.addField("relatedId","String");
//     schema.addRelation("owner", "_User");
//     schema.addField("owningClass", "String");
//     schema.addField("relatedClass", "String");
//     schema.addField("owningId", "String");
//     schema.addField("relatedId", "String");
//     await schema.save();
  schema.update();
};
main()
