--
-- PostgreSQL database dump
--

-- Dumped from database version 12.10 (Ubuntu 12.10-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.10 (Ubuntu 12.10-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: orafce; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS orafce WITH SCHEMA public;


--
-- Name: EXTENSION orafce; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION orafce IS 'Functions and operators that emulate a subset of functions and packages from the Oracle RDBMS';


--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: parse
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO parse;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: parse
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO parse;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: parse
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO parse;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: parse
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: cube; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;


--
-- Name: EXTENSION cube; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';


--
-- Name: earthdistance; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;


--
-- Name: EXTENSION earthdistance; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION earthdistance IS 'calculate great-circle distances on the surface of the Earth';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: jsquery; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS jsquery WITH SCHEMA public;


--
-- Name: EXTENSION jsquery; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION jsquery IS 'data type for jsonb inspection';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: postgis_raster; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;


--
-- Name: EXTENSION postgis_raster; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';


--
-- Name: postgis_sfcgal; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_sfcgal WITH SCHEMA public;


--
-- Name: EXTENSION postgis_sfcgal; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_sfcgal IS 'PostGIS SFCGAL functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: array_add(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.array_add("array" jsonb, "values" jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT array_to_json(ARRAY(SELECT unnest(ARRAY(SELECT DISTINCT jsonb_array_elements("array")) || ARRAY(SELECT jsonb_array_elements("values")))))::jsonb; $$;


ALTER FUNCTION public.array_add("array" jsonb, "values" jsonb) OWNER TO parse;

--
-- Name: array_add_unique(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.array_add_unique("array" jsonb, "values" jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT array_to_json(ARRAY(SELECT DISTINCT unnest(ARRAY(SELECT DISTINCT jsonb_array_elements("array")) || ARRAY(SELECT DISTINCT jsonb_array_elements("values")))))::jsonb; $$;


ALTER FUNCTION public.array_add_unique("array" jsonb, "values" jsonb) OWNER TO parse;

--
-- Name: array_contains(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.array_contains("array" jsonb, "values" jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT RES.CNT >= 1 FROM (SELECT COUNT(*) as CNT FROM jsonb_array_elements("array") as elt WHERE elt IN (SELECT jsonb_array_elements("values"))) as RES; $$;


ALTER FUNCTION public.array_contains("array" jsonb, "values" jsonb) OWNER TO parse;

--
-- Name: array_contains_all(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.array_contains_all("array" jsonb, "values" jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT CASE WHEN 0 = jsonb_array_length("values") THEN true = false ELSE (SELECT RES.CNT = jsonb_array_length("values") FROM (SELECT COUNT(*) as CNT FROM jsonb_array_elements_text("array") as elt WHERE elt IN (SELECT jsonb_array_elements_text("values"))) as RES) END; $$;


ALTER FUNCTION public.array_contains_all("array" jsonb, "values" jsonb) OWNER TO parse;

--
-- Name: array_contains_all_regex(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.array_contains_all_regex("array" jsonb, "values" jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT CASE WHEN 0 = jsonb_array_length("values") THEN true = false ELSE (SELECT RES.CNT = jsonb_array_length("values") FROM (SELECT COUNT(*) as CNT FROM jsonb_array_elements_text("array") as elt WHERE elt LIKE ANY (SELECT jsonb_array_elements_text("values"))) as RES) END; $$;


ALTER FUNCTION public.array_contains_all_regex("array" jsonb, "values" jsonb) OWNER TO parse;

--
-- Name: array_remove(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.array_remove("array" jsonb, "values" jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT array_to_json(ARRAY(SELECT * FROM jsonb_array_elements("array") as elt WHERE elt NOT IN (SELECT * FROM (SELECT jsonb_array_elements("values")) AS sub)))::jsonb; $$;


ALTER FUNCTION public.array_remove("array" jsonb, "values" jsonb) OWNER TO parse;

--
-- Name: dist(point, point); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.dist(pt1 point, pt2 point) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ 
    SELECT ST_DistanceSphere(pt1::geometry,pt2::geometry)
    $$;


ALTER FUNCTION public.dist(pt1 point, pt2 point) OWNER TO parse;

--
-- Name: idempotency_delete_expired_records(); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.idempotency_delete_expired_records() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN DELETE FROM "_Idempotency" WHERE expire < NOW() - INTERVAL '300 seconds'; END; $$;


ALTER FUNCTION public.idempotency_delete_expired_records() OWNER TO parse;

--
-- Name: json_object_set_key(jsonb, text, anyelement); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.json_object_set_key(json jsonb, key_to_set text, value_to_set anyelement) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT concat('{', string_agg(to_json("key") || ':' || "value", ','), '}')::jsonb FROM (SELECT * FROM jsonb_each("json") WHERE key <> key_to_set UNION ALL SELECT key_to_set, to_json("value_to_set")::jsonb) AS fields $$;


ALTER FUNCTION public.json_object_set_key(json jsonb, key_to_set text, value_to_set anyelement) OWNER TO parse;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _Audience; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Audience" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    query text,
    "lastUsed" timestamp with time zone,
    "timesUsed" double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_Audience" OWNER TO parse;

--
-- Name: _GlobalConfig; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_GlobalConfig" (
    "objectId" text NOT NULL,
    params jsonb,
    "masterKeyOnly" jsonb
);


ALTER TABLE public."_GlobalConfig" OWNER TO parse;

--
-- Name: _Hooks; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Hooks" (
    "functionName" text,
    "className" text,
    "triggerName" text,
    url text
);


ALTER TABLE public."_Hooks" OWNER TO parse;

--
-- Name: _Idempotency; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Idempotency" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "reqId" text,
    expire timestamp with time zone,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_Idempotency" OWNER TO parse;

--
-- Name: _JobSchedule; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_JobSchedule" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "jobName" text,
    description text,
    params text,
    "startAfter" text,
    "daysOfWeek" jsonb,
    "timeOfDay" text,
    "lastRun" double precision,
    "repeatMinutes" double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_JobSchedule" OWNER TO parse;

--
-- Name: _JobStatus; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_JobStatus" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "jobName" text,
    source text,
    status text,
    message text,
    params jsonb,
    "finishedAt" timestamp with time zone,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_JobStatus" OWNER TO parse;

--
-- Name: _Join:roles:_Role; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:roles:_Role" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:roles:_Role" OWNER TO parse;

--
-- Name: _Join:users:_Role; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:users:_Role" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:users:_Role" OWNER TO parse;

--
-- Name: _PushStatus; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_PushStatus" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "pushTime" text,
    source text,
    query text,
    payload text,
    title text,
    expiry double precision,
    expiration_interval double precision,
    status text,
    "numSent" double precision,
    "numFailed" double precision,
    "pushHash" text,
    "errorMessage" jsonb,
    "sentPerType" jsonb,
    "failedPerType" jsonb,
    "sentPerUTCOffset" jsonb,
    "failedPerUTCOffset" jsonb,
    count double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_PushStatus" OWNER TO parse;

--
-- Name: _Role; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Role" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_Role" OWNER TO parse;

--
-- Name: _SCHEMA; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_SCHEMA" (
    "className" character varying(120) NOT NULL,
    schema jsonb,
    "isParseClass" boolean
);


ALTER TABLE public."_SCHEMA" OWNER TO parse;

--
-- Name: _User; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_User" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    username text,
    email text,
    "emailVerified" boolean,
    "authData" jsonb,
    _rperm text[],
    _wperm text[],
    _hashed_password text,
    _email_verify_token_expires_at timestamp with time zone,
    _email_verify_token text,
    _account_lockout_expires_at timestamp with time zone,
    _failed_login_count double precision,
    _perishable_token text,
    _perishable_token_expires_at timestamp with time zone,
    _password_changed_at timestamp with time zone,
    _password_history jsonb
);


ALTER TABLE public."_User" OWNER TO parse;

--
-- Name: address; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public.address (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    _wperm text[],
    location point,
    city text,
    state text,
    country text,
    address text,
    "fromCache" boolean
);


ALTER TABLE public.address OWNER TO parse;

--
-- Name: city; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public.city (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    _wperm text[],
    location point,
    city text,
    state text,
    country text,
    "fromCache" boolean,
    "minLng" double precision,
    "maxLat" double precision,
    "maxLng" double precision,
    "minLat" double precision
);


ALTER TABLE public.city OWNER TO parse;

--
-- Name: input; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public.input (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    _rperm text[],
    _wperm text[],
    input text,
    address text,
    city text
);


ALTER TABLE public.input OWNER TO parse;

--
-- Name: my_location; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public.my_location (
    location point
);


ALTER TABLE public.my_location OWNER TO parse;

--
-- Data for Name: _Audience; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_Audience" ("objectId", "createdAt", "updatedAt", name, query, "lastUsed", "timesUsed", _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _GlobalConfig; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_GlobalConfig" ("objectId", params, "masterKeyOnly") FROM stdin;
\.


--
-- Data for Name: _Hooks; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_Hooks" ("functionName", "className", "triggerName", url) FROM stdin;
\.


--
-- Data for Name: _Idempotency; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_Idempotency" ("objectId", "createdAt", "updatedAt", "reqId", expire, _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _JobSchedule; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_JobSchedule" ("objectId", "createdAt", "updatedAt", "jobName", description, params, "startAfter", "daysOfWeek", "timeOfDay", "lastRun", "repeatMinutes", _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _JobStatus; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_JobStatus" ("objectId", "createdAt", "updatedAt", "jobName", source, status, message, params, "finishedAt", _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _Join:roles:_Role; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_Join:roles:_Role" ("relatedId", "owningId") FROM stdin;
\.


--
-- Data for Name: _Join:users:_Role; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_Join:users:_Role" ("relatedId", "owningId") FROM stdin;
\.


--
-- Data for Name: _PushStatus; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_PushStatus" ("objectId", "createdAt", "updatedAt", "pushTime", source, query, payload, title, expiry, expiration_interval, status, "numSent", "numFailed", "pushHash", "errorMessage", "sentPerType", "failedPerType", "sentPerUTCOffset", "failedPerUTCOffset", count, _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _Role; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_Role" ("objectId", "createdAt", "updatedAt", name, _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _SCHEMA; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_SCHEMA" ("className", schema, "isParseClass") FROM stdin;
_User	{"fields": {"email": {"type": "String"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "authData": {"type": "Object"}, "objectId": {"type": "String"}, "username": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "emailVerified": {"type": "Boolean"}, "_hashed_password": {"type": "String"}}, "className": "_User"}	t
_Role	{"fields": {"name": {"type": "String"}, "roles": {"type": "Relation", "targetClass": "_Role"}, "users": {"type": "Relation", "targetClass": "_User"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "_Role"}	t
city	{"fields": {"city": {"type": "String"}, "state": {"type": "String"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "maxLat": {"type": "Number"}, "maxLng": {"type": "Number"}, "minLat": {"type": "Number"}, "minLng": {"type": "Number"}, "country": {"type": "String"}, "location": {"type": "GeoPoint"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "fromCache": {"type": "Boolean"}, "updatedAt": {"type": "Date"}}, "className": "city"}	t
address	{"fields": {"city": {"type": "String"}, "state": {"type": "String"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "address": {"type": "String"}, "country": {"type": "String"}, "location": {"type": "GeoPoint"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "fromCache": {"type": "Boolean"}, "updatedAt": {"type": "Date"}}, "className": "address"}	t
input	{"fields": {"city": {"type": "Pointer", "targetClass": "city"}, "input": {"type": "String"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "address": {"type": "Pointer", "targetClass": "address"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "input"}	t
\.


--
-- Data for Name: _User; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public."_User" ("objectId", "createdAt", "updatedAt", username, email, "emailVerified", "authData", _rperm, _wperm, _hashed_password, _email_verify_token_expires_at, _email_verify_token, _account_lockout_expires_at, _failed_login_count, _perishable_token, _perishable_token_expires_at, _password_changed_at, _password_history) FROM stdin;
\.


--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public.address ("objectId", "createdAt", "updatedAt", _rperm, _wperm, location, city, state, country, address, "fromCache") FROM stdin;
XjmSvrEbGU	2022-04-24 03:28:03.668+00	2022-04-24 03:28:20.06+00	\N	\N	(-83.73066449645455,42.26376455)	ann arbor	mi	us	1415 brooklyn avenue, ann arbor, mi, us	t
9yvuA2Fhif	2022-04-24 03:28:24.099+00	2022-04-24 03:28:24.208+00	\N	\N	(-83.730668,42.263826)	ann arbor	mi	us	1415 brooklyn avenue, ann arbor, mi, us	t
Cyn2YoWVHA	2022-04-24 03:28:33.651+00	2022-04-24 03:28:33.759+00	\N	\N	(-72.28544581481482,42.93713974074074)	keene	nh	us	73 leverett street, keene, nh, us	t
RaTuOuGf8r	2022-04-24 03:28:30.92+00	2022-04-24 03:28:38.636+00	\N	\N	(-72.28547444444445,42.937140222222226)	keene	nh	us	75 leverett street, keene, nh, us	t
xDjcIjfEdj	2022-04-24 03:28:43.27+00	2022-04-24 03:29:10.144+00	\N	\N	(-82.586111,28.068031)	tampa	fl	us	8917 beeler drive, tampa, fl, us	t
dH70VWxj3g	2022-04-24 20:27:18.316+00	2022-04-24 20:27:36.952+00	\N	\N	(-71.28542384088448,42.9279269)	derry	nh	us	166 chester road, derry, nh, us	t
nttCFf6WDo	2022-04-28 22:21:14.633+00	2022-04-28 22:21:14.733+00	\N	\N	(-72.27716820366064,42.930149150000005)	keene	nh	us	cumberland farms, keene, nh, us	t
uLLJXD2foW	2022-04-28 22:29:17.401+00	2022-04-28 22:29:17.501+00	\N	\N	(-72.2749185,42.927858)	keene	nh	us	84 marlboro street, keene, nh, us	t
\.


--
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public.city ("objectId", "createdAt", "updatedAt", _rperm, _wperm, location, city, state, country, "fromCache", "minLng", "maxLat", "maxLng", "minLat") FROM stdin;
MGV4KiImV6	2022-04-24 04:11:33.428+00	2022-04-24 04:11:33.528+00	\N	\N	(-117.45392875,47.672788)	spokane	wa	us	t	-117.6039994	47.7587975	-117.3038581	47.5867785
kUv8I4YGoN	2022-04-24 04:11:34.417+00	2022-04-24 04:11:34.517+00	\N	\N	(-104.8010465,39.95913775)	brighton	co	us	t	-104.883817	40.0186094	-104.718276	39.8996661
2MBh1drmRC	2022-04-24 04:11:35.016+00	2022-04-24 04:11:35.116+00	\N	\N	(-105.1268256,39.6901972)	lakewood	co	us	t	-105.2004371	39.761955	-105.0532141	39.6184394
nB4goZSr6R	2022-04-25 04:14:14.637+00	2022-05-09 20:00:55.884+00	\N	\N	(150.80236150000002,-33.768714)	sydney	nsw	au	t	150.260825	-33.3641864	151.343898	-34.1732416
51KIH6MPOu	2022-04-24 21:09:57.288+00	2022-04-24 21:15:02.177+00	\N	\N	(-71.56007629999999,43.4096153)	northfield	nh	us	t	-71.6520045	43.4554634	-71.4681481	43.3637672
wjzFC80VRk	2022-04-24 21:16:16.626+00	2022-04-24 21:16:17.263+00	\N	\N	(-73.2346795,45.40916835)	richelieu	qc	ca	t	-73.2766318	45.4562675	-73.1927272	45.3620692
TH0Wz18eft	2022-04-24 21:15:04.6+00	2022-04-24 21:15:05.315+00	\N	\N	(-71.56569329999999,42.563126499999996)	ayer	ma	us	t	-71.6199274	42.5832227	-71.5114592	42.5430303
sOZBD7f4LM	2022-04-24 21:15:12.567+00	2022-04-24 21:15:13.105+00	\N	\N	(-72.1141206,43.59376495)	enfield	nh	us	t	-72.208145	43.658591	-72.0200962	43.5289389
3bRdNF29Cm	2022-04-24 21:15:19.744+00	2022-04-24 23:25:21.904+00	\N	\N	(-117.10340310000001,47.66972925)	liberty lake	wa	us	t	-117.1434749	47.6899519	-117.0633313	47.6495066
hnmADIQyn4	2022-04-24 21:16:25.211+00	2022-04-24 21:16:25.779+00	\N	\N	(-88.391235,35.2696415)	adamsville	tn	us	t	-88.428379	35.337109	-88.354091	35.202174
GyePdUuxEf	2022-04-24 21:11:51.414+00	2022-04-24 23:25:26.798+00	\N	\N	(-72.4509934,42.891165900000004)	chesterfield	nh	us	t	-72.5553948	42.9342758	-72.346592	42.848056
7DdiwuYBEr	2022-04-25 04:12:57.585+00	2022-04-25 04:12:58.623+00	\N	\N	(-98.7599584,33.360113850000005)	olney	tx	us	t	-98.776933	33.3797678	-98.7429838	33.3404599
G73lsytDmO	2022-04-24 04:11:35.616+00	2022-05-09 20:00:55.78+00	\N	\N	(-87.73209109999999,41.8337853)	chicago	il	us	t	-87.940101	42.0230396	-87.5240812	41.644531
t5vHGFwZ2v	2022-04-24 21:16:28.985+00	2022-04-24 21:16:29.639+00	\N	\N	(-117.6487884,33.506338549999995)	san juan capistrano	ca	us	t	-117.6867648	33.5461755	-117.610812	33.4665016
XfN9SVMvGF	2022-04-24 04:14:45.622+00	2022-04-24 04:21:38.084+00	\N	\N	(-72.2512455,43.033045)	gilsum	nh	us	t	-72.308399	43.07618	-72.194092	42.98991
0BShpXbMYu	2022-04-24 04:17:00.841+00	2022-04-24 04:21:38.402+00	\N	\N	(-72.30975649999999,43.1158715)	alstead	nh	us	t	-72.376424	43.169952	-72.243089	43.061791
3BhX1YAXW7	2022-04-24 04:17:01.189+00	2022-04-24 04:21:38.648+00	\N	\N	(-72.28801005,43.21685265)	acworth	nh	us	t	-72.3563081	43.2708643	-72.219712	43.162841
xAvGQpMowl	2022-04-24 04:17:01.454+00	2022-04-24 04:21:38.898+00	\N	\N	(-72.2606805,43.29680085)	unity	nh	us	t	-72.361725	43.3337381	-72.159636	43.2598636
g8NqfF9FgK	2022-04-24 04:17:01.712+00	2022-04-24 04:21:39.221+00	\N	\N	(-72.31234995,43.47448115)	cornish	nh	us	t	-72.3991188	43.5251763	-72.2255811	43.423786
ifbd36Yu83	2022-04-24 04:17:02.35+00	2022-04-24 04:21:39.556+00	\N	\N	(-72.2838034,43.54460345)	plainfield	nh	us	t	-72.3964415	43.6002671	-72.1711653	43.4889398
k2hgQaLv3q	2022-04-24 04:17:02.741+00	2022-04-24 04:21:39.886+00	\N	\N	(-72.2477524,43.63877595)	lebanon	nh	us	t	-72.3351728	43.69239	-72.160332	43.5851619
ECwyxqFNOJ	2022-04-24 21:15:15.974+00	2022-04-24 23:25:36.902+00	\N	\N	(-71.51490515,42.85092535)	merrimack	nh	us	t	-71.57742	42.9110827	-71.4523903	42.790768
pvhSWUWqDl	2022-04-24 04:17:02.993+00	2022-04-24 04:21:40.222+00	\N	\N	(-72.3138241,43.751389599999996)	norwich	vt	us	t	-72.4222485	43.8104556	-72.2053997	43.6923236
kMoRPioarf	2022-04-24 21:15:56.099+00	2022-04-24 21:16:34.374+00	\N	\N	(-77.2584145,38.636404999999996)	woodbridge	va	us	t	-77.292779	38.671859	-77.22405	38.600951
VcVcHE14AE	2022-04-24 21:15:59.71+00	2022-04-24 21:16:00.253+00	\N	\N	(-89.409152,43.0850327)	madison	wi	us	t	-89.571661	43.171916	-89.246643	42.9981494
kt7QEIhJoV	2022-04-24 21:08:40.044+00	2022-04-24 21:14:18.402+00	\N	\N	(-71.82276494999999,43.17348355)	henniker	nh	us	t	-71.9129635	43.2315982	-71.7325664	43.1153689
EkTSBhHRDV	2022-04-25 06:15:04.486+00	2022-04-25 06:15:05.192+00	\N	\N	(-118.24472225,34.1929755)	glendale	ca	us	t	-118.3078696	34.26719	-118.1815749	34.118761
Ki4svPcpok	2022-04-24 21:08:55.149+00	2022-04-24 21:14:23.446+00	\N	\N	(-121.29220465,38.76325405)	roseville	ca	us	t	-121.400248	38.8101558	-121.1841613	38.7163523
iFXN9Xh7Nu	2022-04-25 06:09:29.604+00	2022-05-09 18:40:18.886+00	\N	\N	(-96.96140980000001,32.862876)	irving	tx	us	t	-97.0340376	32.953966	-96.888782	32.771786
c1Dcg1PEvB	2022-04-24 21:09:01.229+00	2022-04-24 21:14:31.76+00	\N	\N	(-71.9460419,43.14953495)	hillsborough	nh	us	t	-72.03656	43.2068251	-71.8555238	43.0922448
em5vtrF9yj	2022-04-25 02:22:33.221+00	2022-04-25 02:47:26.735+00	\N	\N	(-83.09919905000001,42.352717600000005)	detroit	mi	us	t	-83.287959	42.4502432	-82.9104391	42.255192
duypr0EdT0	2022-04-28 19:15:15.263+00	2022-05-09 18:41:00.235+00	\N	\N	(-71.7226642,43.083332)	weare	nh	us	t	-71.8102484	43.152454	-71.63508	43.01421
bwQQ3W2ryJ	2022-04-24 21:17:07.456+00	2022-04-24 21:17:08.075+00	\N	\N	(-122.093077,47.927566999999996)	snohomish	wa	us	t	-122.119772	47.949522	-122.066382	47.905612
xnbcBidHhZ	2022-04-24 21:16:12.967+00	2022-04-24 21:16:13.613+00	\N	\N	(-83.925084,35.958462499999996)	knoxville	tn	us	t	-84.161625	36.067428	-83.688543	35.849497
0wRIMONrbL	2022-04-24 23:26:06.398+00	2022-04-24 23:26:07.582+00	\N	\N	(145.318275,-37.950559999999996)	melbourne	vic	au	t	144.44405	-37.40175	146.1925	-38.49937
sQVIJd1s6y	2022-04-24 23:25:52.247+00	2022-05-09 18:41:00.323+00	\N	\N	(-0.08817979999999997,51.4893171)	london	eng	gb	t	-0.5103751	51.6918741	0.3340155	51.2867601
auMOVHrDK9	2022-04-24 20:36:53.3+00	2022-04-24 23:24:59.953+00	\N	\N	(-71.69560005,43.19989345)	hopkinton	nh	us	t	-71.7878692	43.260014	-71.6033309	43.1397729
NkynY9rTsf	2022-04-25 04:13:09.954+00	2022-04-25 04:13:10.643+00	\N	\N	(-79.37624600000001,43.71752535)	toronto	on	ca	t	-79.6392727	43.8554425	-79.1132193	43.5796082
eiAAZfK1Cl	2022-04-24 04:05:54.173+00	2022-04-29 01:42:05.322+00	\N	\N	(-71.27680445,42.89136255)	derry	nh	us	t	-71.3466435	42.941805	-71.2069654	42.8409201
JCCEuKIntw	2022-04-25 02:47:28.66+00	2022-04-25 02:47:29.881+00	\N	\N	(-122.11617065,38.00047225)	martinez	ca	us	t	-122.1571681	38.0473872	-122.0751732	37.9535573
tfvuNBTHHd	2022-04-24 23:26:31.874+00	2022-04-24 23:26:32.465+00	\N	\N	(-74.96471275,40.709295)	hampton	nj	us	t	-74.9812505	40.720517	-74.948175	40.698073
639vG9mSFD	2022-04-25 06:09:03.394+00	2022-04-25 06:09:04.021+00	\N	\N	(82.142694,26.7789282)	faizabad	up	in	t	81.982694	26.9389282	82.302694	26.6189282
1xCSnsT8ri	2022-04-25 02:52:59.191+00	2022-04-25 02:53:02.421+00	\N	\N	(19.764755,-33.584995)	breede valley local municipality	wc	za	t	19.10196	-33.17011	20.42755	-33.99988
RjjCqliXzv	2022-04-24 21:15:30.559+00	2022-05-09 20:00:29.264+00	\N	\N	(-71.4480416,43.18767105)	pembroke	nh	us	t	-71.5028516	43.2482865	-71.3932316	43.1270556
89heWttK4g	2022-04-25 06:14:50.726+00	2022-04-25 06:14:51.754+00	\N	\N	(-71.0194157,43.45780765000001)	milton	nh	us	t	-71.0851005	43.5414553	-70.9537309	43.37416
BqwdSNsEhc	2022-04-25 06:08:44.56+00	2022-04-25 06:08:45.513+00	\N	\N	(-97.4436775,37.664609)	wichita	ks	us	t	-97.734352	37.8402	-97.153003	37.489018
LOopjfw47O	2022-04-24 03:29:15.295+00	2022-05-09 18:41:00.01+00	\N	\N	(-72.299983,42.9521465)	keene	nh	us	t	-72.382909	43.000032	-72.217057	42.904261
1y48eYXglo	2022-04-28 19:16:26.604+00	2022-05-09 20:00:55.923+00	\N	\N	(-72.19768675,43.36568445)	newport	nh	us	t	-72.269503	43.423786	-72.1258705	43.3075829
uo85AkhZGf	2022-05-09 20:00:55.205+00	2022-05-09 20:00:55.299+00	\N	\N	(-74.028436,41.4738375)	new windsor	ny	us	t	-74.049683	41.493339	-74.007189	41.454336
f02E1sMRGF	2022-04-25 06:32:02.383+00	2022-04-25 06:32:03.087+00	\N	\N	(-95.05369959999999,29.662114600000002)	la porte	tx	us	t	-95.1127028	29.7093221	-94.9946964	29.6149071
aPpZ77iG3I	2022-04-25 11:00:28.188+00	2022-04-25 11:00:29.268+00	\N	\N	(-97.18694375000001,31.55355685)	waco	tx	us	t	-97.329176	31.6603867	-97.0447115	31.446727
Ed5wSNxPc8	2022-04-25 20:15:21.855+00	2022-04-25 20:15:22.896+00	\N	\N	(-86.97832700000001,33.500661)	pleasant grove	al	us	t	-87.012922	33.538252	-86.943732	33.46307
F5rCtAVbTt	2022-04-28 18:50:21.312+00	2022-04-28 18:50:22.568+00	\N	\N	(-87.00148275,34.578604850000005)	decatur	al	us	t	-87.1053755	34.67101	-86.89759	34.4861997
rYbtCCk7cv	2022-04-24 21:09:21.147+00	2022-05-09 20:00:55.964+00	\N	\N	(-71.44408895000001,42.971067149999996)	manchester	nh	us	t	-71.5127468	43.0517833	-71.3754311	42.890351
y0tj2oHqnb	2022-04-24 21:16:36.814+00	2022-05-09 18:40:18.617+00	\N	\N	(-117.8871477,33.737833699999996)	santa ana	ca	us	t	-117.9439459	33.7840133	-117.8303495	33.6916541
8HXkMdNKSj	2022-04-25 06:31:12.171+00	2022-05-09 20:00:55.927+00	\N	\N	(28.0545147,-26.1045525)	sandton	gt	za	t	27.8945147	-25.9445525	28.2145147	-26.2645525
8cEZsSN2hc	2022-04-24 21:17:14.305+00	2022-05-09 20:00:55.756+00	\N	\N	(-97.74864755,30.3075694)	austin	tx	us	t	-97.9367663	30.5166255	-97.5605288	30.0985133
6HwogZ9jMc	2022-04-28 20:16:54.993+00	2022-04-28 20:16:55.941+00	\N	\N	(-96.8654126,32.60632255)	desoto	tx	us	t	-96.9084633	32.6476411	-96.8223619	32.565004
Kd2i4ZRgoV	2022-04-28 20:17:31.72+00	2022-05-09 18:40:18.798+00	\N	\N	(-86.785177,36.186640499999996)	nashville	tn	us	t	-87.054766	36.405496	-86.515588	35.967785
A9K73OWpY6	2022-05-09 18:37:27.369+00	2022-05-09 18:37:27.47+00	\N	\N	(-71.75378265,43.38062865)	salisbury	nh	us	t	-71.8383093	43.4438634	-71.669256	43.3173939
VutTOwp26I	2022-04-28 20:25:10.926+00	2022-04-28 20:25:11.947+00	\N	\N	(28.0498575,-26.2054913)	city of johannesburg metropolitan municipality	gt	za	t	27.8898575	-26.0454913	28.2098575	-26.3654913
WajMIz2eIe	2022-04-29 01:40:54.636+00	2022-04-29 01:40:54.736+00	\N	\N	(-70.83781785,42.81455845)	newburyport	ma	us	t	-70.9402949	42.8416465	-70.7353408	42.7874704
imTcjhrmMO	2022-04-29 01:41:04.469+00	2022-04-29 01:41:05.137+00	\N	\N	(-70.99786615,42.31244435)	boston	ma	us	t	-71.1912442	42.3969775	-70.8044881	42.2279112
2fCpEPUOYI	2022-04-29 01:41:59.073+00	2022-04-29 01:41:59.848+00	\N	\N	(-71.56273775,43.2308015)	concord	nh	us	t	-71.66871	43.309816	-71.4567655	43.151787
8WOTe74qXq	2022-05-09 18:37:27.379+00	2022-05-09 20:01:19.658+00	\N	\N	(-97.477833,35.4827235)	oklahoma city	ok	us	t	-97.830948	35.674752	-97.124718	35.290695
FgLlFALW0I	2022-04-29 01:42:12.917+00	2022-04-29 01:42:13.637+00	\N	\N	(-70.2270614,41.674846)	yarmouth	ma	us	t	-70.2948743	41.7939462	-70.1592485	41.5557458
2uBFn5jziB	2022-04-29 01:42:27.966+00	2022-04-29 01:42:28.603+00	\N	\N	(-71.095241,42.8430337)	plastow	nh	us	t	-71.136489	42.879793	-71.053993	42.8062744
cP2ArOMJiQ	2022-05-05 00:38:00.729+00	2022-05-05 00:38:00.829+00	\N	\N	(-71.384834,43.56107165)	gilford	nh	us	t	-71.4581698	43.6405734	-71.3114982	43.4815699
3JOAMUNbDq	2022-05-09 18:37:27.396+00	2022-05-09 18:37:27.497+00	\N	\N	(-72.46143625,45.8923575)	drummondville	qc	ca	t	-72.6552443	46.0316708	-72.2676282	45.7530442
hTD6YulaOB	2022-05-05 10:44:00.132+00	2022-05-05 10:44:00.232+00	\N	\N	(-72.275353437075,42.927924167703)	keene	nh	us	t	-72.275403437075	42.927974167703	-72.275303437075	42.927874167703
EM6CRz6hYI	2022-05-06 07:15:56.912+00	2022-05-06 07:16:05.978+00	\N	\N	(-71.4819594,43.5656171)	laconia	nh	us	t	-71.5355344	43.6295413	-71.4283844	43.5016929
dxdJr8kHc5	2022-05-05 10:43:00.535+00	2022-05-09 05:00:25.104+00	\N	\N	(-72.27506573333301,42.927921466667)	keene	nh	us	t	-72.275115733333	42.927971466667	-72.275015733333	42.927871466667
5Ct2n3mrDj	2022-05-09 18:37:27.338+00	2022-05-09 18:37:27.437+00	\N	\N	(-87.88270975,30.6229)	daphne	al	us	t	-87.9223745	30.676768	-87.843045	30.569032
jo2VGvAQf8	2022-05-09 18:37:27.345+00	2022-05-09 18:37:27.447+00	\N	\N	(152.3516785,-24.8653253)	bundaberg	qld	au	t	152.1916785	-24.7053253	152.5116785	-25.0253253
Qfzk4G1v6k	2022-05-09 18:37:27.347+00	2022-05-09 18:37:27.448+00	\N	\N	(-90.426834,37.785365999999996)	farmington	mo	us	t	-90.464181	37.823975	-90.389487	37.746757
4as7ZtxUax	2022-05-09 18:37:27.353+00	2022-05-09 18:37:27.452+00	\N	\N	(-80.64725064999999,27.9603346)	palm bay	fl	us	t	-80.7535564	28.0638216	-80.5409449	27.8568476
CrUdFIEQq6	2022-05-09 18:37:27.486+00	2022-05-09 18:37:27.941+00	\N	\N	(-81.683107,30.344972499999997)	jacksonville	fl	us	t	-82.049502	30.586197	-81.316712	30.103748
wyKFpOnE5c	2022-05-09 18:37:27.402+00	2022-05-09 18:37:27.504+00	\N	\N	(-124.0590934,48.8258937)	lake cowichan	bc	ca	t	-124.1139711	48.8414184	-124.0042157	48.810369
LVWJoH7oxJ	2022-05-09 18:37:27.425+00	2022-05-09 18:37:27.526+00	\N	\N	(-81.61007685,28.126601649999998)	haines city	fl	us	t	-81.6695027	28.1867383	-81.550651	28.066465
BT05PvTuri	2022-05-09 18:37:27.428+00	2022-05-09 18:37:27.528+00	\N	\N	(-122.2768516,38.116438599999995)	vallejo	ca	us	t	-122.3875532	38.173496	-122.16615	38.0593812
WuPSXKebGN	2022-05-09 18:37:27.433+00	2022-05-09 18:37:27.532+00	\N	\N	(-108.5637175,45.781662999999995)	billings	mt	us	t	-108.691519	45.852653	-108.435916	45.710673
MjueF4ok0b	2022-05-09 18:37:27.639+00	2022-05-09 18:37:27.739+00	\N	\N	(-76.86694205,39.193833850000004)	columbia	md	us	t	-76.9469099	39.2400085	-76.7869742	39.1476592
VucjbNC60L	2022-05-09 18:37:27.443+00	2022-05-09 18:37:27.543+00	\N	\N	(-117.2840508,34.140525999999994)	san bernardino	ca	us	t	-117.4031296	34.230706	-117.164972	34.050346
Bb1g4GcmeP	2022-05-09 18:37:27.949+00	2022-05-09 19:45:27.405+00	\N	\N	(-77.4932379,37.5247702)	richmond	va	us	t	-77.6011728	37.6028099	-77.385303	37.4467305
lJ4wYT0mv0	2022-05-09 18:37:27.463+00	2022-05-09 18:37:27.564+00	\N	\N	(30.318395000000002,-23.53461)	greater letaba local municipality	lp	za	t	29.94788	-23.30845	30.68891	-23.76077
dW9hUq5weZ	2022-05-09 18:37:27.469+00	2022-05-09 18:37:27.569+00	\N	\N	(-96.68583555000001,40.8043845)	lincoln	ne	us	t	-96.80415	40.915002	-96.5675211	40.693767
laYppyi9jW	2022-05-09 18:37:27.472+00	2022-05-09 18:37:27.572+00	\N	\N	(-117.2819291,33.04235665)	encinitas	ca	us	t	-117.3682912	33.0887223	-117.195567	32.995991
Afza78UDbi	2022-05-09 18:37:27.478+00	2022-05-09 18:37:27.579+00	\N	\N	(-84.25399295,30.46696975)	tallahassee	fl	us	t	-84.3780355	30.5872436	-84.1299504	30.3466959
lGZnoM2OSt	2022-05-09 18:37:27.731+00	2022-05-09 18:37:27.831+00	\N	\N	(-74.070111,40.9445835)	paramus	nj	us	t	-74.101378	40.980635	-74.038844	40.908532
G47JQmn0UK	2022-05-09 18:37:27.493+00	2022-05-09 18:37:27.593+00	\N	\N	(-71.1036617,42.39534115)	somerville	ma	us	t	-71.134635	42.4181555	-71.0726884	42.3725268
qh06Tddl3N	2022-05-09 18:37:27.508+00	2022-05-09 20:00:29.278+00	\N	\N	(-71.05625144999999,43.739557399999995)	effingham	nh	us	t	-71.1321909	43.800636	-70.980312	43.6784788
B0bn8ByW5T	2022-05-09 18:37:27.511+00	2022-05-09 18:37:27.611+00	\N	\N	(-81.4420188,28.405193099999998)	williamsburg	fl	us	t	-81.4540507	28.4208033	-81.4299869	28.3895829
h7n6VhRYZV	2022-05-09 18:37:27.542+00	2022-05-09 18:37:27.641+00	\N	\N	(-52.812647049999995,47.51888145)	mount pearl	nl	ca	t	-52.8514944	47.5404946	-52.7737997	47.4972683
x3VwAShxB6	2022-05-09 18:37:27.548+00	2022-05-09 18:37:27.647+00	\N	\N	(-76.16157100000001,42.516961)	town of virgil	ny	us	t	-76.261674	42.555751	-76.061468	42.478171
CasIYTREGV	2022-05-09 18:37:27.57+00	2022-05-09 18:37:27.671+00	\N	\N	(-88.3276885,41.6784157)	oswego	il	us	t	-88.395102	41.7195814	-88.260275	41.63725
8XAjawlTS2	2022-05-09 18:37:27.435+00	2022-05-09 18:37:27.715+00	\N	\N	(-82.3223151,29.6881284)	city of gainesville municipal boundaries	fl	us	t	-82.4222531	29.7783723	-82.2223771	29.5978845
Z2qa23VOgc	2022-05-09 18:37:27.624+00	2022-05-09 18:37:27.717+00	\N	\N	(-84.15736065,39.695737300000005)	kettering	oh	us	t	-84.214729	39.7365246	-84.0999923	39.65495
O5l57OBgNO	2022-05-09 18:37:27.673+00	2022-05-09 18:37:27.773+00	\N	\N	(-88.0491125,42.11473)	palatine	il	us	t	-88.094968	42.153852	-88.003257	42.075608
0vy0tp497G	2022-05-09 18:37:27.675+00	2022-05-09 18:37:27.776+00	\N	\N	(-76.09856540000001,43.03229505)	dewitt	ny	us	t	-76.13433	43.0543721	-76.0628008	43.010218
Ax3OkouGQ5	2022-05-09 18:37:27.684+00	2022-05-09 18:37:27.785+00	\N	\N	(-74.9995851,41.6740235)	town of cochecton	ny	us	t	-75.0689897	41.7298085	-74.9301805	41.6182385
Fc5djV7C3x	2022-05-09 18:37:27.692+00	2022-05-09 18:37:27.791+00	\N	\N	(-73.08673535,44.42636505)	williston	vt	us	t	-73.154497	44.483231	-73.0189737	44.3694991
7X5kIBZfbE	2022-05-09 18:37:27.706+00	2022-05-09 18:37:27.806+00	\N	\N	(-73.85725065,45.68381235)	blainville	qc	ca	t	-73.9254873	45.7247461	-73.789014	45.6428786
ZjngfbEXV7	2022-05-09 18:37:27.714+00	2022-05-09 18:37:27.813+00	\N	\N	(-87.5437108,37.996239)	evansville	in	us	t	-87.637548	38.05689	-87.4498736	37.935588
sZje2MoeEf	2022-05-09 18:37:27.811+00	2022-05-09 20:00:55.938+00	\N	\N	(30.270935,-23.858449999999998)	greater tzaneen local municipality	lp	za	t	29.85444	-23.52139	30.68743	-24.19551
bqGRpxvbxo	2022-05-09 18:37:27.732+00	2022-05-09 18:37:27.833+00	\N	\N	(-118.21401499999999,33.97892095)	huntington park	ca	us	t	-118.239021	33.9962649	-118.189009	33.961577
ODrvUmSsXM	2022-05-09 18:37:27.738+00	2022-05-09 18:37:27.839+00	\N	\N	(145.927171,-38.149333999999996)	warragul	vic	au	t	145.875495	-38.095304	145.978847	-38.203364
Ol6w2TKNVp	2022-05-09 18:37:27.789+00	2022-05-09 18:37:27.889+00	\N	\N	(-106.325336,42.825237)	casper	wy	us	t	-106.434966	42.907532	-106.215706	42.742942
Ar2jeO5Sej	2022-05-09 18:37:27.798+00	2022-05-09 18:37:27.898+00	\N	\N	(-73.6129952,45.76835955)	mascouche	qc	ca	t	-73.7010495	45.8203925	-73.5249409	45.7163266
5GbC3OFvCg	2022-05-09 18:37:27.803+00	2022-05-09 18:37:27.903+00	\N	\N	(-71.44174865,42.485477849999995)	acton	ma	us	t	-71.4985504	42.5340164	-71.3849469	42.4369393
yzxtwQ0B7H	2022-05-09 18:37:27.805+00	2022-05-09 18:37:27.906+00	\N	\N	(-85.59674275,42.274158)	kalamazoo	mi	us	t	-85.6627076	42.332752	-85.5307779	42.215564
CFhKEf43rf	2022-05-09 18:37:27.456+00	2022-05-09 20:00:55.946+00	\N	\N	(-112.12477965,33.60437665)	phoenix	az	us	t	-112.3240289	33.9183794	-111.9255304	33.2903739
0PncqZTcWh	2022-05-09 18:37:27.364+00	2022-05-09 18:37:27.918+00	\N	\N	(-98.2455314,19.20353485)	zacatelco	tla	mx	t	-98.2608258	19.2327137	-98.230237	19.174356
WRWqj6zoQ9	2022-05-09 18:37:27.498+00	2022-05-09 20:00:20.414+00	\N	\N	(-111.83147919999999,33.4151117)	mesa	az	us	t	-111.9914792	33.5751117	-111.6714792	33.2551117
Ad213iBHNV	2022-05-09 18:37:27.775+00	2022-05-09 18:37:27.875+00	\N	\N	(-85.6826375,38.051671)	hillview	ky	us	t	-85.710033	38.085839	-85.655242	38.017503
vbIBOaP18D	2022-05-09 20:00:55.349+00	2022-05-09 20:00:55.449+00	\N	\N	(-123.12232180000001,44.05990035)	eugene	or	us	t	-123.2087577	44.1322715	-123.0358859	43.9875292
QnlC2B3CPK	2022-05-09 20:00:55.435+00	2022-05-09 20:00:55.535+00	\N	\N	(27.56942865,-28.5695933)	setsoto local municipality	fs	za	t	27.03721	-28.02925	28.1016473	-29.1099366
RvSUXJNxUE	2022-05-09 20:00:55.468+00	2022-05-09 20:00:55.575+00	\N	\N	(5.89665035,52.00567735)	arnhem	ge	nl	t	5.8029606	52.0778905	5.9903401	51.9334642
oCWx5XBApm	2022-05-09 18:37:27.841+00	2022-05-09 20:00:29.051+00	\N	\N	(-73.72422595,45.557432649999996)	montreal	qc	ca	t	-73.9741567	45.7047897	-73.4742952	45.4100756
PHHYg4vyjH	2022-05-09 20:00:55.585+00	2022-05-09 20:00:55.691+00	\N	\N	(-85.63591885,44.7308495)	garfield township	mi	us	t	-85.6968312	44.7754541	-85.5750065	44.6862449
W8eN4D8sDQ	2022-05-09 20:00:55.612+00	2022-05-09 20:00:55.725+00	\N	\N	(-83.363073,41.4509025)	woodville	oh	us	t	-83.378253	41.459026	-83.347893	41.442779
RIWtydGBd5	2022-05-09 20:00:55.813+00	2022-05-09 20:00:55.912+00	\N	\N	(7.2526679000000005,47.0857855)	merzligen	be	ch	t	7.2359167	47.0964678	7.2694191	47.0751032
879WKhnSeF	2022-05-09 20:00:55.831+00	2022-05-09 20:00:55.93+00	\N	\N	(-97.58598045,30.44104325)	pflugerville	tx	us	t	-97.6688245	30.5006645	-97.5031364	30.381422
JdFmRWs5Ay	2022-05-09 20:00:55.869+00	2022-05-09 20:00:55.969+00	\N	\N	(-117.24487869999999,47.65484)	spokane valley	wa	us	t	-117.3469902	47.709875	-117.1427672	47.599805
DW5SocJJtp	2022-05-09 20:08:28.748+00	2022-05-09 20:08:28.848+00	\N	\N	(-90.1967725,32.303971399999995)	jackson	ms	us	t	-90.3299278	32.4124415	-90.0636172	32.1955013
mSW5I53cdu	2022-05-09 20:08:33.29+00	2022-05-09 20:08:33.39+00	\N	\N	(-118.05488335,34.10318675)	temple city	ca	us	t	-118.0814147	34.120996	-118.028352	34.0853775
ML8ntvFcly	2022-05-09 21:39:07.765+00	2022-05-09 21:39:07.864+00	\N	\N	(18.417004249999998,-34.137593949999996)	fish hoek	wc	za	t	18.3941083	-34.1233637	18.4399002	-34.1518242
MCRt5mVeso	2022-05-17 07:17:01.644+00	2022-05-17 07:17:01.744+00	\N	\N	(-126.91816564999999,50.584985700000004)	alert bay	bc	ca	t	-126.9347934	50.5962345	-126.9015379	50.5737369
uBJU8ir5tt	2022-05-17 10:00:22.092+00	2022-05-17 10:00:22.191+00	\N	\N	(-82.7247635,27.8918109)	pinellas county	fl	us	t	-82.908909	28.1733488	-82.540618	27.610273
T0OvDcqPA0	2022-05-17 10:00:22.434+00	2022-05-17 10:00:22.535+00	\N	\N	(-90.33748800000001,43.654904450000004)	hillsboro	wi	us	t	-90.352617	43.6623919	-90.322359	43.647417
VSyVP4j2cQ	2022-05-17 10:00:23.166+00	2022-05-17 10:00:23.266+00	\N	\N	(12.4657641,44.135080349999996)	bellaria-igea marina	emi	it	t	12.4278982	44.1622868	12.50363	44.1078739
qa2xOY3Q79	2022-05-17 10:00:23.885+00	2022-05-17 10:00:23.986+00	\N	\N	(-86.85013699999999,33.5312375)	birmingham	al	us	t	-87.122124	33.678715	-86.57815	33.38376
5OXapyMCzM	2022-05-17 10:00:24.649+00	2022-05-17 10:00:24.749+00	\N	\N	(-83.26857290000001,42.2255876)	taylor	mi	us	t	-83.3090035	42.2698921	-83.2281423	42.1812831
wMMx9aAV5V	2022-05-17 10:00:25.396+00	2022-05-17 10:00:25.495+00	\N	\N	(-71.24010095,42.389042)	waltham	ma	us	t	-71.2860312	42.4244463	-71.1941707	42.3536377
lS5jsuzWMq	2022-05-17 10:00:26.189+00	2022-05-17 10:00:26.288+00	\N	\N	(-80.11164984999999,40.578474)	franklin park	pa	us	t	-80.1593237	40.616301	-80.063976	40.540647
G5kFsHHzTd	2022-05-17 10:00:26.903+00	2022-05-17 10:00:27.003+00	\N	\N	(-87.90504615,42.037484500000005)	des plaines	il	us	t	-87.950074	42.079627	-87.8600183	41.995342
RZs0SLNb49	2022-05-17 10:00:27.649+00	2022-05-17 10:00:27.748+00	\N	\N	(-112.6586921,33.4708927)	buckeye	az	us	t	-112.8591058	33.8112594	-112.4582784	33.130526
iYvZtMyQ8f	2022-05-17 10:00:28.335+00	2022-05-17 10:00:28.435+00	\N	\N	(-117.59682799999999,46.4739915)	pomeroy	wa	us	t	-117.629269	46.480777	-117.564387	46.467206
ssR4cwAoVD	2022-05-17 10:00:28.739+00	2022-05-17 10:00:28.839+00	\N	\N	(-85.660089,42.956347550000004)	grand rapids	mi	us	t	-85.751532	43.0290471	-85.568646	42.883648
9DiRkIPeBe	2022-05-17 10:00:29.416+00	2022-05-17 10:00:29.516+00	\N	\N	(-78.28855365000001,39.237002950000004)	frederick county	va	us	t	-78.544137	39.466012	-78.0329703	39.0079939
hafJBHMJU8	2022-05-17 10:00:29.697+00	2022-05-17 10:00:29.796+00	\N	\N	(-116.4168621,33.8236662)	cathedral city	ca	us	t	-116.5043233	33.8913441	-116.3294009	33.7559883
ZCfWAvecQG	2022-05-17 10:00:30.135+00	2022-05-17 10:00:30.236+00	\N	\N	(-84.138043,33.6863735)	stonecrest	ga	us	t	-84.201754	33.758081	-84.074332	33.614666
pqGy5yypHl	2022-05-17 10:00:30.995+00	2022-05-17 10:00:31.095+00	\N	\N	(32.4934553,-25.8438683)	matola	l	mz	t	32.4007541	-25.6936495	32.5861565	-25.9940871
tsZI8Hhk6F	2022-05-17 10:00:31.3+00	2022-05-17 10:00:31.4+00	\N	\N	(-108.7668995,44.813917000000004)	powell	wy	us	t	-108.804175	44.883429	-108.729624	44.744405
OGqj97c1iu	2022-05-17 10:00:31.622+00	2022-05-17 10:00:31.723+00	\N	\N	(28.494385,-25.593851)	city of tshwane metropolitan municipality	gt	za	t	27.89035	-25.109612	29.09842	-26.07809
1GPvI7L0JI	2022-05-17 10:00:32.004+00	2022-05-17 10:00:32.104+00	\N	\N	(4.3755366,50.855156199999996)	city of brussels	brussels-capital	be	t	4.3140021	50.9139045	4.4370711	50.7964079
HyNxSVSEv6	2022-05-17 10:00:32.689+00	2022-05-17 10:00:32.788+00	\N	\N	(24.7048647,45.19331165)	valea iașului		ro	t	24.6602971	45.2225089	24.7494323	45.1641144
qYahJCVbyG	2022-05-17 10:00:33.211+00	2022-05-17 10:00:33.311+00	\N	\N	(-76.0300692,36.7903304)	virginia beach	va	us	t	-76.228243	37.0302476	-75.8318954	36.5504132
kvdcZQrT3X	2022-05-17 10:00:33.632+00	2022-05-17 10:00:33.732+00	\N	\N	(18.6562791,-33.914808)	city of cape town	wc	za	t	18.30722	-33.471276	19.0053382	-34.35834
BLlwjKwuXB	2022-05-17 10:00:34.677+00	2022-05-17 10:00:34.778+00	\N	\N	(-75.3836901,39.525260599999996)	quinton township	nj	us	t	-75.4601928	39.5789275	-75.3071874	39.4715937
ZOCP0sjQxZ	2022-05-17 10:00:35.001+00	2022-05-17 10:00:35.102+00	\N	\N	(-97.75814589999999,32.451021)	granbury	tx	us	t	-97.8343647	32.490727	-97.6819271	32.411315
V53gBaidVW	2022-05-17 10:00:35.691+00	2022-05-17 10:00:35.79+00	\N	\N	(-79.13347300000001,37.2279877)	campbell county	va	us	t	-79.4422797	37.4336768	-78.8246663	37.0222986
tVDiKIUhqS	2022-05-17 10:00:36.111+00	2022-05-17 10:00:36.211+00	\N	\N	(-90.442279,38.3804595)	imperial township	mo	us	t	-90.513739	38.43795	-90.370819	38.322969
vBnfZjBHas	2022-05-17 10:00:36.762+00	2022-05-17 10:00:36.863+00	\N	\N	(31.930039899999997,-28.788668)	umhlathuze local municipality	nl	za	t	31.7057799	-28.6219761	32.1542999	-28.9553599
HaqO2ZCWFd	2022-05-17 10:00:37.041+00	2022-05-17 10:00:37.142+00	\N	\N	(-115.448325,32.624862199999995)	mexicali	bcn	mx	t	-115.608325	32.7848622	-115.288325	32.4648622
2jehCCGuIq	2022-05-17 10:00:37.357+00	2022-05-17 10:00:37.456+00	\N	\N	(-91.01865495,38.555659)	washington	mo	us	t	-91.079287	38.59043	-90.9580229	38.520888
UTfCWSHPQi	2022-05-17 10:00:37.811+00	2022-05-17 10:00:37.91+00	\N	\N	(-83.26022985,42.47975195)	southfield	mi	us	t	-83.319938	42.5174709	-83.2005217	42.442033
jcUQk6zo22	2022-05-17 10:00:38.125+00	2022-05-17 10:00:38.224+00	\N	\N	(-81.93280225,40.806875700000006)	wooster	oh	us	t	-81.979975	40.8660854	-81.8856295	40.747666
5Yw3K9ZEoE	2022-05-17 10:00:38.49+00	2022-05-17 10:00:38.59+00	\N	\N	(-111.8585004,33.6740782)	scottsdale	az	us	t	-111.9609326	33.9005256	-111.7560682	33.4476308
nC17lYpMPW	2022-05-17 10:00:39.071+00	2022-05-17 10:00:39.171+00	\N	\N	(-0.1305539,50.8452919)	brighton and hove	eng	gb	t	-0.2450771	50.8923741	-0.0160307	50.7982097
4o9QGooFTi	2022-05-17 10:00:39.427+00	2022-05-17 10:00:39.527+00	\N	\N	(-71.09049999999999,42.78286985)	haverhill	ma	us	t	-71.1823981	42.8332765	-70.9986019	42.7324632
E11wg3rn4E	2022-05-17 10:00:39.833+00	2022-05-17 10:00:39.932+00	\N	\N	(-84.88431115,10.4807056)	tilarán	50801	cr	t	-85.0018857	10.5574907	-84.7667366	10.4039205
P3DIaQ0kHm	2022-05-17 10:00:40.125+00	2022-05-17 10:00:40.226+00	\N	\N	(-84.751132,29.774942)	franklin county	fl	us	t	-85.246316	30.013931	-84.255948	29.535953
Q6gPy9yJtp	2022-05-17 10:00:40.601+00	2022-05-17 10:00:40.702+00	\N	\N	(21.061419700000002,52.2330014)	warsaw	masovian voivodeship	pl	t	20.8516882	52.3681531	21.2711512	52.0978497
IbvMrjNrbq	2022-05-17 10:00:40.98+00	2022-05-17 10:00:41.08+00	\N	\N	(-83.82954050000001,37.824926000000005)	powell county	ky	us	t	-84.027817	37.933746	-83.631264	37.716106
surG6vFRzN	2022-05-17 10:00:41.328+00	2022-05-17 10:00:41.427+00	\N	\N	(-79.0885093,43.05360745)	niagara falls	on	ca	t	-79.1772787	43.1479269	-78.9997399	42.959288
t0OSjFBgDm	2022-05-17 10:00:41.662+00	2022-05-17 10:00:41.761+00	\N	\N	(-121.4532215,36.50737275)	gonzales	ca	us	t	-121.484481	36.5270635	-121.421962	36.487682
qkH68G6rfA	2022-05-17 10:00:42.006+00	2022-05-17 10:00:42.106+00	\N	\N	(-121.98845785,48.818846699999995)	whatcom county	wa	us	t	-123.3222397	49.0024392	-120.654676	48.6352542
1gYXqyLtiO	2022-05-17 10:00:34.345+00	2022-06-01 04:16:19.88+00	\N	\N	(-115.96666535,34.8401198)	san bernardino county	ca	us	t	-117.8025491	35.8092552	-114.1307816	33.8709844
ee0jFv1wQK	2022-05-09 18:37:27.874+00	2022-05-09 18:37:27.973+00	\N	\N	(-121.890591,37.3361663)	san jose	ca	us	t	-122.050591	37.4961663	-121.730591	37.1761663
J1COlWvNkb	2022-05-09 18:40:18.574+00	2022-05-09 20:00:55.373+00	\N	\N	(-111.92093795,40.7766584)	salt lake city	ut	us	t	-112.1013916	40.8533905	-111.7404843	40.6999263
WZTf3rzO0l	2022-05-09 18:40:59.953+00	2022-05-09 20:00:29.417+00	\N	\N	(-110.9748477,32.2228765)	tucson	az	us	t	-111.1348477	32.3828765	-110.8148477	32.0628765
zqH76X1fUA	2022-05-09 18:40:18.502+00	2022-05-09 18:40:18.618+00	\N	\N	(-93.03753689999999,44.883867)	south st. paul	mn	us	t	-93.0654984	44.919538	-93.0095754	44.848196
xnQIp5URDN	2022-05-09 18:40:18.566+00	2022-05-09 18:40:18.671+00	\N	\N	(-74.43948950000001,40.621896)	north plainfield	nj	us	t	-74.465242	40.641576	-74.413737	40.602216
fPX4ajIx9Y	2022-05-09 18:40:18.567+00	2022-05-09 18:40:18.672+00	\N	\N	(-93.2616149,45.080044)	fridley	mn	us	t	-93.2960932	45.124601	-93.2271366	45.035487
dEOTi7RQaH	2022-05-09 18:40:18.569+00	2022-05-09 18:40:18.673+00	\N	\N	(-93.03753689999999,44.883867)	south st. paul	mn	us	t	-93.0654984	44.919538	-93.0095754	44.848196
NTGWwrvnIw	2022-05-09 18:40:18.57+00	2022-05-09 18:40:18.674+00	\N	\N	(-73.62083150000001,40.7029335)	hempstead	ny	us	t	-73.643173	40.721374	-73.59849	40.684493
q9YTFBp7HA	2022-05-09 18:40:18.61+00	2022-05-09 18:40:18.709+00	\N	\N	(-113.673463,42.618684)	rupert	id	us	t	-113.688885	42.63409	-113.658041	42.603278
B5vMDdGsGy	2022-05-09 18:40:18.81+00	2022-05-09 20:00:29.21+00	\N	\N	(-95.8780375,36.152301)	tulsa	ok	us	t	-96.074478	36.336505	-95.681597	35.968097
TWKfOoUKkW	2022-05-09 18:40:18.613+00	2022-05-09 18:40:18.717+00	\N	\N	(-97.14597555,33.6462595)	gainesville	tx	us	t	-97.2115991	33.714696	-97.080352	33.577823
ki4PneXR5R	2022-05-09 18:40:18.622+00	2022-05-09 18:40:18.722+00	\N	\N	(-103.1984935,34.453936)	clovis	nm	us	t	-103.262363	34.532174	-103.134624	34.375698
G5D8iYssXT	2022-05-09 18:40:59.886+00	2022-05-09 18:40:59.986+00	\N	\N	(-112.4449085,41.7733695)	howell	ut	us	t	-112.494884	41.824879	-112.394933	41.72186
iW0jHkxCz5	2022-05-09 18:41:00.104+00	2022-05-09 20:00:20.452+00	\N	\N	(-119.85085889999999,39.557930999999996)	reno	nv	us	t	-120.0023728	39.723436	-119.699345	39.392426
U49jSRWEcf	2022-05-09 18:40:18.628+00	2022-05-09 18:40:18.729+00	\N	\N	(-83.6017257,42.2172635)	ypsilanti township	mi	us	t	-83.6612556	42.262462	-83.5421958	42.172065
VMyrlmjncp	2022-05-09 18:40:18.871+00	2022-05-09 20:00:55.757+00	\N	\N	(-122.65438705,45.5427086)	portland	or	us	t	-122.8367489	45.6528812	-122.4720252	45.432536
FyE54c9KNK	2022-05-09 18:40:18.647+00	2022-05-09 18:40:18.748+00	\N	\N	(-93.2752922,44.77325515)	burnsville	mn	us	t	-93.329828	44.8290621	-93.2207564	44.7174482
TgFsbB45Oe	2022-05-09 18:40:18.668+00	2022-05-09 18:40:18.769+00	\N	\N	(-122.61954765,45.637696950000006)	vancouver	wa	us	t	-122.7745353	45.6980031	-122.46456	45.5773908
bIbFKQxavK	2022-05-09 18:40:18.67+00	2022-05-09 18:40:18.769+00	\N	\N	(-122.28207,37.7541245)	alameda	ca	us	t	-122.340281	37.800628	-122.223859	37.707621
wBOnO6rhqW	2022-05-09 18:40:18.677+00	2022-05-09 18:40:18.778+00	\N	\N	(-77.23075134999999,38.916506150000004)	tysons	va	us	t	-77.265258	38.9344653	-77.1962447	38.898547
GIRypA1SiB	2022-05-09 18:40:59.924+00	2022-05-09 20:00:58.529+00	\N	\N	(27.88517545,-26.09775585)	roodepoort	gt	za	t	27.8142109	-25.997732	27.95614	-26.1977797
p8cvIg0KHF	2022-05-09 18:40:18.706+00	2022-05-09 18:40:18.808+00	\N	\N	(-80.88125285000001,35.4732975)	cornelius	nc	us	t	-80.9465	35.507327	-80.8160057	35.439268
YztyzFgA2A	2022-05-09 20:00:55.652+00	2022-05-09 20:00:55.761+00	\N	\N	(-81.27511999999999,28.784108500000002)	sanford	fl	us	t	-81.347073	28.829248	-81.203167	28.738969
DgRQ0maXav	2022-05-09 18:40:18.792+00	2022-05-09 18:40:18.893+00	\N	\N	(-86.419963,36.972749500000006)	bowling green	ky	us	t	-86.533207	37.046652	-86.306719	36.898847
YU9TPGlFRy	2022-05-09 20:00:55.561+00	2022-05-09 20:00:55.688+00	\N	\N	(-117.4626887,34.1096243)	fontana	ca	us	t	-117.5243184	34.1858204	-117.401059	34.0334282
kEpbz1v1ZO	2022-05-09 18:40:18.816+00	2022-05-09 18:40:18.916+00	\N	\N	(-117.4587947,33.991923150000005)	jurupa valley	ca	us	t	-117.5503202	34.0342337	-117.3672692	33.9496126
pQeiCKsdX4	2022-05-09 18:40:18.624+00	2022-05-09 18:40:18.937+00	\N	\N	(-76.6204867,39.284635300000005)	baltimore	md	us	t	-76.7112977	39.3720378	-76.5296757	39.1972328
BFgdawfb0w	2022-05-09 18:40:18.85+00	2022-05-09 18:40:18.949+00	\N	\N	(-75.321684,39.741210800000005)	woolwich township	nj	us	t	-75.378347	39.7928055	-75.265021	39.6896161
cMYhCNoMN7	2022-05-09 18:40:18.627+00	2022-05-09 20:00:19.822+00	\N	\N	(-71.42314025,41.8171176)	providence	ri	us	t	-71.472667	41.8618007	-71.3736135	41.7724345
v7Y03F9lwE	2022-05-09 18:40:18.885+00	2022-05-09 18:40:18.984+00	\N	\N	(-93.2075802,45.10542975)	mounds view	mn	us	t	-93.2278384	45.1245495	-93.187322	45.08631
C5rjVBdoJn	2022-05-09 18:37:27.996+00	2022-05-09 20:00:55.91+00	\N	\N	(-73.97963545,40.696788749999996)	new york	ny	us	t	-74.25909	40.9161785	-73.7001809	40.477399
ZL9i8l3Fx9	2022-05-09 18:37:27.956+00	2022-05-17 07:17:08.538+00	\N	\N	(-117.10776394999999,32.82451135)	san diego	ca	us	t	-117.3098053	33.114249	-116.9057226	32.5347737
g1XOr24I3W	2022-05-09 18:40:59.906+00	2022-05-09 18:41:00.005+00	\N	\N	(-121.83489505,36.6257703)	seaside	ca	us	t	-121.8799085	36.6547441	-121.7898816	36.5967965
RfsD3GJ3Gz	2022-05-09 18:40:59.919+00	2022-05-09 18:41:00.018+00	\N	\N	(-112.18171835,41.7159913)	tremonton	ut	us	t	-112.2402978	41.7400816	-112.1231389	41.691901
jxamir34bT	2022-05-09 18:40:59.922+00	2022-05-09 18:41:00.021+00	\N	\N	(-82.2435585,36.335898)	elizabethton	tn	us	t	-82.32279	36.376684	-82.164327	36.295112
P4HcM6LOKM	2022-05-09 18:40:59.946+00	2022-05-09 18:41:00.045+00	\N	\N	(-74.02523500000001,40.9746985)	emerson	nj	us	t	-74.056979	40.987189	-73.993491	40.962208
CC2haMmsYA	2022-05-09 18:40:18.612+00	2022-05-09 20:00:29.205+00	\N	\N	(-93.26149305,44.9707)	minneapolis	mn	us	t	-93.3291271	45.05125	-93.193859	44.89015
rtFdx6jN4j	2022-05-09 18:40:59.957+00	2022-05-09 18:41:00.056+00	\N	\N	(-111.8845886,40.9292582)	centerville	ut	us	t	-111.915772	40.9547318	-111.8534052	40.9037846
MzithApaxl	2022-05-09 18:40:59.961+00	2022-05-09 18:41:00.061+00	\N	\N	(-111.8998315,40.7061548)	south salt lake	ut	us	t	-111.928402	40.7259806	-111.871261	40.686329
XbyP5I9NFS	2022-05-09 18:40:18.908+00	2022-05-09 20:00:55.871+00	\N	\N	(-96.73205684999999,32.818576300000004)	dallas	tx	us	t	-97.000482	33.0239366	-96.4636317	32.613216
0I9y7Rw3jY	2022-05-09 18:40:59.97+00	2022-05-09 18:41:00.069+00	\N	\N	(-82.29825170000001,34.784075)	mauldin	sc	us	t	-82.3336247	34.8182314	-82.2628787	34.7499186
lb1wP1ElWc	2022-05-09 18:41:00.049+00	2022-05-09 18:41:00.151+00	\N	\N	(-94.95580415,36.6975324)	afton	ok	us	t	-94.9841812	36.711824	-94.9274271	36.6832408
5JIiMD4myO	2022-05-09 18:40:59.995+00	2022-05-09 18:41:00.094+00	\N	\N	(-74.20487705,40.072143499999996)	lakewood	nj	us	t	-74.2586431	40.1203643	-74.151111	40.0239227
7v7jk77Xea	2022-05-09 18:41:00.011+00	2022-05-09 18:41:00.113+00	\N	\N	(-85.6374965,38.2498785)	st. matthews	ky	us	t	-85.668512	38.27221	-85.606481	38.227547
lWjdhCcvOX	2022-05-09 20:00:55.61+00	2022-05-09 20:00:55.725+00	\N	\N	(152.9414635,-26.318263)	noosa shire	qld	au	t	152.76299	-26.137121	153.119937	-26.499405
1v52Qy1fDP	2022-05-09 18:41:00.068+00	2022-05-09 18:41:00.168+00	\N	\N	(-111.84931845,40.5728335)	sandy	ut	us	t	-111.921621	40.618005	-111.7770159	40.527662
Aj13omkZ5D	2022-05-09 18:40:59.979+00	2022-05-09 18:41:00.148+00	\N	\N	(-87.9670141,43.057879850000006)	milwaukee	wi	us	t	-88.0710611	43.1949437	-87.8629671	42.920816
veANmBu0la	2022-05-09 18:41:00.058+00	2022-05-09 18:41:00.157+00	\N	\N	(-78.147087,33.9212365)	oak island	nc	us	t	-78.236873	33.941157	-78.057301	33.901316
IR5rex0WNx	2022-05-09 18:41:00.038+00	2022-05-09 18:41:00.16+00	\N	\N	(-85.6760822,38.18861955)	louisville	ky	us	t	-85.9470644	38.3801391	-85.4051	37.9971
vvqeDfNV49	2022-05-09 18:41:00.076+00	2022-05-09 18:41:00.176+00	\N	\N	(-94.408979,37.0849365)	duenweg	mo	us	t	-94.422859	37.101192	-94.395099	37.068681
IZV91ujb6d	2022-05-09 18:41:00.088+00	2022-05-09 18:41:00.187+00	\N	\N	(-72.00976170000001,42.48382025)	hubbardston	ma	us	t	-72.0996879	42.5466106	-71.9198355	42.4210299
lBs19pD3Tq	2022-05-09 18:40:18.683+00	2022-05-09 20:00:25.968+00	\N	\N	(-94.1485973,45.52141185)	saint cloud	mn	us	t	-94.261421	45.5903481	-94.0357736	45.4524756
d4BPncOUBi	2022-05-09 18:41:00.107+00	2022-05-09 18:41:00.206+00	\N	\N	(-72.2084058,42.4465722)	petersham	ma	us	t	-72.315879	42.5503426	-72.1009326	42.3428018
yFFxRznGVz	2022-05-09 18:41:00.125+00	2022-05-09 18:41:00.226+00	\N	\N	(-84.2021575,39.811336499999996)	dayton	oh	us	t	-84.311377	39.920823	-84.092938	39.70185
ixWYjtQdz5	2022-05-09 18:41:00.127+00	2022-05-09 18:41:00.227+00	\N	\N	(-122.45520744999999,47.2428954)	tacoma	wa	us	t	-122.562265	47.31898	-122.3481499	47.1668108
LoiNnGnKL3	2022-05-09 18:40:18.752+00	2022-05-09 20:00:55.852+00	\N	\N	(-95.4608972,29.82371055)	houston	tx	us	t	-95.9097419	30.1103506	-95.0120525	29.5370705
BkyRvzNH6F	2022-05-09 18:41:00.035+00	2022-05-09 18:41:00.136+00	\N	\N	(-80.14009544999999,25.8102415)	miami beach	fl	us	t	-80.1699989	25.872806	-80.110192	25.747677
TZ1aqgWSrD	2022-05-09 18:41:00.131+00	2022-05-09 18:41:00.23+00	\N	\N	(-96.6440175,35.774178)	stroud	ok	us	t	-96.69862	35.824093	-96.589415	35.724263
cpNndBVll4	2022-05-09 18:41:00.145+00	2022-05-09 18:41:00.244+00	\N	\N	(-90.56419349999999,38.2352815)	hillsboro	mo	us	t	-90.578904	38.257805	-90.549483	38.212758
bc93ffR4lE	2022-05-09 20:00:55.571+00	2022-05-09 20:00:55.689+00	\N	\N	(-73.67786100000001,42.7449345)	troy	ny	us	t	-73.706463	42.795791	-73.649259	42.694078
GVAApEPBmt	2022-05-09 18:41:00.165+00	2022-05-09 20:00:20.371+00	\N	\N	(-98.5180947,29.45860975)	san antonio	tx	us	t	-98.8131865	29.7309623	-98.2230029	29.1862572
jOMbJUXBA9	2022-05-17 10:00:49.057+00	2022-05-17 10:00:49.158+00	\N	\N	(-81.6988901,27.99642905)	winter haven	fl	us	t	-81.7701166	28.0922184	-81.6276636	27.9006397
cUGLshwIB6	2022-05-09 20:00:55.714+00	2022-05-09 20:00:55.818+00	\N	\N	(-93.203837,45.35526565)	east bethel	mn	us	t	-93.265932	45.4141763	-93.141742	45.296355
Om9XYjNzcG	2022-05-09 20:00:55.75+00	2022-05-09 20:00:55.851+00	\N	\N	(-89.07896894999999,17.150456849999998)	san ignacio town	cy	bz	t	-89.0920707	17.1664399	-89.0658672	17.1344738
qool5DHZqU	2022-05-09 20:00:55.649+00	2022-05-09 20:00:55.925+00	\N	\N	(-94.16568285,36.33444495)	rogers	ar	us	t	-94.2507421	36.4061009	-94.0806236	36.262789
DkyGsNkSuX	2022-05-09 20:47:59.833+00	2022-05-09 20:47:59.932+00	\N	\N	(-119.84889095,34.26151635)	santa barbara county	ca	us	t	-120.734382	35.114665	-118.9633999	33.4083677
4eYqZXJGS0	2022-05-09 21:39:46.959+00	2022-05-09 21:39:47.059+00	\N	\N	(-82.1568953,29.1773226)	ocala	fl	us	t	-82.2517933	29.233731	-82.0619973	29.1209142
WFaM37MvqN	2022-05-17 07:20:57.544+00	2022-05-17 07:20:57.643+00	\N	\N	(-86.4481325,35.8616835)	murfreesboro	tn	us	t	-86.570986	35.960638	-86.325279	35.762729
iBXrvoh2Qu	2022-05-17 10:00:42.401+00	2022-05-17 10:00:42.502+00	\N	\N	(-88.4513191,42.32431375)	mchenry county	il	us	t	-88.7059813	42.4950734	-88.1966569	42.1535541
dZX2mBM8F9	2022-05-17 10:00:42.791+00	2022-05-17 10:00:42.891+00	\N	\N	(-119.6402638,36.7463883)	fresno county	ca	us	t	-120.9192485	37.586101	-118.3612791	35.9066756
wARE7faFbS	2022-05-17 10:00:43.096+00	2022-05-17 10:00:43.197+00	\N	\N	(-97.70901615,30.6616703)	georgetown	tx	us	t	-97.8327917	30.7525362	-97.5852406	30.5708044
FpzmiHEpLM	2022-05-17 10:00:43.411+00	2022-05-17 10:00:43.512+00	\N	\N	(-82.0874431,29.2407383)	marion county	fl	us	t	-82.5359526	29.521678	-81.6389336	28.9597986
C10J8MSLkB	2022-05-17 10:00:43.725+00	2022-05-17 10:00:43.825+00	\N	\N	(174.82055450000001,-37.10336485)	franklin	auk	nz	t	174.2524638	-36.8422559	175.3886452	-37.3644738
vEcQmiZmoH	2022-05-17 10:00:44.123+00	2022-05-17 10:00:44.223+00	\N	\N	(-71.6122011,42.870655)	amherst	nh	us	t	-71.6664296	42.9434	-71.5579726	42.79791
sdczXvrbJW	2022-05-17 10:00:44.621+00	2022-05-17 10:00:44.721+00	\N	\N	(-87.0761265,41.4905055)	porter county	in	us	t	-87.222932	41.761368	-86.929321	41.219643
VclEt41dJz	2022-05-17 10:00:44.967+00	2022-05-17 10:00:45.066+00	\N	\N	(-84.30104424999999,39.355574)	mason	oh	us	t	-84.3493305	39.401613	-84.252758	39.309535
CqFUMEpl8K	2022-05-17 10:00:45.326+00	2022-05-17 10:00:45.426+00	\N	\N	(-82.05193080000001,26.893009499999998)	punta gorda	fl	us	t	-82.0978393	26.9493614	-82.0060223	26.8366576
edirARZlZL	2022-05-17 10:00:45.622+00	2022-05-17 10:00:45.721+00	\N	\N	(-83.0305393,42.5813015)	sterling heights	mi	us	t	-83.0914436	42.627811	-82.969635	42.534792
6isPZxSm8Z	2022-05-17 10:00:46.153+00	2022-05-17 10:00:46.253+00	\N	\N	(-84.1869685,33.792766)	dekalb county	ga	us	t	-84.350224	33.970866	-84.023713	33.614666
ggzUQRnSkA	2022-05-17 10:00:46.608+00	2022-05-17 10:00:46.708+00	\N	\N	(-76.8631675,42.390158)	schuyler county	ny	us	t	-77.107053	42.546791	-76.619282	42.233525
nGZmBjkDg0	2022-05-17 10:00:47.03+00	2022-05-17 10:00:47.131+00	\N	\N	(28.29638,-26.18447955)	city of ekurhuleni metropolitan municipality	gt	za	t	28.06561	-25.9033796	28.52715	-26.4655795
HeTxujclFs	2022-05-17 10:00:47.418+00	2022-05-17 10:00:47.517+00	\N	\N	(74.60568760000001,42.879635)	bishkek		kg	t	74.4936126	42.9718978	74.7177626	42.7873722
b1L2yZrF8Q	2022-05-17 10:00:47.788+00	2022-05-17 10:00:47.888+00	\N	\N	(25.596243899999997,45.6259881)	brasov		ro	t	25.5035642	45.752328	25.6889236	45.4996482
WA3DGUCToE	2022-05-17 10:00:48.141+00	2022-05-17 10:00:48.241+00	\N	\N	(-81.65364199999999,28.81057955)	lake county	fl	us	t	-81.957641	29.2767866	-81.349643	28.3443725
jWD1fcDySd	2022-05-17 10:00:48.579+00	2022-05-17 10:00:48.679+00	\N	\N	(-81.831555,41.312897)	strongsville	oh	us	t	-81.878053	41.35075	-81.785057	41.275044
ExOdOGxg7o	2022-05-17 10:00:49.402+00	2022-05-17 10:00:49.502+00	\N	\N	(-98.33269675,19.0723524)	san pedro cholula	pue	mx	t	-98.4043503	19.118687	-98.2610432	19.0260178
5mZb2ci33w	2022-05-17 10:00:49.977+00	2022-05-17 10:00:50.076+00	\N	\N	(-46.5956902,-23.682827699999997)	são paulo	sp	br	t	-46.8262906	-23.3577551	-46.3650898	-24.0079003
jlgBya848O	2022-05-17 10:00:50.332+00	2022-05-17 10:00:50.431+00	\N	\N	(-123.6348953,42.38965595)	josephine county	or	us	t	-124.0419826	42.7840844	-123.227808	41.9952275
pioumDcQK8	2022-05-17 10:00:50.686+00	2022-05-17 10:00:50.786+00	\N	\N	(-122.727652,37.78506265)	san francisco	ca	us	t	-123.173825	37.929811	-122.281479	37.6403143
OeKIXtpsdP	2022-05-17 10:00:50.966+00	2022-05-17 10:00:51.066+00	\N	\N	(-87.7407472,42.108775550000004)	winnetka	il	us	t	-87.7707407	42.1283745	-87.7107537	42.0891766
Oe5Dj4EudU	2022-05-17 10:00:51.423+00	2022-05-17 10:00:51.522+00	\N	\N	(130.65471915,32.820084)	kumamoto	860-8601	jp	t	130.4802732	32.979857	130.8291651	32.660311
95YwXZpmvj	2022-05-17 10:00:51.829+00	2022-05-17 10:00:51.929+00	\N	\N	(-77.17246825000001,38.27144225000001)	king george county	va	us	t	-77.3475667	38.4009021	-76.9973698	38.1419824
hA3vt1GgLD	2022-05-17 10:00:52.153+00	2022-05-17 10:00:52.253+00	\N	\N	(27.797005,-26.609135000000002)	emfuleni local municipality	gt	za	t	27.56909	-26.41898	28.02492	-26.79929
Xvpu3z2VqY	2022-05-17 10:00:52.506+00	2022-05-17 10:00:52.607+00	\N	\N	(-74.99034549999999,39.818124499999996)	lindenwold	nj	us	t	-75.027981	39.836523	-74.95271	39.799726
jDTI3cjKCF	2022-05-17 10:00:52.837+00	2022-05-17 10:00:52.938+00	\N	\N	(28.0760224,45.500445600000006)	galați		ro	t	27.9433558	45.6103724	28.208689	45.3905188
Q0fs8lMZKe	2022-05-17 10:00:53.33+00	2022-05-17 10:00:53.429+00	\N	\N	(-122.73021335,46.11843115)	cowlitz county	wa	us	t	-123.220474	46.386227	-122.2399527	45.8506353
WBDpuIpA5L	2022-05-17 10:00:53.677+00	2022-05-17 10:00:53.776+00	\N	\N	(-75.23694355,40.678697400000004)	easton	pa	us	t	-75.2837405	40.7166598	-75.1901466	40.640735
dUDgsWHC8n	2022-05-17 10:00:54.016+00	2022-05-17 10:00:54.117+00	\N	\N	(-83.76460315,43.0018647)	flint township	mi	us	t	-83.813085	43.0462243	-83.7161213	42.9575051
f4MZJp63uV	2022-05-17 10:00:54.36+00	2022-05-17 10:00:54.46+00	\N	\N	(-81.25975535,27.9952555)	osceola county	fl	us	t	-81.6570871	28.348521	-80.8624236	27.64199
Csih6HDSJu	2022-05-17 10:00:54.694+00	2022-05-17 10:00:54.794+00	\N	\N	(130.7821025,-11.552900999999999)	tiwi islands region	tiwi islands region	au	t	130.02052	-11.16546	131.543685	-11.940342
lnTVyJKGvo	2022-05-17 10:00:55.055+00	2022-05-17 10:00:55.155+00	\N	\N	(-112.0210621,41.1000144)	clearfield	ut	us	t	-112.0549518	41.1253604	-111.9871724	41.0746684
6U9gHP3im9	2022-05-17 10:00:55.598+00	2022-05-17 10:00:55.698+00	\N	\N	(29.0630386,40.9811442)	kadıköy	marmara region	tr	t	29.0148423	41.0123228	29.1112349	40.9499656
GZvAh7UQZx	2022-05-17 10:00:56.077+00	2022-05-17 10:00:56.177+00	\N	\N	(-90.58937845,41.54046235)	davenport	ia	us	t	-90.6879323	41.6202927	-90.4908246	41.460632
VyEV6kq84O	2022-05-17 10:00:56.468+00	2022-05-17 10:00:56.568+00	\N	\N	(-66.050111,18.3974229)	río piedras	pr	us	t	-66.210111	18.5574229	-65.890111	18.2374229
zaqXBqWj9q	2022-05-17 10:00:56.882+00	2022-05-17 10:00:56.982+00	\N	\N	(-87.2043049,30.4530143)	pensacola	fl	us	t	-87.2588885	30.5104858	-87.1497213	30.3955428
JPB13pzGus	2022-05-17 10:00:57.361+00	2022-05-17 10:00:57.461+00	\N	\N	(121.06175300000001,14.68289135)	quezon city	metro manila	ph	t	120.9896736	14.7764137	121.1338324	14.589369
W01vJppJI1	2022-05-17 10:00:57.641+00	2022-05-17 10:00:57.74+00	\N	\N	(-88.09583985,41.6362853)	romeoville	il	us	t	-88.1631089	41.6798828	-88.0285708	41.5926878
jHx04H5jer	2022-05-17 10:00:57.944+00	2022-05-17 10:00:58.044+00	\N	\N	(-71.0169135,43.12701065)	lee	nh	us	t	-71.0731001	43.1724038	-70.9607269	43.0816175
EEIb0mRbhj	2022-05-17 10:00:58.232+00	2022-05-17 10:00:58.331+00	\N	\N	(153.1135293,-30.2962407)	coffs harbour	nsw	au	t	152.9535293	-30.1362407	153.2735293	-30.4562407
51a2duNifu	2022-05-17 10:00:58.614+00	2022-05-17 10:00:58.714+00	\N	\N	(-78.5368344,37.563257899999996)	buckingham county	va	us	t	-78.8339468	37.7969628	-78.239722	37.329553
BaVi0ifXoB	2022-05-17 10:00:58.998+00	2022-05-17 10:00:59.098+00	\N	\N	(-88.10240725,41.683294000000004)	bolingbrook	il	us	t	-88.1796545	41.7358214	-88.02516	41.6307666
fdyPLbhkUt	2022-05-09 18:41:00.143+00	2022-05-09 18:41:00.242+00	\N	\N	(-89.9727275,35.1290159)	memphis	tn	us	t	-90.308366	35.263879	-89.637089	34.9941528
KGLqDojUll	2022-05-09 18:40:59.899+00	2022-05-09 20:00:55.66+00	\N	\N	(-93.81378004999999,32.461279000000005)	shreveport	la	us	t	-93.9478451	32.5898665	-93.679715	32.3326915
ZMrVvcCDDy	2022-05-09 20:00:55.573+00	2022-05-09 20:00:55.69+00	\N	\N	(-71.1853442,42.73187455)	methuen	ma	us	t	-71.2551324	42.7943296	-71.115556	42.6694195
xnO0ILB4nX	2022-05-09 20:00:55.767+00	2022-05-09 20:00:55.868+00	\N	\N	(-0.81667085,51.8137021)	aylesbury	eng	gb	t	-0.8606549	51.8326055	-0.7726868	51.7947987
tTzI07HvzO	2022-05-09 20:00:55.809+00	2022-05-09 20:00:55.908+00	\N	\N	(-84.3070201,42.27405575)	leoni township	mi	us	t	-84.364935	42.3517413	-84.2491052	42.1963702
32V6X22aAb	2022-05-09 20:00:55.829+00	2022-05-09 20:00:55.929+00	\N	\N	(-0.45541565,52.02885825)	maulden	eng	gb	t	-0.4865315	52.0484001	-0.4242998	52.0093164
HW3Z0KA8s2	2022-05-09 20:48:41.785+00	2022-05-09 20:48:41.886+00	\N	\N	(-84.17366200000001,33.8053035)	stone mountain	ga	us	t	-84.186566	33.820667	-84.160758	33.78994
wkPT3kkV0Q	2022-05-09 20:48:54.998+00	2022-05-09 20:48:55.098+00	\N	\N	(-88.2445305,42.52231985)	twin lakes	wi	us	t	-88.294984	42.549841	-88.194077	42.4947987
iHdpFstn8K	2022-05-09 20:49:05.693+00	2022-05-09 20:49:05.793+00	\N	\N	(30.0483829,-29.4424749)	umgeni local municipality	nl	za	t	29.6899159	-29.2451099	30.4068499	-29.6398399
Nfn4aTUxIx	2022-05-09 21:40:00.647+00	2022-05-09 21:40:00.747+00	\N	\N	(-4.248878700000001,55.860982500000006)	glasgow	sct	gb	t	-4.4088787	56.0209825	-4.0888787	55.7009825
ZpQlmPPf64	2022-05-17 07:24:19.261+00	2022-05-17 07:24:19.36+00	\N	\N	(-88.71211500000001,44.1101325)	winneconne	wi	us	t	-88.73363	44.122783	-88.6906	44.097482
lPJD5LVDtW	2022-05-17 07:24:26.141+00	2022-05-17 07:24:26.242+00	\N	\N	(-81.68729529999999,29.983285799999997)	green cove springs	fl	us	t	-81.7314763	30.0130643	-81.6431143	29.9535073
yZpDPAL08A	2022-05-17 10:00:59.307+00	2022-05-17 10:00:59.408+00	\N	\N	(-119.61890410000001,49.86668305)	west kelowna	bc	ca	t	-119.7266019	49.9452394	-119.5112063	49.7881267
Vcr978Ep7i	2022-05-17 10:00:59.647+00	2022-05-17 10:00:59.747+00	\N	\N	(-80.12905495000001,26.742298249999997)	west palm beach	fl	us	t	-80.214633	26.8401733	-80.0434769	26.6444232
PTo9pbfAtC	2022-05-17 10:01:00.013+00	2022-05-17 10:01:00.112+00	\N	\N	(-119.5656831,49.4891808)	penticton	bc	ca	t	-119.6166799	49.5559042	-119.5146863	49.4224574
CAsHo2USxt	2022-05-17 10:01:00.334+00	2022-05-17 10:01:00.435+00	\N	\N	(-82.34841664999999,37.470751)	pike county	ky	us	t	-82.732292	37.745384	-81.9645413	37.196118
fBA3sAmC6R	2022-05-17 10:01:00.697+00	2022-05-17 10:01:00.797+00	\N	\N	(147.138713,-41.4307185)	launceston	tas	au	t	146.972181	-41.334565	147.305245	-41.526872
kpo3xFYnbj	2022-05-17 10:01:00.962+00	2022-05-17 10:01:01.063+00	\N	\N	(-78.3108072,33.910307599999996)	holden beach	nc	us	t	-78.3843078	33.9207009	-78.2373066	33.8999143
Av05ECmgGB	2022-05-17 10:01:01.312+00	2022-05-17 10:01:01.412+00	\N	\N	(-83.69074,32.806758599999995)	macon	ga	us	t	-83.89205	32.9528742	-83.48943	32.660643
OUTcE6DCAz	2022-05-17 10:01:01.609+00	2022-05-17 10:01:01.709+00	\N	\N	(-84.1796995,42.9944985)	owosso	mi	us	t	-84.211327	43.017222	-84.148072	42.971775
J8yucg1hPk	2022-05-17 10:01:01.913+00	2022-05-17 10:01:02.013+00	\N	\N	(-87.7165034,30.723335249999998)	baldwin county	al	us	t	-88.0614271	31.3032945	-87.3715797	30.143376
Oe35z6hWvc	2022-05-17 10:01:02.288+00	2022-05-17 10:01:02.388+00	\N	\N	(-78.6146439,35.304395400000004)	dunn	nc	us	t	-78.6533412	35.3397118	-78.5759466	35.269079
anFMNdc0xL	2022-05-17 10:01:02.64+00	2022-05-17 10:01:02.74+00	\N	\N	(-106.67676305,35.082645049999996)	albuquerque	nm	us	t	-106.8821501	35.218203	-106.471376	34.9470871
22mP4fdoG5	2022-05-17 10:01:03.127+00	2022-05-17 10:01:03.228+00	\N	\N	(-9.622706449999999,52.4582469)	county kerry	listowel municipal district	ie	t	-9.9479416	52.6024543	-9.2974713	52.3140395
HL98B7aB4Y	2022-05-17 10:01:03.543+00	2022-05-17 10:01:03.644+00	\N	\N	(121.89043525,31.0722684)	pudong	shanghai	cn	t	121.4525228	31.4167763	122.3283477	30.7277605
gHUIDzuxq1	2022-05-17 10:01:03.925+00	2022-05-17 10:01:04.026+00	\N	\N	(-117.3381876,33.21631705)	oceanside	ca	us	t	-117.4398002	33.3000686	-117.236575	33.1325655
tKAvsNcg80	2022-05-17 10:01:04.308+00	2022-05-17 10:01:04.408+00	\N	\N	(-108.0573608,34.9633258)	cibola county	nm	us	t	-109.0461093	35.348866	-107.0686123	34.5777856
73MChNJ1v1	2022-05-17 10:01:04.639+00	2022-05-17 10:01:04.738+00	\N	\N	(-82.85210950000001,41.274801)	bellevue	oh	us	t	-82.888534	41.295715	-82.815685	41.253887
3bE76y005B	2022-05-17 10:01:05.026+00	2022-05-17 10:01:05.126+00	\N	\N	(-111.3260805,32.98366715)	pinal county	az	us	t	-112.203736	33.466104	-110.448425	32.5012303
1TQIk4DvwD	2022-05-17 10:01:05.539+00	2022-05-17 10:01:05.639+00	\N	\N	(-0.9906823499999999,50.84045155)	havant	eng	gb	t	-1.054899	50.9096587	-0.9264657	50.7712444
mSNDtXN7BJ	2022-05-17 10:01:05.933+00	2022-05-17 10:01:06.034+00	\N	\N	(4.30374405,52.074942300000004)	the hague	south holland	nl	t	4.1849984	52.1350362	4.4224897	52.0148484
nXRmbqIfin	2022-05-17 10:01:06.331+00	2022-05-17 10:01:06.43+00	\N	\N	(-84.7444332,42.7574985)	grand ledge	mi	us	t	-84.769082	42.781121	-84.7197844	42.733876
J2e1fm88Qg	2022-05-17 10:01:06.871+00	2022-05-17 10:01:06.971+00	\N	\N	(-85.88042485,38.94561455)	seymour	in	us	t	-85.9262347	38.982115	-85.834615	38.9091141
xYvptVFQc7	2022-05-17 10:01:07.176+00	2022-05-17 10:01:07.276+00	\N	\N	(-121.7723722,37.68038405)	livermore	ca	us	t	-121.8481011	37.732196	-121.6966433	37.6285721
QXCaNEaBJp	2022-05-17 10:01:07.569+00	2022-05-17 10:01:07.669+00	\N	\N	(-76.75344225,18.05402435)	saint andrew		jm	t	-76.8895715	18.1798348	-76.617313	17.9282139
JUBlg4Oq0q	2022-05-17 10:01:08.034+00	2022-05-17 10:01:08.133+00	\N	\N	(-75.6900574,45.4211435)	ottawa	on	ca	t	-75.8500574	45.5811435	-75.5300574	45.2611435
ENv4Fjg2MR	2022-05-17 10:01:08.355+00	2022-05-17 10:01:08.454+00	\N	\N	(-73.99193615,41.64014)	town of marlborough	ny	us	t	-74.0369903	41.698171	-73.946882	41.582109
d2f5ydaTPl	2022-05-17 10:01:08.75+00	2022-05-17 10:01:08.85+00	\N	\N	(-122.65872475,48.116541549999994)	island county	wa	us	t	-122.9889865	48.4156353	-122.328463	47.8174478
SLYdDuaJjG	2022-05-17 10:01:09.14+00	2022-05-17 10:01:09.241+00	\N	\N	(-113.5632814,37.10479755)	st. george	ut	us	t	-113.6497557	37.2095922	-113.4768071	37.0000029
E6vQa2qLgB	2022-05-17 10:01:09.466+00	2022-05-17 10:01:09.566+00	\N	\N	(-84.3911308,42.190776)	vandercook lake	mi	us	t	-84.4180052	42.213792	-84.3642564	42.16776
FGDCYXmksY	2022-05-17 10:01:09.79+00	2022-05-17 10:01:09.891+00	\N	\N	(-85.77181949999999,43.553921900000006)	white cloud	mi	us	t	-85.7920274	43.5613285	-85.7516116	43.5465153
FcMaSnFufh	2022-05-17 10:01:10.116+00	2022-05-17 10:01:10.216+00	\N	\N	(-88.3898235,43.072877500000004)	delafield	wi	us	t	-88.43006	43.1061523	-88.349587	43.0396027
bSas80uuRW	2022-05-17 10:01:10.514+00	2022-05-17 10:01:10.613+00	\N	\N	(26.215496,-29.116395)	bloemfontein	fs	za	t	26.055496	-28.956395	26.375496	-29.276395
zqavWkdTi8	2022-05-17 10:01:10.935+00	2022-05-17 10:01:11.035+00	\N	\N	(21.239435,-33.61648)	kannaland local municipality	wc	za	t	20.50315	-33.36496	21.97572	-33.868
7xDRRLITTW	2022-05-17 10:01:11.274+00	2022-05-17 10:01:11.373+00	\N	\N	(-121.243709,36.32405)	greenfield	ca	us	t	-121.260665	36.339523	-121.226753	36.308577
ecAE3p0mZd	2022-05-17 10:01:11.606+00	2022-05-17 10:01:11.705+00	\N	\N	(9.56614875,49.8582243)	marktheidenfeld	bavaria	de	t	9.4994664	49.9128552	9.6328311	49.8035934
Ieh3Lq4wAS	2022-05-17 10:01:12.062+00	2022-05-17 10:01:12.163+00	\N	\N	(-76.30031985,40.03997225)	lancaster	pa	us	t	-76.3465478	40.0730345	-76.2540919	40.00691
aHhnGAkgVs	2022-05-17 10:01:12.443+00	2022-05-17 10:01:12.542+00	\N	\N	(-111.29394450000001,45.33474085)	gallatin county	mt	us	t	-111.80538	46.193325	-110.782509	44.4761567
BNJGHBNs9l	2022-05-17 10:01:12.853+00	2022-05-17 10:01:12.952+00	\N	\N	(-82.968266,40.6362995)	caledonia	oh	us	t	-82.97244	40.641684	-82.964092	40.630915
LUSsG7teGe	2022-05-17 10:01:13.318+00	2022-05-17 10:01:13.418+00	\N	\N	(-79.62663235,44.0124492)	king	on	ca	t	-79.7755033	44.1504955	-79.4777614	43.8744029
Gv7p4sTnQL	2022-05-17 10:01:13.712+00	2022-05-17 10:01:13.812+00	\N	\N	(72.9272881,20.6067767)	valsad	gj	in	t	72.7672881	20.7667767	73.0872881	20.4467767
JHhgcVZjQz	2022-05-17 10:01:14.023+00	2022-05-17 10:01:14.124+00	\N	\N	(-85.96597750000001,37.138431)	cave city	ky	us	t	-85.997742	37.156448	-85.934213	37.120414
tUe7n3WS0M	2022-05-17 10:01:14.479+00	2022-05-17 10:01:14.579+00	\N	\N	(-106.66433225,52.15046955)	saskatoon	sk	ca	t	-106.8249655	52.2311425	-106.503699	52.0697966
c5dv73wHOS	2022-05-17 10:01:14.837+00	2022-05-17 10:01:14.937+00	\N	\N	(-71.6613964,41.693131199999996)	coventry	ri	us	t	-71.789703	41.730208	-71.5330898	41.6560544
zK2Tl7ykJ3	2022-05-17 10:01:15.163+00	2022-05-17 10:01:15.264+00	\N	\N	(27.32405,-25.702064999999997)	rustenburg local municipality	north west	za	t	27.00158	-25.28663	27.64652	-26.1175
9j8rfANmyh	2022-05-09 18:41:00.118+00	2022-05-09 18:41:00.217+00	\N	\N	(-94.01647,37.8745105)	el dorado springs	mo	us	t	-94.040044	37.897428	-93.992896	37.851593
yZIxZ3jOFA	2022-05-09 18:41:00.146+00	2022-05-09 18:41:00.246+00	\N	\N	(-75.3734274,39.96415519999999)	marple township	pa	us	t	-75.414139	39.997989	-75.3327158	39.9303214
Y0an1VUAvB	2022-05-09 18:41:00.233+00	2022-05-09 18:41:00.332+00	\N	\N	(78.173108,30.13579625)	rishikesh	ut	in	t	78.036232	30.308478	78.309984	29.9631145
gZQYQXcKd8	2022-05-09 18:41:00.266+00	2022-05-09 18:41:00.365+00	\N	\N	(-77.3490615,38.955582)	reston	va	us	t	-77.393259	39.002923	-77.304864	38.908241
viBijU1kNB	2022-05-09 18:41:00.321+00	2022-05-09 18:41:00.42+00	\N	\N	(-73.53773975,46.386074199999996)	saint-damien	qc	ca	t	-73.6816656	46.4899745	-73.3938139	46.2821739
p14oh2qQM5	2022-05-09 18:41:00.337+00	2022-05-09 18:41:00.437+00	\N	\N	(-71.167426,42.4168484)	arlington	ma	us	t	-71.2026422	42.4362876	-71.1322098	42.3974092
SjFxXi8Cg8	2022-05-09 18:41:00.411+00	2022-05-09 18:41:00.51+00	\N	\N	(-95.61003500000001,33.1414155)	sulphur springs	tx	us	t	-95.664651	33.190797	-95.555419	33.092034
o8QYfa22DO	2022-05-09 18:41:00.179+00	2022-05-09 18:41:00.556+00	\N	\N	(5.2626817,52.11486884999999)	zeist	ut	nl	t	5.1927521	52.1712509	5.3326113	52.0584868
XN8AxjtRI6	2022-05-09 18:41:00.459+00	2022-05-09 18:41:00.559+00	\N	\N	(-78.8733584,43.93974695)	oshawa	on	ca	t	-78.9587724	44.0474286	-78.7879444	43.8320653
5eWZ8LlV6X	2022-05-09 18:41:00.483+00	2022-05-09 18:41:00.583+00	\N	\N	(-78.48500405,38.04004795)	charlottesville	va	us	t	-78.5237084	38.0705032	-78.4462997	38.0095927
N78AmOH3sh	2022-05-09 18:41:00.524+00	2022-05-09 18:41:00.624+00	\N	\N	(74.60924829999999,30.9611784)	firozpur	pb	in	t	74.4492483	31.1211784	74.7692483	30.8011784
zlMY5e7NuF	2022-05-09 18:41:00.536+00	2022-05-09 18:41:00.635+00	\N	\N	(-97.677424,30.53103375)	round rock	tx	us	t	-97.7648422	30.5937774	-97.5900058	30.4682901
De3lyWuMuS	2022-05-09 18:41:00.544+00	2022-05-09 18:41:00.643+00	\N	\N	(76.93814265,28.370736450000003)	gurugram	hr	in	t	76.6510198	28.5409048	77.2252655	28.2005681
cf8A6NDIFJ	2022-05-09 20:00:55.587+00	2022-05-09 20:00:55.692+00	\N	\N	(-122.1557545,48.17429435)	arlington	wa	us	t	-122.204007	48.203799	-122.107502	48.1447897
hiveiIpro7	2022-05-09 20:00:55.615+00	2022-05-09 20:00:55.726+00	\N	\N	(-84.1538925,39.632234499999996)	centerville	oh	us	t	-84.208693	39.673849	-84.099092	39.59062
gALSKFiILD	2022-05-09 20:52:42.837+00	2022-05-09 20:52:42.936+00	\N	\N	(-117.31839310000001,33.6876327)	lake elsinore	ca	us	t	-117.4200034	33.7567838	-117.2167828	33.6184816
325aH2YEaw	2022-05-09 20:53:16.944+00	2022-05-09 20:53:17.045+00	\N	\N	(-78.87109530000001,38.43964745)	harrisonburg	va	us	t	-78.917871	38.4895289	-78.8243196	38.389766
V4lhzo6PoB	2022-05-09 20:53:25.526+00	2022-05-09 20:53:25.626+00	\N	\N	(-81.2502104,33.9255009)	lexington county	sc	us	t	-81.5751588	34.1974155	-80.925262	33.6535863
SRGfH6rLiO	2022-05-09 21:41:30.327+00	2022-05-09 21:41:30.427+00	\N	\N	(-80.243458,36.107355999999996)	winston-salem	nc	us	t	-80.385947	36.21816	-80.100969	35.996552
3dpTIWzQ63	2022-05-17 07:24:43.83+00	2022-05-17 07:24:43.93+00	\N	\N	(24.845934999999997,-33.912375)	kouga local municipality	ec	za	t	24.44495	-33.61089	25.24692	-34.21386
JR6JzDfgBf	2022-05-17 07:24:48.48+00	2022-05-17 07:24:48.579+00	\N	\N	(-81.2233607,28.7448677)	seminole county	fl	us	t	-81.4597364	28.879227	-80.986985	28.6105084
I9TWHdH7ZK	2022-05-17 10:01:15.561+00	2022-05-17 10:01:15.661+00	\N	\N	(-79.33296644999999,33.4374028)	georgetown county	sc	us	t	-79.681114	33.780167	-78.9848189	33.0946386
q3qMJNMVRL	2022-05-17 10:01:16.028+00	2022-05-17 10:01:16.127+00	\N	\N	(-95.46340335,30.32830195)	montgomery county	tx	us	t	-95.8301579	30.6304191	-95.0966488	30.0261848
qNjqFWK0FZ	2022-05-17 10:01:16.404+00	2022-05-17 10:01:16.504+00	\N	\N	(-93.62463355,44.75991645)	carver	mn	us	t	-93.6550541	44.7869627	-93.594213	44.7328702
CkIAqyHHWa	2022-05-17 10:01:16.852+00	2022-05-17 10:01:16.952+00	\N	\N	(-76.26079849999999,36.8952611)	norfolk	va	us	t	-76.3448722	36.9697231	-76.1767248	36.8207991
vvjvC2v013	2022-05-17 10:01:17.261+00	2022-05-17 10:01:17.358+00	\N	\N	(-78.61604745,35.68765845)	garner	nc	us	t	-78.7005239	35.7313099	-78.531571	35.644007
9578KD6PV1	2022-05-17 10:01:17.637+00	2022-05-17 10:01:17.737+00	\N	\N	(-122.1927858,47.8128445)	north creek	wa	us	t	-122.253891	47.849461	-122.1316806	47.776228
wHVTR9lQ7C	2022-05-17 10:01:18.087+00	2022-05-17 10:01:18.187+00	\N	\N	(-123.40297975,48.6531267)	sidney	bc	ca	t	-123.4178094	48.672175	-123.3881501	48.6340784
fuCXtzCkqn	2022-05-17 10:01:18.41+00	2022-05-17 10:01:18.51+00	\N	\N	(-114.6276157,32.692658800000004)	yuma	az	us	t	-114.7876157	32.8526588	-114.4676157	32.5326588
aHUeMByGLY	2022-05-17 10:01:18.731+00	2022-05-17 10:01:18.83+00	\N	\N	(-121.99870419999999,37.97328885)	concord	ca	us	t	-122.0645819	38.022717	-121.9328265	37.9238607
4CVojBu301	2022-05-17 10:01:19.028+00	2022-05-17 10:01:19.128+00	\N	\N	(-85.4751566,44.80162705)	acme township	mi	us	t	-85.5260525	44.8596715	-85.4242607	44.7435826
lNrQwPqhcY	2022-05-17 10:01:30.871+00	2022-05-17 10:01:30.971+00	\N	\N	(-113.2092047,53.715885099999994)	fort saskatchewan	ab	ca	t	-113.2942696	53.7742587	-113.1241398	53.6575115
nZFYqKeHcT	2022-05-17 10:01:31.187+00	2022-05-17 10:01:31.288+00	\N	\N	(-76.3972095,42.814021)	town of niles	ny	us	t	-76.515396	42.849387	-76.279023	42.778655
auVWfZXv16	2022-05-17 10:01:31.632+00	2022-05-17 10:01:31.732+00	\N	\N	(-159.31506050000002,22.14600685)	anahola	hi	us	t	-159.338707	22.164537	-159.291414	22.1274767
2IGrHg9r4a	2022-05-17 10:01:31.981+00	2022-05-17 10:01:32.081+00	\N	\N	(-76.30297350000001,43.0557255)	town of camillus	ny	us	t	-76.377175	43.100924	-76.228772	43.010527
JCnlSfKlFy	2022-05-17 10:01:32.377+00	2022-05-17 10:01:32.477+00	\N	\N	(-77.45271654999999,37.7731154)	hanover county	va	us	t	-77.7973069	38.0081575	-77.1081262	37.5380733
wWvJwEvtI7	2022-05-17 10:01:32.704+00	2022-05-17 10:01:32.803+00	\N	\N	(-86.1566542,41.6773185)	mishawaka	in	us	t	-86.2158454	41.73066	-86.097463	41.623977
YSfmYF8NEW	2022-05-17 10:01:33.043+00	2022-05-17 10:01:33.142+00	\N	\N	(-80.6706739,28.1177741)	melbourne	fl	us	t	-80.7482559	28.200533	-80.5930919	28.0350152
pDHFbyznBl	2022-05-17 10:01:33.441+00	2022-05-17 10:01:33.54+00	\N	\N	(-93.29585929999999,37.1828864)	springfield	mo	us	t	-93.4132228	37.2769839	-93.1784958	37.0887889
rzjlceOrBS	2022-05-17 10:01:33.838+00	2022-05-17 10:01:33.937+00	\N	\N	(-77.2821084,38.9418881)	wolf trap	va	us	t	-77.3172848	38.977704	-77.246932	38.9060722
09p1AbARyf	2022-05-17 10:01:34.35+00	2022-05-17 10:01:34.45+00	\N	\N	(-75.62521155,38.3882338)	wicomico county	md	us	t	-75.9437322	38.5606646	-75.3066909	38.215803
VDPOAexMt9	2022-05-17 10:01:35.174+00	2022-05-17 10:01:35.274+00	\N	\N	(-86.768965,39.283657500000004)	spencer	in	us	t	-86.787827	39.293401	-86.750103	39.273914
XtRnfL0kGR	2022-05-17 10:01:35.491+00	2022-05-17 10:01:35.59+00	\N	\N	(-98.218283,32.215030999999996)	stephenville	tx	us	t	-98.263457	32.241177	-98.173109	32.188885
EVxcTj8xDn	2022-05-17 10:01:35.823+00	2022-05-17 10:01:35.924+00	\N	\N	(-73.921368,41.4992315)	town of fishkill	ny	us	t	-74.000108	41.559558	-73.842628	41.438905
0LaWBieeM5	2022-05-17 10:01:36.141+00	2022-05-17 10:01:36.24+00	\N	\N	(-93.16525865,42.01474425)	state center	ia	us	t	-93.1749951	42.0221463	-93.1555222	42.0073422
cTsu7kYAz0	2022-05-17 10:01:36.552+00	2022-05-17 10:01:36.653+00	\N	\N	(-78.748385,42.908495)	town of cheektowaga	ny	us	t	-78.799896	42.953478	-78.696874	42.863512
SW1RjXUJdD	2022-05-17 10:01:36.913+00	2022-05-17 10:01:37.013+00	\N	\N	(-70.84365930000001,42.5141282)	salem	ma	us	t	-70.9499444	42.5521402	-70.7373742	42.4761162
VzrAEA4TGX	2022-05-17 10:01:37.347+00	2022-05-17 10:01:37.447+00	\N	\N	(-114.97081800000001,35.9279907)	clark county	nv	us	t	-115.8953504	36.854092	-114.0462856	35.0018894
toVF42GIOi	2022-05-17 10:01:37.67+00	2022-05-17 10:01:37.77+00	\N	\N	(-124.053224,40.845421)	arcata	ca	us	t	-124.118951	40.910476	-123.987497	40.780366
oSeXQ47ubq	2022-05-17 10:01:38.01+00	2022-05-17 10:01:38.11+00	\N	\N	(-82.4815025,28.324384549999998)	pasco county	fl	us	t	-82.908311	28.478837	-82.054694	28.1699321
IOLt2B0vtK	2022-05-17 10:01:38.381+00	2022-05-17 10:01:38.48+00	\N	\N	(-75.00385990000001,40.36519)	solebury township	pa	us	t	-75.0805912	40.4111666	-74.9271286	40.3192134
uUjVI9qnBD	2022-05-17 10:01:38.705+00	2022-05-17 10:01:38.804+00	\N	\N	(-71.36345305,42.3612682)	wayland	ma	us	t	-71.3981524	42.4127147	-71.3287537	42.3098217
F5Kid5HsMA	2022-05-17 10:01:38.997+00	2022-05-17 10:01:39.097+00	\N	\N	(-73.0683675,43.1656804)	manchester	vt	us	t	-73.1350368	43.2147212	-73.0016982	43.1166396
f4Dzlup3FV	2022-05-17 10:01:39.356+00	2022-05-17 10:01:39.456+00	\N	\N	(-83.06580564999999,43.98046575)	hume township	mi	us	t	-83.1265026	44.0256117	-83.0051087	43.9353198
snPTujCzXV	2022-05-17 10:01:39.673+00	2022-05-17 10:01:39.772+00	\N	\N	(55.32619205,25.271128)	deira	dubai	ae	t	55.2921277	25.3075803	55.3602564	25.2346757
DQGuAtZHBZ	2022-05-17 10:01:40.013+00	2022-05-17 10:01:40.114+00	\N	\N	(-104.5308155,33.369912299999996)	roswell	nm	us	t	-104.586274	33.459725	-104.475357	33.2800996
a8CHB61eEx	2022-05-09 18:41:00.159+00	2022-05-09 18:41:00.259+00	\N	\N	(-78.88354255,36.0016801)	durham	nc	us	t	-79.0074981	36.1370099	-78.759587	35.8663503
HoU9IuTS1r	2022-05-09 18:45:41.278+00	2022-05-09 18:45:41.377+00	\N	\N	(-119.018687,35.320977)	bakersfield	ca	us	t	-119.265033	35.447975	-118.772341	35.193979
DVECPv7FWP	2022-05-09 18:46:39.34+00	2022-05-09 18:46:39.439+00	\N	\N	(-71.3268333,42.63650495)	lowell	ma	us	t	-71.3824786	42.6665157	-71.271188	42.6064942
w1m69aGIXX	2022-05-09 18:47:18.836+00	2022-05-09 18:47:18.936+00	\N	\N	(-81.13831685,42.7719627)	central elgin	on	ca	t	-81.2446059	42.8926837	-81.0320278	42.6512417
AudbX12DcC	2022-05-09 18:48:36.701+00	2022-05-09 18:48:36.801+00	\N	\N	(-87.1242355,37.760346)	owensboro	ky	us	t	-87.196074	37.810033	-87.052397	37.710659
lUD54vVmRy	2022-05-09 18:48:42.818+00	2022-05-09 18:48:42.917+00	\N	\N	(-71.19923399999999,43.0323784)	raymond	nh	us	t	-71.267635	43.0801708	-71.130833	42.984586
bqLuKBOgzL	2022-05-09 18:52:20.741+00	2022-05-09 18:52:20.84+00	\N	\N	(-84.54098365,39.13654665)	cincinnati	oh	us	t	-84.71239	39.2210368	-84.3695773	39.0520565
vINZCsZ4XO	2022-05-09 18:52:37.834+00	2022-05-09 18:52:37.933+00	\N	\N	(-88.12812299999999,42.970091499999995)	new berlin	wi	us	t	-88.188994	43.017325	-88.067252	42.922858
lkBUOgLsU0	2022-05-09 19:45:03.817+00	2022-05-09 19:45:03.917+00	\N	\N	(-122.02934479999999,37.5206567)	newark	ca	us	t	-122.070899	37.5636823	-121.9877906	37.4776311
VxeOlmACne	2022-05-09 20:00:20.191+00	2022-05-09 20:00:26.332+00	\N	\N	(18.62769875,-33.88316845)	bellville	wc	za	t	18.5776601	-33.8251342	18.6777374	-33.9412027
sCJNvhEotk	2022-05-09 19:45:18.969+00	2022-05-09 19:45:19.07+00	\N	\N	(-74.94116735,40.37036825)	lambertville	nj	us	t	-74.9541817	40.3858046	-74.928153	40.3549319
FHT0F7BD3n	2022-05-09 19:45:21.38+00	2022-05-09 19:45:21.48+00	\N	\N	(-96.67283085,33.11440055)	allen	tx	us	t	-96.7366668	33.1580078	-96.6089949	33.0707933
NP4TRNU7Tl	2022-05-09 19:45:23.628+00	2022-05-09 19:45:23.728+00	\N	\N	(-84.3949769,39.2429643)	sycamore township	oh	us	t	-84.4558447	39.294399	-84.3341091	39.1915296
OpZo6a6Vhv	2022-05-09 19:45:25.666+00	2022-05-09 19:45:25.766+00	\N	\N	(-87.28293550000001,33.849868)	jasper	al	us	t	-87.361896	33.909372	-87.203975	33.790364
QAVdH4LOmg	2022-05-09 19:44:17.922+00	2022-05-09 20:00:55.598+00	\N	\N	(29.52411,-23.954695)	polokwane local municipality	lp	za	t	29.12004	-23.61248	29.92818	-24.29691
zugEsus7gZ	2022-05-09 20:00:19.947+00	2022-05-09 20:00:20.246+00	\N	\N	(-104.8547921,39.76426205)	denver	co	us	t	-105.1098845	39.9142087	-104.5996997	39.6143154
R0d2Eip3mh	2022-05-09 19:45:39.956+00	2022-05-09 19:45:40.056+00	\N	\N	(-114.08788025000001,51.02751365)	calgary	ab	ca	t	-114.3157587	51.2125013	-113.8600018	50.842526
D0lX80wXj7	2022-05-09 19:45:42.009+00	2022-05-09 19:45:42.108+00	\N	\N	(78.43054895,17.426234899999997)	hyderabad	tg	in	t	78.2387067	17.5608321	78.6223912	17.2916377
SOJm1EcxxA	2022-05-09 20:00:19.952+00	2022-05-09 20:00:20.051+00	\N	\N	(-85.738708,30.176301)	upper grand lagoon	fl	us	t	-85.792724	30.223069	-85.684692	30.129533
HwshfeFcRu	2022-05-09 19:45:46.662+00	2022-05-09 19:45:46.762+00	\N	\N	(18.3695351,-34.0327566)	hout bay	wc	za	t	18.3331816	-34.006257	18.4058886	-34.0592562
GbNHgt3avD	2022-05-09 19:54:49.828+00	2022-05-09 19:54:49.927+00	\N	\N	(22.976425,-33.94402)	knysna local municipality	wc	za	t	22.70434	-33.79402	23.24851	-34.09402
Gd8vdgrGWL	2022-05-09 19:55:13.261+00	2022-05-09 19:55:13.361+00	\N	\N	(-134.1957195,58.3850105)	juneau	ak	us	t	-135.219128	58.974972	-133.172311	57.795049
VyMvy7viAF	2022-05-09 19:55:17.925+00	2022-05-09 19:55:18.025+00	\N	\N	(-75.38459270000001,40.131759)	west norriton township	pa	us	t	-75.4246523	40.155858	-75.3445331	40.10766
PxY5rT6NuQ	2022-05-09 19:45:29.233+00	2022-05-09 20:00:25.97+00	\N	\N	(27.975,-26.096111)	randburg	gt	za	t	27.815	-25.936111	28.135	-26.256111
gMDWpGZDmR	2022-05-09 19:55:27.186+00	2022-05-09 19:55:27.286+00	\N	\N	(-74.06854575,40.715279800000005)	jersey city	nj	us	t	-74.1166865	40.7689376	-74.020405	40.661622
0cP6QWZgog	2022-05-09 19:55:54.928+00	2022-05-09 19:55:55.028+00	\N	\N	(-78.6863475,43.1497425)	town of lockport	ny	us	t	-78.754864	43.219367	-78.617831	43.080118
oQLPCQuMaa	2022-05-09 20:00:19.739+00	2022-05-09 20:00:19.838+00	\N	\N	(-121.82729710000001,38.4345369)	dixon	ca	us	t	-121.8683517	38.4890107	-121.7862425	38.3800631
cGtEeV6YeD	2022-05-09 20:00:19.742+00	2022-05-09 20:00:19.843+00	\N	\N	(-82.37471640000001,28.0410421)	temple terrace	fl	us	t	-82.4017295	28.0692064	-82.3477033	28.0128778
HpAEVUJVjF	2022-05-09 20:00:19.756+00	2022-05-09 20:00:19.857+00	\N	\N	(-95.53167555,33.67951055)	paris	tx	us	t	-95.6279396	33.7383866	-95.4354115	33.6206345
UQ7d6F071g	2022-05-09 20:00:20.171+00	2022-05-09 20:00:20.272+00	\N	\N	(-84.4011467,39.27926735)	sharonville	oh	us	t	-84.4497173	39.3040567	-84.3525761	39.254478
cjgBDgmiDt	2022-05-09 20:00:19.784+00	2022-05-09 20:00:19.883+00	\N	\N	(-86.8088205,33.677489)	gardendale	al	us	t	-86.869907	33.732376	-86.747734	33.622602
bpzGBiBr6r	2022-05-09 20:00:19.826+00	2022-05-09 20:00:19.927+00	\N	\N	(-86.53151245000001,39.17134545)	bloomington	in	us	t	-86.5918944	39.2213618	-86.4711305	39.1213291
UgSjT8Zy4a	2022-05-09 19:45:44.004+00	2022-05-09 20:00:19.968+00	\N	\N	(18.53478,-33.293525200000005)	swartland local municipality	wc	za	t	18.07214	-32.9000204	18.99742	-33.68703
Jd5qTV17VD	2022-05-09 19:55:24.868+00	2022-05-09 20:00:26.145+00	\N	\N	(18.999238249999998,-33.503370000000004)	drakenstein local municipality	wc	za	t	18.7844275	-33.12766	19.214049	-33.87908
ao7QXuB11Y	2022-05-09 20:00:19.964+00	2022-05-09 20:00:20.064+00	\N	\N	(-125.34257975,50.0102316)	campbell river	bc	ca	t	-125.4915516	50.1188647	-125.1936079	49.9015985
Z6KHpBEGQM	2022-05-09 20:00:19.966+00	2022-05-09 20:00:20.067+00	\N	\N	(-111.7744204,32.8870615)	casa grande	az	us	t	-111.91231	32.99662	-111.6365308	32.777503
sEWvbily0y	2022-05-09 20:00:19.974+00	2022-05-09 20:00:20.074+00	\N	\N	(-0.6385181,54.347280749999996)	scarborough	eng	gb	t	-1.0646829	54.5621437	-0.2123533	54.1324178
DFG14pt1Jm	2022-05-09 20:00:19.977+00	2022-05-09 20:00:20.076+00	\N	\N	(-71.8406148,44.338955049999996)	littleton	nh	us	t	-71.9845413	44.4066658	-71.6966883	44.2712443
bCDMMFzXVi	2022-05-09 20:00:19.978+00	2022-05-09 20:00:20.079+00	\N	\N	(-97.0824806,36.141778)	stillwater	ok	us	t	-97.1495688	36.2045006	-97.0153924	36.0790554
GpaJDk7CxN	2022-05-09 20:00:19.98+00	2022-05-09 20:00:20.082+00	\N	\N	(-100.4698025,39.114115999999996)	grainfield	ks	us	t	-100.478669	39.11873	-100.460936	39.109502
1LB47biH2z	2022-05-09 20:00:19.995+00	2022-05-09 20:00:20.098+00	\N	\N	(-122.0334467,38.23362)	fairfield	ca	us	t	-122.174914	38.308742	-121.8919794	38.158498
R4zG1gSrR6	2022-05-09 20:00:19.999+00	2022-05-09 20:00:20.103+00	\N	\N	(-96.90898035000001,33.381363)	pilot point	tx	us	t	-96.982822	33.416406	-96.8351387	33.34632
4q7scfOWB4	2022-05-09 20:00:55.642+00	2022-05-09 20:00:55.758+00	\N	\N	(-80.3627858,27.289993799999998)	port saint lucie	fl	us	t	-80.481303	27.3744233	-80.2442686	27.2055643
E2xeYwGtLA	2022-05-09 19:45:15.291+00	2022-05-09 20:00:55.781+00	\N	\N	(25.620751900000002,-33.9617051)	gqeberha	ec	za	t	25.4607519	-33.8017051	25.7807519	-34.1217051
H2ceUAYXvb	2022-05-09 20:00:20.037+00	2022-05-09 20:00:20.136+00	\N	\N	(-95.52382205,30.3113246)	conroe	tx	us	t	-95.6567012	30.4199903	-95.3909429	30.2026589
5UXjmgNBZL	2022-05-09 20:00:20.147+00	2022-05-09 20:00:20.252+00	\N	\N	(-1.2859631,53.4084281)	rotherham	eng	gb	t	-1.4567893	53.5153079	-1.1151369	53.3015483
LLbxxowO4T	2022-05-09 20:00:20.084+00	2022-05-09 20:00:20.186+00	\N	\N	(-79.9842986,36.00448095)	high point	nc	us	t	-80.0722241	36.0969655	-79.8963731	35.9119964
TMxKkF9deK	2022-05-09 20:00:20.269+00	2022-05-09 20:00:20.369+00	\N	\N	(-96.6532069,33.21569205)	mckinney	tx	us	t	-96.7679041	33.3060918	-96.5385097	33.1252923
YHWLlHtk42	2022-05-09 20:00:20.115+00	2022-05-09 20:00:20.217+00	\N	\N	(-122.34206449999999,47.607568799999996)	seattle	wa	us	t	-122.459696	47.7341354	-122.224433	47.4810022
Ej4CQMOxb2	2022-05-09 20:00:20.122+00	2022-05-09 20:00:20.222+00	\N	\N	(-89.79036550000001,35.074884999999995)	germantown	tn	us	t	-89.84554	35.121072	-89.735191	35.028698
0VCZAQYgl7	2022-05-09 20:00:19.759+00	2022-05-09 20:00:20.266+00	\N	\N	(-121.6329524,36.6866326)	salinas	ca	us	t	-121.691914	36.7342482	-121.5739908	36.639017
VBACC08U1W	2022-05-09 20:00:20.175+00	2022-05-09 20:00:20.276+00	\N	\N	(-83.11725475,41.35749955)	fremont	oh	us	t	-83.1655195	41.3840791	-83.06899	41.33092
z9UmTmh9fc	2022-05-09 20:00:20.18+00	2022-05-09 20:00:20.282+00	\N	\N	(-73.864857,40.944435999999996)	yonkers	ny	us	t	-73.919289	40.988393	-73.810425	40.900479
DVlxLAgHJD	2022-05-09 20:00:20.073+00	2022-05-09 20:00:20.291+00	\N	\N	(-93.2981543,44.8241363)	bloomington	mn	us	t	-93.3988956	44.8631417	-93.197413	44.7851309
X7rHXAeawZ	2022-05-09 20:00:20.225+00	2022-05-09 20:00:20.33+00	\N	\N	(-82.2938428,27.9284815)	brandon	fl	us	t	-82.3438286	27.978093	-82.243857	27.87887
BFkZPUNZvo	2022-05-09 20:00:20.086+00	2022-05-09 20:00:20.355+00	\N	\N	(-84.47523949999999,33.451959)	fayetteville	ga	us	t	-84.528849	33.491117	-84.42163	33.412801
aUpuYfRoXm	2022-05-09 20:00:20.196+00	2022-05-09 20:00:20.298+00	\N	\N	(-123.02908565,44.9339353)	salem	or	us	t	-123.1229614	45.0166247	-122.9352099	44.8512459
5AHCXV2gRs	2022-05-09 20:00:20.212+00	2022-05-09 20:00:20.314+00	\N	\N	(-66.92025964999999,17.980328999999998)	guánica	pr	us	t	-66.9810029	18.0337544	-66.8595164	17.9269036
T4FEaQ32Sx	2022-05-09 20:00:20.293+00	2022-05-09 20:00:20.393+00	\N	\N	(-93.6668054,32.5068732)	bossier city	la	us	t	-93.7492794	32.5939542	-93.5843314	32.4197922
mP85LnGtAq	2022-05-09 20:00:25.784+00	2022-05-09 20:00:25.884+00	\N	\N	(-84.873335,32.49099955)	columbus	ga	us	t	-85.079207	32.6081231	-84.667463	32.373876
owQiqUYwXo	2022-05-09 20:00:28.94+00	2022-05-09 20:00:29.052+00	\N	\N	(-77.0341894,-12.098169550000001)	san isidro	lim	pe	t	-77.0608319	-12.085041	-77.0075469	-12.1112981
3QKYf5k44Z	2022-05-09 20:00:29.017+00	2022-05-09 20:00:29.122+00	\N	\N	(-89.729478,38.1457255)	sparta	il	us	t	-89.777414	38.190606	-89.681542	38.100845
BzVQ5Y7TTb	2022-05-09 20:00:29.08+00	2022-05-09 20:00:29.184+00	\N	\N	(-122.84024289999999,45.358755849999994)	sherwood	or	us	t	-122.8750326	45.375159	-122.8054532	45.3423527
8MgoseDOL1	2022-05-09 20:00:29.116+00	2022-05-09 20:00:29.221+00	\N	\N	(-80.2693152,26.63858895)	wellington	fl	us	t	-80.3641803	26.6846569	-80.1744501	26.592521
3bKpEdm7wu	2022-05-17 07:26:01.267+00	2022-05-17 07:26:01.367+00	\N	\N	(-76.16984550000001,40.686493)	palo alto	pa	us	t	-76.189013	40.69673	-76.150678	40.676256
2t09Vs7Kv9	2022-05-09 20:00:29.273+00	2022-05-09 20:00:29.374+00	\N	\N	(-86.2760197,41.678859)	south bend	in	us	t	-86.3607483	41.7602675	-86.1912911	41.5974505
0nACBRG3J4	2022-05-09 20:00:29.283+00	2022-05-09 20:00:29.383+00	\N	\N	(-104.6877219,39.68901305)	aurora	co	us	t	-104.8865378	39.826965	-104.488906	39.5510611
tcDwdlc078	2022-05-09 20:00:55.637+00	2022-05-09 20:00:55.757+00	\N	\N	(-81.200471,32.038757)	savannah	ga	us	t	-81.371427	32.189662	-81.029515	31.887852
ucfZshqk0X	2022-05-09 20:00:55.707+00	2022-05-09 20:00:55.816+00	\N	\N	(-72.66265705,42.32969595)	northampton	ma	us	t	-72.7412178	42.3752541	-72.5840963	42.2841378
NGAEE0uiYP	2022-05-09 20:00:55.742+00	2022-05-09 20:00:55.843+00	\N	\N	(-87.17356805,41.59247379999999)	portage	in	us	t	-87.2226137	41.6489036	-87.1245224	41.536044
Vzlehu7uua	2022-05-09 20:00:55.786+00	2022-05-09 20:00:55.885+00	\N	\N	(-97.135413,32.701843)	arlington	tx	us	t	-97.233818	32.817121	-97.037008	32.586565
jRBoXDLq55	2022-05-09 20:00:25.747+00	2022-05-09 20:00:58.506+00	\N	\N	(31.009909,-29.861825)	durban	nl	za	t	30.849909	-29.701825	31.169909	-30.021825
D8Fj1vINbt	2022-05-09 21:17:35.901+00	2022-05-09 21:17:35.999+00	\N	\N	(25.98815185,45.15442135)	poiana vărbilău	107654	ro	t	25.9801197	45.16437	25.996184	45.1444727
TD7xnbO230	2022-05-09 21:41:58.948+00	2022-05-09 21:41:59.048+00	\N	\N	(35.03480005,31.9299069)	matityahu	judea and samaria	ps	t	35.0317204	31.9318618	35.0378797	31.927952
MLk1MiItHL	2022-05-17 07:25:53.509+00	2022-05-17 07:25:53.609+00	\N	\N	(-111.9821975,40.559489150000005)	south jordan	ut	us	t	-112.069822	40.5821186	-111.894573	40.5368597
U0l39lQiCO	2022-05-17 07:25:54.245+00	2022-05-17 07:25:54.345+00	\N	\N	(-86.78049899999999,41.2158075)	north judson	in	us	t	-86.795524	41.225784	-86.765474	41.205831
jvIDqltjTe	2022-05-17 07:25:54.889+00	2022-05-17 07:25:54.989+00	\N	\N	(7.5535706000000005,47.51910985)	oberwil	bl	ch	t	7.5234659	47.5340149	7.5836753	47.5042048
Te40BdQ94i	2022-05-17 07:25:55.192+00	2022-05-17 07:25:55.292+00	\N	\N	(-80.22945849999999,25.782417199999998)	miami	fl	us	t	-80.31976	25.8557827	-80.139157	25.7090517
vS7PnD0hgB	2022-05-17 07:25:55.496+00	2022-05-17 07:25:55.596+00	\N	\N	(-82.94454425,36.418111249999995)	hawkins county	tn	us	t	-83.289078	36.5941115	-82.6000105	36.242111
y5kDasbKA7	2022-05-17 07:25:55.928+00	2022-05-17 07:25:56.029+00	\N	\N	(-2.9185864500000003,53.3932656)	liverpool	eng	gb	t	-3.0191726	53.4749885	-2.8180003	53.3115427
FPioa9mheb	2022-05-17 07:25:56.764+00	2022-05-17 07:25:56.864+00	\N	\N	(-121.72251945,48.4766875)	skagit county	wa	us	t	-122.7596469	48.657827	-120.685392	48.295548
z2kkZl5YBc	2022-05-17 07:25:57.239+00	2022-05-17 07:25:57.338+00	\N	\N	(-82.8158887,35.2251921)	transylvania county	nc	us	t	-83.056938	35.4229703	-82.5748394	35.0274139
X2vAWRAEUB	2022-05-17 07:25:57.94+00	2022-05-17 07:25:58.04+00	\N	\N	(116.0858885,-31.770361)	city of swan	wa	au	t	115.873763	-31.59713	116.298014	-31.943592
1qdvfHYnFj	2022-05-17 07:25:58.724+00	2022-05-17 07:25:58.824+00	\N	\N	(-92.53246025,41.6855973)	poweshiek county	ia	us	t	-92.7668012	41.8629476	-92.2981193	41.508247
v9nvK3arCp	2022-05-17 07:25:59.199+00	2022-05-17 07:25:59.3+00	\N	\N	(77.3271074,28.5707841)	noida	up	in	t	77.1671074	28.7307841	77.4871074	28.4107841
bvqIr42s5T	2022-05-17 07:25:59.501+00	2022-05-17 07:25:59.601+00	\N	\N	(-75.48371865,40.593087249999996)	allentown	pa	us	t	-75.5480852	40.6361993	-75.4193521	40.5499752
79kAra9aFM	2022-05-17 07:26:00.165+00	2022-05-17 07:26:00.265+00	\N	\N	(152.9510863,-27.0839336)	caboolture	qld	au	t	152.7910863	-26.9239336	153.1110863	-27.2439336
O8LFEfV1BZ	2022-05-17 07:26:00.965+00	2022-05-17 07:26:01.065+00	\N	\N	(-93.05264935,41.6852585)	jasper county	ia	us	t	-93.348675	41.86311	-92.7566237	41.507407
zhlhT6y56h	2022-05-17 07:26:01.789+00	2022-05-17 07:26:01.889+00	\N	\N	(-76.880442,40.2819312)	harrisburg	pa	us	t	-76.92449	40.3262914	-76.836394	40.237571
BaoX5Np9sU	2022-05-17 07:26:02.109+00	2022-05-17 07:26:02.21+00	\N	\N	(131.0840205,-13.1523525)	coomalie shire		au	t	130.889081	-12.815831	131.27896	-13.488874
aB9G8pX37s	2022-05-17 07:26:02.564+00	2022-05-17 07:26:02.664+00	\N	\N	(-66.9265815,10.4523236)	caracas	capital district	ve	t	-67.16228	10.5641499	-66.690883	10.3404973
OjtDEptRKW	2022-05-17 07:26:02.905+00	2022-05-17 07:26:03.004+00	\N	\N	(-116.2439505,43.45984675)	ada county	id	us	t	-116.513696	43.8074186	-115.974205	43.1122749
tHLGIcOlwR	2022-05-17 07:26:03.28+00	2022-05-17 07:26:03.379+00	\N	\N	(10.62530075,55.08227395)	svendborg municipality	region of southern denmark	dk	t	10.3606264	55.2215971	10.8899751	54.9429508
eWN66DHZ39	2022-05-17 07:26:03.608+00	2022-05-17 07:26:03.708+00	\N	\N	(-117.0699815,33.134725)	escondido	ca	us	t	-117.146104	33.211608	-116.993859	33.057842
ugPVNhdyvH	2022-05-17 07:26:03.979+00	2022-05-17 07:26:04.08+00	\N	\N	(14.4656111,50.05966535)	prague	prague	cz	t	14.2244355	50.1774301	14.7067867	49.9419006
gN1RWdp2iH	2022-05-17 07:26:04.298+00	2022-05-17 07:26:04.397+00	\N	\N	(-71.9430568,45.771799)	val-des-sources	qc	ca	t	-72.0123593	45.8048209	-71.8737543	45.7387771
ATJ8svNyol	2022-05-17 07:26:04.594+00	2022-05-17 07:26:04.694+00	\N	\N	(-85.2385749,35.0986641)	chattanooga	tn	us	t	-85.4255628	35.214346	-85.051587	34.9829822
wq08qegxwt	2022-05-17 07:26:04.971+00	2022-05-17 07:26:05.071+00	\N	\N	(-88.12451444999999,43.1485853)	menomonee falls	wi	us	t	-88.185671	43.1926056	-88.0633579	43.104565
OtC4EXTEKc	2022-05-17 07:26:05.327+00	2022-05-17 07:26:05.428+00	\N	\N	(-84.04997495,9.7899229)	corralillo	30107	cr	t	-84.0881161	9.8164057	-84.0118338	9.7634401
TlCD0vLcrh	2022-05-17 07:26:05.632+00	2022-05-17 07:26:05.731+00	\N	\N	(-81.62062815,35.0116804)	cherokee county	sc	us	t	-81.8746194	35.1840345	-81.3666369	34.8393263
I3xuEtF00e	2022-05-17 07:26:06.001+00	2022-05-17 07:26:06.101+00	\N	\N	(-79.91956214999999,43.83231135)	caledon	on	ca	t	-80.1442605	43.9897547	-79.6948638	43.674868
trA72OzqhJ	2022-05-17 07:26:06.51+00	2022-05-17 07:26:06.61+00	\N	\N	(24.9035175,41.940906999999996)	asenovgrad		bg	t	24.659413	42.093845	25.147622	41.787969
mg0CxXgsAJ	2022-05-17 07:26:06.846+00	2022-05-17 07:26:06.946+00	\N	\N	(-122.11368110000001,47.0663284)	pierce county	wa	us	t	-122.8529952	47.4038582	-121.374367	46.7287986
vDtJyW8JXh	2022-05-17 07:26:07.143+00	2022-05-17 07:26:07.243+00	\N	\N	(-73.39999055,46.4534904)	mandeville	qc	ca	t	-73.5590536	46.5862175	-73.2409275	46.3207633
4oWiulO96h	2022-05-17 07:26:07.547+00	2022-05-17 07:26:07.646+00	\N	\N	(-122.20190905,37.475204649999995)	north fair oaks	ca	us	t	-122.2177078	37.4852536	-122.1861103	37.4651557
NYb7wsWJpD	2022-05-17 07:26:07.989+00	2022-05-17 07:26:08.094+00	\N	\N	(-74.2199985,4.2825314)	bogota capital district - department		co	t	-74.4509502	4.8369566	-73.9890468	3.7281062
r4hysuB54f	2022-05-17 07:26:08.388+00	2022-05-17 07:26:08.487+00	\N	\N	(-80.11736925,26.372643449999998)	boca raton	fl	us	t	-80.1710745	26.4246101	-80.063664	26.3206768
O4IbUUDNyO	2022-05-17 07:26:08.756+00	2022-05-17 07:26:08.855+00	\N	\N	(-72.5715489,41.83395765)	south windsor	ct	us	t	-72.6462873	41.8699055	-72.4968105	41.7980098
sKLu4uzgHQ	2022-05-17 07:26:09.236+00	2022-05-17 07:26:09.337+00	\N	\N	(-78.03633009999999,38.25505215)	orange county	va	us	t	-78.3698166	38.392788	-77.7028436	38.1173163
Z1FhgBF1QD	2022-05-17 07:26:09.682+00	2022-05-17 07:26:09.781+00	\N	\N	(-77.56132425000001,37.3897096)	chesterfield county	va	us	t	-77.8784815	37.5624252	-77.244167	37.216994
HiRajonpDm	2022-05-17 07:26:10.074+00	2022-05-17 07:26:10.174+00	\N	\N	(-84.7562005,33.3514005)	coweta county	ga	us	t	-85.015358	33.511758	-84.497043	33.191043
Af2lYFvqy9	2022-05-09 20:00:20.199+00	2022-05-09 20:00:20.301+00	\N	\N	(-116.964662,32.5010188)	tijuana	bcn	mx	t	-117.124662	32.6610188	-116.804662	32.3410188
LARUHncdyG	2022-05-09 20:00:20.214+00	2022-05-09 20:00:20.315+00	\N	\N	(-84.05744905,39.7354969)	beavercreek	oh	us	t	-84.1066202	39.7901329	-84.0082779	39.6808609
YsGVuz0Uv4	2022-05-09 20:00:20.245+00	2022-05-09 20:00:20.339+00	\N	\N	(-84.296573,35.9696835)	oak ridge	tn	us	t	-84.436588	36.064502	-84.156558	35.874865
udT2NnMtvZ	2022-05-09 20:00:28.948+00	2022-05-09 20:00:29.052+00	\N	\N	(-1.45727215,54.87160635)	sunderland	eng	gb	t	-1.5688793	54.9441703	-1.345665	54.7990424
4aKVj3wSgi	2022-05-09 20:00:29.044+00	2022-05-09 20:00:29.15+00	\N	\N	(-94.3427435,37.8393435)	nevada	mo	us	t	-94.38753	37.879584	-94.297957	37.799103
ud0UjHCsJ9	2022-05-09 20:00:29.082+00	2022-05-09 20:00:29.185+00	\N	\N	(-122.4650828,48.752708850000005)	bellingham	wa	us	t	-122.531455	48.8174119	-122.3987106	48.6880058
BaPafQi60Z	2022-05-09 20:00:29.118+00	2022-05-09 20:00:29.222+00	\N	\N	(-115.24317525000001,36.2551973)	las vegas	nv	us	t	-115.4242845	36.3808406	-115.062066	36.129554
TXqubH81UX	2022-05-09 20:00:55.551+00	2022-05-09 20:00:55.659+00	\N	\N	(-96.89694175,32.9866379)	carrollton	tx	us	t	-96.9586136	33.0551786	-96.8352699	32.9180972
GhOcpco4IH	2022-05-09 20:00:55.878+00	2022-05-09 20:00:55.978+00	\N	\N	(-77.3257295,37.55257374999999)	highland springs	va	us	t	-77.365772	37.5757455	-77.285687	37.529402
5kYBsIJDBX	2022-05-09 20:00:55.992+00	2022-05-09 20:00:56.092+00	\N	\N	(-123.11204745,45.5234061)	forest grove	or	us	t	-123.1535277	45.5450822	-123.0705672	45.50173
1YrbMHxpVB	2022-05-09 20:00:58.435+00	2022-05-09 20:00:58.534+00	\N	\N	(-83.291406,42.39893)	redford township	mi	us	t	-83.316825	42.44268	-83.265987	42.35518
9lUU5Z5qjK	2022-05-09 20:00:58.498+00	2022-05-09 20:00:58.598+00	\N	\N	(-84.63962905,39.25825255)	colerain township	oh	us	t	-84.7169009	39.3120806	-84.5623572	39.2044245
YCLehpcjcC	2022-05-09 18:40:59.965+00	2022-05-09 20:01:24.558+00	\N	\N	(-118.4117363,33.9984235)	los angeles	ca	us	t	-118.6681779	34.337306	-118.1552947	33.659541
VjrcbtitBm	2022-05-09 21:19:40.53+00	2022-05-09 21:19:40.629+00	\N	\N	(-90.17936655,30.00160305)	metairie	la	us	t	-90.2376169	30.034366	-90.1211162	29.9688401
MMkXTFJa9p	2022-05-09 21:19:45.418+00	2022-05-09 21:19:45.519+00	\N	\N	(-84.7787581,42.9004096)	westphalia township	mi	us	t	-84.837619	42.9437592	-84.7198972	42.85706
lRDHfka95G	2022-05-09 21:19:50.895+00	2022-05-09 21:19:50.995+00	\N	\N	(-83.38576775,42.659637000000004)	waterford township	mi	us	t	-83.446139	42.705918	-83.3253965	42.613356
24GT8F0REI	2022-05-09 21:47:18.342+00	2022-05-09 21:47:18.441+00	\N	\N	(-121.80442744999999,47.4323964)	king county	wa	us	t	-122.5431459	47.7803281	-121.065709	47.0844647
DZLm8cTfQ7	2022-05-17 07:26:10.523+00	2022-05-17 07:26:10.623+00	\N	\N	(-85.0705521,41.09409555)	allen county	in	us	t	-85.3381614	41.2711639	-84.8029428	40.9170272
jbECp8DDJf	2022-05-17 07:26:10.906+00	2022-05-17 07:26:11.005+00	\N	\N	(-122.70216595,38.43619045)	santa rosa	ca	us	t	-122.8343404	38.5080485	-122.5699915	38.3643324
D7y8jjGPFN	2022-05-17 07:26:11.354+00	2022-05-17 07:26:11.454+00	\N	\N	(4.5687642,51.01850925)	bonheiden	antwerp	be	t	4.5028193	51.0468743	4.6347091	50.9901442
W2aHnD4Pki	2022-05-17 07:26:11.78+00	2022-05-17 07:26:11.88+00	\N	\N	(-83.3877511,42.27745)	wayne	mi	us	t	-83.427436	42.289186	-83.3480662	42.265714
jueFObKgFl	2022-05-17 07:26:12.122+00	2022-05-17 07:26:12.222+00	\N	\N	(23.60878485,46.77590155)	cluj-napoca		ro	t	23.499243	46.861832	23.7183267	46.6899711
SlGS2Kf8rn	2022-05-17 07:26:12.472+00	2022-05-17 07:26:12.572+00	\N	\N	(26.6970402,45.215640050000005)	vernești		ro	t	26.6235867	45.2817682	26.7704937	45.1495119
FKFpueVpFk	2022-05-17 07:26:12.859+00	2022-05-17 07:26:12.959+00	\N	\N	(-72.75721415,41.762546)	west hartford	ct	us	t	-72.8006054	41.8066305	-72.7138229	41.7184615
fabPD3tTWJ	2022-05-17 07:26:13.167+00	2022-05-17 07:26:13.266+00	\N	\N	(-122.29181385,38.02646705)	hercules	ca	us	t	-122.374009	38.0695272	-122.2096187	37.9834069
Zq2XkrW5AA	2022-05-17 07:26:13.599+00	2022-05-17 07:26:13.699+00	\N	\N	(-81.2231527,43.5193946)	southwestern ontario	on	ca	t	-83.1496944	45.3622336	-79.296611	41.6765556
LRuL9B6H7a	2022-05-17 07:26:13.983+00	2022-05-17 07:26:14.083+00	\N	\N	(30.9832549,-29.402149899999998)	ndwedwe local municipality	nl	za	t	30.7025199	-29.1767099	31.2639899	-29.6275899
jI4OQU3KXE	2022-05-17 07:26:14.352+00	2022-05-17 07:26:14.453+00	\N	\N	(-77.49222385,18.0414858)	manchester		jm	t	-77.63845	18.2443626	-77.3459977	17.838609
5qCdJaQ7DV	2022-05-17 07:26:14.706+00	2022-05-17 07:26:14.805+00	\N	\N	(-92.48109155,43.9964002)	rochester	mn	us	t	-92.5731822	44.1082534	-92.3890009	43.884547
SZxuwBigRL	2022-05-17 07:26:15.085+00	2022-05-17 07:26:15.184+00	\N	\N	(-116.558847,43.589672)	nampa	id	us	t	-116.644171	43.655884	-116.473523	43.52346
6CmgjvqD5o	2022-05-17 07:26:15.621+00	2022-05-17 07:26:15.72+00	\N	\N	(-66.47443319999999,18.12990995)	villalba	pr	us	t	-66.5301376	18.1788532	-66.4187288	18.0809667
MFrExjg15F	2022-05-17 07:26:16.21+00	2022-05-17 07:26:16.311+00	\N	\N	(-81.70591884999999,41.497532)	cleveland	oh	us	t	-81.8790937	41.604436	-81.532744	41.390628
roMUsj3OMZ	2022-05-17 07:26:16.661+00	2022-05-17 07:26:16.761+00	\N	\N	(-121.80604585,39.7577607)	chico	ca	us	t	-121.8987215	39.8168492	-121.7133702	39.6986722
p1HY46H4tr	2022-05-17 07:26:16.99+00	2022-05-17 07:26:17.09+00	\N	\N	(14.5313988,-22.6767841)	swakopmund	erongo region	na	t	14.3713988	-22.5167841	14.6913988	-22.8367841
v2Pz7CHB0y	2022-05-17 07:26:17.354+00	2022-05-17 07:26:17.453+00	\N	\N	(-79.78644355,37.55516055)	botetourt county	va	us	t	-80.0741195	37.8009735	-79.4987676	37.3093476
zepo72O2Bm	2022-05-17 07:26:17.673+00	2022-05-17 07:26:17.773+00	\N	\N	(-74.5536901,45.187497050000005)	south glengarry	on	ca	t	-74.787274	45.3561743	-74.3201062	45.0188198
GCsf4gPCbc	2022-05-17 07:26:18.024+00	2022-05-17 07:26:18.124+00	\N	\N	(-84.84110050000001,33.915008)	dallas	ga	us	t	-84.898927	33.941267	-84.783274	33.888749
GwhMOpcAjN	2022-05-17 07:26:18.517+00	2022-05-17 07:26:18.617+00	\N	\N	(11.9670171,57.7072326)	gothenburg	41106	se	t	11.8070171	57.8672326	12.1270171	57.5472326
wT1j7rkSnk	2022-05-17 07:26:19.781+00	2022-05-17 07:26:19.881+00	\N	\N	(-107.8551395,38.472668999999996)	montrose	co	us	t	-107.924288	38.523868	-107.785991	38.42147
YkMZelU5MB	2022-05-17 07:26:20.139+00	2022-05-17 07:26:20.239+00	\N	\N	(-97.14522695,33.237590499999996)	denton	tx	us	t	-97.2666409	33.358306	-97.023813	33.116875
ZsM8BBGHYI	2022-05-17 07:26:20.48+00	2022-05-17 07:26:20.579+00	\N	\N	(-99.0181547,19.4079028)	nezahualcóyotl	state of mexico	mx	t	-99.1781547	19.5679028	-98.8581547	19.2479028
Vi6vzTXWHa	2022-05-17 07:26:20.783+00	2022-05-17 07:26:20.884+00	\N	\N	(-70.75526335,41.873916)	carver	ma	us	t	-70.8298277	41.9475071	-70.680699	41.8003249
UdDFjInEWF	2022-05-17 07:26:21.193+00	2022-05-17 07:26:21.293+00	\N	\N	(-116.13855635,33.6713215)	coachella	ca	us	t	-116.2164863	33.729527	-116.0606264	33.613116
lhHLh7HwUp	2022-05-17 07:26:21.552+00	2022-05-17 07:26:21.652+00	\N	\N	(-96.2585915,44.0236988)	pipestone county	mn	us	t	-96.453405	44.198395	-96.063778	43.8490026
WuaLYykOin	2022-05-17 07:26:22.11+00	2022-05-17 07:26:22.209+00	\N	\N	(-78.64488305,35.83949675)	raleigh	nc	us	t	-78.8189744	35.970736	-78.4707917	35.7082575
wHHBYOUsTg	2022-05-17 07:26:22.424+00	2022-05-17 07:26:22.524+00	\N	\N	(-99.74533455,32.48383445)	abilene	tx	us	t	-99.8675851	32.624481	-99.623084	32.3431879
s6ZPGKl7ks	2022-05-17 07:26:22.742+00	2022-05-17 07:26:22.842+00	\N	\N	(-80.223937,26.0031465)	pembroke pines	fl	us	t	-80.383937	26.1631465	-80.063937	25.8431465
DzSh1LfEDw	2022-05-17 07:26:23.132+00	2022-05-17 07:26:23.233+00	\N	\N	(-105.23977485,40.029380149999994)	boulder	co	us	t	-105.3014509	40.094409	-105.1780988	39.9643513
8BTldsqMut	2022-05-17 07:26:23.407+00	2022-05-17 07:26:23.506+00	\N	\N	(-82.26381125,36.505416)	sullivan county	tn	us	t	-82.700943	36.616213	-81.8266795	36.394619
88Fjn1RAju	2022-05-17 07:26:23.833+00	2022-05-17 07:26:23.932+00	\N	\N	(-122.25974314999999,45.1736892)	clackamas county	or	us	t	-122.8679985	45.4616701	-121.6514878	44.8857083
32r49Yc3BD	2022-05-17 07:26:24.2+00	2022-05-17 07:26:24.3+00	\N	\N	(-81.09731765000001,29.1988008)	daytona beach	fl	us	t	-81.2115407	29.2687678	-80.9830946	29.1288338
Z9NftHeYSO	2022-05-17 07:26:24.552+00	2022-05-17 07:26:24.653+00	\N	\N	(-86.1330804,39.77984395)	indianapolis	in	us	t	-86.3281207	39.9275253	-85.9380401	39.6321626
jNHNHasqjW	2022-05-17 07:26:24.82+00	2022-05-17 07:26:24.92+00	\N	\N	(-117.72837505,33.94724825)	chino hills	ca	us	t	-117.8025491	34.0235121	-117.654201	33.8709844
3Ux9GBRDkJ	2022-05-17 07:26:25.197+00	2022-05-17 07:26:25.297+00	\N	\N	(-92.0395648,30.2102107)	lafayette	la	us	t	-92.1077963	30.2964622	-91.9713333	30.1239592
TpIgovR0mf	2022-05-17 07:26:25.522+00	2022-05-17 07:26:25.622+00	\N	\N	(-110.8994059,27.9216441)	guaymas	son	mx	t	-111.0594059	28.0816441	-110.7394059	27.7616441
Ht3R1mSMKQ	2022-05-17 07:26:19.032+00	2022-05-29 12:35:50.607+00	\N	\N	(8.494311,29.5143765)	debdeb	illizi	dz	t	7.086309	30.559038	9.902313	28.469715
HWZfz4JJhD	2022-05-09 20:00:20.11+00	2022-05-09 20:00:20.21+00	\N	\N	(-85.48451745,41.160734500000004)	columbia city	in	us	t	-85.5248749	41.178058	-85.44416	41.143411
ceJ7c0bjlb	2022-05-09 20:00:20.312+00	2022-05-09 20:00:20.411+00	\N	\N	(-121.77982829999999,36.9515861)	watsonville	ca	us	t	-121.8273244	37.019109	-121.7323322	36.8840632
IGwBnzZ6Oa	2022-05-09 20:00:20.997+00	2022-05-09 20:00:21.097+00	\N	\N	(-66.67526415,18.4047718)	arecibo	pr	us	t	-66.7707289	18.4943161	-66.5797994	18.3152275
8BTil1cUVE	2022-05-09 20:00:55.701+00	2022-05-09 20:00:55.815+00	\N	\N	(116.1330695,-32.003812499999995)	city of kalamunda	wa	au	t	115.977173	-31.922466	116.288966	-32.085159
pYoQhFE5ZZ	2022-05-09 21:22:16.525+00	2022-05-09 21:22:16.623+00	\N	\N	(-102.34511875,31.88031125)	odessa	tx	us	t	-102.4420576	31.9631525	-102.2481799	31.79747
nMT9kFFpqr	2022-05-09 20:00:25.767+00	2022-05-09 20:00:25.867+00	\N	\N	(8.69191575,49.53103975)	weinheim	bw	de	t	8.6033587	49.5938416	8.7804728	49.4682379
btpDISANXq	2022-05-09 21:48:12.227+00	2022-05-09 21:48:12.326+00	\N	\N	(-83.0140255,41.052066499999995)	bloomville	oh	us	t	-83.022422	41.059518	-83.005629	41.044615
HAZtM2xmSh	2022-05-09 20:00:28.971+00	2022-05-09 20:00:29.074+00	\N	\N	(-97.3129844,32.8005565)	fort worth	tx	us	t	-97.592388	33.049529	-97.0335808	32.551584
WzQ3jmw49m	2022-05-09 20:00:25.474+00	2022-05-09 20:00:29.166+00	\N	\N	(18.8287394,-34.0638665)	somerset west	wc	za	t	18.7682725	-34.0142988	18.8892063	-34.1134342
khXAqQuycf	2022-05-09 20:00:29.086+00	2022-05-09 20:00:29.197+00	\N	\N	(-93.217356,45.0280607)	st. anthony	mn	us	t	-93.2270205	45.050044	-93.2076915	45.0060774
rEuczuFaF1	2022-05-09 20:00:29.124+00	2022-05-09 20:00:29.231+00	\N	\N	(-84.553132,38.2274345)	georgetown	ky	us	t	-84.602072	38.277944	-84.504192	38.176925
jPs6eZxEzr	2022-05-09 20:00:29.161+00	2022-05-09 20:00:29.263+00	\N	\N	(-94.748311,39.123241300000004)	kansas city	ks	us	t	-94.9084171	39.202911	-94.5882049	39.0435716
beqQD1UufA	2022-05-09 20:00:29.251+00	2022-05-09 20:00:29.35+00	\N	\N	(32.356019200000006,-27.849509750000003)	the big five false bay local municipality	nl	za	t	32.0329399	-27.5458396	32.6790985	-28.1531799
VMMd35L5Ml	2022-05-09 20:00:29.271+00	2022-05-09 20:00:29.373+00	\N	\N	(-106.41746549999999,31.811850049999997)	el paso	tx	us	t	-106.6357782	32.001484	-106.1991528	31.6222161
vBHRjSYbth	2022-05-17 07:26:25.945+00	2022-05-17 07:26:26.045+00	\N	\N	(-84.2299064,40.039989500000004)	miami county	oh	us	t	-84.4365588	40.199879	-84.023254	39.8801
OEkDEVzmMD	2022-05-17 07:26:26.274+00	2022-05-17 07:26:26.375+00	\N	\N	(-94.6843704,38.9165331)	overland park	ks	us	t	-94.7610708	39.0440703	-94.60767	38.7889959
kTYiLYUICn	2022-05-17 07:26:26.56+00	2022-05-17 07:26:26.66+00	\N	\N	(-74.283391,40.54980245)	woodbridge township	nj	us	t	-74.338493	40.6089876	-74.228289	40.4906173
fLqoCikh6v	2022-05-17 07:26:26.859+00	2022-05-17 07:26:26.959+00	\N	\N	(-77.30183665,38.8522447)	fairfax	va	us	t	-77.3350493	38.871692	-77.268624	38.8327974
jXotpUXioI	2022-05-17 07:26:27.155+00	2022-05-17 07:26:27.255+00	\N	\N	(-105.06967845,40.55597915)	fort collins	co	us	t	-105.1573564	40.639352	-104.9820005	40.4726063
UIujIhRDWZ	2022-05-17 07:26:27.53+00	2022-05-17 07:26:27.631+00	\N	\N	(-85.84297805,42.907004549999996)	georgetown township	mi	us	t	-85.9038592	42.957933	-85.7820969	42.8560761
PXjkX8izn9	2022-05-17 07:26:28.053+00	2022-05-17 07:26:28.153+00	\N	\N	(-74.5303325,40.2588775)	east windsor township	nj	us	t	-74.579463	40.301054	-74.481202	40.216701
9AlYSiVZzC	2022-05-17 07:26:28.465+00	2022-05-17 07:26:28.566+00	\N	\N	(-118.29899605,33.78667605)	los angeles county	ca	us	t	-118.9517221	34.8233121	-117.64627	32.75004
0GEuFm15Zz	2022-05-17 07:26:28.798+00	2022-05-17 07:26:28.897+00	\N	\N	(36.87741245,-1.3039015)	nairobi	nairobi	ke	t	36.6509378	-1.163332	37.1038871	-1.444471
whymHoVNT5	2022-05-17 07:26:29.21+00	2022-05-17 07:26:29.31+00	\N	\N	(-84.886773,33.9286835)	paulding county	ga	us	t	-85.05031	34.082609	-84.723236	33.774758
pSpFvwMmwn	2022-05-17 07:26:29.63+00	2022-05-17 07:26:29.729+00	\N	\N	(-122.897162,47.039560949999995)	olympia	wa	us	t	-122.971077	47.0782592	-122.823247	47.0008627
ZAYGUArYSW	2022-05-17 07:26:29.913+00	2022-05-17 07:26:30.013+00	\N	\N	(-82.6548205,27.7787695)	saint petersburg	fl	us	t	-82.769023	27.913901	-82.540618	27.643638
4ukt4QfAh5	2022-05-17 07:26:30.229+00	2022-05-17 07:26:30.328+00	\N	\N	(-85.84420965,35.9788705)	dekalb county	tn	us	t	-86.058044	36.131912	-85.6303753	35.825829
0kXONUfKOf	2022-05-17 07:26:30.521+00	2022-05-17 07:26:30.622+00	\N	\N	(-77.87192200000001,34.207136000000006)	wilmington	nc	us	t	-77.956995	34.267026	-77.786849	34.147246
f11QHiIfC9	2022-05-17 07:26:30.967+00	2022-05-17 07:26:31.067+00	\N	\N	(-79.93533625,43.2605939)	hamilton	on	ca	t	-80.2485579	43.4706805	-79.6221146	43.0505073
1PBrVSPNTL	2022-05-17 07:26:31.243+00	2022-05-17 07:26:31.343+00	\N	\N	(28.758605000000003,-26.107725000000002)	victor khanye local municipality	mp	za	t	28.4905	-25.86973	29.02671	-26.34572
WbrOH74u0S	2022-05-17 07:26:31.765+00	2022-05-17 07:26:31.865+00	\N	\N	(-81.5999142,33.53651975)	aiken county	sc	us	t	-82.012527	33.875076	-81.1873014	33.1979635
IeS8Rosz2U	2022-05-17 07:26:32.215+00	2022-05-17 07:26:32.315+00	\N	\N	(31.261569899999998,-29.35383245)	kwadukuza local municipality	nl	za	t	31.0483699	-29.13588	31.4747699	-29.5717849
dmR4NDMfjd	2022-05-17 07:26:32.604+00	2022-05-17 07:26:32.703+00	\N	\N	(-149.89485200000001,61.216312900000005)	anchorage	ak	us	t	-150.054852	61.3763129	-149.734852	61.0563129
Mg3af8iVbz	2022-05-17 07:26:33.031+00	2022-05-17 07:26:33.131+00	\N	\N	(-83.33372990000001,44.424018000000004)	oscoda	mi	us	t	-83.3434	44.440706	-83.3240598	44.40733
vFUhIlw1WF	2022-05-17 07:26:33.306+00	2022-05-17 07:26:33.406+00	\N	\N	(-83.708247,37.584621999999996)	beattyville	ky	us	t	-83.724512	37.603201	-83.691982	37.566043
xSX37F26De	2022-05-17 07:26:33.626+00	2022-05-17 07:26:33.726+00	\N	\N	(-71.43736795000001,42.30520625)	framingham	ma	us	t	-71.4970456	42.3531309	-71.3776903	42.2572816
eX9v5mmilu	2022-05-17 07:26:33.937+00	2022-05-17 07:26:34.037+00	\N	\N	(-104.99502835000001,39.34781615)	douglas county	co	us	t	-105.329445	39.5661453	-104.6606117	39.129487
9gKHDtUX5d	2022-05-17 07:26:34.409+00	2022-05-17 07:26:34.509+00	\N	\N	(-2.07662165,51.8986037)	cheltenham	eng	gb	t	-2.1430198	51.9388732	-2.0102235	51.8583342
GLF0Z7fwO6	2022-05-17 07:26:34.771+00	2022-05-17 07:26:34.87+00	\N	\N	(-106.8194785,32.337077)	las cruces	nm	us	t	-106.973286	32.431869	-106.665671	32.242285
62rLEDEuXm	2022-05-17 07:26:35.087+00	2022-05-17 07:26:35.187+00	\N	\N	(26.062205,-27.285515)	maquassi hills local municipality	north west	za	t	25.61015	-26.83426	26.51426	-27.73677
Tu3yWR1Y21	2022-05-17 07:26:35.393+00	2022-05-17 07:26:35.494+00	\N	\N	(-112.03558749999999,33.043534300000005)	maricopa	az	us	t	-112.150781	33.0879436	-111.920394	32.999125
Jo48qHl02R	2022-05-17 07:26:35.787+00	2022-05-17 07:26:35.887+00	\N	\N	(-1.73398305,51.58758225)	swindon	eng	gb	t	-1.8651375	51.6927094	-1.6028286	51.4824551
LXCOS5f9tf	2022-05-17 07:26:36.18+00	2022-05-17 07:26:36.279+00	\N	\N	(-77.9299662,35.720638)	wilson county	nc	us	t	-78.1919334	35.868408	-77.667999	35.572868
DpU8jJ314X	2022-05-17 07:26:36.66+00	2022-05-17 07:26:36.76+00	\N	\N	(-90.40533715000001,30.612289750000002)	tangipahoa parish	la	us	t	-90.567429	31.0005133	-90.2432453	30.2240662
8jWw8f1Ah9	2022-05-17 07:26:37+00	2022-05-17 07:26:37.101+00	\N	\N	(30.873094950000002,-29.88485)	ethekwini metropolitan municipality	nl	za	t	30.5599999	-29.5011301	31.18619	-30.2685699
QpdquFGX3W	2022-05-17 07:26:37.292+00	2022-05-17 07:26:37.393+00	\N	\N	(-97.3869305,31.1039645)	temple	tx	us	t	-97.477125	31.177408	-97.296736	31.030521
Wkn4sLRANB	2022-05-17 07:26:37.613+00	2022-05-17 07:26:37.714+00	\N	\N	(-81.3892465,26.1432605)	collier county	fl	us	t	-81.905501	26.517069	-80.872992	25.769452
8CMIKitJ36	2022-05-17 07:26:37.982+00	2022-05-17 07:26:38.082+00	\N	\N	(35.49720805,32.49595925)	beit shean	north district	il	t	35.485578	32.5078405	35.5088381	32.484078
PtShPTQTSz	2022-05-17 07:26:38.335+00	2022-05-17 07:26:38.435+00	\N	\N	(-85.0287065,33.036685)	lagrange	ga	us	t	-85.10746	33.107495	-84.949953	32.965875
mMHNOgrLsn	2022-05-17 07:26:38.602+00	2022-05-17 07:26:38.702+00	\N	\N	(26.073561599999998,44.6223547)	balotești		ro	t	26.0042533	44.6607447	26.1428699	44.5839647
ti29fUjedz	2022-05-17 07:26:38.964+00	2022-05-17 07:26:39.063+00	\N	\N	(-92.72993324999999,44.963556499999996)	hudson	wi	us	t	-92.7704644	44.989177	-92.6894021	44.937936
pgBSiecrtb	2022-05-17 07:26:39.438+00	2022-05-17 07:26:39.539+00	\N	\N	(5.0322516,47.33186635)	dijon	bfc	fr	t	4.9624434	47.377486	5.1020598	47.2862467
C8lhzGudGE	2022-05-17 07:26:39.929+00	2022-05-17 07:26:40.029+00	\N	\N	(-2.47753935,51.809009)	forest of dean	eng	gb	t	-2.6875372	52.023885	-2.2675415	51.594133
b9EjVKAdvE	2022-05-17 07:26:40.18+00	2022-05-17 07:26:40.28+00	\N	\N	(-91.70215675,41.48587225)	kalona	ia	us	t	-91.7190766	41.4967926	-91.6852369	41.4749519
OQBPnEcedD	2022-05-17 07:26:40.51+00	2022-05-17 07:26:40.609+00	\N	\N	(-84.1154975,37.13742475)	laurel county	ky	us	t	-84.368446	37.3358925	-83.862549	36.938957
r5yOrDZQcg	2022-05-09 19:45:37.632+00	2022-05-09 20:00:20.226+00	\N	\N	(-117.55787799999999,34.1283672)	rancho cucamonga	ca	us	t	-117.6368438	34.1795363	-117.4789122	34.0771981
grBF6gKgyu	2022-05-09 20:00:20.265+00	2022-05-09 20:00:20.365+00	\N	\N	(-1.7137601999999998,54.8750078)	stanley	eng	gb	t	-1.7740375	54.9095526	-1.6534829	54.840463
cwP3EvGM2Q	2022-05-09 20:00:20.285+00	2022-05-09 20:00:20.384+00	\N	\N	(-78.77169645,39.6429206)	ridgeley	wv	us	t	-78.7782908	39.6484289	-78.7651021	39.6374123
a1RjDQ5kVY	2022-05-09 20:00:20.351+00	2022-05-09 20:00:20.45+00	\N	\N	(-2.3674184,53.4790153)	salford	eng	gb	t	-2.4897303	53.5421391	-2.2451065	53.4158915
7vk2ZjQiq1	2022-05-09 20:00:20.194+00	2022-05-09 20:00:20.456+00	\N	\N	(115.65129984999999,-32.0576293)	city of cockburn	wa	au	t	115.3864467	-31.9338696	115.916153	-32.181389
JayH9DHcdu	2022-05-09 20:00:20.388+00	2022-05-09 20:00:20.488+00	\N	\N	(-120.6517458,35.1046139)	grover beach	ca	us	t	-120.699107	35.1343688	-120.6043846	35.074859
95875khkPu	2022-05-09 20:00:20.41+00	2022-05-09 20:00:20.511+00	\N	\N	(29.727074950000002,-28.4225444)	emnambithi/ladysmith local municipality	nl	za	t	29.37556	-28.0744889	30.0785899	-28.7705999
s0sMQ9AAOV	2022-05-09 20:00:25.662+00	2022-05-09 20:00:55.54+00	\N	\N	(18.44887215,-33.717731)	melkbosstrand	wc	za	t	18.4352707	-33.6975066	18.4624736	-33.7379554
rCZOnIxFQK	2022-05-09 20:00:25.569+00	2022-05-09 20:00:25.675+00	\N	\N	(29.933424950000003,-27.696504949999998)	newcastle local municipality	nl	za	t	29.6538	-27.37653	30.2130499	-28.0164799
BvDg2EM4Vf	2022-05-09 20:00:55.704+00	2022-05-09 20:00:55.816+00	\N	\N	(-79.58648099999999,40.014668)	connellsville	pa	us	t	-79.608486	40.027869	-79.564476	40.001467
g3A3K69YLK	2022-05-09 20:00:55.739+00	2022-05-09 20:00:55.84+00	\N	\N	(-115.26167735,36.10003315)	spring valley	nv	us	t	-115.315484	36.1445327	-115.2078707	36.0555336
00I5fm6HX9	2022-04-24 23:26:13.104+00	2022-05-09 20:00:55.939+00	\N	\N	(18.417396,-33.928991999999994)	cape town	wc	za	t	18.257396	-33.768992	18.577396	-34.088992
Cdtc99midw	2022-05-09 20:00:25.463+00	2022-05-09 20:00:56.004+00	\N	\N	(18.976065,-33.928375)	stellenbosch local municipality	wc	za	t	18.70833	-33.79336	19.2438	-34.06339
J2uScFzERC	2022-05-09 21:23:42.31+00	2022-05-09 21:23:42.408+00	\N	\N	(21.2194268,45.75899975)	timișoara		ro	t	21.1116841	45.8341742	21.3271695	45.6838253
2LXZBZe0D4	2022-05-09 20:00:26.056+00	2022-05-09 20:00:26.156+00	\N	\N	(31.41437805,-24.584318500000002)	bushbuckridge	mp	za	t	30.79504	-23.98124	32.0337161	-25.187397
W1HZgjigEq	2022-05-09 20:00:26.089+00	2022-05-09 20:00:26.19+00	\N	\N	(18.6612014,-33.830072799999996)	durbanville	wc	za	t	18.6248455	-33.8008553	18.6975573	-33.8592903
HaK0Vot5aF	2022-05-09 21:52:31.77+00	2022-05-09 21:52:31.87+00	\N	\N	(-84.573864,33.3879825)	peachtree city	ga	us	t	-84.62614	33.448434	-84.521588	33.327531
BUogr1sWW1	2022-05-17 07:26:40.935+00	2022-05-17 07:26:41.034+00	\N	\N	(-98.42545865,34.602923849999996)	lawton	ok	us	t	-98.5364913	34.694351	-98.314426	34.5114967
2fMjC0c7Pj	2022-05-17 07:26:41.229+00	2022-05-17 07:26:41.328+00	\N	\N	(4.7063369,51.8347438)	papendrecht	south holland	nl	t	4.6691594	51.8490933	4.7435144	51.8203943
a9ThquuMcX	2022-05-09 20:00:28.992+00	2022-05-09 20:00:29.092+00	\N	\N	(-1.4406560000000002,53.22265615)	north east derbyshire	eng	gb	t	-1.5993013	53.3419738	-1.2820107	53.1033385
PtJljQ1cGm	2022-05-17 07:26:41.569+00	2022-05-17 07:26:41.668+00	\N	\N	(-1.22158245,54.55108035)	middlesbrough	eng	gb	t	-1.2824988	54.5914007	-1.1606661	54.51076
KaGdR14RYJ	2022-05-17 07:26:41.918+00	2022-05-17 07:26:42.018+00	\N	\N	(1.8503765,41.25479865)	sitges	catalonia	es	t	1.7562044	41.2910086	1.9445486	41.2185887
3AGUHLWHRP	2022-05-09 20:00:25.75+00	2022-05-09 20:00:25.851+00	\N	\N	(-95.5668259,29.048550749999997)	brazoria	tx	us	t	-95.5905838	29.074149	-95.543068	29.0229525
YTRI4iSmxZ	2022-05-17 07:26:42.363+00	2022-05-17 07:26:42.462+00	\N	\N	(45.3419183,2.0349312)	mogadishu	bn	so	t	45.1819183	2.1949312	45.5019183	1.8749312
EzNFHEgKbS	2022-05-17 07:26:45.088+00	2022-05-17 07:26:45.189+00	\N	\N	(-96.29210025,30.587444249999997)	college station	tx	us	t	-96.3876547	30.6584084	-96.1965458	30.5164801
CESCaCDc1o	2022-05-09 20:00:29.189+00	2022-05-09 20:00:29.289+00	\N	\N	(-99.14164845,30.031566750000003)	kerrville	tx	us	t	-99.2116383	30.1013337	-99.0716586	29.9617998
SDBEcHjwyj	2022-05-09 20:00:29.226+00	2022-05-09 20:00:29.325+00	\N	\N	(-79.867338,35.71817515)	asheboro	nc	us	t	-79.969947	35.791578	-79.764729	35.6447723
r7QfQPkREr	2022-05-17 07:26:42.659+00	2022-05-17 07:26:42.759+00	\N	\N	(-90.40397005,31.174989699999998)	pike county	ms	us	t	-90.5483153	31.350258	-90.2596248	30.9997214
reGyq9ySi0	2022-05-09 20:00:29.255+00	2022-05-09 20:00:29.356+00	\N	\N	(-86.621362,32.8433325)	clanton	al	us	t	-86.683047	32.89961	-86.559677	32.787055
wZFsHQZaAH	2022-05-17 07:26:43.055+00	2022-05-17 07:26:43.156+00	\N	\N	(-94.54079575,38.8150375)	belton	mo	us	t	-94.5914239	38.846177	-94.4901676	38.783898
pIORAC996d	2022-05-17 07:26:43.447+00	2022-05-17 07:26:43.546+00	\N	\N	(23.789385,-33.25302045)	baviaans local municipality	ec	za	t	22.73574	-32.727586	24.84303	-33.7784549
DpDSQjEpII	2022-05-17 07:26:43.718+00	2022-05-17 07:26:43.816+00	\N	\N	(-74.314905,40.46295485)	sayreville	nj	us	t	-74.386158	40.509307	-74.243652	40.4166027
sF3EtvPjGo	2022-05-17 07:26:44.099+00	2022-05-17 07:26:44.198+00	\N	\N	(5.48973915,50.9669103)	genk	vli	be	t	5.3843163	51.0207714	5.595162	50.9130492
SWiqpDgGPz	2022-05-17 07:26:44.403+00	2022-05-17 07:26:44.503+00	\N	\N	(-94.81887,38.8838856)	olathe	ks	us	t	-94.97887	39.0438856	-94.65887	38.7238856
Ai5L9ORMgG	2022-05-17 07:26:44.756+00	2022-05-17 07:26:44.856+00	\N	\N	(-78.63651,43.026034499999994)	town of clarence	ny	us	t	-78.696952	43.097401	-78.576068	42.954668
LRGkkPw2HK	2022-05-17 10:01:19.432+00	2022-05-17 10:01:19.533+00	\N	\N	(-80.13847325,26.251819400000002)	pompano beach	fl	us	t	-80.1956115	26.2976628	-80.081335	26.205976
0227HRkktE	2022-05-17 10:01:19.724+00	2022-05-17 10:01:19.825+00	\N	\N	(-70.77546459999999,43.05658135)	portsmouth	nh	us	t	-70.8229994	43.0996118	-70.7279298	43.0135509
wxeor48mCu	2022-05-17 10:01:20.02+00	2022-05-17 10:01:20.12+00	\N	\N	(-79.426354,40.2929255)	unity township	pa	us	t	-79.542615	40.380104	-79.310093	40.205747
PV2x4QGMxA	2022-05-17 10:01:20.436+00	2022-05-17 10:01:20.536+00	\N	\N	(118.15740555,24.47367445)	lianqian subdistrict	fujian	cn	t	118.1130212	24.5062256	118.2017899	24.4411233
HZWeWgTGSN	2022-05-17 10:01:20.729+00	2022-05-17 10:01:20.83+00	\N	\N	(-97.1366195,37.577645000000004)	rose hill	ks	us	t	-97.152833	37.60685	-97.120406	37.54844
7d1M5RawP3	2022-05-17 10:01:20.981+00	2022-05-17 10:01:21.08+00	\N	\N	(-79.2787895,39.97666545)	middlecreek township	pa	us	t	-79.347581	40.0404899	-79.209998	39.912841
6DUq0nE0J6	2022-05-17 10:01:21.291+00	2022-05-17 10:01:21.391+00	\N	\N	(26.66873655,59.463942450000005)	viru-nigula vald		ee	t	26.3763254	59.5548079	26.9611477	59.373077
vU90Uc0rtu	2022-05-17 10:01:21.681+00	2022-05-17 10:01:21.781+00	\N	\N	(-80.638726,24.9297685)	islamorada	fl	us	t	-80.748061	25.014777	-80.529391	24.84476
flyCKdOLiO	2022-05-17 10:01:22.158+00	2022-05-17 10:01:22.259+00	\N	\N	(121.64451925,24.98644995)	new taipei		tw	t	121.2826336	25.2997353	122.0064049	24.6731646
VUhMRVsqPE	2022-05-17 10:01:22.468+00	2022-05-17 10:01:22.568+00	\N	\N	(-123.66910005,48.84487685)	north cowichan	bc	ca	t	-123.7843632	48.9366199	-123.5538369	48.7531338
GqalYLuF3j	2022-05-17 10:01:22.746+00	2022-05-17 10:01:22.846+00	\N	\N	(-71.2786405,42.29885135)	wellesley	ma	us	t	-71.3297504	42.3280895	-71.2275306	42.2696132
zWxtuoAW0x	2022-05-17 10:01:23.078+00	2022-05-17 10:01:23.176+00	\N	\N	(-93.2046795,45.165079)	blaine	mn	us	t	-93.266938	45.211589	-93.142421	45.118569
4lGt9XGEHQ	2022-05-17 10:01:23.466+00	2022-05-17 10:01:23.565+00	\N	\N	(-94.34419965000001,35.3543351)	fort smith	ar	us	t	-94.4355398	35.4498153	-94.2528595	35.2588549
3HUMPPc73o	2022-05-17 10:01:23.862+00	2022-05-17 10:01:23.962+00	\N	\N	(-106.9606053,44.77896695)	sheridan county	wy	us	t	-107.9115622	45.0012394	-106.0096484	44.5566945
ijBuJwbH2I	2022-05-17 10:01:24.217+00	2022-05-17 10:01:24.317+00	\N	\N	(-85.4977036,41.1483985)	whitley county	in	us	t	-85.687637	41.295029	-85.3077702	41.001768
ikW2Klm4NX	2022-05-17 10:01:24.659+00	2022-05-17 10:01:24.759+00	\N	\N	(-90.3584952,29.961275999999998)	st. charles parish	la	us	t	-90.5496394	30.230524	-90.167351	29.692028
iocz1kilf7	2022-05-17 10:01:24.997+00	2022-05-17 10:01:25.097+00	\N	\N	(-117.5784922,33.8580895)	corona	ca	us	t	-117.673177	33.9161643	-117.4838074	33.8000147
SXlr5696SK	2022-05-17 10:01:25.364+00	2022-05-17 10:01:25.463+00	\N	\N	(31.64448415,-25.4764165)	nkomazi	mp	za	t	31.25716	-24.953233	32.0318083	-25.9996
Od2DGOXXcd	2022-05-17 10:01:25.674+00	2022-05-17 10:01:25.773+00	\N	\N	(-101.80501050000001,35.1982407)	amarillo	tx	us	t	-101.956244	35.2944807	-101.653777	35.1020007
lqDcRBIPy4	2022-05-17 10:01:26.163+00	2022-05-17 10:01:26.263+00	\N	\N	(-68.0119167,10.269675)	naguanagua	carabobo state	ve	t	-68.1719167	10.429675	-67.8519167	10.109675
e76sn3PvKx	2022-05-09 20:00:29.088+00	2022-05-09 20:00:29.198+00	\N	\N	(-86.0980777,43.7720718)	colfax township	mi	us	t	-86.1583056	43.8160046	-86.0378498	43.728139
RiYDDCqATR	2022-05-09 20:00:29.146+00	2022-05-09 20:00:29.247+00	\N	\N	(-157.80110474999998,21.32850475)	honolulu	hi	us	t	-157.9535818	21.4021936	-157.6486277	21.2548159
tnxLd56zfq	2022-05-09 20:00:29.165+00	2022-05-09 20:00:29.269+00	\N	\N	(28.67385,-23.872844999999998)	mogalakwena local municipality	lp	za	t	28.11351	-23.33091	29.23419	-24.41478
oQedk1ArP7	2022-05-09 20:00:29.243+00	2022-05-09 20:00:29.343+00	\N	\N	(-83.98397965000001,43.50180855000001)	kochville township	mi	us	t	-84.0518752	43.5240671	-83.9160841	43.47955
xR8rMqjppk	2022-05-09 20:00:20.127+00	2022-05-09 20:00:55.817+00	\N	\N	(-75.11806455,40.00248215)	philadelphia	pa	us	t	-75.2802977	40.1379593	-74.9558314	39.867005
VUoOuCUNHV	2022-05-09 20:00:55.748+00	2022-05-09 20:00:55.847+00	\N	\N	(-105.77992499999999,39.881347500000004)	winter park	co	us	t	-105.812018	39.930462	-105.747832	39.832233
GJAfhxUprj	2022-05-09 20:00:55.787+00	2022-05-09 20:00:55.888+00	\N	\N	(-83.4837695,42.219852200000005)	van buren township	mi	us	t	-83.544463	42.265351	-83.423076	42.1743534
Ywu7NAr6pm	2022-05-09 21:53:47.637+00	2022-05-09 21:53:47.737+00	\N	\N	(-81.2292962,35.68868445)	catawba county	nc	us	t	-81.533411	35.8294061	-80.9251814	35.5479628
OQtjNyyQqt	2022-05-09 20:00:55.711+00	2022-05-09 20:08:36.496+00	\N	\N	(28.1879444,-25.7459374)	pretoria	gt	za	t	28.0279444	-25.5859374	28.3479444	-25.9059374
wTvNeux4k1	2022-05-09 21:24:18.414+00	2022-05-09 21:24:18.514+00	\N	\N	(-73.67987185,43.36719745)	queensbury	ny	us	t	-73.764792	43.4824391	-73.5949517	43.2519558
eq2iHyhXbj	2022-05-09 21:24:26.131+00	2022-05-09 21:24:26.231+00	\N	\N	(-83.472618,36.045399)	jefferson county	tn	us	t	-83.710556	36.192074	-83.23468	35.898724
BEOD56uPYr	2022-05-09 21:24:29.997+00	2022-05-09 21:24:30.097+00	\N	\N	(-104.75849984999999,38.8752882)	colorado springs	co	us	t	-104.9170862	39.0351247	-104.5999135	38.7154517
lJDJJ4Dk0c	2022-05-09 21:24:33.218+00	2022-05-09 21:24:33.318+00	\N	\N	(-77.119777,39.0407093)	north bethesda	md	us	t	-77.155176	39.0743828	-77.084378	39.0070358
wpp8g431Fw	2022-05-09 21:24:37.605+00	2022-05-09 21:24:37.705+00	\N	\N	(-90.42696559999999,38.6392867)	saint louis county	mo	us	t	-90.7362242	38.8921602	-90.117707	38.3864132
bnCIcArHQp	2022-05-09 21:52:59.675+00	2022-05-09 21:52:59.775+00	\N	\N	(-80.839829,35.2031535)	charlotte	nc	us	t	-81.009554	35.393133	-80.670104	35.013174
YtaJZ87NJl	2022-05-09 21:53:10.053+00	2022-05-09 21:53:10.153+00	\N	\N	(-74.43740685,40.8635485)	parsippany-troy hills	nj	us	t	-74.5340276	40.902059	-74.3407861	40.825038
cHnqwiLKKu	2022-05-09 21:53:13.028+00	2022-05-09 21:53:13.129+00	\N	\N	(-71.496841,42.75286785)	nashua	nh	us	t	-71.5613907	42.8058627	-71.4322913	42.699873
YCtbsnBYlf	2022-05-09 21:53:15.364+00	2022-05-09 21:53:15.464+00	\N	\N	(12.66568255,55.62258385)	tårnby kommune	capital region of denmark	dk	t	12.5087921	55.672682	12.822573	55.5724857
26U549IRmu	2022-05-09 21:53:18.171+00	2022-05-09 21:53:18.271+00	\N	\N	(26.096125649999998,44.4378215)	bucharest		ro	t	25.9666745	44.5413964	26.2255768	44.3342466
D2MmDW3m8z	2022-05-09 21:53:21.65+00	2022-05-09 21:53:21.75+00	\N	\N	(-92.162405,38.5711939)	jefferson city	mo	us	t	-92.287547	38.6176948	-92.037263	38.524693
8aj5VuLDdK	2022-05-09 21:53:25.127+00	2022-05-09 21:53:25.226+00	\N	\N	(-77.4601839,38.4163635)	stafford county	va	us	t	-77.634155	38.590603	-77.2862128	38.242124
1CXLwH6vXb	2022-05-09 21:53:27.234+00	2022-05-09 21:53:27.334+00	\N	\N	(30.86419995,-22.87959625)	thulamela local municipality	lp	za	t	30.1647999	-22.5349097	31.5636	-23.2242828
MPLOv6B5tY	2022-05-09 21:53:29.018+00	2022-05-09 21:53:29.118+00	\N	\N	(3.93431555,6.47180295)	ibeju lekki	la	ng	t	3.6260536	6.5630188	4.2425775	6.3805871
bxJMI7kHs5	2022-05-09 21:53:31.021+00	2022-05-09 21:53:31.121+00	\N	\N	(-105.0609353,40.407469)	loveland	co	us	t	-105.1597946	40.465872	-104.962076	40.349066
ya1xAlqYRB	2022-05-09 21:53:33.131+00	2022-05-09 21:53:33.231+00	\N	\N	(25.1796805,37.0811568)	δήμος πάρου	aegean	gr	t	25.0602409	37.1946337	25.2991201	36.9676799
ZDpAgKLpTr	2022-05-09 21:53:38.577+00	2022-05-09 21:53:38.675+00	\N	\N	(-77.3455985,38.0539335)	bowling green	va	us	t	-77.361262	38.070404	-77.329935	38.037463
G052Pg3v5G	2022-05-09 21:53:43.521+00	2022-05-09 21:53:43.622+00	\N	\N	(135.718724,35.09806835)	kyoto		jp	t	135.559006	35.3212207	135.878442	34.874916
esQynck9O1	2022-05-09 21:53:45.614+00	2022-05-09 21:53:45.714+00	\N	\N	(24.73822655,59.471692250000004)	tallinn		ee	t	24.55017	59.5915769	24.9262831	59.3518076
aF6tSyFyN3	2022-05-09 21:53:54.306+00	2022-05-09 21:53:54.406+00	\N	\N	(-146.2759795,64.8561645)	fairbanks north star	ak	us	t	-148.667164	65.454475	-143.884795	64.257854
2BsnQm4RyD	2022-05-09 21:53:56.528+00	2022-05-09 21:53:56.628+00	\N	\N	(-82.9907458,39.9830009)	columbus	oh	us	t	-83.2101797	40.1573082	-82.7713119	39.8086936
2iyKiDCrqe	2022-05-09 21:53:58.68+00	2022-05-09 21:53:58.78+00	\N	\N	(-85.47232414999999,42.2888677)	charter township of comstock	mi	us	t	-85.5311345	42.3328044	-85.4135138	42.244931
nJVz5dcCMG	2022-05-09 21:53:59.504+00	2022-05-09 21:53:59.603+00	\N	\N	(-106.946539,39.171934)	pitkin county	co	us	t	-107.466095	39.366177	-106.426983	38.977691
jxmm6Dk4IU	2022-05-09 21:54:00.935+00	2022-05-09 21:54:01.034+00	\N	\N	(-124.9825812,49.693852899999996)	courtenay	bc	ca	t	-125.0320134	49.7408142	-124.933149	49.6468916
AZVHDoaDoZ	2022-05-17 07:26:45.547+00	2022-05-17 07:26:45.648+00	\N	\N	(-85.2336584,34.3322735)	floyd county	ga	us	t	-85.4620818	34.58683	-85.005235	34.077717
OW54TbqIDK	2022-05-17 07:26:45.83+00	2022-05-17 07:26:45.93+00	\N	\N	(-86.13319755,32.58766445)	elmore county	al	us	t	-86.4132775	32.769295	-85.8531176	32.4060339
uzNCnbZwtz	2022-05-17 07:26:46.132+00	2022-05-17 07:26:46.232+00	\N	\N	(-72.8409181,45.71909925)	saint-simon	qc	ca	t	-72.909988	45.7816433	-72.7718482	45.6565552
c5CcCuZj7S	2022-05-17 07:26:46.555+00	2022-05-17 07:26:46.655+00	\N	\N	(31.56451925,30.034611499999997)	cairo	cairo	eg	t	31.2200331	30.3209168	31.9090054	29.7483062
8JTESXHLS8	2022-05-17 07:26:46.895+00	2022-05-17 07:26:46.995+00	\N	\N	(-83.1054539,42.505405)	madison heights	mi	us	t	-83.1263857	42.534792	-83.0845221	42.476018
jWEJTxV643	2022-05-17 07:26:47.375+00	2022-05-17 07:26:47.475+00	\N	\N	(9.78839095,4.028097300000001)	douala iii	lt	cm	t	9.7123698	4.1157263	9.8644121	3.9404683
YgLBddkxnL	2022-05-17 07:26:47.646+00	2022-05-17 07:26:47.746+00	\N	\N	(-123.1335937,49.173990849999996)	richmond	bc	ca	t	-123.3099703	49.2619422	-122.9572171	49.0860395
mPWTl9GqiS	2022-05-17 07:26:48.071+00	2022-05-17 07:26:48.172+00	\N	\N	(-94.468407,38.996663999999996)	raytown	mo	us	t	-94.499178	39.029681	-94.437636	38.963647
oVcujUCBjr	2022-05-17 07:26:48.47+00	2022-05-17 07:26:48.57+00	\N	\N	(-78.32815120000001,44.31555805)	peterborough	on	ca	t	-78.3879706	44.3784864	-78.2683318	44.2526297
OBWdld6j2U	2022-05-17 07:26:48.901+00	2022-05-17 07:26:49+00	\N	\N	(-71.34143904999999,46.8541948)	quebec city	qc	ca	t	-71.5492175	46.9806797	-71.1336606	46.7277099
MtqjrrCcAK	2022-05-17 07:26:49.234+00	2022-05-17 07:26:49.333+00	\N	\N	(-119.4082439,46.281689799999995)	benton county	wa	us	t	-119.8770436	46.727396	-118.9394442	45.8359836
1vPD5WKGJe	2022-05-17 07:26:49.591+00	2022-05-17 07:26:49.691+00	\N	\N	(-111.99716365,40.60304095)	west jordan	ut	us	t	-112.0825853	40.6401398	-111.911742	40.5659421
Hzakg1gZHx	2022-05-17 07:26:49.985+00	2022-05-17 07:26:50.085+00	\N	\N	(174.5810061,-36.2889232)	rodney	auk	nz	t	173.8963284	-35.6983921	175.2656838	-36.8794543
vqhWNpz52G	2022-05-17 07:26:50.308+00	2022-05-17 07:26:50.407+00	\N	\N	(6.8498562,50.874225499999994)	hürth	north rhine-westphalia	de	t	6.7764643	50.9115756	6.9232481	50.8368754
WywIVqawUS	2022-05-17 07:26:50.585+00	2022-05-17 07:26:50.685+00	\N	\N	(-72.1609378,43.92318315)	fairlee	vt	us	t	-72.2224514	43.9746576	-72.0994242	43.8717087
33NhHhAUQe	2022-05-17 07:26:51.053+00	2022-05-17 07:26:51.153+00	\N	\N	(-72.6692276,40.93287465)	suffolk county	ny	us	t	-73.5474832	41.310504	-71.790972	40.5552453
hg4wJLM3oC	2022-05-17 07:26:51.589+00	2022-05-17 07:26:51.688+00	\N	\N	(13.42475295,52.50687675)	berlin		de	t	13.088345	52.6755087	13.7611609	52.3382448
9fhiZbpf1k	2022-05-17 07:26:51.928+00	2022-05-17 07:26:52.028+00	\N	\N	(-95.2145559,30.744529)	point blank	tx	us	t	-95.2345138	30.759492	-95.194598	30.729566
EkblNc7qHz	2022-05-17 07:26:52.251+00	2022-05-17 07:26:52.351+00	\N	\N	(151.7812534,-32.9272881)	newcastle	nsw	au	t	151.6212534	-32.7672881	151.9412534	-33.0872881
aMlLhqBzLp	2022-05-17 07:26:52.687+00	2022-05-17 07:26:52.786+00	\N	\N	(-70.2130245,-33.672005999999996)	provincia de cordillera	santiago metropolitan region	cl	t	-70.6558155	-33.05201	-69.7702335	-34.292002
Td0qUCKTw1	2022-05-17 07:26:53.082+00	2022-05-17 07:26:53.181+00	\N	\N	(138.63802385000002,-34.961269)	adelaide	sa	au	t	138.4281386	-34.572242	138.8479091	-35.350296
tH2Ah7vkMu	2022-05-17 07:26:53.431+00	2022-05-17 07:26:53.532+00	\N	\N	(-92.31679005,45.077179349999994)	town of emerald	wi	us	t	-92.3757163	45.1221708	-92.2578638	45.0321879
Foqav85SgW	2022-05-09 20:00:20.286+00	2022-05-09 20:00:20.386+00	\N	\N	(-76.5095075,42.4374155)	ithaca	ny	us	t	-76.573038	42.481164	-76.445977	42.393667
CET5yMp1Bf	2022-05-09 20:00:20.328+00	2022-05-09 20:00:20.423+00	\N	\N	(-94.8277997,29.19787145)	galveston	tx	us	t	-95.129935	29.399399	-94.5256644	28.9963439
WoWqn8KPKt	2022-05-09 20:00:25.652+00	2022-05-09 20:00:25.752+00	\N	\N	(18.191195,-33.01052585)	saldanha bay local municipality	wc	za	t	17.84384	-32.70041	18.53855	-33.3206417
FgXD2OhZAp	2022-05-09 20:00:29.083+00	2022-05-09 20:00:29.186+00	\N	\N	(-116.06122425000001,36.2055165)	pahrump	nv	us	t	-116.228019	36.409828	-115.8944295	36.001205
kieUHt1AFU	2022-05-09 20:00:29.217+00	2022-05-09 20:00:29.316+00	\N	\N	(-82.76134515000001,27.9925425)	clearwater	fl	us	t	-82.8434471	28.0499611	-82.6792432	27.9351239
DYQ2BlccSO	2022-05-09 20:00:29.372+00	2022-05-09 20:00:29.472+00	\N	\N	(-157.9616235,21.4005815)	pearl city	hi	us	t	-157.98908	21.43261	-157.934167	21.368553
Rk97Qhg1od	2022-05-17 07:26:55.243+00	2022-05-17 07:26:55.344+00	\N	\N	(30.3105149,-29.6347099)	msunduzi local municipality	nl	za	t	30.0771499	-29.5173999	30.5438799	-29.7520199
x8cphg3Vc0	2022-05-09 20:00:55.866+00	2022-05-09 20:00:55.966+00	\N	\N	(-84.35287794999999,33.943541499999995)	sandy springs	ga	us	t	-84.447543	34.010137	-84.2582129	33.876946
B7fCgz8dPf	2022-05-09 18:40:18.635+00	2022-05-09 20:00:55.997+00	\N	\N	(-122.23515065000001,37.759551)	oakland	ca	us	t	-122.355881	37.8854257	-122.1144203	37.6336763
LIlqVQ36IE	2022-05-09 20:00:55.959+00	2022-05-09 20:00:56.058+00	\N	\N	(-94.317105,30.374319999999997)	kountze	tx	us	t	-94.335476	30.397658	-94.298734	30.350982
mZRMLY1OcI	2022-05-09 21:28:45.132+00	2022-05-09 21:28:45.232+00	\N	\N	(-88.47757820000001,47.1920209)	osceola township	mi	us	t	-88.5314584	47.2713456	-88.423698	47.1126962
0pfqwOCpKv	2022-05-09 21:28:54.184+00	2022-05-09 21:28:54.284+00	\N	\N	(-115.13374365,36.060859050000005)	paradise	nv	us	t	-115.208162	36.137126	-115.0593253	35.9845921
3IqfCO88HE	2022-05-09 21:28:56.839+00	2022-05-09 21:28:56.939+00	\N	\N	(-83.17810614999999,42.4667833)	oak park	mi	us	t	-83.202384	42.488727	-83.1538283	42.4448396
5vC3QWOsNI	2022-05-09 21:29:02.731+00	2022-05-09 21:29:02.83+00	\N	\N	(-75.7044442,45.39454175)	(old) ottawa	on	ca	t	-75.816932	45.468688	-75.5919564	45.3203955
9i3MV6fDfb	2022-05-09 21:29:05.126+00	2022-05-09 21:29:05.226+00	\N	\N	(16.692918050000003,44.9797141)	приједор центар / prijedor centar	srp	ba	t	16.6586484	45.0031401	16.7271877	44.9562881
cAVfy8TyVh	2022-05-09 21:29:08.372+00	2022-05-09 21:29:08.472+00	\N	\N	(-119.677145,36.8647815)	clovis	ca	us	t	-119.732556	36.946598	-119.621734	36.782965
JaHOuCz5kp	2022-05-09 21:29:10.673+00	2022-05-09 21:29:10.772+00	\N	\N	(-105.09784965,40.1681733)	longmont	co	us	t	-105.1783773	40.2099583	-105.017322	40.1263883
Zgp3vSpuZy	2022-05-09 21:29:12.724+00	2022-05-09 21:29:12.824+00	\N	\N	(130.97232250000002,-12.495997500000001)	city of palmerston		au	t	130.930306	-12.444995	131.014339	-12.547
o145K4HaRo	2022-05-09 21:29:17.285+00	2022-05-09 21:29:17.385+00	\N	\N	(-118.73181805,34.26554045)	simi valley	ca	us	t	-118.8310988	34.3226657	-118.6325373	34.2084152
0Q0lkOtnE4	2022-05-09 21:29:21.31+00	2022-05-09 21:29:21.407+00	\N	\N	(-76.4455155,37.235991299999995)	york county	va	us	t	-76.755511	37.380139	-76.13552	37.0918436
7LcHmtcDPI	2022-05-09 21:29:23.439+00	2022-05-09 21:29:23.539+00	\N	\N	(-69.3149182,43.76719115)	monhegan island plantation	me	us	t	-69.3972103	43.8307062	-69.2326261	43.7036761
mxePJJHaVt	2022-05-09 21:29:25.735+00	2022-05-09 21:29:25.835+00	\N	\N	(-94.55204935,18.0060626)	cosoleacaque	veracruz	mx	t	-94.6898382	18.1422018	-94.4142605	17.8699234
NW5jaSTPbM	2022-05-09 21:29:28.198+00	2022-05-09 21:29:28.297+00	\N	\N	(-118.036849,34.0751571)	el monte	ca	us	t	-118.196849	34.2351571	-117.876849	33.9151571
7DPtiTX7rO	2022-05-09 21:29:30.484+00	2022-05-09 21:29:30.583+00	\N	\N	(-96.0380461,41.2015544)	ralston	ne	us	t	-96.0524055	41.2124668	-96.0236867	41.190642
XBu42uTjOY	2022-05-09 21:29:32.573+00	2022-05-09 21:29:32.673+00	\N	\N	(-79.9308525,40.29120005)	jefferson hills	pa	us	t	-79.985151	40.3298821	-79.876554	40.252518
hCSDzVuoMD	2022-05-09 21:29:37.402+00	2022-05-09 21:29:37.502+00	\N	\N	(-80.0508692,37.26577505)	roanoke county	va	us	t	-80.2621845	37.4224691	-79.8395539	37.109081
Q9g08UtJis	2022-05-09 22:02:37.691+00	2022-05-09 22:02:37.791+00	\N	\N	(-70.83962149999999,42.930552250000005)	hampton	nh	us	t	-70.901599	42.971088	-70.777644	42.8900165
cP5yXGdxD7	2022-05-17 07:26:53.772+00	2022-05-17 07:26:53.872+00	\N	\N	(-78.8817463,33.7193159)	myrtle beach	sc	us	t	-78.978024	33.791255	-78.7854686	33.6473768
pYoyXhw8ci	2022-05-17 07:26:54.277+00	2022-05-17 07:26:54.378+00	\N	\N	(-80.2674715,33.906269699999996)	sumter county	sc	us	t	-80.640816	34.1687636	-79.894127	33.6437758
B6lauw8E6c	2022-05-17 07:26:54.767+00	2022-05-17 07:26:54.867+00	\N	\N	(-116.8022615,47.7721325)	hayden	id	us	t	-116.851147	47.802574	-116.753376	47.741691
fLYaOxxFqc	2022-05-17 07:26:55.71+00	2022-05-17 07:26:55.809+00	\N	\N	(123.84179285,10.3710273)	cebu city	central visayas	ph	t	123.7533688	10.4957531	123.9302169	10.2463015
ha6nudEsar	2022-05-17 07:26:55.996+00	2022-05-17 07:26:56.096+00	\N	\N	(-74.3781872,40.53842965)	edison	nj	us	t	-74.4403224	40.605503	-74.316052	40.4713563
QsBLrvE0F9	2022-05-17 07:26:56.39+00	2022-05-17 07:26:56.491+00	\N	\N	(-122.75292425,49.2513682)	port coquitlam	bc	ca	t	-122.80737	49.2892694	-122.6984785	49.213467
0qdwwXcCWa	2022-05-17 07:26:56.727+00	2022-05-17 07:26:56.827+00	\N	\N	(-71.5506652,42.3457912)	marlborough	ma	us	t	-71.6258251	42.3806327	-71.4755053	42.3109497
m0z6QxGAox	2022-05-17 07:26:57.014+00	2022-05-17 07:26:57.113+00	\N	\N	(-111.85875215,40.87159615)	bountiful	ut	us	t	-111.902122	40.9102795	-111.8153823	40.8329128
lKq0HSrVpU	2022-05-17 07:26:57.299+00	2022-05-17 07:26:57.4+00	\N	\N	(-94.1622797,36.06914435)	fayetteville	ar	us	t	-94.2978481	36.1489329	-94.0267113	35.9893558
DhHj5uXimC	2022-05-17 07:26:57.839+00	2022-05-17 07:26:57.938+00	\N	\N	(73.98558765,15.2558852)	salcete	ga	in	t	73.8970167	15.3753225	74.0741586	15.1364479
47Fj11YrSQ	2022-05-17 07:26:58.319+00	2022-05-17 07:26:58.42+00	\N	\N	(-80.458177,25.5582731)	miami-dade county	fl	us	t	-80.8736	25.9791962	-80.042754	25.13735
ctCxEPbisu	2022-05-17 07:26:58.752+00	2022-05-17 07:26:58.852+00	\N	\N	(-100.03598099999999,27.322781300000003)	municipio de anáhuac	nle	mx	t	-100.4219092	27.7991372	-99.6500528	26.8464254
fwgYdnPn6b	2022-05-17 07:26:59.03+00	2022-05-17 07:26:59.13+00	\N	\N	(-110.9787602,32.40929715)	oro valley	az	us	t	-111.0300662	32.4819496	-110.9274542	32.3366447
F8CO154rKL	2022-05-17 07:26:59.344+00	2022-05-17 07:26:59.443+00	\N	\N	(27.7921996,-23.63372625)	lephalale local municipality	lp	za	t	26.9877892	-22.811517	28.59661	-24.4559355
hfh6O4KZid	2022-05-17 07:26:59.654+00	2022-05-17 07:26:59.754+00	\N	\N	(-84.1907898,42.36566035)	waterloo township	mi	us	t	-84.2504436	42.4247941	-84.131136	42.3065266
Q1w7pjVxRk	2022-05-17 07:26:59.949+00	2022-05-17 07:27:00.048+00	\N	\N	(-122.6327895,38.7530045)	middletown	ca	us	t	-122.664615	38.77236	-122.600964	38.733649
KYzPGpEQH5	2022-05-17 07:27:00.295+00	2022-05-17 07:27:00.396+00	\N	\N	(-103.720828,19.2451909)	colima	col	mx	t	-103.880828	19.4051909	-103.560828	19.0851909
SGwHQs3X19	2022-05-17 07:27:00.63+00	2022-05-17 07:27:00.73+00	\N	\N	(-78.9063366,37.7915999)	nelson county	va	us	t	-79.1719065	38.0475772	-78.6407667	37.5356226
K3aQjbLpxD	2022-05-17 07:27:01.066+00	2022-05-17 07:27:01.166+00	\N	\N	(-82.5654167,35.53627025)	asheville	nc	us	t	-82.6703643	35.6560763	-82.4604691	35.4164642
kz3o8yPg6v	2022-05-17 07:27:01.557+00	2022-05-17 07:27:01.656+00	\N	\N	(-122.19431245,40.7354148)	shasta county	ca	us	t	-123.0690573	41.185405	-121.3195676	40.2854246
In0y4thTiD	2022-05-17 10:01:26.584+00	2022-05-17 10:01:26.683+00	\N	\N	(20.090325,-31.138505000000002)	hantam local municipality	nc	za	t	18.87539	-29.60377	21.30526	-32.67324
mIicUEtPH0	2022-05-17 10:01:26.922+00	2022-05-17 10:01:27.022+00	\N	\N	(12.344855899999999,55.73039265)	ballerup municipality	capital region of denmark	dk	t	12.2635028	55.7634491	12.426209	55.6973362
L1CfS1ypXG	2022-05-17 10:01:27.223+00	2022-05-17 10:01:27.323+00	\N	\N	(-90.9790345,38.968036)	troy	mo	us	t	-91.023479	39.003495	-90.93459	38.932577
LAwA4AIJZw	2022-05-17 10:01:27.61+00	2022-05-17 10:01:27.71+00	\N	\N	(130.8410469,-12.46044)	darwin	0800	au	t	130.6810469	-12.30044	131.0010469	-12.62044
zonjOtAJG1	2022-05-17 10:01:28.017+00	2022-05-17 10:01:28.117+00	\N	\N	(-72.6403621,42.224145449999995)	holyoke	ma	us	t	-72.6905147	42.2862587	-72.5902095	42.1620322
GxTi0KYNPT	2022-05-17 10:01:28.479+00	2022-05-17 10:01:28.579+00	\N	\N	(-89.06895815,30.4201497)	gulfport	ms	us	t	-89.136708	30.5000969	-89.0012083	30.3402025
U20otBbQMa	2022-05-17 10:01:28.912+00	2022-05-17 10:01:29.012+00	\N	\N	(-123.1241015,49.257551)	vancouver	bc	ca	t	-123.2249611	49.3161714	-123.0232419	49.1989306
M44grpMea9	2022-05-17 10:01:29.373+00	2022-05-17 10:01:29.479+00	\N	\N	(-78.6167062,34.21466315)	columbus county	nc	us	t	-79.0712116	34.4848477	-78.1622008	33.9444786
I0CLtqRVt7	2022-05-09 20:00:20.294+00	2022-05-09 20:00:20.395+00	\N	\N	(-81.92198295,41.444540450000005)	westlake	oh	us	t	-81.970263	41.4780359	-81.8737029	41.411045
QNgETzXLb5	2022-05-09 20:00:25.465+00	2022-05-09 20:00:25.578+00	\N	\N	(18.976065,-33.928375)	stellenbosch local municipality	wc	za	t	18.70833	-33.79336	19.2438	-34.06339
IfbGIu3tOo	2022-05-09 20:00:25.485+00	2022-05-09 20:00:25.591+00	\N	\N	(29.94046495,-29.165169900000002)	mpofana local municipality	nl	za	t	29.5068	-28.9148999	30.3741299	-29.4154399
14AJGyKYdr	2022-05-09 20:00:25.493+00	2022-05-09 20:00:25.619+00	\N	\N	(29.6991275,-24.292202500000002)	lepelle-nkumpi local municipality	lp	za	t	29.03204	-23.94379	30.366215	-24.640615
UxqQYZsXWg	2022-05-09 20:00:25.565+00	2022-05-09 20:00:25.674+00	\N	\N	(27.8998573,-33.019160400000004)	east london	ec	za	t	27.7398573	-32.8591604	28.0598573	-33.1791604
cqWlemWeSo	2022-05-09 20:00:25.613+00	2022-05-09 20:00:25.714+00	\N	\N	(29.96649095,-27.9890699)	dannhauser local municipality	nl	za	t	29.616862	-27.7883599	30.3161199	-28.1897799
XG3Uy5Dz8V	2022-05-09 20:00:25.628+00	2022-05-09 20:00:25.734+00	\N	\N	(73.0923253,31.4220558)	faisalabad	pb	pk	t	72.9323253	31.5820558	73.2523253	31.2620558
rJ1EShLtMf	2022-05-09 20:00:25.693+00	2022-05-09 20:00:25.802+00	\N	\N	(-77.141792,42.04525195)	town of lindley	ny	us	t	-77.200464	42.090949	-77.08312	41.9995549
DJ2JH0RTEB	2022-05-09 20:00:25.911+00	2022-05-09 20:00:26.013+00	\N	\N	(-65.17116,47.2679915)	alnwick parish	nb	ca	t	-65.4614112	47.4490896	-64.8809088	47.0868934
XsmjVMzNDT	2022-05-09 20:00:26.15+00	2022-05-09 20:00:26.25+00	\N	\N	(-0.34110555,51.7685749)	st albans	eng	gb	t	-0.4406074	51.8495978	-0.2416037	51.687552
gX9BKBNCnB	2022-05-09 20:00:28.896+00	2022-05-09 20:00:29.016+00	\N	\N	(-95.1985637,42.642236600000004)	storm lake	ia	us	t	-95.2455006	42.669208	-95.1516268	42.6152652
z81FyQRpAJ	2022-05-09 20:00:28.928+00	2022-05-09 20:00:29.037+00	\N	\N	(-86.15248550000001,41.4480865)	bremen	in	us	t	-86.174688	41.460625	-86.130283	41.435548
mewEg9s77Y	2022-05-09 20:00:28.95+00	2022-05-09 20:00:29.053+00	\N	\N	(-1.45727215,54.87160635)	sunderland	eng	gb	t	-1.5688793	54.9441703	-1.345665	54.7990424
hYbeRstSHH	2022-05-09 20:00:29.284+00	2022-05-09 20:00:29.385+00	\N	\N	(-113.49265969999999,53.5267602)	edmonton	ab	ca	t	-113.7138411	53.7162646	-113.2714783	53.3372558
xFisFfpp0k	2022-05-09 20:00:29.079+00	2022-05-09 20:00:29.183+00	\N	\N	(-122.4292775,47.139855499999996)	parkland	wa	us	t	-122.469329	47.161152	-122.389226	47.118559
kqvuBeQo4R	2022-05-09 20:00:29.085+00	2022-05-09 20:00:29.196+00	\N	\N	(-2.54354385,51.19449725)	mendip	eng	gb	t	-2.8426859	51.3257085	-2.2444018	51.063286
8BHCNmQBb4	2022-05-09 20:00:29.106+00	2022-05-09 20:00:29.21+00	\N	\N	(-78.431905,42.0828635)	olean	ny	us	t	-78.463291	42.104406	-78.400519	42.061321
AZgivN8Y70	2022-05-09 20:00:29.113+00	2022-05-09 20:00:29.22+00	\N	\N	(-93.10606275,44.93964645)	saint paul	mn	us	t	-93.2078138	44.9920237	-93.0043117	44.8872692
356Tp287E5	2022-05-09 20:00:29.137+00	2022-05-09 20:00:29.237+00	\N	\N	(-158.009166,21.3866667)	waipahu	hi	us	t	-158.169166	21.5466667	-157.849166	21.2266667
Mgqf5fk5xc	2022-05-09 20:00:29.151+00	2022-05-09 20:00:29.258+00	\N	\N	(-77.0841585,38.890396100000004)	arlington	va	us	t	-77.2441585	39.0503961	-76.9241585	38.7303961
dYqLJmAajp	2022-05-09 20:00:29.02+00	2022-05-09 20:00:29.294+00	\N	\N	(19.274769999999997,-34.49445065)	overstrand local municipality	wc	za	t	18.80954	-34.2035279	19.74	-34.7853734
u1QXkSqddz	2022-05-09 20:00:29.245+00	2022-05-09 20:00:29.345+00	\N	\N	(138.7448933,-34.597331100000005)	gawler	sa	au	t	138.5848933	-34.4373311	138.9048933	-34.7573311
W9oVtrEkCI	2022-05-09 20:00:29.261+00	2022-05-09 20:00:29.361+00	\N	\N	(-94.704589,37.4169305)	pittsburg	ks	us	t	-94.741662	37.466417	-94.667516	37.367444
9vH6gTJYL1	2022-05-09 20:00:29.276+00	2022-05-09 20:00:29.376+00	\N	\N	(-118.15740084999999,33.9952459)	commerce	ca	us	t	-118.193514	34.0196169	-118.1212877	33.9708749
hGAXzrjV37	2022-05-09 20:00:29.298+00	2022-05-09 20:00:29.397+00	\N	\N	(-111.9400091,33.425505599999994)	tempe	az	us	t	-112.1000091	33.5855056	-111.7800091	33.2655056
OinTqMibuh	2022-05-09 20:00:29.327+00	2022-05-09 20:00:29.427+00	\N	\N	(-122.15501295,47.597900499999994)	bellevue	wa	us	t	-122.2228062	47.660788	-122.0872197	47.535013
bjWC9GS0JV	2022-05-09 20:00:29.341+00	2022-05-09 20:00:29.44+00	\N	\N	(-79.98062250000001,40.43136105)	pittsburgh	pa	us	t	-80.095517	40.5012021	-79.865728	40.36152
12f0k59hXo	2022-05-09 20:00:25.792+00	2022-05-09 20:00:29.687+00	\N	\N	(28.049722,-26.205)	johannesburg	gt	za	t	27.889722	-26.045	28.209722	-26.365
pLtGq1meRd	2022-05-09 20:01:21.421+00	2022-05-09 20:01:21.52+00	\N	\N	(-97.6176036,35.029673)	dibble	ok	us	t	-97.6705493	35.087899	-97.5646579	34.971447
Kd9s9AnGzd	2022-05-09 20:01:22.953+00	2022-05-09 20:01:23.053+00	\N	\N	(-2.4399607999999997,50.7116755)	dorchester	eng	gb	t	-2.4737587	50.7236302	-2.4061629	50.6997208
5iOiBsDbXF	2022-05-09 21:36:57.439+00	2022-05-09 21:36:57.539+00	\N	\N	(-88.25647475,43.0843435)	village of pewaukee	wi	us	t	-88.28828	43.1050934	-88.2246695	43.0635936
bYQC5PH9BZ	2022-05-09 21:37:00.673+00	2022-05-09 21:37:00.773+00	\N	\N	(-71.6055801,44.37504975)	whitefield	nh	us	t	-71.6867459	44.445293	-71.5244143	44.3048065
YSMnQD8wMf	2022-05-17 07:27:01.996+00	2022-05-17 07:27:02.096+00	\N	\N	(-77.66169385,38.18450905)	spotsylvania county	va	us	t	-77.9548896	38.3783298	-77.3684981	37.9906883
wZgqy8T7U9	2022-05-17 07:27:02.343+00	2022-05-17 07:27:02.444+00	\N	\N	(28.4277171,-26.14329205)	daveyton	gt	za	t	28.3976321	-26.120746	28.4578021	-26.1658381
A336u4PPlo	2022-05-17 07:27:02.696+00	2022-05-17 07:27:02.797+00	\N	\N	(-81.18930280000001,35.284179949999995)	gaston county	nc	us	t	-81.4556038	35.4198172	-80.9230018	35.1485427
FTThTp8M3R	2022-05-17 07:27:03+00	2022-05-17 07:27:03.1+00	\N	\N	(12.35779315,58.2178636)	trollhättans kommun		se	t	12.1354639	58.3405542	12.5801224	58.095173
yO7BDGiaK9	2022-05-17 07:27:03.428+00	2022-05-17 07:27:03.528+00	\N	\N	(-74.118745,40.936512199999996)	fair lawn	nj	us	t	-74.148171	40.955272	-74.089319	40.9177524
Hqq4F3ehbD	2022-05-17 07:27:03.91+00	2022-05-17 07:27:04.009+00	\N	\N	(-114.27454399999999,42.673013350000005)	jerome county	id	us	t	-114.617401	42.8511207	-113.931687	42.494906
v6Fpyf3n2L	2022-05-17 07:27:04.344+00	2022-05-17 07:27:04.443+00	\N	\N	(8.6583869,56.91469795)	thisted municipality	north denmark region	dk	t	8.2208505	57.1589524	9.0959233	56.6704435
EhCvRDLZvx	2022-05-17 07:27:04.664+00	2022-05-17 07:27:04.764+00	\N	\N	(17.0587443,-22.5585733)	windhoek	kh	na	t	16.9868681	-22.4784896	17.1306205	-22.638657
3V82pirrQ5	2022-05-17 07:27:04.99+00	2022-05-17 07:27:05.089+00	\N	\N	(-156.646693,20.868019500000003)	maui county	hi	us	t	-157.366549	21.278773	-155.926837	20.457266
oePgbQ9e3c	2022-05-17 07:27:05.408+00	2022-05-17 07:27:05.508+00	\N	\N	(-80.477074,35.6827402)	rowan county	nc	us	t	-80.7715826	35.8635158	-80.1825654	35.5019646
2ETmyJpRDu	2022-05-17 07:27:05.853+00	2022-05-17 07:27:05.952+00	\N	\N	(-82.508718,28.8591355)	citrus county	fl	us	t	-82.848248	29.0526	-82.169188	28.665671
zZA0w5GDyy	2022-05-17 07:27:06.276+00	2022-05-17 07:27:06.377+00	\N	\N	(30.35234995,-30.810214350000003)	hibiscus coast local municipality	nl	za	t	30.12002	-30.5373899	30.5846799	-31.0830388
PAHxFyVBUf	2022-05-17 07:27:06.677+00	2022-05-17 07:27:06.777+00	\N	\N	(-95.3060868,32.3492885)	tyler	tx	us	t	-95.4188842	32.4679055	-95.1932894	32.2306715
xye38PDpuc	2022-05-17 07:27:06.981+00	2022-05-17 07:27:07.081+00	\N	\N	(-82.4388405,27.8719645)	hillsborough county	fl	us	t	-82.823669	28.173379	-82.054012	27.57055
pX87MD6GbE	2022-05-17 07:27:07.339+00	2022-05-17 07:27:07.439+00	\N	\N	(-81.36756195000001,28.4811732)	orlando	fl	us	t	-81.5075377	28.614283	-81.2275862	28.3480634
euiZOhzXsz	2022-05-17 07:27:07.702+00	2022-05-17 07:27:07.801+00	\N	\N	(-94.969998,35.4983291)	vian	ok	us	t	-94.9793601	35.5069023	-94.9606359	35.4897559
nI70iZWgYi	2022-05-17 07:27:08.054+00	2022-05-17 07:27:08.153+00	\N	\N	(-105.98188755,35.52252685)	santa fe county	nm	us	t	-106.249219	36.00449	-105.7145561	35.0405637
AJ3RC7t8iR	2022-05-17 07:27:08.305+00	2022-05-17 07:27:08.405+00	\N	\N	(-111.91707745,40.3386814)	saratoga springs	ut	us	t	-111.9783908	40.4167308	-111.8557641	40.260632
2OL62Ls1nA	2022-05-17 07:27:08.702+00	2022-05-17 07:27:08.803+00	\N	\N	(78.63280485,12.453138899999999)	tirupathur	tn	in	t	78.4068193	12.649111	78.8587904	12.2571668
FNeFI5aR6z	2022-05-17 07:27:08.988+00	2022-05-17 07:27:09.088+00	\N	\N	(-83.18383045,36.84298135)	harlan county	ky	us	t	-83.511795	37.021211	-82.8558659	36.6647517
Lv7rOKepKx	2022-05-17 10:01:29.765+00	2022-05-17 10:01:29.864+00	\N	\N	(23.43327,-33.946775)	bitou local municipality	wc	za	t	23.16324	-33.78212	23.7033	-34.11143
IeVMBabJWW	2022-05-17 10:01:30.088+00	2022-05-17 10:01:30.188+00	\N	\N	(-86.0230321,40.1242015)	cicero	in	us	t	-86.037775	40.146731	-86.0082892	40.101672
uodWHJdY6C	2022-05-17 10:01:30.523+00	2022-05-17 10:01:30.622+00	\N	\N	(-93.79256670000001,41.5448633)	west des moines	ia	us	t	-93.8868692	41.60046	-93.6982642	41.4892666
mnWX2R5XNG	2022-05-17 10:01:40.428+00	2022-05-17 10:01:40.528+00	\N	\N	(-122.2541275,48.0333865)	priest point	wa	us	t	-122.298583	48.045496	-122.209672	48.021277
M5mGmB7gTd	2022-05-17 10:01:40.876+00	2022-05-17 10:01:40.977+00	\N	\N	(-74.91845525,41.3333667)	dingman township	pa	us	t	-75.0450833	41.3905683	-74.7918272	41.2761651
DLcx0XNnC4	2022-05-17 10:01:41.375+00	2022-05-17 10:01:41.478+00	\N	\N	(7.163751250000001,51.2419322)	wuppertal	north rhine-westphalia	de	t	7.0140725	51.3180616	7.31343	51.1658028
KWFxBzXJ8w	2022-05-17 10:01:41.765+00	2022-05-17 10:01:41.865+00	\N	\N	(153.26184690000002,-28.7936349)	lismore city council	nsw	au	t	153.0736578	-28.5158299	153.450036	-29.0714399
iPaIL2meZ0	2022-05-17 10:01:42.068+00	2022-05-17 10:01:42.168+00	\N	\N	(-95.5205095,35.8680405)	porter	ok	us	t	-95.528281	35.878436	-95.512738	35.857645
Cl6mLt0C40	2022-05-17 10:01:42.572+00	2022-05-17 10:01:42.672+00	\N	\N	(-75.9885629,40.836991499999996)	rush township	pa	us	t	-76.0687038	40.8785633	-75.908422	40.7954197
zAMns7NiEB	2022-05-17 10:01:42.942+00	2022-05-17 10:01:43.04+00	\N	\N	(28.8821851,-24.50326995)	mookgopong local municipality	lp	za	t	28.3638802	-24.02533	29.40049	-24.9812099
IUCkn0nM3o	2022-05-17 10:01:43.328+00	2022-05-17 10:01:43.424+00	\N	\N	(-71.2948127,41.9404258)	attleboro	ma	us	t	-71.381463	41.9873058	-71.2081624	41.8935458
k2biivN7Fz	2022-05-17 10:01:43.7+00	2022-05-17 10:01:43.801+00	\N	\N	(-112.4960605,42.866817499999996)	pocatello	id	us	t	-112.631862	42.931488	-112.360259	42.802147
fOhdOAD5zU	2022-05-17 10:01:44.033+00	2022-05-17 10:01:44.133+00	\N	\N	(-87.94366099999999,42.365644)	gurnee	il	us	t	-88.00303	42.403852	-87.884292	42.327436
WEEMdxYc99	2022-05-17 10:01:44.498+00	2022-05-17 10:01:44.598+00	\N	\N	(-78.008989,34.739759)	wallace	nc	us	t	-78.046617	34.757497	-77.971361	34.722021
Lf6KDNbYwN	2022-05-17 10:01:44.816+00	2022-05-17 10:01:44.916+00	\N	\N	(-90.735027,38.79302545)	o’fallon	mo	us	t	-90.82098	38.8733246	-90.649074	38.7127263
mwIxhntXTl	2022-05-17 10:01:45.157+00	2022-05-17 10:01:45.256+00	\N	\N	(26.37308865,46.920683)	piatra neamț		ro	t	26.2984458	46.9795831	26.4477315	46.8617829
TKjwH6AMbc	2022-05-17 10:01:45.571+00	2022-05-17 10:01:45.67+00	\N	\N	(-73.834509,41.03175)	town of greenburgh	ny	us	t	-73.897396	41.086958	-73.771622	40.976542
rw9dgRgtO5	2022-05-17 10:01:45.881+00	2022-05-17 10:01:45.98+00	\N	\N	(-95.6460126,31.7518503)	palestine	tx	us	t	-95.7242641	31.8084308	-95.5677611	31.6952698
H2WvcA09Jl	2022-05-17 10:01:46.485+00	2022-05-17 10:01:46.585+00	\N	\N	(18.0710935,59.325117199999994)	stockholm	111 29	se	t	17.9110935	59.4851172	18.2310935	59.1651172
U1dSDYrLdo	2022-05-17 10:01:46.895+00	2022-05-17 10:01:46.994+00	\N	\N	(-98.3227457,29.816132250000003)	comal county	tx	us	t	-98.646221	30.0379088	-97.9992704	29.5943557
SNruVnN4Hp	2022-05-17 10:01:47.27+00	2022-05-17 10:01:47.37+00	\N	\N	(-82.41645299999999,28.5640745)	hernando county	fl	us	t	-82.778437	28.694859	-82.054469	28.43329
Wqf4NxdAHK	2022-05-17 10:01:47.56+00	2022-05-17 10:01:47.66+00	\N	\N	(-99.50207295,35.34182)	elk city	ok	us	t	-99.639948	35.443408	-99.3641979	35.240232
6qPR6MrUMj	2022-05-17 10:01:47.969+00	2022-05-17 10:01:48.069+00	\N	\N	(-85.8433015,33.675441500000005)	anniston	al	us	t	-85.931236	33.750917	-85.755367	33.599966
yRyD93BIJj	2022-05-17 10:01:48.352+00	2022-05-17 10:01:48.452+00	\N	\N	(-94.57571949999999,39.091919000000004)	kansas city	mo	us	t	-94.765917	39.356662	-94.385522	38.827176
OayislS2lK	2022-05-17 10:01:48.744+00	2022-05-17 10:01:48.844+00	\N	\N	(-3.7131006500000003,36.771001299999995)	almuñécar	andalusia	es	t	-3.790611	36.8227882	-3.6355903	36.7192144
MHw3fMGe7s	2022-05-17 10:01:49.049+00	2022-05-17 10:01:49.148+00	\N	\N	(-88.39708759999999,44.2812876)	appleton	wi	us	t	-88.4515792	44.3539177	-88.342596	44.2086575
YSA8V8ZlCt	2022-05-17 10:01:49.479+00	2022-05-17 10:01:49.579+00	\N	\N	(-123.11428215,45.548676)	washington county	or	us	t	-123.4860593	45.7801553	-122.742505	45.3171967
Y0cWBl4pcw	2022-05-17 10:01:49.8+00	2022-05-17 10:01:49.901+00	\N	\N	(-93.422883,37.5874202)	bolivar	mo	us	t	-93.466748	37.636227	-93.379018	37.5386134
s40Oadu5Pn	2022-05-17 10:01:50.247+00	2022-05-17 10:01:50.346+00	\N	\N	(-76.27460335,38.97018455)	chester	md	us	t	-76.3071727	38.9977709	-76.242034	38.9425982
AdQiXnqwFE	2022-05-17 10:01:50.594+00	2022-05-17 10:01:50.694+00	\N	\N	(-70.55737575,43.77557375)	standish	me	us	t	-70.6682314	43.8640416	-70.4465201	43.6871059
zAx5BZ9neZ	2022-05-17 10:01:50.976+00	2022-05-17 10:01:51.076+00	\N	\N	(4.90395925,52.354619)	amsterdam	north holland	nl	t	4.7287563	52.4310638	5.0791622	52.2781742
Hoz3M7gDVx	2022-05-17 10:01:51.301+00	2022-05-17 10:01:51.401+00	\N	\N	(-70.6477412,-34.741707149999996)	san fernando	o'higgins region	cl	t	-71.0472964	-34.4774986	-70.248186	-35.0059157
nRGTLw4UsZ	2022-05-17 10:01:51.641+00	2022-05-17 10:01:51.741+00	\N	\N	(31.034985300000002,-25.350870999999998)	mbombela	mp	za	t	30.44243	-24.960392	31.6275406	-25.74135
OfYGXQekya	2022-05-17 10:01:52.129+00	2022-05-17 10:01:52.229+00	\N	\N	(121.03313685,14.5545329)	makati	metro manila	ph	t	120.9987708	14.5794322	121.0675029	14.5296336
I06JgEZj6q	2022-05-17 10:01:52.544+00	2022-05-17 10:01:52.644+00	\N	\N	(-97.39860035000001,31.437045949999998)	mcgregor	tx	us	t	-97.503342	31.4965998	-97.2938587	31.3774921
jdPhcXqIhW	2022-05-17 10:01:52.864+00	2022-05-17 10:01:52.963+00	\N	\N	(-146.283932,61.140311999999994)	valdez	ak	us	t	-146.73145	61.25816	-145.836414	61.022464
jhlP9oGwzd	2022-05-17 10:01:53.275+00	2022-05-17 10:01:53.375+00	\N	\N	(-111.09151185,54.077436750000004)	county of st. paul	ab	ca	t	-111.828277	54.4396805	-110.3547467	53.715193
cNN94dHXtY	2022-05-17 10:01:53.746+00	2022-05-17 10:01:53.845+00	\N	\N	(-77.6170075,43.1855446)	rochester	ny	us	t	-77.701505	43.2677292	-77.53251	43.10336
yugjWADVLF	2022-05-17 10:01:54.098+00	2022-05-17 10:01:54.198+00	\N	\N	(-81.05086109999999,38.46537175)	clay county	wv	us	t	-81.2843656	38.667313	-80.8173566	38.2634305
0KWvNQ9C7K	2022-05-17 10:01:54.619+00	2022-05-17 10:01:54.719+00	\N	\N	(-122.3541002,38.5095912)	napa county	ca	us	t	-122.6468084	38.8643182	-122.061392	38.1548642
5klFJywGQd	2022-05-17 10:01:55.115+00	2022-05-17 10:01:55.216+00	\N	\N	(-74.60632050000001,40.56889235)	somerville	nj	us	t	-74.626382	40.581697	-74.586259	40.5560877
sm4BlnnNrS	2022-05-17 10:01:55.545+00	2022-05-17 10:01:55.644+00	\N	\N	(-96.82361159999999,33.1506744)	frisco	tx	us	t	-96.9836116	33.3106744	-96.6636116	32.9906744
k0DUQOj7qF	2022-05-17 10:01:55.903+00	2022-05-17 10:01:56.003+00	\N	\N	(-121.44494415,38.37730995)	sacramento county	ca	us	t	-121.8628053	38.7363502	-121.027083	38.0182697
SWaS6DTJCx	2022-05-17 10:01:56.235+00	2022-05-17 10:01:56.335+00	\N	\N	(-85.15154154999999,44.9024182)	custer township	mi	us	t	-85.2117469	44.9461356	-85.0913362	44.8587008
nU3POztJvd	2022-05-17 10:01:56.639+00	2022-05-17 10:01:56.739+00	\N	\N	(-77.55517725,39.103074899999996)	leesburg	va	us	t	-77.6024279	39.1385274	-77.5079266	39.0676224
Dcikzj4T6K	2022-05-17 10:01:57.029+00	2022-05-17 10:01:57.129+00	\N	\N	(-81.02665999999999,34.942825)	rock hill	sc	us	t	-81.125219	35.014812	-80.928101	34.870838
k9nNoc0dI6	2022-05-17 10:01:57.411+00	2022-05-17 10:01:57.511+00	\N	\N	(-76.60238799999999,39.4018552)	towson	md	us	t	-76.762388	39.5618552	-76.442388	39.2418552
35oUp1EFbC	2022-05-17 10:01:57.956+00	2022-05-17 10:01:58.057+00	\N	\N	(-87.2757515,30.613813)	escambia county	fl	us	t	-87.634896	30.998946	-86.916607	30.22868
3F81l27qNd	2022-05-17 10:01:58.289+00	2022-05-17 10:01:58.388+00	\N	\N	(26.676019699999998,47.753350999999995)	botoșani		ro	t	26.6105684	47.8029526	26.741471	47.7037494
iwiHLEBbHw	2022-05-17 10:01:58.79+00	2022-05-17 10:01:58.89+00	\N	\N	(151.3417318,-33.425017499999996)	gosford	nsw	au	t	151.1817318	-33.2650175	151.5017318	-33.5850175
zLsQZne8Lc	2022-05-17 10:01:59.158+00	2022-05-17 10:01:59.258+00	\N	\N	(-82.0962705,26.457563)	sanibel	fl	us	t	-82.186855	26.500827	-82.005686	26.414299
tDjAfV4bFC	2022-05-17 10:01:59.582+00	2022-05-17 10:01:59.681+00	\N	\N	(6.41387145,51.1668357)	mönchengladbach	north rhine-westphalia	de	t	6.2910981	51.2478874	6.5366448	51.085784
FxUCIYCzOk	2022-05-17 10:02:00.023+00	2022-05-17 10:02:00.124+00	\N	\N	(153.073984,-27.3411165)	brisbane city	qld	au	t	152.679693	-27.022014	153.468275	-27.660219
hqG92EUl74	2022-05-17 10:02:00.325+00	2022-05-17 10:02:00.426+00	\N	\N	(-108.569721,39.085684)	grand junction	co	us	t	-108.675724	39.15274	-108.463718	39.018628
dsmEyoGEs4	2022-05-17 10:02:00.711+00	2022-05-17 10:02:00.812+00	\N	\N	(-85.95618745,41.68824075)	elkhart	in	us	t	-86.0423016	41.73882	-85.8700733	41.6376615
nepqCPeQrw	2022-05-17 10:02:01.185+00	2022-05-17 10:02:01.284+00	\N	\N	(-1.6292765999999999,50.857585150000006)	new forest	eng	gb	t	-1.9572806	51.0094299	-1.3012726	50.7057404
w4A5gpAUb9	2022-05-17 10:02:01.647+00	2022-05-17 10:02:01.747+00	\N	\N	(26.794107850000003,46.25957265)	onești		ro	t	26.7153704	46.2985989	26.8728453	46.2205464
ZRrohYcoPm	2022-05-17 10:02:02.042+00	2022-05-17 10:02:02.141+00	\N	\N	(7.3949354,46.95459265)	bern	be	ch	t	7.2943145	46.9901527	7.4955563	46.9190326
pkoqmyROhM	2022-05-17 10:02:02.355+00	2022-05-17 10:02:02.456+00	\N	\N	(-89.8825535,30.032474800000003)	new orleans	la	us	t	-90.1399307	30.1994687	-89.6251763	29.8654809
8HdAjNKOwF	2022-05-17 10:02:02.863+00	2022-05-17 10:02:02.964+00	\N	\N	(-83.9258155,35.67381880000001)	blount county	tn	us	t	-84.188431	35.887089	-83.6632	35.4605486
zESgFweojd	2022-05-17 10:02:03.262+00	2022-05-17 10:02:03.362+00	\N	\N	(-122.52039045000001,45.80172325)	clark county	wa	us	t	-122.7962496	46.0597239	-122.2445313	45.5437226
DcgydDX3YW	2022-05-17 10:02:03.613+00	2022-05-17 10:02:03.715+00	\N	\N	(-77.8927186,37.55331925)	powhatan county	va	us	t	-78.1322829	37.692627	-77.6531543	37.4140115
FeI87f9x2I	2022-05-17 10:02:03.956+00	2022-05-17 10:02:04.058+00	\N	\N	(-117.1923635,33.92189115)	moreno valley	ca	us	t	-117.296524	33.985102	-117.088203	33.8586803
M3RsYO8Eii	2022-05-17 10:02:04.474+00	2022-05-17 10:02:04.574+00	\N	\N	(27.71786775,45.77681245)	galați		ro	t	27.2270465	46.1631061	28.208689	45.3905188
LCPu1XdWQj	2022-05-17 10:02:04.904+00	2022-05-17 10:02:05.004+00	\N	\N	(17.6387436,59.8586126)	uppsala	753 20	se	t	17.4787436	60.0186126	17.7987436	59.6986126
EaR1eeXkoH	2022-05-17 10:02:05.248+00	2022-05-17 10:02:05.348+00	\N	\N	(12.5700724,55.686724299999995)	copenhagen	capital region of denmark	dk	t	12.4100724	55.8467243	12.7300724	55.5267243
v3hVRdQdKL	2022-05-17 10:02:05.634+00	2022-05-17 10:02:05.733+00	\N	\N	(-90.2064795,38.9484825)	godfrey	il	us	t	-90.276011	39.000052	-90.136948	38.896913
CfNz24a1xD	2022-05-17 10:02:06.108+00	2022-05-17 10:02:06.207+00	\N	\N	(17.1152875,48.1358664)	bratislava	region of bratislava	sk	t	16.946044	48.2650685	17.284531	48.0066643
AKDPIl4ApC	2022-05-17 10:02:06.452+00	2022-05-17 10:02:06.552+00	\N	\N	(-84.8456835,34.244178500000004)	bartow county	ga	us	t	-85.047074	34.413061	-84.644293	34.075296
JtvHr0KiZw	2022-05-17 10:02:06.861+00	2022-05-17 10:02:06.96+00	\N	\N	(-77.81979605000001,35.984968)	rocky mount	nc	us	t	-77.9039401	36.068373	-77.735652	35.901563
bnpdjV0rsU	2022-05-17 10:02:07.22+00	2022-05-17 10:02:07.319+00	\N	\N	(153.36042795,-27.9777525)	gold coast	qld	au	t	153.16891	-27.690395	153.5519459	-28.26511
4u4jfgeNvJ	2022-05-17 10:02:07.463+00	2022-05-17 10:02:07.563+00	\N	\N	(-72.50906555,43.07406845)	westminster	vt	us	t	-72.5856441	43.1277728	-72.432487	43.0203641
keUADgisNj	2022-05-17 10:02:07.839+00	2022-05-17 10:02:07.939+00	\N	\N	(-73.79783950000001,42.234519500000005)	town of greenport	ny	us	t	-73.851286	42.288356	-73.744393	42.180683
wFGAknkwff	2022-05-17 10:02:08.134+00	2022-05-17 10:02:08.234+00	\N	\N	(-84.79149290000001,45.4276062)	littlefield township	mi	us	t	-84.8530825	45.4643316	-84.7299033	45.3908808
9CESzcixpK	2022-05-17 10:02:08.536+00	2022-05-17 10:02:08.635+00	\N	\N	(-2.6143948,51.47085774999999)	bristol	eng	gb	t	-2.7183704	51.5444317	-2.5104192	51.3972838
hVVugqOExB	2022-05-17 10:02:08.982+00	2022-05-17 10:02:09.08+00	\N	\N	(12.071047,55.4517625)	køge municipality	region zealand	dk	t	11.9110121	55.5352389	12.2310819	55.3682861
VRiaLjezgR	2022-05-17 10:02:09.39+00	2022-05-17 10:02:09.49+00	\N	\N	(-78.8038001,35.05089475)	cumberland county	nc	us	t	-79.1129202	35.2669209	-78.49468	34.8348686
aDZlaMsifw	2022-05-17 10:02:09.784+00	2022-05-17 10:02:09.884+00	\N	\N	(14.4980949,52.3254715)	frankfurt (oder)	bb	de	t	14.3948254	52.3980721	14.6013644	52.2528709
U5DBSyIWQc	2022-05-17 10:02:10.16+00	2022-05-17 10:02:10.261+00	\N	\N	(-0.1848353,51.7729758)	welwyn hatfield	eng	gb	t	-0.2775417	51.8604367	-0.0921289	51.6855149
FAsgTFo1fz	2022-05-17 10:02:10.527+00	2022-05-17 10:02:10.626+00	\N	\N	(7.54049585,53.483602399999995)	aurich	lower saxony	de	t	7.4018508	53.5617576	7.6791409	53.4054472
BuHBbkKxeI	2022-05-17 10:02:10.895+00	2022-05-17 10:02:10.996+00	\N	\N	(33.2055568,0.4353036)	jinja	jinja	ug	t	33.0455568	0.5953036	33.3655568	0.2753036
kdI14qV5AT	2022-05-17 10:02:11.217+00	2022-05-17 10:02:11.316+00	\N	\N	(-76.2894359,45.2506622)	mississippi mills	on	ca	t	-76.5038072	45.4093948	-76.0750646	45.0919296
fOWTCdXhWD	2022-05-17 10:02:11.743+00	2022-05-17 10:02:11.843+00	\N	\N	(-87.45210900000001,33.2868815)	tuscaloosa	al	us	t	-87.661589	33.458866	-87.242629	33.114897
RwPVGsnzEF	2022-05-17 10:02:12.104+00	2022-05-17 10:02:12.204+00	\N	\N	(-78.5123274,-0.2201641)	quito	p	ec	t	-78.6723274	-0.0601641	-78.3523274	-0.3801641
B0WOSNBIb6	2022-05-17 10:02:12.56+00	2022-05-17 10:02:12.659+00	\N	\N	(152.8936597,-31.461213649999998)	port macquarie	nsw	au	t	152.8489452	-31.4052772	152.9383742	-31.5171501
kJswjPDQoQ	2022-05-17 10:02:12.882+00	2022-05-17 10:02:12.981+00	\N	\N	(-112.2939585,34.600232)	prescott valley	az	us	t	-112.386236	34.672624	-112.201681	34.52784
97riAEckPm	2022-05-17 10:02:13.159+00	2022-05-17 10:02:13.259+00	\N	\N	(22.221675349999998,-33.59046385)	oudtshoorn	wc	za	t	22.1798388	-33.5662409	22.2635119	-33.6146868
QBro5c1fA5	2022-05-17 10:02:13.477+00	2022-05-17 10:02:13.577+00	\N	\N	(-76.5041297,38.97252705)	annapolis	md	us	t	-76.5395832	39.0025548	-76.4686762	38.9424993
PdQsOv7jYN	2022-05-17 10:02:13.898+00	2022-05-17 10:02:13.997+00	\N	\N	(-77.731941,43.081587999999996)	town of chili	ny	us	t	-77.820275	43.127431	-77.643607	43.035745
t5KBC12gvG	2022-05-17 10:02:14.302+00	2022-05-17 10:02:14.401+00	\N	\N	(-94.75384460000001,32.51055515)	longview	tx	us	t	-94.84434	32.5895809	-94.6633492	32.4315294
VHSUnqHmng	2022-05-17 10:02:14.705+00	2022-05-17 10:02:14.805+00	\N	\N	(-17.47281405,14.721548049999999)	dakar	dakar region	sn	t	-17.5490249	14.7966431	-17.3966032	14.646453
uXTNxn75EV	2022-05-17 10:02:15.113+00	2022-05-17 10:02:15.212+00	\N	\N	(-88.30663014999999,41.75103)	aurora	il	us	t	-88.408369	41.822191	-88.2048913	41.679869
Eci2MzvhAI	2022-05-17 10:02:15.547+00	2022-05-17 10:02:15.647+00	\N	\N	(-122.70397505,46.97845275)	thurston county	wa	us	t	-123.2059347	47.1941356	-122.2020154	46.7627699
gmnrnvPIp3	2022-05-17 10:02:15.92+00	2022-05-17 10:02:16.02+00	\N	\N	(-72.5237874,41.77702465)	manchester	ct	us	t	-72.5834905	41.8203065	-72.4640843	41.7337428
uCOa0nxTog	2022-05-17 10:02:16.248+00	2022-05-17 10:02:16.348+00	\N	\N	(-81.99598284999999,26.64757555)	cape coral	fl	us	t	-82.0916584	26.7700251	-81.9003073	26.525126
emg0ZF6DYd	2022-05-17 10:02:16.716+00	2022-05-17 10:02:16.816+00	\N	\N	(-80.62865049999999,35.3941035)	concord	nc	us	t	-80.764909	35.482811	-80.492392	35.305396
mmFh2IuSo7	2022-05-17 10:02:17.045+00	2022-05-17 10:02:17.145+00	\N	\N	(8.76318505,48.196747650000006)	schömberg	bw	de	t	8.7193406	48.2339265	8.8070295	48.1595688
LMn2ncqNiE	2022-05-17 10:02:17.508+00	2022-05-17 10:02:17.608+00	\N	\N	(-122.5125711,37.98397265)	san rafael	ca	us	t	-122.589722	38.0290987	-122.4354202	37.9388466
s9n0J2PEjw	2022-05-17 10:02:17.775+00	2022-05-17 10:02:17.874+00	\N	\N	(-83.78953519999999,43.2504789)	village of birch run	mi	us	t	-83.8097042	43.2610159	-83.7693662	43.2399419
b0CMQQIFEB	2022-05-17 10:02:18.05+00	2022-05-17 10:02:18.149+00	\N	\N	(-97.52195745,28.000283)	san patricio county	tx	us	t	-97.9087809	28.179461	-97.135134	27.821105
KHzqYcdvSL	2022-05-17 10:02:18.405+00	2022-05-17 10:02:18.504+00	\N	\N	(-86.07809875,42.81249755)	holland charter township	mi	us	t	-86.13806	42.8561837	-86.0181375	42.7688114
PBTyKkbxME	2022-05-17 10:02:18.683+00	2022-05-17 10:02:18.782+00	\N	\N	(-82.559538,41.400707999999995)	huron	oh	us	t	-82.593397	41.429122	-82.525679	41.372294
fS7XWXAg7N	2022-05-17 10:02:19.065+00	2022-05-17 10:02:19.165+00	\N	\N	(-70.97371305,42.53257215)	peabody	ma	us	t	-71.0348327	42.5703914	-70.9125934	42.4947529
RYiJ0CcRX1	2022-05-17 10:02:19.375+00	2022-05-17 10:02:19.474+00	\N	\N	(-74.14259050000001,40.994688)	midland park	nj	us	t	-74.157154	41.007495	-74.128027	40.981881
DgwWi0DP3W	2022-05-17 10:02:19.692+00	2022-05-17 10:02:19.792+00	\N	\N	(-83.0568095,37.751303)	salyersville	ky	us	t	-83.080128	37.768602	-83.033491	37.734004
9TiEaPhnAy	2022-05-17 10:02:20.057+00	2022-05-17 10:02:20.156+00	\N	\N	(8.52236115,11.97436105)	gandu albasa	kn	ng	t	8.5043307	11.9935243	8.5403916	11.9551978
yXPLUTa28F	2022-05-17 10:02:20.425+00	2022-05-17 10:02:20.525+00	\N	\N	(-85.60475245,42.897839)	kentwood	mi	us	t	-85.664864	42.941188	-85.5446409	42.85449
wnnwIRRFpn	2022-05-17 10:02:20.807+00	2022-05-17 10:02:20.906+00	\N	\N	(-74.36341,39.9553425)	manchester township	nj	us	t	-74.495277	40.055882	-74.231543	39.854803
AratQcIwZ6	2022-05-17 10:02:21.267+00	2022-05-17 10:02:21.367+00	\N	\N	(-121.70543814999999,37.188868600000006)	santa clara county	ca	us	t	-122.2025817	37.4846245	-121.2082946	36.8931127
cc12BkZUy6	2022-05-17 10:02:21.614+00	2022-05-17 10:02:21.717+00	\N	\N	(-97.33676085,30.10310535)	bastrop county	tx	us	t	-97.6490607	30.4196697	-97.024461	29.786541
YpFgQeGaA8	2022-05-17 10:02:21.981+00	2022-05-17 10:02:22.081+00	\N	\N	(-106.18389305,31.675504150000002)	horizon city	tx	us	t	-106.2200465	31.7115283	-106.1477396	31.63948
q8g8ssT6LK	2022-05-17 10:02:22.332+00	2022-05-17 10:02:22.432+00	\N	\N	(-81.87045699999999,26.5508361)	villas	fl	us	t	-81.886625	26.5756602	-81.854289	26.526012
cyKZJxeSHE	2022-05-17 10:02:22.69+00	2022-05-17 10:02:22.79+00	\N	\N	(-93.36203,45.03630495)	crystal	mn	us	t	-93.390373	45.0657101	-93.333687	45.0068998
Y21tLtQcfY	2022-05-17 10:02:23.118+00	2022-05-17 10:02:23.217+00	\N	\N	(27.683035,-26.004565)	mogale city local municipality	gt	za	t	27.42522	-25.79592	27.94085	-26.21321
vBGOSzElFC	2022-05-17 10:02:23.465+00	2022-05-17 10:02:23.566+00	\N	\N	(-71.96844625,46.0618318)	victoriaville	qc	ca	t	-72.0452493	46.1225604	-71.8916432	46.0011032
UXfXwog3jU	2022-05-17 10:02:23.83+00	2022-05-17 10:02:23.93+00	\N	\N	(-83.46140894999999,39.5471156)	fayette county	oh	us	t	-83.6703303	39.7169113	-83.2524876	39.3773199
rSnLOzvubI	2022-05-17 10:02:24.169+00	2022-05-17 10:02:24.269+00	\N	\N	(-91.90979300000001,42.4672322)	independence	ia	us	t	-91.9533747	42.4914421	-91.8662113	42.4430223
fced8mt7sx	2022-05-17 10:02:24.567+00	2022-05-17 10:02:24.668+00	\N	\N	(16.369383300000003,48.113880699999996)	gemeinde hennersdorf	lower austria	at	t	16.3504228	48.1284	16.3883438	48.0993614
35tBTrLEJz	2022-05-17 10:02:24.871+00	2022-05-17 10:02:24.971+00	\N	\N	(-83.13775165,42.2494985)	ecorse	mi	us	t	-83.161635	42.264777	-83.1138683	42.23422
hfxlNYD1Gx	2022-05-17 10:02:25.293+00	2022-05-17 10:02:25.394+00	\N	\N	(24.40860125,44.983800849999994)	nicolae bălcescu		ro	t	24.3081631	45.0266545	24.5090394	44.9409472
9qq02pyGpA	2022-05-17 10:02:25.738+00	2022-05-17 10:02:25.838+00	\N	\N	(-83.18936045,34.1363006)	madison county	ga	us	t	-83.4024269	34.27353	-82.976294	33.9990712
9T1ZHNVEZB	2022-05-17 10:02:26.073+00	2022-05-17 10:02:26.173+00	\N	\N	(-83.7596265,31.1804487)	colquitt county	ga	us	t	-84.013832	31.3350154	-83.505421	31.025882
NpyviBbfv4	2022-05-17 10:02:26.388+00	2022-05-17 10:02:26.488+00	\N	\N	(-84.9183312,45.07404975)	warner township	mi	us	t	-84.9793303	45.1183458	-84.8573321	45.0297537
w4gMKmC8MG	2022-05-17 10:02:26.706+00	2022-05-17 10:02:26.806+00	\N	\N	(-76.382339,37.7101346)	kilmarnock	va	us	t	-76.400431	37.7326038	-76.364247	37.6876654
ONTfIw7T1x	2022-05-17 10:02:27.085+00	2022-05-17 10:02:27.185+00	\N	\N	(-122.91755365,49.2065449)	new westminster	bc	ca	t	-122.9600726	49.2380741	-122.8750347	49.1750157
JAlQUC329g	2022-05-17 10:02:27.352+00	2022-05-17 10:02:27.453+00	\N	\N	(-110.27360250000001,31.52190775)	sierra vista	az	us	t	-110.449149	31.6960385	-110.098056	31.347777
krAahmQES8	2022-05-17 10:02:27.742+00	2022-05-17 10:02:27.841+00	\N	\N	(90.40261509999999,23.7861979)	dhaka	dhaka division	bd	t	90.2426151	23.9461979	90.5626151	23.6261979
Hfjc5FKVJG	2022-05-17 10:02:28.118+00	2022-05-17 10:02:28.218+00	\N	\N	(-75.7138001,35.6927745)	dare county	nc	us	t	-76.0274812	36.244984	-75.400119	35.140565
Lrxwl0eVTR	2022-05-17 10:02:28.448+00	2022-05-17 10:02:28.547+00	\N	\N	(-97.7060685,26.1685085)	harlingen	tx	us	t	-97.796356	26.279894	-97.615781	26.057123
3KiuzbcfnW	2022-05-17 10:02:28.752+00	2022-05-17 10:02:28.852+00	\N	\N	(-72.07016465000001,42.561114700000005)	templeton	ma	us	t	-72.1389525	42.6266076	-72.0013768	42.4956218
Iq7iEzbl5s	2022-05-17 10:02:29.125+00	2022-05-17 10:02:29.225+00	\N	\N	(-88.15177175,42.072225450000005)	hoffman estates	il	us	t	-88.2433485	42.117863	-88.060195	42.0265879
asXxehcqiA	2022-05-17 10:02:29.557+00	2022-05-17 10:02:29.657+00	\N	\N	(10.50262255,59.0160508)	færder		no	t	10.3302253	59.2711412	10.6750198	58.7609604
L2euPoYiHM	2022-05-17 10:02:29.911+00	2022-05-17 10:02:30.016+00	\N	\N	(-76.7934255,40.895528999999996)	northumberland	pa	us	t	-76.811032	40.907557	-76.775819	40.883501
nPXLhpRQpA	2022-05-17 10:02:30.243+00	2022-05-17 10:02:30.343+00	\N	\N	(-84.42399710000001,42.2911141)	blackman charter township	mi	us	t	-84.4831759	42.3348189	-84.3648183	42.2474093
mkgQrzA3dS	2022-05-17 10:02:30.546+00	2022-05-17 10:02:30.647+00	\N	\N	(-116.9025815,34.244853500000005)	big bear lake	ca	us	t	-116.962546	34.265146	-116.842617	34.224561
TL5MkkvE5k	2022-05-17 10:02:30.986+00	2022-05-17 10:02:31.086+00	\N	\N	(-116.9901455,33.7258145)	hemet	ca	us	t	-117.071575	33.780394	-116.908716	33.671235
4LPzGfKwSY	2022-05-17 10:02:31.363+00	2022-05-17 10:02:31.462+00	\N	\N	(24.0832504,45.745483750000005)	sibiu		ro	t	23.9219067	45.8570932	24.2445941	45.6338743
Dgwyb299rZ	2022-05-17 10:02:31.687+00	2022-05-17 10:02:31.786+00	\N	\N	(-73.81961849999999,42.595479)	town of bethlehem	ny	us	t	-73.887069	42.669823	-73.752168	42.521135
b7DFJA4WVE	2022-05-17 10:02:32.106+00	2022-05-17 10:02:32.206+00	\N	\N	(-96.1709305,41.291743)	douglas county	ne	us	t	-96.47072	41.393239	-95.871141	41.190247
1QxDD4VfHc	2022-05-17 10:02:32.5+00	2022-05-17 10:02:32.599+00	\N	\N	(-100.93138300000001,37.0473305)	liberal	ks	us	t	-100.976437	37.077255	-100.886329	37.017406
XYJpJ14L4u	2022-05-17 10:02:32.802+00	2022-05-17 10:02:32.901+00	\N	\N	(-80.1042488,40.709502349999994)	cranberry township	pa	us	t	-80.1525583	40.7453357	-80.0559393	40.673669
Du4Z7lgZMV	2022-05-17 10:02:33.231+00	2022-05-17 10:02:33.331+00	\N	\N	(-123.9438767,40.73361455)	humboldt county	ca	us	t	-124.482003	41.4658436	-123.4057504	40.0013855
XwUJ7ffdx8	2022-05-17 10:02:33.677+00	2022-05-17 10:02:33.777+00	\N	\N	(-83.89382649999999,33.9828045)	dacula	ga	us	t	-83.927432	34.011806	-83.860221	33.953803
4ELiy4vWSX	2022-05-17 10:02:33.957+00	2022-05-17 10:02:34.057+00	\N	\N	(-87.4416857,20.58446425)	solidaridad	roo	mx	t	-87.962742	20.8120637	-86.9206294	20.3568648
lemMQHupxv	2022-05-17 10:02:34.338+00	2022-05-17 10:02:34.441+00	\N	\N	(-84.26236879999999,39.10828635)	union township	oh	us	t	-84.3150793	39.168053	-84.2096583	39.0485197
wUnMHGM2WO	2022-05-17 10:02:34.74+00	2022-05-17 10:02:34.84+00	\N	\N	(-76.42112499999999,40.36425)	north lebanon township	pa	us	t	-76.493489	40.389401	-76.348761	40.339099
MMGjYDIyJL	2022-05-17 10:02:35.25+00	2022-05-17 10:02:35.35+00	\N	\N	(-122.7566282,42.49986885)	jackson county	or	us	t	-123.2313434	42.996618	-122.281913	42.0031197
LE1b1PQx0I	2022-05-17 10:02:35.591+00	2022-05-17 10:02:35.69+00	\N	\N	(-71.4345231,41.9562205)	cumberland	ri	us	t	-71.4877191	42.0189359	-71.3813271	41.8935051
R2NSFOSz5H	2022-05-17 10:02:35.924+00	2022-05-17 10:02:36.025+00	\N	\N	(-70.8903145,43.18630975)	dover	nh	us	t	-70.961606	43.254982	-70.819023	43.1176375
mgCv6NUiUw	2022-05-17 10:02:36.239+00	2022-05-17 10:02:36.338+00	\N	\N	(-2.23337365,53.44234835)	manchester	eng	gb	t	-2.3199185	53.5445923	-2.1468288	53.3401044
549DtOJQmX	2022-05-17 10:02:36.597+00	2022-05-17 10:02:36.696+00	\N	\N	(-76.2975886,40.01840845)	lancaster county	pa	us	t	-76.7219602	40.315713	-75.873217	39.7211039
t2KNmDqBKd	2022-05-17 10:02:36.971+00	2022-05-17 10:02:37.071+00	\N	\N	(-88.91546345,37.672143000000005)	marion	il	us	t	-89.0218789	37.767952	-88.809048	37.576334
nFdCVdayew	2022-05-17 10:02:37.332+00	2022-05-17 10:02:37.433+00	\N	\N	(-88.16191165000001,41.7459429)	naperville	il	us	t	-88.2353098	41.821991	-88.0885135	41.6698948
bCsif4rHVS	2022-05-17 10:02:37.685+00	2022-05-17 10:02:37.785+00	\N	\N	(-83.856622,42.6461115)	oceola township	mi	us	t	-83.917367	42.69199	-83.795877	42.600233
FAkw5JEYfi	2022-05-17 10:02:38.156+00	2022-05-17 10:02:38.256+00	\N	\N	(90.7152981,23.9197152)	narsingdi	dhaka division	bd	t	90.5552981	24.0797152	90.8752981	23.7597152
mCzuw9IXKP	2022-05-17 10:02:38.682+00	2022-05-17 10:02:38.781+00	\N	\N	(172.60732575,-43.509144)	christchurch	can	nz	t	172.3930248	-43.3890866	172.8216267	-43.6292014
sUa9m5uBx0	2022-05-17 10:02:38.988+00	2022-05-17 10:02:39.088+00	\N	\N	(-75.30732705,39.88558605)	prospect park	pa	us	t	-75.316274	39.8961696	-75.2983801	39.8750025
itN55xRHCr	2022-05-17 10:02:39.43+00	2022-05-17 10:02:39.53+00	\N	\N	(-82.38106189999999,27.16757205)	sarasota county	fl	us	t	-82.705438	27.3897857	-82.0566858	26.9453584
EPjiX2sSjH	2022-05-17 10:02:39.709+00	2022-05-17 10:02:39.808+00	\N	\N	(-77.8946345,34.0381615)	carolina beach	nc	us	t	-77.909762	34.062763	-77.879507	34.01356
lczDFS1FfR	2022-05-17 10:02:40.148+00	2022-05-17 10:02:40.247+00	\N	\N	(-64.68625320000001,10.1373006)	barcelona	anzoategui state	ve	t	-64.8462532	10.2973006	-64.5262532	9.9773006
6yJme3jepq	2022-05-17 10:02:40.517+00	2022-05-17 10:02:40.617+00	\N	\N	(-80.089775,32.913129)	north charleston	sc	us	t	-80.249758	32.999514	-79.929792	32.826744
CY8TL32fAj	2022-05-17 10:02:40.842+00	2022-05-17 10:02:40.942+00	\N	\N	(-95.4779163,32.648233700000006)	mineola	tx	us	t	-95.5171314	32.6908175	-95.4387012	32.6056499
hJMqsZU56L	2022-05-17 10:02:41.161+00	2022-05-17 10:02:41.26+00	\N	\N	(-86.2811461,42.0283986)	pipestone township	mi	us	t	-86.3394901	42.0722491	-86.2228021	41.9845481
PbcPYmRCsv	2022-05-17 10:02:41.512+00	2022-05-17 10:02:41.612+00	\N	\N	(9.5333238,55.700005700000006)	vejle	region of southern denmark	dk	t	9.3733238	55.8600057	9.6933238	55.5400057
ZM1EZGxh1z	2022-05-17 10:02:41.989+00	2022-05-17 10:02:42.089+00	\N	\N	(25.825922249999998,47.53268085)	suceava		ro	t	24.947111	47.9880243	26.7047335	47.0773374
UHnuO8eN2C	2022-05-17 10:02:42.379+00	2022-05-17 10:02:42.479+00	\N	\N	(-89.875828,30.42564505)	st. tammany parish	la	us	t	-90.256683	30.7122995	-89.494973	30.1389906
xKqEUHvFdJ	2022-05-17 10:02:42.816+00	2022-05-17 10:02:42.916+00	\N	\N	(-81.61864,28.002553)	polk county	fl	us	t	-82.106236	28.361868	-81.131044	27.643238
KLnexHHynr	2022-05-17 10:02:43.259+00	2022-05-17 10:02:43.359+00	\N	\N	(-82.44248935,38.407845050000006)	huntington	wv	us	t	-82.5317857	38.4396988	-82.353193	38.3759913
Ge9FCc5Tsk	2022-05-17 10:02:43.72+00	2022-05-17 10:02:43.819+00	\N	\N	(-81.17218199999999,29.022729599999998)	volusia county	fl	us	t	-81.680903	29.432462	-80.663461	28.6129972
JHessj2EBX	2022-05-17 10:02:44.117+00	2022-05-17 10:02:44.217+00	\N	\N	(-55.36139355,49.1386422)	botwood	nl	ca	t	-55.4031547	49.1683263	-55.3196324	49.1089581
pAsRfrMMGd	2022-05-17 10:02:44.498+00	2022-05-17 10:02:44.598+00	\N	\N	(-82.09099645,33.38609355)	augusta	ga	us	t	-82.3538702	33.5450221	-81.8281227	33.227165
C6IZphQXNZ	2022-05-17 10:02:44.955+00	2022-05-17 10:02:45.056+00	\N	\N	(7.0159971,51.440886649999996)	essen	north rhine-westphalia	de	t	6.8943442	51.5342019	7.13765	51.3475714
K6DuL1CP1O	2022-05-17 12:30:44.493+00	2022-05-17 12:30:44.593+00	\N	\N	(-85.51000485,44.700168)	east bay township	mi	us	t	-85.575232	44.7580258	-85.4447777	44.6423102
UOfzpBxE3R	2022-05-17 12:30:53.335+00	2022-05-17 12:30:53.435+00	\N	\N	(-75.50222769999999,44.833161950000004)	edwardsburgh/cardinal	on	ca	t	-75.6471387	44.9564553	-75.3573167	44.7098686
rHv5jsjCac	2022-05-17 20:32:02.802+00	2022-05-17 20:32:02.901+00	\N	\N	(-72.44722300000001,42.97350875)	westmoreland	nh	us	t	-72.534563	43.0206235	-72.359883	42.926394
DxfmxRXVzP	2022-05-18 11:15:17.164+00	2022-05-18 11:15:17.263+00	\N	\N	(12.3817029,45.40462235)	venice	ven	it	t	12.1668349	45.5779981	12.5965709	45.2312466
yjLd1krBFt	2022-05-18 12:00:42.244+00	2022-05-18 12:00:42.344+00	\N	\N	(-83.4937872,36.2564215)	grainger county	tn	us	t	-83.732864	36.4323173	-83.2547104	36.0805257
7jNeZEUzn3	2022-05-18 13:04:57.497+00	2022-05-18 13:04:57.597+00	\N	\N	(72.8773928,19.0759899)	mumbai	mh	in	t	72.7173928	19.2359899	73.0373928	18.9159899
OjCGEPsKWu	2022-05-21 03:18:39.664+00	2022-05-21 03:18:39.764+00	\N	\N	(-120.47113505,37.29883445)	merced	ca	us	t	-120.5427532	37.3757339	-120.3995169	37.221935
GJywdReCh9	2022-05-21 03:18:40.471+00	2022-05-21 03:18:40.571+00	\N	\N	(-121.87694585,37.6615472)	pleasanton	ca	us	t	-121.954974	37.7030362	-121.7989177	37.6200582
eX30Dj4kKb	2022-05-21 03:18:41.2+00	2022-05-21 03:18:41.301+00	\N	\N	(-90.0702365,38.862053)	wood river	il	us	t	-90.120153	38.881558	-90.02032	38.842548
PBT3Xn2Mvs	2022-05-21 03:18:41.494+00	2022-05-21 03:18:41.594+00	\N	\N	(-71.45672345,41.8578931)	north providence	ri	us	t	-71.4966202	41.8786752	-71.4168267	41.837111
73PmnYdM8R	2022-05-21 03:18:41.945+00	2022-05-21 03:18:42.046+00	\N	\N	(-85.9792445,37.722593849999996)	hardin county	ky	us	t	-86.277558	38.0050787	-85.680931	37.440109
8yeFnOfUbq	2022-05-21 03:18:42.472+00	2022-05-21 03:18:42.573+00	\N	\N	(-117.6443935,46.8387475)	whitman county	wa	us	t	-118.249389	47.260449	-117.039398	46.417046
k7PkIK7IXY	2022-05-21 03:18:43.131+00	2022-05-21 03:18:43.231+00	\N	\N	(-104.5911555,38.26723715)	pueblo	co	us	t	-104.7222744	38.3453683	-104.4600366	38.189106
1RlA6E3yys	2022-05-21 03:18:43.471+00	2022-05-21 03:18:43.571+00	\N	\N	(9.14785095,56.29274085)	kølvrå	central denmark region	dk	t	9.1380934	56.2974162	9.1576085	56.2880655
jHGvhVU8aO	2022-05-21 03:18:43.837+00	2022-05-21 03:18:43.936+00	\N	\N	(-83.03437650000001,42.67006735)	shelby charter township	mi	us	t	-83.095436	42.7159247	-82.973317	42.62421
3QdhMNCB3D	2022-05-21 03:18:44.224+00	2022-05-21 03:18:44.323+00	\N	\N	(27.58427005,47.15636425)	iași		ro	t	27.4765246	47.2279047	27.6920155	47.0848238
7XjO7DnuID	2022-05-21 03:18:44.91+00	2022-05-21 03:18:45.009+00	\N	\N	(-76.7457009,38.9516645)	bowie	md	us	t	-76.7998736	39.0140935	-76.6915282	38.8892355
t9hO2GCxvo	2022-05-21 03:18:45.793+00	2022-05-21 03:18:45.892+00	\N	\N	(-77.64521955000001,39.0853441)	loudoun county	va	us	t	-77.9621643	39.3244371	-77.3282748	38.8462511
WI9aAIHLbg	2022-05-21 03:18:46.2+00	2022-05-21 03:18:46.299+00	\N	\N	(-97.01572150000001,46.6490285)	kindred	nd	us	t	-97.031805	46.658992	-96.999638	46.639065
BvADI40gTM	2022-05-21 03:18:46.924+00	2022-05-21 03:18:47.023+00	\N	\N	(-88.29746094999999,44.3111245)	town of vandenbroek	wi	us	t	-88.3432321	44.3286734	-88.2516898	44.2935756
fcfGewmitF	2022-05-21 03:18:47.283+00	2022-05-21 03:18:47.383+00	\N	\N	(-115.52902474999999,41.05888985)	elko county	nv	us	t	-117.017754	41.9992147	-114.0402955	40.118565
hnyncXcwEh	2022-05-21 03:18:47.791+00	2022-05-21 03:18:47.892+00	\N	\N	(77.84433915,18.69209405)	bodhan mandal	tg	in	t	77.7286147	18.810678	77.9600636	18.5735101
z6uflBGU04	2022-05-21 03:18:48.288+00	2022-05-21 03:18:48.388+00	\N	\N	(30.33263165,-30.4859899)	umzumbe local municipality	nl	za	t	30.0358599	-30.3165699	30.6294034	-30.6554099
L4CUuuoZys	2022-05-21 03:18:48.612+00	2022-05-21 03:18:48.711+00	\N	\N	(-121.9407079,37.75818165)	san ramon	ca	us	t	-122.0044837	37.7951234	-121.8769321	37.7212399
eBmZhJ6rgt	2022-05-21 03:18:48.927+00	2022-05-21 03:18:49.026+00	\N	\N	(-112.45563275,33.68121465)	surprise	az	us	t	-112.6127257	33.7823434	-112.2985398	33.5800859
JNp45ZXKBD	2022-05-21 03:18:49.587+00	2022-05-21 03:18:49.686+00	\N	\N	(2.64973365,41.6227411)	calella	catalonia	es	t	2.6277847	41.6407097	2.6716826	41.6047725
cNhLIypW9x	2022-05-21 03:18:50.267+00	2022-05-21 03:18:50.366+00	\N	\N	(-82.41906850000001,40.077738499999995)	newark	oh	us	t	-82.498616	40.125488	-82.339521	40.029989
EZawAkZFO3	2022-05-21 03:18:50.64+00	2022-05-21 03:18:50.74+00	\N	\N	(-96.88300634999999,35.18096645)	pottawatomie county	ok	us	t	-97.1421829	35.464561	-96.6238298	34.8973719
UhqiFT8Ntb	2022-05-21 03:18:50.944+00	2022-05-21 03:18:51.044+00	\N	\N	(-70.9650064,41.84317514999999)	lakeville	ma	us	t	-71.0365711	41.9074542	-70.8934417	41.7788961
8A2IRiSmGS	2022-05-21 03:18:51.404+00	2022-05-21 03:18:51.503+00	\N	\N	(-93.04510105,44.9638269)	maplewood	mn	us	t	-93.105968	45.036876	-92.9842341	44.8907778
i0dbV819oC	2022-05-21 03:18:52.243+00	2022-05-21 03:18:52.342+00	\N	\N	(23.626835,-28.233600000000003)	kgatelopele local municipality	nc	za	t	23.36225	-27.87931	23.89142	-28.58789
V00vUlP5JZ	2022-05-21 03:18:52.584+00	2022-05-21 03:18:52.684+00	\N	\N	(-78.07085599999999,34.0400205)	boiling spring lakes	nc	us	t	-78.129919	34.09772	-78.011793	33.982321
ckuKgxaoHc	2022-05-21 03:18:53.032+00	2022-05-21 03:18:53.133+00	\N	\N	(-78.27646250000001,36.04200645)	franklin county	nc	us	t	-78.546463	36.266159	-78.006462	35.8178539
2I7tV9Rv1C	2022-05-21 03:18:53.393+00	2022-05-21 03:18:53.494+00	\N	\N	(-122.43282640000001,45.510909749999996)	gresham	or	us	t	-122.4980699	45.5608795	-122.3675829	45.46094
QTWFiL2wCE	2022-05-21 03:18:53.799+00	2022-05-21 03:18:53.899+00	\N	\N	(-70.87197169999999,42.6008341)	wenham	ma	us	t	-70.9338588	42.6238464	-70.8100846	42.5778218
EpPLSG73TE	2022-05-21 03:18:54.154+00	2022-05-21 03:18:54.254+00	\N	\N	(-77.91970435,18.4710279)	montego bay		jm	t	-77.9274209	18.4790101	-77.9119878	18.4630457
oGZTJC0hge	2022-05-21 03:18:54.574+00	2022-05-21 03:18:54.675+00	\N	\N	(-79.1669546,35.501220450000005)	sanford	nc	us	t	-79.2415119	35.5953755	-79.0923973	35.4070654
OAIzboC6Id	2022-05-21 03:18:54.905+00	2022-05-21 03:18:55.005+00	\N	\N	(115.83320900000001,-32.331047)	baldivis	wa	au	t	115.776689	-32.271979	115.889729	-32.390115
K1LJdpwePW	2022-05-21 03:18:55.246+00	2022-05-21 03:18:55.346+00	\N	\N	(-76.59445255,38.97318155)	anne arundel county	md	us	t	-76.8403258	39.2371116	-76.3485793	38.7092515
tFAMfNTwL4	2022-05-21 03:18:55.64+00	2022-05-21 03:18:55.74+00	\N	\N	(-76.913209,42.138418)	town of big flats	ny	us	t	-76.965765	42.200584	-76.860653	42.076252
Ye5FEcvbzV	2022-05-21 03:18:56.153+00	2022-05-21 03:18:56.253+00	\N	\N	(-110.9692202,29.0948207)	hermosillo	son	mx	t	-111.1292202	29.2548207	-110.8092202	28.9348207
Aqvbv9H7sp	2022-05-21 03:18:56.817+00	2022-05-21 03:18:56.917+00	\N	\N	(-83.6926818,43.0019428)	genesee county	mi	us	t	-83.9320666	43.2231163	-83.453297	42.7807693
5RibCzllLl	2022-05-21 03:18:57.372+00	2022-05-21 03:18:57.471+00	\N	\N	(8.42821015,47.201278450000004)	hünenberg	zg	ch	t	8.3948352	47.2483758	8.4615851	47.1541811
3jpLlO1G0k	2022-05-21 03:18:58.112+00	2022-05-21 03:18:58.212+00	\N	\N	(9.159124250000001,49.97067)	aschaffenburg	bavaria	de	t	9.0802454	50.0212787	9.2380031	49.9200613
dKgNacfyzp	2022-05-21 03:18:58.496+00	2022-05-21 03:18:58.595+00	\N	\N	(-72.92923615000001,41.2984977)	new haven	ct	us	t	-72.998048	41.3505701	-72.8604243	41.2464253
zYOisjrFA7	2022-05-21 03:18:58.835+00	2022-05-21 03:18:58.934+00	\N	\N	(-75.72421645,37.7380189)	accomack county	va	us	t	-76.2366082	38.0274758	-75.2118247	37.448562
agtYcvyCAR	2022-05-21 03:18:59.196+00	2022-05-21 03:18:59.296+00	\N	\N	(-90.73036744999999,42.483580599999996)	dubuque	ia	us	t	-90.8240079	42.5579044	-90.636727	42.4092568
9vdagT3pXF	2022-05-21 03:18:59.726+00	2022-05-21 03:18:59.826+00	\N	\N	(-83.9400919,42.008041000000006)	tecumseh	mi	us	t	-83.974625	42.027104	-83.9055588	41.988978
miKbwjwqks	2022-05-21 03:19:00.131+00	2022-05-21 03:19:00.232+00	\N	\N	(-84.7445955,33.6898105)	douglas county	ga	us	t	-84.911059	33.806264	-84.578132	33.573357
kLU8OnEQ22	2022-05-21 03:19:00.591+00	2022-05-21 03:19:00.692+00	\N	\N	(-77.61241,35.217332999999996)	lenoir county	nc	us	t	-77.833855	35.427029	-77.390965	35.007637
eQlGgHNGL7	2022-05-21 03:19:01.043+00	2022-05-21 03:19:01.143+00	\N	\N	(-81.4407352,41.23995165)	hudson	oh	us	t	-81.489636	41.277053	-81.3918344	41.2028503
N6DgJmyEAd	2022-05-21 03:19:01.524+00	2022-05-21 03:19:01.624+00	\N	\N	(-0.873212,52.25104545)	northampton	eng	gb	t	-0.9550541	52.2826966	-0.7913699	52.2193943
KHiAtclC8m	2022-05-21 03:19:01.868+00	2022-05-21 03:19:01.969+00	\N	\N	(-77.53969645000001,34.8987992)	richlands	nc	us	t	-77.5596616	34.9114701	-77.5197313	34.8861283
n2oLSC8kZl	2022-05-21 03:19:02.44+00	2022-05-21 03:19:02.539+00	\N	\N	(-85.44271230000001,33.304241000000005)	randolph county	al	us	t	-85.653236	33.501747	-85.2321886	33.106735
5lc1O5yEEl	2022-05-21 03:19:02.959+00	2022-05-21 03:19:03.059+00	\N	\N	(55.45950915,25.07406685)		dubai	ae	t	54.7153981	25.5250676	56.2036202	24.6230661
LXqaAYAJUH	2022-05-21 03:19:03.461+00	2022-05-21 03:19:03.561+00	\N	\N	(-115.61879005,43.433393)	elmore county	id	us	t	-116.2662199	44.098685	-114.9713602	42.768101
T9HuGQwuCW	2022-05-21 03:19:03.989+00	2022-05-21 03:19:04.09+00	\N	\N	(100.4934734,13.7525438)	bangkok	bangkok	th	t	100.3334734	13.9125438	100.6534734	13.5925438
Rkv0icGHJn	2022-05-21 03:19:04.302+00	2022-05-21 03:19:04.403+00	\N	\N	(-81.2236975,37.750440499999996)	raleigh county	wv	us	t	-81.569931	37.992477	-80.877464	37.508404
eHSYBheKyp	2022-05-21 03:19:04.712+00	2022-05-21 03:19:04.813+00	\N	\N	(-123.7706153,46.98206595)	aberdeen	wa	us	t	-123.8605036	47.0205141	-123.680727	46.9436178
B6neXnGqT5	2022-05-21 03:19:04.968+00	2022-05-21 03:19:05.067+00	\N	\N	(-84.01259350000001,39.8066035)	fairborn	oh	us	t	-84.079145	39.845972	-83.946042	39.767235
qCxIIhfjtf	2022-05-21 03:19:05.214+00	2022-05-21 03:19:05.315+00	\N	\N	(-90.37142895,40.9469345)	galesburg	il	us	t	-90.441216	40.992441	-90.3016419	40.901428
wkF4gpZPEm	2022-05-21 03:19:05.484+00	2022-05-21 03:19:05.583+00	\N	\N	(-105.1721163,39.8386998)	arvada	co	us	t	-105.3019196	39.8930153	-105.042313	39.7843843
CPKxc425uw	2022-05-21 03:19:05.803+00	2022-05-21 03:19:05.903+00	\N	\N	(-81.14540185,41.53614515)	claridon township	oh	us	t	-81.1909233	41.5717142	-81.0998804	41.5005761
Bdd8pK58GU	2022-05-21 03:19:06.353+00	2022-05-21 03:19:06.452+00	\N	\N	(-76.34589285,39.5326742)	bel air	md	us	t	-76.3680653	39.5524282	-76.3237204	39.5129202
1cuXsLWzTs	2022-05-21 03:19:06.773+00	2022-05-21 03:19:06.872+00	\N	\N	(-79.20786665,39.46235365)	garrett county	md	us	t	-79.4873055	39.7227791	-78.9284278	39.2019282
QTalJSGKXq	2022-05-21 03:19:07.232+00	2022-05-21 03:19:07.331+00	\N	\N	(-82.5031522,35.322206449999996)	henderson county	nc	us	t	-82.7451458	35.5002247	-82.2611586	35.1441882
upYrnZG09o	2022-05-21 03:19:07.666+00	2022-05-21 03:19:07.766+00	\N	\N	(30.5978949,-29.394595000000002)	umshwathi local municipality	nl	za	t	30.2762999	-29.1638501	30.9194899	-29.6253399
GvF2ZoAanG	2022-05-21 03:19:08.004+00	2022-05-21 03:19:08.104+00	\N	\N	(-111.8525765,40.49345245)	draper	ut	us	t	-111.921989	40.5443511	-111.783164	40.4425538
C7CBulJo1A	2022-05-21 03:19:08.395+00	2022-05-21 03:19:08.495+00	\N	\N	(-98.224035,26.40968415)	hidalgo county	tx	us	t	-98.58646	26.7830283	-97.86161	26.03634
wY16aIMcIA	2022-05-21 03:19:08.762+00	2022-05-21 03:19:08.861+00	\N	\N	(-91.40514,38.0668385)	cuba	mo	us	t	-91.43223	38.086805	-91.37805	38.046872
29rKUECT7B	2022-05-21 03:19:09.217+00	2022-05-21 03:19:09.316+00	\N	\N	(-105.88850735,56.81245615)	northern saskatchewan administration district	sk	ca	t	-110.006368	60.0000252	-101.7706467	53.6248871
EpBUJy5nLH	2022-05-21 03:19:09.764+00	2022-05-21 03:19:09.864+00	\N	\N	(-71.5452008,44.47441325)	lancaster	nh	us	t	-71.6606305	44.5386388	-71.4297711	44.4101877
SR6oa5ZErA	2022-05-21 03:19:10.154+00	2022-05-21 03:19:10.254+00	\N	\N	(28.613305949999997,44.17285325)	constanța		ro	t	28.5503732	44.2213707	28.6762387	44.1243358
oBsm76bzkd	2022-05-21 03:19:10.555+00	2022-05-21 03:19:10.654+00	\N	\N	(-80.0890355,35.880390000000006)	thomasville	nc	us	t	-80.137421	35.929766	-80.04065	35.831014
7Wt8oTGxLL	2022-05-21 03:19:10.986+00	2022-05-21 03:19:11.086+00	\N	\N	(-70.56982550000001,43.3719112)	kennebunk	me	us	t	-70.6701117	43.4580055	-70.4695393	43.2858169
533r2CWU69	2022-05-21 03:19:11.364+00	2022-05-21 03:19:11.464+00	\N	\N	(11.13566415,49.436093650000004)	nuremberg	bavaria	de	t	10.9887326	49.5407534	11.2825957	49.3314339
HSye9IPRhr	2022-05-21 03:19:11.668+00	2022-05-21 03:19:11.768+00	\N	\N	(174.7772114,-41.288795300000004)	wellington	wgn	nz	t	174.6172114	-41.1287953	174.9372114	-41.4487953
20QedJl6jV	2022-05-21 03:19:11.925+00	2022-05-21 03:19:12.025+00	\N	\N	(-85.8540274,43.8971705)	baldwin	mi	us	t	-85.866641	43.908217	-85.8414138	43.886124
lD9haT1hiT	2022-05-21 03:19:12.291+00	2022-05-21 03:19:12.39+00	\N	\N	(70.8028377,22.3053263)	rajkot	gj	in	t	70.6428377	22.4653263	70.9628377	22.1453263
1lcJsEIZlP	2022-05-21 03:19:12.724+00	2022-05-21 03:19:12.825+00	\N	\N	(-121.96368005,38.36329885000001)	vacaville	ca	us	t	-122.032454	38.418291	-121.8949061	38.3083067
E3nfLe2kFw	2022-05-21 03:19:13.099+00	2022-05-21 03:19:13.2+00	\N	\N	(32.64120605,-2.6630805000000004)	sengerema	mwanza	tz	t	32.4050742	-2.3143166	32.8773379	-3.0118444
uZyLCF6FYh	2022-05-21 03:19:13.454+00	2022-05-21 03:19:13.554+00	\N	\N	(-66.6078417,10.466288)	guarenas	miranda state	ve	t	-66.7678417	10.626288	-66.4478417	10.306288
DGVL54yOop	2022-05-21 03:19:13.88+00	2022-05-21 03:19:13.98+00	\N	\N	(-75.5963912,6.26951865)	medellín	ant	co	t	-75.7193741	6.3764208	-75.4734083	6.1626165
h0iEJsBsAS	2022-05-21 03:19:14.294+00	2022-05-21 03:19:14.393+00	\N	\N	(-95.44098579999999,29.0482381)	lake jackson	tx	us	t	-95.5143148	29.1217785	-95.3676568	28.9746977
n5hJzGWQkx	2022-05-21 03:19:15.007+00	2022-05-21 03:19:15.107+00	\N	\N	(-84.56066145,39.395888)	hamilton	oh	us	t	-84.6302449	39.457279	-84.491078	39.334497
sW3zXucDeb	2022-05-21 03:19:15.476+00	2022-05-21 03:19:15.577+00	\N	\N	(28.05476,-26.92748)	metsimaholo local municipality	fs	za	t	27.68047	-26.66874	28.42905	-27.18622
xSwrVsZ3Z2	2022-05-21 03:19:15.804+00	2022-05-21 03:19:15.904+00	\N	\N	(-80.2405803,27.196280950000002)	stuart	fl	us	t	-80.2695329	27.2452095	-80.2116277	27.1473524
tOFlQZnSlX	2022-05-21 03:19:16.155+00	2022-05-21 03:19:16.255+00	\N	\N	(-93.98781195,41.68248465)	dallas center	ia	us	t	-94.0351008	41.6993532	-93.9405231	41.6656161
EH5N7or8sG	2022-05-21 03:19:16.75+00	2022-05-21 03:19:16.85+00	\N	\N	(-81.34431230000001,41.4666201)	russell township	oh	us	t	-81.391518	41.500537	-81.2971066	41.4327032
ODmZos6wY1	2022-05-21 03:19:17.108+00	2022-05-21 03:19:17.207+00	\N	\N	(-114.145722,47.688146)	polson	mt	us	t	-114.188912	47.707647	-114.102532	47.668645
sKyTqdheuu	2022-05-21 03:19:17.4+00	2022-05-21 03:19:17.499+00	\N	\N	(-71.8076401,42.27561335)	worcester	ma	us	t	-71.8840431	42.341187	-71.7312371	42.2100397
CVXH1PggPc	2022-05-21 03:19:17.841+00	2022-05-21 03:19:17.941+00	\N	\N	(-116.8457831,33.01738295)	san diego county	ca	us	t	-117.6105363	33.5052423	-116.0810299	32.5295236
ES131LpmyU	2022-05-21 03:19:18.132+00	2022-05-21 03:19:18.231+00	\N	\N	(-91.08024384999999,30.5158579)	east baton rouge parish	la	us	t	-91.3163654	30.7192468	-90.8441223	30.312469
BfCTyZ1bmq	2022-05-21 03:19:18.51+00	2022-05-21 03:19:18.609+00	\N	\N	(-117.0441755,34.0407185)	yucaipa	ca	us	t	-117.126232	34.077422	-116.962119	34.004015
G8Rne8HjEJ	2022-05-21 03:19:18.782+00	2022-05-21 03:19:18.882+00	\N	\N	(-96.82830395,46.84718955)	fargo	nd	us	t	-96.903771	46.9629491	-96.7528369	46.73143
k0yPeTNEEy	2022-05-21 03:19:19.104+00	2022-05-21 03:19:19.203+00	\N	\N	(-92.4768235,44.735691599999996)	ellsworth	wi	us	t	-92.497171	44.757483	-92.456476	44.7139002
tmLImQXn8M	2022-05-21 03:19:19.472+00	2022-05-21 03:19:19.572+00	\N	\N	(-122.95833515,49.23993265)	burnaby	bc	ca	t	-123.0240678	49.2996734	-122.8926025	49.1801919
RWjtQr3xER	2022-05-21 03:19:19.904+00	2022-05-21 03:19:20.003+00	\N	\N	(-86.8571555,36.50107250000001)	robertson county	tn	us	t	-87.150431	36.652486	-86.56388	36.349659
EdTBgva1Tw	2022-05-21 03:19:20.409+00	2022-05-21 03:19:20.508+00	\N	\N	(-96.53373529999999,36.58003985)	osage county	ok	us	t	-97.067009	36.999286	-96.0004616	36.1607937
jdpFKZBSKo	2022-05-21 03:19:20.846+00	2022-05-21 03:19:20.945+00	\N	\N	(12.23718925,55.924229600000004)	hillerød municipality	capital region of denmark	dk	t	12.0796875	56.0033716	12.394691	55.8450876
cEmwsQIaoH	2022-05-21 03:19:21.429+00	2022-05-21 03:19:21.529+00	\N	\N	(-77.2454031,18.3303434)	saint ann		jm	t	-77.4941725	18.4799067	-76.9966337	18.1807801
cXiKyQSZXL	2022-05-21 03:19:21.918+00	2022-05-21 03:19:22.018+00	\N	\N	(-69.80027480000001,18.5264558)	santo domingo este	santo domingo	do	t	-69.8979393	18.598232	-69.7026103	18.4546796
DtpsZXpB0l	2022-05-21 03:19:22.326+00	2022-05-21 03:19:22.426+00	\N	\N	(-124.90600605,49.69644975)	comox	bc	ca	t	-124.9573767	49.7293594	-124.8546354	49.6635401
ib1nbWOdj9	2022-05-21 03:19:22.722+00	2022-05-21 03:19:22.822+00	\N	\N	(-77.3928105,35.580230650000004)	pitt county	nc	us	t	-77.700905	35.832825	-77.084716	35.3276363
E5HEkhKTO7	2022-05-21 03:19:23.219+00	2022-05-21 03:19:23.319+00	\N	\N	(-90.9783205,38.440890100000004)	union	mo	us	t	-91.040369	38.4697574	-90.916272	38.4120228
nCzf9IsscQ	2022-05-21 03:19:23.632+00	2022-05-21 03:19:23.733+00	\N	\N	(-72.5466223,42.11297795)	springfield	ma	us	t	-72.6221576	42.1622195	-72.471087	42.0637364
xGdPylI3wT	2022-05-21 03:19:24.122+00	2022-05-21 03:19:24.222+00	\N	\N	(-8.23407165,12.602)	kati cercle	koulikoro	ml	t	-9.0441433	13.518	-7.424	11.686
HRILLiYi38	2022-05-21 03:19:24.553+00	2022-05-21 03:19:24.653+00	\N	\N	(-105.02403425,38.933922499999994)	green mountain falls	co	us	t	-105.0413375	38.940971	-105.006731	38.926874
O3gBdI6baz	2022-05-21 03:19:24.919+00	2022-05-21 03:19:25.02+00	\N	\N	(-111.90992475,40.98432105)	farmington	ut	us	t	-111.9469205	41.0165296	-111.872929	40.9521125
CATv4wVpdB	2022-05-21 03:19:25.256+00	2022-05-21 03:19:25.355+00	\N	\N	(-155.087425,19.685067)	hilo	hi	us	t	-155.18441	19.74913	-154.99044	19.621004
uCgeAQXPBs	2022-05-21 03:19:25.667+00	2022-05-21 03:19:25.766+00	\N	\N	(-112.39787425,34.7064055)	yavapai county	az	us	t	-113.33448	35.530651	-111.4612685	33.88216
QIBRyiFBlF	2022-05-21 03:19:26.126+00	2022-05-21 03:19:26.226+00	\N	\N	(29.071804999999998,-28.374291)	maluti-a-phofung local municipality	fs	za	t	28.57961	-27.972852	29.564	-28.77573
RPPuxYpqhg	2022-05-21 03:19:26.485+00	2022-05-21 03:19:26.585+00	\N	\N	(26.7757905,-30.131415)	mohokare local municipality	fs	za	t	26.141251	-29.56875	27.41033	-30.69408
1tyNpI7f4G	2022-05-21 03:19:26.837+00	2022-05-21 03:19:26.936+00	\N	\N	(-117.18212199999999,33.5776259)	murrieta	ca	us	t	-117.2800431	33.6418181	-117.0842009	33.5134337
S5isBmyu76	2022-05-21 03:19:27.28+00	2022-05-21 03:19:27.38+00	\N	\N	(-83.1414763,35.26364965)	jackson county	nc	us	t	-83.3637692	35.5260597	-82.9191834	35.0012396
HPKb2rAeHO	2022-05-21 03:19:27.589+00	2022-05-21 03:19:27.69+00	\N	\N	(-80.5588872,40.63408)	east liverpool	oh	us	t	-80.5987834	40.654017	-80.518991	40.614143
zRh5aGoPc2	2022-05-21 03:19:27.975+00	2022-05-21 03:19:28.074+00	\N	\N	(36.955418449999996,-1.1512913)	ruiru	kiambu	ke	t	36.9383195	-1.1376053	36.9725174	-1.1649773
DFCv5xeNLG	2022-05-21 03:19:28.282+00	2022-05-21 03:19:28.381+00	\N	\N	(-51.1611463,-30.10096215)	porto alegre	rs	br	t	-51.3034404	-29.9324744	-51.0188522	-30.2694499
ABRwwxq8Ch	2022-05-21 03:19:28.737+00	2022-05-21 03:19:28.836+00	\N	\N	(-76.5118635,38.5375181)	calvert county	md	us	t	-76.7020072	38.7692981	-76.3217198	38.3057381
MKaNQswJe4	2022-05-21 03:19:29.109+00	2022-05-21 03:19:29.208+00	\N	\N	(-78.0449145,34.2151945)	leland	nc	us	t	-78.109325	34.275843	-77.980504	34.154546
BI8e2HXDMy	2022-05-21 03:19:29.537+00	2022-05-21 03:19:29.638+00	\N	\N	(-102.5161988,22.7470359)	guadalupe	zac	mx	t	-102.6761988	22.9070359	-102.3561988	22.5870359
dYYLJ28um5	2022-05-21 03:19:29.969+00	2022-05-21 03:19:30.069+00	\N	\N	(-74.3290545,40.788005999999996)	livingston	nj	us	t	-74.377517	40.818416	-74.280592	40.757596
XrtAqO8RKN	2022-05-21 03:19:30.311+00	2022-05-21 03:19:30.411+00	\N	\N	(-88.0118716,42.80020585)	village of raymond	wi	us	t	-88.0717369	42.8435597	-87.9520063	42.756852
v36lN2Mvtd	2022-05-21 03:19:30.762+00	2022-05-21 03:19:30.861+00	\N	\N	(-98.98279099999999,41.566576)	valley county	ne	us	t	-99.21476	41.740536	-98.750822	41.392616
F3rEY3jrcb	2022-05-21 03:19:31.153+00	2022-05-21 03:19:31.252+00	\N	\N	(132.5779447,-11.148727749999999)	minjilang		au	t	132.5752015	-11.1457023	132.5806879	-11.1517532
cXd9EiUFMc	2022-05-21 03:19:31.63+00	2022-05-21 03:19:31.731+00	\N	\N	(-71.30826175,43.2988282)	pittsfield	nh	us	t	-71.3813226	43.3464517	-71.2352009	43.2512047
KusBixq63n	2022-05-21 03:19:32.148+00	2022-05-21 03:19:32.249+00	\N	\N	(72.5797068,23.0216238)	ahmedabad	gj	in	t	72.4197068	23.1816238	72.7397068	22.8616238
rEa2fNU2sp	2022-05-21 03:19:32.525+00	2022-05-21 03:19:32.624+00	\N	\N	(-84.4765448,33.636832)	college park	ga	us	t	-84.524753	33.669469	-84.4283366	33.604195
AL1SDMvFZF	2022-05-21 03:19:32.915+00	2022-05-21 03:19:33.015+00	\N	\N	(24.55935795,46.5480954)	târgu mureș		ro	t	24.4918674	46.5961738	24.6268485	46.500017
es4a7BdtYs	2022-05-21 03:19:33.2+00	2022-05-21 03:19:33.3+00	\N	\N	(-97.7262325,33.7827915)	nocona	tx	us	t	-97.745178	33.802569	-97.707287	33.763014
N1MlgLfyot	2022-05-21 03:19:33.492+00	2022-05-21 03:19:33.593+00	\N	\N	(-82.60877550000001,41.24824855)	norwalk	oh	us	t	-82.659214	41.2782891	-82.558337	41.218208
EMa9n7S9kM	2022-05-21 03:19:33.796+00	2022-05-21 03:19:33.895+00	\N	\N	(-85.98471655,41.44604885)	nappanee	in	us	t	-86.040189	41.466297	-85.9292441	41.4258007
ln2avqXgJj	2022-05-21 03:19:34.084+00	2022-05-21 03:19:34.184+00	\N	\N	(-95.111552,29.4934135)	league city	tx	us	t	-95.22547	29.559078	-94.997634	29.427749
HBuyL1nIHm	2022-05-21 03:19:34.571+00	2022-05-21 03:19:34.671+00	\N	\N	(-93.8892568,35.4868706)	franklin county	ar	us	t	-94.0821406	35.7743089	-93.696373	35.1994323
2Js8OvvB5k	2022-05-21 03:19:34.956+00	2022-05-21 03:19:35.056+00	\N	\N	(-72.30835379999999,42.193200250000004)	palmer	ma	us	t	-72.395478	42.24525	-72.2212296	42.1411505
oIWUIJgBcF	2022-05-21 03:19:35.298+00	2022-05-21 03:19:35.397+00	\N	\N	(-93.19984725,44.74661155)	apple valley	mn	us	t	-93.2483505	44.7758872	-93.151344	44.7173359
AomfAjixC2	2022-05-21 03:19:35.662+00	2022-05-21 03:19:35.761+00	\N	\N	(-71.7722814,42.52449665)	leominster	ma	us	t	-71.8423261	42.5738598	-71.7022367	42.4751335
iIiW2uJRJN	2022-05-21 03:19:36.146+00	2022-05-21 03:19:36.246+00	\N	\N	(-1.0815361000000001,53.959055500000005)	york	eng	gb	t	-1.2415361	54.1190555	-0.9215361	53.7990555
vTITS4vasZ	2022-05-21 03:19:36.787+00	2022-05-21 03:19:36.887+00	\N	\N	(-78.8764395,35.38805075)	harnett county	nc	us	t	-79.2230252	35.5841114	-78.5298538	35.1919901
4dPbvHCnym	2022-05-21 03:19:37.202+00	2022-05-21 03:19:37.302+00	\N	\N	(-80.0281945,40.58338565)	mccandless	pa	us	t	-80.067672	40.614198	-79.988717	40.5525733
vi8KIZ1ySy	2022-05-21 03:19:37.688+00	2022-05-21 03:19:37.788+00	\N	\N	(13.2823903,52.68416945)	hohen neuendorf	bb	de	t	13.2042296	52.7414744	13.360551	52.6268645
uS7AaaUAvu	2022-05-21 03:19:37.966+00	2022-05-21 03:19:38.067+00	\N	\N	(-75.5698175,39.671723)	new castle	de	us	t	-75.606354	39.69097	-75.533281	39.652476
CoQsgScEzl	2022-05-21 03:19:38.388+00	2022-05-21 03:19:38.487+00	\N	\N	(-93.959199,29.8367403)	port arthur	tx	us	t	-94.106597	30.032348	-93.811801	29.6411326
QFameFpn9t	2022-05-21 03:19:38.843+00	2022-05-21 03:19:38.942+00	\N	\N	(28.800041,45.15141335)	tulcea		ro	t	28.6870918	45.2497722	28.9129902	45.0530545
sF6ApjOKZG	2022-05-21 03:19:39.172+00	2022-05-21 03:19:39.272+00	\N	\N	(-100.9763993,22.1516472)	san luis potosí	san luis potosi	mx	t	-101.1363993	22.3116472	-100.8163993	21.9916472
mlO565i3CN	2022-05-21 03:19:39.486+00	2022-05-21 03:19:39.586+00	\N	\N	(-104.66652959999999,41.32737015)	laramie county	wy	us	t	-105.2806734	41.6566709	-104.0523858	40.9980694
uDVFiLOten	2022-05-21 03:19:39.903+00	2022-05-21 03:19:40.002+00	\N	\N	(-94.68579395,29.64210695)	chambers county	tx	us	t	-95.0182049	29.8903855	-94.353383	29.3938284
bORWDiWMhc	2022-05-21 03:19:40.268+00	2022-05-21 03:19:40.367+00	\N	\N	(-86.5103012,39.7624752)	hendricks county	in	us	t	-86.6952294	39.9241814	-86.325373	39.600769
DfPcOHAmCV	2022-05-21 03:19:40.66+00	2022-05-21 03:19:40.759+00	\N	\N	(-122.1980581,48.0915654)	marysville	wa	us	t	-122.2865099	48.1632874	-122.1096063	48.0198434
Dg2ybGG5I7	2022-05-21 03:19:41.138+00	2022-05-21 03:19:41.238+00	\N	\N	(-80.57235750000001,27.7090495)	indian river county	fl	us	t	-80.881172	27.861362	-80.263543	27.556737
Qpz62YTiRB	2022-05-21 03:19:41.565+00	2022-05-21 03:19:41.665+00	\N	\N	(-84.41544925,39.33525645)	west chester township	oh	us	t	-84.484501	39.3746952	-84.3463975	39.2958177
Bpq1pCzhcD	2022-05-21 03:19:41.989+00	2022-05-21 03:19:42.089+00	\N	\N	(-76.90285499999999,42.9086015)	town of waterloo	ny	us	t	-76.963563	42.946953	-76.842147	42.87025
fssoCF0ZCL	2022-05-21 03:19:42.347+00	2022-05-21 03:19:42.448+00	\N	\N	(-103.636695,48.188657)	williston	nd	us	t	-103.712359	48.24476	-103.561031	48.132554
L8catftULL	2022-05-21 03:19:42.712+00	2022-05-21 03:19:42.811+00	\N	\N	(-96.3525696,30.658058750000002)	bryan	tx	us	t	-96.4592491	30.7315157	-96.2458901	30.5846018
wzhbZ3ECIo	2022-05-21 03:19:43.025+00	2022-05-21 03:19:43.127+00	\N	\N	(-75.228101,43.098369000000005)	utica	ny	us	t	-75.295296	43.132269	-75.160906	43.064469
Y2nvw9CzgZ	2022-05-21 03:19:43.371+00	2022-05-21 03:19:43.471+00	\N	\N	(-97.85463204999999,30.07693655)	buda	tx	us	t	-97.9000922	30.1141548	-97.8091719	30.0397183
viQeaCyK01	2022-05-21 03:19:43.793+00	2022-05-21 03:19:43.893+00	\N	\N	(-6.2509543999999995,53.3546379)	dublin		ie	t	-6.3870259	53.4105416	-6.1148829	53.2987342
ACJo8suydl	2022-05-21 03:19:44.13+00	2022-05-21 03:19:44.231+00	\N	\N	(-80.1801375,33.000014199999995)	summerville	sc	us	t	-80.235478	33.0551744	-80.124797	32.944854
CyIQvua5Cq	2022-05-21 03:19:44.483+00	2022-05-21 03:19:44.583+00	\N	\N	(-99.8940182,16.8680495)	acapulco	gro	mx	t	-100.0540182	17.0280495	-99.7340182	16.7080495
ECJ2Tztd3g	2022-05-21 03:19:44.786+00	2022-05-21 03:19:44.885+00	\N	\N	(-88.31630899999999,41.991208)	south elgin	il	us	t	-88.364869	42.012685	-88.267749	41.969731
AWOWByW1Lc	2022-05-21 03:19:45.181+00	2022-05-21 03:19:45.281+00	\N	\N	(-88.65218745,32.401287499999995)	lauderdale county	ms	us	t	-88.9156121	32.5782944	-88.3887628	32.2242806
3mTuzp3m1u	2022-05-21 03:19:45.5+00	2022-05-21 03:19:45.6+00	\N	\N	(-86.5741107,40.58433985)	carroll county	in	us	t	-86.7742974	40.7377797	-86.373924	40.4309
lRMJk0Afcx	2022-05-21 03:19:45.79+00	2022-05-21 03:19:45.89+00	\N	\N	(-122.81813765,49.11145085)	surrey	bc	ca	t	-122.957166	49.220825	-122.6791093	49.0020767
nhMyrQipRl	2022-05-21 03:19:46.141+00	2022-05-21 03:19:46.242+00	\N	\N	(-85.635563,40.535071)	marion	in	us	t	-85.731576	40.591091	-85.53955	40.479051
Y3xorue6S2	2022-05-21 03:19:46.589+00	2022-05-21 03:19:46.688+00	\N	\N	(-90.08995695,29.66279435)	jefferson parish	la	us	t	-90.2802345	30.230524	-89.8996794	29.0950647
wGQMEFhypZ	2022-05-21 03:19:46.972+00	2022-05-21 03:19:47.073+00	\N	\N	(-73.07995115,43.7989649)	brandon	vt	us	t	-73.1563861	43.8471899	-73.0035162	43.7507399
Z9WnZwounT	2022-05-21 03:19:47.4+00	2022-05-21 03:19:47.501+00	\N	\N	(-94.71657074999999,31.321272399999998)	lufkin	tx	us	t	-94.7750478	31.3879599	-94.6580937	31.2545849
uK0aU7MtxB	2022-05-21 03:19:47.803+00	2022-05-21 03:19:47.903+00	\N	\N	(-71.01134545,42.4675541)	saugus	ma	us	t	-71.0542145	42.5051922	-70.9684764	42.429916
OVsHmHRe0D	2022-05-21 03:19:48.222+00	2022-05-21 03:19:48.322+00	\N	\N	(-80.9455365,27.301078500000003)	okeechobee county	fl	us	t	-81.213717	27.643238	-80.677356	26.958919
ntFGdt8jol	2022-05-21 03:19:48.754+00	2022-05-21 03:19:48.854+00	\N	\N	(-84.03809849999999,33.9603405)	gwinnett county	ga	us	t	-84.277093	34.167873	-83.799104	33.752808
yS9hemzIBt	2022-05-21 03:19:49.118+00	2022-05-21 03:19:49.218+00	\N	\N	(-93.9796752,33.43345865)	texarkana	ar	us	t	-94.0431953	33.5150583	-93.9161551	33.351859
wK2t6SO3fk	2022-05-21 03:19:49.461+00	2022-05-21 03:19:49.563+00	\N	\N	(-79.7946,34.170224000000005)	florence	sc	us	t	-79.87218	34.22983	-79.71702	34.110618
OzlXficYEr	2022-05-21 03:19:49.81+00	2022-05-21 03:19:49.91+00	\N	\N	(-83.35771084999999,41.52321015)	clay township	oh	us	t	-83.4154667	41.559789	-83.299955	41.4866313
dMgM8tSMd5	2022-05-21 03:19:50.243+00	2022-05-21 03:19:50.342+00	\N	\N	(-122.55372485000001,38.09373225)	novato	ca	us	t	-122.6237763	38.1479824	-122.4836734	38.0394821
oYF5cfPGMm	2022-05-21 03:19:50.606+00	2022-05-21 03:19:50.705+00	\N	\N	(-112.1728565,47.816606500000006)	choteau	mt	us	t	-112.196349	47.830384	-112.149364	47.802829
HPVZjfBJfp	2022-05-21 03:19:51.074+00	2022-05-21 03:19:51.173+00	\N	\N	(-84.40674150000001,30.1307755)	wakulla county	fl	us	t	-84.738028	30.303501	-84.075455	29.95805
z4ZQwQhsub	2022-05-21 03:19:51.372+00	2022-05-21 03:19:51.472+00	\N	\N	(7.09436345,5.4322841)	owerri north	im	ng	t	7.013906	5.5406241	7.1748209	5.3239441
2oEfVJgofg	2022-05-21 03:19:51.762+00	2022-05-21 03:19:51.863+00	\N	\N	(-92.34284285000001,42.4958222)	waterloo	ia	us	t	-92.4368211	42.5704868	-92.2488646	42.4211576
Y4H6H9Gpxt	2022-05-21 03:19:52.204+00	2022-05-21 03:19:52.304+00	\N	\N	(-104.76326449999999,40.429392)	greeley	co	us	t	-104.907386	40.481218	-104.619143	40.377566
croPtfUZJ6	2022-05-21 03:19:52.548+00	2022-05-21 03:19:52.649+00	\N	\N	(-82.038314,41.2830675)	grafton	oh	us	t	-82.074792	41.303148	-82.001836	41.262987
ANkRUvpYXA	2022-05-21 03:19:52.861+00	2022-05-21 03:19:52.961+00	\N	\N	(-81.26088715,28.56651)	orange county	fl	us	t	-81.658619	28.786278	-80.8631553	28.346742
dsAWalTw6E	2022-05-21 03:19:53.293+00	2022-05-21 03:19:53.393+00	\N	\N	(-104.5719941,44.5881695)	crook county	wy	us	t	-105.0894282	45.0001751	-104.05456	44.1761639
eCAc4ruB1X	2022-05-21 03:19:53.792+00	2022-05-21 03:19:53.892+00	\N	\N	(10.2134046,56.149627800000005)	aarhus	central denmark region	dk	t	10.0534046	56.3096278	10.3734046	55.9896278
zUfT33oKr6	2022-05-21 03:19:54.27+00	2022-05-21 03:19:54.37+00	\N	\N	(11.847808950000001,54.76539775)	guldborgsund municipality	region zealand	dk	t	11.5300405	54.9717311	12.1655774	54.5590644
3f1Eywv2Ya	2022-05-21 03:19:54.695+00	2022-05-21 03:19:54.795+00	\N	\N	(-77.8010735,38.715668)	warrenton	va	us	t	-77.824558	38.737892	-77.777589	38.693444
AEOKebBjgd	2022-05-21 03:19:54.994+00	2022-05-21 03:19:55.095+00	\N	\N	(-71.799744,42.757711)	greenville	nh	us	t	-71.821827	42.790035	-71.777661	42.725387
P9tBOXrG6j	2022-05-21 03:19:55.533+00	2022-05-21 03:19:55.633+00	\N	\N	(-69.6109731,18.456662299999998)	boca chica	santo domingo	do	t	-69.7070545	18.5129981	-69.5148917	18.4003265
C6z4oaLint	2022-05-21 03:19:55.91+00	2022-05-21 03:19:56.009+00	\N	\N	(-103.02703754999999,49.9160237)	golden west no. 95	sk	ca	t	-103.2345965	50.0472524	-102.8194786	49.784795
p2PsIb4rDh	2022-05-21 03:19:56.395+00	2022-05-21 03:19:56.495+00	\N	\N	(-91.66281975,41.96525175)	cedar rapids	ia	us	t	-91.7745806	42.0689041	-91.5510589	41.8615994
5TDputCBAf	2022-05-21 03:19:56.807+00	2022-05-21 03:19:56.907+00	\N	\N	(24.128527300000002,56.97166385)	riga	vidzeme	lv	t	23.9325504	57.0859815	24.3245042	56.8573462
9lLxvKW8jl	2022-05-21 03:19:57.146+00	2022-05-21 03:19:57.246+00	\N	\N	(-77.34614450000001,38.646348)	dale city	va	us	t	-77.402553	38.681165	-77.289736	38.611531
D2oLMPT9Qt	2022-05-21 03:19:57.574+00	2022-05-21 03:19:57.674+00	\N	\N	(-84.42031399999999,33.767315499999995)	atlanta	ga	us	t	-84.551068	33.886823	-84.28956	33.647808
SCMOvlCbhv	2022-05-21 03:19:58.067+00	2022-05-21 03:19:58.167+00	\N	\N	(-111.84881855,40.6872958)	millcreek	ut	us	t	-111.921104	40.7143706	-111.7765331	40.660221
7abaIsvtje	2022-05-21 03:19:58.378+00	2022-05-21 03:19:58.478+00	\N	\N	(-86.10821,38.4064275)	palmyra	in	us	t	-86.123632	38.41935	-86.092788	38.393505
enGwNAGw9V	2022-05-21 03:19:58.763+00	2022-05-21 03:19:58.863+00	\N	\N	(-88.83093099999999,33.4594945)	starkville	ms	us	t	-88.875593	33.512702	-88.786269	33.406287
0zGQmUlGMZ	2022-05-21 03:19:59.138+00	2022-05-21 03:19:59.238+00	\N	\N	(-96.4194684,32.91987345)	rockwall	tx	us	t	-96.4891902	32.982448	-96.3497466	32.8572989
VGEyqSEj4h	2022-05-21 03:19:59.515+00	2022-05-21 03:19:59.614+00	\N	\N	(-86.422798,35.860346500000006)	rutherford county	tn	us	t	-86.700218	36.10061	-86.145378	35.620083
VTEYs2AKy8	2022-05-21 03:19:59.857+00	2022-05-21 03:19:59.956+00	\N	\N	(26.478585000000002,-33.252404999999996)	makana local municipality	ec	za	t	25.94819	-32.93213	27.00898	-33.57268
yrPahMN3GM	2022-05-21 03:20:00.252+00	2022-05-21 03:20:00.352+00	\N	\N	(150.85083985,-34.341883100000004)	wollongong city council	nsw	au	t	150.6351001	-34.1300239	151.0665796	-34.5537423
lnouK9dAE2	2022-05-21 03:20:00.728+00	2022-05-21 03:20:00.827+00	\N	\N	(-114.0123038,46.8707448)	missoula	mt	us	t	-114.1272915	46.949951	-113.8973161	46.7915386
ZWPl6k6zWG	2022-05-21 03:20:01.062+00	2022-05-21 03:20:01.163+00	\N	\N	(-94.84640705000001,37.1692823)	cherokee county	ks	us	t	-95.0751661	37.3399684	-94.617648	36.9985962
6UPA0GaJlq	2022-05-21 03:20:01.472+00	2022-05-21 03:20:01.573+00	\N	\N	(44.3107804,15.2246735)		sana'a governorate	ye	t	44.1703253	15.3792124	44.4512355	15.0701346
E5VoIeGfyy	2022-05-21 03:20:02.347+00	2022-05-21 03:20:02.447+00	\N	\N	(-5.83713205,55.989781050000005)	argyll and bute	sct	gb	t	-7.1144125	56.7050822	-4.5598516	55.2744799
8PTJjerhsD	2022-05-21 03:20:02.718+00	2022-05-21 03:20:02.818+00	\N	\N	(-80.7623221,41.91082475)	ashtabula county	oh	us	t	-81.0053395	42.3232365	-80.5193047	41.498413
m2M1a9loAM	2022-05-21 03:20:03.103+00	2022-05-21 03:20:03.204+00	\N	\N	(-83.8908865,40.4678575)	russells point	oh	us	t	-83.903211	40.480573	-83.878562	40.455142
JRoXkGQr5O	2022-05-21 03:20:03.558+00	2022-05-21 03:20:03.658+00	\N	\N	(-72.57600045000001,42.2586205)	south hadley	ma	us	t	-72.6241107	42.3056834	-72.5278902	42.2115576
U3zOSSplZg	2022-05-21 03:20:03.879+00	2022-05-21 03:20:03.979+00	\N	\N	(-87.4457123,41.6502085)	east chicago	in	us	t	-87.4904786	41.690473	-87.400946	41.609944
YsVIg2CRyV	2022-05-21 03:20:04.377+00	2022-05-21 03:20:04.476+00	\N	\N	(-92.55804555,44.905874499999996)	town of kinnickinnic	wi	us	t	-92.6192763	44.949301	-92.4968148	44.862448
3AvSht4P9M	2022-05-21 03:20:04.828+00	2022-05-21 03:20:04.929+00	\N	\N	(-77.03815700000001,41.241145)	williamsport	pa	us	t	-77.095566	41.26427	-76.980748	41.21802
FvY1utEixG	2022-05-21 03:20:05.148+00	2022-05-21 03:20:05.248+00	\N	\N	(27.580185,-30.867765)	senqu local municipality	ec	za	t	26.99808	-30.31323	28.16229	-31.4223
faeCMvJoYr	2022-05-21 03:20:05.517+00	2022-05-21 03:20:05.618+00	\N	\N	(15.096119850000001,48.19996185)	gemeinde persenbeug-gottsdorf	lower austria	at	t	15.0707746	48.2287867	15.1214651	48.171137
OP5e7FRvGM	2022-05-21 03:20:05.892+00	2022-05-21 03:20:05.993+00	\N	\N	(-149.4415055,61.108472500000005)	anchorage	ak	us	t	-150.420615	61.483938	-148.462396	60.733007
2gcXjV72WV	2022-05-21 03:20:06.291+00	2022-05-21 03:20:06.39+00	\N	\N	(-71.1467695,43.734631050000004)	ossipee	nh	us	t	-71.2799437	43.8328411	-71.0135953	43.636421
HhQ7FnMFKl	2022-05-21 03:20:06.588+00	2022-05-21 03:20:06.689+00	\N	\N	(-94.50889035,37.0953335)	joplin	mo	us	t	-94.5774257	37.173653	-94.440355	37.017014
SmUkBFcqiz	2022-05-21 03:20:06.944+00	2022-05-21 03:20:07.043+00	\N	\N	(-84.567047,37.897914)	nicholasville	ky	us	t	-84.627279	37.963316	-84.506815	37.832512
xqlrnk8FrI	2022-05-21 03:20:07.254+00	2022-05-21 03:20:07.353+00	\N	\N	(-71.08032954999999,41.5873315)	westport	ma	us	t	-71.138347	41.6928042	-71.0223121	41.4818588
Ca7jlw2ryn	2022-05-21 03:20:07.52+00	2022-05-21 03:20:07.619+00	\N	\N	(-75.8055088,39.89134824999999)	west marlborough township	pa	us	t	-75.8531507	39.9334077	-75.7578669	39.8492888
vCd8KKMG67	2022-05-21 03:20:08.063+00	2022-05-21 03:20:08.162+00	\N	\N	(-85.13354995,43.1631327)	fairplain township	mi	us	t	-85.1935892	43.2067044	-85.0735107	43.119561
M9mBJf6bVw	2022-05-21 03:20:08.464+00	2022-05-21 03:20:08.563+00	\N	\N	(-83.77798475,42.17629235)	saline	mi	us	t	-83.80274	42.1996149	-83.7532295	42.1529698
KRuoKnZAib	2022-05-21 03:20:08.867+00	2022-05-21 03:20:08.967+00	\N	\N	(-106.6243417,52.1471902)	saskatoon (city)	sk	ca	t	-107.3243417	52.8471902	-105.9243417	51.4471902
HduIOlMlLK	2022-05-21 03:20:09.374+00	2022-05-21 03:20:09.473+00	\N	\N	(-61.63019865,10.71470975)		dmn	tt	t	-61.7647786	10.7721315	-61.4956187	10.657288
8Vn5tV5Xba	2022-05-21 03:20:09.735+00	2022-05-21 03:20:09.836+00	\N	\N	(30.118454999999997,-26.51525)	msukaligwa	mp	za	t	29.46867	-26.17069	30.76824	-26.85981
89TADhrKGs	2022-05-21 03:20:10.266+00	2022-05-21 03:20:10.366+00	\N	\N	(-93.60710075,41.721724949999995)	ankeny	ia	us	t	-93.6727663	41.7913181	-93.5414352	41.6521318
aFpjFrUG1f	2022-05-21 03:20:10.672+00	2022-05-21 03:20:10.772+00	\N	\N	(8.63663245,50.121342150000004)	frankfurt	hesse	de	t	8.4727933	50.2271408	8.8004716	50.0155435
x0K3kRTEE6	2022-05-21 03:20:11.052+00	2022-05-21 03:20:11.153+00	\N	\N	(-102.83128535,34.068834)	bailey county	tx	us	t	-103.0474127	34.3129215	-102.615158	33.8247465
wnatgLKJpO	2022-05-21 03:20:11.421+00	2022-05-21 03:20:11.521+00	\N	\N	(-73.96584465,41.135414999999995)	town of clarkstown	ny	us	t	-74.041688	41.19251	-73.8900013	41.07832
PcRkwtLrSU	2022-05-21 03:20:11.794+00	2022-05-21 03:20:11.893+00	\N	\N	(-83.9620362,35.990065799999996)	knox county	tn	us	t	-84.2729954	36.1858316	-83.651077	35.7943
FZcZPV6TLf	2022-05-21 03:20:12.239+00	2022-05-21 03:20:12.34+00	\N	\N	(-81.5417805,39.2568075)	parkersburg	wv	us	t	-81.580832	39.309381	-81.502729	39.204234
6iiBsxj7Tg	2022-05-21 03:20:12.572+00	2022-05-21 03:20:12.673+00	\N	\N	(-58.7187151,-34.5367864)	san miguel	b	ar	t	-58.7408935	-34.518282	-58.6965367	-34.5552908
GA7AA1HIrQ	2022-05-21 03:20:12.959+00	2022-05-21 03:20:13.059+00	\N	\N	(-79.80429805,35.713273099999995)	randolph county	nc	us	t	-80.0668286	35.9206985	-79.5417675	35.5058477
7R5Njww5Yt	2022-05-21 03:20:13.437+00	2022-05-21 03:20:13.537+00	\N	\N	(-86.3939515,36.9833945)	warren county	ky	us	t	-86.674332	37.190479	-86.113571	36.77631
DBPN41zWmC	2022-05-21 03:20:13.903+00	2022-05-21 03:20:14.003+00	\N	\N	(26.081007149999998,44.98914619999999)	bucov		ro	t	26.0177406	45.0273	26.1442737	44.9509924
jyrchNdGvB	2022-05-21 03:20:14.361+00	2022-05-21 03:20:14.462+00	\N	\N	(22.8989591,45.8774782)	deva		ro	t	22.8737	45.9016763	22.9242182	45.8532801
svSju1q8gI	2022-05-21 03:20:14.708+00	2022-05-21 03:20:14.808+00	\N	\N	(-76.27829735,36.708806949999996)	chesapeake	va	us	t	-76.4913958	36.8671757	-76.0651989	36.5504382
aa3BIpa4Q8	2022-05-21 03:20:15.105+00	2022-05-21 03:20:15.204+00	\N	\N	(-74.84827,40.07259475)	burlington township	nj	us	t	-74.899002	40.1203045	-74.797538	40.024885
itIjPBBHkX	2022-05-21 03:20:15.639+00	2022-05-21 03:20:15.739+00	\N	\N	(-111.8410671,41.73636995)	logan	ut	us	t	-111.9019425	41.7973558	-111.7801917	41.6753841
vyb4pigY5W	2022-05-21 03:20:16.006+00	2022-05-21 03:20:16.105+00	\N	\N	(-77.4871048,38.7436354)	manassas	va	us	t	-77.5265024	38.7811645	-77.4477072	38.7061063
PFBYSRn26y	2022-05-21 03:20:16.353+00	2022-05-21 03:20:16.452+00	\N	\N	(-70.95236704999999,42.853179850000004)	amesbury	ma	us	t	-71.0049017	42.8866472	-70.8998324	42.8197125
koePaWo26X	2022-05-21 03:20:16.808+00	2022-05-21 03:20:16.907+00	\N	\N	(-103.80675550000001,40.262335)	morgan county	co	us	t	-104.150414	40.524071	-103.463097	40.000599
Q1yKwsZwss	2022-05-21 03:20:17.215+00	2022-05-21 03:20:17.315+00	\N	\N	(-70.62931425,41.57476615)	falmouth	ma	us	t	-70.7606313	41.6603883	-70.4979972	41.489144
A04STYppyY	2022-05-21 03:20:17.6+00	2022-05-21 03:20:17.699+00	\N	\N	(-86.12707900000001,40.472435700000005)	kokomo	in	us	t	-86.184256	40.5346033	-86.069902	40.4102681
SE2GBFkOk9	2022-05-21 03:20:18.064+00	2022-05-21 03:20:18.163+00	\N	\N	(-82.4071415,36.34685)	johnson city	tn	us	t	-82.52183	36.434556	-82.292453	36.259144
t97128Y1Hz	2022-05-21 03:20:18.562+00	2022-05-21 03:20:18.663+00	\N	\N	(-93.32684995,30.264308)	calcasieu parish	la	us	t	-93.7660903	30.4904181	-92.8876096	30.0381979
ak58eBxXCz	2022-05-21 03:20:19.124+00	2022-05-21 03:20:19.224+00	\N	\N	(145.02961325,28.056502799999997)	tokyo		jp	t	135.8536855	35.8984245	154.205541	20.2145811
9oSWBcjb4w	2022-05-21 03:20:19.533+00	2022-05-21 03:20:19.633+00	\N	\N	(-75.6263617,45.485753450000004)	gatineau	qc	ca	t	-75.9083514	45.5991239	-75.344372	45.372383
kBIbjo2Mf2	2022-05-21 03:20:19.854+00	2022-05-21 03:20:19.954+00	\N	\N	(-83.90911969999999,39.70016595)	xenia township	oh	us	t	-83.981098	39.784885	-83.8371414	39.6154469
AvUT7BRvfH	2022-05-21 03:20:20.347+00	2022-05-21 03:20:20.448+00	\N	\N	(-85.2357805,34.936926)	fort oglethorpe	ga	us	t	-85.28306	34.978504	-85.188501	34.895348
1mPCaqBnOr	2022-05-21 03:20:20.806+00	2022-05-21 03:20:20.906+00	\N	\N	(-76.6541175,41.0265275)	montour county	pa	us	t	-76.795868	41.172119	-76.512367	40.880936
ihjKgV63oU	2022-05-21 03:20:21.132+00	2022-05-21 03:20:21.232+00	\N	\N	(24.6667445,45.1420698)	curtea de argeș	115300	ro	t	24.632185	45.1801364	24.701304	45.1040032
jhoL8edxVG	2022-05-21 03:20:21.454+00	2022-05-21 03:20:21.553+00	\N	\N	(-69.50884020000001,47.82315135)	rivière-du-loup	qc	ca	t	-69.5859865	47.8907909	-69.4316939	47.7555118
lt2a552g9Y	2022-05-21 03:20:21.84+00	2022-05-21 03:20:21.94+00	\N	\N	(-82.43868900000001,27.4273321)	manatee county	fl	us	t	-82.823029	27.64668	-82.054349	27.2079842
CSp6aQNYdA	2022-05-21 03:20:22.158+00	2022-05-21 03:20:22.258+00	\N	\N	(-110.31261620000001,24.1422841)	la paz	lower california south	mx	t	-110.4726162	24.3022841	-110.1526162	23.9822841
PVUnZ7Dq9J	2022-05-21 03:20:22.447+00	2022-05-21 03:20:22.547+00	\N	\N	(-113.6433095,42.33475295)	cassia county	id	us	t	-114.286654	42.680672	-112.999965	41.9888339
HqT6bN1O4X	2022-05-21 03:20:22.869+00	2022-05-21 03:20:22.969+00	\N	\N	(-111.9550479,41.1736284)	south ogden	ut	us	t	-111.9812568	41.197902	-111.928839	41.1493548
6nUcKIYv5X	2022-05-21 03:20:23.211+00	2022-05-21 03:20:23.31+00	\N	\N	(-75.42387790000001,40.15163)	lower providence township	pa	us	t	-75.4716268	40.2002518	-75.376129	40.1030082
Hp9eJcF2Cj	2022-05-21 03:20:23.687+00	2022-05-21 03:20:23.786+00	\N	\N	(-82.45568324999999,34.8497723)	greenville county	sc	us	t	-82.7644102	35.2154852	-82.1469563	34.4840594
O80qjX9xqm	2022-05-21 03:20:24.062+00	2022-05-21 03:20:24.161+00	\N	\N	(-89.6449988,42.60356095)	monroe	wi	us	t	-89.6717003	42.6251367	-89.6182973	42.5819852
1M90ONusMI	2022-05-21 03:20:24.414+00	2022-05-21 03:20:24.514+00	\N	\N	(-115.11809034999999,47.692402)	sanders county	mt	us	t	-116.0491187	48.264087	-114.187062	47.120717
Pqw22KEGpT	2022-05-21 03:20:24.871+00	2022-05-21 03:20:24.972+00	\N	\N	(-75.18690375,40.8476383)	washington township	pa	us	t	-75.2434144	40.8988668	-75.1303931	40.7964098
iKVT1mYAsG	2022-05-21 03:20:25.257+00	2022-05-21 03:20:25.356+00	\N	\N	(-75.74613495,40.5248815)	maxatawny township	pa	us	t	-75.818421	40.57994	-75.6738489	40.469823
wc5wFVYNTB	2022-05-21 03:20:25.645+00	2022-05-21 03:20:25.745+00	\N	\N	(-86.59453450000001,30.661167)	okaloosa county	fl	us	t	-86.800554	30.99698	-86.388515	30.325354
frwV9XxmFs	2022-05-21 03:20:26.127+00	2022-05-21 03:20:26.227+00	\N	\N	(-2.7091470500000003,50.9842709)	south somerset	eng	gb	t	-3.0924352	51.1477031	-2.3258589	50.8208387
dlMMBRtbpG	2022-05-21 03:20:26.481+00	2022-05-21 03:20:26.58+00	\N	\N	(-95.7634714,43.99236795)	slayton	mn	us	t	-95.7835165	44.0075477	-95.7434263	43.9771882
Aqb09hAvV7	2022-05-21 03:20:26.884+00	2022-05-21 03:20:26.984+00	\N	\N	(-79.11431225,43.9019164)	pickering	on	ca	t	-79.2200381	44.0107582	-79.0085864	43.7930746
QHUNHegAxG	2022-05-21 03:20:27.289+00	2022-05-21 03:20:27.389+00	\N	\N	(-74.720593,40.568668)	branchburg township	nj	us	t	-74.774763	40.635429	-74.666423	40.501907
FHP3QEXLG9	2022-05-21 03:20:27.649+00	2022-05-21 03:20:27.749+00	\N	\N	(-98.94583895,30.31811855)	gillespie county	tx	us	t	-99.3042164	30.4999945	-98.5874615	30.1362426
JjaEfkU2bV	2022-05-21 03:20:28.052+00	2022-05-21 03:20:28.153+00	\N	\N	(-98.15717815,19.0338589)	puebla	pue	mx	t	-98.2941242	19.2309383	-98.0202321	18.8367795
C8Ovf7aMXw	2022-05-21 03:20:28.497+00	2022-05-21 03:20:28.597+00	\N	\N	(29.992885,-27.101935)	pixley ka seme local municipality	mp	za	t	29.41886	-26.69772	30.56691	-27.50615
msr2Gvy7ND	2022-05-21 03:20:28.814+00	2022-05-21 03:20:28.915+00	\N	\N	(-83.3864076,42.65991525)	oakland county	mi	us	t	-83.689438	42.888647	-83.0833772	42.4311835
AGHgYcnsJN	2022-05-21 03:20:29.346+00	2022-05-21 03:20:29.446+00	\N	\N	(9.170923649999999,44.7442012)	fabbrica curone	piemont	it	t	9.1276069	44.802389	9.2142404	44.6860134
eyMOO4x8p1	2022-05-21 03:20:29.759+00	2022-05-21 03:20:29.859+00	\N	\N	(-95.5136359,35.9651815)	wagoner county	ok	us	t	-95.819527	36.163506	-95.2077448	35.766857
SQ72LHvetf	2022-05-21 03:20:30.153+00	2022-05-21 03:20:30.252+00	\N	\N	(-75.05663150000001,42.4671805)	town of oneonta	ny	us	t	-75.138323	42.529268	-74.97494	42.405093
OfsVvIw2iS	2022-05-21 03:20:30.686+00	2022-05-21 03:20:30.785+00	\N	\N	(17.0738106,58.742102450000004)	nyköpings kommun		se	t	16.2689173	59.030544	17.8787039	58.4536609
urDZrgbEZ0	2022-05-21 03:20:31.099+00	2022-05-21 03:20:31.198+00	\N	\N	(120.93686944999999,14.4002552)	imus	cavite	ph	t	120.8920699	14.4463766	120.981669	14.3541338
BIwqSjugmI	2022-05-21 03:20:31.515+00	2022-05-21 03:20:31.614+00	\N	\N	(-85.1643454,31.905250000000002)	eufaula	al	us	t	-85.2798659	32.029122	-85.0488249	31.781378
Nn8qmPab0z	2022-05-21 03:20:31.983+00	2022-05-21 03:20:32.083+00	\N	\N	(-1.9694054,51.84505515)	cotswold	eng	gb	t	-2.3236088	52.1125797	-1.615202	51.5775306
60oshA1s9D	2022-05-21 03:20:32.457+00	2022-05-21 03:20:32.557+00	\N	\N	(-80.43026900000001,26.64580015)	palm beach county	fl	us	t	-80.886232	26.9709235	-79.974306	26.3206768
7Mz6pZ5axk	2022-05-21 03:20:32.914+00	2022-05-21 03:20:33.013+00	\N	\N	(-77.75936565,18.05380725)	saint elizabeth	jmdeh26	jm	t	-77.9521233	18.2531879	-77.566608	17.8544266
Uo3Nq50WpO	2022-05-21 03:20:33.288+00	2022-05-21 03:20:33.387+00	\N	\N	(31.0748399,-27.8315999)	abaqulusi local municipality	nl	za	t	30.5788999	-27.4914299	31.5707799	-28.1717699
GE6YrTTbkV	2022-05-21 03:20:33.624+00	2022-05-21 03:20:33.723+00	\N	\N	(-76.8663315,41.0839535)	watsontown	pa	us	t	-76.879578	41.094473	-76.853085	41.073434
D20c8nBtzg	2022-05-21 03:20:34.102+00	2022-05-21 03:20:34.202+00	\N	\N	(-97.37992249999999,35.0304545)	purcell	ok	us	t	-97.424219	35.096512	-97.335626	34.964397
7y1r4on0EJ	2022-05-21 03:20:34.591+00	2022-05-21 03:20:34.691+00	\N	\N	(28.556765249999998,43.844730299999995)	mangalia		ro	t	28.4983027	43.9003914	28.6152278	43.7890692
3G2Rck3XqC	2022-05-21 03:20:35+00	2022-05-21 03:20:35.1+00	\N	\N	(-79.48824719999999,9.01644855)	parque lefevre	panamá	pa	t	-79.5073118	9.0313152	-79.4691826	9.0015819
BJbAhsyICR	2022-05-21 03:20:35.394+00	2022-05-21 03:20:35.494+00	\N	\N	(-102.7366915,43.402333)	white clay district	sd	us	t	-103.00161	43.6747657	-102.471773	43.1299003
nSZ5prDEsW	2022-05-21 03:20:35.851+00	2022-05-21 03:20:35.951+00	\N	\N	(12.21312695,56.04885465)	gribskov municipality	capital region of denmark	dk	t	12.0088291	56.1292187	12.4174248	55.9684906
OQ2JEqZkfQ	2022-05-21 03:20:36.171+00	2022-05-21 03:20:36.271+00	\N	\N	(-93.6014161,41.56927475)	des moines	ia	us	t	-93.7091411	41.6589106	-93.4936911	41.4796389
2jEYVL6m2F	2022-05-21 03:20:36.502+00	2022-05-21 03:20:36.602+00	\N	\N	(-93.59889100000001,40.088924000000006)	trenton	mo	us	t	-93.636937	40.119052	-93.560845	40.058796
9b0zLBNTPf	2022-05-21 03:20:36.86+00	2022-05-21 03:20:36.96+00	\N	\N	(-93.72483249999999,41.703308)	johnston	ia	us	t	-93.785111	41.753938	-93.664554	41.652678
5KMuKcRbr1	2022-05-21 03:20:37.185+00	2022-05-21 03:20:37.285+00	\N	\N	(-78.95769855,43.012906)	town of grand island	ny	us	t	-79.0250771	43.069795	-78.89032	42.956017
iHzhyYvyRJ	2022-05-21 03:20:37.525+00	2022-05-21 03:20:37.625+00	\N	\N	(-106.5773893,36.46537764999999)	rio arriba county	nm	us	t	-107.6241771	37.0001451	-105.5306015	35.9306102
QQFiCH2ky6	2022-05-21 03:20:37.901+00	2022-05-21 03:20:38.001+00	\N	\N	(-77.28880665,38.8308283)	fairfax county	va	us	t	-77.5370677	39.0577059	-77.0405456	38.6039507
NrwEA3VAXf	2022-05-21 03:20:38.405+00	2022-05-21 03:20:38.504+00	\N	\N	(-71.57317979999999,41.682539)	kent county	ri	us	t	-71.789703	41.768333	-71.3566566	41.596745
hC8NvqgU5e	2022-05-21 03:20:38.911+00	2022-05-21 03:20:39.011+00	\N	\N	(11.02573355,48.06206065)	windach	bavaria	de	t	10.9778441	48.088978	11.073623	48.0351433
etqGC24EHA	2022-05-21 03:20:39.258+00	2022-05-21 03:20:39.358+00	\N	\N	(-74.043455,41.552494249999995)	town of newburgh	ny	us	t	-74.133603	41.6143955	-73.953307	41.490593
BXSDYk3FKr	2022-05-21 03:20:39.637+00	2022-05-21 03:20:39.737+00	\N	\N	(24.47978625,-28.73667)	sol plaatje local municipality	nc	za	t	24.0577325	-28.42235	24.90184	-29.05099
ayxq2DMJCT	2022-05-21 03:20:39.991+00	2022-05-21 03:20:40.091+00	\N	\N	(-72.66219415,41.657854349999994)	rocky hill	ct	us	t	-72.7152914	41.6879953	-72.6090969	41.6277134
hLssNUJ0ms	2022-05-21 03:20:40.282+00	2022-05-21 03:20:40.382+00	\N	\N	(-151.655897,60.036583)	kenai peninsula	ak	us	t	-154.748768	61.428157	-148.563026	58.645009
Li3Hl8U40F	2022-05-21 03:20:40.748+00	2022-05-21 03:20:40.847+00	\N	\N	(-120.69468119999999,46.56460425)	yakima county	wa	us	t	-121.523938	47.0891105	-119.8654244	46.040098
HEufJeLEqo	2022-05-21 03:20:41.486+00	2022-05-21 03:20:41.586+00	\N	\N	(39.667169,-4.05052)	mombasa	mombasa	ke	t	39.507169	-3.89052	39.827169	-4.21052
TBFHkG0sZS	2022-05-21 03:20:41.904+00	2022-05-21 03:20:42.003+00	\N	\N	(-85.37436249999999,40.45406)	hartford city	in	us	t	-85.407539	40.4764	-85.341186	40.43172
hc0XAB2M20	2022-05-21 03:20:42.297+00	2022-05-21 03:20:42.397+00	\N	\N	(-83.6492815,41.38171825)	bowling green	oh	us	t	-83.698601	41.414595	-83.599962	41.3488415
vm7renKAAD	2022-05-21 03:20:42.771+00	2022-05-21 03:20:42.871+00	\N	\N	(-77.86640455,18.3656834)	saint james		jm	t	-77.9967257	18.5251491	-77.7360834	18.2062177
KdrTGGYc70	2022-05-21 03:20:43.205+00	2022-05-21 03:20:43.304+00	\N	\N	(-100.9616387,35.54786875)	pampa	tx	us	t	-100.9956754	35.5771915	-100.927602	35.518546
LfzUvnGOqE	2022-05-21 03:20:43.507+00	2022-05-21 03:20:43.607+00	\N	\N	(-85.18663000000001,35.259343)	soddy-daisy	tn	us	t	-85.253956	35.333583	-85.119304	35.185103
AuxgjKAm6L	2022-05-21 03:20:43.986+00	2022-05-21 03:20:44.086+00	\N	\N	(-85.446575,37.756668)	nelson county	ky	us	t	-85.742508	37.990562	-85.150642	37.522774
96rniiWQXm	2022-05-21 03:20:44.431+00	2022-05-21 03:20:44.531+00	\N	\N	(-74.9894545,43.823372500000005)	town of webb	ny	us	t	-75.170543	44.097068	-74.808366	43.549677
8dlgJqb1Eo	2022-05-21 03:20:44.813+00	2022-05-21 03:20:44.912+00	\N	\N	(-66.11128585,43.837346049999994)	town of yarmouth	ns	ca	t	-66.1340164	43.8572084	-66.0885553	43.8174837
upy0fFHxzN	2022-05-21 03:20:45.279+00	2022-05-21 03:20:45.379+00	\N	\N	(27.478222,-29.310054)	maseru	maseru district	ls	t	27.318222	-29.150054	27.638222	-29.470054
a7MWBbbdWJ	2022-05-21 03:20:45.685+00	2022-05-21 03:20:45.785+00	\N	\N	(-84.471565,38.0283496)	lexington	ky	us	t	-84.660415	38.211404	-84.282715	37.8452952
xlz2CBPCI4	2022-05-21 03:20:46.005+00	2022-05-21 03:20:46.105+00	\N	\N	(-101.0556945,39.3509275)	thomas county	ks	us	t	-101.391281	39.568802	-100.720108	39.133053
udEyNwpvFx	2022-05-21 03:20:46.437+00	2022-05-21 03:20:46.537+00	\N	\N	(31.045686,-17.831773)	harare	harare province	zw	t	30.885686	-17.671773	31.205686	-17.991773
V7C5yKAn7F	2022-05-21 03:20:46.975+00	2022-05-21 03:20:47.075+00	\N	\N	(-99.1526135,19.32073795)	mexico city		mx	t	-99.3649242	19.5927572	-98.9403028	19.0487187
3pbHu6v8Wi	2022-05-21 03:20:47.354+00	2022-05-21 03:20:47.454+00	\N	\N	(-79.85400859999999,32.853910150000004)	charleston county	sc	us	t	-80.451912	33.215019	-79.2561052	32.4928013
O4uiuSoGVm	2022-05-21 03:20:47.719+00	2022-05-21 03:20:47.819+00	\N	\N	(-84.5547655,39.992379)	arcanum	oh	us	t	-84.565651	40.005278	-84.54388	39.97948
GYZJVUEE0o	2022-05-21 03:20:48.129+00	2022-05-21 03:20:48.229+00	\N	\N	(-72.1560293,44.00941675)	bradford	vt	us	t	-72.2328254	44.0614232	-72.0792332	43.9574103
ljRG1hRgaG	2022-05-21 03:20:48.494+00	2022-05-21 03:20:48.594+00	\N	\N	(-155.43789650000002,19.593456500000002)	hawaiʻi county	hi	us	t	-156.120001	20.321453	-154.755792	18.86546
OX2qJkaOEK	2022-05-21 03:20:48.983+00	2022-05-21 03:20:49.082+00	\N	\N	(-86.34924000000001,36.186903)	lebanon	tn	us	t	-86.454144	36.256276	-86.244336	36.11753
u25DtRMR1V	2022-05-21 03:20:49.304+00	2022-05-21 03:20:49.405+00	\N	\N	(103.73324005,1.3239627)	jurong east		sg	t	103.7083787	1.3534941	103.7581014	1.2944313
Cnptf2rudc	2022-05-21 03:20:54.657+00	2022-06-01 04:16:09.152+00	\N	\N	(14.229599749999998,-19.0784859)		kunene region	na	t	11.7367163	-16.9635105	16.7224832	-21.1934613
U1mxGrb6HW	2022-05-21 03:20:50.12+00	2022-05-21 03:20:50.221+00	\N	\N	(-80.2291605,38.8992845)	upshur county	wv	us	t	-80.412331	39.1124	-80.04599	38.686169
zriVDtbagp	2022-05-21 03:20:50.665+00	2022-05-21 03:20:50.764+00	\N	\N	(-94.93605124999999,32.99002715)	camp county	tx	us	t	-95.1523419	33.0773981	-94.7197606	32.9026562
nYCUq5OFBz	2022-05-21 03:20:50.991+00	2022-05-21 03:20:51.091+00	\N	\N	(-122.204049,40.121779599999996)	tehama county	ca	us	t	-123.0660707	40.4461616	-121.3420273	39.7973976
JBKLC0i2Oj	2022-05-21 03:20:51.477+00	2022-05-21 03:20:51.577+00	\N	\N	(-88.6487219,30.86636235)	george county	ms	us	t	-88.8849855	30.9984568	-88.4124583	30.7342679
kSPM2OAAJa	2022-05-21 03:20:51.944+00	2022-05-21 03:20:52.045+00	\N	\N	(23.90495035,40.9033792)	δήμος αμφίπολης	macedonia and thrace	gr	t	23.691966	41.0494182	24.1179347	40.7573402
61bscERw8R	2022-05-21 03:20:52.296+00	2022-05-21 03:20:52.395+00	\N	\N	(-85.0008197,41.941786050000005)	coldwater township	mi	us	t	-85.060004	41.9855733	-84.9416354	41.8979988
2BQVfyallT	2022-05-21 03:20:52.732+00	2022-05-21 03:20:52.832+00	\N	\N	(-94.13094534999999,30.080982249999998)	beaumont	tx	us	t	-94.2249569	30.1890213	-94.0369338	29.9729432
F91vLzmEhS	2022-05-21 03:20:53.202+00	2022-05-21 03:20:53.301+00	\N	\N	(-89.7174733,40.7440759)	peoria county	il	us	t	-89.9890166	40.9745075	-89.44593	40.5136443
lFL96Ifsi5	2022-05-21 03:20:53.572+00	2022-05-21 03:20:53.671+00	\N	\N	(-80.74031930000001,28.313749700000002)	rockledge	fl	us	t	-80.7799588	28.3494555	-80.7006798	28.2780439
cUFHDvLdRa	2022-05-21 03:20:54.031+00	2022-05-21 03:20:54.131+00	\N	\N	(-1.1411604,52.7392753)	charnwood	eng	gb	t	-1.3350747	52.8247029	-0.9472461	52.6538477
tfocYB8L9M	2022-05-21 03:20:54.947+00	2022-05-21 03:20:55.046+00	\N	\N	(9.9215263,57.046262600000006)	aalborg	north denmark region	dk	t	9.7615263	57.2062626	10.0815263	56.8862626
Z9ouawGbGw	2022-05-21 03:20:55.251+00	2022-05-21 03:20:55.351+00	\N	\N	(-86.2460375,32.343799000000004)	montgomery	al	us	t	-86.41987	32.437677	-86.072205	32.249921
TeuSUGTGjt	2022-05-21 03:20:55.82+00	2022-05-21 03:20:55.92+00	\N	\N	(-82.52859624999999,35.620287000000005)	buncombe county	nc	us	t	-82.88811	35.8241166	-82.1690825	35.4164574
mIJfSfJUj0	2022-05-21 03:20:56.195+00	2022-05-21 03:20:56.295+00	\N	\N	(-85.26443764999999,43.59757875)	morton township	mi	us	t	-85.3242949	43.6409642	-85.2045804	43.5541933
Ec7vhjuaWb	2022-05-21 03:20:56.737+00	2022-05-21 03:20:56.837+00	\N	\N	(-73.5842365,40.6484605)	freeport	ny	us	t	-73.603841	40.673548	-73.564632	40.623373
vaARoIJGlA	2022-05-21 03:20:57.049+00	2022-05-21 03:20:57.149+00	\N	\N	(25.420299900000003,58.807869499999995)	türi linn		ee	t	25.3920008	58.824777	25.448599	58.790962
vHVWum1lx9	2022-05-21 03:20:49.699+00	2022-06-01 04:15:24.973+00	\N	\N	(-111.89065525,31.96995855)	pima county	az	us	t	-113.333992	32.514423	-110.4473185	31.4254941
aJg3qUVUKP	2022-05-21 03:20:57.423+00	2022-05-21 03:20:57.522+00	\N	\N	(-71.10334470000001,42.118409400000004)	stoughton	ma	us	t	-71.1501777	42.1640573	-71.0565117	42.0727615
jC676jkXNQ	2022-05-21 03:20:57.857+00	2022-05-21 03:20:57.956+00	\N	\N	(-74.95528135,40.04903615)	delanco township	nj	us	t	-74.9858017	40.0688163	-74.924761	40.029256
NLMg5aNgUJ	2022-05-21 03:20:58.334+00	2022-05-21 03:20:58.433+00	\N	\N	(-82.879195,42.598048500000004)	mount clemens	mi	us	t	-82.901619	42.617894	-82.856771	42.578203
stKB9WUS87	2022-05-21 03:20:58.83+00	2022-05-21 03:20:58.93+00	\N	\N	(33.0138516,-13.78256335)		mchinji	mw	t	32.6705332	-13.3444338	33.35717	-14.2206929
25k9tCB4WS	2022-05-21 03:20:59.123+00	2022-05-21 03:20:59.223+00	\N	\N	(-92.46784099999999,42.725164500000005)	waverly	ia	us	t	-92.5148339	42.7537997	-92.4208481	42.6965293
CGK2tJU7us	2022-05-21 03:20:59.549+00	2022-05-21 03:20:59.649+00	\N	\N	(121.0711508,14.407893999999999)	muntinlupa	metro manila	ph	t	121.0079062	14.4679839	121.1343954	14.3478041
uGBEcwdm2d	2022-05-21 03:20:59.903+00	2022-05-21 03:21:00.002+00	\N	\N	(-71.81662845,42.994090400000005)	francestown	nh	us	t	-71.885836	43.0384778	-71.7474209	42.949703
f5faRm6esV	2022-05-21 03:21:00.317+00	2022-05-21 03:21:00.417+00	\N	\N	(-99.3032977,34.66502885)	altus	ok	us	t	-99.3515486	34.7104986	-99.2550468	34.6195591
zp0omf7Q1i	2022-05-21 03:21:00.747+00	2022-05-21 03:21:00.847+00	\N	\N	(-88.94234804999999,42.776061150000004)	milton	wi	us	t	-88.978677	42.7944559	-88.9060191	42.7576664
DHZic3DX9O	2022-05-21 03:21:01.165+00	2022-05-21 03:21:01.265+00	\N	\N	(-118.1015546,34.5854289)	palmdale	ca	us	t	-118.287107	34.6610448	-117.9160022	34.509813
Dg4fUhUPt2	2022-05-21 03:21:01.9+00	2022-05-21 03:21:02.001+00	\N	\N	(16.3796721,48.220287400000004)	vienna		at	t	16.181831	48.3226679	16.5775132	48.1179069
vrVw9xlIdZ	2022-05-21 03:21:02.29+00	2022-05-21 03:21:02.39+00	\N	\N	(23.64173035,38.02145325)	regional unit of west athens	attica	gr	t	23.5486728	38.0667392	23.7347879	37.9761673
FL9QgnLsGF	2022-05-21 03:21:02.692+00	2022-05-21 03:21:02.792+00	\N	\N	(114.19072645,-26.3271203)	shire of shark bay	wa	au	t	112.8656697	-25.3563076	115.5157832	-27.297933
y8qfBwO3O7	2022-05-21 03:21:03.212+00	2022-05-21 03:21:03.311+00	\N	\N	(-102.0315502,31.8691568)	midland county	tx	us	t	-102.2874424	32.0869893	-101.775658	31.6513243
vriFLDmfIH	2022-05-21 03:21:03.569+00	2022-05-21 03:21:03.668+00	\N	\N	(-85.8072713,41.2183835)	winona lake	in	us	t	-85.835381	41.233492	-85.7791616	41.203275
9N3O3VI4Fr	2022-05-21 03:21:04.089+00	2022-05-21 03:21:04.189+00	\N	\N	(-83.681716,34.165619)	pendergrass	ga	us	t	-83.701709	34.191915	-83.661723	34.139323
JI2q3CNlht	2022-05-21 03:21:04.473+00	2022-05-21 03:21:04.573+00	\N	\N	(-103.1548152,31.7549494)	wink	tx	us	t	-103.1674504	31.7655372	-103.14218	31.7443616
jwTWOuTGuH	2022-05-21 03:21:04.983+00	2022-05-21 03:21:05.083+00	\N	\N	(27.30929545,47.197628249999994)	iași		ro	t	26.4911147	47.5894225	28.1274762	46.805834
C35foWbYni	2022-05-21 03:21:05.386+00	2022-05-21 03:21:05.486+00	\N	\N	(-88.57535899999999,35.1907789)	mcnairy county	tn	us	t	-88.786926	35.386341	-88.363792	34.9952168
RZhvDH9DTW	2022-05-21 03:21:05.688+00	2022-05-21 03:21:05.787+00	\N	\N	(-122.04397399999999,47.957102750000004)	everett	wa	us	t	-122.29397	48.0360295	-121.793978	47.878176
Qzd9iuSH3T	2022-05-21 03:21:06.196+00	2022-05-21 03:21:06.296+00	\N	\N	(150.3148645,-28.4628575)	goondiwindi regional	qld	au	t	148.919594	-27.746449	151.710135	-29.179266
w59hkmbMPC	2022-05-21 03:21:06.626+00	2022-05-21 03:21:06.725+00	\N	\N	(-122.99109680000001,38.46109105)	sonoma county	ca	us	t	-123.632497	38.8526549	-122.3496966	38.0695272
RKs2DCllsW	2022-05-21 03:21:07.121+00	2022-05-21 03:21:07.22+00	\N	\N	(-86.8948729,40.3887167)	tippecanoe county	in	us	t	-87.0953948	40.5630784	-86.694351	40.214355
Fx0jZItxyi	2022-05-21 03:21:07.538+00	2022-05-21 03:21:07.63+00	\N	\N	(-93.70669985,44.9347107)	minnetrista	mn	us	t	-93.768003	44.9785986	-93.6453967	44.8908228
sCLptKvBIW	2022-05-21 03:21:08.006+00	2022-05-21 03:21:08.107+00	\N	\N	(-122.21415975,37.5087745)	redwood city	ca	us	t	-122.2908234	37.5703773	-122.1374961	37.4471717
hzzcmLd7RK	2022-05-21 03:21:08.366+00	2022-05-21 03:21:08.466+00	\N	\N	(-96.58594785,28.35057995)	calhoun county	tx	us	t	-96.9303337	28.7299835	-96.241562	27.9711764
zGH1YjLEFk	2022-05-21 03:21:08.744+00	2022-05-21 03:21:08.843+00	\N	\N	(-81.17377350000001,35.9121895)	alexander county	nc	us	t	-81.344131	36.047779	-81.003416	35.7766
KpzLNKHpkf	2022-05-21 03:21:09.127+00	2022-05-21 03:21:09.228+00	\N	\N	(-81.6392472,41.2398343)	richfield	oh	us	t	-81.668558	41.2774806	-81.6099364	41.202188
5rslpvPY4f	2022-05-21 03:21:09.549+00	2022-05-21 03:21:09.648+00	\N	\N	(-71.95566575000001,45.4119775)	sherbrooke	qc	ca	t	-72.1087893	45.5240502	-71.8025422	45.2999048
QoLYreaajC	2022-05-21 03:21:10.133+00	2022-05-21 03:21:10.233+00	\N	\N	(2.1404266,41.3924744)	barcelona	catalonia	es	t	2.0524977	41.4679135	2.2283555	41.3170353
5jg91VMGdW	2022-05-21 03:21:10.546+00	2022-05-21 03:21:10.645+00	\N	\N	(13.5027631,59.3809146)	karlstad	652 24	se	t	13.3427631	59.5409146	13.6627631	59.2209146
Nh2HCrmiFA	2022-05-21 03:21:10.963+00	2022-05-21 03:21:11.063+00	\N	\N	(26.40692,-29.146985)	mangaung metropolitan municipality	fs	za	t	25.71936	-28.76006	27.09448	-29.53391
YtvGosXD3E	2022-05-21 03:21:11.383+00	2022-05-21 03:21:11.483+00	\N	\N	(-86.82980975,34.49555465)	morgan county	al	us	t	-87.110222	34.6862123	-86.5493975	34.304897
vfOPa49xX7	2022-05-21 03:21:11.828+00	2022-05-21 03:21:11.928+00	\N	\N	(21.997235,-34.09555)	mossel bay local municipality	wc	za	t	21.63977	-33.84637	22.3547	-34.34473
WsamTvYcRs	2022-05-21 03:21:12.259+00	2022-05-21 03:21:12.358+00	\N	\N	(-97.631808,38.825306)	salina	ks	us	t	-97.705992	38.895971	-97.557624	38.754641
2YWE8CPhvi	2022-05-21 03:21:12.562+00	2022-05-21 03:21:12.662+00	\N	\N	(-76.58716435,34.86660675)	carteret county	nc	us	t	-77.1677717	35.2014775	-76.006557	34.531736
yHDZ4YC1KI	2022-05-21 03:21:12.854+00	2022-05-21 03:21:12.955+00	\N	\N	(-75.3671059,40.6253144)	bethlehem	pa	us	t	-75.4312193	40.6725749	-75.3029925	40.5780539
0YG8Gax3K9	2022-05-21 03:21:13.302+00	2022-05-21 03:21:13.402+00	\N	\N	(-87.63070300000001,41.4831635)	south chicago heights	il	us	t	-87.655073	41.491588	-87.606333	41.474739
lwqS406EDA	2022-05-21 03:21:13.716+00	2022-05-21 03:21:13.819+00	\N	\N	(-105.248392,20.829079450000002)	bahía de banderas	nay	mx	t	-105.539369	20.9864277	-104.957415	20.6717312
MhQYwbmjC5	2022-05-21 03:21:14.123+00	2022-05-21 03:21:14.223+00	\N	\N	(-71.04296395,43.2132639)	barrington	nh	us	t	-71.1331229	43.288581	-70.952805	43.1379468
IpechobLnw	2022-05-21 03:21:14.704+00	2022-05-21 03:21:14.803+00	\N	\N	(-121.92146665,37.680319850000004)	alameda county	ca	us	t	-122.373843	37.9066896	-121.4690903	37.4539501
t2CZHNFvDt	2022-05-21 03:21:15.183+00	2022-05-21 03:21:15.283+00	\N	\N	(-96.43790899999999,30.222363)	washington county	tx	us	t	-96.7944459	30.4003511	-96.0813721	30.0443749
BTf2foJavA	2022-05-21 03:21:15.627+00	2022-05-21 03:21:15.726+00	\N	\N	(-79.4175587,44.609205900000006)	orillia	on	ca	t	-79.5775587	44.7692059	-79.2575587	44.4492059
ucaPKl4Bca	2022-05-21 03:21:16.039+00	2022-05-21 03:21:16.138+00	\N	\N	(-79.2719985,36.0962685)	mebane	nc	us	t	-79.319847	36.135323	-79.22415	36.057214
glckGs2l2o	2022-05-21 03:21:16.389+00	2022-05-21 03:21:16.489+00	\N	\N	(-81.6072721,41.00861225)	barberton	oh	us	t	-81.650647	41.0413065	-81.5638972	40.975918
65TpJH9bku	2022-05-21 03:21:16.749+00	2022-05-21 03:21:16.849+00	\N	\N	(-89.81767049999999,43.954113750000005)	adams	wi	us	t	-89.8378414	43.9668464	-89.7974996	43.9413811
HxlOtAa3sZ	2022-05-21 03:21:17.079+00	2022-05-21 03:21:17.178+00	\N	\N	(29.87187495,-30.64771)	umuziwabantu local municipality	nl	za	t	29.57128	-30.4673499	30.1724699	-30.8280701
obr4NHemps	2022-05-21 03:21:17.598+00	2022-05-21 03:21:17.698+00	\N	\N	(-82.6949655,38.3709195)	boyd county	ky	us	t	-82.818054	38.505808	-82.571877	38.236031
xGXoDqNilc	2022-05-21 03:21:17.929+00	2022-05-21 03:21:18.03+00	\N	\N	(8.029617,50.1365332)	bad schwalbach	hesse	de	t	7.9569931	50.1780615	8.1022409	50.0950049
jBAnLwmqsP	2022-05-21 03:21:18.252+00	2022-05-21 03:21:18.353+00	\N	\N	(-85.81205105000001,34.53109125)	dekalb county	al	us	t	-86.1102514	34.8623385	-85.5138507	34.199844
OF9hlVllLH	2022-05-21 03:21:18.53+00	2022-05-21 03:21:18.63+00	\N	\N	(-101.89056585,33.5781762)	lubbock	tx	us	t	-102.0321237	33.7084726	-101.749008	33.4478798
OLicDpRtmp	2022-05-21 03:21:18.867+00	2022-05-21 03:21:18.966+00	\N	\N	(2.6253361,6.4990718)	porto-novo	ou	bj	t	2.4653361	6.6590718	2.7853361	6.3390718
odbCUaQ581	2022-05-21 03:21:19.227+00	2022-05-21 03:21:19.326+00	\N	\N	(-71.99662655,45.57128985)	windsor	qc	ca	t	-72.034526	45.5919669	-71.9587271	45.5506128
qXF0B2jQyX	2022-05-21 03:21:19.616+00	2022-05-21 03:21:19.716+00	\N	\N	(4.2370214,51.2601935)	beveren	east flanders	be	t	4.152493	51.3539671	4.3215498	51.1664199
mCfX0jJOY5	2022-05-21 03:21:19.994+00	2022-05-21 03:21:20.094+00	\N	\N	(28.1379625,-26.629495)	midvaal local municipality	gt	za	t	27.869075	-26.33516	28.40685	-26.92383
pyRMHo2BMu	2022-05-21 03:21:20.421+00	2022-05-21 03:21:20.522+00	\N	\N	(-83.71924615,42.214765099999994)	pittsfield township	mi	us	t	-83.779252	42.2593932	-83.6592403	42.170137
NDFjo4PhXt	2022-05-21 03:21:20.719+00	2022-05-21 03:21:20.818+00	\N	\N	(-104.21197445,32.3874113)	carlsbad	nm	us	t	-104.2896384	32.4765339	-104.1343105	32.2982887
CRprWLadLr	2022-05-21 03:21:21.128+00	2022-05-21 03:21:21.228+00	\N	\N	(-76.49032295,45.41320185)	mcnab/braeside	on	ca	t	-76.6423426	45.5164237	-76.3383033	45.30998
mYVUGFLFuJ	2022-05-21 03:21:21.54+00	2022-05-21 03:21:21.639+00	\N	\N	(-74.04652974999999,40.208449)	neptune township	nj	us	t	-74.0945785	40.234395	-73.998481	40.182503
GM06zaowbV	2022-05-21 03:21:21.984+00	2022-05-21 03:21:22.083+00	\N	\N	(-73.9931815,40.945079500000006)	dumont	nj	us	t	-74.010782	40.955263	-73.975581	40.934896
ycEhqoLCjf	2022-05-21 03:21:22.429+00	2022-05-21 03:21:22.528+00	\N	\N	(-104.9480935,40.0605126)	dacono	co	us	t	-104.9817157	40.0879788	-104.9144713	40.0330464
FDksoA4x2m	2022-05-21 03:21:23.027+00	2022-05-21 03:21:23.127+00	\N	\N	(-15.9799757,12.8354242)	marsassoum	sédhiou region	sn	t	-15.9887927	12.8477061	-15.9711587	12.8231423
xZEuskAvKD	2022-05-21 03:21:23.46+00	2022-05-21 03:21:23.56+00	\N	\N	(-80.2716284,43.1512947)	brantford	on	ca	t	-80.3535817	43.2084745	-80.1896751	43.0941149
IDMVyuxSX7	2022-05-21 03:21:23.839+00	2022-05-21 03:21:23.939+00	\N	\N	(-64.76542625,48.35491175)	chandler	qc	ca	t	-64.9575568	48.5034124	-64.5732957	48.2064111
6dbRfmCTv1	2022-05-21 03:21:24.296+00	2022-05-21 03:21:24.397+00	\N	\N	(-84.2557065,39.66498455)	west carrollton	oh	us	t	-84.290691	39.6899711	-84.220722	39.639998
8oFjkPTIFD	2022-05-21 03:21:24.64+00	2022-05-21 03:21:24.739+00	\N	\N	(27.89635095,43.2052225)	varna		bg	t	27.736489	43.310216	28.0562129	43.100229
Oa5PhOB4Oo	2022-05-21 03:21:24.921+00	2022-05-21 03:21:25.02+00	\N	\N	(-92.97059575,45.8354276)	pine city	mn	us	t	-92.9913089	45.8644499	-92.9498826	45.8064053
3hR3Ohc5F2	2022-05-21 03:21:25.246+00	2022-05-21 03:21:25.346+00	\N	\N	(-101.78575765,37.9998233)	hamilton county	ks	us	t	-102.0445107	38.2632939	-101.5270046	37.7363527
DQkqHwwHKS	2022-05-21 03:21:25.637+00	2022-05-21 03:21:25.737+00	\N	\N	(-63.351187350000004,46.229901)	riverdale	pe	ca	t	-63.3829068	46.2516182	-63.3194679	46.2081838
G6uxJjYLZ3	2022-05-21 03:21:26.442+00	2022-05-21 03:21:26.541+00	\N	\N	(12.4702559,49.205356050000006)	roding	bavaria	de	t	12.3707906	49.2768494	12.5697212	49.1338627
7vCCzpXErp	2022-05-21 03:21:26.943+00	2022-05-21 03:21:27.044+00	\N	\N	(-84.2990475,33.2656205)	spalding county	ga	us	t	-84.509104	33.352621	-84.088991	33.17862
F0cZLHeC4X	2022-05-21 03:21:27.403+00	2022-05-21 03:21:27.502+00	\N	\N	(-93.2555275,36.9537744)	christian county	mo	us	t	-93.60936	37.09827	-92.901695	36.8092788
msfrpcljOR	2022-05-21 03:21:27.93+00	2022-05-21 03:21:28.029+00	\N	\N	(-77.82955430000001,38.711326650000004)	fauquier county	va	us	t	-78.1310145	39.0137713	-77.5280941	38.408882
CoM1Rc0IVR	2022-05-21 03:21:28.359+00	2022-05-21 03:21:28.459+00	\N	\N	(-93.766344,44.8066376)	carver county	mn	us	t	-94.0123331	44.9787132	-93.5203549	44.634562
KXZ90HF6mi	2022-05-21 03:21:28.695+00	2022-05-21 03:21:28.795+00	\N	\N	(-111.60786145,35.18124915)	flagstaff	az	us	t	-111.7089429	35.240102	-111.50678	35.1223963
5wQi6Xu3Ir	2022-05-21 03:21:29.156+00	2022-05-21 03:21:29.256+00	\N	\N	(12.22549455,55.76098175)	egedal municipality	capital region of denmark	dk	t	12.1087064	55.8282713	12.3422827	55.6936922
qZCgvgfATc	2022-05-21 03:21:29.511+00	2022-05-21 03:21:29.611+00	\N	\N	(-101.6040259,43.59240275)	eagle nest district	sd	us	t	-101.9806261	43.7965575	-101.2274257	43.388248
yS9GCFqtQY	2022-05-21 03:21:29.88+00	2022-05-21 03:21:29.98+00	\N	\N	(-117.43454700000001,34.5908479)	adelanto	ca	us	t	-117.507447	34.6752108	-117.361647	34.506485
KeTKRJeYde	2022-05-21 03:21:30.245+00	2022-05-21 03:21:30.344+00	\N	\N	(-79.8678965,36.699047)	henry county	va	us	t	-80.095141	36.856139	-79.640652	36.541955
kHzTsv4tOE	2022-05-21 03:21:30.751+00	2022-05-21 03:21:30.85+00	\N	\N	(-80.20774705,40.50599045)	moon township	pa	us	t	-80.2743758	40.5564264	-80.1411183	40.4555545
Ic2ILOrsWI	2022-05-21 03:21:31.088+00	2022-05-21 03:21:31.187+00	\N	\N	(13.293995800000001,55.54300685)	svedala kommun		se	t	13.1062966	55.619994	13.481695	55.4660197
XapXpTQAWQ	2022-05-21 03:21:31.347+00	2022-05-21 03:21:31.446+00	\N	\N	(-80.01733540000001,48.1890277)	kirkland lake	on	ca	t	-80.1465294	48.2763221	-79.8881414	48.1017333
zfmNiaFgG5	2022-05-21 03:21:31.755+00	2022-05-21 03:21:31.854+00	\N	\N	(-117.3310119,48.52299285)	pend oreille county	wa	us	t	-117.6299168	49.0004709	-117.032107	48.0455148
yFPdIA0Om1	2022-05-21 03:21:32.089+00	2022-05-21 03:21:32.189+00	\N	\N	(-111.69377625,40.29534805)	orem	ut	us	t	-111.7529994	40.3338216	-111.6345531	40.2568745
IOAxDj8xa7	2022-05-21 03:21:32.519+00	2022-05-21 03:21:32.618+00	\N	\N	(7.88227455,48.334329600000004)	lahr/schwarzwald	bw	de	t	7.7858394	48.3821335	7.9787097	48.2865257
26IDFdrV4Y	2022-05-21 03:21:32.993+00	2022-05-21 03:21:33.093+00	\N	\N	(-86.81295449999999,33.219485500000005)	alabaster	al	us	t	-86.873217	33.27176	-86.752692	33.167211
01nEg5Ix9j	2022-05-21 03:21:33.551+00	2022-05-21 03:21:33.651+00	\N	\N	(-70.47369135,41.728455249999996)	sandwich	ma	us	t	-70.5689043	41.8196316	-70.3784784	41.6372789
Mg0AlyOC2H	2022-05-21 03:21:34.063+00	2022-05-21 03:21:34.163+00	\N	\N	(-84.676485,34.053008000000005)	acworth	ga	us	t	-84.719708	34.078633	-84.633262	34.027383
FbiFtxRwwW	2022-05-21 03:21:34.519+00	2022-05-21 03:21:34.619+00	\N	\N	(24.8712685,49.82506315)	zolochiv urban hromada	lviv oblast	ua	t	24.5897162	49.9463984	25.1528208	49.7037279
tFsVXALvYE	2022-05-21 03:21:34.919+00	2022-05-21 03:21:35.024+00	\N	\N	(23.80686605,44.32336085)	craiova		ro	t	23.7079153	44.3786461	23.9058168	44.2680756
lnoNouwIPs	2022-05-21 03:21:35.336+00	2022-05-21 03:21:35.435+00	\N	\N	(-52.8253124,47.4806124)	st. john's	nl	ca	t	-53.0378593	47.6338515	-52.6127655	47.3273733
aYldaD3Lqn	2022-05-21 03:21:35.694+00	2022-05-21 03:21:35.794+00	\N	\N	(-97.817028,30.50185065)	cedar park	tx	us	t	-97.888639	30.5570365	-97.745417	30.4466648
ouOxULT9kb	2022-05-21 03:21:36.086+00	2022-05-21 03:21:36.185+00	\N	\N	(-117.2190559,36.6257581)	inyo county	ca	us	t	-118.7900515	37.4649344	-115.6480603	35.7865818
jM1QAJoLq4	2022-05-21 03:21:36.367+00	2022-05-21 03:21:36.466+00	\N	\N	(-94.3644765,39.361909999999995)	kearney	mo	us	t	-94.405561	39.399043	-94.323392	39.324777
1GeBPeO2AT	2022-05-21 03:21:36.78+00	2022-05-21 03:21:36.88+00	\N	\N	(12.0845754,55.01669085)	vordingborg municipality	region zealand	dk	t	11.6165172	55.1548461	12.5526336	54.8785356
NEVXyGGKOj	2022-05-21 03:21:37.088+00	2022-05-21 03:21:37.187+00	\N	\N	(-87.84742245000001,42.4623105)	zion	il	us	t	-87.898143	42.493944	-87.7967019	42.430677
xQnHOnoKDk	2022-05-21 03:21:37.389+00	2022-05-21 03:21:37.489+00	\N	\N	(-74.4181648,41.7600527)	town of wawarsing	ny	us	t	-74.576121	41.8754572	-74.2602086	41.6446482
ODfDuhfemb	2022-05-21 03:21:37.794+00	2022-05-21 03:21:37.893+00	\N	\N	(21.72701615,46.29118335)	arad		ro	t	20.7053121	46.6804536	22.7487202	45.9019131
f6QofI1Yx7	2022-05-21 03:21:38.173+00	2022-05-21 03:21:38.273+00	\N	\N	(-80.76121985,41.3174195)	trumbull county	oh	us	t	-81.003367	41.5014882	-80.5190727	41.1333508
wPwbNnRcr6	2022-05-21 03:21:38.503+00	2022-05-21 03:21:38.602+00	\N	\N	(-105.20191,39.74385865)	golden	co	us	t	-105.241961	39.787111	-105.161859	39.7006063
7v7ffEFQ7V	2022-05-21 03:21:38.791+00	2022-05-21 03:21:38.891+00	\N	\N	(-94.27915200000001,39.004969849999995)	blue springs	mo	us	t	-94.337106	39.066243	-94.221198	38.9436967
1PpluhCaNZ	2022-05-21 03:21:39.104+00	2022-05-21 03:21:39.203+00	\N	\N	(-2.29002605,57.154551299999994)	westhill	sct	gb	t	-2.3144987	57.1651957	-2.2655534	57.1439069
9XwfxvqsQy	2022-05-21 03:21:39.557+00	2022-05-21 03:21:39.656+00	\N	\N	(29.15556095,40.94398635)	maltepe	marmara region	tr	t	29.0948141	40.9813017	29.2163078	40.906671
zJlHFFhCfh	2022-05-21 03:21:40.155+00	2022-05-21 03:21:40.255+00	\N	\N	(-66.16947289999999,18.181545300000003)	cidra	pr	us	t	-66.2444178	18.2304704	-66.094528	18.1326202
bDV8MAiyw7	2022-05-21 03:21:40.544+00	2022-05-21 03:21:40.644+00	\N	\N	(-92.6491686,36.2805305)	marion county	ar	us	t	-92.891396	36.498592	-92.4069412	36.062469
YApl5mXhF1	2022-05-21 03:21:41.011+00	2022-05-21 03:21:41.111+00	\N	\N	(-107.93912334999999,38.943049099999996)	delta county	co	us	t	-108.3789717	39.218127	-107.499275	38.6679712
eBrab2sUSs	2022-05-21 03:21:41.313+00	2022-05-21 03:21:41.413+00	\N	\N	(-86.388434,34.115837)	snead	al	us	t	-86.414623	34.136817	-86.362245	34.094857
FRwuWZ1ud9	2022-05-21 03:21:41.778+00	2022-05-21 03:21:41.877+00	\N	\N	(-97.366915,46.7598925)	walburg township	nd	us	t	-97.430146	46.803508	-97.303684	46.716277
OtGeTslVYj	2022-05-21 03:21:42.128+00	2022-05-21 03:21:42.228+00	\N	\N	(-83.35675825,41.957054400000004)	frenchtown township	mi	us	t	-83.466002	42.0075326	-83.2475145	41.9065762
qbWdDVoxX1	2022-05-21 03:21:42.597+00	2022-05-21 03:21:42.698+00	\N	\N	(11.07064435,58.3962498)	sotenäs kommun		se	t	10.675444	58.5002476	11.4658447	58.292252
Na1uyPv1eK	2022-05-21 03:21:42.919+00	2022-05-21 03:21:43.019+00	\N	\N	(-74.2589381,40.74895635)	south orange	nj	us	t	-74.2831775	40.7622954	-74.2346987	40.7356173
kdK9XM33BX	2022-05-21 03:21:43.387+00	2022-05-21 03:21:43.487+00	\N	\N	(-111.74299024999999,33.60410825)	fountain hills	az	us	t	-111.7873824	33.6403431	-111.6985981	33.5678734
MKkTsAix5F	2022-05-21 03:21:43.716+00	2022-05-21 03:21:43.817+00	\N	\N	(-83.7827144,39.90420875)	clark county	oh	us	t	-84.053736	40.04019	-83.5116928	39.7682275
R0C8QRqRBN	2022-05-21 03:21:44.104+00	2022-05-21 03:21:44.204+00	\N	\N	(-87.413893,36.6723445)	oak grove	ky	us	t	-87.458122	36.703845	-87.369664	36.640844
AKLlSjamNS	2022-05-21 03:21:44.517+00	2022-05-21 03:21:44.617+00	\N	\N	(-97.77131795,30.325661099999998)	travis county	tx	us	t	-98.173053	30.6280321	-97.3695829	30.0232901
3eamHThYoa	2022-05-21 03:21:44.845+00	2022-05-21 03:21:44.945+00	\N	\N	(-93.512077,39.789814)	livingston county	mo	us	t	-93.764694	39.967762	-93.25946	39.611866
QMy59Z3ODi	2022-05-21 03:21:45.226+00	2022-05-21 03:21:45.325+00	\N	\N	(-79.03927759999999,35.9212162)	chapel hill	nc	us	t	-79.0831657	35.9730252	-78.9953895	35.8694072
1hED2c2TCs	2022-05-21 03:21:45.592+00	2022-05-21 03:21:45.693+00	\N	\N	(-81.5186365,41.162161749999996)	cuyahoga falls	oh	us	t	-81.587357	41.2072608	-81.449916	41.1170627
BD2tz5KQEQ	2022-05-21 03:21:45.929+00	2022-05-21 03:21:46.031+00	\N	\N	(-121.93624919999999,36.636414200000004)	pacific grove	ca	us	t	-122.0028166	36.6752021	-121.8696818	36.5976263
ERlTgGOk1x	2022-05-21 03:21:46.458+00	2022-05-21 03:21:46.558+00	\N	\N	(-75.38171464999999,40.0948725)	king of prussia	pa	us	t	-75.419933	40.117728	-75.3434963	40.072017
xVGJraYMO4	2022-05-21 03:21:46.849+00	2022-05-21 03:21:46.949+00	\N	\N	(-95.74482915,43.400491099999996)	sibley	ia	us	t	-95.7617024	43.411359	-95.7279559	43.3896232
SwFe4lN3ab	2022-05-21 03:21:47.248+00	2022-05-21 03:21:47.348+00	\N	\N	(-79.21947275,-4.29594145)	vilcabamba	l	ec	t	-79.3338325	-4.2371565	-79.105113	-4.3547264
959fjpYG8W	2022-05-21 03:21:47.556+00	2022-05-21 03:21:47.656+00	\N	\N	(-83.5099177,34.6294977)	habersham county	ga	us	t	-83.681679	34.8278084	-83.3381564	34.431187
FYiSY19Ovl	2022-05-21 03:21:48.017+00	2022-05-21 03:21:48.117+00	\N	\N	(6.81434975,51.238430949999994)	dusseldorf	north rhine-westphalia	de	t	6.6888147	51.3524872	6.9398848	51.1243747
JXRSuSFppt	2022-05-21 03:21:48.365+00	2022-05-21 03:21:48.465+00	\N	\N	(10.46069155,53.28342295)	adendorf	lower saxony	de	t	10.4231811	53.3128229	10.498202	53.254023
CWqwu4F4nW	2022-05-21 03:21:48.706+00	2022-05-21 03:21:48.807+00	\N	\N	(-76.8898283,38.9932668)	greenbelt	md	us	t	-76.9195925	39.0146608	-76.8600641	38.9718728
jkU5qk9s8f	2022-05-21 03:21:49.076+00	2022-05-21 03:21:49.176+00	\N	\N	(-6.1872339,53.25679685)	dún laoghaire-rathdown		ie	t	-6.2993678	53.3148682	-6.0751	53.1987255
ziBeYKAaQS	2022-05-21 03:21:49.481+00	2022-05-21 03:21:49.58+00	\N	\N	(-94.9128217,32.7104577)	upshur county	tx	us	t	-95.1533186	32.9044903	-94.6723248	32.5164251
svnTk2DJOb	2022-05-21 03:21:50.068+00	2022-05-21 03:21:50.167+00	\N	\N	(-83.6028955,42.3043051)	superior township	mi	us	t	-83.662063	42.349217	-83.543728	42.2593932
tIKqDqCAX8	2022-05-21 03:21:50.438+00	2022-05-21 03:21:50.538+00	\N	\N	(152.984682,-30.6412722)	nambucca heads	nsw	au	t	152.9491239	-30.5991066	153.0202401	-30.6834378
4bny9DCpE2	2022-05-21 03:21:50.906+00	2022-05-21 03:21:51.006+00	\N	\N	(-72.15610955,41.465477)	montville	ct	us	t	-72.2422974	41.5188226	-72.0699217	41.4121314
JCtSNSHPGt	2022-05-21 03:21:51.772+00	2022-05-21 03:21:51.871+00	\N	\N	(-71.40758890000001,42.0872195)	franklin	ma	us	t	-71.4559046	42.1395425	-71.3592732	42.0348965
hMKpWUUY9T	2022-05-21 03:21:52.257+00	2022-05-21 03:21:52.356+00	\N	\N	(-92.57000085,44.59880955)	red wing	mn	us	t	-92.6727732	44.6696627	-92.4672285	44.5279564
zTMQSyjCU9	2022-05-21 03:21:52.762+00	2022-05-21 03:21:52.862+00	\N	\N	(19.288149,48.225985)	district of veľký krtíš	region of banská bystrica	sk	t	19.012156	48.398324	19.564142	48.053646
9vlbXavEaM	2022-05-21 03:21:53.141+00	2022-05-21 03:21:53.241+00	\N	\N	(-119.42604945,49.21022415)	area c (inkaneep/willowbrook)	bc	ca	t	-119.6768184	49.3391514	-119.1752805	49.0812969
9PjDy5wmIV	2022-05-21 03:21:53.593+00	2022-05-21 03:21:53.692+00	\N	\N	(-3.8169411,40.42918555)	pozuelo de alarcón	community of madrid	es	t	-3.8630994	40.4663143	-3.7707828	40.3920568
fkDXhSR7TO	2022-05-21 03:21:53.994+00	2022-05-21 03:21:54.094+00	\N	\N	(-43.44766655,-22.914396449999998)	rio de janeiro	rj	br	t	-43.796252	-22.7460878	-43.0990811	-23.0827051
1qrOl5Obm0	2022-05-21 03:21:54.458+00	2022-05-21 03:21:54.557+00	\N	\N	(-72.5180125,42.5594492)	montague	ma	us	t	-72.5832898	42.6124162	-72.4527352	42.5064822
uxTVHRiSuK	2022-05-21 03:21:54.849+00	2022-05-21 03:21:54.949+00	\N	\N	(-2.15900245,53.0194458)	stoke-on-trent	eng	gb	t	-2.2387603	53.0927015	-2.0792446	52.9461901
W6ZrVwt6Th	2022-05-21 03:21:55.279+00	2022-05-21 03:21:55.378+00	\N	\N	(-89.26293315000001,33.599694)	webster county	ms	us	t	-89.5073789	33.7395374	-89.0184874	33.4598506
V5ChaLAYCj	2022-05-21 03:21:55.624+00	2022-05-21 03:21:55.724+00	\N	\N	(-75.906734,41.2626925)	edwardsville	pa	us	t	-75.920903	41.277074	-75.892565	41.248311
vHsOvMiRFW	2022-05-21 03:21:56.029+00	2022-05-21 03:21:56.128+00	\N	\N	(-84.264602,39.639522299999996)	miami township	oh	us	t	-84.328297	39.694127	-84.200907	39.5849176
UhkQUfF2Jd	2022-05-21 03:21:56.43+00	2022-05-21 03:21:56.529+00	\N	\N	(-79.6657741,44.3591697)	barrie	on	ca	t	-79.7456508	44.4245913	-79.5858974	44.2937481
2hL6cOix1A	2022-05-21 03:21:56.763+00	2022-05-21 03:21:56.864+00	\N	\N	(-75.24009595000001,39.8392447)	paulsboro	nj	us	t	-75.2573279	39.8586534	-75.222864	39.819836
DkwGG2Rs04	2022-05-21 03:21:57.053+00	2022-05-21 03:21:57.152+00	\N	\N	(-73.93825845,42.8036225)	schenectady	ny	us	t	-73.9834749	42.843668	-73.893042	42.763577
YZJpegS8ue	2022-05-21 03:21:57.471+00	2022-05-21 03:21:57.57+00	\N	\N	(-73.8292477,40.912568)	mount vernon	ny	us	t	-73.8534724	40.9353186	-73.805023	40.8898174
Z75ZNSq3GR	2022-05-21 03:21:57.882+00	2022-05-21 03:21:57.983+00	\N	\N	(-73.638139,40.6685545)	rockville centre	ny	us	t	-73.658684	40.690023	-73.617594	40.647086
SvouTxIxJo	2022-05-21 03:21:58.405+00	2022-05-21 03:21:58.505+00	\N	\N	(7.4833321999999995,50.4604528)	neuwied	rhineland-palatinate	de	t	7.3834047	50.5091018	7.5832597	50.4118038
pvtIpRUkhP	2022-05-21 03:21:58.814+00	2022-05-21 03:21:58.914+00	\N	\N	(-86.4486615,42.07990115)	fair plain	mi	us	t	-86.476555	42.1016873	-86.420768	42.058115
OhNGlTt4dR	2022-05-21 03:21:59.188+00	2022-05-21 03:21:59.288+00	\N	\N	(-113.6725845,42.859211)	minidoka county	id	us	t	-113.932063	43.199859	-113.413106	42.518563
DxKYXiT0HC	2022-05-21 03:21:59.533+00	2022-05-21 03:21:59.634+00	\N	\N	(-82.52277475,40.7661236)	mansfield	oh	us	t	-82.5900726	40.8436307	-82.4554769	40.6886165
eiEPGzmdPr	2022-05-21 03:21:59.967+00	2022-05-21 03:22:00.067+00	\N	\N	(-79.819525,36.09558615)	greensboro	nc	us	t	-80.017884	36.2153577	-79.621166	35.9758146
Nz5CW402SU	2022-05-21 03:22:00.56+00	2022-05-21 03:22:00.661+00	\N	\N	(1.31481635,52.51692655)	south norfolk	eng	gb	t	0.9470055	52.6785177	1.6826272	52.3553354
mmPsbkRAMw	2022-05-21 03:22:00.894+00	2022-05-21 03:22:00.994+00	\N	\N	(-108.50725840000001,37.3183584)	montezuma county	co	us	t	-109.0459268	37.637749	-107.96859	36.9989678
cmREtfBD0d	2022-05-21 03:22:01.239+00	2022-05-21 03:22:01.338+00	\N	\N	(24.843695,-26.814835000000002)	naledi local municipality	north west	za	t	24.26585	-26.20525	25.42154	-27.42442
ribbaP8XCq	2022-05-21 03:22:01.588+00	2022-05-21 03:22:01.693+00	\N	\N	(-70.36361210000001,41.6708976)	barnstable	ma	us	t	-70.4675983	41.7932794	-70.2596259	41.5485158
YZG51oOYHG	2022-05-21 03:22:02.074+00	2022-05-21 03:22:02.175+00	\N	\N	(8.76843715,51.727536549999996)	paderborn	north rhine-westphalia	de	t	8.6362871	51.8008385	8.9005872	51.6542346
8aNM7mewmi	2022-05-21 03:22:02.478+00	2022-05-21 03:22:02.577+00	\N	\N	(-79.22787045000001,43.0836408)	thorold	on	ca	t	-79.2871604	43.1405954	-79.1685805	43.0266862
9aMDWP7G74	2022-05-21 03:22:02.79+00	2022-05-21 03:22:02.894+00	\N	\N	(-85.23681350000001,38.1997915)	shelbyville	ky	us	t	-85.28269	38.237687	-85.190937	38.161896
r8fIxYQwSP	2022-05-21 03:22:03.254+00	2022-05-21 03:22:03.353+00	\N	\N	(-81.512978,41.084359250000006)	akron	oh	us	t	-81.621014	41.171061	-81.404942	40.9976575
QZPieTitkE	2022-05-21 03:22:03.809+00	2022-05-21 03:22:03.909+00	\N	\N	(-90.48624964999999,14.62509855)	guatemala city	guatemala department	gt	t	-90.5870896	14.7137893	-90.3854097	14.5364078
GFcJzVMSsF	2022-05-21 03:22:04.203+00	2022-05-21 03:22:04.302+00	\N	\N	(-109.250903,45.63372699999999)	columbus	mt	us	t	-109.271248	45.645951	-109.230558	45.621503
84yfVWsXr2	2022-05-21 03:22:04.617+00	2022-05-21 03:22:04.717+00	\N	\N	(-94.0160864,41.3482164)	winterset	ia	us	t	-94.0423091	41.3807363	-93.9898637	41.3156965
fnH5IBxRWG	2022-05-21 03:22:05.186+00	2022-05-21 03:22:05.285+00	\N	\N	(35.9239625,31.9515694)	amman	amman	jo	t	35.7639625	32.1115694	36.0839625	31.7915694
8Dy4Ncns5O	2022-05-21 03:22:05.626+00	2022-05-21 03:22:05.726+00	\N	\N	(-104.85500075,39.60223740000001)	centennial	co	us	t	-104.988394	39.6384808	-104.7216075	39.565994
ZohDrKBnfJ	2022-05-21 03:22:06.12+00	2022-05-21 03:22:06.22+00	\N	\N	(-85.69202150000001,30.234228450000003)	bay county	fl	us	t	-85.999893	30.5674239	-85.38415	29.901033
Gzq3ZARYy1	2022-05-21 03:22:06.564+00	2022-05-21 03:22:06.664+00	\N	\N	(-120.43150265,34.932364449999994)	santa maria	ca	us	t	-120.5084085	34.9892014	-120.3545968	34.8755275
yJxuB8sMX3	2022-05-21 03:22:06.948+00	2022-05-21 03:22:07.049+00	\N	\N	(13.242043500000001,-8.84002685)	luanda	luanda province	ao	t	13.1732251	-8.759227	13.3108619	-8.9208267
rIkGp2rqLg	2022-05-21 03:22:07.415+00	2022-05-21 03:22:07.515+00	\N	\N	(27.89,-26.2227778)	soweto	gt	za	t	27.73	-26.0627778	28.05	-26.3827778
aNubfw3MQE	2022-05-21 03:22:07.73+00	2022-05-21 03:22:07.83+00	\N	\N	(-72.78799355,41.68041585)	new britain	ct	us	t	-72.8256258	41.7158149	-72.7503613	41.6450168
KgrUMwuCvX	2022-05-21 03:22:08.141+00	2022-05-21 03:22:08.244+00	\N	\N	(-93.03101435,44.69723465)	dakota county	mn	us	t	-93.329828	44.9232887	-92.7322007	44.4711806
aSSFDC2nZL	2022-05-21 03:22:08.538+00	2022-05-21 03:22:08.637+00	\N	\N	(-98.9775414,31.7337719)	brownwood	tx	us	t	-99.0130904	31.8084484	-98.9419924	31.6590954
hdXpTluhYB	2022-05-21 03:22:08.81+00	2022-05-21 03:22:08.91+00	\N	\N	(-85.97630565,40.0442699)	noblesville	in	us	t	-86.0903705	40.1018074	-85.8622408	39.9867324
nd38F9UAeL	2022-05-21 03:22:09.176+00	2022-05-21 03:22:09.275+00	\N	\N	(-70.4195208,43.3694361)	kennebunkport	me	us	t	-70.4928574	43.4524623	-70.3461842	43.2864099
9Lq7pF5bMi	2022-05-21 03:22:09.542+00	2022-05-21 03:22:09.643+00	\N	\N	(-123.7180922,53.020033600000005)	area i (west fraser/nazko)	bc	ca	t	-125	53.5423434	-122.4361844	52.4977238
OUxerF1sGk	2022-05-21 03:22:09.893+00	2022-05-21 03:22:09.992+00	\N	\N	(-81.2602107,29.53295045)	palm coast	fl	us	t	-81.3716417	29.651799	-81.1487797	29.4141019
NArBvKUHS5	2022-05-21 03:22:10.292+00	2022-05-21 03:22:10.392+00	\N	\N	(-87.6901162,37.17336)	dawson springs	ky	us	t	-87.7097146	37.19861	-87.6705178	37.14811
eCibVsurgd	2022-05-21 03:24:50.128+00	2022-05-21 03:24:50.227+00	\N	\N	(-79.2335365,39.070578499999996)	grant county	wv	us	t	-79.487175	39.3278171	-78.979898	38.8133399
Dm1K3YlAvH	2022-05-21 03:24:50.611+00	2022-05-21 03:24:50.711+00	\N	\N	(9.81397355,53.79482025)	heede	sh	de	t	9.766381	53.830289	9.8615661	53.7593515
neX8xiUEnb	2022-05-21 03:24:51.09+00	2022-05-21 03:24:51.19+00	\N	\N	(-84.35119320000001,33.5006574)	clayton county	ga	us	t	-84.4585284	33.6488498	-84.243858	33.352465
acwTsnDnsS	2022-05-21 03:24:51.592+00	2022-05-21 03:24:51.692+00	\N	\N	(-75.51109059999999,39.633881)	pennsville township	nj	us	t	-75.5598656	39.6982349	-75.4623156	39.5695271
hlHvmuq75F	2022-05-21 03:24:52.06+00	2022-05-21 03:24:52.16+00	\N	\N	(3.30161675,6.447433800000001)	amuwo odofin	la	ng	t	3.1991897	6.5047898	3.4040438	6.3900778
pm9AD7jhsb	2022-05-21 03:24:52.486+00	2022-05-21 03:24:52.586+00	\N	\N	(-74.02852494999999,40.1781045)	belmar	nj	us	t	-74.0505689	40.189295	-74.006481	40.166914
vjSl1mRHpn	2022-05-21 03:24:53.078+00	2022-05-21 03:24:53.178+00	\N	\N	(112.71912265,-7.26783565)	surabaya	east java	id	t	112.5915698	-7.1842308	112.8466755	-7.3514405
U0a0YX7uyK	2022-05-21 03:24:53.363+00	2022-05-21 03:24:53.463+00	\N	\N	(-106.34703300000001,42.920655)	bar nunn	wy	us	t	-106.3592	42.936458	-106.334866	42.904852
0Bz3uH71Fv	2022-05-21 03:24:53.806+00	2022-05-21 03:24:53.906+00	\N	\N	(-123.1323093,43.322190000000006)	douglas county	or	us	t	-124.290327	43.945131	-121.9742916	42.699249
symzpEdICm	2022-05-21 03:24:54.224+00	2022-05-21 03:24:54.324+00	\N	\N	(20.259594200000002,63.83379555)	umeå		se	t	20.1338355	63.8820322	20.3853529	63.7855589
8J6q14GQqw	2022-05-21 03:24:54.713+00	2022-05-21 03:24:54.813+00	\N	\N	(-1.5453865,53.8224195)	leeds	eng	gb	t	-1.8004214	53.9458715	-1.2903516	53.6989675
UvJEigcHyB	2022-05-21 03:24:55.194+00	2022-05-21 03:24:55.294+00	\N	\N	(-80.697052,34.2189995)	lugoff	sc	us	t	-80.751207	34.248907	-80.642897	34.189092
PjKykX6IrL	2022-05-21 03:24:55.649+00	2022-05-21 03:24:55.749+00	\N	\N	(-88.9986796,42.19535885)	cherry valley township	il	us	t	-89.057652	42.2391891	-88.9397072	42.1515286
KltAMbWhj1	2022-05-21 03:24:56.137+00	2022-05-21 03:24:56.236+00	\N	\N	(-89.30369245,43.23828485)	windsor	wi	us	t	-89.3631938	43.2820557	-89.2441911	43.194514
UX8ZXEQgPO	2022-05-21 03:24:56.524+00	2022-05-21 03:24:56.624+00	\N	\N	(-113.6748425,37.1754115)	ivins	ut	us	t	-113.7160826	37.2080132	-113.6336024	37.1428098
k6GOHWoyHb	2022-05-21 03:24:57.019+00	2022-05-21 03:24:57.119+00	\N	\N	(-118.9052747,35.2940203)	kern county	ca	us	t	-120.1941544	35.7983076	-117.616395	34.789733
5cH2DpfOs7	2022-05-21 03:24:57.39+00	2022-05-21 03:24:57.489+00	\N	\N	(-83.28744499999999,43.103048650000005)	mayfield township	mi	us	t	-83.348205	43.1486748	-83.226685	43.0574225
VoesHF7ZXq	2022-05-21 03:24:57.777+00	2022-05-21 03:24:57.877+00	\N	\N	(-73.64594450000001,42.2473685)	philmont	ny	us	t	-73.658038	42.257363	-73.633851	42.237374
wGFMso4PSL	2022-05-21 03:24:58.21+00	2022-05-21 03:24:58.309+00	\N	\N	(3.0039100999999997,50.8644831)	zonnebeke	west flanders	be	t	2.9382492	50.9288581	3.069571	50.8001081
sSfjlTenoE	2022-05-21 03:24:58.735+00	2022-05-21 03:24:58.836+00	\N	\N	(13.560146249999999,59.4700579)	karlstads kommun		se	t	13.0890512	59.7738858	14.0312413	59.16623
cAWGCjX2dB	2022-05-21 03:24:59.142+00	2022-05-21 03:24:59.242+00	\N	\N	(-84.522389,42.636601999999996)	holt	mi	us	t	-84.543125	42.654824	-84.501653	42.61838
RKKJnjSVd8	2022-05-21 03:24:59.488+00	2022-05-21 03:24:59.588+00	\N	\N	(-87.0681689,35.62960245)	maury county	tn	us	t	-87.3543049	35.8504975	-86.7820329	35.4087074
GrQ19EdHmR	2022-05-21 03:24:59.919+00	2022-05-21 03:25:00.019+00	\N	\N	(21.19462965,-27.7411022)	ǁkhara hais local municipality	nc	za	t	20.3895397	-26.7707244	21.9997196	-28.71148
TzdKLvTWjj	2022-05-21 03:25:00.397+00	2022-05-21 03:25:00.497+00	\N	\N	(26.02935645,44.59946565)	corbeanca		ro	t	25.9872081	44.6328951	26.0715048	44.5660362
G4jsPVI3vk	2022-05-21 03:25:00.713+00	2022-05-21 03:25:00.813+00	\N	\N	(-85.12265,34.8778025)	catoosa county	ga	us	t	-85.265396	34.98797	-84.979904	34.767635
qUEafl08Vj	2022-05-21 03:25:01.07+00	2022-05-21 03:25:01.168+00	\N	\N	(-16.930482050000002,14.78609225)	arrondissement de thiès sud	thiès region	sn	t	-16.9695847	14.8043414	-16.8913794	14.7678431
jnPLVL2Jlz	2022-05-21 03:25:01.419+00	2022-05-21 03:25:01.519+00	\N	\N	(-123.28362665,44.563587749999996)	corvallis	or	us	t	-123.3362174	44.607243	-123.2310359	44.5199325
U4rhMGzewS	2022-05-21 03:25:01.819+00	2022-05-21 03:25:01.919+00	\N	\N	(-61.64936095,15.9927369)	trois-rivières	gp	fr	t	-61.6844176	16.0331949	-61.6143043	15.9522789
bIYEkFZTmo	2022-05-21 03:25:02.16+00	2022-05-21 03:25:02.263+00	\N	\N	(-96.30393845,32.5995667)	kaufman county	tx	us	t	-96.532326	32.8417346	-96.0755509	32.3573988
fMSODKgSt7	2022-05-21 03:25:02.494+00	2022-05-21 03:25:02.594+00	\N	\N	(-96.7623105,34.07920045)	madill	ok	us	t	-96.798373	34.132786	-96.726248	34.0256149
J6giQ20Sw9	2022-05-21 03:25:02.828+00	2022-05-21 03:25:02.928+00	\N	\N	(-73.42129935,46.01068195)	joliette	qc	ca	t	-73.4716114	46.0440718	-73.3709873	45.9772921
Rq3qpnMpUd	2022-05-21 03:25:03.227+00	2022-05-21 03:25:03.326+00	\N	\N	(-78.85357295,38.529139)	rockingham county	va	us	t	-79.221406	38.850102	-78.4857399	38.208176
JDXT0ZunRh	2022-05-21 03:25:03.586+00	2022-05-21 03:25:03.685+00	\N	\N	(-80.35056975,27.42730685)	fort pierce	fl	us	t	-80.4237628	27.4813092	-80.2773767	27.3733045
68UE3dVgUw	2022-05-21 03:25:03.993+00	2022-05-21 03:25:04.094+00	\N	\N	(15.8311721,-4.4800737)	kinshasa		cd	t	15.1282208	-3.9276112	16.5341234	-5.0325362
uL1otpBvA6	2022-05-21 03:25:04.544+00	2022-05-21 03:25:04.644+00	\N	\N	(-95.422072,29.1456828)	brazoria county	tx	us	t	-95.8739195	29.599104	-94.9702245	28.6922616
Ti47E9ODHy	2022-05-21 03:25:05.041+00	2022-05-21 03:25:05.141+00	\N	\N	(12.3895463,51.34314245)	leipzig	saxony	de	t	12.2366519	51.4481145	12.5424407	51.2381704
TbEahWrKaW	2022-05-21 03:25:05.404+00	2022-05-21 03:25:05.504+00	\N	\N	(-105.9672875,32.88315)	alamogordo	nm	us	t	-106.016858	32.947558	-105.917717	32.818742
pFmv2u08q3	2022-05-21 03:25:05.713+00	2022-05-21 03:25:05.813+00	\N	\N	(-88.406466,47.193137199999995)	lake linden	mi	us	t	-88.417783	47.203992	-88.395149	47.1822824
xtc9FEvu0f	2022-05-21 03:25:06.045+00	2022-05-21 03:25:06.15+00	\N	\N	(-84.8619345,35.1726599)	bradley county	tn	us	t	-85.026825	35.357647	-84.697044	34.9876728
x5av7FVYkp	2022-05-21 03:25:06.521+00	2022-05-21 03:25:06.622+00	\N	\N	(-3.73795055,37.178075500000006)	santa fe	andalusia	es	t	-3.7780557	37.2215478	-3.6978454	37.1346032
rp9hJ91fpI	2022-05-21 03:25:06.934+00	2022-05-21 03:25:07.035+00	\N	\N	(-72.7693927,42.140636099999995)	westfield	ma	us	t	-72.8538949	42.2004746	-72.6848905	42.0807976
Lt3gAVNuPS	2022-05-21 03:25:07.389+00	2022-05-21 03:25:07.489+00	\N	\N	(-74.6850101,40.4980886)	hillsborough township	nj	us	t	-74.7978842	40.5647929	-74.572136	40.4313843
orH4SQSk3b	2022-05-21 03:25:07.666+00	2022-05-21 03:25:07.765+00	\N	\N	(-117.62948225,34.3583666)	wrightwood	ca	us	t	-117.6533435	34.3738302	-117.605621	34.342903
SoYgrBkQHE	2022-05-21 03:25:08.094+00	2022-05-21 03:25:08.194+00	\N	\N	(6.61380535,53.111026949999996)	de punt	dr	nl	t	6.5904888	53.12982	6.6371219	53.0922339
FBpMG2cLu6	2022-05-21 03:25:08.528+00	2022-05-21 03:25:08.628+00	\N	\N	(175.1683424,-41.21223175)	featherston community	wgn	nz	t	174.9586536	-41.0279459	175.3780312	-41.3965176
urS1FhphyA	2022-05-21 03:25:08.884+00	2022-05-21 03:25:08.984+00	\N	\N	(-1.0967304,50.804591349999995)	portsmouth	eng	gb	t	-1.1749699	50.859311	-1.0184909	50.7498717
qQIwGuWhkt	2022-05-21 03:25:09.326+00	2022-05-21 03:25:09.425+00	\N	\N	(-75.32348705,38.22315625)	worcester county	md	us	t	-75.6617692	38.4520375	-74.9852049	37.994275
JHAlXRn6Z0	2022-05-21 03:30:17.682+00	2022-05-21 03:30:17.782+00	\N	\N	(73.55537645000001,18.5147011)	mulshi	mh	in	t	73.3227109	18.6779316	73.788042	18.3514706
d58lCTA7Uq	2022-05-21 03:30:18.437+00	2022-05-21 03:30:18.536+00	\N	\N	(29.163311999999998,-26.020395)	emalahleni local municipality	mp	za	t	28.919584	-25.6565	29.40704	-26.38429
5YGnq66zts	2022-05-21 03:30:19.216+00	2022-05-21 03:30:19.315+00	\N	\N	(-73.9921205,40.294996999999995)	long branch	nj	us	t	-74.01258	40.329783	-73.971661	40.260211
U8uDK36GGC	2022-05-21 03:30:19.78+00	2022-05-21 03:30:19.879+00	\N	\N	(4.4905589,51.9279744)	rotterdam	south holland	nl	t	4.3793095	51.9942816	4.6018083	51.8616672
RgCDGIzdEZ	2022-05-21 03:30:20.043+00	2022-05-21 03:30:20.142+00	\N	\N	(-101.265309,48.2373425)	minot	nd	us	t	-101.342952	48.283041	-101.187666	48.191644
7Cv2uLK6uJ	2022-05-21 03:30:20.767+00	2022-05-21 03:30:20.866+00	\N	\N	(-95.940124,32.1824673)	henderson county	tx	us	t	-96.451874	32.3590747	-95.428374	32.0058599
J3RXQjISgJ	2022-05-21 03:30:21.448+00	2022-05-21 03:30:21.547+00	\N	\N	(-89.24416975,48.3989891)	thunder bay	on	ca	t	-89.4275716	48.5149964	-89.0607679	48.2829818
NYkFnoAGlM	2022-05-21 03:30:22.103+00	2022-05-21 03:30:22.203+00	\N	\N	(-85.214922,42.302783700000006)	battle creek	mi	us	t	-85.297893	42.359433	-85.131951	42.2461344
2RcwoAiQGf	2022-05-21 03:30:22.507+00	2022-05-21 03:30:22.606+00	\N	\N	(-80.384922,39.2845925)	harrison county	wv	us	t	-80.604301	39.468376	-80.165543	39.100809
GSOkxMEBUw	2022-05-21 03:30:23.123+00	2022-05-21 03:30:23.223+00	\N	\N	(-102.46288385,51.21378095)	yorkton	sk	ca	t	-102.5213941	51.2470374	-102.4043736	51.1805245
XJApwHf3sU	2022-05-21 03:30:23.925+00	2022-05-21 03:30:24.025+00	\N	\N	(-80.35754800000001,40.369089)	smith township	pa	us	t	-80.435027	40.429584	-80.280069	40.308594
lJyU5QjRys	2022-05-21 03:30:24.318+00	2022-05-21 03:30:24.419+00	\N	\N	(-88.67076685,44.7230144)	town of belle plaine	wi	us	t	-88.7364402	44.7677675	-88.6050935	44.6782613
6EfBhe7Mzq	2022-05-21 03:30:25.022+00	2022-05-21 03:30:25.121+00	\N	\N	(-76.1777255,42.600262)	city of cortland	ny	us	t	-76.200831	42.614679	-76.15462	42.585845
2MJFwFY7YH	2022-05-21 03:30:25.786+00	2022-05-21 03:30:25.885+00	\N	\N	(22.93423,-33.7237533)	george local municipality	wc	za	t	22.19348	-33.38615	23.67498	-34.0613566
jd9wxVr6EP	2022-05-21 03:30:26.62+00	2022-05-21 03:30:26.719+00	\N	\N	(-120.82483665000001,56.24276785)	fort st. john	bc	ca	t	-120.8811168	56.2754739	-120.7685565	56.2100618
IYm3oQl6Xu	2022-05-21 03:30:27.418+00	2022-05-21 03:30:27.519+00	\N	\N	(-112.5405647,52.2603541)	county of stettler	ab	ca	t	-113.0917902	52.6680742	-111.9893392	51.852634
fXFaVBTlGr	2022-05-21 03:30:28.048+00	2022-05-21 03:30:28.147+00	\N	\N	(-86.6380255,31.857038000000003)	greenville	al	us	t	-86.70243	31.912161	-86.573621	31.801915
Kds9u3BDz1	2022-05-21 03:30:28.85+00	2022-05-21 03:30:28.953+00	\N	\N	(99.6037755,17.8935694)	wang chin	phrae province	th	t	99.4437755	18.0535694	99.7637755	17.7335694
RwRg9kZCSv	2022-05-21 03:30:29.54+00	2022-05-21 03:30:29.639+00	\N	\N	(3.27983355,50.80282985)	kortrijk	west flanders	be	t	3.2007699	50.8746286	3.3588972	50.7310311
bxQyJkqZUR	2022-05-21 03:30:29.898+00	2022-05-21 03:30:29.997+00	\N	\N	(74.49449295,18.483492650000002)	daund	mh	in	t	74.1415786	18.6734057	74.8474073	18.2935796
G9sE17YSk7	2022-05-21 03:30:30.282+00	2022-05-21 03:30:30.38+00	\N	\N	(-74.31471725,40.2318715)	freehold township	nj	us	t	-74.406777	40.295479	-74.2226575	40.168264
Gi2CxsWRpA	2022-05-21 03:30:30.59+00	2022-05-21 03:30:30.69+00	\N	\N	(-97.73789934999999,31.0822413)	killeen	tx	us	t	-97.8244787	31.1410253	-97.65132	31.0234573
wCCHda0Lxg	2022-05-21 03:30:31.025+00	2022-05-21 03:30:31.125+00	\N	\N	(-91.2388045,29.699637)	berwick	la	us	t	-91.263079	29.72532	-91.21453	29.673954
2TMI9F2CWp	2022-05-21 03:30:31.415+00	2022-05-21 03:30:31.516+00	\N	\N	(9.1300154,46.5880408)	vals	grisons	ch	t	9.0166229	46.6821288	9.2434079	46.4939528
JAhr5OjdMW	2022-05-21 03:30:31.86+00	2022-05-21 03:30:31.96+00	\N	\N	(-78.1223025,18.2104074)	westmoreland		jm	t	-78.3689286	18.3578369	-77.8756764	18.0629779
dPWQGM1A0j	2022-05-21 03:30:32.225+00	2022-05-21 03:30:32.325+00	\N	\N	(-72.9409675,41.68138395)	bristol	ct	us	t	-72.9985466	41.723165	-72.8833884	41.6396029
P9ijf7CZda	2022-05-21 03:30:33.314+00	2022-05-21 03:30:33.414+00	\N	\N	(9.54152275,56.18177125)	silkeborg municipality	central denmark region	dk	t	9.2219633	56.369558	9.8610822	55.9939845
iAVhgjM8Yv	2022-05-21 03:30:33.839+00	2022-05-21 03:30:33.938+00	\N	\N	(-81.024073,24.7328185)	marathon	fl	us	t	-81.124769	24.777277	-80.923377	24.68836
zRuloapZjW	2022-05-21 03:30:34.202+00	2022-05-21 03:30:34.303+00	\N	\N	(-84.0922315,34.192938100000006)	forsyth county	ga	us	t	-84.258934	34.335171	-83.925529	34.0507052
vO5fErHEZg	2022-05-21 03:30:34.588+00	2022-05-21 03:30:34.684+00	\N	\N	(-90.869629,30.2048987)	ascension parish	la	us	t	-91.106926	30.3470644	-90.632332	30.062733
Cxl5sZdycZ	2022-05-21 03:30:34.915+00	2022-05-21 03:30:35.014+00	\N	\N	(-96.9146374,19.5408338)	xalapa	veracruz	mx	t	-97.0746374	19.7008338	-96.7546374	19.3808338
QyxEnDcG09	2022-05-21 03:30:35.374+00	2022-05-21 03:30:35.474+00	\N	\N	(-83.5546124,35.487501550000005)	swain county	nc	us	t	-83.9533945	35.6958885	-83.1558303	35.2791146
GuagyC3MDs	2022-05-21 03:30:35.665+00	2022-05-21 03:30:35.766+00	\N	\N	(-93.34035645,45.108815)	brooklyn park	mn	us	t	-93.4023859	45.1520363	-93.278327	45.0655937
Lo4gr58LBm	2022-05-21 03:30:36.076+00	2022-05-21 03:30:36.175+00	\N	\N	(-88.1581185,33.119127)	aliceville	al	us	t	-88.181153	33.14098	-88.135084	33.097274
C6sa6Kkqsk	2022-05-21 03:30:36.443+00	2022-05-21 03:30:36.543+00	\N	\N	(-93.0182736,45.0674465)	white bear lake	mn	us	t	-93.056241	45.101898	-92.9803062	45.032995
u0htzLaRBC	2022-05-21 03:30:36.952+00	2022-05-21 03:30:37.052+00	\N	\N	(-88.17627885,41.5126441)	joliet	il	us	t	-88.3621969	41.5948417	-87.9903608	41.4304465
qKyHw53snW	2022-05-21 03:30:37.383+00	2022-05-21 03:30:37.483+00	\N	\N	(-88.80571185,43.0060695)	jefferson	wi	us	t	-88.8350617	43.028336	-88.776362	42.983803
wFCcWGrgBF	2022-05-21 03:30:37.672+00	2022-05-21 03:30:37.771+00	\N	\N	(-87.8510125,41.60265485)	orland park	il	us	t	-87.911639	41.6525927	-87.790386	41.552717
XSD2BpQtLK	2022-05-21 03:30:38.029+00	2022-05-21 03:30:38.129+00	\N	\N	(-112.132909,43.381384499999996)	shelley	id	us	t	-112.153133	43.395883	-112.112685	43.366886
yVutHZE4rX	2022-05-21 03:30:38.405+00	2022-05-21 03:30:38.505+00	\N	\N	(-95.76967055,39.042784600000005)	shawnee county	ks	us	t	-96.0390871	39.2167022	-95.500254	38.868867
A8tmGlZuTo	2022-05-21 03:30:38.855+00	2022-05-21 03:30:38.955+00	\N	\N	(115.12254999999999,-8.2565125)		bali	id	t	114.4126778	-7.4627963	115.8324222	-9.0502287
eGO9UScGNj	2022-05-21 03:30:39.254+00	2022-05-21 03:30:39.355+00	\N	\N	(-85.75964350000001,44.381256199999996)	springville township	mi	us	t	-85.8207308	44.4245356	-85.6985562	44.3379768
Kb89fR4VDK	2022-05-21 03:30:39.608+00	2022-05-21 03:30:39.707+00	\N	\N	(25.3397029,43.513673999999995)	svishtov		bg	t	25.1260509	43.6556733	25.5533549	43.3716747
CNhpX4X31v	2022-05-21 03:30:40.074+00	2022-05-21 03:30:40.174+00	\N	\N	(-92.3925724,34.752289450000006)	pulaski county	ar	us	t	-92.7554438	35.0146269	-92.029701	34.489952
Q8ZOCQqohV	2022-05-21 03:30:40.451+00	2022-05-21 03:30:40.552+00	\N	\N	(-96.74593315,43.540902)	sioux falls	sd	us	t	-96.8407323	43.6163657	-96.651134	43.4654383
7B1Vq6OFfT	2022-05-21 03:30:40.861+00	2022-05-21 03:30:40.961+00	\N	\N	(-96.07503595,30.105282449999997)	hempstead	tx	us	t	-96.1113695	30.1332253	-96.0387024	30.0773396
oIYocA2Rbh	2022-05-21 03:30:41.239+00	2022-05-21 03:30:41.339+00	\N	\N	(-75.99974915,39.541457550000004)	cecil county	md	us	t	-76.2329069	39.7222006	-75.7665914	39.3607145
oivdXjDfps	2022-05-21 03:30:41.586+00	2022-05-21 03:30:41.686+00	\N	\N	(26.0099332,44.932281)	ploiești		ro	t	25.9178971	44.9684177	26.1019693	44.8961443
9Vij7fuyxD	2022-05-21 03:30:41.975+00	2022-05-21 03:30:42.076+00	\N	\N	(27.19711,-27.568445)	moqhaka local municipality	fs	za	t	26.52162	-26.85265	27.8726	-28.28424
Oh6tddEndC	2022-05-21 03:30:42.306+00	2022-05-21 03:30:42.405+00	\N	\N	(-3.7034351,40.477853350000004)	madrid	community of madrid	es	t	-3.8889539	40.6437293	-3.5179163	40.3119774
1IKwmYhG2l	2022-05-21 03:30:42.649+00	2022-05-21 03:30:42.748+00	\N	\N	(-121.3128911,44.0614073)	bend	or	us	t	-121.3824328	44.1237516	-121.2433494	43.999063
XyYuFlRrKW	2022-05-21 03:30:42.999+00	2022-05-21 03:30:43.099+00	\N	\N	(-87.6987387,42.04545815)	evanston	il	us	t	-87.732456	42.0717698	-87.6650214	42.0191465
PhFytuncBC	2022-05-21 03:30:43.347+00	2022-05-21 03:30:43.447+00	\N	\N	(-86.56277700000001,33.5375885)	leeds	al	us	t	-86.626624	33.589448	-86.49893	33.485729
0Ar4R1MEVy	2022-05-21 03:30:43.741+00	2022-05-21 03:30:43.842+00	\N	\N	(-8.18720595,54.289443950000006)	county leitrim	manorhamilton municipal district	ie	t	-8.4277309	54.4743537	-7.946681	54.1045342
2maOUH8VEE	2022-05-21 03:30:44.082+00	2022-05-21 03:30:44.181+00	\N	\N	(30.6634864,-30.3507928)	umdoni local municipality	nl	za	t	30.5626899	-30.1985479	30.7642829	-30.5030377
GHrQaWeqKj	2022-05-21 03:30:44.376+00	2022-05-21 03:30:44.476+00	\N	\N	(-94.758668,31.2342142)	burke	tx	us	t	-94.7872315	31.2499152	-94.7301045	31.2185132
uVNBzEDWGx	2022-05-21 03:30:44.729+00	2022-05-21 03:30:44.829+00	\N	\N	(-72.50548515,42.367640249999994)	amherst	ma	us	t	-72.5467762	42.4338163	-72.4641941	42.3014642
SBhjAAPWuL	2022-05-21 03:30:45.086+00	2022-05-21 03:30:45.187+00	\N	\N	(-80.24950515,26.270335950000003)	coral springs	fl	us	t	-80.2974021	26.3109974	-80.2016082	26.2296745
Mm26yIToaU	2022-05-21 03:30:45.501+00	2022-05-21 03:30:45.6+00	\N	\N	(-84.98458099999999,40.4369305)	portland	in	us	t	-85.009914	40.461887	-84.959248	40.411974
w1Cwq6Iav4	2022-05-21 03:30:45.826+00	2022-05-21 03:30:45.925+00	\N	\N	(-75.45292509999999,41.1769381)	coolbaugh township	pa	us	t	-75.5986418	41.2424144	-75.3072084	41.1114618
62yUhTjUeS	2022-05-21 03:30:46.261+00	2022-05-21 03:30:46.36+00	\N	\N	(-96.13816765,31.7130008)	freestone county	tx	us	t	-96.4967691	32.0125957	-95.7795662	31.4134059
2iFh5mhjny	2022-05-21 03:30:46.709+00	2022-05-21 03:30:46.81+00	\N	\N	(-87.8111509,42.03101075)	niles	il	us	t	-87.855008	42.0620186	-87.7672938	42.0000029
i6AGETPHx9	2022-05-21 03:30:47.172+00	2022-05-21 03:30:47.271+00	\N	\N	(-90.51487449999999,38.2526117)	jefferson county	mo	us	t	-90.7803989	38.5017706	-90.2493501	38.0034528
tCO0z0kHtV	2022-05-21 03:30:47.667+00	2022-05-21 03:30:47.767+00	\N	\N	(-1.5192081499999999,52.4143282)	coventry	eng	gb	t	-1.6144589	52.4647716	-1.4239574	52.3638848
mgNTLt8OwX	2022-05-21 03:30:48.189+00	2022-05-21 03:30:48.288+00	\N	\N	(-75.3741691,6.153616599999999)	rionegro	ant	co	t	-75.5341691	6.3136166	-75.2141691	5.9936166
KsxkCV2nhl	2022-05-21 03:30:48.565+00	2022-05-21 03:30:48.666+00	\N	\N	(23.1950615,45.8430455)	orăștie	335700	ro	t	23.172998	45.862384	23.217125	45.823707
0ul4HGmESM	2022-05-21 03:30:48.948+00	2022-05-21 03:30:49.049+00	\N	\N	(29.196015000000003,-26.453575)	govan mbeki	mp	za	t	28.76292	-26.16955	29.62911	-26.7376
B5unne4kIH	2022-05-21 03:30:49.289+00	2022-05-21 03:30:49.388+00	\N	\N	(-82.5718731,40.680913000000004)	lexington	oh	us	t	-82.607919	40.6959954	-82.5358272	40.6658306
pNIBuz6G2F	2022-05-21 03:30:49.734+00	2022-05-21 03:30:49.833+00	\N	\N	(-73.3502015,42.900013)	hoosick falls	ny	us	t	-73.363025	42.911376	-73.337378	42.88865
hgPuCGWl5h	2022-05-21 03:30:50.105+00	2022-05-21 03:30:50.205+00	\N	\N	(-78.05247,48.45885455)	saint-marc-de-figuery	qc	ca	t	-78.1359416	48.5170411	-77.9689984	48.400668
eZseuEEGbp	2022-05-21 03:30:50.418+00	2022-05-21 03:30:50.518+00	\N	\N	(-77.87871,39.873005)	peters township	pa	us	t	-77.977774	39.946404	-77.779646	39.799606
BNvkbSXqtF	2022-05-21 03:30:50.714+00	2022-05-21 03:30:50.813+00	\N	\N	(39.16536120000001,21.5810088)	jeddah	makkah region	sa	t	39.0053612	21.7410088	39.3253612	21.4210088
JyAiTNsVG0	2022-05-21 03:30:51.249+00	2022-05-21 03:30:51.349+00	\N	\N	(91.1808748,23.4610615)	cumilla	chattogram division	bd	t	91.0208748	23.6210615	91.3408748	23.3010615
qzuGNvsaMh	2022-05-21 03:30:51.715+00	2022-05-21 03:30:51.817+00	\N	\N	(24.98761,-26.1358569)	ratlou local municipality	north west	za	t	24.46507	-25.7214188	25.51015	-26.550295
0cfxExH0RY	2022-05-21 03:30:52.311+00	2022-05-21 03:30:52.411+00	\N	\N	(9.2148899,53.7113809)	hamburg		de	t	8.1044993	54.02765	10.3252805	53.3951118
b8GACIZmH0	2022-05-21 03:30:52.736+00	2022-05-21 03:30:52.835+00	\N	\N	(-99.5563473,38.93532)	ellis	ks	us	t	-99.573213	38.949645	-99.5394816	38.920995
bRbEDG0rBj	2022-05-21 03:30:53.223+00	2022-05-21 03:30:53.322+00	\N	\N	(-82.06450595,32.39349015)	metter	ga	us	t	-82.0935002	32.4188098	-82.0355117	32.3681705
GctBvppyfx	2022-05-21 03:30:53.766+00	2022-05-21 03:30:53.866+00	\N	\N	(-75.028527,39.7893)	gloucester township	nj	us	t	-75.088681	39.852636	-74.968373	39.725964
kLWDqdWCOD	2022-05-21 03:30:54.13+00	2022-05-21 03:30:54.229+00	\N	\N	(-73.45004315,45.4492265)	brossard	qc	ca	t	-73.5237193	45.4853509	-73.376367	45.4131021
o4pAVLkXBw	2022-05-21 03:30:54.438+00	2022-05-21 03:30:54.538+00	\N	\N	(-89.06807425,42.2409468)	rockford	il	us	t	-89.1952803	42.3386478	-88.9408682	42.1432458
s7BuGcDLAr	2022-05-21 03:30:54.78+00	2022-05-21 03:30:54.879+00	\N	\N	(17.6829489,59.3554297)	ekerö kommun		se	t	17.4110712	59.4515678	17.9548266	59.2592916
BiyI5Cykbd	2022-05-21 03:30:55.306+00	2022-05-21 03:30:55.406+00	\N	\N	(-101.1956788,36.2060537)	spearman	tx	us	t	-101.209175	36.2285139	-101.1821826	36.1835935
Qyn2CimYPn	2022-05-21 03:30:55.751+00	2022-05-21 03:30:55.851+00	\N	\N	(-88.98166455,40.5277931)	normal	il	us	t	-89.060454	40.5617532	-88.9028751	40.493833
a8UcAamPpZ	2022-05-21 03:30:56.126+00	2022-05-21 03:30:56.225+00	\N	\N	(-122.3744374,45.58063785)	multnomah county	or	us	t	-122.9292062	45.7286439	-121.8196686	45.4326318
r37lUAatpw	2022-05-21 03:30:56.515+00	2022-05-21 03:30:56.615+00	\N	\N	(-71.3013454,42.8054045)	windham	nh	us	t	-71.3663038	42.850701	-71.236387	42.760108
TyZZrgpnrH	2022-05-21 03:30:56.898+00	2022-05-21 03:30:56.999+00	\N	\N	(-71.44140595,42.1974945)	holliston	ma	us	t	-71.5026303	42.2382065	-71.3801816	42.1567825
WcodDMJPmC	2022-05-21 03:30:57.572+00	2022-05-21 03:30:57.672+00	\N	\N	(-84.13023385,31.7692258)	lee county	ga	us	t	-84.338013	31.916487	-83.9224547	31.6219646
YrV00xLfLE	2022-05-21 03:30:57.886+00	2022-05-21 03:30:57.985+00	\N	\N	(-91.3212319,45.508527)	town of atlanta	wi	us	t	-91.41947	45.552474	-91.2229938	45.46458
kM7tFmozq6	2022-05-21 03:30:58.297+00	2022-05-21 03:30:58.396+00	\N	\N	(6.2238758999999995,46.1956768)	ambilly	ara	fr	t	6.2138026	46.2035048	6.2339492	46.1878488
sJ8NsTDMBZ	2022-05-21 03:30:58.548+00	2022-05-21 03:30:58.647+00	\N	\N	(25.34938,-32.778255)	blue crane route local municipality	ec	za	t	24.41368	-32.24118	26.28508	-33.31533
MLk4QfKdAD	2022-05-21 03:30:58.932+00	2022-05-21 03:30:59.032+00	\N	\N	(7.4892974,9.0643305)	abuja	federal capital territory	ng	t	7.3292974	9.2243305	7.6492974	8.9043305
aAnXTaEuNs	2022-05-21 03:30:59.425+00	2022-05-21 03:30:59.524+00	\N	\N	(-71.49331864999999,43.6257788)	meredith	nh	us	t	-71.6424419	43.6986683	-71.3441954	43.5528893
ZCvUjCiPzQ	2022-05-21 03:30:59.9+00	2022-05-21 03:31:00+00	\N	\N	(-120.514506,34.7431243)	vandenberg afb	ca	us	t	-120.573763	34.7837738	-120.455249	34.7024748
QFdKOCCtPg	2022-05-21 03:31:00.268+00	2022-05-21 03:31:00.368+00	\N	\N	(-75.57733765,40.67918675)	north whitehall township	pa	us	t	-75.6388008	40.7376316	-75.5158745	40.6207419
GAdU4VM1Vc	2022-05-21 03:31:00.838+00	2022-05-21 03:31:00.937+00	\N	\N	(-84.542372,33.9483787)	marietta	ga	us	t	-84.616806	34.00117	-84.467938	33.8955874
7H4kcE9Qkb	2022-05-21 03:31:01.144+00	2022-05-21 03:31:01.243+00	\N	\N	(-84.4584135,34.242944)	cherokee county	ga	us	t	-84.659241	34.41259	-84.257586	34.073298
OhxIeVJ0nF	2022-05-21 03:31:01.469+00	2022-05-21 03:31:01.568+00	\N	\N	(-97.36581244999999,29.0989114)	dewitt county	tx	us	t	-97.754855	29.3845414	-96.9767699	28.8132814
3WBR7FkRMZ	2022-05-21 03:31:01.824+00	2022-05-21 03:31:01.924+00	\N	\N	(-74.057174,41.0827665)	chestnut ridge	ny	us	t	-74.081713	41.102075	-74.032635	41.063458
mM93GqR8Sh	2022-05-29 12:35:46.624+00	2022-05-29 12:35:46.721+00	\N	\N	(-90.13279700000001,32.47430605)	madison	ms	us	t	-90.2052797	32.522702	-90.0603143	32.4259101
4khZlQPd6R	2022-05-29 12:35:47.254+00	2022-05-29 12:35:47.332+00	\N	\N	(25.5301248,-33.801919999999996)	nelson mandela bay metropolitan municipality	ec	za	t	25.19223	-33.55308	25.8680196	-34.05076
xvsbpb84XB	2022-05-29 12:35:48.177+00	2022-05-29 12:35:48.267+00	\N	\N	(13.0705688,11.7715019)	dala	bo	ng	t	13.0392692	11.8282391	13.1018684	11.7147647
A2sfI9KZPN	2022-05-29 12:35:48.575+00	2022-05-29 12:35:48.673+00	\N	\N	(-93.2825208,44.370172100000005)	rice county	mn	us	t	-93.525638	44.5439451	-93.0394036	44.1963991
ieXUniuE9m	2022-05-29 12:35:49.344+00	2022-05-29 12:35:49.438+00	\N	\N	(-94.45017055,38.7957244)	raymore	mo	us	t	-94.4994726	38.8416654	-94.4008685	38.7497834
7sux7ie3sG	2022-05-29 12:35:49.824+00	2022-05-29 12:35:49.929+00	\N	\N	(2.2880342999999996,48.93186355)	gennevilliers	ile-de-france	fr	t	2.2475775	48.9510806	2.3284911	48.9126465
pDX84pI8OS	2022-05-29 12:35:50.869+00	2022-05-29 12:35:50.969+00	\N	\N	(16.59722975,58.62555035)	norrköpings kommun		se	t	15.6176019	58.8539615	17.5768576	58.3971392
McGcKv38f9	2022-05-29 12:35:51.21+00	2022-05-29 12:35:51.31+00	\N	\N	(-92.068462,46.698457000000005)	city of superior	wi	us	t	-92.205692	46.749237	-91.931232	46.647677
tJfk5v68Um	2022-05-29 12:35:52.02+00	2022-05-29 12:35:52.12+00	\N	\N	(44.80735935,41.731907500000005)	tbilisi		ge	t	44.5969219	41.8434205	45.0177968	41.6203945
ZaolmcYC6X	2022-05-29 12:35:52.841+00	2022-05-29 12:35:52.939+00	\N	\N	(-76.8881555,38.760012599999996)	clinton	md	us	t	-76.9321174	38.7991112	-76.8441936	38.720914
GP64WV7WGA	2022-05-29 12:35:53.319+00	2022-05-29 12:35:53.417+00	\N	\N	(-71.57700034999999,42.616439299999996)	groton	ma	us	t	-71.6604731	42.6634953	-71.4935276	42.5693833
vA70AS2Wd1	2022-05-29 12:35:54.169+00	2022-05-29 12:35:54.263+00	\N	\N	(8.0270917,50.3600525)	diez	rhineland-palatinate	de	t	7.9902478	50.3861281	8.0639356	50.3339769
ER56AcQ4ZG	2022-05-29 12:35:56.985+00	2022-05-29 12:35:57.081+00	\N	\N	(-95.2555784,38.96898465)	lawrence	ks	us	t	-95.3445398	39.0335024	-95.166617	38.9044669
7G9N9IJMwv	2022-05-29 12:35:57.646+00	2022-05-29 12:35:57.745+00	\N	\N	(74.7493451,19.092952)	ahmednagar	mh	in	t	74.5893451	19.252952	74.9093451	18.932952
pKDV3h56Ir	2022-05-29 12:35:58.03+00	2022-05-29 12:35:58.126+00	\N	\N	(9.364129349999999,56.833754600000006)	vesthimmerland municipality	north denmark region	dk	t	9.0683518	57.0306136	9.6599069	56.6368956
Sgh8xLSOEY	2022-05-29 12:35:58.422+00	2022-05-29 12:35:58.524+00	\N	\N	(21.9428424,47.0575872)	oradea		ro	t	21.8864318	47.0951855	21.999253	47.0199889
oMBh0DJfPX	2022-05-29 12:35:58.804+00	2022-05-29 12:35:58.904+00	\N	\N	(-71.51849375,41.82862025)	johnston	ri	us	t	-71.575107	41.8688575	-71.4618805	41.788383
aFDUlribNA	2022-05-29 12:35:59.259+00	2022-05-29 12:35:59.356+00	\N	\N	(-73.863864,42.807801)	town of niskayuna	ny	us	t	-73.918167	42.851333	-73.809561	42.764269
kBurECHdAl	2022-05-29 12:35:59.968+00	2022-05-29 12:36:00.064+00	\N	\N	(-84.6586418,38.981291999999996)	florence	ky	us	t	-84.706664	39.030914	-84.6106196	38.93167
H5llpL9Aro	2022-05-29 12:36:00.354+00	2022-05-29 12:36:00.453+00	\N	\N	(-84.1577365,37.96848635)	clark county	ky	us	t	-84.348974	38.115162	-83.966499	37.8218107
Pd5mWzyFxI	2022-05-29 12:36:00.737+00	2022-05-29 12:36:00.827+00	\N	\N	(-74.26915249999999,39.706677)	stafford township	nj	us	t	-74.389658	39.773047	-74.148647	39.640307
62hNRGA2qq	2022-05-29 12:36:01.129+00	2022-05-29 12:36:01.229+00	\N	\N	(-72.68016225,41.7655447)	hartford	ct	us	t	-72.7180372	41.8074191	-72.6422873	41.7236703
X0Yh3aS0ZD	2022-05-29 12:36:03.099+00	2022-05-29 12:36:03.195+00	\N	\N	(-105.220306,20.6407176)	puerto vallarta	jal	mx	t	-105.380306	20.8007176	-105.060306	20.4807176
BWSM9YCGvK	2022-05-29 12:36:03.412+00	2022-05-29 12:36:03.52+00	\N	\N	(144.28259309999999,-36.7588767)	bendigo	vic	au	t	144.1225931	-36.5988767	144.4425931	-36.9188767
wE2NkoWKIE	2022-05-29 12:36:03.914+00	2022-05-29 12:36:04.013+00	\N	\N	(-82.2207432,39.44819505)	nelsonville	oh	us	t	-82.254322	39.4712541	-82.1871644	39.425136
s8K3xttY1p	2022-05-29 12:36:04.304+00	2022-05-29 12:36:04.403+00	\N	\N	(100.4577414,7.0026257)	hat yai	songkhla province	th	t	100.2977414	7.1626257	100.6177414	6.8426257
66F2Abr5g8	2022-05-29 12:36:05.055+00	2022-05-29 12:36:05.155+00	\N	\N	(-81.1057715,37.41552885)	mercer county	wv	us	t	-81.362092	37.596188	-80.849451	37.2348697
EDo64TL81m	2022-05-29 12:36:05.498+00	2022-05-29 12:36:05.584+00	\N	\N	(-94.4241435,30.7749385)	woodville	tx	us	t	-94.440276	30.796202	-94.408011	30.753675
oHA6eJwZDK	2022-05-29 12:36:05.962+00	2022-05-29 12:36:06.062+00	\N	\N	(-71.24473485,42.285677050000004)	needham	ma	us	t	-71.3012709	42.316515	-71.1881988	42.2548391
VcMxCN6J88	2022-05-29 12:36:06.249+00	2022-05-29 12:36:06.348+00	\N	\N	(-83.34891535,40.229849)	marysville	oh	us	t	-83.4141997	40.273974	-83.283631	40.185724
UFXs6BI6la	2022-05-29 12:36:06.765+00	2022-05-29 12:36:06.865+00	\N	\N	(-92.467503,37.2711611)	wright county	mo	us	t	-92.689835	37.482613	-92.245171	37.0597092
zZWncYjgHd	2022-05-29 12:36:07.592+00	2022-05-29 12:36:07.678+00	\N	\N	(-121.22683045,37.7967923)	manteca	ca	us	t	-121.292984	37.8409803	-121.1606769	37.7526043
wHfl5IaDXw	2022-05-29 12:36:08.333+00	2022-05-29 12:36:08.433+00	\N	\N	(76.68913775,30.77848895)	kharar tahsil	pb	in	t	76.5212714	30.9377727	76.8570041	30.6192052
D2IY1MB01v	2022-05-29 12:36:08.661+00	2022-05-29 12:36:08.761+00	\N	\N	(-106.6446535,39.637393849999995)	eagle county	co	us	t	-107.113739	39.9252967	-106.175568	39.349491
YgSmWTCwAa	2022-05-29 12:36:08.914+00	2022-05-29 12:36:09.014+00	\N	\N	(-97.5251355,44.011268)	howard	sd	us	t	-97.540001	44.020211	-97.51027	44.002325
ogD832nYGy	2022-05-29 12:36:09.51+00	2022-05-29 12:36:09.606+00	\N	\N	(47.973562900000005,29.3797091)	kuwait city	al asimah	kw	t	47.8135629	29.5397091	48.1335629	29.2197091
6LI8xockfj	2022-05-29 12:36:10.075+00	2022-05-29 12:36:10.166+00	\N	\N	(73.0535122,33.5914237)	rawalpindi	pb	pk	t	72.8935122	33.7514237	73.2135122	33.4314237
feyVeWvpEj	2022-05-29 12:36:10.452+00	2022-05-29 12:36:10.551+00	\N	\N	(-106.2151974,38.102990250000005)	saguache county	co	us	t	-107.0018958	38.458171	-105.428499	37.7478095
iCoLucA7h1	2022-05-29 12:36:10.834+00	2022-05-29 12:36:10.935+00	\N	\N	(-149.71454949999998,62.2788488)	matanuska-susitna	ak	us	t	-153.005115	63.4797376	-146.423984	61.07796
MHCGw4HCUB	2022-05-29 12:36:11.336+00	2022-05-29 12:36:11.437+00	\N	\N	(-81.5487782,35.2847869)	shelby	nc	us	t	-81.636922	35.3303978	-81.4606344	35.239176
TvNUjiogeu	2022-05-29 12:36:11.746+00	2022-05-29 12:36:11.846+00	\N	\N	(-87.6849718,41.6025295)	markham	il	us	t	-87.719873	41.622362	-87.6500706	41.582697
BSYNDNwQqz	2022-05-29 12:36:12.31+00	2022-05-29 12:36:12.41+00	\N	\N	(21.3613196,38.655466849999996)	municipal unit of agrinio	peloponnese, western greece and the ionian	gr	t	21.2546574	38.7490333	21.4679818	38.5619004
j9n7pYYj6X	2022-05-29 12:36:13.464+00	2022-05-29 12:36:13.563+00	\N	\N	(-114.0506058,47.116327999999996)	missoula county	mt	us	t	-114.7975536	47.601078	-113.303658	46.631578
BO7IynKFsb	2022-05-29 12:36:13.961+00	2022-05-29 12:36:14.067+00	\N	\N	(12.14689805,54.147653399999996)	rostock	mv	de	t	11.998369	54.2445018	12.2954271	54.050805
u9GY1oqjGF	2022-05-29 12:36:14.4+00	2022-05-29 12:36:14.504+00	\N	\N	(-71.69472285,41.970829949999995)	burrillville	ri	us	t	-71.799195	42.0132805	-71.5902507	41.9283794
Wg3122ww7D	2022-05-29 12:36:14.805+00	2022-05-29 12:36:14.904+00	\N	\N	(20.445596899999998,-34.037205)	swellendam local municipality	wc	za	t	19.8808538	-33.62197	21.01034	-34.45244
DnCVtYS4Hg	2022-05-29 12:36:15.111+00	2022-05-29 12:36:15.211+00	\N	\N	(-91.3827112,34.2521305)	arkansas county	ar	us	t	-91.7116424	34.566502	-91.05378	33.937759
AuAwlfXCMO	2022-05-29 12:36:15.467+00	2022-05-29 12:36:15.563+00	\N	\N	(-84.16581479999999,31.5727127)	albany	ga	us	t	-84.2729886	31.6230413	-84.058641	31.5223841
dfZBd3BWJk	2022-05-29 12:36:16.724+00	2022-05-29 12:36:16.824+00	\N	\N	(-85.35684,40.341646499999996)	eaton	in	us	t	-85.372319	40.352197	-85.341361	40.331096
YD3Oly2FyG	2022-05-29 12:36:17.042+00	2022-05-29 12:36:17.142+00	\N	\N	(-86.7205935,32.9684755)	jemison	al	us	t	-86.76287	33.008763	-86.678317	32.928188
4m8FEtHhNa	2022-05-29 12:36:17.499+00	2022-05-29 12:36:17.598+00	\N	\N	(-84.082122,42.467222)	unadilla township	mi	us	t	-84.140842	42.510525	-84.023402	42.423919
C6fBjhdupH	2022-05-29 12:36:17.926+00	2022-05-29 12:36:18.025+00	\N	\N	(76.27414569999999,9.98408)	ernakulam	kl	in	t	76.1141457	10.14408	76.4341457	9.82408
q8vLT3QRRZ	2022-05-29 12:36:18.381+00	2022-05-29 12:36:18.481+00	\N	\N	(-72.059681,42.829185)	jaffrey	nh	us	t	-72.144652	42.868968	-71.97471	42.789402
4AdIVhMmEr	2022-05-29 12:36:18.725+00	2022-05-29 12:36:18.825+00	\N	\N	(-114.84055699999999,42.9239325)	gooding county	id	us	t	-115.086902	43.198567	-114.594212	42.649298
dqgxe16ViT	2022-05-29 12:36:19.194+00	2022-05-29 12:36:19.295+00	\N	\N	(-88.093515,30.843024)	saraland	al	us	t	-88.157286	30.908357	-88.029744	30.777691
mH4y3tnrJH	2022-05-29 12:36:19.815+00	2022-05-29 12:36:19.911+00	\N	\N	(-90.191678,41.2968415)	cambridge	il	us	t	-90.208286	41.31057	-90.17507	41.283113
w5k2kwVEwJ	2022-05-29 12:36:20.253+00	2022-05-29 12:36:20.343+00	\N	\N	(-88.3386692,42.037476999999996)	elgin	il	us	t	-88.4545654	42.103581	-88.222773	41.971373
BJJRUsNvPd	2022-05-29 12:36:20.632+00	2022-05-29 12:36:20.732+00	\N	\N	(-120.46763975,47.516322599999995)	cashmere	wa	us	t	-120.488684	47.5251853	-120.4465955	47.5074599
rqDK7JCXCE	2022-05-29 12:35:54.582+00	2022-05-29 12:35:54.681+00	\N	\N	(-69.5850545,44.528965150000005)	winslow	me	us	t	-69.6765666	44.577319	-69.4935424	44.4806113
gnckov5E8A	2022-05-29 12:35:55.154+00	2022-05-29 12:35:55.254+00	\N	\N	(-0.42793585,51.8911061)	luton	eng	gb	t	-0.5059486	51.9277389	-0.3499231	51.8544733
kpflxpwxa9	2022-05-29 12:35:55.532+00	2022-05-29 12:35:55.633+00	\N	\N	(10.41753375,57.461257599999996)	frederikshavn municipality	north denmark region	dk	t	10.18283	57.7523787	10.6522375	57.1701365
qFHKqZDv1E	2022-05-29 12:35:56.011+00	2022-05-29 12:35:56.102+00	\N	\N	(-83.06752825,39.341890500000005)	ross county	oh	us	t	-83.3943714	39.5159735	-82.7406851	39.1678075
l5JMCbHftL	2022-05-29 12:35:56.351+00	2022-05-29 12:35:56.449+00	\N	\N	(-97.94302975,35.94504945)	kingfisher county	ok	us	t	-98.212067	36.165007	-97.6739925	35.7250919
hsp8aiqMMH	2022-05-29 12:36:02.032+00	2022-05-29 12:36:02.132+00	\N	\N	(-73.9203071,45.825574950000004)	sainte-sophie	qc	ca	t	-74.0328539	45.8845908	-73.8077603	45.7665591
RKwyI1xgSm	2022-05-29 12:36:02.629+00	2022-05-29 12:36:02.722+00	\N	\N	(-78.6247992,35.79799985)	wake county	nc	us	t	-78.9950674	36.0765416	-78.254531	35.5194581
E0NjArOh9v	2022-05-29 12:36:15.899+00	2022-05-29 12:36:15.999+00	\N	\N	(-76.75514000000001,40.011973350000005)	manchester township	pa	us	t	-76.80185	40.052427	-76.70843	39.9715197
Qk67QWnCoP	2022-05-29 12:36:16.273+00	2022-05-29 12:36:16.372+00	\N	\N	(-71.49907974999999,41.99839195)	woonsocket	ri	us	t	-71.5400433	42.0178523	-71.4581162	41.9789316
k5vrzYwtWD	2022-05-29 12:36:21.112+00	2022-05-29 12:36:21.212+00	\N	\N	(10.422590750000001,53.23924175)	lüneburg	lower saxony	de	t	10.3308253	53.2866442	10.5143562	53.1918393
Rkcs7Dqpt9	2022-05-29 12:36:21.579+00	2022-05-29 12:36:21.678+00	\N	\N	(-83.1782405,43.6006035)	cass city	mi	us	t	-83.194575	43.618564	-83.161906	43.582643
eqhNPCbJM1	2022-05-29 12:36:21.885+00	2022-05-29 12:36:21.985+00	\N	\N	(-83.0706055,40.282801)	delaware	oh	us	t	-83.12861	40.338201	-83.012601	40.227401
9ouDsDFbKy	2022-05-29 12:36:22.36+00	2022-05-29 12:36:22.459+00	\N	\N	(127.40184045000001,36.341621849999996)	daejeon		kr	t	127.2463188	36.4998754	127.5573621	36.1833683
RG4LMzSIRA	2022-05-29 12:36:22.85+00	2022-05-29 12:36:22.95+00	\N	\N	(-97.60254284999999,30.65681095)	williamson county	tx	us	t	-98.0498869	30.910808	-97.1551988	30.4028139
FEFPfYd443	2022-05-29 12:36:23.187+00	2022-05-29 12:36:23.283+00	\N	\N	(-71.0286131,42.6788418)	boxford	ma	us	t	-71.1086316	42.7370006	-70.9485946	42.620683
vMADNxOqma	2022-05-29 12:36:23.756+00	2022-05-29 12:36:23.856+00	\N	\N	(-121.610052,39.763452)	paradise	ca	us	t	-121.655652	39.801543	-121.564452	39.725361
EUeQWruHYf	2022-05-29 12:36:24.28+00	2022-05-29 12:36:24.38+00	\N	\N	(-3.7706144,40.2288861)	parla	community of madrid	es	t	-3.8074244	40.256532	-3.7338044	40.2012402
uqdSk7eLi8	2022-05-29 12:36:24.706+00	2022-05-29 12:36:24.806+00	\N	\N	(-85.92693755,39.19772185)	columbus	in	us	t	-86.0029791	39.2748477	-85.850896	39.120596
FCQNGvHn3h	2022-05-29 12:36:25.319+00	2022-05-29 12:36:25.419+00	\N	\N	(-74.54825249999999,40.46459745)	franklin township	nj	us	t	-74.637463	40.554801	-74.459042	40.3743939
6wtd1b3CAH	2022-05-29 12:36:25.703+00	2022-05-29 12:36:25.803+00	\N	\N	(-111.87054900000001,48.483063)	shelby	mt	us	t	-111.917444	48.544516	-111.823654	48.42161
TR9FG0DIka	2022-05-29 12:36:26.081+00	2022-05-29 12:36:26.178+00	\N	\N	(-79.4281979,43.9026207)	richmond hill	on	ca	t	-79.485534	43.9776956	-79.3708618	43.8275458
vbMF2eitcJ	2022-05-29 12:36:26.611+00	2022-05-29 12:36:26.709+00	\N	\N	(131.1204245,-12.499503)	litchfield municipality		au	t	130.84396	-12.13713	131.396889	-12.861876
dObvPKF6S8	2022-05-29 12:36:26.973+00	2022-05-29 12:36:27.072+00	\N	\N	(-77.92484630000001,34.95218505)	duplin county	nc	us	t	-78.1986461	35.194164	-77.6510465	34.7102061
4XctRelV8a	2022-05-29 12:36:27.421+00	2022-05-29 12:36:27.521+00	\N	\N	(20.3844272,44.71335965)	cukarica urban municipality	central serbia	rs	t	20.2875665	44.7968791	20.4812879	44.6298402
ZmpUaLWhyj	2022-05-29 12:36:27.836+00	2022-05-29 12:36:27.936+00	\N	\N	(-93.63583374999999,43.251741800000005)	forest city	ia	us	t	-93.656252	43.278601	-93.6154155	43.2248826
8RO95Q7R3h	2022-05-29 12:36:28.182+00	2022-05-29 12:36:28.282+00	\N	\N	(-122.62217085,53.17288475)	area b (quesnel west/bouchie lake)	bc	ca	t	-122.9129089	53.3923282	-122.3314328	52.9534413
wECan34qhH	2022-05-29 12:36:28.628+00	2022-05-29 12:36:28.728+00	\N	\N	(-73.64805849999999,40.799161999999995)	roslyn	ny	us	t	-73.65915	40.806965	-73.636967	40.791359
zSTMyUU2sV	2022-05-29 12:36:29.143+00	2022-05-29 12:36:29.243+00	\N	\N	(-122.33493899999999,37.37809875)	san mateo county	ca	us	t	-122.588177	37.7082836	-122.081701	37.0479139
BnZSSdUZ71	2022-05-29 12:36:29.805+00	2022-05-29 12:36:29.904+00	\N	\N	(-6.35862995,36.67195075)	rota	andalusia	es	t	-6.4211139	36.7335099	-6.296146	36.6103916
nCb0e0lRJ2	2022-05-29 12:36:30.157+00	2022-05-29 12:36:30.257+00	\N	\N	(-90.78636755,35.01223395)	forrest city	ar	us	t	-90.8271281	35.0605107	-90.745607	34.9639572
82SmIJhZZv	2022-05-29 12:36:30.493+00	2022-05-29 12:36:30.592+00	\N	\N	(-71.90530634999999,41.36688945)	stonington	ct	us	t	-71.9812477	41.4337361	-71.829365	41.3000428
6lG7CdKoF9	2022-05-29 12:36:30.889+00	2022-05-29 12:36:30.989+00	\N	\N	(-86.4684009,40.05161285)	boone county	in	us	t	-86.696053	40.180819	-86.2407488	39.9224067
3PRHmqtEm8	2022-05-29 12:36:31.448+00	2022-05-29 12:36:31.537+00	\N	\N	(-97.856345,34.532731)	duncan	ok	us	t	-98.054676	34.637953	-97.658014	34.427509
EamDcLLOrd	2022-05-29 12:36:31.799+00	2022-05-29 12:36:31.899+00	\N	\N	(-82.2066995,31.366765)	pierce county	ga	us	t	-82.420952	31.530813	-81.992447	31.202717
JCNhjRPrQw	2022-05-29 12:36:32.083+00	2022-05-29 12:36:32.183+00	\N	\N	(-84.98652935000001,10.58749425)	tierras morenas	50806	cr	t	-85.0468285	10.6523748	-84.9262302	10.5226137
2UEIFv9z9k	2022-05-29 12:36:32.608+00	2022-05-29 12:36:32.708+00	\N	\N	(75.19642705,33.212575099999995)	ramban	jk	in	t	75.0179314	33.3582409	75.3749227	33.0669093
9J58vVkv4B	2022-05-29 12:36:32.949+00	2022-05-29 12:36:33.045+00	\N	\N	(-74.82480699999999,39.7324495)	waterford township	nj	us	t	-74.913305	39.790797	-74.736309	39.674102
cFPasmtpKS	2022-05-29 12:36:33.653+00	2022-05-29 12:36:33.754+00	\N	\N	(-81.5682685,30.62784765)	yulee	fl	us	t	-81.622611	30.6865073	-81.513926	30.569188
s1EQ5yJjYg	2022-05-29 12:36:34.066+00	2022-05-29 12:36:34.165+00	\N	\N	(-79.5067723,8.9871932)	san francisco	panamá	pa	t	-79.5195696	9.0085418	-79.493975	8.9658446
WFcFBuatiV	2022-05-29 12:36:34.399+00	2022-05-29 12:36:34.498+00	\N	\N	(-95.4016115,37.925780849999995)	iola	ks	us	t	-95.423441	37.9514287	-95.379782	37.900133
uAo0x6io6m	2022-05-29 12:36:34.904+00	2022-05-29 12:36:34.99+00	\N	\N	(-116.62705715000001,31.79905475)	ensenada	bcn	mx	t	-116.7568468	31.9462343	-116.4972675	31.6518752
d27sYPCDib	2022-05-29 12:36:44.13+00	2022-05-29 12:36:44.225+00	\N	\N	(-97.40847160000001,35.9445482)	logan county	ok	us	t	-97.67646	36.1647165	-97.1404832	35.7243799
Znr6PxrCaE	2022-05-29 12:36:44.46+00	2022-05-29 12:36:44.56+00	\N	\N	(-93.52254205,47.23871715)	grand rapids	mn	us	t	-93.5767632	47.2822912	-93.4683209	47.1951431
vZmC5S2EI4	2022-05-29 12:36:44.905+00	2022-05-29 12:36:45.004+00	\N	\N	(-79.54378,34.6666075)	mccoll	sc	us	t	-79.555697	34.675387	-79.531863	34.657828
6dSccsZMUu	2022-05-29 12:36:45.24+00	2022-05-29 12:36:45.34+00	\N	\N	(-79.67162239999999,41.628539849999996)	titusville	pa	us	t	-79.6991898	41.6398879	-79.644055	41.6171918
CQomFE0DFQ	2022-05-29 12:36:45.651+00	2022-05-29 12:36:45.745+00	\N	\N	(-77.29543065,39.09016245)	darnestown	md	us	t	-77.3435754	39.134033	-77.2472859	39.0462919
HPEox5xbEr	2022-05-29 12:36:46.409+00	2022-05-29 12:36:46.505+00	\N	\N	(-81.0715635,31.971394500000002)	chatham county	ga	us	t	-81.391698	32.237591	-80.751429	31.705198
aZsQrq6XFm	2022-05-29 12:36:47.115+00	2022-05-29 12:36:47.214+00	\N	\N	(-77.39376899999999,34.726824)	jacksonville	nc	us	t	-77.479674	34.815329	-77.307864	34.638319
lBYD1KMR1H	2022-05-29 12:36:47.413+00	2022-05-29 12:36:47.512+00	\N	\N	(20.96881295,-18.4939472)		ke	na	t	19.4375364	-17.821016	22.5000895	-19.1668784
JZwNEfJD2H	2022-05-29 12:36:48.183+00	2022-05-29 12:36:48.284+00	\N	\N	(-73.83478149999999,42.8540705)	town of clifton park	ny	us	t	-73.900815	42.929313	-73.768748	42.778828
OOYlXyUIfl	2022-05-29 12:36:48.755+00	2022-05-29 12:36:48.854+00	\N	\N	(-77.20751824999999,39.14433755)	montgomery county	md	us	t	-77.527376	39.354324	-76.8876605	38.9343511
pOgw9q3LPE	2022-05-29 12:36:49.551+00	2022-05-29 12:36:49.65+00	\N	\N	(-79.87514955,40.5666652)	indiana township	pa	us	t	-79.938858	40.5991154	-79.8114411	40.534215
HB6MMdRMpe	2022-05-29 12:36:49.883+00	2022-05-29 12:36:49.977+00	\N	\N	(-109.27116910000001,33.1024909)	greenlee county	az	us	t	-109.4957742	33.778748	-109.046564	32.4262338
hPEffl1kGl	2022-05-29 12:36:50.242+00	2022-05-29 12:36:50.331+00	\N	\N	(-73.5879099,40.7863675)	old westbury	ny	us	t	-73.625106	40.816194	-73.5507138	40.756541
qh7mV5khrw	2022-05-29 12:36:50.571+00	2022-05-29 12:36:50.667+00	\N	\N	(-86.7190065,41.600001)	la porte	in	us	t	-86.764498	41.639249	-86.673515	41.560753
w8zp6MijD1	2022-05-29 12:36:50.98+00	2022-05-29 12:36:51.08+00	\N	\N	(-71.324267,41.486045700000005)	newport	ri	us	t	-71.363448	41.5231244	-71.285086	41.448967
epojqJPDZP	2022-05-29 12:36:51.447+00	2022-05-29 12:36:51.538+00	\N	\N	(-87.77790425,34.73344595)	colbert county	al	us	t	-88.1399028	34.9073934	-87.4159057	34.5594985
uGYFRUjEVA	2022-05-29 12:36:51.75+00	2022-05-29 12:36:51.851+00	\N	\N	(-75.959236,41.1648766)	luzerne county	pa	us	t	-76.319878	41.4276139	-75.598594	40.9021393
45FEQAEHFV	2022-05-29 12:36:52.156+00	2022-05-29 12:36:52.255+00	\N	\N	(-89.277914,39.5296425)	taylorville	il	us	t	-89.337651	39.596916	-89.218177	39.462369
PMrbFu0Ftc	2022-05-29 12:36:52.603+00	2022-05-29 12:36:52.692+00	\N	\N	(3.34728665,6.52903715)	mushin	la	ng	t	3.3236234	6.5583227	3.3709499	6.4997516
VnRMdHipyT	2022-05-29 12:36:53.119+00	2022-05-29 12:36:53.215+00	\N	\N	(-90.48602005000001,41.4696541)	moline	il	us	t	-90.5399416	41.5183246	-90.4320985	41.4209836
k5yiQkvk8v	2022-05-29 12:36:53.505+00	2022-05-29 12:36:53.605+00	\N	\N	(-87.04976500000001,30.659158249999997)	santa rosa county	fl	us	t	-87.313838	30.9995925	-86.785692	30.318724
3HnEUkHp3h	2022-05-29 12:36:53.921+00	2022-05-29 12:36:54.002+00	\N	\N	(-91.8482166,44.268087)	town of belvidere	wi	us	t	-91.9237139	44.3348187	-91.7727193	44.2013553
ZFnALip1oH	2022-05-29 12:36:54.203+00	2022-05-29 12:36:54.302+00	\N	\N	(45.05377895,37.5460973)	urmia	west azerbaijan province	ir	t	44.9788421	37.6014276	45.1287158	37.490767
GD1IFe31db	2022-05-29 12:36:54.773+00	2022-05-29 12:36:54.873+00	\N	\N	(-84.6140065,38.865517999999994)	walton	ky	us	t	-84.640575	38.889266	-84.587438	38.84177
IMHwELg9CQ	2022-05-29 12:36:55.12+00	2022-05-29 12:36:55.22+00	\N	\N	(-122.9645981,44.0592357)	springfield	or	us	t	-123.0501425	44.094935	-122.8790537	44.0235364
oW5Oh0eX4A	2022-05-29 12:36:55.564+00	2022-05-29 12:36:55.664+00	\N	\N	(-87.94175095,41.96205500000001)	bensenville	il	us	t	-87.9688184	41.993371	-87.9146835	41.930739
HuZO5inx0J	2022-05-29 12:36:55.897+00	2022-05-29 12:36:55.998+00	\N	\N	(25.96678665,44.45031335)	chiajna		ro	t	25.9126255	44.4731642	26.0209478	44.4274625
tamDLoKec9	2022-05-29 12:37:01.174+00	2022-05-29 12:37:01.259+00	\N	\N	(77.8902124,29.8693496)	roorkee	ut	in	t	77.7302124	30.0293496	78.0502124	29.7093496
5SquB7tcfg	2022-05-29 12:37:01.495+00	2022-05-29 12:37:01.595+00	\N	\N	(-73.50263029999999,44.777448050000004)	beekmantown	ny	us	t	-73.672063	44.8278941	-73.3331976	44.727002
H3RloZ9jSB	2022-05-29 12:37:01.944+00	2022-05-29 12:37:02.043+00	\N	\N	(-78.2160775,40.892765)	philipsburg	pa	us	t	-78.227482	40.906369	-78.204673	40.879161
nnJzx4yV7P	2022-05-29 12:37:02.519+00	2022-05-29 12:37:02.614+00	\N	\N	(-123.9016448,46.986697500000005)	hoquiam	wa	us	t	-123.951386	47.021877	-123.8519036	46.951518
hcxwWDTDs1	2022-05-29 12:37:02.814+00	2022-05-29 12:37:02.912+00	\N	\N	(-89.996022,38.5187105)	belleville	il	us	t	-90.086874	38.590815	-89.90517	38.446606
qClJmUOYcZ	2022-05-29 12:37:03.296+00	2022-05-29 12:37:03.396+00	\N	\N	(-73.75469815,41.0261205)	white plains	ny	us	t	-73.7898554	41.069796	-73.7195409	40.982445
IQ6I3CUF2H	2022-05-29 12:37:03.716+00	2022-05-29 12:37:03.812+00	\N	\N	(-81.744867,29.582303)	putnam county	fl	us	t	-82.056151	29.840176	-81.433583	29.32443
IwoOkzYv44	2022-05-29 12:36:56.369+00	2022-05-29 12:36:56.468+00	\N	\N	(-121.2509422,37.89096935)	san joaquin county	ca	us	t	-121.5848663	38.3001213	-120.9170181	37.4818174
R6DwvY4qIj	2022-05-29 12:36:56.895+00	2022-05-29 12:36:56.995+00	\N	\N	(-1.3386649,54.250429600000004)	hambleton	eng	gb	t	-1.7052533	54.511984	-0.9720765	53.9888752
amF13Hxn2p	2022-05-29 12:36:57.265+00	2022-05-29 12:36:57.366+00	\N	\N	(-79.73392095,36.502093849999994)	eden	nc	us	t	-79.7881279	36.533787	-79.679714	36.4704007
EhN8PtIfOY	2022-05-29 12:36:57.66+00	2022-05-29 12:36:57.758+00	\N	\N	(-82.92973515,39.60638325)	circleville	oh	us	t	-82.9625131	39.6396066	-82.8969572	39.5731599
KAIjWd2xn5	2022-05-29 12:36:58.055+00	2022-05-29 12:36:58.153+00	\N	\N	(-112.81622055,39.66306955)	juab county	ut	us	t	-114.047649	40.011656	-111.5847921	39.3144831
JrJTx8ies1	2022-05-29 12:36:58.345+00	2022-05-29 12:36:58.445+00	\N	\N	(-85.72916405000001,10.21625375)	veintisiete de abril	50303	cr	t	-85.837557	10.3116475	-85.6207711	10.12086
xhrgeMZx0m	2022-05-29 12:36:58.724+00	2022-05-29 12:36:58.819+00	\N	\N	(-74.90428845,38.9823619)	lower township	nj	us	t	-74.9777079	39.0392588	-74.830869	38.925465
qTZDOjlMTA	2022-05-29 12:36:59.644+00	2022-05-29 12:36:59.743+00	\N	\N	(-121.5729219,39.72373805)	butte county	ca	us	t	-122.0692552	40.1517198	-121.0765886	39.2957563
tchbjXAqpU	2022-05-29 12:37:00.243+00	2022-05-29 12:37:00.346+00	\N	\N	(8.6290285,50.2607742)	friedrichsdorf	hesse	de	t	8.5681395	50.2902557	8.6899175	50.2312927
Tt8B9W9jMn	2022-05-29 12:37:00.63+00	2022-05-29 12:37:00.73+00	\N	\N	(-96.910485,46.85507)	west fargo	nd	us	t	-96.95935	46.906196	-96.86162	46.803944
tHdqlCEKbD	2022-05-29 12:37:04.084+00	2022-05-29 12:37:04.183+00	\N	\N	(6.88127755,6.3145888)	anambra east	an	ng	t	6.7812004	6.4398394	6.9813547	6.1893382
tx6aiBvJOh	2022-05-29 12:37:04.453+00	2022-05-29 12:37:04.552+00	\N	\N	(-70.22532575,42.047817499999994)	provincetown	ma	us	t	-70.3120567	42.1336459	-70.1385948	41.9619891
OLwMh7MtrG	2022-05-29 12:37:04.877+00	2022-05-29 12:37:04.971+00	\N	\N	(-2.30875525,53.589542949999995)	bury	eng	gb	t	-2.3834089	53.6670647	-2.2341016	53.5120212
2qSwM80fG0	2022-05-29 12:37:05.447+00	2022-05-29 12:37:05.545+00	\N	\N	(76.58019350000001,28.9010899)	rohtak	hr	in	t	76.4201935	29.0610899	76.7401935	28.7410899
5RsDg9VH5I	2022-05-29 12:37:05.986+00	2022-05-29 12:37:06.083+00	\N	\N	(-112.16153,43.841254)	jefferson county	id	us	t	-112.697122	44.059368	-111.625938	43.62314
naaHzfEV0D	2022-05-29 12:37:06.307+00	2022-05-29 12:37:06.406+00	\N	\N	(-87.213087,36.1052065)	white bluff	tn	us	t	-87.253531	36.131103	-87.172643	36.07931
8KBlV8I0EL	2022-05-29 12:37:06.58+00	2022-05-29 12:37:06.68+00	\N	\N	(-93.47895135,41.64410195)	altoona	ia	us	t	-93.5224019	41.6803123	-93.4355008	41.6078916
OjovwaJGsL	2022-05-29 12:37:07.001+00	2022-05-29 12:37:07.101+00	\N	\N	(74.1933745,32.1525312)	gujranwala	pb	pk	t	74.0333745	32.3125312	74.3533745	31.9925312
wMtHK4hmWg	2022-05-29 12:37:07.465+00	2022-05-29 12:37:07.565+00	\N	\N	(-123.47628130000001,39.380294500000005)	mendocino county	ca	us	t	-124.134889	40.00247	-122.8176736	38.758119
7tG6ARJ4OO	2022-05-29 12:37:07.778+00	2022-05-29 12:37:07.878+00	\N	\N	(-87.34396079999999,36.560202849999996)	clarksville	tn	us	t	-87.482366	36.6417648	-87.2055556	36.4786409
UuAhUaLYvO	2022-05-29 12:37:08.14+00	2022-05-29 12:37:08.24+00	\N	\N	(-86.31971935,34.349722)	marshall county	al	us	t	-86.581749	34.600098	-86.0576897	34.099346
QKBQUDkCjr	2022-05-29 12:37:08.511+00	2022-05-29 12:37:08.602+00	\N	\N	(-81.02294040000001,32.2711714)	hardeeville	sc	us	t	-81.1199783	32.3773368	-80.9259025	32.165006
g2vmOXSRFZ	2022-05-29 12:37:09.105+00	2022-05-29 12:37:09.205+00	\N	\N	(-86.6652515,34.6992935)	huntsville	al	us	t	-86.93117	34.86516	-86.399333	34.533427
tPLTejM58B	2022-05-29 12:37:09.731+00	2022-05-29 12:37:09.83+00	\N	\N	(-80.5818295,34.3418995)	kershaw county	sc	us	t	-80.879425	34.616245	-80.284234	34.067554
VjzZiTCg2z	2022-05-29 12:37:10.117+00	2022-05-29 12:37:10.217+00	\N	\N	(-87.6652245,41.5589325)	homewood	il	us	t	-87.699009	41.579107	-87.63144	41.538758
UE9pzvGTxh	2022-05-29 12:37:10.704+00	2022-05-29 12:37:10.801+00	\N	\N	(-3.2622419000000002,55.9114378)	city of edinburgh	sct	gb	t	-3.4495326	56.0040837	-3.0749512	55.8187919
iIMSdHaIze	2022-05-29 12:37:11.025+00	2022-05-29 12:37:11.124+00	\N	\N	(-88.9494655,36.006977649999996)	gibson county	tn	us	t	-89.206297	36.222834	-88.692634	35.7911213
6fvWwFdsAs	2022-05-29 12:37:11.481+00	2022-05-29 12:37:11.583+00	\N	\N	(3.3864123499999996,6.49280285)	lagos mainland	la	ng	t	3.3628218	6.5223884	3.4100029	6.4632173
m6SasDEW21	2022-05-29 12:37:11.975+00	2022-05-29 12:37:12.074+00	\N	\N	(-88.838871,35.648476)	jackson	tn	us	t	-88.921087	35.756726	-88.756655	35.540226
0R6g97oN3F	2022-05-29 12:37:12.356+00	2022-05-29 12:37:12.456+00	\N	\N	(-106.06661349999999,35.00882475)	moriarty	nm	us	t	-106.120663	35.035184	-106.012564	34.9824655
m7YVXKMSSg	2022-05-29 12:37:12.68+00	2022-05-29 12:37:12.783+00	\N	\N	(6.00775275,49.5320454)	mondercange		lu	t	5.9530067	49.5528782	6.0624988	49.5112126
5wW9Okdza4	2022-05-29 12:37:13.035+00	2022-05-29 12:37:13.134+00	\N	\N	(-81.80988925,27.186201500000003)	desoto county	fl	us	t	-82.0575825	27.340702	-81.562196	27.031701
aWQkCAOVaK	2022-05-29 12:37:13.363+00	2022-05-29 12:37:13.444+00	\N	\N	(-82.65365785,42.28173185)	lakeshore	on	ca	t	-82.8774101	42.3981039	-82.4299056	42.1653598
xCX8D219Pm	2022-05-29 12:37:13.789+00	2022-05-29 12:37:13.885+00	\N	\N	(22.98893945,40.658635849999996)	pefka municipal unit	macedonia and thrace	gr	t	22.9682715	40.6725442	23.0096074	40.6447275
Tb2TZj0ntY	2022-05-29 12:37:14.321+00	2022-05-29 12:37:14.419+00	\N	\N	(5.19888285,7.51484965)	ikere	ek	ng	t	5.0847464	7.5962591	5.3130193	7.4334402
8rDD7SFdBN	2022-05-29 12:37:14.626+00	2022-05-29 12:37:14.725+00	\N	\N	(-13.957883800000001,28.49852865)	puerto del rosario		es	t	-14.0902188	28.5772015	-13.8255488	28.4198558
gZvSlF3zYF	2022-05-29 12:37:15.01+00	2022-05-29 12:37:15.107+00	\N	\N	(-74.728703,45.0184417)	cornwall	on	ca	t	-74.888703	45.1784417	-74.568703	44.8584417
hp47ICkN4z	2022-05-29 12:37:15.415+00	2022-05-29 12:37:15.516+00	\N	\N	(-93.57877635,44.54698445)	new prague	mn	us	t	-93.6054394	44.56423	-93.5521133	44.5297389
z0ApLNKKJu	2022-05-29 12:37:15.949+00	2022-05-29 12:37:16.048+00	\N	\N	(2.02028755,42.5103114)	font-romeu-odeillo-via	occitania	fr	t	1.9693104	42.5453398	2.0712647	42.475283
t0C70zhcHp	2022-05-29 12:37:16.36+00	2022-05-29 12:37:16.46+00	\N	\N	(-76.41371000000001,42.657028499999996)	town of locke	ny	us	t	-76.462597	42.695516	-76.364823	42.618541
8hQVZEwwSe	2022-05-29 12:37:16.83+00	2022-05-29 12:37:16.93+00	\N	\N	(27.7383175,-25.43057)	madibeng local municipality	north west	za	t	27.424235	-24.96652	28.0524	-25.89462
WGIVE4oQpN	2022-05-29 12:37:17.224+00	2022-05-29 12:37:17.324+00	\N	\N	(-77.2130085,39.89480105)	adams county	pa	us	t	-77.471085	40.0698359	-76.954932	39.7197662
YWqlJ8KMHo	2022-05-29 12:37:17.608+00	2022-05-29 12:37:17.707+00	\N	\N	(-82.8752175,36.170435)	greene county	tn	us	t	-83.173309	36.419056	-82.577126	35.921814
ZNzgfp8QbE	2022-05-29 12:37:18.013+00	2022-05-29 12:37:18.113+00	\N	\N	(-84.63053099999999,35.441407999999996)	mcminn county	tn	us	t	-84.859962	35.644951	-84.4011	35.237865
zviyfHgEoL	2022-05-29 12:37:18.523+00	2022-05-29 12:37:18.613+00	\N	\N	(6.827966549999999,51.8532975)	borken	north rhine-westphalia	de	t	6.7323128	51.9328675	6.9236203	51.7737275
6Y6efojGN2	2022-05-29 12:37:19.019+00	2022-05-29 12:37:19.115+00	\N	\N	(-73.5612935,40.7452415)	salisbury	ny	us	t	-73.5796713	40.7566859	-73.5429157	40.7337971
ntDZGmlvwL	2022-05-29 12:37:19.478+00	2022-05-29 12:37:19.58+00	\N	\N	(-111.6389172,40.2573)	provo	ut	us	t	-111.740962	40.328801	-111.5368724	40.185799
DfGpvSYsQn	2022-05-29 12:37:19.933+00	2022-05-29 12:37:20.015+00	\N	\N	(-111.96852565,41.076624699999996)	layton	ut	us	t	-112.0358598	41.1165661	-111.9011915	41.0366833
ATgC8upVdn	2022-05-29 12:37:20.273+00	2022-05-29 12:37:20.372+00	\N	\N	(-86.6332433,34.01286055)	blount county	al	us	t	-86.9634316	34.2603671	-86.303055	33.765354
wwwC0lkarU	2022-05-29 12:37:20.698+00	2022-05-29 12:37:20.798+00	\N	\N	(7.91473415,4.9900749)	uyo	ak	ng	t	7.7943082	5.1034608	8.0351601	4.876689
V7QwvixTNL	2022-05-29 12:37:21.209+00	2022-05-29 12:37:21.309+00	\N	\N	(-107.79717885,50.2916769)	swift current	sk	ca	t	-107.8380701	50.3245594	-107.7562876	50.2587944
b7COaVynpK	2022-05-29 12:37:21.525+00	2022-05-29 12:37:21.623+00	\N	\N	(-88.11820545,45.7791478)	town of aurora	wi	us	t	-88.1781579	45.8453324	-88.058253	45.7129632
JqeSbx3NeU	2022-05-29 12:37:21.909+00	2022-05-29 12:37:22.009+00	\N	\N	(-111.81027785,41.92547065)	richmond	ut	us	t	-111.8291343	41.9471368	-111.7914214	41.9038045
zemqwFbDVF	2022-05-29 12:37:22.383+00	2022-05-29 12:37:22.483+00	\N	\N	(-93.48005355000001,44.765249499999996)	shakopee	mn	us	t	-93.561362	44.812818	-93.3987451	44.717681
nBwJytinvc	2022-05-29 12:37:22.711+00	2022-05-29 12:37:22.811+00	\N	\N	(-105.61273969999999,41.306616399999996)	laramie	wy	us	t	-105.6972892	41.335813	-105.5281902	41.2774198
IFxvGe0Yty	2022-05-29 12:37:23.011+00	2022-05-29 12:37:23.108+00	\N	\N	(-83.577649,35.795448)	pigeon forge	tn	us	t	-83.640886	35.828803	-83.514412	35.762093
D6rw2Jd5YJ	2022-05-29 12:37:23.538+00	2022-05-29 12:37:23.638+00	\N	\N	(115.33413095,-33.657752450000004)	city of busselton	wa	au	t	114.9007889	-33.4757719	115.767473	-33.839733
Z8nDPwJvLY	2022-05-29 12:37:23.946+00	2022-05-29 12:37:24.045+00	\N	\N	(-83.3891519,33.94374345)	athens	ga	us	t	-83.5374696	34.039466	-83.2408342	33.8480209
bBoetC8T39	2022-05-29 12:37:24.51+00	2022-05-29 12:37:24.604+00	\N	\N	(-77.2423378,40.136763349999995)	cumberland county	pa	us	t	-77.627552	40.3294497	-76.8571236	39.944077
r6kvvy64st	2022-05-29 12:37:24.894+00	2022-05-29 12:37:24.993+00	\N	\N	(-84.7297892,44.55485555)	beaver creek township	mi	us	t	-84.8508618	44.5989651	-84.6087166	44.510746
BDJU34w74b	2022-05-29 12:37:25.615+00	2022-05-29 12:37:25.715+00	\N	\N	(-104.5620751,38.824447750000004)	el paso county	co	us	t	-105.072529	39.129876	-104.0516212	38.5190195
1FvS2lEpcv	2022-05-29 12:37:26.043+00	2022-05-29 12:37:26.142+00	\N	\N	(-77.91609414999999,39.52043465)	washington county	md	us	t	-78.3633135	39.7225773	-77.4688748	39.318292
oTR5kx2HIp	2022-05-29 12:37:26.472+00	2022-05-29 12:37:26.572+00	\N	\N	(31.1822563,-23.680578699999998)	ba-phalaborwa local municipality	lp	za	t	30.48012	-23.2151794	31.8843926	-24.145978
f6DKnAL3Sf	2022-05-29 12:37:26.772+00	2022-05-29 12:37:26.871+00	\N	\N	(-89.61550935,44.91616615)	schofield	wi	us	t	-89.641122	44.9308643	-89.5898967	44.901468
D4SCZHB0AW	2022-05-29 12:37:27.273+00	2022-05-29 12:37:27.373+00	\N	\N	(-74.93970494999999,46.60723635)	laurentides	qc	ca	t	-76.1492607	47.7645752	-73.7301492	45.4498975
k5K79T1pep	2022-05-29 12:37:30.781+00	2022-05-29 12:37:30.881+00	\N	\N	(-94.0398255,34.05161205)	howard county	ar	us	t	-94.259163	34.355511	-93.820488	33.7477131
kaMreQkX3n	2022-05-29 12:37:31.423+00	2022-05-29 12:37:31.522+00	\N	\N	(-75.14092339999999,39.5283564)	pittsgrove township	nj	us	t	-75.2199505	39.5991338	-75.0618963	39.457579
kaBhtJCnio	2022-05-29 12:37:31.919+00	2022-05-29 12:37:32.019+00	\N	\N	(-83.31485334999999,42.293498)	inkster	mi	us	t	-83.3399307	42.312051	-83.289776	42.274945
hewqPeyNlt	2022-05-29 12:37:32.314+00	2022-05-29 12:37:32.414+00	\N	\N	(-105.1049419,40.0024894)	lafayette	co	us	t	-105.157078	40.047173	-105.0528058	39.9578058
Rkg8sCxEyM	2022-05-29 12:37:32.711+00	2022-05-29 12:37:32.811+00	\N	\N	(-84.0698056,9.9560369)	anselmo llorente	11303	cr	t	-84.0785702	9.9625574	-84.061041	9.9495164
FgCmsSvntG	2022-05-29 12:37:33.066+00	2022-05-29 12:37:33.155+00	\N	\N	(-89.8403843,34.9566004)	olive branch	ms	us	t	-89.9213286	34.9947668	-89.75944	34.918434
cCxrrBPfsC	2022-05-29 12:37:33.653+00	2022-05-29 12:37:33.749+00	\N	\N	(10.179495849999999,48.9648863)	ellwangen (jagst)	bw	de	t	10.0515584	49.0255744	10.3074333	48.9041982
HGKvT3ok6q	2022-05-29 12:37:33.962+00	2022-05-29 12:37:34.062+00	\N	\N	(-85.97987140000001,43.5106421)	dayton township	mi	us	t	-86.0397845	43.5540682	-85.9199583	43.467216
J5uLGtbDEM	2022-05-29 12:37:34.439+00	2022-05-29 12:37:34.534+00	\N	\N	(-1.8812451499999998,52.4948794)	birmingham	eng	gb	t	-2.0336486	52.6087058	-1.7288417	52.381053
5nGEsLd4n1	2022-05-29 12:37:34.944+00	2022-05-29 12:37:35.032+00	\N	\N	(35.0148555,32.800326299999995)	haifa	haifa district	il	t	34.9499666	32.8427003	35.0797444	32.7579523
GFsE6REXP3	2022-05-29 12:37:35.396+00	2022-05-29 12:37:35.486+00	\N	\N	(-99.204926,26.947708)	zapata county	tx	us	t	-99.4556178	27.3191317	-98.9542342	26.5762843
KVapiQKvwf	2022-05-29 12:37:35.901+00	2022-05-29 12:37:36.003+00	\N	\N	(-80.6865415,28.306727)	brevard county	fl	us	t	-80.988014	28.791396	-80.385069	27.822058
2oXgit973X	2022-05-29 12:37:36.716+00	2022-05-29 12:37:36.816+00	\N	\N	(-70.52840710000001,19.2237411)	la vega	la vega	do	t	-70.6884071	19.3837411	-70.3684071	19.0637411
Lmb8zvDHNd	2022-05-29 12:37:37.336+00	2022-05-29 12:37:37.432+00	\N	\N	(77.622077,12.988838699999999)	bengaluru	ka	in	t	77.4601025	13.1436649	77.7840515	12.8340125
EiQ8ag4der	2022-05-29 12:37:37.728+00	2022-05-29 12:37:37.828+00	\N	\N	(-94.1070071,33.44667715)	texarkana	tx	us	t	-94.1709726	33.5119622	-94.0430416	33.3813921
Rt5vdKZ18k	2022-05-29 12:37:38.118+00	2022-05-29 12:37:38.219+00	\N	\N	(-90.7388435,30.82451065)	saint helena parish	la	us	t	-90.9118989	30.9996962	-90.5657881	30.6493251
vz5kAcNGrF	2022-05-29 12:37:38.501+00	2022-05-29 12:37:38.601+00	\N	\N	(-116.682526,47.6788037)	kootenai county	id	us	t	-117.042657	47.9915469	-116.322395	47.3660605
ARvAVUW2Ko	2022-05-29 12:37:38.996+00	2022-05-29 12:37:39.095+00	\N	\N	(67.1065026,24.929698350000002)	gulshan town	sd	pk	t	67.0437812	24.9918617	67.169224	24.867535
nVhEq6RMVu	2022-05-29 12:37:39.334+00	2022-05-29 12:37:39.434+00	\N	\N	(-77.65468584999999,39.933226)	chambersburg	pa	us	t	-77.6856817	39.960649	-77.62369	39.905803
HGApoYRITP	2022-05-29 12:37:39.744+00	2022-05-29 12:37:39.845+00	\N	\N	(0.39833995,51.10252855)	tunbridge wells	eng	gb	t	0.1500363	51.2016189	0.6466436	51.0034382
18iwZyY8KK	2022-05-29 12:37:40.315+00	2022-05-29 12:37:40.415+00	\N	\N	(-89.5009439,31.20821395)	lamar county	ms	us	t	-89.6542669	31.433977	-89.3476209	30.9824509
ZAvDsZTjOP	2022-05-29 12:37:40.7+00	2022-05-29 12:37:40.786+00	\N	\N	(23.0707469,47.19032765)	zalău		ro	t	23.0268904	47.225799	23.1146034	47.1548563
qjqcZx6aRc	2022-05-29 12:37:41.289+00	2022-05-29 12:37:41.388+00	\N	\N	(-95.94005250000001,41.14202485)	bellevue	ne	us	t	-96.009261	41.1912712	-95.870844	41.0927785
4GGmZpDTg4	2022-05-29 12:37:41.647+00	2022-05-29 12:37:41.744+00	\N	\N	(-95.58591465,33.168601949999996)	hopkins county	tx	us	t	-95.8638157	33.3768361	-95.3080136	32.9603678
V358I30qxs	2022-05-29 12:37:41.978+00	2022-05-29 12:37:42.079+00	\N	\N	(-86.11535245,38.19068695)	harrison county	in	us	t	-86.3310919	38.422685	-85.899613	37.9586889
VFRFUz1D2Z	2022-05-29 12:37:42.416+00	2022-05-29 12:37:42.515+00	\N	\N	(-95.3450375,37.924794500000004)	gas	ks	us	t	-95.354324	37.932932	-95.335751	37.916657
OqtcFVNBKB	2022-05-29 12:37:42.945+00	2022-05-29 12:37:43.045+00	\N	\N	(-83.2525682,30.8279605)	lowndes county	ga	us	t	-83.4849285	31.031954	-83.0202079	30.623967
IsWfr2SFYw	2022-05-29 12:37:43.397+00	2022-05-29 12:37:43.497+00	\N	\N	(-95.0681065,33.610373)	clarksville	tx	us	t	-95.10161	33.627031	-95.034603	33.593715
43if21KFC3	2022-05-29 12:37:43.749+00	2022-05-29 12:37:43.849+00	\N	\N	(-48.485796449999995,-27.613)	florianópolis	sc	br	t	-48.613	-27.379	-48.3585929	-27.847
wmM6GW5W2P	2022-05-29 12:37:44.248+00	2022-05-29 12:37:44.348+00	\N	\N	(-121.04420675,39.2189439)	grass valley	ca	us	t	-121.0828217	39.2440784	-121.0055918	39.1938094
8wNfDyiuKU	2022-05-29 12:37:44.625+00	2022-05-29 12:37:44.724+00	\N	\N	(-78.858739,42.896227499999995)	buffalo	ny	us	t	-78.922357	42.966449	-78.795121	42.826006
iTuQ7tIdUC	2022-05-29 12:37:44.964+00	2022-05-29 12:37:45.065+00	\N	\N	(-81.10974300000001,32.8678245)	hampton	sc	us	t	-81.134344	32.891678	-81.085142	32.843971
0c1AvU3Mgu	2022-05-29 12:37:45.404+00	2022-05-29 12:37:45.489+00	\N	\N	(-70.40555725,43.79199725)	windham	me	us	t	-70.486735	43.886583	-70.3243795	43.6974115
LUoXSf2q6f	2022-05-29 12:37:45.935+00	2022-05-29 12:37:46.035+00	\N	\N	(11.54184345,48.1548703)	munich	bavaria	de	t	11.360777	48.2481162	11.7229099	48.0616244
LAHZBoSLpC	2022-05-29 12:37:46.507+00	2022-05-29 12:37:46.607+00	\N	\N	(-72.91332685,41.3956496)	hamden	ct	us	t	-72.9752937	41.4641042	-72.85136	41.327195
SMaFOVxxdM	2022-05-29 12:37:46.911+00	2022-05-29 12:37:47.012+00	\N	\N	(-85.7743196,39.54609415)	shelbyville	in	us	t	-85.8286092	39.5987493	-85.72003	39.493439
RhyCpJy0B2	2022-05-29 12:37:47.444+00	2022-05-29 12:37:47.544+00	\N	\N	(-89.5813175,36.895062499999995)	sikeston	mo	us	t	-89.635956	36.939986	-89.526679	36.850139
2OA1wcvKA8	2022-05-29 12:37:47.842+00	2022-05-29 12:37:47.939+00	\N	\N	(-1.4118563499999999,53.65857985)	wakefield	eng	gb	t	-1.6248982	53.7418108	-1.1988145	53.5753489
dD4B1OuwNB	2022-05-29 12:37:48.231+00	2022-05-29 12:37:48.327+00	\N	\N	(-123.75617299999999,46.03308145)	clatsop county	or	us	t	-124.1536	46.2928325	-123.358746	45.7733304
Y4satCIg8z	2022-05-29 12:37:48.741+00	2022-05-29 12:37:48.841+00	\N	\N	(89.9436684,24.9255866)	jamalpur	mymensingh division	bd	t	89.7836684	25.0855866	90.1036684	24.7655866
j8KdeQC8FA	2022-05-29 12:37:49.261+00	2022-05-29 12:37:49.361+00	\N	\N	(-82.6264975,30.2116605)	columbia county	fl	us	t	-82.800477	30.597734	-82.452518	29.825587
Ux0G5hd4uW	2022-05-29 12:37:49.691+00	2022-05-29 12:37:49.791+00	\N	\N	(24.35294295,46.13594625)	mediaș		ro	t	24.3059515	46.2046137	24.3999344	46.0672788
BtHg76cLNn	2022-05-29 12:37:50.134+00	2022-05-29 12:37:50.234+00	\N	\N	(-86.34833215,40.741185)	logansport	in	us	t	-86.393973	40.775348	-86.3026913	40.707022
aeU351Mqgq	2022-05-29 12:37:50.571+00	2022-05-29 12:37:50.659+00	\N	\N	(-70.93946414999999,42.0804926)	whitman	ma	us	t	-70.976528	42.1001235	-70.9024003	42.0608617
Aodsbfp8D3	2022-05-29 12:37:50.922+00	2022-05-29 12:37:51.022+00	\N	\N	(25.501902899999997,44.843747050000005)	văcărești		ro	t	25.4477788	44.8799549	25.556027	44.8075392
cStJnK8pzf	2022-05-29 12:37:51.294+00	2022-05-29 12:37:51.391+00	\N	\N	(34.12597685,0.44290525000000003)	busia	busia	ke	t	34.0968132	0.4705205	34.1551405	0.41529
kTmkTdUK3F	2022-05-29 12:37:51.729+00	2022-05-29 12:37:51.829+00	\N	\N	(-82.4737195,40.3785565)	mount vernon	oh	us	t	-82.517196	40.419255	-82.430243	40.337858
BQ5n8yRsA2	2022-05-29 12:37:52.153+00	2022-05-29 12:37:52.242+00	\N	\N	(17.1133859,-22.87723525)		kh	na	t	15.7240223	-21.7084606	18.5027495	-24.0460099
ZOZJ1PWjlK	2022-05-29 12:37:52.511+00	2022-05-29 12:37:52.603+00	\N	\N	(7.6702945499999995,51.581764)	kamen	north rhine-westphalia	de	t	7.5902989	51.6150198	7.7502902	51.5485082
GCOHFpYW8A	2022-05-29 12:37:52.978+00	2022-05-29 12:37:53.075+00	\N	\N	(-72.0281718,41.3385064)	groton	ct	us	t	-72.0972217	41.4004064	-71.9591219	41.2766064
k9QOZDun9S	2022-05-29 12:37:58.387+00	2022-05-29 12:37:58.486+00	\N	\N	(-87.24531999999999,38.062051499999995)	warrick county	in	us	t	-87.473217	38.246077	-87.017423	37.878026
fZAxvcBGES	2022-05-29 12:37:58.748+00	2022-05-29 12:37:58.848+00	\N	\N	(-71.53477985,42.9395756)	bedford	nh	us	t	-71.6171694	42.982799	-71.4523903	42.8963522
8GzYSLzgw7	2022-05-29 12:37:59.121+00	2022-05-29 12:37:59.217+00	\N	\N	(29.52253,-25.830199999999998)	steve tshwete local municipality	mp	za	t	29.1681	-25.40652	29.87696	-26.25388
coSePHoYpR	2022-05-29 12:37:59.488+00	2022-05-29 12:37:59.587+00	\N	\N	(-72.182598,41.70690395)	windham	ct	us	t	-72.2531503	41.7561716	-72.1120457	41.6576363
KqGrYOX2yJ	2022-05-29 12:37:59.783+00	2022-05-29 12:37:59.873+00	\N	\N	(-83.727902,39.6369721)	silvercreek township	oh	us	t	-83.7976806	39.6752813	-83.6581234	39.5986629
hYfA0F8aE2	2022-05-29 12:38:00.277+00	2022-05-29 12:38:00.372+00	\N	\N	(-83.09148655,34.7641159)	oconee county	sc	us	t	-83.3539979	35.0561977	-82.8289752	34.4720341
XN1edHuQwh	2022-05-29 12:38:00.852+00	2022-05-29 12:38:00.951+00	\N	\N	(-120.3302663,47.42402505)	wenatchee	wa	us	t	-120.367718	47.4605568	-120.2928146	47.3874933
az1Gvbr5yV	2022-05-29 12:38:01.1+00	2022-05-29 12:38:01.199+00	\N	\N	(-111.3031114,47.50497445)	great falls	mt	us	t	-111.407472	47.5519561	-111.1987508	47.4579928
L15aWQbYB6	2022-05-29 12:38:01.511+00	2022-05-29 12:38:01.603+00	\N	\N	(115.942181,-31.954277)	city of belmont	wa	au	t	115.89689	-31.919758	115.987472	-31.988796
GJfFm7TorM	2022-05-29 12:38:01.991+00	2022-05-29 12:38:02.091+00	\N	\N	(-89.7409585,31.8704475)	magee	ms	us	t	-89.76945	31.898899	-89.712467	31.841996
EnVJfAmKCD	2022-05-29 12:38:02.579+00	2022-05-29 12:38:02.674+00	\N	\N	(-69.96499854999999,19.5806361)	cabrera	maría trinidad sánchez	do	t	-70.0614954	19.6838965	-69.8685017	19.4773757
efh5bDlfiZ	2022-05-29 12:38:03.002+00	2022-05-29 12:38:03.092+00	\N	\N	(-122.52729149999999,44.497090799999995)	linn county	or	us	t	-123.260836	44.7943356	-121.793747	44.199846
pC7DT0CeSf	2022-05-29 12:38:03.544+00	2022-05-29 12:38:03.641+00	\N	\N	(-83.4523765,43.7297395)	village of sebewaing	mi	us	t	-83.468913	43.740736	-83.43584	43.718743
zbYjOIFUnq	2022-05-29 12:38:04.131+00	2022-05-29 12:38:04.22+00	\N	\N	(-89.4850242,34.74517075)	marshall county	ms	us	t	-89.7243293	34.9952578	-89.2457191	34.4950837
n4q7OJFBhh	2022-05-29 12:38:04.495+00	2022-05-29 12:38:04.595+00	\N	\N	(-111.51300954999999,53.7514573)	county of two hills	ab	ca	t	-112.2334147	53.9767338	-110.7926044	53.5261808
ryeGUEyBsr	2022-05-29 12:38:04.851+00	2022-05-29 12:38:04.951+00	\N	\N	(27.95382885,45.27224795)	brăila		ro	t	27.908531	45.3134918	27.9991267	45.2310041
fBSXl49f72	2022-05-29 12:38:05.211+00	2022-05-29 12:38:05.311+00	\N	\N	(-78.27696755,37.848373699999996)	fluvanna county	va	us	t	-78.4914549	38.0064104	-78.0624802	37.690337
FG3upAi2hq	2022-05-29 12:38:05.605+00	2022-05-29 12:38:05.696+00	\N	\N	(-79.615947,40.3265885)	jeannette	pa	us	t	-79.6364	40.342835	-79.595494	40.310342
ds3Zgh9P8A	2022-05-29 12:37:53.466+00	2022-05-29 12:37:53.563+00	\N	\N	(6.0832869,51.9413654)	zevenaar	ge	nl	t	6.0378965	51.9749818	6.1286773	51.907749
KA3UGZgWjK	2022-05-29 12:37:53.943+00	2022-05-29 12:37:54.043+00	\N	\N	(-71.4413734,42.58998195)	westford	ma	us	t	-71.4980066	42.6537743	-71.3847402	42.5261896
TSUZ0uz3Va	2022-05-29 12:37:54.348+00	2022-05-29 12:37:54.446+00	\N	\N	(-80.7971164,33.4419602)	orangeburg county	sc	us	t	-81.3726878	33.7071871	-80.221545	33.1767333
HGIh5brn45	2022-05-29 12:37:54.894+00	2022-05-29 12:37:54.994+00	\N	\N	(-75.4455925,40.065854900000005)	tredyffrin township	pa	us	t	-75.5302626	40.0971581	-75.3609224	40.0345517
DICPSxEHJI	2022-05-29 12:37:55.264+00	2022-05-29 12:37:55.364+00	\N	\N	(22.58563235,44.673247849999996)	drobeta-turnu severin		ro	t	22.469362	44.7327796	22.7019027	44.6137161
OGqpcoTLWO	2022-05-29 12:37:55.775+00	2022-05-29 12:37:55.873+00	\N	\N	(-84.0486885,33.655915)	rockdale county	ga	us	t	-84.184148	33.786054	-83.913229	33.525776
ea1hwBUXxm	2022-05-29 12:38:06.025+00	2022-06-01 04:13:58.659+00	\N	\N	(-113.642293,35.6053603)	mohave county	az	us	t	-114.755618	37.0008206	-112.528968	34.2099
IUV78ApZsl	2022-05-29 12:37:56.711+00	2022-05-29 12:37:56.811+00	\N	\N	(-83.609625,34.139691)	jefferson	ga	us	t	-83.67439	34.20015	-83.54486	34.079232
6SrNjIEgiQ	2022-05-29 12:37:57.126+00	2022-05-29 12:37:57.224+00	\N	\N	(23.640501999999998,37.9791245)	municipal unit of nikaia	attica	gr	t	23.6103102	37.9965364	23.6706938	37.9617126
BFEnUD98jl	2022-05-29 12:37:57.628+00	2022-05-29 12:37:57.728+00	\N	\N	(-120.60974015,35.105290999999994)	oceano	ca	us	t	-120.6317	35.11532	-120.5877803	35.095262
gDE1Fgzgh2	2022-05-29 12:37:57.931+00	2022-05-29 12:37:58.029+00	\N	\N	(-114.3811662,53.511590350000006)	parkland county	ab	ca	t	-115.1174333	53.715831	-113.6448991	53.3073497
vzrCAQWXql	2022-05-29 12:38:06.405+00	2022-05-29 12:38:06.504+00	\N	\N	(72.85761289999999,3.6246506)		ari atholhu dhekunuburi	mv	t	72.4969656	3.8768278	73.2182602	3.3724734
fU0LAyEEhF	2022-05-29 12:38:06.814+00	2022-05-29 12:38:06.914+00	\N	\N	(-77.6845635,43.257007200000004)	town of greece	ny	us	t	-77.753536	43.3347444	-77.615591	43.17927
PFd4llciV9	2022-05-29 12:38:07.24+00	2022-05-29 12:38:07.333+00	\N	\N	(-86.2929583,41.596777)	saint joseph county	in	us	t	-86.5266379	41.7606756	-86.0592787	41.4328784
s1fm78BHLh	2022-05-29 12:38:07.596+00	2022-05-29 12:38:07.694+00	\N	\N	(-124.0020887,44.9687226)	lincoln city	or	us	t	-124.0262016	45.0242563	-123.9779758	44.9131889
PXdV7DZ2UQ	2022-05-29 12:38:07.946+00	2022-05-29 12:38:08.035+00	\N	\N	(-79.5808083,43.19371865)	grimsby	on	ca	t	-79.6496842	43.254844	-79.5119324	43.1325933
73NGp62tSY	2022-05-29 12:38:08.288+00	2022-05-29 12:38:08.389+00	\N	\N	(-92.5267851,31.204444799999997)	rapides parish	la	us	t	-92.9812202	31.5176034	-92.07235	30.8912862
qwgNWWYytc	2022-05-29 12:38:08.745+00	2022-05-29 12:38:08.841+00	\N	\N	(-88.12858265,42.53911875)	salem lakes	wi	us	t	-88.1879683	42.5830232	-88.069197	42.4952143
vH5GLlB0PC	2022-05-29 12:38:09.063+00	2022-05-29 12:38:09.161+00	\N	\N	(-79.2469872,35.0232885)	hoke county	nc	us	t	-79.4592041	35.211021	-79.0347703	34.835556
whnUdagw7z	2022-05-29 12:38:09.72+00	2022-05-29 12:38:09.819+00	\N	\N	(-80.9789875,39.2829365)	pennsboro	wv	us	t	-81.00447	39.293892	-80.953505	39.271981
HrzN0W9fnJ	2022-05-29 12:38:09.98+00	2022-05-29 12:38:10.08+00	\N	\N	(-85.2178405,39.297751500000004)	batesville	in	us	t	-85.256024	39.323273	-85.179657	39.27223
5CVsXhe4TF	2022-05-29 12:38:10.419+00	2022-05-29 12:38:10.518+00	\N	\N	(-95.29000075,32.41106795)	smith county	tx	us	t	-95.5946318	32.6870696	-94.9853697	32.1350663
Dso3VAAuAJ	2022-05-29 12:38:10.887+00	2022-05-29 12:38:10.986+00	\N	\N	(8.5020752,49.50042565)	mannheim	bw	de	t	8.4141602	49.5904894	8.5899902	49.4103619
UvBofI0A1H	2022-05-29 12:38:11.377+00	2022-05-29 12:38:11.466+00	\N	\N	(-89.131394,31.706071)	laurel	ms	us	t	-89.193719	31.755985	-89.069069	31.656157
rAxAPuLvon	2022-05-29 12:38:11.638+00	2022-05-29 12:38:11.734+00	\N	\N	(-75.2788941,40.242170200000004)	lansdale	pa	us	t	-75.3034642	40.2613362	-75.254324	40.2230042
5YAFRvhKFv	2022-05-29 12:38:12.18+00	2022-05-29 12:38:12.276+00	\N	\N	(-97.88552225000001,31.116345000000003)	copperas cove	tx	us	t	-97.9662312	31.174517	-97.8048133	31.058173
6TTEB3evq3	2022-05-29 12:38:12.601+00	2022-05-29 12:38:12.695+00	\N	\N	(-100.315258,25.6802019)	monterrey	nle	mx	t	-100.475258	25.8402019	-100.155258	25.5202019
QmesLyEoky	2022-05-29 12:38:12.936+00	2022-05-29 12:38:13.035+00	\N	\N	(-88.00963955,42.8868641)	franklin	wi	us	t	-88.0699027	42.9304019	-87.9493764	42.8433263
IPJFPT5Qmd	2022-05-29 12:38:13.552+00	2022-05-29 12:38:13.651+00	\N	\N	(-74.64857135,40.8828508)	roxbury township	nj	us	t	-74.702451	40.9395	-74.5946917	40.8262016
fCLT22LPLd	2022-05-29 12:38:13.956+00	2022-05-29 12:38:14.055+00	\N	\N	(-88.547308,33.828483500000004)	aberdeen	ms	us	t	-88.600185	33.860005	-88.494431	33.796962
DWp2bC8hbG	2022-05-29 12:38:14.336+00	2022-05-29 12:38:14.436+00	\N	\N	(9.27570625,45.59272905)	monza	lombardy	it	t	9.2270251	45.6321966	9.3243874	45.5532615
EM6W0Yv4en	2022-05-31 15:55:19.764+00	2022-05-31 15:55:19.864+00	\N	\N	(-71.4367965,43.06577755)	hooksett	nh	us	t	-71.5174767	43.1222516	-71.3561163	43.0093035
P4N7tlBNwU	2022-06-01 04:03:52.712+00	2022-06-01 04:03:52.812+00	\N	\N	(9.76701155,54.95934215)	sønderborg municipality	region of southern denmark	dk	t	9.4624476	55.0837904	10.0715755	54.8348939
Qm51rZpzjb	2022-06-01 04:03:53.462+00	2022-06-01 04:03:53.562+00	\N	\N	(-57.53838895,-25.1981617)	mariano roque alonso	central	py	t	-57.5772552	-25.1536781	-57.4995227	-25.2426453
VI3VB73dFl	2022-06-01 04:03:53.926+00	2022-06-01 04:03:54.026+00	\N	\N	(-68.2127167,48.60038325)	sainte-flavie	qc	ca	t	-68.2946529	48.641596	-68.1307805	48.5591705
l8JpK7F1Bt	2022-06-01 04:03:54.534+00	2022-06-01 04:03:54.634+00	\N	\N	(-78.3868217,35.5362622)	johnston county	nc	us	t	-78.7088536	35.8178539	-78.0647898	35.2546705
Bfn0xbM4EN	2022-06-01 04:03:55.299+00	2022-06-01 04:03:55.399+00	\N	\N	(-63.2113509,45.26553845)	brookfield	ns	ca	t	-63.2964159	45.3037094	-63.1262859	45.2273675
oTZojha9v4	2022-06-01 04:03:56.057+00	2022-06-01 04:03:56.157+00	\N	\N	(-97.1741395,36.37964665)	noble county	ok	us	t	-97.461713	36.600075	-96.886566	36.1592183
01IFjaCDvQ	2022-06-01 04:03:56.692+00	2022-06-01 04:03:56.792+00	\N	\N	(30.4635755,-26.10793)	albert luthuli local municipality	mp	za	t	29.800581	-25.7118	31.12657	-26.50406
N81QD5QBIO	2022-06-01 04:03:57.137+00	2022-06-01 04:03:57.236+00	\N	\N	(-78.129048,36.7289095)	south hill	va	us	t	-78.171528	36.757313	-78.086568	36.700506
dfik5E0bpD	2022-06-01 04:03:58.04+00	2022-06-01 04:03:58.145+00	\N	\N	(106.6443241,-5.6869105)	jakarta special capital region		id	t	106.3146732	-4.9993635	106.973975	-6.3744575
68CMJzWYB7	2022-06-01 04:03:58.506+00	2022-06-01 04:03:58.604+00	\N	\N	(-74.67348045,40.423413)	montgomery township	nj	us	t	-74.7520249	40.471637	-74.594936	40.375189
5aXe5yL04I	2022-06-01 04:03:59.18+00	2022-06-01 04:03:59.28+00	\N	\N	(-97.927044,29.8685871)	san marcos	tx	us	t	-98.01213	29.960591	-97.841958	29.7765832
mlEtOjdoK2	2022-06-01 04:04:00.385+00	2022-06-01 04:04:00.484+00	\N	\N	(-81.1275148,36.472683)	alleghany county	nc	us	t	-81.353322	36.575024	-80.9017076	36.370342
6lQe40Kmaz	2022-06-01 04:04:01.182+00	2022-06-01 04:04:01.282+00	\N	\N	(-96.7907781,44.3698585)	brookings county	sd	us	t	-97.1297402	44.543784	-96.451816	44.195933
lraK2eQUA0	2022-06-01 04:04:01.561+00	2022-06-01 04:04:01.661+00	\N	\N	(-84.072704,42.2058295)	sharon township	mi	us	t	-84.134079	42.251477	-84.011329	42.160182
6ovwVMBswS	2022-06-01 04:04:02.059+00	2022-06-01 04:04:02.159+00	\N	\N	(25.25305795,54.7008287)	vilnius	vilnius county	lt	t	25.0245351	54.83232	25.4815808	54.5693374
M4VtCQ3XKq	2022-06-01 04:04:02.456+00	2022-06-01 04:04:02.553+00	\N	\N	(-83.4898525,42.372659999999996)	plymouth township	mi	us	t	-83.549667	42.396103	-83.430038	42.349217
suCGOpB9K0	2022-06-01 04:04:03.094+00	2022-06-01 04:04:03.194+00	\N	\N	(-81.44030860000001,41.3865091)	solon	oh	us	t	-81.488922	41.424753	-81.3916952	41.3482652
avrDyLseR2	2022-06-01 04:04:03.499+00	2022-06-01 04:04:03.599+00	\N	\N	(135.14674405,34.2690049)	wakayama	640-8511	jp	t	134.9787171	34.3940376	135.314771	34.1439722
8fNJAgLWf6	2022-06-01 04:04:03.782+00	2022-06-01 04:04:03.881+00	\N	\N	(-84.14388195000001,40.6851754)	fort shawnee	oh	us	t	-84.179997	40.7130429	-84.1077669	40.6573079
M4PoFcp308	2022-06-01 04:04:04.355+00	2022-06-01 04:04:04.454+00	\N	\N	(-83.6456545,36.5703145)	harrogate	tn	us	t	-83.671963	36.600402	-83.619346	36.540227
H2AS60maV3	2022-06-01 04:04:05.151+00	2022-06-01 04:04:05.25+00	\N	\N	(-114.02669165,52.92362625)	county of wetaskiwin	ab	ca	t	-115.0258198	53.1341902	-113.0275635	52.7130623
mM2S7zEa50	2022-06-01 04:04:05.568+00	2022-06-01 04:04:05.667+00	\N	\N	(-122.37877639999999,47.81967585)	edmonds	wa	us	t	-122.4381474	47.861617	-122.3194054	47.7777347
iFyRwcE0cP	2022-05-29 12:37:56.193+00	2022-06-01 04:04:16.322+00	\N	\N	(-61.80283085,44.5004361)	halifax	ns	ca	t	-64.2422055	45.2756249	-59.3634562	43.7252473
QgNNQOB3jS	2022-06-01 04:04:06.141+00	2022-06-01 04:04:06.241+00	\N	\N	(14.327468450000001,48.2950319)	linz	upper austria	at	t	14.24572	48.3786926	14.4092169	48.2113712
gnVBMmLcas	2022-06-01 04:04:06.766+00	2022-06-01 04:04:06.865+00	\N	\N	(13.0551722,53.3362253)	neustrelitz	mv	de	t	12.9274802	53.4123074	13.1828642	53.2601432
LCK49noZng	2022-06-01 04:04:07.091+00	2022-06-01 04:04:07.189+00	\N	\N	(-89.650839,39.576794500000005)	divernon	il	us	t	-89.661061	39.60049	-89.640617	39.553099
XfA9RZJYuM	2022-06-01 04:04:07.788+00	2022-06-01 04:04:07.889+00	\N	\N	(-77.113541,45.8260909)	pembroke	on	ca	t	-77.273541	45.9860909	-76.953541	45.6660909
vZpBAZN6oc	2022-06-01 04:04:08.232+00	2022-06-01 04:04:08.331+00	\N	\N	(23.366825,-29.05302)	siyancuma local municipality	nc	za	t	22.04187	-28.44446	24.69178	-29.66158
jJeKF1LI3F	2022-06-01 04:04:08.825+00	2022-06-01 04:04:08.925+00	\N	\N	(-97.1528399,49.853780650000004)	winnipeg	mb	ca	t	-97.3491505	49.9940075	-96.9565293	49.7135538
36Z4taroWj	2022-06-01 04:04:09.298+00	2022-06-01 04:04:09.398+00	\N	\N	(-81.420643,29.937686499999998)	saint johns county	fl	us	t	-81.690469	30.252941	-81.150817	29.622432
0DIPitBYJC	2022-06-01 04:04:09.704+00	2022-06-01 04:04:09.805+00	\N	\N	(-120.857855,37.501841999999996)	turlock	ca	us	t	-120.904026	37.537526	-120.811684	37.466158
eSln7N4Id3	2022-06-01 04:04:10.12+00	2022-06-01 04:04:10.219+00	\N	\N	(103.8520359,1.2904753)	singapore	178957	sg	t	103.6920359	1.4504753	104.0120359	1.1304753
mihTKR5Jjk	2022-06-01 04:04:11.027+00	2022-06-01 04:04:11.127+00	\N	\N	(-71.0277363,42.084352800000005)	brockton	ma	us	t	-71.0804832	42.1265268	-70.9749894	42.0421788
5lnRaBZfz8	2022-06-01 04:04:11.384+00	2022-06-01 04:04:11.483+00	\N	\N	(7.9358977,46.8904586)	escholzmatt-marbach	lucerne	ch	t	7.8561587	46.9812583	8.0156367	46.7996589
ebfWXjJUH4	2022-06-01 04:04:12.106+00	2022-06-01 04:04:12.206+00	\N	\N	(-112.9758155,54.23898135)	thorhild county	ab	ca	t	-113.3753637	54.5000264	-112.5762673	53.9779363
a1Cam7cyQb	2022-06-01 04:04:12.863+00	2022-06-01 04:04:12.963+00	\N	\N	(76.61651789999999,28.1956468)	rewari	hr	in	t	76.4565179	28.3556468	76.7765179	28.0356468
EC8ycQEgqt	2022-06-01 04:04:13.278+00	2022-06-01 04:04:13.378+00	\N	\N	(-84.55718200000001,33.912643)	cobb county	ga	us	t	-84.739636	34.081779	-84.374728	33.743507
od3t7sKfFh	2022-06-01 04:04:13.819+00	2022-06-01 04:04:13.919+00	\N	\N	(9.4320763,54.79443515)	flensburg	sh	de	t	9.3573409	54.8370717	9.5068117	54.7517986
YRnNYkJDB8	2022-06-01 04:04:14.2+00	2022-06-01 04:04:14.3+00	\N	\N	(-75.76961549999999,38.692704500000005)	federalsburg	md	us	t	-75.789459	38.709026	-75.749772	38.676383
SE2Jd2KZyp	2022-06-01 04:04:14.862+00	2022-06-01 04:04:14.962+00	\N	\N	(-90.60743794999999,14.5327574)	villa nueva city	guatemala department	gt	t	-90.663641	14.5889122	-90.5512349	14.4766026
nW4mPiC2VM	2022-06-01 04:04:15.281+00	2022-06-01 04:04:15.38+00	\N	\N	(-80.32769175,26.026600350000002)	pembroke pines	fl	us	t	-80.4418998	26.0609535	-80.2134837	25.9922472
LpEITqp1DK	2022-06-01 04:04:15.738+00	2022-06-01 04:04:15.837+00	\N	\N	(-0.9889087000000001,46.313905649999995)	marans	new aquitaine	fr	t	-1.0742351	46.3715027	-0.9035823	46.2563086
7xudkOCUMs	2022-06-01 04:04:16.787+00	2022-06-01 04:04:16.887+00	\N	\N	(-92.8994921,45.759287)	rock creek	mn	us	t	-93.0219828	45.78855	-92.7770014	45.730024
zSPeBluHGo	2022-06-01 04:04:17.096+00	2022-06-01 04:04:17.195+00	\N	\N	(-89.6321064,42.285359299999996)	freeport	il	us	t	-89.6865714	42.3214008	-89.5776414	42.2493178
CCposq4hFv	2022-06-01 04:04:17.604+00	2022-06-01 04:04:17.704+00	\N	\N	(-112.00292225000001,41.3230352)	pleasant view	ut	us	t	-112.034304	41.3504735	-111.9715405	41.2955969
QhQDFlJBok	2022-06-01 04:04:18.297+00	2022-06-01 04:04:18.396+00	\N	\N	(-84.8243105,42.565102499999995)	charlotte	mi	us	t	-84.860597	42.591637	-84.788024	42.538568
kGZP74mPB1	2022-06-01 04:04:18.777+00	2022-06-01 04:04:18.876+00	\N	\N	(-95.40862895000001,32.77711205)	wood county	tx	us	t	-95.6653125	33.0132704	-95.1519454	32.5409537
GumV4yoYpD	2022-06-01 04:04:19.16+00	2022-06-01 04:04:19.26+00	\N	\N	(-78.3860115,42.17399)	town of hinsdale	ny	us	t	-78.463264	42.217874	-78.308759	42.130106
vL0k7FoqfN	2022-06-01 04:04:19.555+00	2022-06-01 04:04:19.655+00	\N	\N	(-95.0993384,30.342601799999997)	cleveland	tx	us	t	-95.1980665	30.4054646	-95.0006103	30.279739
fJiLjtUP99	2022-06-01 04:04:19.963+00	2022-06-01 04:04:20.062+00	\N	\N	(-85.37327099999999,38.4032435)	la grange	ky	us	t	-85.410142	38.437578	-85.3364	38.368909
hptb0RgPRt	2022-06-01 04:04:20.683+00	2022-06-01 04:04:20.783+00	\N	\N	(-3.1420776999999998,56.22966405)	fife	sct	gb	t	-3.7399184	56.4534987	-2.544237	56.0058294
nfJA9zKSv4	2022-06-01 04:04:21.084+00	2022-06-01 04:04:21.184+00	\N	\N	(-75.5971512,39.564832800000005)	new castle county	de	us	t	-75.7890215	39.8394337	-75.4052809	39.2902319
5KOH10Po6r	2022-06-01 04:04:21.561+00	2022-06-01 04:04:21.66+00	\N	\N	(-87.818895,42.086274200000005)	glenview	il	us	t	-87.8791553	42.1174717	-87.7586347	42.0550767
JG9vpgpE4w	2022-06-01 04:04:21.928+00	2022-06-01 04:04:22.028+00	\N	\N	(-112.00526540000001,40.4896569)	herriman	ut	us	t	-112.0770317	40.5369698	-111.9334991	40.442344
LMS8FnT37i	2022-06-01 04:04:22.433+00	2022-06-01 04:04:22.533+00	\N	\N	(-120.52021049999999,47.9057982)	chelan county	wa	us	t	-121.180713	48.550725	-119.859708	47.2608714
wrD1C8Rw8A	2022-06-01 04:04:22.965+00	2022-06-01 04:04:23.065+00	\N	\N	(-87.64547145,32.738068549999994)	hale county	al	us	t	-87.8706629	33.0070054	-87.42028	32.4691317
E1HPXNxtnr	2022-06-01 04:04:23.33+00	2022-06-01 04:04:23.431+00	\N	\N	(-81.45384250000001,31.7263345)	riceboro	ga	us	t	-81.505847	31.754026	-81.401838	31.698643
WmPBdcVGMt	2022-06-01 04:04:23.677+00	2022-06-01 04:04:23.777+00	\N	\N	(73.84449715,29.257722)	suratgarh tehsil	rj	in	t	73.4411573	29.6136103	74.247837	28.9018337
ZEFyVe0JK9	2022-06-01 04:04:24.166+00	2022-06-01 04:04:24.266+00	\N	\N	(5.481549899999999,53.37051305)	oosterend	frisia	nl	t	5.3502689	53.4715849	5.6128309	53.2694412
uujS8flfL3	2022-06-01 04:04:24.681+00	2022-06-01 04:04:24.78+00	\N	\N	(-81.4415915,41.5503231)	mayfield	oh	us	t	-81.463247	41.5699542	-81.419936	41.530692
jI7FRp68tg	2022-06-01 04:04:25.066+00	2022-06-01 04:04:25.167+00	\N	\N	(-73.6133465,41.3978855)	brewster	ny	us	t	-73.624745	41.404521	-73.601948	41.39125
GABwY7TYb4	2022-06-01 04:04:25.511+00	2022-06-01 04:04:25.611+00	\N	\N	(175.1469047,-40.85682435)	kapiti coast district	wgn	nz	t	174.868496	-40.7003335	175.4253134	-41.0133152
g7PaesPro8	2022-06-01 04:04:26.089+00	2022-06-01 04:04:26.189+00	\N	\N	(-77.3095821,17.95768245)	clarendon		jm	t	-77.4941725	18.2098016	-77.1249917	17.7055633
Yp0JLHed7s	2022-06-01 04:04:26.578+00	2022-06-01 04:04:26.678+00	\N	\N	(-1.422348,52.770501550000006)	north west leicestershire	eng	gb	t	-1.5975472	52.8770626	-1.2471488	52.6639405
6h9nNYtdYS	2022-06-01 04:04:27.018+00	2022-06-01 04:04:27.118+00	\N	\N	(-76.23655099999999,46.1692945)	cayamant	qc	ca	t	-76.3208866	46.3164022	-76.1522154	46.0221868
mqBgrF0GNf	2022-06-01 04:04:27.445+00	2022-06-01 04:04:27.544+00	\N	\N	(-85.17229739999999,33.99905)	polk county	ga	us	t	-85.4218528	34.099094	-84.922742	33.899006
6JYFljCHYT	2022-06-01 04:04:27.936+00	2022-06-01 04:04:28.036+00	\N	\N	(-82.62640805000001,36.9299401)	norton	va	us	t	-82.6636261	36.9597637	-82.58919	36.9001165
AVyQ68uZTJ	2022-06-01 04:04:28.701+00	2022-06-01 04:04:28.801+00	\N	\N	(-79.4966691,36.068733)	burlington	nc	us	t	-79.6214106	36.1277562	-79.3719276	36.0097098
7lZR04GGpG	2022-06-01 04:04:29.203+00	2022-06-01 04:04:29.303+00	\N	\N	(-88.1157386,42.335732050000004)	round lake	il	us	t	-88.1488971	42.3680911	-88.0825801	42.303373
6DWHotDExF	2022-06-01 04:04:29.668+00	2022-06-01 04:04:29.768+00	\N	\N	(-80.4090245,27.382149)	saint lucie county	fl	us	t	-80.68	27.558714	-80.138049	27.205584
ynXESViNG9	2022-06-01 04:04:30.317+00	2022-06-01 04:04:30.417+00	\N	\N	(78.06096005,13.4711631)	chintamani taluk	ka	in	t	77.9132581	13.6755557	78.208662	13.2667705
LjbcW6awrc	2022-06-01 04:04:30.707+00	2022-06-01 04:04:30.808+00	\N	\N	(-96.66223515,33.6781172)	grayson county	tx	us	t	-96.9450702	33.9583489	-96.3794001	33.3978855
wsTeeOSEak	2022-06-01 04:04:31.113+00	2022-06-01 04:04:31.211+00	\N	\N	(-74.2798904,41.32769005)	town of chester	ny	us	t	-74.332971	41.3832461	-74.2268098	41.272134
Z4TrEdVcpe	2022-06-01 04:04:31.588+00	2022-06-01 04:04:31.689+00	\N	\N	(2.7718533,39.38957055)	palma	balearic islands	es	t	2.563847	39.6584127	2.9798596	39.1207284
aRxi3ddYNH	2022-06-01 04:04:31.997+00	2022-06-01 04:04:32.098+00	\N	\N	(-1.17741775,53.1752026)	mansfield	eng	gb	t	-1.2600703	53.2356135	-1.0947652	53.1147917
uIAmnUQ5lo	2022-06-01 04:04:32.391+00	2022-06-01 04:04:32.491+00	\N	\N	(-77.85258265,40.78781065)	state college	pa	us	t	-77.8861677	40.8072512	-77.8189976	40.7683701
Lx2p3mtUUY	2022-06-01 04:04:32.851+00	2022-06-01 04:04:32.95+00	\N	\N	(-87.9088705,36.81842255)	trigg county	ky	us	t	-88.157745	37.002094	-87.659996	36.6347511
iZ2C1ukVXm	2022-06-01 04:04:33.28+00	2022-06-01 04:04:33.379+00	\N	\N	(-119.27121650000001,47.137755999999996)	moses lake	wa	us	t	-119.3636379	47.218432	-119.1787951	47.05708
FmCWbC3rPo	2022-06-01 04:04:33.877+00	2022-06-01 04:04:33.976+00	\N	\N	(12.058604899999999,55.269235800000004)	faxe municipality	region zealand	dk	t	11.8319507	55.4049156	12.2852591	55.133556
im2X4vwJqR	2022-06-01 04:04:34.302+00	2022-06-01 04:04:34.402+00	\N	\N	(-75.74782245,40.0393272)	east brandywine township	pa	us	t	-75.7896788	40.0675922	-75.7059661	40.0110622
Gh6RntDftD	2022-06-01 04:04:34.999+00	2022-06-01 04:04:35.099+00	\N	\N	(-1.9256624000000002,51.324063800000005)	wiltshire	eng	gb	t	-2.3655986	51.7031417	-1.4857262	50.9449859
CIct1lqG0c	2022-06-01 04:04:35.445+00	2022-06-01 04:04:35.545+00	\N	\N	(-111.97297595,41.223051)	ogden	ut	us	t	-112.0255709	41.285993	-111.920381	41.160109
Zdzjfla4rn	2022-06-01 04:04:35.811+00	2022-06-01 04:04:35.911+00	\N	\N	(-75.76777125,41.7045202)	hop bottom	pa	us	t	-75.775628	41.7130186	-75.7599145	41.6960218
YY5XebmyAi	2022-06-01 04:04:36.217+00	2022-06-01 04:04:36.316+00	\N	\N	(-80.74794664999999,40.02097355)	bellaire	oh	us	t	-80.7654355	40.0504851	-80.7304578	39.991462
1jAlaUCfWa	2022-06-01 04:04:36.579+00	2022-06-01 04:04:36.677+00	\N	\N	(-75.5475755,41.508131000000006)	archbald	pa	us	t	-75.611532	41.54478	-75.483619	41.471482
hHfllCZajW	2022-06-01 04:04:36.967+00	2022-06-01 04:04:37.067+00	\N	\N	(-82.63959645,36.7395687)	scott county	va	us	t	-82.9851254	36.8856764	-82.2940675	36.593461
iQO33tkTDa	2022-06-01 04:04:37.254+00	2022-06-01 04:04:37.351+00	\N	\N	(-157.79525205,21.4053595)	kaneohe	hi	us	t	-157.830384	21.431426	-157.7601201	21.379293
IFFGSCWemy	2022-06-01 04:04:37.959+00	2022-06-01 04:04:38.056+00	\N	\N	(54.53153305,24.44144355)	abu dhabi	abu dhabi emirate	ae	t	54.2971553	24.601854	54.7659108	24.2810331
YUH9Wv7rDG	2022-06-01 04:04:38.427+00	2022-06-01 04:04:38.527+00	\N	\N	(-97.80539845,32.77918965)	parker county	tx	us	t	-98.0667047	33.0035826	-97.5440922	32.5547967
LpFqUrPER7	2022-06-01 04:04:38.892+00	2022-06-01 04:04:38.992+00	\N	\N	(-81.97970165,34.4943241)	laurens county	sc	us	t	-82.3147573	34.7855462	-81.644646	34.203102
zGTOC1MVeV	2022-06-01 04:04:39.438+00	2022-06-01 04:04:39.538+00	\N	\N	(-100.45399094999999,29.3539392)	kinney county	tx	us	t	-100.79696	29.6237767	-100.1110219	29.0841017
gemcr3xj4W	2022-06-01 04:04:39.869+00	2022-06-01 04:04:39.969+00	\N	\N	(-71.794355,43.44600405)	andover	nh	us	t	-71.8941483	43.5029851	-71.6945617	43.389023
wS5BMhqBUc	2022-06-01 04:04:40.319+00	2022-06-01 04:04:40.418+00	\N	\N	(30.674529900000003,-29.0059749)	umvoti local municipality	nl	za	t	30.3252799	-28.7217799	31.0237799	-29.2901699
euNgDiB8VY	2022-06-01 04:04:41.022+00	2022-06-01 04:04:41.122+00	\N	\N	(-100.4446081,31.430995)	san angelo	tx	us	t	-100.5292906	31.5264855	-100.3599256	31.3355045
IEnFUbOLtK	2022-06-01 04:04:41.624+00	2022-06-01 04:04:41.724+00	\N	\N	(-81.68699585,36.251384599999994)	watauga county	nc	us	t	-81.9180772	36.3912931	-81.4559145	36.1114761
5zaqDmqyoT	2022-06-01 04:04:42.243+00	2022-06-01 04:04:42.343+00	\N	\N	(-120.54983494999999,38.46329065)	amador county	ca	us	t	-121.0273043	38.7090956	-120.0723656	38.2174857
4iqKhA7YTT	2022-06-01 04:04:42.547+00	2022-06-01 04:04:42.647+00	\N	\N	(27.20685075,45.6994841)	focșani		ro	t	27.1467221	45.7477646	27.2669794	45.6512036
80JmlrZaRA	2022-06-01 04:04:43.037+00	2022-06-01 04:04:43.137+00	\N	\N	(-72.084523,42.9441895)	harrisville	nh	us	t	-72.167831	42.968935	-72.001215	42.919444
FSDsGuBIov	2022-06-01 04:04:43.364+00	2022-06-01 04:04:43.464+00	\N	\N	(-96.7353263,32.300625350000004)	ellis county	tx	us	t	-97.0871038	32.5492189	-96.3835488	32.0520318
NAMVaBiWse	2022-06-01 04:04:43.779+00	2022-06-01 04:04:43.879+00	\N	\N	(-75.28949705,40.277201000000005)	hatfield township	pa	us	t	-75.335939	40.3079058	-75.2430551	40.2464962
FMyzyqFrl8	2022-06-01 04:12:42.914+00	2022-06-01 04:12:43.013+00	\N	\N	(-104.2872605,32.48269865)	eddy county	nm	us	t	-104.8517216	32.9654321	-103.7227994	31.9999652
Dm4T2W2FUR	2022-06-01 04:12:43.632+00	2022-06-01 04:12:43.732+00	\N	\N	(-86.51448405,42.0181041)	lincoln charter township	mi	us	t	-86.5634864	42.0507831	-86.4654817	41.9854251
a3dXpFloeJ	2022-06-01 04:12:44.403+00	2022-06-01 04:12:44.503+00	\N	\N	(-83.853155,42.556406499999994)	genoa township	mi	us	t	-83.91431	42.602118	-83.792	42.510695
ejN7pTuLxz	2022-06-01 04:12:45.214+00	2022-06-01 04:12:45.314+00	\N	\N	(83.184439,26.0654351)	azamgarh	up	in	t	83.024439	26.2254351	83.344439	25.9054351
4cDhXyR8CO	2022-06-01 04:12:45.935+00	2022-06-01 04:12:46.034+00	\N	\N	(-82.30807155,40.86717005)	ashland	oh	us	t	-82.3562108	40.9000401	-82.2599323	40.8343
nQ74eN6Ujd	2022-06-01 04:12:46.823+00	2022-06-01 04:12:46.923+00	\N	\N	(-116.540699,48.75071595)	boundary county	id	us	t	-117.0324281	49.0008447	-116.0489699	48.5005872
wJFFlaBxfC	2022-06-01 04:12:47.471+00	2022-06-01 04:12:47.571+00	\N	\N	(-95.951278,36.6777255)	bartlesville	ok	us	t	-96.012763	36.783389	-95.889793	36.572062
uaGFTyB1hU	2022-06-01 04:12:48.157+00	2022-06-01 04:12:48.257+00	\N	\N	(-73.771366,43.062027)	saratoga springs	ny	us	t	-73.848663	43.108491	-73.694069	43.015563
f9wRxsKMwZ	2022-06-01 04:12:48.51+00	2022-06-01 04:12:48.609+00	\N	\N	(35.20680145,31.78838515)	jerusalem	jerusalem district	il	t	35.1523819	31.8597262	35.261221	31.7170441
BoRoyCwobM	2022-06-01 04:12:49.342+00	2022-06-01 04:12:49.441+00	\N	\N	(101.686827,3.1390764)	kuala lumpur		my	t	101.6151592	3.2447194	101.7584948	3.0334334
Bf3uKKYzO8	2022-06-01 04:12:49.681+00	2022-06-01 04:12:49.781+00	\N	\N	(-70.87320994999999,42.0560305)	hanson	ma	us	t	-70.9129643	42.0963364	-70.8334556	42.0157246
8xGM2LdWvW	2022-06-01 04:12:50.399+00	2022-06-01 04:12:50.5+00	\N	\N	(-87.84934899999999,43.5035845)	belgium	wi	us	t	-87.870421	43.522259	-87.828277	43.48491
TmiKcrSEm0	2022-06-01 04:12:51.15+00	2022-06-01 04:12:51.249+00	\N	\N	(-5.9260377,37.37658075)	seville	andalusia	es	t	-6.0329183	37.4529579	-5.8191571	37.3002036
AbUnVPhS2d	2022-06-01 04:12:51.904+00	2022-06-01 04:12:51.999+00	\N	\N	(-87.973736,42.285105200000004)	libertyville	il	us	t	-88.022622	42.32464	-87.92485	42.2455704
xpU7SVDfR6	2022-06-01 04:12:52.586+00	2022-06-01 04:12:52.686+00	\N	\N	(-70.99116470000001,42.4191412)	revere	ma	us	t	-71.0331809	42.4501176	-70.9491485	42.3881648
DdDpIjdzDp	2022-06-01 04:12:53.048+00	2022-06-01 04:12:53.148+00	\N	\N	(-74.55853300000001,40.888362)	dover	nj	us	t	-74.578961	40.904109	-74.538105	40.872615
Q88nBgipHi	2022-06-01 04:12:53.667+00	2022-06-01 04:12:53.767+00	\N	\N	(-71.23950400000001,42.970652799999996)	chester	nh	us	t	-71.311203	43.021396	-71.167805	42.9199096
GKyDn6UhCk	2022-06-01 04:12:54.089+00	2022-06-01 04:12:54.188+00	\N	\N	(-87.90154675,42.5885625)	kenosha	wi	us	t	-87.996968	42.639375	-87.8061255	42.53775
02NDYBSblr	2022-06-01 04:12:54.875+00	2022-06-01 04:12:54.973+00	\N	\N	(-90.37484140000001,39.092965)	jersey county	il	us	t	-90.6036228	39.262501	-90.14606	38.923429
uzLgDwcoQ7	2022-06-01 04:12:55.458+00	2022-06-01 04:12:55.557+00	\N	\N	(18.87425315,50.27006245)	ruda śląska	silesian voivodeship	pl	t	18.792342	50.3317029	18.9561643	50.208422
SzoMDh24nr	2022-06-01 04:12:56.055+00	2022-06-01 04:12:56.154+00	\N	\N	(-83.03817065,42.757853499999996)	washington township	mi	us	t	-83.099432	42.803333	-82.9769093	42.712374
5ramPq4eo9	2022-06-01 04:12:56.525+00	2022-06-01 04:12:56.624+00	\N	\N	(36.811193,0.28679125)		laikipia	ke	t	36.2266898	0.8690666	37.3956962	-0.2954841
GIv4JBkkWd	2022-06-01 04:12:56.922+00	2022-06-01 04:12:57.021+00	\N	\N	(-82.794308,42.675541)	chesterfield township	mi	us	t	-82.859339	42.720843	-82.729277	42.630239
Qfyl12h3hE	2022-06-01 04:12:57.296+00	2022-06-01 04:12:57.394+00	\N	\N	(-79.75957059999999,43.72494885)	brampton	on	ca	t	-79.8888473	43.8480959	-79.6302939	43.6018018
qeHF61SC4G	2022-06-01 04:12:57.789+00	2022-06-01 04:12:57.889+00	\N	\N	(-71.55846925,41.87174945)	providence county	ri	us	t	-71.799195	42.0189359	-71.3177435	41.724563
01P4gEtPgk	2022-06-01 04:12:58.285+00	2022-06-01 04:12:58.385+00	\N	\N	(-87.72188,34.5036415)	russellville	al	us	t	-87.759549	34.5491953	-87.684211	34.4580877
uue6mzaCaC	2022-06-01 04:12:58.62+00	2022-06-01 04:12:58.719+00	\N	\N	(-85.55854049999999,43.12739929999999)	rockford	mi	us	t	-85.58145	43.1464946	-85.535631	43.108304
a0R88eMFyL	2022-06-01 04:12:59.427+00	2022-06-01 04:12:59.526+00	\N	\N	(-88.4788797,44.163325)	town of neenah	wi	us	t	-88.5239262	44.199977	-88.4338332	44.126673
SKQ2Fp7OZJ	2022-06-01 04:12:59.759+00	2022-06-01 04:12:59.859+00	\N	\N	(-81.43151950000001,41.659218)	eastlake	oh	us	t	-81.462731	41.694577	-81.400308	41.623859
HEo3bBotfA	2022-06-01 04:13:00.15+00	2022-06-01 04:13:00.25+00	\N	\N	(-95.01739935,41.3979856)	atlantic	ia	us	t	-95.0602956	41.4177831	-94.9745031	41.3781881
OlscdrT8gF	2022-06-01 04:13:00.589+00	2022-06-01 04:13:00.689+00	\N	\N	(-108.051196,39.44644425)	parachute	co	us	t	-108.065	39.461178	-108.037392	39.4317105
LcIDwRGAy7	2022-06-01 04:13:00.952+00	2022-06-01 04:13:01.051+00	\N	\N	(-101.6013055,45.049479500000004)	dupree	sd	us	t	-101.609079	45.053252	-101.593532	45.045707
VR6QAFDthf	2022-06-01 04:13:01.227+00	2022-06-01 04:13:01.325+00	\N	\N	(-94.1910291,31.37645315)	san augustine county	tx	us	t	-94.398822	31.6536087	-93.9832362	31.0992976
8HKcg0Uvk8	2022-06-01 04:13:01.615+00	2022-06-01 04:13:01.715+00	\N	\N	(-83.20472434999999,42.2061446)	southgate	mi	us	t	-83.2298557	42.2280061	-83.179593	42.1842831
ZKFsmRYwfS	2022-06-01 04:13:01.956+00	2022-06-01 04:13:02.056+00	\N	\N	(-69.97246265,43.896187999999995)	brunswick	me	us	t	-70.0878925	43.9756705	-69.8570328	43.8167055
KQ2bvFZ7JA	2022-06-01 04:13:02.25+00	2022-06-01 04:13:02.349+00	\N	\N	(-81.92242150000001,34.941981)	spartanburg	sc	us	t	-81.998107	34.982502	-81.846736	34.90146
9BC7PkHwkz	2022-06-01 04:13:02.614+00	2022-06-01 04:13:02.714+00	\N	\N	(-84.66690955,43.4225019)	pine river township	mi	us	t	-84.7267327	43.4662372	-84.6070864	43.3787666
YXD1n93R40	2022-06-01 04:13:02.911+00	2022-06-01 04:13:03.01+00	\N	\N	(-108.9922712,25.784229)	los mochis	sin	mx	t	-109.0463376	25.8395287	-108.9382048	25.7289293
lAJS1ZmxdT	2022-06-01 04:13:03.507+00	2022-06-01 04:13:03.607+00	\N	\N	(-84.84686075,43.1795976)	carson city	mi	us	t	-84.8571143	43.187872	-84.8366072	43.1713232
iBNpDGjNI5	2022-06-01 04:13:03.944+00	2022-06-01 04:13:04.044+00	\N	\N	(-80.7689811,40.377226)	jefferson county	oh	us	t	-80.941765	40.599648	-80.5961972	40.154804
ssx36uAhpD	2022-06-01 04:13:04.379+00	2022-06-01 04:13:04.478+00	\N	\N	(-78.00646814999999,40.49794805)	huntingdon	pa	us	t	-78.0267913	40.518918	-77.986145	40.4769781
qLhNRrEVqr	2022-06-01 04:13:05.116+00	2022-06-01 04:13:05.215+00	\N	\N	(-80.62896905,40.101094450000005)	ohio county	wv	us	t	-80.7390431	40.1859899	-80.518895	40.016199
1RF3e10Dxi	2022-06-01 04:13:05.547+00	2022-06-01 04:13:05.646+00	\N	\N	(-71.16172664999999,41.736552450000005)	somerset	ma	us	t	-71.2082917	41.7911098	-71.1151616	41.6819951
U4KyPPj6rp	2022-06-01 04:13:05.971+00	2022-06-01 04:13:06.07+00	\N	\N	(5.32900825,50.8074455)	borgloon	vli	be	t	5.2503757	50.8454268	5.4076408	50.7694642
ASx7Kut3fO	2022-06-01 04:13:06.336+00	2022-06-01 04:13:06.434+00	\N	\N	(-77.9154605,43.252236499999995)	town of clarkson	ny	us	t	-77.996899	43.284954	-77.834022	43.219519
HghIctuom9	2022-06-01 04:13:07.134+00	2022-06-01 04:13:07.234+00	\N	\N	(-76.352349,42.089808000000005)	town of tioga	ny	us	t	-76.441484	42.155003	-76.263214	42.024613
58bnTEe9sW	2022-06-01 04:13:07.455+00	2022-06-01 04:13:07.554+00	\N	\N	(-85.3965304,40.22791035)	delaware county	in	us	t	-85.5788002	40.3794287	-85.2142606	40.076392
ZqerhdAjAC	2022-06-01 04:13:07.768+00	2022-06-01 04:13:07.866+00	\N	\N	(-107.92927315,37.3186685)	la plata county	co	us	t	-108.3806098	37.637749	-107.4779365	36.999588
yhGaMdJQPy	2022-06-01 04:13:08.063+00	2022-06-01 04:13:08.163+00	\N	\N	(-93.11223705,36.244318199999995)	harrison	ar	us	t	-93.1593009	36.2775628	-93.0651732	36.2110736
LFrRbhaxza	2022-06-01 04:13:08.468+00	2022-06-01 04:13:08.566+00	\N	\N	(-72.51189984999999,42.775569250000004)	vernon	vt	us	t	-72.5653526	42.8241785	-72.4584471	42.72696
7ozwmKj6lM	2022-06-01 04:13:09.014+00	2022-06-01 04:13:09.113+00	\N	\N	(-74.105845,40.069126499999996)	brick township	nj	us	t	-74.16057	40.137036	-74.05112	40.001217
tFvHB3Plmq	2022-06-01 04:13:09.425+00	2022-06-01 04:13:09.525+00	\N	\N	(-123.13879895,49.75576855)	squamish	bc	ca	t	-123.2604193	49.8729446	-123.0171786	49.6385925
4Qgc8JYDRg	2022-06-01 04:13:09.781+00	2022-06-01 04:13:09.88+00	\N	\N	(-74.9807435,40.756589)	washington	nj	us	t	-74.999381	40.768524	-74.962106	40.744654
rcmQ61prqB	2022-06-01 04:13:10.259+00	2022-06-01 04:13:10.354+00	\N	\N	(-3.0498284499999997,53.0004522)	wrexham	wls	gb	t	-3.3755226	53.1343104	-2.7241343	52.866594
vH6TVZl1XF	2022-06-01 04:13:11.795+00	2022-06-01 04:13:11.896+00	\N	\N	(-75.516344,43.887501)	castorland	ny	us	t	-75.526373	43.895653	-75.506315	43.879349
nC3hgX5fef	2022-06-01 04:13:12.165+00	2022-06-01 04:13:12.265+00	\N	\N	(-70.9835084,43.302502000000004)	rochester	nh	us	t	-71.0708838	43.379222	-70.896133	43.225782
lCfZtCkvYX	2022-06-01 04:13:12.55+00	2022-06-01 04:13:12.65+00	\N	\N	(-120.29209605,50.74096835)	kamloops	bc	ca	t	-120.5424391	50.8664283	-120.041753	50.6155084
Eoaar35p9V	2022-06-01 04:13:12.917+00	2022-06-01 04:13:13.016+00	\N	\N	(-92.51153479999999,32.553216)	choudrant	la	us	t	-92.5364728	32.5820405	-92.4865968	32.5243915
FE5UjHqbRE	2022-06-01 04:13:13.263+00	2022-06-01 04:13:13.357+00	\N	\N	(100.2851098,5.3933491)	air itam	penang	my	t	100.2675607	5.42576	100.3026589	5.3609382
IRIwAdkEte	2022-06-01 04:13:15.911+00	2022-06-01 04:13:16.01+00	\N	\N	(-119.82486355,49.20571165)	keremeos	bc	ca	t	-119.8373726	49.2129734	-119.8123545	49.1984499
7gxaZZUCPG	2022-06-01 04:13:16.238+00	2022-06-01 04:13:16.338+00	\N	\N	(-82.353803,29.6811555)	alachua county	fl	us	t	-82.658554	29.945254	-82.049052	29.417057
AtY6LlRXXO	2022-06-01 04:13:16.559+00	2022-06-01 04:13:16.657+00	\N	\N	(-108.41753565,43.043053799999996)	riverton	wy	us	t	-108.48887	43.077369	-108.3462013	43.0087386
H1Fiprbp8b	2022-06-01 04:13:10.618+00	2022-06-01 04:13:10.718+00	\N	\N	(-6.40871465,53.2733788)	south dublin		ie	t	-6.5468919	53.368494	-6.2705374	53.1782636
omd8da3e2o	2022-06-01 04:13:11.456+00	2022-06-01 04:13:11.553+00	\N	\N	(34.881276799999995,32.267806)	even yehuda	center district	il	t	34.8659082	32.293541	34.8966454	32.242071
BQvNELgAOi	2022-06-01 04:13:13.619+00	2022-06-01 04:13:13.719+00	\N	\N	(25.43055,-28.379275)	tokologo local municipality	fs	za	t	24.7977	-27.79318	26.0634	-28.96537
xLMvZR95RJ	2022-06-01 04:13:14.021+00	2022-06-01 04:13:14.121+00	\N	\N	(27.18375,-26.749521350000002)	tlokwe local municipality	north west	za	t	26.76466	-26.5185527	27.60284	-26.98049
TNFA2t6R55	2022-06-01 04:13:14.5+00	2022-06-01 04:13:14.6+00	\N	\N	(-74.148303,40.467723500000005)	keansburg	nj	us	t	-74.206451	40.500137	-74.090155	40.43531
Ktcj90b5Lj	2022-06-01 04:13:15.461+00	2022-06-01 04:13:15.557+00	\N	\N	(24.85291705,59.296720750000006)	kiili vald		ee	t	24.7493487	59.3600897	24.9564854	59.2333518
nPJsXB9WaE	2022-06-01 04:13:16.923+00	2022-06-01 04:13:17.022+00	\N	\N	(-91.391685,39.7128635)	hannibal	mo	us	t	-91.461424	39.751133	-91.321946	39.674594
GtZMBrXYyy	2022-06-01 04:13:17.337+00	2022-06-01 04:13:17.436+00	\N	\N	(-81.1788179,34.9926548)	york county	sc	us	t	-81.4923938	35.1648848	-80.865242	34.8204248
OxUloAe6XA	2022-06-01 04:13:17.78+00	2022-06-01 04:13:17.88+00	\N	\N	(-79.67443685,43.60802525)	mississauga	on	ca	t	-79.8103184	43.7370604	-79.5385553	43.4789901
ZrPkhgkMsi	2022-06-01 04:13:18.435+00	2022-06-01 04:13:18.535+00	\N	\N	(16.99177925,51.1263645)	wroclaw	lower silesian voivodeship	pl	t	16.8073393	51.2100604	17.1762192	51.0426686
lnOmfwRGDb	2022-06-01 04:13:18.838+00	2022-06-01 04:13:18.934+00	\N	\N	(-106.4153144,23.2313053)	mazatlán	sin	mx	t	-106.5753144	23.3913053	-106.2553144	23.0713053
tNOrKuXHcj	2022-06-01 04:13:19.137+00	2022-06-01 04:13:19.232+00	\N	\N	(-82.7205905,41.0549755)	willard	oh	us	t	-82.743566	41.075346	-82.697615	41.034605
t6EhsF5sSn	2022-06-01 04:13:19.498+00	2022-06-01 04:13:19.597+00	\N	\N	(-67.58002625,10.2149277)	parroquia pedro josé ovalles	aragua state	ve	t	-67.5971627	10.2273869	-67.5628898	10.2024685
zEJhdo6nJ2	2022-06-01 04:13:19.853+00	2022-06-01 04:13:19.952+00	\N	\N	(-119.34081945,50.23650505)	vernon	bc	ca	t	-119.4764321	50.3215156	-119.2052068	50.1514945
liKRcSRpsg	2022-06-01 04:13:20.104+00	2022-06-01 04:13:20.203+00	\N	\N	(-105.28720455,55.13227095)	la ronge	sk	ca	t	-105.3252614	55.1674784	-105.2491477	55.0970635
KmGZc6HoE6	2022-06-01 04:13:20.423+00	2022-06-01 04:13:20.522+00	\N	\N	(-93.45963475,44.845404450000004)	eden prairie	mn	us	t	-93.5208965	44.8922578	-93.398373	44.7985511
h3AqrFePG8	2022-06-01 04:13:20.752+00	2022-06-01 04:13:20.851+00	\N	\N	(-71.99197745000001,41.51661225)	preston	ct	us	t	-72.0810942	41.5696181	-71.9028607	41.4636064
jwBqqoLcVi	2022-06-01 04:13:21.185+00	2022-06-01 04:13:21.284+00	\N	\N	(-87.09927675,36.2484993)	cheatham county	tn	us	t	-87.2889615	36.4556866	-86.909592	36.041312
VlfckgQPd9	2022-06-01 04:13:21.601+00	2022-06-01 04:13:21.701+00	\N	\N	(-76.26782965,37.035387799999995)	hampton	va	us	t	-76.4513394	37.1513676	-76.0843199	36.919408
1G54Dym4i3	2022-06-01 04:13:22.03+00	2022-06-01 04:13:22.129+00	\N	\N	(101.63990369999999,3.03079645)	subang jaya	selangor	my	t	101.5488664	3.0853219	101.730941	2.976271
0gy8I80zAj	2022-06-01 04:13:22.372+00	2022-06-01 04:13:22.472+00	\N	\N	(-82.92983100000001,32.43158965000001)	laurens county	ga	us	t	-83.226536	32.71576	-82.633126	32.1474193
8dgkF8Y3wL	2022-06-01 04:13:22.743+00	2022-06-01 04:13:22.844+00	\N	\N	(-71.0615565,42.908437500000005)	kingston	nh	us	t	-71.125603	42.959287	-70.99751	42.857588
1JBDGfoAHR	2022-06-01 04:13:23.053+00	2022-06-01 04:13:23.153+00	\N	\N	(-76.25691954999999,36.28517855)	pasquotank county	nc	us	t	-76.4914411	36.5106702	-76.022398	36.0596869
boYsIn5G56	2022-06-01 04:13:23.348+00	2022-06-01 04:13:23.448+00	\N	\N	(-73.5862705,42.42465015)	town of chatham	ny	us	t	-73.65249	42.4922073	-73.520051	42.357093
3LSC7foE5i	2022-06-01 04:13:23.719+00	2022-06-01 04:13:23.818+00	\N	\N	(14.48337855,56.111123250000006)	bromölla kommun		se	t	14.3806359	56.239294	14.5861212	55.9829525
4ohdlcIEtI	2022-06-01 04:13:24.229+00	2022-06-01 04:13:24.329+00	\N	\N	(126.95732525,37.02115205)	pyeongtaek-si		kr	t	126.7607267	37.1447047	127.1539238	36.8975994
ClMzOskQOj	2022-06-01 04:13:24.659+00	2022-06-01 04:13:24.758+00	\N	\N	(27.4791364,-11.6584232)	kiwele	hk	cd	t	27.4706728	-11.6515411	27.4876	-11.6653053
9WoGEFzqfH	2022-06-01 04:13:25.053+00	2022-06-01 04:13:25.15+00	\N	\N	(-78.52362020000001,38.00027405)	albemarle county	va	us	t	-78.8393544	38.277965	-78.207886	37.7225831
70HDeH1urB	2022-06-01 04:13:25.452+00	2022-06-01 04:13:25.551+00	\N	\N	(-78.9984695,40.6423085)	cherryhill township	pa	us	t	-79.08926	40.709515	-78.907679	40.575102
0zopvq7Hld	2022-06-01 04:13:26.034+00	2022-06-01 04:13:26.133+00	\N	\N	(76.6220761,9.4891344)	changanassery	kl	in	t	76.4928915	9.5780053	76.7512607	9.4002635
RCeg3fNx9z	2022-06-01 04:13:26.411+00	2022-06-01 04:13:26.51+00	\N	\N	(42.761051300000005,36.8980165)	simele district	iraqi kurdistan region	iq	t	42.3781316	37.091032	43.143971	36.705001
4wN9RFxGOb	2022-06-01 04:13:26.767+00	2022-06-01 04:13:26.864+00	\N	\N	(-84.525856,35.8466102)	roane county	tn	us	t	-84.788895	36.0486814	-84.262817	35.644539
kFdpUF05F8	2022-06-01 04:13:27.176+00	2022-06-01 04:13:27.276+00	\N	\N	(23.5398662,37.93796735)	ampelakia municipal unit	attica	gr	t	23.5004755	37.9622624	23.5792569	37.9136723
gFUQFdlEEQ	2022-06-01 04:13:27.574+00	2022-06-01 04:13:27.674+00	\N	\N	(-81.3337839,32.34565415)	effingham county	ga	us	t	-81.5480108	32.5954223	-81.119557	32.095886
LIzcAzJvUY	2022-06-01 04:13:27.944+00	2022-06-01 04:13:28.044+00	\N	\N	(103.85903210000001,13.3617562)	siem reap	siem reap	kh	t	103.6990321	13.5217562	104.0190321	13.2017562
nWMtR5Eltv	2022-06-01 04:13:48.393+00	2022-06-01 04:13:48.493+00	\N	\N	(85.32078440000001,27.709634700000002)	kathmandu	bagmati pradesh	np	t	85.2680887	27.75132	85.3734801	27.6679494
wxsAE6yNiB	2022-06-01 04:13:48.804+00	2022-06-01 04:13:48.901+00	\N	\N	(-80.2166574,8.4735311)	distrito antón	coclé	pa	t	-80.3902674	8.6573825	-80.0430474	8.2896797
O4jsbjD2Nk	2022-06-01 04:13:49.099+00	2022-06-01 04:13:49.199+00	\N	\N	(-98.6875215,34.230380999999994)	grandfield	ok	us	t	-98.699737	34.240168	-98.675306	34.220594
De6T9MSvJR	2022-06-01 04:13:49.41+00	2022-06-01 04:13:49.51+00	\N	\N	(-111.91278804999999,40.90053665)	west bountiful	ut	us	t	-111.9336221	40.9178177	-111.891954	40.8832556
zwaY4v1AaS	2022-06-01 04:13:49.839+00	2022-06-01 04:13:49.939+00	\N	\N	(80.9346001,26.8381)	lucknow	up	in	t	80.7746001	26.9981	81.0946001	26.6781
Bby6l9RcE3	2022-06-01 04:13:50.245+00	2022-06-01 04:13:50.344+00	\N	\N	(-108.261417,32.772986)	silver city	nm	us	t	-108.298858	32.810707	-108.223976	32.735265
G4deKvO0Lt	2022-06-01 04:13:50.605+00	2022-06-01 04:13:50.705+00	\N	\N	(-88.73807049999999,36.282273)	weakley county	tn	us	t	-88.959839	36.502729	-88.516302	36.061817
Rn8cmrubet	2022-06-01 04:13:50.942+00	2022-06-01 04:13:51.041+00	\N	\N	(-76.8649525,40.800329500000004)	selinsgrove	pa	us	t	-76.88106	40.812793	-76.848845	40.787866
1hdUBfOkcx	2022-06-01 04:13:51.302+00	2022-06-01 04:13:51.4+00	\N	\N	(-104.96797135,40.53459905)	timnath	co	us	t	-104.9918487	40.5774565	-104.944094	40.4917416
rEuIGDqhBf	2022-06-01 04:13:51.597+00	2022-06-01 04:13:51.696+00	\N	\N	(-3.4587040499999997,36.95823325)	lanjarón	andalusia	es	t	-3.5247355	37.0423897	-3.3926726	36.8740768
TU6O8G5liL	2022-06-01 04:13:51.985+00	2022-06-01 04:13:52.085+00	\N	\N	(-80.9723055,34.00593715)	richland county	sc	us	t	-81.345314	34.268642	-80.599297	33.7432323
hEOmZwGOgU	2022-06-01 04:13:52.391+00	2022-06-01 04:13:52.49+00	\N	\N	(-117.88286299999999,35.1446095)	california city	ca	us	t	-118.134453	35.275181	-117.631273	35.014038
SgIYeXi3LW	2022-06-01 04:13:52.768+00	2022-06-01 04:13:52.866+00	\N	\N	(-72.9654457,45.283258599999996)	farnham	qc	ca	t	-73.0488569	45.3419322	-72.8820345	45.224585
o7wJjnN4AA	2022-06-01 04:13:53.212+00	2022-06-01 04:13:53.311+00	\N	\N	(-100.7350041,46.345513)	cannonball district	nd	us	t	-100.9235372	46.429294	-100.546471	46.261732
BACcrVArFN	2022-06-01 04:13:53.569+00	2022-06-01 04:13:53.669+00	\N	\N	(-77.85244685,34.088040199999995)	new hanover county	nc	us	t	-78.0296177	34.3892804	-77.675276	33.7868
0WU6UywYDM	2022-06-01 04:13:54.004+00	2022-06-01 04:13:54.103+00	\N	\N	(-91.84651635,45.84332605)	town of spooner	wi	us	t	-91.908078	45.872712	-91.7849547	45.8139401
EY430D8jpm	2022-06-01 04:13:54.417+00	2022-06-01 04:13:54.516+00	\N	\N	(-123.4211457,48.58202005)	central saanich	bc	ca	t	-123.4853576	48.613738	-123.3569338	48.5503021
rQo1k4CcCe	2022-06-01 04:13:54.851+00	2022-06-01 04:13:54.95+00	\N	\N	(-92.110685,46.764864700000004)	duluth	mn	us	t	-92.301192	46.880571	-91.920178	46.6491584
6kFYgjOQcC	2022-06-01 04:13:55.221+00	2022-06-01 04:13:55.32+00	\N	\N	(10.3852104,55.399722499999996)	odense	region of southern denmark	dk	t	10.2252104	55.5597225	10.5452104	55.2397225
Zf9Kmjmgip	2022-06-01 04:13:55.649+00	2022-06-01 04:13:55.746+00	\N	\N	(-87.86216005,42.314691350000004)	north chicago	il	us	t	-87.8996865	42.3417527	-87.8246336	42.28763
0rqWarTUu7	2022-06-01 04:13:55.963+00	2022-06-01 04:13:56.063+00	\N	\N	(-98.5193667,33.91603335)	wichita falls	tx	us	t	-98.6143877	33.9964124	-98.4243457	33.8356543
1FohuSZkEr	2022-06-01 04:13:56.326+00	2022-06-01 04:13:56.426+00	\N	\N	(-119.69116869999999,50.88587845)	chase	bc	ca	t	-119.709222	50.9655478	-119.6731154	50.8062091
B51FZ76CLY	2022-06-01 04:13:56.744+00	2022-06-01 04:13:56.844+00	\N	\N	(3.8299886499999998,46.305613449999996)	lenax	ara	fr	t	3.7828587	46.3311135	3.8771186	46.2801134
LAMKe1IiWS	2022-06-01 04:13:57.082+00	2022-06-01 04:13:57.181+00	\N	\N	(-73.6732035,40.65715)	lynbrook	ny	us	t	-73.690776	40.671297	-73.655631	40.643003
hX6tYE6m9f	2022-06-01 04:13:57.461+00	2022-06-01 04:13:57.56+00	\N	\N	(-83.43446,39.890533)	london	oh	us	t	-83.478923	39.921786	-83.389997	39.85928
JIyVOKVo9u	2022-06-01 04:13:57.825+00	2022-06-01 04:13:57.921+00	\N	\N	(101.2495699,3.340688)	kuala selangor	selangor	my	t	101.0895699	3.500688	101.4095699	3.180688
H41QDj7pDI	2022-06-01 04:13:58.226+00	2022-06-01 04:13:58.321+00	\N	\N	(-121.79648835,37.97544675)	antioch	ca	us	t	-121.8605884	38.0300593	-121.7323883	37.9208342
ZNBkgeCfFO	2022-06-01 04:13:58.952+00	2022-06-01 04:13:59.051+00	\N	\N	(-85.7049198,38.4368585)	clark county	in	us	t	-85.994949	38.606736	-85.4148906	38.266981
oAMbfm0BiJ	2022-06-01 04:13:59.493+00	2022-06-01 04:13:59.594+00	\N	\N	(-76.30254645,39.48960855)	harford county	md	us	t	-76.5694525	39.7212078	-76.0356404	39.2580093
6bmnYwYGQb	2022-06-01 04:13:59.925+00	2022-06-01 04:14:00.025+00	\N	\N	(32.7168218,-25.95086555)	maputo		mz	t	32.4399695	-25.8117064	32.9936741	-26.0900247
ZV1v2hV6sV	2022-06-01 04:14:00.313+00	2022-06-01 04:14:00.412+00	\N	\N	(-92.505444,39.428869)	randolph county	mo	us	t	-92.708321	39.61108	-92.302567	39.246658
h0XlHI2iDW	2022-06-01 04:14:00.812+00	2022-06-01 04:14:00.906+00	\N	\N	(-57.58847555,-38.0188522)	mar del plata	b	ar	t	-57.6591066	-37.9039649	-57.5178445	-38.1337395
mSRcr8kqRi	2022-06-01 04:14:01.366+00	2022-06-01 04:14:01.465+00	\N	\N	(26.859445,-31.02491)	maletswai local municipality	ec	za	t	26.42134	-30.59457	27.29755	-31.45525
wX796ztSGS	2022-06-01 04:14:01.773+00	2022-06-01 04:14:01.873+00	\N	\N	(17.0617457,59.35009355)	strängnäs kommun		se	t	16.6977002	59.5307135	17.4257912	59.1694736
W2bkcGELZw	2022-06-01 04:14:02.189+00	2022-06-01 04:14:02.288+00	\N	\N	(-83.6492195,41.39269795)	wood county	oh	us	t	-83.883736	41.6191209	-83.414703	41.166275
YVGsSA8D8z	2022-06-01 04:14:02.603+00	2022-06-01 04:14:02.703+00	\N	\N	(-75.51346699999999,39.156438)	dover	de	us	t	-75.586203	39.210681	-75.440731	39.102195
grbkbfkArH	2022-06-01 04:14:02.962+00	2022-06-01 04:14:03.061+00	\N	\N	(5.0744212,52.6316508)	hoorn	north holland	nl	t	5.0135367	52.6843655	5.1353057	52.5789361
JDszICH2sQ	2022-06-01 04:14:03.325+00	2022-06-01 04:14:03.425+00	\N	\N	(-121.8007485,47.8730042)	sultan	wa	us	t	-121.834285	47.8891474	-121.767212	47.856861
oLe7LGj4wG	2022-06-01 04:14:03.668+00	2022-06-01 04:14:03.768+00	\N	\N	(-97.58945005,33.231484050000006)	decatur	tx	us	t	-97.6230092	33.2652446	-97.5558909	33.1977235
Q8di8h3Mci	2022-06-01 04:14:04.44+00	2022-06-01 04:14:04.54+00	\N	\N	(-75.0392265,44.677443)	potsdam	ny	us	t	-75.182462	44.779367	-74.895991	44.575519
q1gYROFmat	2022-06-01 04:14:04.869+00	2022-06-01 04:14:04.967+00	\N	\N	(-123.229983,44.8505905)	monmouth	or	us	t	-123.250674	44.864552	-123.209292	44.836629
zr0F6hvkr7	2022-06-01 04:14:05.177+00	2022-06-01 04:14:05.277+00	\N	\N	(-106.79093420000001,34.687141600000004)	belen	nm	us	t	-106.8424864	34.744042	-106.739382	34.6302412
ye1DQya3Hc	2022-06-01 04:14:05.806+00	2022-06-01 04:14:05.905+00	\N	\N	(-82.10948450000001,37.743679900000004)	mingo county	wv	us	t	-82.420484	37.9747792	-81.798485	37.5125806
PfNieSmB6R	2022-06-01 04:14:06.248+00	2022-06-01 04:14:06.347+00	\N	\N	(-9.001929050000001,52.843463)	county clare	ennis municipal district	ie	t	-9.1430006	52.9240611	-8.8608575	52.7628649
gApw1z4MZT	2022-06-01 04:14:06.713+00	2022-06-01 04:14:06.812+00	\N	\N	(-76.73113535,39.96767)	york	pa	us	t	-76.762814	39.992584	-76.6994567	39.942756
4yTBbTpkZI	2022-06-01 04:14:07.168+00	2022-06-01 04:14:07.266+00	\N	\N	(-76.19769600000001,43.02144)	onondaga county	ny	us	t	-76.499568	43.271593	-75.895824	42.771287
LKA9Mbu1lt	2022-06-01 04:14:07.82+00	2022-06-01 04:14:07.919+00	\N	\N	(-2.46370675,53.6991864)	blackburn with darwen	eng	gb	t	-2.5647705	53.7818047	-2.362643	53.6165681
ddwqUDC6Lp	2022-06-01 04:14:08.088+00	2022-06-01 04:14:08.187+00	\N	\N	(-77.5164054,45.616788549999995)	killaloe, hagarty and richards	on	ca	t	-77.6715216	45.7642446	-77.3612892	45.4693325
mHYUCqiANV	2022-06-01 04:14:08.422+00	2022-06-01 04:14:08.522+00	\N	\N	(-78.73281850000001,41.42719700000001)	ridgway	pa	us	t	-78.752668	41.438979	-78.712969	41.415415
U3umKchPE6	2022-06-01 04:14:08.773+00	2022-06-01 04:14:08.872+00	\N	\N	(-116.7272171,33.7435001)	idyllwild-pine cove	ca	us	t	-116.7690821	33.7816426	-116.6853521	33.7053576
g1ANrDB2Eu	2022-06-01 04:14:09.252+00	2022-06-01 04:14:09.352+00	\N	\N	(-71.5787097,41.1893434)	new shoreham	ri	us	t	-71.6129322	41.2321241	-71.5444872	41.1465627
yk34su3ZCZ	2022-06-01 04:14:09.664+00	2022-06-01 04:14:09.763+00	\N	\N	(-86.34374249999999,37.4719245)	grayson county	ky	us	t	-86.668488	37.623037	-86.018997	37.320812
n0qBH9eAyV	2022-06-01 04:14:10.006+00	2022-06-01 04:14:10.105+00	\N	\N	(-87.95351260000001,44.4618376)	bellevue	wi	us	t	-88.019902	44.4891597	-87.8871232	44.4345155
46jXuwIQeI	2022-06-01 04:14:10.34+00	2022-06-01 04:14:10.44+00	\N	\N	(-83.2408602,40.206978750000005)	millcreek township	oh	us	t	-83.310446	40.24461	-83.1712744	40.1693475
GlBVB2lhJb	2022-06-01 04:14:10.702+00	2022-06-01 04:14:10.802+00	\N	\N	(-75.34444785,40.43889425)	quakertown	pa	us	t	-75.3698875	40.4516181	-75.3190082	40.4261704
9AUPsBGyZ5	2022-06-01 04:14:11.048+00	2022-06-01 04:14:11.147+00	\N	\N	(-79.5139994,34.83683945)	scotland county	nc	us	t	-79.6929688	35.0432988	-79.33503	34.6303801
jM9LD6YQAn	2022-06-01 04:14:11.342+00	2022-06-01 04:14:11.443+00	\N	\N	(-84.42369135000001,42.20383845)	summit township	mi	us	t	-84.4831759	42.2475502	-84.3642068	42.1601267
T8wqFoXkZB	2022-06-01 04:14:11.658+00	2022-06-01 04:14:11.758+00	\N	\N	(-88.3983995,35.668097)	lexington	tn	us	t	-88.451128	35.725098	-88.345671	35.611096
QTEJ8Rbid0	2022-06-01 04:14:12.12+00	2022-06-01 04:14:12.22+00	\N	\N	(-101.1147331,19.98709025)	cuitzeo	michoacán	mx	t	-101.2107956	20.0978275	-101.0186706	19.876353
uwAupNfnNz	2022-06-01 04:14:12.459+00	2022-06-01 04:14:12.559+00	\N	\N	(-77.641873,43.057019499999996)	town of henrietta	ny	us	t	-77.730305	43.096835	-77.553441	43.017204
0XJN34TvVc	2022-06-01 04:14:12.792+00	2022-06-01 04:14:12.891+00	\N	\N	(25.315798,42.8710344)	gabrovo	5300	bg	t	25.155798	43.0310344	25.475798	42.7110344
XkPYJfGsu5	2022-06-01 04:14:13.222+00	2022-06-01 04:14:13.322+00	\N	\N	(-73.526937,42.6882315)	town of poestenkill	ny	us	t	-73.621074	42.723155	-73.4328	42.653308
E5r4Sz3LzH	2022-06-01 04:14:13.633+00	2022-06-01 04:14:13.732+00	\N	\N	(-84.1387038,40.78154565)	allen county	oh	us	t	-84.397568	40.9204333	-83.8798396	40.642658
aZpW24KFwI	2022-06-01 04:14:13.959+00	2022-06-01 04:14:14.058+00	\N	\N	(29.3177099,-28.7605531)	okhahlamba local municipality	nl	za	t	28.8734799	-28.3719	29.7619399	-29.1492062
rdtmAYIcgo	2022-06-01 04:14:14.292+00	2022-06-01 04:14:14.39+00	\N	\N	(-112.035969,43.49538)	idaho falls	id	us	t	-112.097687	43.558954	-111.974251	43.431806
dSvDx8MCLs	2022-06-01 04:14:14.946+00	2022-06-01 04:14:15.046+00	\N	\N	(-103.1821329,44.0658552)	rapid city	sd	us	t	-103.3263526	44.1367886	-103.0379132	43.9949218
k9R2jcGZdq	2022-06-01 04:14:15.301+00	2022-06-01 04:14:15.4+00	\N	\N	(-87.83475775,41.486443449999996)	frankfort	il	us	t	-87.9071764	41.5316294	-87.7623391	41.4412575
LRc6jzQjuM	2022-06-01 04:14:15.662+00	2022-06-01 04:14:15.759+00	\N	\N	(-74.7742428,40.21606595)	trenton	nj	us	t	-74.8195816	40.248298	-74.728904	40.1838339
wqPNJx9M9P	2022-06-01 04:14:16.405+00	2022-06-01 04:14:16.504+00	\N	\N	(144.7084345,-36.3233755)	shire of campaspe	vic	au	t	144.259311	-35.884139	145.157558	-36.762612
Z3pOwkTSUR	2022-06-01 04:14:17.209+00	2022-06-01 04:14:17.309+00	\N	\N	(-120.45539805,35.34708645)	san luis obispo county	ca	us	t	-121.438176	35.796655	-119.4726201	34.8975179
4oMafYEosE	2022-06-01 04:14:17.635+00	2022-06-01 04:14:17.735+00	\N	\N	(-6.2347709,53.494101900000004)	fingal		ie	t	-6.4750377	53.6347143	-5.9945041	53.3534895
UFpsUoWYdB	2022-06-01 04:14:18.058+00	2022-06-01 04:14:18.158+00	\N	\N	(14.3488322,45.3769734)	grad kastav	51215	hr	t	14.3245866	45.4008942	14.3730778	45.3530526
0w5qWq8yQw	2022-06-01 04:14:18.38+00	2022-06-01 04:14:18.481+00	\N	\N	(-93.8841321,33.2632673)	fouke	ar	us	t	-93.8992058	33.2725628	-93.8690584	33.2539718
Mhz6INjZob	2022-06-01 04:14:18.726+00	2022-06-01 04:14:18.826+00	\N	\N	(-91.81492,18.651739)	ciudad del carmen	cam	mx	t	-91.97492	18.811739	-91.65492	18.491739
fQLpDDp6XP	2022-06-01 04:14:19.126+00	2022-06-01 04:14:19.226+00	\N	\N	(80.3217588,26.4609135)	kanpur	up	in	t	80.1617588	26.6209135	80.4817588	26.3009135
iu5VvzWA6W	2022-06-01 04:14:19.574+00	2022-06-01 04:14:19.674+00	\N	\N	(-111.35899425,56.724105800000004)	fort mcmurray	ab	ca	t	-111.5109382	56.8044658	-111.2070503	56.6437458
8Srx52BTE2	2022-06-01 04:14:19.98+00	2022-06-01 04:14:20.079+00	\N	\N	(11.972235600000001,51.4728062)	halle (saale)	saxony-anhalt	de	t	11.8552541	51.5435116	12.0892171	51.4021008
czoYf5UAPo	2022-06-01 04:14:20.51+00	2022-06-01 04:14:20.607+00	\N	\N	(6.1259883,50.97362355)	geilenkirchen	north rhine-westphalia	de	t	6.0150734	51.0173661	6.2369032	50.929881
trHYRzwHf3	2022-06-01 04:14:20.879+00	2022-06-01 04:14:20.978+00	\N	\N	(-81.54491680000001,35.37403055)	cleveland county	nc	us	t	-81.7681019	35.5845819	-81.3217317	35.1634792
qp2rv78Pio	2022-06-01 04:14:21.272+00	2022-06-01 04:14:21.371+00	\N	\N	(-97.36218170000001,35.246821)	norman	ok	us	t	-97.5474454	35.348324	-97.176918	35.145318
wd3PGU1uSL	2022-06-01 04:14:21.724+00	2022-06-01 04:14:21.823+00	\N	\N	(-96.96379669999999,30.78427405)	milam county	tx	us	t	-97.3154661	31.1112617	-96.6121273	30.4572864
5brFogvbbO	2022-06-01 04:14:22.153+00	2022-06-01 04:14:22.253+00	\N	\N	(-76.7869033,40.055781249999995)	conewago township	pa	us	t	-76.8479084	40.1107854	-76.7258982	40.0007771
CIZY2yyXCp	2022-06-01 04:14:22.513+00	2022-06-01 04:14:22.61+00	\N	\N	(-15.45939335,28.1028686)	las palmas de gran canaria		es	t	-15.525324	28.181426	-15.3934627	28.0243112
Vhnw1x11Ab	2022-06-01 04:14:22.948+00	2022-06-01 04:14:23.048+00	\N	\N	(-112.18682995,33.276558550000004)	maricopa county	az	us	t	-113.333755	34.0481432	-111.0399049	32.5049739
hXJ9q0oHkP	2022-06-01 04:14:23.339+00	2022-06-01 04:14:23.439+00	\N	\N	(-93.6100828,42.026444600000005)	ames	ia	us	t	-93.6987324	42.0779587	-93.5214332	41.9749305
SOr3nBlw3i	2022-06-01 04:14:23.788+00	2022-06-01 04:14:23.886+00	\N	\N	(-81.24563645,41.907812050000004)	lake county	oh	us	t	-81.4886902	42.2459537	-81.0025827	41.5696704
YmaxCJ4cd6	2022-06-01 04:14:24.157+00	2022-06-01 04:14:24.255+00	\N	\N	(-75.37508395,39.8465785)	chester	pa	us	t	-75.4080803	39.8758445	-75.3420876	39.8173125
mUVhApETZV	2022-06-01 04:14:26.525+00	2022-06-01 04:14:26.624+00	\N	\N	(-56.22695015,-34.819954300000006)	montevideo	mo	uy	t	-56.4313997	-34.7018526	-56.0225006	-34.938056
vv9RVfJK4C	2022-06-01 04:14:27.021+00	2022-06-01 04:14:27.121+00	\N	\N	(-123.36931675,48.49569585)	saanich	bc	ca	t	-123.477976	48.5580058	-123.2606575	48.4333859
TGVi6RpZWQ	2022-06-01 04:14:27.474+00	2022-06-01 04:14:27.574+00	\N	\N	(-113.25538465,37.231008349999996)	la verkin	ut	us	t	-113.2921994	37.273325	-113.2185699	37.1886917
S0nNejqcL2	2022-06-01 04:14:27.859+00	2022-06-01 04:14:27.959+00	\N	\N	(-79.9434655,39.624702)	morgantown	wv	us	t	-79.98816	39.675097	-79.898771	39.574307
kAkLtH1aeZ	2022-06-01 04:14:28.57+00	2022-06-01 04:14:28.67+00	\N	\N	(30.30525445,59.917442449999996)	saint petersburg	saint petersburg	ru	t	30.0433427	60.0907368	30.5671662	59.7441481
DA3QeGIclL	2022-06-01 04:14:28.891+00	2022-06-01 04:14:28.99+00	\N	\N	(-102.63373229999999,32.74112315)	gaines county	tx	us	t	-103.0648409	32.959312	-102.2026237	32.5229343
Z8LHH79PH6	2022-06-01 04:14:24.52+00	2022-06-01 04:14:24.619+00	\N	\N	(-120.94954684999999,44.0022651)	deschutes county	or	us	t	-122.0025141	44.3934732	-119.8965796	43.611057
XDdEaUvmYs	2022-06-01 04:14:24.905+00	2022-06-01 04:14:25.005+00	\N	\N	(28.6157125,-26.783925)	dipaleseng local municipality	mp	za	t	28.243465	-26.50089	28.98796	-27.06696
ID2cojJCp9	2022-06-01 04:14:25.434+00	2022-06-01 04:14:25.534+00	\N	\N	(77.37098445000001,28.29168005)	ballabgarh	hr	in	t	77.1915386	28.3875137	77.5504303	28.1958464
xuBnNRQAkM	2022-06-01 04:14:25.909+00	2022-06-01 04:14:26.01+00	\N	\N	(-70.616791,43.971734100000006)	naples	me	us	t	-70.6894872	44.0321574	-70.5440948	43.9113108
hHqLzoKioj	2022-06-01 04:14:28.141+00	2022-06-01 04:14:28.237+00	\N	\N	(-73.808873,42.747687)	town of colonie	ny	us	t	-73.933546	42.822542	-73.6842	42.672832
HMEdXOR0sH	2022-06-01 04:14:55.604+00	2022-06-01 04:14:55.704+00	\N	\N	(-90.0026725,40.390237)	liverpool	il	us	t	-90.007934	40.392478	-89.997411	40.387996
NVyzpBLmna	2022-06-01 04:14:55.999+00	2022-06-01 04:14:56.099+00	\N	\N	(34.8603758,32.3041939)	netanya	center district	il	t	34.8247416	32.3534834	34.89601	32.2549044
1XCvlG2k8R	2022-06-01 04:14:56.447+00	2022-06-01 04:14:56.547+00	\N	\N	(110.3439862,1.5574127)	kuching	sarawak	my	t	110.1839862	1.7174127	110.5039862	1.3974127
5yBG24iRQc	2022-06-01 04:14:56.951+00	2022-06-01 04:14:57.051+00	\N	\N	(-80.6395556,41.09448315)	youngstown	oh	us	t	-80.7111792	41.139013	-80.567932	41.0499533
fqBPWThJEB	2022-06-01 04:14:57.267+00	2022-06-01 04:14:57.367+00	\N	\N	(23.7013288,37.930304050000004)	municipality of palaio faliro	attica	gr	t	23.6785538	37.9433638	23.7241038	37.9172443
rS86HxMkFj	2022-06-01 04:14:57.815+00	2022-06-01 04:14:57.913+00	\N	\N	(-119.94352975000001,39.233273350000005)	incline village-crystal bay	nv	us	t	-120.0057276	39.301108	-119.8813319	39.1654387
gPd7ZDq1Gh	2022-06-01 04:14:58.173+00	2022-06-01 04:14:58.272+00	\N	\N	(-71.1255566,48.37699965)	ville de saguenay	qc	ca	t	-71.5637733	48.5662729	-70.6873399	48.1877264
wgQF161NHX	2022-06-01 04:14:58.564+00	2022-06-01 04:14:58.663+00	\N	\N	(-72.08257135,42.2693353)	north brookfield	ma	us	t	-72.1347845	42.3086976	-72.0303582	42.229973
gz2sTXkHFJ	2022-06-01 04:14:59.075+00	2022-06-01 04:14:59.17+00	\N	\N	(-82.18850090000001,36.5959685)	bristol	va	us	t	-82.3485009	36.7559685	-82.0285009	36.4359685
BzjOM7YYA1	2022-06-01 04:14:59.538+00	2022-06-01 04:14:59.638+00	\N	\N	(-96.56969125,33.19348425)	collin county	tx	us	t	-96.8440326	33.4054665	-96.2953499	32.981502
5Hv63IAfHl	2022-06-01 04:14:59.896+00	2022-06-01 04:14:59.995+00	\N	\N	(-94.94630725,38.5006445)	osawatomie	ks	us	t	-95.00203	38.53877	-94.8905845	38.462519
ftedLurVBI	2022-06-01 04:15:00.373+00	2022-06-01 04:15:00.473+00	\N	\N	(-43.8043725,-21.247136)	barbacena	mg	br	t	-44.028745	-21.118272	-43.58	-21.376
cytMcE8MWJ	2022-06-01 04:15:00.814+00	2022-06-01 04:15:00.914+00	\N	\N	(-122.75182889999999,53.92715215)	prince george	bc	ca	t	-122.8993696	54.0416899	-122.6042882	53.8126144
3dpTI2Awx0	2022-06-01 04:15:01.316+00	2022-06-01 04:15:01.415+00	\N	\N	(78.9006822,26.0817489)	lahar tahsil	mp	in	t	78.7730646	26.2576059	79.0282998	25.9058919
vI093s4nRm	2022-06-01 04:15:01.766+00	2022-06-01 04:15:01.865+00	\N	\N	(40.798523700000004,8.68068465)	west harerghe	oromia region	et	t	40.0260659	9.4820021	41.5709815	7.8793672
hRkz1lFmp4	2022-06-01 04:15:02.175+00	2022-06-01 04:15:02.274+00	\N	\N	(-80.73720804999999,36.761284149999994)	hillsville	va	us	t	-80.7832252	36.7898271	-80.6911909	36.7327412
DaDYPcWJIO	2022-06-01 04:15:02.601+00	2022-06-01 04:15:02.7+00	\N	\N	(-113.80811525,52.27932365)	red deer	ab	ca	t	-113.8977285	52.3429183	-113.718502	52.215729
ACBDwKqFDE	2022-06-01 04:15:02.994+00	2022-06-01 04:15:03.094+00	\N	\N	(121.0751393,14.366381)	san pedro	laguna	ph	t	121.0066135	14.4114052	121.1436651	14.3213568
bTW4wefis4	2022-06-01 04:15:03.358+00	2022-06-01 04:15:03.457+00	\N	\N	(-113.05360335,49.8864274)	nobleford	ab	ca	t	-113.0612416	49.8995173	-113.0459651	49.8733375
gO2Wbbhoh3	2022-06-01 04:15:03.746+00	2022-06-01 04:15:03.845+00	\N	\N	(-87.88445985,42.533448199999995)	pleasant prairie	wi	us	t	-87.968477	42.57425	-87.8004427	42.4926464
TlMusD3Gt7	2022-06-01 04:15:04.126+00	2022-06-01 04:15:04.226+00	\N	\N	(-74.4230695,40.6193465)	plainfield	nj	us	t	-74.463348	40.644191	-74.382791	40.594502
317dcYSKhE	2022-06-01 04:15:04.452+00	2022-06-01 04:15:04.552+00	\N	\N	(-70.7768404,-32.42290825)	cabildo	valparaiso region	cl	t	-71.1432257	-32.2111491	-70.4104551	-32.6346674
yOTBg7Ublk	2022-06-01 04:15:04.819+00	2022-06-01 04:15:04.919+00	\N	\N	(-89.23470180000001,43.180559599999995)	sun prairie	wi	us	t	-89.2882113	43.210558	-89.1811923	43.1505612
3od64zF0IH	2022-06-01 04:15:05.24+00	2022-06-01 04:15:05.34+00	\N	\N	(7.59362125,49.18765045000001)	pirmasens	rhineland-palatinate	de	t	7.5132617	49.2338706	7.6739808	49.1414303
YTFs23GIO1	2022-06-01 04:15:05.67+00	2022-06-01 04:15:05.769+00	\N	\N	(-84.32672160000001,43.95525775)	hay township	mi	us	t	-84.3663338	43.9975072	-84.2871094	43.9130083
kUcHnHi5lV	2022-06-01 04:15:06.079+00	2022-06-01 04:15:06.179+00	\N	\N	(26.487375,-26.832192499999998)	matlosana local municipality	north west	za	t	26.07676	-26.4835	26.89799	-27.180885
YYKeNjHedL	2022-06-01 04:15:06.453+00	2022-06-01 04:15:06.553+00	\N	\N	(-90.47906904999999,41.5665933)	bettendorf	ia	us	t	-90.5330175	41.6120794	-90.4251206	41.5211072
WVHMjXeacU	2022-06-01 04:15:06.781+00	2022-06-01 04:15:06.881+00	\N	\N	(-70.1428018,47.7390386)	la malbaie	qc	ca	t	-70.3855375	47.8859554	-69.9000661	47.5921218
FrFKOh8lC0	2022-06-01 04:15:07.056+00	2022-06-01 04:15:07.156+00	\N	\N	(-96.07795805,33.12338925)	hunt county	tx	us	t	-96.2973941	33.409591	-95.858522	32.8371875
ZlsI9Q36zx	2022-06-01 04:15:07.4+00	2022-06-01 04:15:07.499+00	\N	\N	(-83.88071844999999,43.5812487)	bay city	mi	us	t	-83.9161566	43.6238297	-83.8452803	43.5386677
8lqiG5uIFm	2022-06-01 04:15:07.829+00	2022-06-01 04:15:07.929+00	\N	\N	(-85.72940829999999,43.0735233)	alpine township	mi	us	t	-85.7892567	43.1180276	-85.6695599	43.029019
YxolBx0kQ9	2022-06-01 04:15:08.332+00	2022-06-01 04:15:08.431+00	\N	\N	(23.60205,-27.549325500000002)	ga-segonyana local municipality	nc	za	t	23.08548	-27.135831	24.11862	-27.96282
CWbiCVzq2g	2022-06-01 04:15:08.689+00	2022-06-01 04:15:08.789+00	\N	\N	(-97.8747305,36.3927555)	enid	ok	us	t	-97.984467	36.466801	-97.764994	36.31871
72Hs5H8cuC	2022-06-01 04:15:09.007+00	2022-06-01 04:15:09.107+00	\N	\N	(-77.98034899999999,39.1502325)	berryville	va	us	t	-77.998667	39.165986	-77.962031	39.134479
E3ZQUrIa0A	2022-06-01 04:15:09.394+00	2022-06-01 04:15:09.494+00	\N	\N	(-75.3140205,40.740952300000004)	nazareth	pa	us	t	-75.330709	40.7515446	-75.297332	40.73036
RyTtHcSq6E	2022-06-01 04:15:09.725+00	2022-06-01 04:15:09.825+00	\N	\N	(-105.00271845,40.7006162)	wellington	co	us	t	-105.0194063	40.7258778	-104.9860306	40.6753546
GDsEHC9ht4	2022-06-01 04:15:10.045+00	2022-06-01 04:15:10.143+00	\N	\N	(-84.4161075,37.4038065)	brodhead	ky	us	t	-84.431332	37.415923	-84.400883	37.39169
NadTyq2GFs	2022-06-01 04:15:10.562+00	2022-06-01 04:15:10.66+00	\N	\N	(-94.3081869,35.99275885)	prairie grove	ar	us	t	-94.3520715	36.024935	-94.2643023	35.9605827
RHgMRdfcaK	2022-06-01 04:15:10.895+00	2022-06-01 04:15:10.995+00	\N	\N	(-118.131924,34.6999025)	lancaster	ca	us	t	-118.325179	34.768855	-117.938669	34.63095
q489sxNI0q	2022-06-01 04:15:11.317+00	2022-06-01 04:15:11.416+00	\N	\N	(-93.06857450000001,45.0574165)	vadnais heights	mn	us	t	-93.106532	45.079279	-93.030617	45.035554
bBV2BJxLsr	2022-06-01 04:15:11.644+00	2022-06-01 04:15:11.744+00	\N	\N	(-116.21527805,33.74385575)	indio	ca	us	t	-116.3012664	33.8167124	-116.1292897	33.6709991
8g0LdbzF3m	2022-06-01 04:15:12.147+00	2022-06-01 04:15:12.247+00	\N	\N	(-111.54901269999999,41.077026849999996)	morgan county	ut	us	t	-111.876598	41.3740222	-111.2214274	40.7800315
88p2R7p8Gb	2022-06-01 04:15:12.47+00	2022-06-01 04:15:12.569+00	\N	\N	(-79.4322277,35.280542999999994)	moore county	nc	us	t	-79.7682274	35.5180096	-79.096228	35.0430764
roiUpA0UYP	2022-06-01 04:15:12.799+00	2022-06-01 04:15:12.899+00	\N	\N	(-81.731762,32.4030997)	bulloch county	ga	us	t	-82.030724	32.653408	-81.4328	32.1527914
J6wZOeB9kC	2022-06-01 04:15:13.231+00	2022-06-01 04:15:13.331+00	\N	\N	(-122.73207719999999,47.686062)	kitsap county	wa	us	t	-123.0321544	47.9695821	-122.432	47.4025419
gPMH7VHzP3	2022-06-01 04:15:13.644+00	2022-06-01 04:15:13.744+00	\N	\N	(-82.6097288,40.8575275)	jackson township	oh	us	t	-82.6484609	40.9013193	-82.5709967	40.8137357
n9bwF1f4dm	2022-06-01 04:15:14.037+00	2022-06-01 04:15:14.137+00	\N	\N	(-81.99769135,38.7521378)	mason county	wv	us	t	-82.2217007	39.0299191	-81.773682	38.4743565
OG83DY5SQV	2022-06-01 04:15:14.397+00	2022-06-01 04:15:14.497+00	\N	\N	(-113.7289606,52.40830085)	lacombe county	ab	ca	t	-114.5296358	52.5816362	-112.9282854	52.2349655
RFmiB3z9pz	2022-06-01 04:15:14.833+00	2022-06-01 04:15:14.933+00	\N	\N	(-76.9398233,36.6789137)	franklin	va	us	t	-76.9697993	36.7105	-76.9098473	36.6473274
mSgbVDjGqi	2022-06-01 04:15:15.118+00	2022-06-01 04:15:15.217+00	\N	\N	(-71.74535535000001,41.4703206)	hopkinton	ri	us	t	-71.803475	41.5541742	-71.6872357	41.386467
SaT482DS2Y	2022-06-01 04:15:15.549+00	2022-06-01 04:15:15.644+00	\N	\N	(-80.4639211,40.81863155)	darlington township	pa	us	t	-80.5193352	40.8521661	-80.408507	40.785097
HCpHTQknwD	2022-06-01 04:15:16.209+00	2022-06-01 04:15:16.31+00	\N	\N	(-75.41299910000001,5.804728000000001)	abejorral	ant	co	t	-75.5581084	5.9459904	-75.2678898	5.6634656
VBaVL5nvVj	2022-06-01 04:15:16.716+00	2022-06-01 04:15:16.816+00	\N	\N	(-75.33440905,6.43841695)	barbosa	ant	co	t	-75.4521915	6.5128884	-75.2166266	6.3639455
rF9NDwOq0t	2022-06-01 04:15:17.015+00	2022-06-01 04:15:17.115+00	\N	\N	(-85.62268405,43.51172965)	big prairie township	mi	us	t	-85.6829623	43.5554295	-85.5624058	43.4680298
WU0aWrs7wE	2022-06-01 04:15:17.337+00	2022-06-01 04:15:17.437+00	\N	\N	(-86.2587839,43.23654)	muskegon	mi	us	t	-86.3481957	43.269701	-86.1693721	43.203379
6yetU6WyBX	2022-06-01 04:15:17.741+00	2022-06-01 04:15:17.841+00	\N	\N	(-3.3650144500000003,39.45562245)	villafranca de los caballeros	castile-la mancha	es	t	-3.4359898	39.5132729	-3.2940391	39.397972
3DO1uMM9GQ	2022-06-01 04:15:18.048+00	2022-06-01 04:15:18.147+00	\N	\N	(-92.1443716,37.82502085)	saint robert	mo	us	t	-92.1925562	37.857022	-92.096187	37.7930197
732tlTqYjj	2022-06-01 04:15:18.582+00	2022-06-01 04:15:18.682+00	\N	\N	(-1.79013885,53.6422814)	kirklees	eng	gb	t	-2.009472	53.7648331	-1.5708057	53.5197297
pwhKyvUnqA	2022-06-01 04:15:18.948+00	2022-06-01 04:15:19.048+00	\N	\N	(-70.944353,43.0687817)	newmarket	nh	us	t	-71.013305	43.0902414	-70.875401	43.047322
mCMZVP0OE8	2022-06-01 04:15:19.314+00	2022-06-01 04:15:19.414+00	\N	\N	(144.84299049999998,13.576022)	dededo	gu	us	t	144.808145	13.654402	144.877836	13.497642
xz5qFWT0aA	2022-06-01 04:15:19.78+00	2022-06-01 04:15:19.879+00	\N	\N	(15.11866925,53.671931)	nowogard	west pomeranian voivodeship	pl	t	15.0755487	53.6928858	15.1617898	53.6509762
uKA4hrV2bK	2022-06-01 04:15:20.15+00	2022-06-01 04:15:20.249+00	\N	\N	(-88.277284,40.1129335)	champaign	il	us	t	-88.333345	40.16398	-88.221223	40.061887
RGZLL2TgT0	2022-06-01 04:15:20.678+00	2022-06-01 04:15:20.777+00	\N	\N	(26.07701005,-10.3575751)	lubudi	lu	cd	t	25.02238	-9.4822334	27.1316401	-11.2329168
fHFjB0RHDq	2022-06-01 04:15:21.077+00	2022-06-01 04:15:21.177+00	\N	\N	(-73.27699815,45.5281476)	saint-basile-le-grand	qc	ca	t	-73.3221679	45.5752089	-73.2318284	45.4810863
OIUovxLq8U	2022-06-01 04:15:21.371+00	2022-06-01 04:15:21.47+00	\N	\N	(-83.5744239,41.656558950000004)	toledo	oh	us	t	-83.694237	41.7328519	-83.4546108	41.580266
qOUCzy2L3n	2022-06-01 04:15:21.81+00	2022-06-01 04:15:21.913+00	\N	\N	(-92.21744445,37.813535)	pulaski county	mo	us	t	-92.4137169	38.024368	-92.021172	37.602702
GikuaWZZpS	2022-06-01 04:15:22.261+00	2022-06-01 04:15:22.357+00	\N	\N	(-83.5892714,41.77555495)	bedford township	mi	us	t	-83.6499971	41.8236019	-83.5285457	41.727508
GSYF3LfgVH	2022-06-01 04:15:22.543+00	2022-06-01 04:15:22.641+00	\N	\N	(-83.35819505,45.07671135)	alpena township	mi	us	t	-83.5260688	45.207129	-83.1903213	44.9462937
6Ew7M0P5Jl	2022-06-01 04:15:22.808+00	2022-06-01 04:15:22.908+00	\N	\N	(-79.14410425,41.84495)	warren	pa	us	t	-79.1765215	41.86488	-79.111687	41.82502
o6FgJ1Vzzc	2022-06-01 04:15:23.128+00	2022-06-01 04:15:23.228+00	\N	\N	(24.71648975,59.28068895)	saku parish		ee	t	24.5220789	59.3648955	24.9109006	59.1964824
Z9cjAFaOQC	2022-06-01 04:15:23.609+00	2022-06-01 04:15:23.709+00	\N	\N	(-76.58402355,39.4364416)	baltimore county	md	us	t	-76.8965564	39.7211988	-76.2714907	39.1516844
12Zvwk1GW2	2022-06-01 04:15:23.957+00	2022-06-01 04:15:24.054+00	\N	\N	(-75.0778584,41.0913312)	middle smithfield township	pa	us	t	-75.1891162	41.153318	-74.9666006	41.0293444
kDEspzzDBs	2022-06-01 04:15:24.431+00	2022-06-01 04:15:24.53+00	\N	\N	(-80.1823215,40.3184895)	cecil township	pa	us	t	-80.252657	40.369957	-80.111986	40.267022
rXt5guXCgl	2022-06-01 04:15:25.296+00	2022-06-01 04:15:25.395+00	\N	\N	(18.426005,-31.218456500000002)	matzikama local municipality	wc	za	t	17.75735	-30.43026	19.09466	-32.006653
STlv9SUvAd	2022-06-01 04:15:25.769+00	2022-06-01 04:15:25.869+00	\N	\N	(-93.42953449999999,36.643192)	kimberling city	mo	us	t	-93.452124	36.660582	-93.406945	36.625802
UU4hFmCw0n	2022-06-01 04:15:26.168+00	2022-06-01 04:15:26.267+00	\N	\N	(-83.91802949999999,38.0476434)	montgomery county	ky	us	t	-84.080238	38.1920388	-83.755821	37.903248
lYiED2pQ6V	2022-06-01 04:15:26.654+00	2022-06-01 04:15:26.75+00	\N	\N	(-91.0601305,33.393497499999995)	greenville	ms	us	t	-91.131229	33.451105	-90.989032	33.33589
HPDnYjEKHe	2022-06-01 04:15:27.282+00	2022-06-01 04:15:27.381+00	\N	\N	(-70.8674542,42.453768499999995)	swampscott	ma	us	t	-70.934111	42.4908413	-70.8007974	42.4166957
SQtL0rKH3q	2022-06-01 04:15:27.7+00	2022-06-01 04:15:27.8+00	\N	\N	(-16.4452875,15.371168449999999)	kébémer	louga region	sn	t	-16.4635823	15.3917654	-16.4269927	15.3505715
RnfGjAAiDj	2022-06-01 04:15:28.14+00	2022-06-01 04:15:28.24+00	\N	\N	(-79.81064655,42.95514365)	haldimand county	on	ca	t	-80.1854293	43.1322001	-79.4358638	42.7780872
NngcLqn9oQ	2022-06-01 04:15:28.492+00	2022-06-01 04:15:28.592+00	\N	\N	(-81.94861,26.55284)	lee county	fl	us	t	-82.33504	26.789551	-81.56218	26.316129
q3NOFINjVP	2022-06-01 04:15:28.797+00	2022-06-01 04:15:28.896+00	\N	\N	(-86.053612,34.0213204)	etowah county	al	us	t	-86.370041	34.2008438	-85.737183	33.841797
XhRYM37fmE	2022-06-01 04:15:29.103+00	2022-06-01 04:15:29.203+00	\N	\N	(-81.34682085,41.100312599999995)	brimfield township	oh	us	t	-81.392958	41.135743	-81.3006837	41.0648822
MIAqmKME8W	2022-06-01 04:15:29.415+00	2022-06-01 04:15:29.513+00	\N	\N	(-84.84063985,39.169871)	hidden valley	in	us	t	-84.861029	39.194174	-84.8202507	39.145568
OmdOaQTMF3	2022-06-01 04:15:29.726+00	2022-06-01 04:15:29.825+00	\N	\N	(-79.84511,41.395042000000004)	franklin	pa	us	t	-79.872759	41.417906	-79.817461	41.372178
9zAuhk3W3n	2022-06-01 04:15:30.016+00	2022-06-01 04:15:30.116+00	\N	\N	(-73.6243851,40.639992750000005)	town of hempstead	ny	us	t	-73.767023	40.7566859	-73.4817472	40.5232996
HQJfa6orPf	2022-06-01 04:15:30.374+00	2022-06-01 04:15:30.474+00	\N	\N	(-60.7969507,-31.6470847)	municipio de santo tomé	s	ar	t	-60.863422	-31.5896894	-60.7304794	-31.70448
x2nLPyXbF2	2022-06-01 04:15:30.84+00	2022-06-01 04:15:30.94+00	\N	\N	(-81.2672415,40.8368705)	louisville	oh	us	t	-81.303693	40.860146	-81.23079	40.813595
l7ShDPaa4P	2022-06-01 04:15:31.19+00	2022-06-01 04:15:31.286+00	\N	\N	(-121.95203615,49.135655549999996)	chilliwack	bc	ca	t	-122.1261538	49.2256076	-121.7779185	49.0457035
GPq8zxa0L6	2022-06-01 04:15:31.59+00	2022-06-01 04:15:31.69+00	\N	\N	(-80.2965805,26.1480278)	sunrise	fl	us	t	-80.36649	26.1937614	-80.226671	26.1022942
7FojyMWQ1c	2022-06-01 04:15:31.969+00	2022-06-01 04:15:32.069+00	\N	\N	(-85.35216299999999,37.348844)	campbellsville	ky	us	t	-85.386191	37.376592	-85.318135	37.321096
oh3AOL9e5B	2022-06-01 04:15:32.232+00	2022-06-01 04:15:32.33+00	\N	\N	(-95.78002599999999,34.919011499999996)	mcalester	ok	us	t	-95.836456	34.967205	-95.723596	34.870818
xcTgrCZKHs	2022-06-01 04:15:32.648+00	2022-06-01 04:15:32.749+00	\N	\N	(-105.6125461,32.6954081)	otero county	nm	us	t	-106.3774345	33.3906945	-104.8476577	32.0001217
zVJETbhYjz	2022-06-01 04:15:33.022+00	2022-06-01 04:15:33.122+00	\N	\N	(-108.27955595,38.4101525)	montrose county	co	us	t	-109.0601879	38.668553	-107.498924	38.151752
U4qduZ62yH	2022-06-01 04:15:33.387+00	2022-06-01 04:15:33.486+00	\N	\N	(-88.07042555000001,42.334036)	round lake park	il	us	t	-88.0877981	42.364771	-88.053053	42.303301
wpnhHuNi0g	2022-06-01 04:15:33.938+00	2022-06-01 04:15:34.038+00	\N	\N	(-65.81271435,18.34746085)	río grande	pr	us	t	-65.8768463	18.4231777	-65.7485824	18.271744
pH2XrjCV1K	2022-06-01 04:15:34.307+00	2022-06-01 04:15:34.407+00	\N	\N	(-74.59524545,41.3699815)	town of greenville	ny	us	t	-74.674308	41.422139	-74.5161829	41.317824
JgQ4xOdGu5	2022-06-01 04:15:34.707+00	2022-06-01 04:15:34.807+00	\N	\N	(-93.767038,38.372376)	clinton	mo	us	t	-93.796396	38.400726	-93.73768	38.344026
ew2UNK2QcC	2022-06-01 04:15:35.097+00	2022-06-01 04:15:35.197+00	\N	\N	(-86.87440459999999,41.7096315)	michigan city	in	us	t	-86.9327242	41.753454	-86.816085	41.665809
j7NF7z5YmK	2022-06-01 04:15:48.809+00	2022-06-01 04:15:48.908+00	\N	\N	(-93.4615085,45.0223521)	plymouth	mn	us	t	-93.522652	45.0664218	-93.400365	44.9782824
EA4QYmf4Bl	2022-06-01 04:15:49.257+00	2022-06-01 04:15:49.356+00	\N	\N	(132.4373215,34.4517845)	hiroshima		jp	t	132.178545	34.614767	132.696098	34.288802
CvZCCL5InQ	2022-06-01 04:15:49.672+00	2022-06-01 04:15:49.771+00	\N	\N	(-74.83208834999999,40.4349275)	east amwell township	nj	us	t	-74.916004	40.487775	-74.7481727	40.38208
gGzwWJb1xP	2022-06-01 04:15:50.136+00	2022-06-01 04:15:50.231+00	\N	\N	(-87.60973385,42.32370735000001)	lake county	il	us	t	-88.1995433	42.4956322	-87.0199244	42.1517825
4HfIOMeTlc	2022-06-01 04:15:50.487+00	2022-06-01 04:15:50.59+00	\N	\N	(-81.1401353,40.858147900000006)	washington township	oh	us	t	-81.193584	40.9023455	-81.0866866	40.8139503
cQyYsnAJWm	2022-06-01 04:15:57.421+00	2022-06-01 04:15:57.521+00	\N	\N	(-3.5341351000000003,50.868496199999996)	mid devon	eng	gb	t	-3.9259083	51.0338427	-3.1423619	50.7031497
luCX0v6qxr	2022-06-01 04:15:50.96+00	2022-06-01 04:15:51.06+00	\N	\N	(19.4682649,-34.1545725)	theewaterskloof local municipality	wc	za	t	18.9290698	-33.879455	20.00746	-34.42969
vIv3mqt3Dr	2022-06-01 04:15:51.314+00	2022-06-01 04:15:51.414+00	\N	\N	(-73.8970665,41.659551)	town of poughkeepsie	ny	us	t	-73.954725	41.737312	-73.839408	41.58179
XC4QEMZ2x6	2022-06-01 04:15:51.794+00	2022-06-01 04:15:51.894+00	\N	\N	(-88.432113,43.76400945)	fond du lac	wi	us	t	-88.497855	43.809213	-88.366371	43.7188059
d98d81VIjl	2022-06-01 04:15:52.216+00	2022-06-01 04:15:52.316+00	\N	\N	(-1.2593465,52.973367350000004)	broxtowe	eng	gb	t	-1.3363891	53.054465	-1.1823039	52.8922697
yKpV7OPVSa	2022-06-01 04:15:52.602+00	2022-06-01 04:15:52.702+00	\N	\N	(-82.82015609999999,42.430298)	grosse pointe shores	mi	us	t	-82.890018	42.468184	-82.7502942	42.392412
RJaZXUxxPV	2022-06-01 04:15:53.031+00	2022-06-01 04:15:53.131+00	\N	\N	(-82.010032,39.368399249999996)	athens county	oh	us	t	-82.298347	39.5564844	-81.721717	39.1803141
tK48X7j976	2022-06-01 04:15:53.363+00	2022-06-01 04:15:53.463+00	\N	\N	(-111.958825,43.591910999999996)	ucon	id	us	t	-111.973927	43.597508	-111.943723	43.586314
3RPjGxUzjX	2022-06-01 04:15:53.684+00	2022-06-01 04:15:53.783+00	\N	\N	(26.8318944,60.933800500000004)	kouvola	mainland finland	fi	t	26.2354153	61.2925945	27.4283735	60.5750065
9VUoufViNZ	2022-06-01 04:15:54.142+00	2022-06-01 04:15:54.242+00	\N	\N	(-97.7315694,33.71326855)	montague county	tx	us	t	-97.9790282	33.9928413	-97.4841106	33.4336958
CgB4dh8Y2U	2022-06-01 04:15:54.479+00	2022-06-01 04:15:54.578+00	\N	\N	(-75.0504688,39.38965715)	millville	nj	us	t	-75.1501146	39.44701	-74.950823	39.3323043
GAv6OKDRzm	2022-06-01 04:15:54.836+00	2022-06-01 04:15:54.936+00	\N	\N	(-111.6343295,40.11140415)	spanish fork	ut	us	t	-111.693955	40.1585793	-111.574704	40.064229
K0vuP73Smp	2022-06-01 04:15:55.218+00	2022-06-01 04:15:55.312+00	\N	\N	(-91.7154958,41.3366525)	washington county	ia	us	t	-91.947151	41.5116	-91.4838406	41.161705
rqFCRevK5w	2022-06-01 04:15:55.603+00	2022-06-01 04:15:55.701+00	\N	\N	(-105.6771004,53.216342499999996)	prince albert	sk	ca	t	-105.8171882	53.2633455	-105.5370126	53.1693395
kOXadGKBQw	2022-06-01 04:15:55.909+00	2022-06-01 04:15:56.007+00	\N	\N	(-104.63508575,50.4585707)	regina	sk	ca	t	-104.7781055	50.5207302	-104.492066	50.3964112
l1mHrvBCsX	2022-06-01 04:15:56.232+00	2022-06-01 04:15:56.33+00	\N	\N	(-123.3499509,44.046608750000004)	veneta	or	us	t	-123.3721487	44.0596909	-123.3277531	44.0335266
f8POjJEAn0	2022-06-01 04:15:56.589+00	2022-06-01 04:15:56.689+00	\N	\N	(9.82802765,44.107671550000006)	la spezia	lig	it	t	9.7637021	44.1515369	9.8923532	44.0638062
Fwz9IQ6tLK	2022-06-01 04:15:56.92+00	2022-06-01 04:15:57.019+00	\N	\N	(9.8414046,53.2435136)	handeloh	lower saxony	de	t	9.788965	53.2815312	9.8938442	53.205496
pXzHIlT2Fw	2022-06-01 04:15:57.805+00	2022-06-01 04:15:57.902+00	\N	\N	(-76.1230257,35.84298135)	tyrrell county	nc	us	t	-76.4060033	36.087958	-75.8400481	35.5980047
0cZO61HQZJ	2022-06-01 04:15:58.347+00	2022-06-01 04:15:58.446+00	\N	\N	(-94.336543,37.20614125)	jasper county	mo	us	t	-94.618505	37.3641355	-94.054581	37.048147
XLTpIEbcGt	2022-06-01 04:15:58.679+00	2022-06-01 04:15:58.776+00	\N	\N	(-76.52199089999999,41.77201225)	bradford county	pa	us	t	-76.9268708	42.0020265	-76.117111	41.541998
4Tya4iYeRG	2022-06-01 04:15:59.142+00	2022-06-01 04:15:59.244+00	\N	\N	(-0.7330901000000001,38.073880200000005)	rojales	valencian community	es	t	-0.7729207	38.1152789	-0.6932595	38.0324815
XrndRIfnBb	2022-06-01 04:15:59.594+00	2022-06-01 04:15:59.693+00	\N	\N	(-86.77903445000001,35.4817295)	marshall county	tn	us	t	-86.9609319	35.710838	-86.597137	35.252621
JSHbh1fAbR	2022-06-01 04:16:00.039+00	2022-06-01 04:16:00.134+00	\N	\N	(-80.10105820000001,42.10107605)	millcreek township	pa	us	t	-80.2120988	42.1731723	-79.9900176	42.0289798
N8LPgNcrOK	2022-06-01 04:16:09.324+00	2022-06-01 04:16:09.424+00	\N	\N	(-89.8607675,31.960328)	mendenhall	ms	us	t	-89.894444	31.984864	-89.827091	31.935792
h8e24O5Sa8	2022-06-01 04:16:09.666+00	2022-06-01 04:16:09.765+00	\N	\N	(10.05087595,57.462795549999996)	hjørring municipality	north denmark region	dk	t	9.6899199	57.6185429	10.411832	57.3070482
NZXm5Y03IX	2022-06-01 04:16:10.072+00	2022-06-01 04:16:10.172+00	\N	\N	(-82.74094945,41.92691825)	kingsville	on	ca	t	-82.8462179	42.1772809	-82.635681	41.6765556
ahuWejtT46	2022-06-01 04:16:10.464+00	2022-06-01 04:16:10.562+00	\N	\N	(-72.7313133,41.6856891)	newington	ct	us	t	-72.7622866	41.7244104	-72.70034	41.6469678
d9VHyOlnXC	2022-06-01 04:16:10.964+00	2022-06-01 04:16:11.064+00	\N	\N	(-105.223945,39.5236304)	jefferson county	co	us	t	-105.39915	39.9177868	-105.04874	39.129474
BwxqlBdq5P	2022-06-01 04:16:11.353+00	2022-06-01 04:16:11.452+00	\N	\N	(12.251014300000001,55.58775055)	greve municipality	region zealand	dk	t	12.1379675	55.6220659	12.3640611	55.5534352
JxWm01RpnT	2022-06-01 04:16:11.718+00	2022-06-01 04:16:11.818+00	\N	\N	(-75.3034445,42.313558)	town of sidney	ny	us	t	-75.41596	42.380026	-75.190929	42.24709
KMdEu5rrT2	2022-06-01 04:16:12.067+00	2022-06-01 04:16:12.167+00	\N	\N	(-120.21815000000001,55.75950475)	dawson creek	bc	ca	t	-120.2893486	55.7885881	-120.1469514	55.7304214
ndsxj0zGb9	2022-06-01 04:16:12.518+00	2022-06-01 04:16:12.615+00	\N	\N	(-93.65825765,45.23676545)	albertville	mn	us	t	-93.6845333	45.2525459	-93.631982	45.220985
k9QJj0mrP1	2022-06-01 04:16:12.861+00	2022-06-01 04:16:12.959+00	\N	\N	(-118.0847905,45.3241935)	la grande	or	us	t	-118.116694	45.346119	-118.052887	45.302268
CHkjPAPvJx	2022-06-01 04:16:13.102+00	2022-06-01 04:16:13.201+00	\N	\N	(-84.09646345,36.933551699999995)	corbin	ky	us	t	-84.142298	36.9658534	-84.0506289	36.90125
AXmjS4Fcou	2022-06-01 04:16:13.45+00	2022-06-01 04:16:13.55+00	\N	\N	(-88.18106705,35.2080374)	hardin county	tn	us	t	-88.380508	35.420647	-87.9816261	34.9954278
bhwlKjuDKL	2022-06-01 04:16:14.001+00	2022-06-01 04:16:14.101+00	\N	\N	(-87.3064905,36.0518725)	burns	tn	us	t	-87.350396	36.065268	-87.262585	36.038477
XAKbRkmiLu	2022-06-01 04:16:14.435+00	2022-06-01 04:16:14.534+00	\N	\N	(-81.54012985,41.24015944999999)	boston township	oh	us	t	-81.5908237	41.2777639	-81.489436	41.202555
VbWhsXgATQ	2022-06-01 04:16:14.737+00	2022-06-01 04:16:14.836+00	\N	\N	(-72.0075477,44.5448813)	lyndon	vt	us	t	-72.0835442	44.5984165	-71.9315512	44.4913461
XblD02o8jL	2022-06-01 04:16:15.062+00	2022-06-01 04:16:15.162+00	\N	\N	(-96.9557645,33.0427394)	lewisville	tx	us	t	-97.045663	33.1003548	-96.865866	32.985124
qnzXRnMs1v	2022-06-01 04:16:15.371+00	2022-06-01 04:16:15.471+00	\N	\N	(-77.54188500000001,41.138319)	bald eagle township	pa	us	t	-77.666237	41.19532	-77.417533	41.081318
n1cMHxsIyj	2022-06-01 04:16:15.711+00	2022-06-01 04:16:15.81+00	\N	\N	(-98.2040556,32.215158900000006)	erath county	tx	us	t	-98.5432168	32.5129542	-97.8648944	31.9173636
cqE2YV1wAu	2022-06-01 04:16:16.023+00	2022-06-01 04:16:16.123+00	\N	\N	(-71.6679022,42.81762855)	milford	nh	us	t	-71.729918	42.8666349	-71.6058864	42.7686222
vYcANIvURS	2022-06-01 04:16:16.45+00	2022-06-01 04:16:16.55+00	\N	\N	(-2.70823155,53.7270716)	south ribble	eng	gb	t	-2.870916	53.7828265	-2.5455471	53.6713167
QuEqu1HYtj	2022-06-01 04:16:16.767+00	2022-06-01 04:16:16.866+00	\N	\N	(-93.94850465,43.6751274)	faribault county	mn	us	t	-94.2490063	43.850636	-93.648003	43.4996188
i3HtMEdcHw	2022-06-01 04:16:17.207+00	2022-06-01 04:16:17.307+00	\N	\N	(29.32768995,-30.28826505)	greater kokstad local municipality	nl	za	t	29.01474	-29.9048001	29.6406399	-30.67173
uDcAwjWDtd	2022-06-01 04:16:17.497+00	2022-06-01 04:16:17.597+00	\N	\N	(-102.9693975,41.1330285)	sidney	ne	us	t	-102.998219	41.156508	-102.940576	41.109549
HWaQGoCTz1	2022-06-01 04:16:18.096+00	2022-06-01 04:16:18.196+00	\N	\N	(-3.87722335,56.5405242)	perth and kinross	sct	gb	t	-4.7204448	56.9486273	-3.0340019	56.1324211
s3saGC50BJ	2022-06-01 04:16:18.385+00	2022-06-01 04:16:18.485+00	\N	\N	(-82.89186815,42.49577885)	saint clair shores	mi	us	t	-82.9285963	42.540918	-82.85514	42.4506397
WBZbMBtQWS	2022-06-01 04:16:18.794+00	2022-06-01 04:16:18.894+00	\N	\N	(20.59328425,68.20812345)	kiruna kommun		se	t	17.8998001	69.0599699	23.2867684	67.356277
xobU3fw2du	2022-06-01 04:16:19.166+00	2022-06-01 04:16:19.267+00	\N	\N	(-106.82011015,32.4181607)	doña ana county	nm	us	t	-107.2997143	33.0528084	-106.340506	31.783513
L3CnJUuDUj	2022-06-01 04:16:20.169+00	2022-06-01 04:16:20.269+00	\N	\N	(7.33783605,50.61756750000001)	vettelschoß	rhineland-palatinate	de	t	7.3089831	50.6309638	7.366689	50.6041712
iCo35L2YZE	2022-06-01 04:16:20.703+00	2022-06-01 04:16:20.803+00	\N	\N	(31.5412799,-27.54070205)	uphongolo local municipality	nl	za	t	31.0324199	-27.24317	32.0501399	-27.8382341
KUWKi7i6L0	2022-06-01 04:16:21.011+00	2022-06-01 04:16:21.11+00	\N	\N	(-77.41174045,39.44050935)	frederick	md	us	t	-77.4781744	39.4885388	-77.3453065	39.3924799
1EUoOwEBhy	2022-06-01 04:16:21.438+00	2022-06-01 04:16:21.536+00	\N	\N	(-88.7328459,44.9867526)	town of menominee	wi	us	t	-88.9821408	45.1180123	-88.483551	44.8554929
yfabwLEo5T	2022-06-01 04:16:00.485+00	2022-06-01 04:16:00.585+00	\N	\N	(-73.7306615,42.643124)	city of rensselaer	ny	us	t	-73.758852	42.670598	-73.702471	42.61565
OFJ62wORq7	2022-06-01 04:16:01.014+00	2022-06-01 04:16:01.113+00	\N	\N	(-91.4813495,44.81780595)	eau claire	wi	us	t	-91.59482	44.879206	-91.367879	44.7564059
YOK930kQwE	2022-06-01 04:16:01.38+00	2022-06-01 04:16:01.48+00	\N	\N	(-83.81769750000001,39.4336265)	wilmington	oh	us	t	-83.8649	39.462084	-83.770495	39.405169
ovwuxKLNp3	2022-06-01 04:16:01.742+00	2022-06-01 04:16:01.841+00	\N	\N	(-75.5681005,40.8783815)	towamensing township	pa	us	t	-75.6358265	40.92865	-75.5003745	40.828113
F8WGNPOu3r	2022-06-01 04:16:02.086+00	2022-06-01 04:16:02.186+00	\N	\N	(-83.200545,29.5382195)	dixie county	fl	us	t	-83.481264	29.825449	-82.919826	29.25099
ExfIOm90A5	2022-06-01 04:16:02.455+00	2022-06-01 04:16:02.555+00	\N	\N	(-78.01372405000001,40.3836028)	union township	pa	us	t	-78.112972	40.4430706	-77.9144761	40.324135
PN2tabF9xD	2022-06-01 04:16:02.792+00	2022-06-01 04:16:02.89+00	\N	\N	(-81.0736254,46.5844458)	greater sudbury	on	ca	t	-81.5984276	46.973056	-80.5488232	46.1958356
M7C9QBLOHf	2022-06-01 04:16:03.342+00	2022-06-01 04:16:03.442+00	\N	\N	(-71.27459544999999,43.849768850000004)	tamworth	nh	us	t	-71.3598436	43.9246355	-71.1893473	43.7749022
zi3ACFH29O	2022-06-01 04:16:03.754+00	2022-06-01 04:16:03.854+00	\N	\N	(-98.2922682,49.9659588)	portage la prairie	mb	ca	t	-98.3387514	49.996962	-98.245785	49.9349556
CmURveyPWH	2022-06-01 04:16:04.05+00	2022-06-01 04:16:04.149+00	\N	\N	(-85.45466065,36.14176965)	putnam county	tn	us	t	-85.8093085	36.3050552	-85.1000128	35.9784841
1tP8eyfnPE	2022-06-01 04:16:04.338+00	2022-06-01 04:16:04.438+00	\N	\N	(-99.77513725,29.212775)	uvalde	tx	us	t	-99.8149373	29.241582	-99.7353372	29.183968
EweHdEYUf8	2022-06-01 04:16:04.696+00	2022-06-01 04:16:04.796+00	\N	\N	(-73.11878215,42.627107949999996)	adams	ma	us	t	-73.174283	42.6601734	-73.0632813	42.5940425
hf8CfaYVAM	2022-06-01 04:16:05.019+00	2022-06-01 04:16:05.119+00	\N	\N	(-82.37918669999999,40.858258199999995)	milton township	oh	us	t	-82.4212204	40.9021225	-82.337153	40.8143939
cJ4JgWXUyG	2022-06-01 04:16:06.378+00	2022-06-01 04:16:06.478+00	\N	\N	(-87.97875355,43.23624045)	mequon	wi	us	t	-88.0638299	43.280374	-87.8936772	43.1921069
q9E4NBCUUe	2022-06-01 04:16:07.134+00	2022-06-01 04:16:07.237+00	\N	\N	(-112.9572714,41.4995822)	box elder county	ut	us	t	-114.0413718	42.0015016	-111.873171	40.9976628
rSVhLSL46a	2022-06-01 04:16:08.272+00	2022-06-01 04:16:08.371+00	\N	\N	(-97.65014045000001,38.78393)	saline county	ks	us	t	-97.9286646	38.958507	-97.3716163	38.609353
vRIT8lF0lm	2022-06-01 04:16:08.656+00	2022-06-01 04:16:08.752+00	\N	\N	(-87.9811963,43.761309350000005)	town of plymouth	wi	us	t	-88.041195	43.804886	-87.9211976	43.7177327
2pCyERVHd2	2022-06-01 04:16:21.779+00	2022-06-01 04:16:21.879+00	\N	\N	(-98.28399155,30.5593508)	marble falls	tx	us	t	-98.3309175	30.628836	-98.2370656	30.4898656
agripGcuRG	2022-06-01 04:16:22.18+00	2022-06-01 04:16:22.28+00	\N	\N	(-82.9145115,42.584919)	clinton township	mi	us	t	-82.973317	42.630507	-82.855706	42.539331
1maQt5cIog	2022-06-01 04:16:22.604+00	2022-06-01 04:16:22.703+00	\N	\N	(-106.7161045,35.287149)	rio rancho	nm	us	t	-106.865206	35.39438	-106.567003	35.179918
GoTESoI5f7	2022-06-01 04:16:23.118+00	2022-06-01 04:16:23.216+00	\N	\N	(-93.8126384,38.748636)	johnson county	mo	us	t	-94.1293968	38.938137	-93.49588	38.559135
hc279Fe5Lk	2022-06-01 04:16:23.463+00	2022-06-01 04:16:23.563+00	\N	\N	(-78.01764795,37.1407692)	nottoway county	va	us	t	-78.239354	37.2963244	-77.7959419	36.985214
W0q9T9ulRz	2022-06-01 04:16:23.878+00	2022-06-01 04:16:23.978+00	\N	\N	(-95.2228545,36.2924845)	mayes county	ok	us	t	-95.4401261	36.510425	-95.0055829	36.074544
06Bci4AQUf	2022-06-01 04:16:24.156+00	2022-06-01 04:16:24.256+00	\N	\N	(-123.30773239999999,48.42973835)	oak bay	bc	ca	t	-123.3291302	48.4677261	-123.2863346	48.3917506
Y2di4PynW8	2022-06-01 04:16:24.625+00	2022-06-01 04:16:24.725+00	\N	\N	(51.434625999999994,25.296619)	al rayyan	ar rayyan	qa	t	51.274626	25.456619	51.594626	25.136619
R2OAEO6ibB	2022-06-01 04:16:25.054+00	2022-06-01 04:16:25.154+00	\N	\N	(-79.09428805,35.9277866)	carrboro	nc	us	t	-79.124678	35.9676121	-79.0638981	35.8879611
gcw2V9Fk6x	2022-06-01 04:16:25.373+00	2022-06-01 04:16:25.472+00	\N	\N	(-98.081521,29.070861999999998)	poth	tx	us	t	-98.101643	29.088142	-98.061399	29.053582
BSv95OTl07	2022-06-01 04:16:25.645+00	2022-06-01 04:16:25.742+00	\N	\N	(138.611829,-33.841432850000004)	clare	sa	au	t	138.5911467	-33.8146329	138.6325113	-33.8682328
KtQ5gsqryo	2022-06-01 04:16:26.022+00	2022-06-01 04:16:26.121+00	\N	\N	(-90.8892155,43.56029465)	viroqua	wi	us	t	-90.909762	43.5856463	-90.868669	43.534943
EIczS6GZWc	2022-06-01 04:16:26.415+00	2022-06-01 04:16:26.515+00	\N	\N	(7.6755868,45.07350495)	turin	piemont	it	t	7.5778348	45.1402175	7.7733388	45.0067924
Ep8XJht92G	2022-06-01 04:16:26.707+00	2022-06-01 04:16:26.803+00	\N	\N	(-77.59875455,39.8952145)	guilford township	pa	us	t	-77.7323851	39.940536	-77.465124	39.849893
nHLucZLbG7	2022-06-01 04:16:27.029+00	2022-06-01 04:16:27.125+00	\N	\N	(144.2181305,-37.059256500000004)	castlemaine	vic	au	t	144.187712	-37.033256	144.248549	-37.085257
UAFAOWWo15	2022-06-01 04:16:27.45+00	2022-06-01 04:16:27.55+00	\N	\N	(75.25151545,31.110945100000002)	shahkot tahsil	pb	in	t	75.0761745	31.231977	75.4268564	30.9899132
vZdVHyHtIv	2022-06-01 04:16:27.817+00	2022-06-01 04:16:27.917+00	\N	\N	(-80.3467155,42.01925995)	lake city	pa	us	t	-80.367008	42.0318099	-80.326423	42.00671
BXuTwHtj84	2022-06-01 04:16:28.318+00	2022-06-01 04:16:28.413+00	\N	\N	(-114.47248995000001,51.1896056)	town of cochrane	ab	ca	t	-114.5249218	51.225017	-114.4200581	51.1541942
hB5h7FkA6l	2022-06-01 04:16:28.628+00	2022-06-01 04:16:28.727+00	\N	\N	(-87.2686735,41.51417)	hobart	in	us	t	-87.317153	41.565151	-87.220194	41.463189
\.


--
-- Data for Name: input; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public.input ("objectId", "createdAt", "updatedAt", _rperm, _wperm, input, address, city) FROM stdin;
mT67UDCiRY	2022-04-24 03:28:03.684+00	2022-04-24 03:28:03.684+00	\N	\N	1415 brooklyn ave,ann arbor,mi,usa	XjmSvrEbGU	\N
03EaLw27NE	2022-04-24 03:28:19.956+00	2022-04-24 03:28:19.956+00	\N	\N	1415 brooklyn ave	XjmSvrEbGU	\N
y4h2YCteJm	2022-04-24 03:28:24.105+00	2022-04-24 03:28:24.105+00	\N	\N	1415 brooklyn	9yvuA2Fhif	\N
45WZs3FK98	2022-04-24 03:28:30.925+00	2022-04-24 03:28:30.925+00	\N	\N	75 leverett street,keene,nh	RaTuOuGf8r	\N
PG2eEiipvZ	2022-04-24 03:28:33.656+00	2022-04-24 03:28:33.656+00	\N	\N	73 leverett street,keene,nh	Cyn2YoWVHA	\N
V3CCbsclU9	2022-04-24 03:28:38.534+00	2022-04-24 03:28:38.534+00	\N	\N	75 leverett street,keene,nh,us	RaTuOuGf8r	\N
4JjHLGWIkX	2022-04-24 03:28:43.276+00	2022-04-24 03:28:43.276+00	\N	\N	8917 beeler dr,tampa,fl	xDjcIjfEdj	\N
bDX3Q2ykiM	2022-04-24 03:29:10.04+00	2022-04-24 03:29:10.04+00	\N	\N	8917 beeler,tampa,fl	xDjcIjfEdj	\N
LlwVSBL0XH	2022-04-24 03:29:15.3+00	2022-04-24 03:29:15.3+00	\N	\N	keene,nh	\N	LOopjfw47O
cfVsrdqhed	2022-04-24 03:29:22.813+00	2022-04-24 03:29:22.813+00	\N	\N	keene,nh,us	\N	LOopjfw47O
PFfDJ6jBlb	2022-04-25 11:00:28.197+00	2022-04-25 11:00:28.197+00	\N	\N	waco, tx	\N	aPpZ77iG3I
\.


--
-- Data for Name: my_location; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public.my_location (location) FROM stdin;
(-72.285824,42.9278053)
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: parse
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: parse
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: parse
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: parse
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: parse
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: parse
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: parse
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: _Audience _Audience_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Audience"
    ADD CONSTRAINT "_Audience_pkey" PRIMARY KEY ("objectId");


--
-- Name: _GlobalConfig _GlobalConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_GlobalConfig"
    ADD CONSTRAINT "_GlobalConfig_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Idempotency _Idempotency_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Idempotency"
    ADD CONSTRAINT "_Idempotency_pkey" PRIMARY KEY ("objectId");


--
-- Name: _JobSchedule _JobSchedule_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_JobSchedule"
    ADD CONSTRAINT "_JobSchedule_pkey" PRIMARY KEY ("objectId");


--
-- Name: _JobStatus _JobStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_JobStatus"
    ADD CONSTRAINT "_JobStatus_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Join:roles:_Role _Join:roles:_Role_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:roles:_Role"
    ADD CONSTRAINT "_Join:roles:_Role_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:users:_Role _Join:users:_Role_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:users:_Role"
    ADD CONSTRAINT "_Join:users:_Role_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _PushStatus _PushStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_PushStatus"
    ADD CONSTRAINT "_PushStatus_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Role _Role_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Role"
    ADD CONSTRAINT "_Role_pkey" PRIMARY KEY ("objectId");


--
-- Name: _SCHEMA _SCHEMA_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_SCHEMA"
    ADD CONSTRAINT "_SCHEMA_pkey" PRIMARY KEY ("className");


--
-- Name: _User _User_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_User"
    ADD CONSTRAINT "_User_pkey" PRIMARY KEY ("objectId");


--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY ("objectId");


--
-- Name: city city_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pkey PRIMARY KEY ("objectId");


--
-- Name: input input_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public.input
    ADD CONSTRAINT input_pkey PRIMARY KEY ("objectId");


--
-- Name: _Idempotency_unique_reqId; Type: INDEX; Schema: public; Owner: parse
--

CREATE UNIQUE INDEX "_Idempotency_unique_reqId" ON public."_Idempotency" USING btree ("reqId");


--
-- Name: _Role_unique_name; Type: INDEX; Schema: public; Owner: parse
--

CREATE UNIQUE INDEX "_Role_unique_name" ON public."_Role" USING btree (name);


--
-- Name: _User_unique_email; Type: INDEX; Schema: public; Owner: parse
--

CREATE UNIQUE INDEX "_User_unique_email" ON public."_User" USING btree (email);


--
-- Name: _User_unique_username; Type: INDEX; Schema: public; Owner: parse
--

CREATE UNIQUE INDEX "_User_unique_username" ON public."_User" USING btree (username);


--
-- Name: case_insensitive_email; Type: INDEX; Schema: public; Owner: parse
--

CREATE INDEX case_insensitive_email ON public."_User" USING btree (lower(email) varchar_pattern_ops);


--
-- Name: case_insensitive_username; Type: INDEX; Schema: public; Owner: parse
--

CREATE INDEX case_insensitive_username ON public."_User" USING btree (lower(username) varchar_pattern_ops);


--
-- Name: ttl; Type: INDEX; Schema: public; Owner: parse
--

CREATE INDEX ttl ON public."_Idempotency" USING btree (expire);


--
-- PostgreSQL database dump complete
--

