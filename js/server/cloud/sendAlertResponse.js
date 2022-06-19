require('./lib/parse.js');

function sendAlertResponse(req) {
  try {
    return doAnnounceHelp(req);
  } catch ( error ) {
    console.log(JSON.stringify(error,null,2));
  };
};
async function doAnnounceHelp(req) {
  const user = req.user;
  if(user==null || user.getSessionToken()==null)
    throw new Error("caller is not logged in");
  if(typeof(req.params.noteId)==="undefined")
    throw new Error("no noteId in params");

  const noteId = req.params.noteId;
  const noteQuery = new Parse.Query("AdditionalNote");
  noteQuery.include("alert");
  noteQuery.include("alert.owner");
  const note=await noteQuery.get(noteId);
  console.dump(note);  
  const alert = note.get("alert");
  console.dump(alert);
  const issuedBy = alert.get("owner");
  console.dump(issuedBy);
  const users = [ user.id, issuedBy.id ];
  const data = {
    "object": {
      "__type": "Pointer",
      "className": "AdditionalNote",
      "object": note
    },
  };

  const res = {};
  res.pushres = await sendPush(
    user,
    "Emergency Response",
    user.getName()+" is coming to try to help",
    users,
    data
  );
  return res;
};
Parse.Cloud.define("sendAlertResponse", sendAlertResponse);
