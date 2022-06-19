--
-- PostgreSQL database dump
--

-- Dumped from database version 12.9 (Ubuntu 12.9-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.9 (Ubuntu 12.9-0ubuntu0.20.04.1)

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

ALTER TABLE ONLY public."_User" DROP CONSTRAINT "fkey__User_lastConsent";
ALTER TABLE ONLY public."_Join:users:_Role" DROP CONSTRAINT "fkey__Join:users:_Role_relatedId";
ALTER TABLE ONLY public."_Join:users:_Role" DROP CONSTRAINT "fkey__Join:users:_Role_owningId";
ALTER TABLE ONLY public."_Join:spamUsers:_User" DROP CONSTRAINT "fkey__Join:spamUsers:_User_relatedId";
ALTER TABLE ONLY public."_Join:spamUsers:_User" DROP CONSTRAINT "fkey__Join:spamUsers:_User_owningId";
ALTER TABLE ONLY public."_Join:roles:_Role" DROP CONSTRAINT "fkey__Join:roles:_Role_relatedId";
ALTER TABLE ONLY public."_Join:roles:_Role" DROP CONSTRAINT "fkey__Join:roles:_Role_owningId";
ALTER TABLE ONLY public."_Join:members:PublicCell" DROP CONSTRAINT "fkey__Join:members:PublicCell_relatedId";
ALTER TABLE ONLY public."_Join:members:PublicCell" DROP CONSTRAINT "fkey__Join:members:PublicCell_owningId";
ALTER TABLE ONLY public."_Join:members:PrivateCell" DROP CONSTRAINT "fkey__Join:members:PrivateCell_relatedId";
ALTER TABLE ONLY public."_Join:members:PrivateCell" DROP CONSTRAINT "fkey__Join:members:PrivateCell_owningId";
ALTER TABLE ONLY public."_Join:friends:_User" DROP CONSTRAINT "fkey__Join:friends:_User_relatedId";
ALTER TABLE ONLY public."_Join:friends:_User" DROP CONSTRAINT "fkey__Join:friends:_User_owningId";
ALTER TABLE ONLY public."Response" DROP CONSTRAINT "fkey_Response_owner";
ALTER TABLE ONLY public."Response" DROP CONSTRAINT "fkey_Response_forwardedBy";
ALTER TABLE ONLY public."Response" DROP CONSTRAINT "fkey_Response_alert";
ALTER TABLE ONLY public."Request" DROP CONSTRAINT "fkey_Request_sentTo";
ALTER TABLE ONLY public."Request" DROP CONSTRAINT "fkey_Request_owner";
ALTER TABLE ONLY public."Request" DROP CONSTRAINT "fkey_Request_cell";
ALTER TABLE ONLY public."PushLog" DROP CONSTRAINT "fkey_PushLog_owner";
ALTER TABLE ONLY public."PublicCell" DROP CONSTRAINT "fkey_PublicCell_owner";
ALTER TABLE ONLY public."PrivateCell" DROP CONSTRAINT "fkey_PrivateCell_owner";
ALTER TABLE ONLY public."Alert" DROP CONSTRAINT "fkey_Alert_owner";
DROP INDEX public.ttl;
DROP INDEX public.case_insensitive_username;
DROP INDEX public.case_insensitive_email;
DROP INDEX public."_User_unique_username";
DROP INDEX public."_User_unique_email";
DROP INDEX public."_Role_unique_name";
DROP INDEX public."_Idempotency_unique_reqId";
ALTER TABLE ONLY public."_User" DROP CONSTRAINT "_User_pkey";
ALTER TABLE ONLY public."_Session" DROP CONSTRAINT "_Session_pkey";
ALTER TABLE ONLY public."_SCHEMA" DROP CONSTRAINT "_SCHEMA_pkey";
ALTER TABLE ONLY public."_Role" DROP CONSTRAINT "_Role_pkey";
ALTER TABLE ONLY public."_PushStatus" DROP CONSTRAINT "_PushStatus_pkey";
ALTER TABLE ONLY public."_Join:users:_Role" DROP CONSTRAINT "_Join:users:_Role_pkey";
ALTER TABLE ONLY public."_Join:spamUsers:_User" DROP CONSTRAINT "_Join:spamUsers:_User_pkey";
ALTER TABLE ONLY public."_Join:roles:_Role" DROP CONSTRAINT "_Join:roles:_Role_pkey";
ALTER TABLE ONLY public."_Join:members:PublicCell" DROP CONSTRAINT "_Join:members:PublicCell_pkey";
ALTER TABLE ONLY public."_Join:members:PrivateCell" DROP CONSTRAINT "_Join:members:PrivateCell_pkey";
ALTER TABLE ONLY public."_Join:friends:_User" DROP CONSTRAINT "_Join:friends:_User_pkey";
ALTER TABLE ONLY public."_JobStatus" DROP CONSTRAINT "_JobStatus_pkey";
ALTER TABLE ONLY public."_JobSchedule" DROP CONSTRAINT "_JobSchedule_pkey";
ALTER TABLE ONLY public."_Idempotency" DROP CONSTRAINT "_Idempotency_pkey";
ALTER TABLE ONLY public."_GlobalConfig" DROP CONSTRAINT "_GlobalConfig_pkey";
ALTER TABLE ONLY public."_Audience" DROP CONSTRAINT "_Audience_pkey";
ALTER TABLE ONLY public."Response" DROP CONSTRAINT "Response_pkey";
ALTER TABLE ONLY public."Request" DROP CONSTRAINT "Request_pkey";
ALTER TABLE ONLY public."PushLog" DROP CONSTRAINT "PushLog_pkey";
ALTER TABLE ONLY public."PublicCell" DROP CONSTRAINT "PublicCell_pkey";
ALTER TABLE ONLY public."PrivateCell" DROP CONSTRAINT "PrivateCell_pkey";
ALTER TABLE ONLY public."PrivacyPolicy" DROP CONSTRAINT "PrivacyPolicy_pkey";
ALTER TABLE ONLY public."Alert" DROP CONSTRAINT "Alert_pkey";
DROP VIEW public.counts;
DROP TABLE public."_User";
DROP TABLE public."_Session";
DROP TABLE public."_SCHEMA";
DROP TABLE public."_Role";
DROP TABLE public."_PushStatus";
DROP TABLE public."_Join:users:_Role";
DROP TABLE public."_Join:spamUsers:_User";
DROP TABLE public."_Join:roles:_Role";
DROP TABLE public."_Join:members:PublicCell";
DROP TABLE public."_Join:members:PrivateCell";
DROP TABLE public."_Join:friends:_User";
DROP TABLE public."_JobStatus";
DROP TABLE public."_JobSchedule";
DROP TABLE public."_Idempotency";
DROP TABLE public."_Hooks";
DROP TABLE public."_GlobalConfig";
DROP TABLE public."_Audience";
DROP TABLE public."Response";
DROP TABLE public."Request";
DROP TABLE public."PushLog";
DROP TABLE public."PublicCell";
DROP TABLE public."PrivateCell";
DROP TABLE public."PrivacyPolicy";
DROP TABLE public."Alert";
DROP FUNCTION public.json_object_set_key(json jsonb, key_to_set text, value_to_set anyelement);
DROP FUNCTION public.idempotency_delete_expired_records();
DROP FUNCTION public.array_remove("array" jsonb, "values" jsonb);
DROP FUNCTION public.array_contains_all_regex("array" jsonb, "values" jsonb);
DROP FUNCTION public.array_contains_all("array" jsonb, "values" jsonb);
DROP FUNCTION public.array_contains("array" jsonb, "values" jsonb);
DROP FUNCTION public.array_add_unique("array" jsonb, "values" jsonb);
DROP FUNCTION public.array_add("array" jsonb, "values" jsonb);
DROP EXTENSION postgis_topology;
DROP EXTENSION postgis;
DROP EXTENSION pgcrypto;
DROP SCHEMA topology;
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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


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
-- Name: Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."Alert" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "alertType" text,
    location point,
    status text,
    "isGlobal" boolean,
    "totalPatrolUsers" double precision,
    media text,
    note text,
    owner text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Alert" OWNER TO parse;

--
-- Name: PrivacyPolicy; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."PrivacyPolicy" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    version text,
    "versionCode" double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."PrivacyPolicy" OWNER TO parse;

--
-- Name: PrivateCell; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."PrivateCell" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    type double precision,
    owner text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."PrivateCell" OWNER TO parse;

--
-- Name: PublicCell; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."PublicCell" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    "isVerified" boolean,
    description text,
    category text,
    "verificationStatus" double precision,
    "cellType" double precision,
    location point,
    owner text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."PublicCell" OWNER TO parse;

--
-- Name: PushLog; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."PushLog" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    owner text,
    text text,
    "deviceToken" text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."PushLog" OWNER TO parse;

--
-- Name: Request; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."Request" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "entryFor" text,
    "to" text,
    status text,
    "sentTo" text,
    owner text,
    cell text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Request" OWNER TO parse;

--
-- Name: Response; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."Response" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    note text,
    "forwardedBy" text,
    "travelTime" text,
    "responseType" text,
    alert text,
    owner text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Response" OWNER TO parse;

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
-- Name: _Join:friends:_User; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:friends:_User" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:friends:_User" OWNER TO parse;

--
-- Name: _Join:members:PrivateCell; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:members:PrivateCell" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:members:PrivateCell" OWNER TO parse;

--
-- Name: _Join:members:PublicCell; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:members:PublicCell" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:members:PublicCell" OWNER TO parse;

--
-- Name: _Join:roles:_Role; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:roles:_Role" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:roles:_Role" OWNER TO parse;

--
-- Name: _Join:spamUsers:_User; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:spamUsers:_User" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:spamUsers:_User" OWNER TO parse;

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
-- Name: _Session; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Session" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "user" text,
    "installationId" text,
    "sessionToken" text,
    "expiresAt" timestamp with time zone,
    "createdWith" jsonb,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_Session" OWNER TO parse;

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
    _password_history jsonb,
    "firstName" text,
    "lastName" text,
    "mobileNumber" text,
    "emergencyContactName" text,
    "emergencyContactNumber" text,
    location point,
    "newPublicCellAlert" boolean,
    "otherMedicalConditions" text,
    allergies text,
    "bloodType" text,
    privilege text,
    "roleId" double precision,
    "imageName" double precision,
    "phoneVerified" boolean,
    "patrolMode" boolean,
    avatar text,
    "lastConsent" text
);


