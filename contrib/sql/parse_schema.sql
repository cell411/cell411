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

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


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
-- Name: json_object_set_key(jsonb, text, anyelement); Type: FUNCTION; Schema: public; Owner: parse
--

CREATE FUNCTION public.json_object_set_key(json jsonb, key_to_set text, value_to_set anyelement) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT concat('{', string_agg(to_json("key") || ':' || "value", ','), '}')::jsonb FROM (SELECT * FROM jsonb_each("json") WHERE key <> key_to_set UNION ALL SELECT key_to_set, to_json("value_to_set")::jsonb) AS fields $$;


ALTER FUNCTION public.json_object_set_key(json jsonb, key_to_set text, value_to_set anyelement) OWNER TO parse;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AdditionalNote; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."AdditionalNote" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "cell411AlertId" text,
    note text,
    seen double precision,
    "writerId" text,
    "writerDuration" text,
    "writerName" text,
    "alertType" text,
    "forwardedBy" text,
    "cellId" text,
    "cellName" text,
    "userType" text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."AdditionalNote" OWNER TO parse;

--
-- Name: Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."Alert" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdBy" text,
    "problemType" text,
    location point,
    note text,
    "fileType" text,
    "fileLink" text,
    global boolean,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Alert" OWNER TO parse;

--
-- Name: Cell; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."Cell" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    "createdBy" text,
    type double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Cell" OWNER TO parse;

--
-- Name: Cell411Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."Cell411Alert" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "targetMembers" jsonb,
    "additionalNote" text,
    "alertType" text,
    "issuedBy" text,
    location point,
    "issuerId" text,
    "entryFor" text,
    "to" text,
    status text,
    "isGlobal" double precision,
    photo text,
    "dispatchMode" double precision,
    "forwardedToMembers" jsonb,
    "cellId" text,
    "cellName" text,
    "forwardedAlert" text,
    "forwardedBy" text,
    audience jsonb,
    "alertId" double precision,
    "totalPatrolUsers" double precision,
    _rperm text[],
    _wperm text[],
    "geoTag" point,
    "issuerFirstName" text
);


ALTER TABLE public."Cell411Alert" OWNER TO parse;

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
-- Name: PublicCell; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."PublicCell" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    "createdBy" text,
    "totalMembers" double precision,
    "geoTag" point,
    "isVerified" double precision,
    description text,
    category text,
    "verificationStatus" double precision,
    "cellType" double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."PublicCell" OWNER TO parse;

--
-- Name: Request; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."Request" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdBy" text,
    "requestType" text,
    "sentTo" text,
    status text,
    cell text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Request" OWNER TO parse;

--
-- Name: Task; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."Task" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "assigneeUserId" text,
    status text,
    task text,
    "userId" text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Task" OWNER TO parse;

--
-- Name: UserConsent; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."UserConsent" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "userId" text,
    "privacyPolicyId" text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."UserConsent" OWNER TO parse;

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
-- Name: _GraphQLConfig; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_GraphQLConfig" (
    "objectId" text NOT NULL,
    config jsonb
);


ALTER TABLE public."_GraphQLConfig" OWNER TO parse;

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
-- Name: _Installation; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Installation" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "installationId" text,
    "deviceToken" text,
    channels jsonb,
    "deviceType" text,
    "pushType" text,
    "GCMSenderId" text,
    "timeZone" text,
    "localeIdentifier" text,
    badge double precision,
    "appVersion" text,
    "appName" text,
    "appIdentifier" text,
    "parseVersion" text,
    _rperm text[],
    _wperm text[],
    "user" text
);


ALTER TABLE public."_Installation" OWNER TO parse;

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
-- Name: _Join:cellMembers:Cell411Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:cellMembers:Cell411Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:cellMembers:Cell411Alert" OWNER TO parse;

--
-- Name: _Join:friends:_User; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:friends:_User" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:friends:_User" OWNER TO parse;

