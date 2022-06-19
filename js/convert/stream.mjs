import 'parse-global';
await loadParseConfig();
import { execSync } from 'child_process';
import { converters } from './converters.mjs';
import fs from 'fs';
import './util.mjs';
import pgpFn from "pg-promise";
import QueryStream from "pg-query-stream";
import JSONStream from "JSONStream";

const pgOptions = {
//     query(e){
//       console.dump(e);
//     }
};
const pgp = pgpFn(pgOptions);

const pg_cred = readJson("/home/parse/.parse/pg_admin.json");
pg_cred.database="parse";
const db = pgp(pg_cred);

// you can also use pgp.as.format(query, values, options)
// to format queries properly, via pg-promise;

//   console.log(db.any('select * from "_User"');
//   process.exit(0);
const qs = new QueryStream('SELECT * FROM "_UserRaw"');
const fileStream = fs.createWriteStream("file.json");

db.stream(qs, stream => 
  {
        // initiate streaming into the console:
        stream.pipe(JSONStream.stringify()).pipe(fileStream);
    })
    .then(data => {
        console.log('Total rows processed:', data.processed,
          'Duration in milliseconds:', data.duration);
    })
    .catch(error => {
        // error;
    });


