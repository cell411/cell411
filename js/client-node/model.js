  global.Request = Parse.Object.extend("Request");
  Parse.Object.registerSubclass('Request', Request);

  global.User = Parse.Object.extend("_User", {
    getName() { return this.get("firstName")+" "+this.get("lastName"); }
  });
  Parse.Object.registerSubclass('_User',User);

  global.Request = Parse.Object.extend("Request");
  Parse.Object.registerSubclass('Request',Request);

  global.Response = Parse.Object.extend("Response");
  Parse.Object.registerSubclass('Response',Response);

  global.Alert = Parse.Object.extend("Alert");
  Parse.Object.registerSubclass('Alert',Alert);

  global.PublicCell = Parse.Object.extend("PublicCell");
  Parse.Object.registerSubclass('PublicCell',PublicCell);

  global.PrivateCell = Parse.Object.extend("PrivateCell");
  Parse.Object.registerSubclass('PrivateCell',PrivateCell);

  global.Role = Parse.Object.extend("_Role");
  Parse.Object.registerSubclass('_Role',Role);

  global.ChatMsg = Parse.Object.extend("ChatMsg");
  Parse.Object.registerSubclass("ChatMsg",ChatMsg);

  global.ChatRoom = Parse.Object.extend("ChatRoom");
  Parse.Object.registerSubclass("ChatRoom",ChatRoom);
