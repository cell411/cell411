const initOptions = {
};
async function setup() {
  require("parse-global");
  global.pgp=require('pg-promise')(initOptions);
  global.pgm=require('pg-monitor');
  global.pgm.attach(initOptions);
  global.pgs=require('pg-connection-string');
  await loadParseConfig();
  global.cn = pgs.parse(parseConfig.databaseURI);
  global.db = pgp(cn); // database instance;
};
setup();
