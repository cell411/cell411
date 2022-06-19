CREATE or replace VIEW public.array_friends AS
 SELECT "_Join:friends:_User"."owningId",
    array_agg("_Join:friends:_User"."relatedId") AS "relatedIds"
   FROM public."_Join:friends:_User"
  GROUP BY "_Join:friends:_User"."owningId";


ALTER TABLE public.array_friends OWNER TO parse;

