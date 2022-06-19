psql admin -c 'drop database geocache';
psql admin -c 'create database geocache';
psql geocache -c 'create extension postgis';
psql geocache -c 'create extension postgis_topology';
