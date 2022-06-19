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
