#!/bin/bash

set -e
set -x

echo "bind 0.0.0.0" > /etc/redis.conf
echo "protected-mode no" >> /etc/redis.conf
if [ -z "$SENTINEL" ]; then
	RENAME_CONFIG=$(echo "kuberdbs" | sha1sum | awk '{ print $1 }')
	echo "rename-command CONFIG $RENAME_CONFIG" >> /etc/redis.conf
	echo "rename-command FLUSHDB \"\"" >> /etc/redis.conf
	echo "rename-command FLUSHALL \"\"" >> /etc/redis.conf
	echo "rename-command SHUTDOWN \"\"" >> /etc/redis.conf
	echo "rename-command DEBUG \"\"" >> /etc/redis.conf
	echo "rename-command OBJECT \"\"" >> /etc/redis.conf
	echo "rename-command MOVE \"\"" >> /etc/redis.conf
	if [ ! -z "$REDIS_PASSWORD" ]; then
		echo "requirepass $REDIS_PASSWORD" >> /etc/redis.conf
	fi
fi
echo "databases 10000" >> /etc/redis.conf

set -- $(which redis-server) /etc/redis.conf

if [ -v REPLICA ] && [ ! -v SENTINEL ]; then
	echo "masterauth $REDIS_PASSWORD" >> /etc/redis.conf
  set -- $@ --slaveof $(redis-cli -h redis-sentinel -p 26379 --raw sentinel get-master-addr-by-name primary | sed -n 1p) 6379
fi

if [ -v SENTINEL ]; then
	echo "sentinel monitor primary $SENTINEL 6379 2" >> /etc/redis.conf
	if [ ! -z "$REDIS_PASSWORD" ]; then
		echo "sentinel auth-pass primary $REDIS_PASSWORD" >> /etc/redis.conf
	fi
	echo "sentinel down-after-milliseconds primary 5000" >> /etc/redis.conf
	echo "sentinel failover-timeout primary 10000" >> /etc/redis.conf
	echo "sentinel parallel-syncs primary 1" >> /etc/redis.conf

	set -- $@ --port 26379 --sentinel
fi

cat /etc/redis.conf

exec "$@"