ALTER TABLE public."_User" OWNER TO parse;

--
-- Name: counts; Type: VIEW; Schema: public; Owner: parse
--

CREATE VIEW public.counts AS
 SELECT x.tab,
    x.cnt
   FROM ( SELECT 'Alert                      '::text AS tab,
            count(*) AS cnt
           FROM public."Alert"
        UNION
         SELECT 'PrivacyPolicy              '::text AS tab,
            count(*) AS cnt
           FROM public."PrivacyPolicy"
        UNION
         SELECT 'PrivateCell                '::text AS tab,
            count(*) AS cnt
           FROM public."PrivateCell"
        UNION
         SELECT 'PublicCell                 '::text AS tab,
            count(*) AS cnt
           FROM public."PublicCell"
        UNION
         SELECT 'PushLog                    '::text AS tab,
            count(*) AS cnt
           FROM public."PushLog"
        UNION
         SELECT 'Request                    '::text AS tab,
            count(*) AS cnt
           FROM public."Request"
        UNION
         SELECT 'Response                   '::text AS tab,
            count(*) AS cnt
           FROM public."Response"
        UNION
         SELECT '_Audience                  '::text AS tab,
            count(*) AS cnt
           FROM public."_Audience"
        UNION
         SELECT '_GlobalConfig              '::text AS tab,
            count(*) AS cnt
           FROM public."_GlobalConfig"
        UNION
         SELECT '_Hooks                     '::text AS tab,
            count(*) AS cnt
           FROM public."_Hooks"
        UNION
         SELECT '_Idempotency               '::text AS tab,
            count(*) AS cnt
           FROM public."_Idempotency"
        UNION
         SELECT '_JobSchedule               '::text AS tab,
            count(*) AS cnt
           FROM public."_JobSchedule"
        UNION
         SELECT '_JobStatus                 '::text AS tab,
            count(*) AS cnt
           FROM public."_JobStatus"
        UNION
         SELECT '_Join:friends:_User        '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:friends:_User"
        UNION
         SELECT '_Join:members:PrivateCell  '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:members:PrivateCell"
        UNION
         SELECT '_Join:members:PublicCell   '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:members:PublicCell"
        UNION
         SELECT '_Join:roles:_Role          '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:roles:_Role"
        UNION
         SELECT '_Join:spamUsers:_User      '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:spamUsers:_User"
        UNION
         SELECT '_Join:users:_Role          '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:users:_Role"
        UNION
         SELECT '_PushStatus                '::text AS tab,
            count(*) AS cnt
           FROM public."_PushStatus"
        UNION
         SELECT '_Role                      '::text AS tab,
            count(*) AS cnt
           FROM public."_Role"
        UNION
         SELECT '_SCHEMA                    '::text AS tab,
            count(*) AS cnt
           FROM public."_SCHEMA"
        UNION
         SELECT '_User                      '::text AS tab,
            count(*) AS cnt
           FROM public."_User") x
  ORDER BY x.tab;


