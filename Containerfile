FROM alpine:3
RUN apk add --no-cache restic postgresql-client && \
  mkdir /backup

COPY --chmod=0700 ./entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
