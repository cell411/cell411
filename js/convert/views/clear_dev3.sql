--
-- Name: clear_dev3(); Type: PROCEDURE; Schema: public; Owner: parse
--

CREATE or REPLACE PROCEDURE public.clear_dev3()
    LANGUAGE sql
    AS $$
delete from "_Join:friends:_User" where 'dev3' in ("owningId","relatedId");
delete from "_Join:members:PublicCell" where 'dev3' in ("owningId","relatedId");
delete from "_Join:members:PrivateCell" where 'dev3' in ("owningId","relatedId");
delete from "PrivateCell" where "owner" = 'dev3';
delete from "PublicCell" where "owner" = 'dev3';
delete from "Request" where 'dev3' in ("owner","sentTo");
delete from "Alert" where 'dev3' in ("owner");
delete from "Response" where 'dev3' = "owner";
$$;


ALTER PROCEDURE public.clear_dev3() OWNER TO parse;