--
-- Name: _Join:initiatedBy:Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:initiatedBy:Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:initiatedBy:Alert" OWNER TO parse;

--
-- Name: _Join:initiatedBy:Cell411Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:initiatedBy:Cell411Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:initiatedBy:Cell411Alert" OWNER TO parse;

--
-- Name: _Join:members:Cell; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:members:Cell" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:members:Cell" OWNER TO parse;

--
-- Name: _Join:members:PublicCell; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:members:PublicCell" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:members:PublicCell" OWNER TO parse;

--
-- Name: _Join:offered:Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:offered:Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:offered:Alert" OWNER TO parse;

--
-- Name: _Join:refused:Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:refused:Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:refused:Alert" OWNER TO parse;

--
-- Name: _Join:rejectedBy:Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:rejectedBy:Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:rejectedBy:Alert" OWNER TO parse;

--
-- Name: _Join:rejectedBy:Cell411Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:rejectedBy:Cell411Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:rejectedBy:Cell411Alert" OWNER TO parse;

--
-- Name: _Join:roles:_Role; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:roles:_Role" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:roles:_Role" OWNER TO parse;

--
-- Name: _Join:seenBy:Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:seenBy:Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:seenBy:Alert" OWNER TO parse;

--
-- Name: _Join:seenBy:Cell411Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:seenBy:Cell411Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:seenBy:Cell411Alert" OWNER TO parse;

--
-- Name: _Join:sentTo:Alert; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:sentTo:Alert" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:sentTo:Alert" OWNER TO parse;

--
-- Name: _Join:spamUsers:_User; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:spamUsers:_User" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:spamUsers:_User" OWNER TO parse;

--
-- Name: _Join:spammedBy:_User; Type: TABLE; Schema: public; Owner: parse
--

CREATE TABLE public."_Join:spammedBy:_User" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:spammedBy:_User" OWNER TO parse;

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
    restricted boolean,
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
    "PatrolMode" double precision,
    "emergencyContactNumber" text,
    location point,
    "otherMedicalConditions" text,
    allergies text,
    "bloodType" text,
    "newPublicCellAlert" double precision,
    "roleId" double precision,
    "imageName" double precision,
    "phoneVerified" boolean,
    privilege text
);


ALTER TABLE public."_User" OWNER TO parse;

--
-- Name: counts; Type: VIEW; Schema: public; Owner: parse
--

