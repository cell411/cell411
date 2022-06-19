async function setPassword(req) {
  const params = req.params;
  console.log(params);
  const username=params.username;
  const password=params.password;
  const query = new Parse.Query('_User');
  query.equalTo('username',username);
  const user = await query.first();
  if(!user) {
    throw new Parse.Error("no user with username: "+username);
  };
  console.log(user);
  user.set("password",password);
  user.save(null,{useMasterKey: true});
  return true;
}
Parse.Cloud.define("setPassword", setPassword);
