const gcm = require('@parse/node-gcm');
const initOptions = { };
const pgp = require('pg-promise')(initOptions);
const https = require('https');

async function main() {
  console.log("main() starting");

  console.dump=function(obj) { this.log(JSON.stringify(obj,null,2)); };
  const pg_config = {
    host: 'localhost', // 'localhost' is the default;
    port: 5432, // 5432 is the default;
    database: 'empty',
    user: 'parse',
    password: 'fuck',

    // to auto-exit on idle, without having to shut-down the pool;
    // see https://github.com/vitaly-t/pg-promise#library-de-initialization
    allowExitOnIdle: true
  };
  const db = pgp(pg_config);
  const regTokens = await db.any('select "deviceToken" from "_Installation" where "deviceToken" is not null');
  for(var i=0;i<regTokens.length;i++) {
    regTokens[i]=regTokens[i].deviceToken;
  };
  const message = await buildMessage();
  const sender = new gcm.Sender(api_key);
  const res = await sender.send(message, regTokens);
};
async function buildMessage() {
  const message = new gcm.Message();
  message.addNotification('title', 'Hello');
  message.addNotification('icon', 'ic_launcher');
  message.addNotification('body', 'World');
  console.log("message complete");
  return message;
};
async function checkTokens(regTokens) {
  for(var i=0;i<regTokens.length;i++) {
    const object=regTokens[i];
    const token=object.deviceToken;
    const options = {
      hostname: "iid.googleapis.com",
      port: 443,
      path: '/iid/info/'+token,
      method: 'GET',
      headers: {
        Authorization: "key="+api_key
      }
    };

    https.get(options, (res)=>{
      console.log({
        statusCode: res.statusCode,
        headers: res.headers,
      });
      res.on('data', (d)=>{
        process.stdout.write(d);
      });
    }).on('error',(e)=>{
      console.error(e);
    });
    function res(){};
      setInterval(res,30000);
  };
};
main();
