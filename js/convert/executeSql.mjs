const fs = await import('fs');
import { execSync } from 'child_process';
import 'parse-global';
await loadParseConfig();

async function runView(file,param){
  execSync(`psql ${param} ${parseConfig.flavor} < views/${file}`, {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
};
async function runSql(file,param){
  execSync(`psql ${param} ${parseConfig.flavor} < sql/${file}`, {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
};

export async function executeSql() {
  console.log("install copied data");
  const tmpSqlFiles = fs.readdirSync("sql");
  const sqlFiles=[];
  for(var i=0;i<tmpSqlFiles.length;i++){
    const file=tmpSqlFiles[i];
    if(!file.endsWith(".sql"))
      continue;
    if(file.endsWith("Constraints.sql"))
      continue;
    sqlFiles.push(file);
  };
  // we want tables, then joins
  sqlFiles.sort(function(a,b){
    if(a.startsWith("_Join:")!=b.startsWith("_Join:"))
      return a.startsWith("_Join:")?1:-1;
    else if(a<b)
      return -1;
    else if(b<a)
      return 1;
    else return 0;
  });


  if(parseConfig.flavor!=="empty"){
    for(var i=0;i<sqlFiles.length;i++) {
      const file=sqlFiles[i];
      if(file.endsWith(".sql")) {
        console.log(file);
      };
      runSql(file,"");
    }
  };
  runSql("cleanConstraints.sql","-e");
  runSql("createConstraints.sql","-e");

  execSync(`perl genview_count.pl ${parseConfig.flavor}`);

  const viewFiles = fs.readdirSync("views");
  for(var i=0;i<viewFiles.length;i++) {
    runView(viewFiles[i],"");
  };
};
await executeSql();
