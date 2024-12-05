# Basic Postgresql setup
FROM postgres:14
ENV POSTGRES_USER=advent
ENV POSTGRES_PASSWORD=advent
ENV POSTGRES_DB=advent
ENV PSOTGRES_HOST_AUTH_METHOD=trust

COPY . /advent
COPY ./setups/days /docker-entrypoint-initdb.d
