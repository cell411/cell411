--
-- Name: user_rels; Type: VIEW; Schema: public; Owner: parse
--

CREATE or replace VIEW public.user_rels AS
 SELECT foo.id,
    foo.other,
    foo.type,
    foo.role,
    foo.aux_id,
    foo.aux_data
   FROM ( SELECT "_Join:friends:_User"."owningId" AS id,
            "_Join:friends:_User"."relatedId" AS other,
            '_User'::text AS type,
            'friending'::text AS role,
            null as aux_id,
            null as aux_data
           FROM public."_Join:friends:_User"
        UNION
         SELECT "_Join:friends:_User"."relatedId" AS id,
            "_Join:friends:_User"."owningId" AS other,
            '_User'::text AS type,
            'friended'::text AS role
           ,null as aux_id
         ,null as aux_data 
           FROM public."_Join:friends:_User"
        UNION
         SELECT "_Join:spamUsers:_User"."owningId" AS id,
            "_Join:spamUsers:_User"."relatedId" AS other,
            '_User'::text AS type,
            'blocking'::text AS role
           ,null as aux_id
         ,null as aux_data 
           FROM public."_Join:spamUsers:_User"
        UNION
         SELECT "_Join:spamUsers:_User"."relatedId" AS id,
            "_Join:spamUsers:_User"."owningId" AS other,
            '_User'::text AS type,
            'blocked'::text AS role
           ,null as aux_id
         ,null as aux_data 
           FROM public."_Join:spamUsers:_User"
        UNION
         SELECT "_Join:members:PublicCell"."relatedId" AS id,
            "_Join:members:PublicCell"."owningId" AS other,
            'PublicCell'::text AS type,
            'member'::text AS role
           ,null as aux_id
         ,null as aux_data 
           FROM public."_Join:members:PublicCell"
        UNION
         SELECT "_Join:members:PrivateCell"."relatedId" AS id,
            "_Join:members:PrivateCell"."owningId" AS other,
            'PrivateCell'::text AS type,
            'member'::text AS role
           ,null as aux_id
         ,null as aux_data 
           FROM public."_Join:members:PrivateCell"
        UNION
         SELECT "PublicCell".owner AS id,
            "PublicCell"."objectId" AS other,
            'PublicCell'::text AS type,
            'owner'::text AS role
           ,null as aux_id
         ,null as aux_data 
           FROM public."PublicCell"
        UNION
         SELECT "PrivateCell".owner AS id,
            "PrivateCell"."objectId" AS other,
            'PrivateCell'::text AS type,
            'owner'::text AS role
           ,null as aux_id
         ,null as aux_data 
           FROM public."PrivateCell"
        UNION
         SELECT "Alert".owner AS id,
            "Alert"."objectId" AS other,
            'Alert'::text AS type,
            'owner'::text AS role
           ,null as aux_id
         ,null as aux_data 
           FROM public."Alert"
        UNION
         SELECT "Request"."sentTo" AS id,
            "Request"."owner" AS other,
            'Request'::text AS type,
            'receiver'::text AS role,
            "Request"."objectId" as aux_id,
            "Request"."status" as aux_data
           FROM public."Request"
        UNION
         SELECT "Request".owner AS id,
            "Request"."sentTo" AS other,
            'Request'::text AS type,
            'sender'::text AS role,
            "Request"."objectId" as aux_id,
            "Request"."status" as aux_data
           FROM public."Request"
        UNION
         SELECT "Response".owner AS id,
            "Alert"."objectId" AS other,
            'Alert'::text AS type,
            'receiver'::text AS role
           ,null as aux_id
         ,null as aux_data 
           FROM public."Response",
            public."Alert"
          WHERE ("Response".alert = "Alert"."objectId")) foo
  ORDER BY foo.id;


ALTER TABLE public.user_rels OWNER TO parse;
