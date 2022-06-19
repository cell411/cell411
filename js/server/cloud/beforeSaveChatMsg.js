const model=require('./lib/parse.js');
const googleData = JSON.parse(fs.readFileSync(process.env.HOME+"/.parse/google.api.json"));

async function beforeSaveChatMsg(req) {
  const chatMsg = req.object;
  const location=chatMsg.get("location");
  if(location!=null) {
    if(chatMsg.get("text")==null || chatMsg.get("text")=="") {
      const gcReq = { params: { location } };
      const res = await reverseGeocode(gcReq);
      console.log({res});
      chatMsg.set("text",res.address);
    }
    if(chatMsg.get("image")==null){
      const url=googleData.prefix+location.latitude+","+location.longitude+googleData.suffix;
      const file = new Parse.File("location.png", {uri: url});
      await file.save({useMasterKey: true});
      chatMsg.set("image",file);
    };
  };
};
Parse.Cloud.beforeSave("ChatMsg",beforeSaveChatMsg);
