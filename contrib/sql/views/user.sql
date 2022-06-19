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
    location point,
    "emergencyContactNumber" text,
    "PatrolMode" double precision,
    "otherMedicalConditions" text,
    allergies text,
    "bloodType" text,
    "newPublicCellAlert" double precision,
    "roleId" double precision,
    "imageName" double precision,
    "phoneVerified" boolean,
    city text,
    "isDeleted" double precision,
    phone text,
    name text
);