ALTER TABLE public.counts OWNER TO parse;

--
-- Name: Alert Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_pkey" PRIMARY KEY ("objectId");


--
-- Name: PrivacyPolicy PrivacyPolicy_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."PrivacyPolicy"
    ADD CONSTRAINT "PrivacyPolicy_pkey" PRIMARY KEY ("objectId");


--
-- Name: PrivateCell PrivateCell_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."PrivateCell"
    ADD CONSTRAINT "PrivateCell_pkey" PRIMARY KEY ("objectId");


--
-- Name: PublicCell PublicCell_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."PublicCell"
    ADD CONSTRAINT "PublicCell_pkey" PRIMARY KEY ("objectId");


--
-- Name: PushLog PushLog_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."PushLog"
    ADD CONSTRAINT "PushLog_pkey" PRIMARY KEY ("objectId");


--
-- Name: Request Request_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Request"
    ADD CONSTRAINT "Request_pkey" PRIMARY KEY ("objectId");


--
-- Name: Response Response_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Response"
    ADD CONSTRAINT "Response_pkey" PRIMARY KEY ("objectId");


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
-- Name: _Join:friends:_User _Join:friends:_User_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:friends:_User"
    ADD CONSTRAINT "_Join:friends:_User_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:members:PrivateCell _Join:members:PrivateCell_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:members:PrivateCell"
    ADD CONSTRAINT "_Join:members:PrivateCell_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:members:PublicCell _Join:members:PublicCell_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:members:PublicCell"
    ADD CONSTRAINT "_Join:members:PublicCell_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:roles:_Role _Join:roles:_Role_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:roles:_Role"
    ADD CONSTRAINT "_Join:roles:_Role_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:spamUsers:_User _Join:spamUsers:_User_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:spamUsers:_User"
    ADD CONSTRAINT "_Join:spamUsers:_User_pkey" PRIMARY KEY ("relatedId", "owningId");


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
-- Name: _Session _Session_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Session"
    ADD CONSTRAINT "_Session_pkey" PRIMARY KEY ("objectId");


