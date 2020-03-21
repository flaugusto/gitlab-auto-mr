FROM alpine:3.6

RUN apk add --no-cache \
  bash \
  curl \
  grep \
  jq

COPY autoMergeRequest.sh /usr/bin

CMD [ "autoMergeRequest.sh" ]

