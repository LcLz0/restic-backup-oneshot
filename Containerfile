FROM alpine:3
RUN apk add --no-cache restic postregsql-common && \
  mkdir /backup /psql-dump

COPY --chmod=0700 ./entrypoint.sh ./psql_dump.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
