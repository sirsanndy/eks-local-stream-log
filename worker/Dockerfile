FROM alpine:latest

# Install dependencies
# aws-cli: for AWS operations (if needed per original config)
# apache2-utils: utilities
# logrotate: for log rotation
# dos2unix: for fixing line endings
# stern: to tail logs (from edge/testing)
RUN apk add --no-cache \
    aws-cli \
    apache2-utils \
    logrotate \
    dos2unix \
    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing stern

# Create directory for logs
RUN mkdir -p /tmp/logs/archived

# Copy entrypoint script
COPY worker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
