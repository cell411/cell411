#!node
import 'parse-global';
await loadParseConfig();
import { execSync } from 'child_process';
import fs from 'fs';
import './util.mjs';
function q(x) {
  return "\""+x+"\"";
};
async function createConstraints() {
  const constraints=readJson('newSchema/constraints.json');
  var createSql = "";
  var cleanSql="";
  var deleteSql = "";
  var rejectSql = "";

  rejectSql=rejectSql+`
    create table "rej__User" as (
      select * from "_User"
      where null is not null
    );
  `;

  cleanSql=cleanSql+`

    insert into "rej__User" (
        select * from "_User"
        where "objectId" not in (
          select min("objectId")
            from "_User"
           group by "mobileNumber"
         )
         and "mobileNumber" is not null
    );
   

      `;


  createSql=createSql+`


    create unique index "_User_mobileNumber_unique" on "_User" ( "mobileNumber" );


      `;
  const rejectCreated={ _User: 1 };

  for(var i=0;i<constraints.length;i++){
    var constraint = constraints[i];
    if(constraint.type == "Relation") {
      const fkey_owning = q("fkey_owning");
      const fkey_related = q("fkey_related");
      const deleteAction = q(constraint.deleteAction);
      const joinTable = q(constraint.joinTable);
      const owningTable= q(constraint.owningTable);
      const relatedTable= q(constraint.relatedTable);
      const joinTable_unique=q(constraint.joinTable+"_uniq");
      const rejectTable=q("rej_"+constraint.joinTable);

      rejectSql=rejectSql+`

        create table ${rejectTable} as (select distinct * from ${joinTable} );

        delete from ${joinTable};
              
        insert into ${joinTable} ( select * from ${rejectTable} );
      
        delete from ${rejectTable};

      `;


      cleanSql=cleanSql+`

        insert into ${rejectTable} (
          select * from ${joinTable} where "owningId" is null or "owningId" not in (select "objectId" from ${owningTable} )
        );

        insert into ${rejectTable} (
          select * from ${joinTable} where "relatedId" is null or "relatedId" not in (select "objectId" from ${relatedTable} )
        );

    `;

    deleteSql=deleteSql+`

      delete from ${joinTable} where ("owningId","relatedId") in (select "owningId", "relatedId" from ${rejectTable});

    `;

    createSql=createSql+`
           
           alter table ${joinTable}
        add constraint ${fkey_owning}
           foreign key ( "owningId" )
            references ${owningTable} ( "objectId" )
               on delete cascade ;

           alter table ${joinTable}
        add constraint ${fkey_related}
           foreign key ( "relatedId" )
            references ${relatedTable} ( "objectId" )
               on delete cascade ;

        create unique index ${joinTable_unique}
          on ${joinTable}
           ( "owningId", "relatedId" );
        
        `;
    } else if(constraint.type=="Pointer") {
      const fkey = q(constraint.owningTable+"_"+constraint.owningField);
      const deleteAction = constraint.deleteAction;
      const joinTable = q(constraint.joinTable);
      const owningTable= q(constraint.owningTable);
      const owningField=q(constraint.owningField);
      const relatedTable= q(constraint.relatedTable);
      const relatedField=q(constraint.relatedField);
      const rejectTable=q("rej_"+constraint.owningTable);

      if(!rejectCreated[constraint.owningTable]) {
        rejectSql=rejectSql+`
        create table ${rejectTable} as
        ( select * from ${owningTable} where null is not null )
        ;
        `;
        rejectCreated[constraint.owningTable]=1;
      };

      cleanSql=cleanSql+`

      insert into ${rejectTable}
         (
            select * from ${owningTable}
            where ${owningField} not in ( select "objectId" from ${relatedTable} )
              and ${owningField} is not null
         );

      `;

      deleteSql=deleteSql+`

      delete from ${owningTable} where "objectId" in (select "objectId" from ${rejectTable} );

      `;
      createSql=createSql+` 

           
           alter table ${owningTable}
        add constraint ${fkey}
           foreign key ( ${owningField} )
            references ${relatedTable} ( ${relatedField} )
               ${deleteAction};
         
      `;
    } else {
      throw new Error(`Unexpected constraint type: ${constraint.type}`);
    };
  };

  cleanSql=cleanSql+`
    
    insert into "rej_Request" (
      select * from "Request"
        where "objectId" not in (
          select min("objectId")
            from "Request"
           group by "owner", "sentTo", "cell"
           )
      );

   insert into "rej_Request" 
    ( select * from "Request" where "owner" is null );

   insert into "rej_Request" 
    ( select * from "Request" where "sentTo" is null );


  `;
  createSql=createSql+`

  create unique index "Request_owner_sentTo_cell_unique" on "Request" ( "owner", "sentTo", "cell" );

  alter table "Request" alter column "owner" set not null;

  alter table "Request" alter column "sentTo" set not null;

  `;

  cleanSql=rejectSql+cleanSql+deleteSql;


  execSync("mkdir -p sql");
  fs.writeFileSync("sql/cleanConstraints.sql",cleanSql);
  fs.writeFileSync('sql/createConstraints.sql',createSql);
};
createConstraints();
