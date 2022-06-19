create or replace view relview
  as
select * from (
select null as otype, null as oid, null as rtype, null as rid, null as extra
union
select 'ChatMsg', "objectId", 'ChatRoom', "chatRoom", '' from "ChatMsg"
union
select 'ChatMsg', "objectId", '_User', "owner", '' from "ChatMsg"
union
select '_User', "owningId", '_User', "relatedId", '_Join:friends:_User' from "_Join:friends:_User"
union
select '_User', "owningId", '_User', "relatedId", '_Join:spamUsers:_User' from "_Join:spamUsers:_User"
union
select 'Alert', "objectId", 'ChatRoom', "chatRoom", '' from "Alert"
union
select 'Alert', "objectId", '_User', "owner", '' from "Alert"
union
select 'PrivateCell', "objectId", '_User', "owner", '' from "PrivateCell"
union
select 'PrivateCell', "objectId", 'ChatRoom', "chatRoom", '' from "PrivateCell"
union
select 'PrivateCell', "owningId", '_User', "relatedId", '_Join:members:PrivateCell' from "_Join:members:PrivateCell"
union
select 'PublicCell', "objectId", 'ChatRoom', "chatRoom", '' from "PublicCell"
union
select 'PublicCell', "objectId", '_User', "owner", '' from "PublicCell"
union
select 'PublicCell', "owningId", '_User', "relatedId", '_Join:members:PublicCell' from "_Join:members:PublicCell"
union
select 'Request', "objectId", '_User', "sentTo", '' from "Request"
union
select 'Request', "objectId", '_User', "owner", '' from "Request"
union
select 'Request', "objectId", 'PublicCell', "cell", '' from "Request"
union
select '_Role', "owningId", '_User', "relatedId", '_Join:users:_Role' from "_Join:users:_Role"
union
select '_Role', "owningId", '_Role', "relatedId", '_Join:roles:_Role' from "_Join:roles:_Role"
union
select 'Response', "objectId", '_User', "forwardedBy", '' from "Response"
union
select 'Response', "objectId", 'Alert', "alert", '' from "Response"
union
select 'Response', "objectId", '_User', "owner", '' from "Response") foo where oid is not null and rid is not null