CREATE VIEW public.counts AS
 SELECT x.tab,
    x.cnt
   FROM ( SELECT 'AdditionalNote                  '::text AS tab,
            count(*) AS cnt
           FROM public."AdditionalNote"
        UNION
         SELECT 'Cell                            '::text AS tab,
            count(*) AS cnt
           FROM public."Cell"
        UNION
         SELECT 'Cell411Alert                    '::text AS tab,
            count(*) AS cnt
           FROM public."Cell411Alert"
        UNION
         SELECT 'PrivacyPolicy                   '::text AS tab,
            count(*) AS cnt
           FROM public."PrivacyPolicy"
        UNION
         SELECT 'PublicCell                      '::text AS tab,
            count(*) AS cnt
           FROM public."PublicCell"
        UNION
         SELECT 'Task                            '::text AS tab,
            count(*) AS cnt
           FROM public."Task"
        UNION
         SELECT 'UserConsent                     '::text AS tab,
            count(*) AS cnt
           FROM public."UserConsent"
        UNION
         SELECT '_Audience                       '::text AS tab,
            count(*) AS cnt
           FROM public."_Audience"
        UNION
         SELECT '_GlobalConfig                   '::text AS tab,
            count(*) AS cnt
           FROM public."_GlobalConfig"
        UNION
         SELECT '_GraphQLConfig                  '::text AS tab,
            count(*) AS cnt
           FROM public."_GraphQLConfig"
        UNION
         SELECT '_Hooks                          '::text AS tab,
            count(*) AS cnt
           FROM public."_Hooks"
        UNION
         SELECT '_Idempotency                    '::text AS tab,
            count(*) AS cnt
           FROM public."_Idempotency"
        UNION
         SELECT '_Installation                   '::text AS tab,
            count(*) AS cnt
           FROM public."_Installation"
        UNION
         SELECT '_JobSchedule                    '::text AS tab,
            count(*) AS cnt
           FROM public."_JobSchedule"
        UNION
         SELECT '_JobStatus                      '::text AS tab,
            count(*) AS cnt
           FROM public."_JobStatus"
        UNION
         SELECT '_Join:cellMembers:Cell411Alert  '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:cellMembers:Cell411Alert"
        UNION
         SELECT '_Join:friends:_User             '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:friends:_User"
        UNION
         SELECT '_Join:initiatedBy:Alert         '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:initiatedBy:Alert"
        UNION
         SELECT '_Join:initiatedBy:Cell411Alert  '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:initiatedBy:Cell411Alert"
        UNION
         SELECT '_Join:members:Cell              '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:members:Cell"
        UNION
         SELECT '_Join:members:PublicCell        '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:members:PublicCell"
        UNION
         SELECT '_Join:rejectedBy:Alert          '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:rejectedBy:Alert"
        UNION
         SELECT '_Join:rejectedBy:Cell411Alert   '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:rejectedBy:Cell411Alert"
        UNION
         SELECT '_Join:roles:_Role               '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:roles:_Role"
        UNION
         SELECT '_Join:seenBy:Alert              '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:seenBy:Alert"
        UNION
         SELECT '_Join:seenBy:Cell411Alert       '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:seenBy:Cell411Alert"
        UNION
         SELECT '_Join:sentTo:Alert              '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:sentTo:Alert"
        UNION
         SELECT '_Join:spamUsers:_User           '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:spamUsers:_User"
        UNION
         SELECT '_Join:spammedBy:_User           '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:spammedBy:_User"
        UNION
         SELECT '_Join:users:_Role               '::text AS tab,
            count(*) AS cnt
           FROM public."_Join:users:_Role"
        UNION
         SELECT '_PushStatus                     '::text AS tab,
            count(*) AS cnt
           FROM public."_PushStatus"
        UNION
         SELECT '_Role                           '::text AS tab,
            count(*) AS cnt
           FROM public."_Role"
        UNION
         SELECT '_SCHEMA                         '::text AS tab,
            count(*) AS cnt
           FROM public."_SCHEMA"
        UNION
         SELECT '_Session                        '::text AS tab,
            count(*) AS cnt
           FROM public."_Session"
        UNION
         SELECT '_User                           '::text AS tab,
            count(*) AS cnt
           FROM public."_User") x
  ORDER BY x.tab;


ALTER TABLE public.counts OWNER TO parse;

--
-- Name: AdditionalNote AdditionalNote_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."AdditionalNote"
    ADD CONSTRAINT "AdditionalNote_pkey" PRIMARY KEY ("objectId");


--
-- Name: Alert Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Alert"
    ADD CONSTRAINT "Alert_pkey" PRIMARY KEY ("objectId");


--
-- Name: Cell411Alert Cell411Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Cell411Alert"
    ADD CONSTRAINT "Cell411Alert_pkey" PRIMARY KEY ("objectId");


--
-- Name: Cell Cell_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Cell"
    ADD CONSTRAINT "Cell_pkey" PRIMARY KEY ("objectId");


--
-- Name: PrivacyPolicy PrivacyPolicy_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."PrivacyPolicy"
    ADD CONSTRAINT "PrivacyPolicy_pkey" PRIMARY KEY ("objectId");


--
-- Name: PublicCell PublicCell_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."PublicCell"
    ADD CONSTRAINT "PublicCell_pkey" PRIMARY KEY ("objectId");


--
-- Name: Request Request_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Request"
    ADD CONSTRAINT "Request_pkey" PRIMARY KEY ("objectId");


--
-- Name: Task Task_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_pkey" PRIMARY KEY ("objectId");


