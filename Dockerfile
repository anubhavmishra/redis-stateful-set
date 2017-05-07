FROM library/redis:3.2
MAINTAINER Anubhav Mishra <anubhavmishra@me.com>

COPY ["docker-entrypoint.sh", "/usr/local/bin/"]
