await import('parse-global');
await import('../parse-login.mjs');
//  import('parse-global');
//promise.then((res)=>{console.log(res);});
//promise.then(()=>{import("../parse-login.mjs")});
//promise.then((res)=>{console.log(res);});
//promise.then(()=>{console.log(global.parseLogin)});

async function main() {
  console.dump(process.argv);
  await initializeParse();
  const user = await parseLogin();
  var cellQuery = new Parse.Query(PublicCell);
  cellQuery.equalTo("owner",user);
  const cells = await cellQuery.find();
  console.dump(cells);
  if(cells==0){
    console.log(`${user.getName()} doesn't have any cells`);
    return;
  }
  const cellNum = Math.round(Math.random()*cells.length);
  const cell = cells[cellNum];
  console.dump(cell);
  console.log(cell.get("name"));
  var userQuery = new Parse.Query(Parse.User);
  var otherQuery=new Parse.Query(Parse.User);
  const count=await otherQuery.count();
  const first=Math.round(Math.random()*count);
  otherQuery.skip(first);
  otherQuery.limit(1);
  const other=(await otherQuery.find())[0];
  const request = new Request();
  request.set("owner",other);
  request.set("sentTo",user);
  request.set("cell",cell);
  await request.save();
  await request.fetch();
  console.dump(request);
}
await main();
