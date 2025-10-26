FROM postgres:15

COPY lab3_1/init.sql /docker-entrypoint-initdb.d/01-init.sql
COPY lab3_1/date.sql /docker-entrypoint-initdb.d/02-date.sql
COPY lab3_1/competitions.sql /docker-entrypoint-initdb.d/03-competitions.sql
COPY lab3_1/outcome.sql /docker-entrypoint-initdb.d/04-outcome.sql
COPY lab3_1/participants.sql /docker-entrypoint-initdb.d/05-participants.sql
COPY lab3_1/performance.sql /docker-entrypoint-initdb.d/06-performance.sql
