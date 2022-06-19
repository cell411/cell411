await import('./parse-login.mjs');

async function main() {
  console.log=console.trace;
  await initializeParse();
  const user = await parseLogin();
  const sessionToken=user.getSessionToken();
  const res = await  Parse.Cloud.run("checkLogin",null,{sessionToken});
  console.log({user});
}
main()
