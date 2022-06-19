await import('./parse-login.mjs');

async function main() {
  await initializeParse();
  const user = await parseLogin();
  const sessionToken=user.getSessionToken();
  const res = await  Parse.Cloud.run("relations",null,{sessionToken});
  console.dump(res);
}
main()
