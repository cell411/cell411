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
