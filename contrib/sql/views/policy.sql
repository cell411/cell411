CREATE TABLE public."PrivacyPolicy" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    version text,
    "versionCode" double precision,
    _rperm text[],
    _wperm text[]
);
