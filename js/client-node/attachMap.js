require('parse-global');
const googleData = JSON.parse(fs.readFileSync(process.env.HOME+"/.parse/google.api.json"));
const fetch = require('node-fetch');

async function attachMap(req) {
  await import('./parse-login.mjs');
  const current = await parseLogin();
  const objectId = req.params.objectId;
  const query = new Parse.Query("ChatMsg");
  query.equalTo("objectId",objectId);
  const list = await query.find();
  const chatMsg = list[0];
  console.dump(chatMsg);
  return {success: true};
  const location=chatMsg.get("location");
  const url=googleData.prefix+location.latitude+","+location.longitude+googleData.suffix;
//     const requestOptions = {
//       method: 'GET',
//     };
//     var res = await fetch(url, requestOptions);
//     if(!res.ok){
//       return { success: false };
//     };
//     const buffer = await res.buffer();
//     const data = { data: buf
  const file = new Parse.File("map.png", {uri: url});
  chatMsg.set("imageFile",file);
  chatMsg.save(null,{useMasterKey: true});
}

const req={};
req.params={};
req.params.objectId='JmnU4aTG4c';
attachMap(req).then((res)=>{console.log(res);});
