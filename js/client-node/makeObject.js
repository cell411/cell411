#!node

const parse_global=require('parse-global');
const util=require('util');
initializeParse();

async function makeChatRoom() {
  const userQuery = new Parse.Query(Parse.User);
  userQuery.limit(1);
  const users = userQuery.find();
  const ChatMsg = Parse.Object.extend("ChatMsg");
  const chatMsg = new ChatMsg();
  const ChatRoom = Parse.Object.extend("ChatRoom");
  const chatRoom = new ChatRoom();
  chatMsg.set("chatRoom",chatRoom);
  chatMsg.set("location",new Parse.GeoPoint(72.0,42.0));
  //  chatMsg.set("image", parseFile);
  chatMsg.set("text", "");
  chatMsg.save(null,{useMasterKey: true});
  console.log("main: exit");
  // objectId | createdAt | updatedAt | chatRoom | owner | text | image | location
};
async function makeFriends() {
  const userQuery = new Parse.Query(Parse.User);
  var skip=(30000*Math.random());
  console.log(skip);
  skip=Math.round(skip);
  console.log(skip);
  userQuery.skip(skip);
  userQuery.limit(10);
  const users=await userQuery.find();
  const user1=users[0];
  const user2=users[1];
  user1.relation("friends").add(user2);
  user2.relation("friends").add(user1);
  user1.save(null,{useMasterKey:true});
  user2.save(null,{useMasterKey:true});

};
async function makeUser() {
  const user = new Parse.User();
  user.set('firstName',"franken");
  user.set("lastName","stein");
  user.set("username","fs2@trans.vein");
  user.set("password","dadsucks");
  user.save(null,{useMasterKen: true});

  async function main(argv) {
    await makeChatRoom();
    await makeUser();
    await makeFriends();

  }
}
main(process.argv);
