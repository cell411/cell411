# Cell411

## Purpose

Cell411 is a system to allow users to crowd-source emergency response

This repo will contain the entire system, both client and server side.

## What's here

 * client-google - google dependant android client.  soon, there will be another, not dependant

 * client-ios - ios client.  Warning, there were some file names with spaces, and I replaced them with
   underscores without repairing the damage.  I'm still waiting for a mac to really get going on this.

 * keys - secrets required by production version, developer public keys,
   management scripts.

 * server - the server side.  It runs under parse and postgres.

 * README.md - this file


## Contrib.

 * There is a contrib *branch* which contains a contrib directory.  This is not-ready-for-prime-time     
   stuff than I have been playing with.  I put it on a branch to avoid confusing people.

### Server

 * you'll need yarn or npm I use yarn.  Go into the server directory, and type
   yarn install.  Then type make to run the server.

### Postgres

 * I use a javascript script to set up the database.  I've not got that to the
   point where I can share it, but if you need help, let me now, and I'll get
   you going.

added client-droid
