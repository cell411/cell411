create or replace view res_count
as
select * from 
(
  select u."objectId",
  (select count(*) from "Request" r1 where r1.owner=u."objectId") all_sent,
  (select count(*) from "Request" r1 where r1."sentTo"=u."objectId") all_recd,
  (select count(*) from "Request" r1 where r1.owner=u."objectId" and status='PENDING') pend_sent,
  (select count(*) from "Request" r1 where r1."sentTo"=u."objectId" and status='PENDING') pend_recd
  from "_User" u
) foo
where (all_sent+all_recd)>0
  order by (all_sent+all_recd) desc


  ;
