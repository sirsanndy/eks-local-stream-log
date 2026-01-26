#!/bin/sh
set -e

# Setup logrotate cron job (run every 5 minutes)
# We overwrite /etc/crontabs/root
echo "*/5 * * * * /usr/sbin/logrotate /etc/logrotate.d/stern" > /etc/crontabs/root

# Fix permissions for logrotate config (must be owned by root and 644)
if [ -f /etc/logrotate.d/stern.template ]; then
    cp /etc/logrotate.d/stern.template /etc/logrotate.d/stern
    chown root:root /etc/logrotate.d/stern
    chmod 644 /etc/logrotate.d/stern
    dos2unix /etc/logrotate.d/stern
fi

# Start cron daemon in background
# -b: background
# -L /var/log/cron.log: log output (optional, let's keep it simple or to stdout)
# Alpine crond default logs to syslog.
crond -b -l 8

echo "Starting Stern Worker..."
echo "Query: $STERN_POD_QUERY"

# Run stern and pipe to tee
# We use sh -c to execute the pipeline so that we can trap signals if we wanted to (omitted for simplicity)
# and to ensure the pipe works as expected.
exec /bin/sh -c "stern \"\$STERN_POD_QUERY\" --all-namespaces --tail=1 --color never --output json | tee -a /tmp/logs/stern.log"
