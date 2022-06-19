CREATE or REPLACE VIEW public.friend_dist AS
 SELECT foo.id, foo.other,
    foo.name1,
    foo.name2,
    foo.dist
   FROM ( SELECT u1."objectId" as id,
            u2."objectId" as other,
            ((u1."firstName" || ' '::text) || u1."lastName") AS name1,
            ((u2."firstName" || ' '::text) || u2."lastName") AS name2,
            public.dist(u1.location, u2.location) AS dist
           FROM public."_User" u1,
            public."_User" u2
          WHERE ((u1.location IS NOT NULL) AND (u2.location IS NOT NULL)
            AND (u1."objectId" < u2."objectId")
            AND ((u1."objectId", u2."objectId") IN
              ( SELECT "_Join:friends:_User"."owningId",
                    "_Join:friends:_User"."relatedId"
                   FROM public."_Join:friends:_User")
          )
      )
    ) foo
  ORDER BY foo.dist;
