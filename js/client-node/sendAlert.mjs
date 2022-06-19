const xParse=await import('./parse-login.mjs');

async function main() {
  const user = await parseLogin();
  console.dump(user);
  console.log(Parse.User.current());
}
main()
