const util = require('util');
function inc(map,id){
  if(map[id]){
    map[id]++;
  } else {
    map[id]=1;
  };
};
async function getFriendQuery(user){
  return user.relation("friends").query();
};
async function getPublicCellMemberQuery(user) {
  var qs=[];
  var cellQuery = new Parse.Query("PublicCell");
  cellQuery.equalTo("members",user);
  qs.push(cellQuery);
  cellQuery = new Parse.Query("PublicCell");
  cellQuery.equalTo("owner",user);
  qs.push(cellQuery);
  cellQuery=Parse.Query.or.apply(null,qs);
  qs=[];
  const cells = await cellQuery.find();
  for(var k=0;k<cells.length;k++){
    const cell=cells[k];
    const relation=cell.relation("members");
    const query=relation.query();
    qs.push(query);
  };
  if(qs.length==0){
    return new Parse.Query(Parse.User).equalTo("objectId","");
  } else if ( qs.length==1 ) {
    return qs[0];
  } else {
    return Parse.Query.or.apply(null,qs);
  };
};
async function createAudience(user,alert,audience) {
  const users={};
  const oids=[];
  for(var i=0;i<audience.length;i++){
    const key = audience[i];
    if(key=='global'){
      console.log("global");
      const query = new Parse.Query("_User");
      query.equalTo("patrolMode",true);
      query.withinMiles("location",alert.location, 50, true);
      console.dump({query});
      const batch=await findFully(query);
      console.log(`got ${batch.length} patrollers`);
      for(var j=0;j<batch.length;j++){
        const patrol=batch[j];
        users[patrol.id]=patrol;
      };
      console.dump({users});
    } else if ( key == "allFriends" ) {
      console.log("allFriends");
      const query = await getFriendQuery(user);
      console.trace({query});
      const batch=await findFully(query);
      console.log(`got ${batch.length} friends`);
      for(var j=0;j<batch.length;j++){
        users[batch[j].id]=batch[j];
      };
    } else if ( key == "allCells" ) {
      console.log("allCells");
      const query = await getPublicCellMemberQuery(user);
      const batch=await findFully(query);
      console.log(`got ${batch.length} members`);
      for(var j=0;j<batch.length;j++){
        const member=batch[j];
        users[member.id]=member;
      };
    } else {
      oids.push(key);
    };
    console.log({oids});
    oids.splice();
  }
  {
    const pub = new Parse.Query(PrivateCell);
    pub.containedIn("objectId",oids);
    const cells = await findFully(pub);
    for(var i=0;i<cells.length;i++){
      const cell=cells[i];
      const rmembers=cell.relation("members");
      const qmembers=rmembers.query();
      const cmembers=await qmembers.find();
      for(var j=0;j<cmembers.length;j++){
        users[cmembers[j].id]=cmembers[j];
      };
    };
  };
  {
    const pub = new Parse.Query(PublicCell);
    pub.containedIn("objectId",oids);
    const cells = await findFully(pub);
    for(var i=0;i<cells.length;i++){
      const cell=cells[i];
      const rmembers=cell.relation("members");
      const qmembers=rmembers.query();
      const cmembers=await qmembers.find();
      for(var j=0;j<cmembers.length;j++){
        users[cmembers[j].id]=cmembers[j];
      };
    };
  };

  return Object.values(users);
}
//     try {
//       const queries=[
//       ];
//       {
//         const query = new Parse.Query("PrivateCell");
//         const privateCells = audience.privateCells;
//         if(privateCells!=null && privateCells.length>0) {
//           query.containedIn("objectId", audience.privateCells);
//           const cells=await query.find();
//           for(var i=0;i<cells.length;i++) {
//             const userQuery=cells[i].relation("members").query();
//             queries.push(userQuery);
//             const uQuery=new Parse.Query(Parse.User).equalTo("objectId", cells[i].createdBy);
//             queries.push(uQuery);
//           };
//         };
//       };
//       {
//         const publicCells=audience.publicCells;
//         const query = new Parse.Query("PublicCell");
//         query.containedIn("objectId", audience.publicCells);
//         const cells=await query.find();
//         for(var i=0;i<cells.length;i++) {
//           const userQuery=cells[i].relation("members").query();
//           userQuery.include("objectId");
//           queries.push(userQuery);
//         };
//       }
//       if(audience.allFriends){
//         queries.push(await getFriendQuery(user));
//       } 
//       if(audience.global) {
//         const query = new Parse.Query(Parse.User);
//         query.equalTo("patrolMode",true);
//         query.withinMiles("location",user.get("location"),50 );
//         queries.push(query);
//       }
//       const finalQuery = Parse.Query.or.apply( null, queries );
//       finalQuery.notEqualTo("objectId", user.id);
//       console.dump(finalQuery);
//       return finalQuery;
//     } catch ( err ) {
//         const errdata={
//         err: err,
//         type: typeof(err),
//         inspect: util.inspect(err),
//       };
//       if(err.constructor) {
//         errdata.xconstructor=err.constructor;
//         errdata.name=err.constructor.name;
//       };
//       console.dump(errdata);
//     };
//   };
module.exports=createAudience;
