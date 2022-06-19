#!node
await import('./parse-login.mjs');

async function main() {
  console.log("main: enter");
  const user = await parseLogin();
  const sessionToken=user.getSessionToken();
  const options={sessionToken};
  if(true) {
    const PublicCell = Parse.Object.extend("PublicCell");
    const query = new Parse.Query(PublicCell);
    var numCells;
    numCells=await query.count();
    console.log(`${numCells} cells`);
    const cell = new PublicCell();
    cell.set("name",`TestCell #${numCells}`);
    cell.set("owner",user);
    cell.set("category","category");
    cell.set("cellType",3);
    cell.set("location",user.get("location"));
    cell.set("isVerified",false);
    cell.set("description","description");
    cell.set("verificationStatus",0);
    await cell.save(null,options);
    numCells=await query.count();
    console.log(`${numCells} cells`);
    const userQuery = new Parse.Query(Parse.User);
    var userCount = await userQuery.count();
    const relation = cell.relation("members");
    for(var i=0;i<10;i++){
      const start=Math.round(userCount*Math.random());
      userQuery.skip(start);
      userQuery.limit(1);
      const users=await userQuery.find();
      await relation.add(users[0]);
      userCount--;
    }
    await cell.save(null,options);
  }
};
main();
