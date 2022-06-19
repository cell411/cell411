const createAlert=require('./lib/createAlert.js');
const createAudience=require('./lib/createAudience.js');

async function sendAlert(req) {
  const user = req.user;
  if(user==null)
    throw new Error("caller is not logged in");
  if(typeof(req.params.alert)==="undefined")
    throw new Error("no alert in params");
  var alertdata = req.params.alert;
  if(typeof(alertdata)==='string')
    alertdata=JSON.parse(req.params.alert);
  if(typeof(alertdata)=="undefined")
    throw new Error("no alertdata");
  if(alertdata.location==null || typeof(alertdata.location)==='undefined')
    throw new Error("no location in alert");
 
  const audience = await createAudience(user,alertdata,req.params.audience);

  const alert = await createAlert(user, alertdata);
  if(!alert)
    throw new Error("Sorry, no alert");
  await alert.save(null,{useMasterKey: true});

  const resps = [];
  for(var i=0;i<audience.length;i++) {
    const user=audience[i];
    const resp = new Response();
    resp.set("owner", user);
    resp.set("alert", alert);
    await resp.save();
  };
  return {
    success: true,
    count: audience.length,
    alert: alert.id
  };
};
Parse.Cloud.define("sendAlert", sendAlert);
