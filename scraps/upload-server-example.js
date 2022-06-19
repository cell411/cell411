#!node

var tmp;
import { default as express } from 'express';
tmp=await import("express-fileupload");
const fuckme=tmp.default;
const fs = await import('fs');
tmp=await import('util');
const util=tmp.default;
let sampleFile;
let uploadPath;
const app = express();
console.log(fuckme);
app.use(
  fuckme(
    {
      debug:true,
      useTempFiles:true,
      useSafeNames:true,
      createParentPath:true
    }
  )
);
app.get('/', function (req, res) {
  res.send('Hello World')
})
app.post('/upload', function(req, res) {
  if (!req.files || Object.keys(req.files).length === 0) {
    res.status(400).send('No files were uploaded.');
    return;
  }

  console.log('req.files >>>', req.files); // eslint-disable-line

  sampleFile = req.files.sampleFile;
  console.log(sampleFile);
  uploadPath = process.env.PWD + '/uploads/' + sampleFile.name;

  sampleFile.mv(uploadPath, function(err) {
    if (err) {
      return res.status(500).send(err);
    }

    res.send('File uploaded to ' + uploadPath);
  });
});
app.listen(3000)
//   import {ParseServer} from 'parse-server';
//   import 'global';
//   
//   const Cell411={};
//   Cell411.config={};
//   const dir=process.env.HOME+"/.parse/";
//   const flavor=process.env.PARSE_FLAVOR || "parse";
//   const file=dir+"config-"+flavor+".json";
//   const config=JSON.parse(fs.readFileSync(file).toString());
//   const app = ParseServer.start(config);
//   const express=await import('express');
//   console.log(express);
