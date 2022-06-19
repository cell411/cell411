pg_dump -s                                   | tee parse_schema.sql | wc -l
pg_dump -a --inserts                         | tee parse_data.sql | wc -l


# pg_dump dumps a database as a text file or to other formats.
# 
# Usage:
#   pg_dump [OPTION]... [DBNAME]
# 
# General options:
#   -f, --file=FILENAME          output file or directory name
#   -F, --format=c|d|t|p         output file format (custom, directory, tar,
#                                plain text (default))
#   -j, --jobs=NUM               use this many parallel jobs to dump
#   -v, --verbose                verbose mode
#   -V, --version                output version information, then exit
#   -Z, --compress=0-9           compression level for compressed formats
#   --lock-wait-timeout=TIMEOUT  fail after waiting TIMEOUT for a table lock
#   --no-sync                    do not wait for changes to be written safely to disk
#   -?, --help                   show this help, then exit
# 
# Options controlling the output content:
#   -a, --data-only              dump only the data, not the schema
#   -b, --blobs                  include large objects in dump
#   -B, --no-blobs               exclude large objects in dump
#   -c, --clean                  clean (drop) database objects before recreating
#   -C, --create                 include commands to create database in dump
#   -E, --encoding=ENCODING      dump the data in encoding ENCODING
#   -n, --schema=PATTERN         dump the specified schema(s) only
#   -N, --exclude-schema=PATTERN do NOT dump the specified schema(s)
#   -O, --no-owner               skip restoration of object ownership in
#                                plain-text format
#   -s, --schema-only            dump only the schema, no data
#   -S, --superuser=NAME         superuser user name to use in plain-text format
#   -t, --table=PATTERN          dump the specified table(s) only
#   -T, --exclude-table=PATTERN  do NOT dump the specified table(s)
#   -x, --no-privileges          do not dump privileges (grant/revoke)
#   --binary-upgrade             for use by upgrade utilities only
#   --column-inserts             dump data as INSERT commands with column names
#   --disable-dollar-quoting     disable dollar quoting, use SQL standard quoting
#   --disable-triggers           disable triggers during data-only restore
#   --enable-row-security        enable row security (dump only content user has
#                                access to)
#   --exclude-table-data=PATTERN do NOT dump data for the specified table(s)
#   --extra-float-digits=NUM     override default setting for extra_float_digits
#   --if-exists                  use IF EXISTS when dropping objects
#   --inserts                    dump data as INSERT commands, rather than COPY
#   --load-via-partition-root    load partitions via the root table
#   --no-comments                do not dump comments
#   --no-publications            do not dump publications
#   --no-security-labels         do not dump security label assignments
#   --no-subscriptions           do not dump subscriptions
#   --no-synchronized-snapshots  do not use synchronized snapshots in parallel jobs
#   --no-tablespaces             do not dump tablespace assignments
#   --no-unlogged-table-data     do not dump unlogged table data
#   --on-conflict-do-nothing     add ON CONFLICT DO NOTHING to INSERT commands
#   --quote-all-identifiers      quote all identifiers, even if not key words
#   --rows-per-insert=NROWS      number of rows per INSERT; implies --inserts
#   --section=SECTION            dump named section (pre-data, data, or post-data)
#   --serializable-deferrable    wait until the dump can run without anomalies
#   --snapshot=SNAPSHOT          use given snapshot for the dump
#   --strict-names               require table and/or schema include patterns to
#                                match at least one entity each
#   --use-set-session-authorization
#                                use SET SESSION AUTHORIZATION commands instead of
#                                ALTER OWNER commands to set ownership
# 
# Connection options:
#   -d, --dbname=DBNAME      database to dump
#   -h, --host=HOSTNAME      database server host or socket directory
#   -p, --port=PORT          database server port number
#   -U, --username=NAME      connect as specified database user
#   -w, --no-password        never prompt for password
#   -W, --password           force password prompt (should happen automatically)
#   --role=ROLENAME          do SET ROLE before dump
# 
# If no database name is supplied, then the PGDATABASE environment
# variable value is used.
# 
# Report bugs to <pgsql-bugs@lists.postgresql.org>.
