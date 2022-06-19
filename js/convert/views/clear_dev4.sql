--
-- Name: clear_dev4(); Type: PROCEDURE; Schema: public; Owner: parse
--

CREATE or REPLACE PROCEDURE public.clear_dev4()
    LANGUAGE sql
    AS $$
delete from "_Join:friends:_User" where 'dev4' in ("owningId","relatedId");
delete from "_Join:members:PublicCell" where 'dev4' in ("owningId","relatedId");
delete from "_Join:members:PrivateCell" where 'dev4' in ("owningId","relatedId");
delete from "PrivateCell" where "owner" = 'dev4';
delete from "PublicCell" where "owner" = 'dev4';
delete from "Request" where 'dev4' in ("owner","sentTo");
delete from "Alert" where 'dev4' in ("owner");
delete from "Response" where 'dev4' = "owner";
$$;


ALTER PROCEDURE public.clear_dev4() OWNER TO parse;

