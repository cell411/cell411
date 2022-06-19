const util = await import('util');
const net = await import("net");
import 'parse-global';
await loadParseConfig();
const initOptions = {
};
const pgp_cred=await readJson(configDir+'/pg_admin.json');
const pgp = (await import('pg-promise')).default(initOptions);
const db = pgp(pgp_cred);
function pgp_done(){pgp.end();}
// Helper for linking to external query files:
function sql(file) {
  const fullPath = process.env.PWD+"/"+file; // generating full path;
  return new pgp.QueryFile(fullPath, {minify: false});
}
const cols = sql("sql/cols.sql");

async function dbdump(){
  var columns = await db.many(cols).then((x)=>{return x;});
  for(var column of columns){
    console.log(column);
  };
  columns = await db.many("select * from information_schema.columns");
  console.log(columns[0]);
};

await dbdump().then(pgp_done);
