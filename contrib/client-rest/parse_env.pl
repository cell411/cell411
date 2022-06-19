fs=require('fs');

var i_file=process.env.PARSE_CONFIG;
console.log(i_file)
var b_file=i_file.substr(0,i_file.length-5);
console.log(b_file);
var o_file=b_file+".sh";
console.log(o_file);

var config=require(process.env.PARSE_CONFIG);

list= [
    [ "PARSE_APPID", "appId" ],
    ["PARSE_REST", "restKey" ],
    ["PARSE_PUB_URL", "publicServerURL" ],
  ];

var out="\n";
for(var i=0;i<list.length;i++) {
  var row=list[i];
  out=out+row[0]+"="+config[row[1]]+"\n";
};
out=out+"\n";

fs.writeFileSync(o_file, out);
