FROM alpine:3.23

RUN apk add --no-cache bash restic dcron tzdata ca-certificates

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY run-backup.sh /usr/local/bin/run-backup.sh

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/run-backup.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
