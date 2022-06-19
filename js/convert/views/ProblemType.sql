drop view "ProblemType";
drop view problemtype;

drop table "ProblemType";
drop table problemtype;

CREATE or replace VIEW "problemtype" AS
 SELECT 'UN_RECOGNIZED'::text AS id
UNION
 SELECT 'BrokenCar'::text AS id
UNION
 SELECT 'Bullied'::text AS id
UNION
 SELECT 'Crime'::text AS id
UNION
 SELECT 'General'::text AS id
UNION
 SELECT 'PulledOver'::text AS id
UNION
 SELECT 'Danger'::text AS id
UNION
 SELECT 'Video'::text AS id
UNION
 SELECT 'Photo'::text AS id
UNION
 SELECT 'Fire'::text AS id
UNION
 SELECT 'Medical'::text AS id
UNION
 SELECT 'CopBlocking'::text AS id
UNION
 SELECT 'Arrested'::text AS id
UNION
 SELECT 'Hijack'::text AS id
UNION
 SELECT 'Panic'::text AS id
UNION
 SELECT 'Trapped'::text AS id
UNION
 SELECT 'CarAccident'::text AS id
UNION
 SELECT 'NaturalDisaster'::text AS id
UNION
 SELECT 'PhysicalAbuse'::text AS id;

create table "ProblemType" as ( select * from problemtype );

alter table "Alert" add constraint "fkey_problemType" foreign key ("problemType") references "ProblemType"(id);

