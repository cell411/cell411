#!node
await import('./parse-login.mjs');

async function main() {
  console.log("main: enter");
  const user = await parseLogin();
  console.dump(user);
  const sessionToken=user.getSessionToken();
  const options={sessionToken};
  console.dump(options);
  if(false) {
    const query = new Parse.Query("PublicCell");
    query.equalTo("owner",user);
    const cells = await query.find();
    for(var i=0;i<cells.length;i++){
      cells[i].set("description","desc at"+(new Date()));
      cells[i].save(null,options);
    };
  } else {
    const PublicCell = Parse.Object.extend("PublicCell");
    const query = new Parse.Query(PublicCell);
    query.equalTo("owner",user);
    const numCells=await query.count();
    console.log(`${numCells} cells`);
    const cell = new PublicCell();
    cell.set("name",`TestCell #${numCells}`);
    cell.set("owner",user);
    cell.set("category","category");
    cell.set("cellType",3);
    cell.set("location",new Parse.GeoPoint(72,43));
    cell.set("isVerified",false);
    cell.set("description","description");
    cell.set("verificationStatus",0);
    await cell.save(null,options);
    const userQuery = new Parse.Query(Parse.User);
    const userCount = userQuery.count();
    const start=Math.round(userCount*Math.random());
    userQuery.skip(start);
    userQuery.limit(10);
    const users=await userQuery.find();
    for(var i=0;i<users.length;i++){
      console.dump(users[i].id);
      //setTimeout(async ()=>{
      cell.relation("members").add(users[i]);
      await cell.save(null,options);
      //}, i*2000);
    }
  }
};
main();
