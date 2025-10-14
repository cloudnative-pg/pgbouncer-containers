ARG BASE=debian:trixie-slim

FROM $BASE
ARG PGBOUNCER_VERSION

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends -o Dpkg::::="--force-confdef" -o Dpkg::::="--force-confold" \
      "pgbouncer=${PGBOUNCER_VERSION}*" postgresql-client && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/* /tmp/* && \
    ln -s /usr/sbin/pgbouncer /usr/bin/pgbouncer && \
    groupadd -r --gid 996 pgbouncer && \
    useradd -r --uid 998 --gid 996 pgbouncer && \
    mkdir -p /var/run/pgbouncer /var/log/pgbouncer && \
    chown -R pgbouncer:pgbouncer /var/run/pgbouncer /var/log/pgbouncer /etc/pgbouncer/

EXPOSE 6432
USER pgbouncer

COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
