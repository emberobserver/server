#!/bin/bash

SOURCE_HOST=
SOURCE_USER=
SOURCE_DB_NAME=

DEST_HOST=
DEST_USER=
DEST_DB_NAME=
DEST_DB_USER=

FILENAME=ember-observer.$(date +%Y-%m-%d).sql
COMPRESSED_FILENAME="${FILENAME}.bz2"

ssh -T "${SOURCE_USER}"@"${SOURCE_HOST}" << END_SOURCE
sudo -u postgres pg_dump --no-owner --no-acl ${SOURCE_DB_NAME} > "/tmp/${FILENAME}"
bzip2 "/tmp/${FILENAME}"
END_SOURCE

scp "${SOURCE_USER}"@"${SOURCE_HOST}":/tmp/${COMPRESSED_FILENAME} .
scp "${COMPRESSED_FILENAME}" "${DEST_USER}"@"${DEST_HOST}":/tmp/

ssh -T "${DEST_USER}"@"${DEST_HOST}" << END_DEST
sudo -u postgres psql <<< "drop database ${DEST_DB_NAME}; create database ${DEST_DB_NAME} with owner ${DEST_DB_USER};"
bzcat /tmp/${COMPRESSED_FILENAME} | sudo -u postgres psql "${DEST_DB_NAME}"

for table_name in \$(sudo -u postgres psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" ${DEST_DB_NAME}); do
	sudo -u postgres psql -c "alter table \"\${table_name}\" owner to ${DEST_DB_USER}" ${DEST_DB_NAME}
done

for table_name in \$(sudo -u postgres psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" ${DEST_DB_NAME}); do
	sudo -u postgres psql -c "alter table \"\${table_name}\" owner to ${DEST_DB_USER}" ${DEST_DB_NAME}
done

for table_name in \$(sudo -u postgres psql -qAt -c "select table_name from information_schema.views where table_schema = 'public';" ${DEST_DB_NAME}); do
	sudo -u postgres psql -c "alter table \"\${table_name}\" owner to ${DEST_DB_USER}" ${DEST_DB_NAME}
done

rm /tmp/${COMPRESSED_FILENAME}

END_DEST

ssh "${SOURCE_USER}"@"${SOURCE_HOST}" "rm /tmp/${COMPRESSED_FILENAME}"
