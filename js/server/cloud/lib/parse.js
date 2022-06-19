#!node
async function module() {

  //console.log(DateTime);
  global.strdate=function(){ return new luxon.DateTime({}).toString(); };


  global.Request = Parse.Object.extend("Request");
  global.User = Parse.Object.extend("_User", {
    getName(){ return this.get("firstName")+" "+this.get("lastName"); }
  });
  async function getName() {
    return this.get("firstName")+" "+this.get("lastName");
  };
  async function getSpamUsers() {
    if(!this.spamUsers){
      const query=this.relation('spamUsers').query;
      this.spamUsers=await query.find();
    };
    return this.spamUsers;
  };
  async function getSpamUsers() {
    if(!this.userSpams){
      const query=this.relation('userSpams').query;
      this.userSpams=await query.find();
    };
    return this.userSpams;
  };


  global.getIds = function getIds(array){
    const res=[];
    for(var i=0;i<array.length;i++) {
      res.push(array[i].id);
    };
    return res;
  };

  //   function cloudDefine(name,func) {
  //     Parse.Cloud.define(name, function(req) {
  //       const start = moment();
  //       const filename = "./logs/"+start.format('YYYY-MM-DD-HH-mm-ss-')+name+".log";
  //       const report = fs.createWriteStream(filename);
  //       console.log({filename: filename, report: report});
  //       report.write(JSON.stringify({filename: filename, report: report},null,2));
  //       const tcons = new Console({
  //         stdout: report,
  //         stderr: report,
  //         inspectOptions: {
  //           showProxy: true,
  //           compact: false,
  //           sorted: true,
  //         }
  //       });
  //       const save=console;
  //       try {
  //         var res = func(req);
  //         console.log(`${name}(${req}) returned ${res}`);
  //         return res;
  //       } catch ( error ) {
  //         console.error(error);
  //         return error;
  //       } finally {
  //         console.save;
  //         report.end();
  //       };
  //       console.log("And you may ask yourself:  how did I get here?");
  //     });
  //   };
  //   global.cloudDefine=cloudDefine;
  //   if(!Parse.Cloud.hasOwnProperty("define")){
  //     console.log("Parse.Cloud.define exists ... not");
  //     Parse.Cloud.funcs={};
  //     Parse.Cloud.run=function run(name, params,options) {
  //       if(!Parse.Cloud.funcs.hasOwnProperty(name))
  //         throw new Error("invalid function: '"+name+"'");
  //       const req={};
  //       req.user=Parse.User.current();
  //       req.params=params;
  //       console.log(`calling ${name} with ${JSON.stringify(params)}`);
  //       const res = Parse.Cloud.funcs[name](req,params,options);
  //       res.then((res)=>{
  //         console.log(` ... ${name} returned ${JSON.stringify(res)}`);
  //       });
  //       return res;
  //     };
  //     Parse.Cloud.define=function define(name,func){
  //       Parse.Cloud.funcs[name]=func;
  //     };
  //     Parse.Cloud.beforeSave=function beforeSave(name,func){
  //     };
  //   } else {
  //     console.log("Parse.Cloud.define exists");
  //   };
  global.findFully = async function findFully(query){
    const res= [];
    const max=500;
    console.log(query._limit);
    var batch;
    query.limit(max);
    do {
      query.skip(res.length);
      console.dump(query);
      batch = await query.find();
      for(var i=0;i<batch.length;i++)
        res.push(batch[i]);
    } while(batch.length==max);
    return res;
  };
};
import("parse-global").then(module);
