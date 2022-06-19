CREATE VIEW public.friend_check AS
 SELECT foo.c1,
    foo.c2,
    count(*) AS count
   FROM ( SELECT "_Join:friends:_User"."owningId" AS c1,
            "_Join:friends:_User"."relatedId" AS c2
           FROM public."_Join:friends:_User"
        UNION ALL
         SELECT "_Join:friends:_User"."relatedId",
            "_Join:friends:_User"."owningId"
           FROM public."_Join:friends:_User") foo
  GROUP BY foo.c1, foo.c2
  ORDER BY foo.c1, foo.c2;

