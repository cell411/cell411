async function beforeSaveRequest(req) {
  const user = req.user;
  console.log("beforeSaveRequest");
  const request = req.object;
  console.dump(request);
  if(request.get("owner")==null)
    request.set("owner",user);
  if(request.get("status")==null)
    request.set("status","PENDING");
  console.log("beforeSaveRequest done");
};
Parse.Cloud.beforeSave("Request",beforeSaveRequest);
