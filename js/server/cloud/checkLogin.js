async function checkLogin(req) {
  const user = req.user;
  console.dump(user);
  return user!=null;
}
Parse.Cloud.define("checkLogin", checkLogin);
