create or replace view numsrc as 
select (select count(*) from counts c2 where c2.tab>c1.tab) as num from counts c1 order by num;
