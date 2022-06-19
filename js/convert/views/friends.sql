CREATE or replace VIEW friends AS
 SELECT u1."objectId" AS oid1,
    u1.username AS username1,
    u2."objectId" AS oid2,
    u2.username AS username2
   FROM "_User" u1,
    "_User" u2,
    "_Join:friends:_User" j
  WHERE ((u1."objectId" = (j."owningId")::text) AND (u2."objectId" = (j."relatedId")::text))
  ORDER BY u1.username, u2.username;
