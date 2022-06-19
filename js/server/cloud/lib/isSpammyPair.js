// Given two users, check if either has blocked the other.
async function isSpammyPair(objectId1,objectId2)
{
  var spamQuery=new Parse.Query(Parse.User);
  if(typeof(objectId1)=='object')
    objectId1=objectId1.id;
  if(typeof(objectId2)=='object')
    objectId1=objectId2.id;
  spamQuery.equalTo("objectId",objectId1);
  spamQuery.equalTo("spamUsers",objectId2);
  var count=await spamQuery.count();
  if(count !=0)
    return true;
  spamQuery=new Parse.Query(Parse.User);
  spamQuery.equalTo("objectId",objectId2);
  spamQuery.equalTo("spamUsers",objectId1);
  count=await spamQuery.count();
  if(await count!=0)
    return true;
  return false;
}
module.exports = isSpammyPair;
