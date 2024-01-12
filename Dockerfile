# vim:set ft=dockerfile:
#
# Copyright The CloudNativePG Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
ARG DEBIAN_VERSION=buster-20240110-slim
ARG PGBOUNCER_VERSION=1.21.0

FROM debian:${DEBIAN_VERSION} AS build
ARG PGBOUNCER_VERSION

# Install build dependencies.
RUN set -ex; \
    apt-get update && apt-get upgrade -y; \
    apt-get install -y --no-install-recommends curl make pkg-config libevent-dev build-essential libssl-dev libudns-dev openssl ; \
    apt-get purge -y --auto-remove ; \
    rm -fr /tmp/* ; \
    rm -rf /var/lib/apt/lists/*

# build pgbouncer
RUN  curl -sL http://www.pgbouncer.org/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz > pgbouncer.tar.gz ; \
     tar xzf pgbouncer.tar.gz ; \
     cd pgbouncer-${PGBOUNCER_VERSION} ; \
     sh ./configure --without-cares --with-udns ;  \
     make


FROM debian:${DEBIAN_VERSION}
ARG PGBOUNCER_VERSION
ARG TARGETARCH

LABEL name="PgBouncer Container Images" \
      vendor="The CloudNativePG Contributors" \
      version="1.21.0" \
      release="12" \
      summary="Container images for PgBouncer (connection pooler for PostgreSQL)." \
      description="This Docker image contains PgBouncer based on Debian ${DEBIAN_VERSION}."

RUN  set -ex; \
     apt-get update && apt-get upgrade -y; \
     apt-get install -y libevent-dev libssl-dev libudns-dev libvshadow-utils findutils; \
     apt-get -y install postgresql ; \
     apt-get -y clean ; \
     rm -rf /var/lib/apt/lists/*; \
     rm -fr /tmp/* ; \
     groupadd -r --gid 996 pgbouncer ; \
     useradd -r --uid 998 --gid 996 pgbouncer ; \
     mkdir -p /var/log/pgbouncer ; \
     mkdir -p /var/run/pgbouncer ; \
     chown pgbouncer:pgbouncer /var/log/pgbouncer ; \
     chown pgbouncer:pgbouncer /var/run/pgbouncer ;

COPY --from=build ["/pgbouncer-${PGBOUNCER_VERSION}/pgbouncer", "/usr/bin/"]
COPY --from=build ["/pgbouncer-${PGBOUNCER_VERSION}/etc/pgbouncer.ini", "/etc/pgbouncer/pgbouncer.ini.example"]
COPY --from=build ["/pgbouncer-${PGBOUNCER_VERSION}/etc/userlist.txt", "/etc/pgbouncer/userlist.txt.example"]

RUN touch /etc/pgbouncer/pgbouncer.ini /etc/pgbouncer/userlist.txt

# DoD 2.3 - remove setuid/setgid from any binary that not strictly requires it, and before doing that list them on the stdout
RUN find / -not -path "/proc/*" -perm /6000 -type f -exec ls -ld {} \; -exec chmod a-s {} \; || true

EXPOSE 6432
USER pgbouncer

COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
