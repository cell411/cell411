import { createWriteStream } from 'fs';

export function quoteName(column) {
  if(column == null) {
    console.trace("null column");
    throw new Error("Null Table or Column Name");
  }
  return '"'+column+'"';
}
export function quoteData(value,type) {
  var result;
  if(value==null) {
    result="null";
  } else if(type==="String" || type==="Pointer" || type==="File") {
    if(value.includes("'")){
      value=value.split("'").join("''");   
    };
    result="'"+value+"'";
  } else if ( type==="Date" ) {
    if(typeof value == 'string')
      value=new Date(Date.parse(value));
    result="to_timestamp("+(value.getTime()/1000)+")";
  } else if ( type==="Boolean" ) {
    result=value;
  } else if ( type==="Number" ) {
    result=value;
  } else if ( type==="GeoPoint" ) {
    result="Point("+value[0]+","+value[1]+")";
  } else {
    result=type+"("+value+")";
  };
  return result;
}
export async function toSql(converter) {
  if(converter==null)
    throw new Error("converter cannot be null");
  const array = converter.newObjects;
  if(array==null) {
    console.log(converter);
    throw new Error("newObjects cannot be null");
  };
  const fields = converter.fields;
  if(fields==null)
    throw new Error("fields cannot be null");
  const newNames = Object.keys(converter.fields);
  if(newNames==null)
    throw new Error("newNames cannot be null");
  const tableName = converter.newClassName;
  if(tableName==null)
    throw new Error("tableName cannot be null");
  console.log(`converting ${array.length} items to sql`);
  var sql = "";
  sql+="delete from "+quoteName(tableName)+";\n";
  if(array.length==0) {
    return "";
  };
  sql+="insert into "+quoteName(tableName)+" (\n";
  for(var j=0;j<newNames.length;j++) {
    if(j>0)
      sql+=",\n";
    sql+="  "+quoteName(newNames[j]);
  };
  sql+="\n)\nvalues\n";
  for(var i=0;i<array.length;i++){
    if(i>0)
      sql+=",\n";
    const object = array[i];
    if(object==null)
      throw new Error("Null object in toSql");
    sql+="(\n";
    for(var j=0;j<newNames.length;j++) {
      if(j>0) {
        sql+=",\n";
      };
      const name=newNames[j];
  // in case you have to grep the sql
//sql+=" /* "+name+" */ ";
      const field=fields[name];
      var value=object[name];
      const type=field.type;
      if(value==null)
        value=field.default;
      sql+="  "+quoteData(value,type);
    };
    sql+="\n)\n";
  };
  sql+="\n";
  console.log(`done writing ${array.length} items to sql.  length: ${sql.length}`);
  return sql;
}
