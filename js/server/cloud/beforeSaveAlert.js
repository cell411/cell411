//   async function beforeSaveAlert(req) {
//     console.log("beforeSaveAlert");
//     const alert = req.object;
//     console.dump(alert);
//     if(alert.get("owner")==null)
//       alert.set("owner",user);
//     console.log("beforeSaveAlert done");
//   };
//   Parse.Cloud.beforeSave("Alert",beforeSaveAlert);
