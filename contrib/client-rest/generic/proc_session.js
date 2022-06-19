const session=require('../session.json');
const fs=require('fs');
fs.writeFileSync('key.json',JSON.stringify({"token":session.sessionToken})+"\n");
fs.writeFileSync('key.sh','PARSE_SESSION_KEY="'+session.sessionToken+'"'+"\n"); 