--
-- Name: UserConsent UserConsent_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."UserConsent"
    ADD CONSTRAINT "UserConsent_pkey" PRIMARY KEY ("objectId");


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
-- Name: _GraphQLConfig _GraphQLConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_GraphQLConfig"
    ADD CONSTRAINT "_GraphQLConfig_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Idempotency _Idempotency_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Idempotency"
    ADD CONSTRAINT "_Idempotency_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Installation _Installation_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Installation"
    ADD CONSTRAINT "_Installation_pkey" PRIMARY KEY ("objectId");


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
-- Name: _Join:cellMembers:Cell411Alert _Join:cellMembers:Cell411Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:cellMembers:Cell411Alert"
    ADD CONSTRAINT "_Join:cellMembers:Cell411Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:friends:_User _Join:friends:_User_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:friends:_User"
    ADD CONSTRAINT "_Join:friends:_User_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:initiatedBy:Alert _Join:initiatedBy:Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:initiatedBy:Alert"
    ADD CONSTRAINT "_Join:initiatedBy:Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:initiatedBy:Cell411Alert _Join:initiatedBy:Cell411Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:initiatedBy:Cell411Alert"
    ADD CONSTRAINT "_Join:initiatedBy:Cell411Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:members:Cell _Join:members:Cell_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:members:Cell"
    ADD CONSTRAINT "_Join:members:Cell_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:members:PublicCell _Join:members:PublicCell_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:members:PublicCell"
    ADD CONSTRAINT "_Join:members:PublicCell_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:offered:Alert _Join:offered:Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:offered:Alert"
    ADD CONSTRAINT "_Join:offered:Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:refused:Alert _Join:refused:Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:refused:Alert"
    ADD CONSTRAINT "_Join:refused:Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:rejectedBy:Alert _Join:rejectedBy:Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:rejectedBy:Alert"
    ADD CONSTRAINT "_Join:rejectedBy:Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:rejectedBy:Cell411Alert _Join:rejectedBy:Cell411Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:rejectedBy:Cell411Alert"
    ADD CONSTRAINT "_Join:rejectedBy:Cell411Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:roles:_Role _Join:roles:_Role_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:roles:_Role"
    ADD CONSTRAINT "_Join:roles:_Role_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:seenBy:Alert _Join:seenBy:Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:seenBy:Alert"
    ADD CONSTRAINT "_Join:seenBy:Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:seenBy:Cell411Alert _Join:seenBy:Cell411Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:seenBy:Cell411Alert"
    ADD CONSTRAINT "_Join:seenBy:Cell411Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:sentTo:Alert _Join:sentTo:Alert_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:sentTo:Alert"
    ADD CONSTRAINT "_Join:sentTo:Alert_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:spamUsers:_User _Join:spamUsers:_User_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:spamUsers:_User"
    ADD CONSTRAINT "_Join:spamUsers:_User_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:spammedBy:_User _Join:spammedBy:_User_pkey; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Join:spammedBy:_User"
    ADD CONSTRAINT "_Join:spammedBy:_User_pkey" PRIMARY KEY ("relatedId", "owningId");


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
-- Name: _User unique_email; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_User"
    ADD CONSTRAINT unique_email UNIQUE (email);


--
-- Name: _Role unique_name; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_Role"
    ADD CONSTRAINT unique_name UNIQUE (name);


--
-- Name: _User unique_username; Type: CONSTRAINT; Schema: public; Owner: parse
--

ALTER TABLE ONLY public."_User"
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- Name: case_insensitive_email; Type: INDEX; Schema: public; Owner: parse
--

CREATE INDEX case_insensitive_email ON public."_User" USING btree (lower(email) varchar_pattern_ops);


--
-- Name: case_insensitive_username; Type: INDEX; Schema: public; Owner: parse
--

CREATE INDEX case_insensitive_username ON public."_User" USING btree (lower(username) varchar_pattern_ops);


--
-- PostgreSQL database dump complete
--