--
-- Name: _User _User_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_User"
    ADD CONSTRAINT "_User_pkey" PRIMARY KEY ("objectId");


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
-- Name: Alert fkey_Alert_owner; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "fkey_Alert_owner" FOREIGN KEY (owner) REFERENCES public."_User"("objectId");


--
-- Name: PrivateCell fkey_PrivateCell_owner; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."PrivateCell"
    ADD CONSTRAINT "fkey_PrivateCell_owner" FOREIGN KEY (owner) REFERENCES public."_User"("objectId");


--
-- Name: PublicCell fkey_PublicCell_owner; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."PublicCell"
    ADD CONSTRAINT "fkey_PublicCell_owner" FOREIGN KEY (owner) REFERENCES public."_User"("objectId");


--
-- Name: PushLog fkey_PushLog_owner; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."PushLog"
    ADD CONSTRAINT "fkey_PushLog_owner" FOREIGN KEY (owner) REFERENCES public."_User"("objectId");


--
-- Name: Request fkey_Request_cell; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Request"
    ADD CONSTRAINT "fkey_Request_cell" FOREIGN KEY (cell) REFERENCES public."PublicCell"("objectId");


--
-- Name: Request fkey_Request_owner; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Request"
    ADD CONSTRAINT "fkey_Request_owner" FOREIGN KEY (owner) REFERENCES public."_User"("objectId");


--
-- Name: Request fkey_Request_sentTo; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Request"
    ADD CONSTRAINT "fkey_Request_sentTo" FOREIGN KEY ("sentTo") REFERENCES public."_User"("objectId");


