#!node
global.user=global.user;

const users=[];
users.push([]);

async function main() {
  await import("../parse-login.mjs");
  const user = await parseLogin();
  const users = await findFully(new Parse.Query("_User"));
  console.log(users.length);
  const todo = [];
  for(var i=1;i<2;i++) {
    const ids = {};
    const cells = await findFully(new Parse.Query("PrivateCell").equalTo("type",i));
    for(var j=0;j<cells.length;j++) {
      ids[cells[j].get("owner").id]=1;
    };
    for(var j=0;j<users.length;j++) {
      if(ids[users[j].id])
        continue;
      todo.push([ users[j].id, i ]);
    };
  };
  fs.writeFileSync("todo.json", JSON.stringify(todo,null,2));
}
main();
