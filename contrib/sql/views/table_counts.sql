create or replace view table_counts
as
select 'AdditionalNote', count(*) from "AdditionalNote" union
select 'Cell', count(*) from "Cell" union
select 'Cell411Alert', count(*) from "Cell411Alert" union
select 'PrivacyPolicy', count(*) from "PrivacyPolicy" union
select 'PublicCell', count(*) from "PublicCell" union
select 'Task', count(*) from "Task" union
select 'UserConsent', count(*) from "UserConsent" union
select '_Audience', count(*) from "_Audience" union
select '_GlobalConfig', count(*) from "_GlobalConfig" union
select '_GraphQLConfig', count(*) from "_GraphQLConfig" union
select '_Hooks', count(*) from "_Hooks" union
select '_Idempotency', count(*) from "_Idempotency" union
select '_Installation', count(*) from "_Installation" union
select '_JobSchedule', count(*) from "_JobSchedule" union
select '_JobStatus', count(*) from "_JobStatus" union
select '_Join:cellMembers:Cell411Alert', count(*) from "_Join:cellMembers:Cell411Alert" union
select '_Join:friends:_User', count(*) from "_Join:friends:_User" union
select '_Join:initiatedBy:Cell411Alert', count(*) from "_Join:initiatedBy:Cell411Alert" union
select '_Join:members:Cell', count(*) from "_Join:members:Cell" union
select '_Join:members:PublicCell', count(*) from "_Join:members:PublicCell" union
select '_Join:rejectedBy:Cell411Alert', count(*) from "_Join:rejectedBy:Cell411Alert" union
select '_Join:roles:_Role', count(*) from "_Join:roles:_Role" union
select '_Join:seenBy:Cell411Alert', count(*) from "_Join:seenBy:Cell411Alert" union
select '_Join:spamUsers:_User', count(*) from "_Join:spamUsers:_User" union
select '_Join:spammedBy:_User', count(*) from "_Join:spammedBy:_User" union
select '_Join:users:_Role', count(*) from "_Join:users:_Role" union
select '_PushStatus', count(*) from "_PushStatus" union
select '_Role', count(*) from "_Role" union
select '_SCHEMA', count(*) from "_SCHEMA" union
select '_Session', count(*) from "_Session" union
select '_User', count(*) from "_User";
