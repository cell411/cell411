CREATE or replace PROCEDURE public.balance_friends()
    LANGUAGE sql
    AS $$
insert into "_Join:friends:_User" ("relatedId", "owningId" )
(
  select "owningId", "relatedId" from "_Join:friends:_User" 
  except
  select "relatedId", "owningId" from "_Join:friends:_User"
 );
$$;

ALTER PROCEDURE public.balance_friends() OWNER TO parse;