--
-- Name: Response fkey_Response_alert; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Response"
    ADD CONSTRAINT "fkey_Response_alert" FOREIGN KEY (alert) REFERENCES public."Alert"("objectId");


--
-- Name: Response fkey_Response_forwardedBy; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Response"
    ADD CONSTRAINT "fkey_Response_forwardedBy" FOREIGN KEY ("forwardedBy") REFERENCES public."_User"("objectId");


--
-- Name: Response fkey_Response_owner; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Response"
    ADD CONSTRAINT "fkey_Response_owner" FOREIGN KEY (owner) REFERENCES public."_User"("objectId");


--
-- Name: _Join:friends:_User fkey__Join:friends:_User_owningId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:friends:_User"
    ADD CONSTRAINT "fkey__Join:friends:_User_owningId" FOREIGN KEY ("owningId") REFERENCES public."_User"("objectId");


--
-- Name: _Join:friends:_User fkey__Join:friends:_User_relatedId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:friends:_User"
    ADD CONSTRAINT "fkey__Join:friends:_User_relatedId" FOREIGN KEY ("relatedId") REFERENCES public."_User"("objectId");


--
-- Name: _Join:members:PrivateCell fkey__Join:members:PrivateCell_owningId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:members:PrivateCell"
    ADD CONSTRAINT "fkey__Join:members:PrivateCell_owningId" FOREIGN KEY ("owningId") REFERENCES public."PrivateCell"("objectId");


--
-- Name: _Join:members:PrivateCell fkey__Join:members:PrivateCell_relatedId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:members:PrivateCell"
    ADD CONSTRAINT "fkey__Join:members:PrivateCell_relatedId" FOREIGN KEY ("relatedId") REFERENCES public."_User"("objectId");


--
-- Name: _Join:members:PublicCell fkey__Join:members:PublicCell_owningId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:members:PublicCell"
    ADD CONSTRAINT "fkey__Join:members:PublicCell_owningId" FOREIGN KEY ("owningId") REFERENCES public."PublicCell"("objectId");


--
-- Name: _Join:members:PublicCell fkey__Join:members:PublicCell_relatedId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:members:PublicCell"
    ADD CONSTRAINT "fkey__Join:members:PublicCell_relatedId" FOREIGN KEY ("relatedId") REFERENCES public."_User"("objectId");


--
-- Name: _Join:roles:_Role fkey__Join:roles:_Role_owningId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:roles:_Role"
    ADD CONSTRAINT "fkey__Join:roles:_Role_owningId" FOREIGN KEY ("owningId") REFERENCES public."_Role"("objectId");


--
-- Name: _Join:roles:_Role fkey__Join:roles:_Role_relatedId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:roles:_Role"
    ADD CONSTRAINT "fkey__Join:roles:_Role_relatedId" FOREIGN KEY ("relatedId") REFERENCES public."_Role"("objectId");


--
-- Name: _Join:spamUsers:_User fkey__Join:spamUsers:_User_owningId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:spamUsers:_User"
    ADD CONSTRAINT "fkey__Join:spamUsers:_User_owningId" FOREIGN KEY ("owningId") REFERENCES public."_User"("objectId");


--
-- Name: _Join:spamUsers:_User fkey__Join:spamUsers:_User_relatedId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:spamUsers:_User"
    ADD CONSTRAINT "fkey__Join:spamUsers:_User_relatedId" FOREIGN KEY ("relatedId") REFERENCES public."_User"("objectId");


--
-- Name: _Join:users:_Role fkey__Join:users:_Role_owningId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:users:_Role"
    ADD CONSTRAINT "fkey__Join:users:_Role_owningId" FOREIGN KEY ("owningId") REFERENCES public."_Role"("objectId");


--
-- Name: _Join:users:_Role fkey__Join:users:_Role_relatedId; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:users:_Role"
    ADD CONSTRAINT "fkey__Join:users:_Role_relatedId" FOREIGN KEY ("relatedId") REFERENCES public."_User"("objectId");


--
-- Name: _User fkey__User_lastConsent; Type: FK CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_User"
    ADD CONSTRAINT "fkey__User_lastConsent" FOREIGN KEY ("lastConsent") REFERENCES public."PrivacyPolicy"("objectId");


--
-- PostgreSQL database dump complete
--

