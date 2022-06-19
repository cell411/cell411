
async function viewNames(db) {
  const res = await db.many('select * from pg_views');
  for(var i=0;i<res.length;i++){
    if(res[i].viewname=='columns'){
      console.log(res[i]);
    };
    res[i]=res[i].viewname;
  };
  return res;
};
async function tableNames(db) {
  const res = await db.many('select * from pg_tables');
  for(var i=0;i<res.length;i++){
    res[i]=res[i].tablename;
  };
  return res;
};
