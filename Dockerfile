# Basic Postgresql setup
FROM postgres:12
ENV POSTGRES_USER=advent
ENV POSTGRES_PASSWORD=advent
ENV POSTGRES_DB=advent
ENV PSOTGRES_HOST_AUTH_METHOD=trust

COPY ./inputs /inputs
COPY ./setups /docker-entrypoint-initdb.d
COPY ./solutions /solutions
