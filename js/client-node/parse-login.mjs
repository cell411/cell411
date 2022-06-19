console.log("loading parse-login.mjs");
global.currentUser=global.currentUser;
global.parseUsername=global.parseUsername;

await import("parse-global");
//console.log("entering parse-login.mjs");
const sessionTokenFile=process.env.HOME+"/.parse/sessionTokens.json";
var user;
async function loadSessionTokens()
{
  if(!fs.existsSync(sessionTokenFile))
    return {};
  const text = fs.readFileSync(sessionTokenFile).toString();
  return JSON.parse(text);
};
async function getSessionToken(username){
  const sessionTokens=await loadSessionTokens();
  const section=sessionTokens[parseConfig.flavor];
  if(!sessionTokens[parseConfig.flavor])
    return null;
  //console.dump({username,sessionTokens});
  return section[username];
};
global.getSessionToken=getSessionToken;
async function saveSessionToken(username,token){
  const sessionTokens=await loadSessionTokens();
  if(!sessionTokens[parseConfig.flavor])
    sessionTokens[parseConfig.flavor]={};
  const section=sessionTokens[parseConfig.flavor];
  if(token==null){
    delete section[username];
  } else {
    section[username]=token;
  };
  const text = JSON.stringify(sessionTokens,null,2);
  fs.writeFileSync(sessionTokenFile,text+"\n\n");
};
var rl;
global.getReadline=async function getReadline() {
  if(rl==null) {
    const process =await import('process');
    const { stdin: input, stdout: output } = process;
    const readline=await import ('node:readline/promises');
    rl=readline.createInterface({input,output,historysize: 0});
  };
  return rl;
};
var initialized=false;
async function parseLogin() {
  if(!initialized) {
    await initializeParse();
    initialized=true;
  };
  var readline;
  try {
    if(parseUsername==null)
      parseUsername=process.env.PARSE_USER;
    if(noe(parseUsername)){
      const rl = await getReadline();
      while(parseUsername==null){
        parseUsername=await rl.question('login: ');
        if(parseUsername=="quit"){
          process.exit(0);
        }
      };
    };
    if(parseUsername==null)
      throw new Error("failed to get username");
    if(!parseUsername.match('@'))
      parseUsername=parseUsername+"@copblock.app";
    var sessionToken=await getSessionToken(parseUsername);
    if(sessionToken==null){
      console.log("no session token");
      const rl=await getReadline();
      user = new Parse.User();
      const password=await rl.question('password: ');
      user.set("username",parseUsername);
      user.set("password",password);
      try {
        await user.logIn({useMasterKey: true});
        sessionToken=await user.getSessionToken();
      } catch ( err ) {
          console.log({err,where:"catch block"});
      };
    } else {
      try {
        user = await Parse.User.me(sessionToken);
        //console.log("logged in with token");
      } catch ( err ) {
        console.dump(err);
        if(err.code==209){
          saveSessionToken(parseUsername,null);
          user=await parseLogin();
          return user;
        } else {
          throw err;
        };
      };
    }
    if(user!=null && user.get("sessionToken")!=null)
      saveSessionToken(user.get("username"),user.get("sessionToken"));
    return user;
  } finally {
    if(rl!=null) {
      rl.close();
      rl=null;
    };
  };
  return user;
};
async function wait(delay) {
  return new Promise((resolve,reject)=>{
    setTimeout(()=>{resolve("done")},delay);
  });
};
async function done() {
  const queue=await Parse.EventuallyQueue.length();
  if(queue){
    await Parse.EventuallyQueue.poll(1);
    console.log("Eventually Queue Run");
  } else {
    await Parse.EventuallyQueue.stopPoll();
    console.log("Eventually Queue Stopped");
  };
};
global.done=done;
global.parseLogin=parseLogin;
global.getSessionToken=getSessionToken;
