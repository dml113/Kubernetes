FROM alpine as certs
RUN apk update && apk add ca-certificates


FROM busybox
WORKDIR /
ADD . .

COPY --from=certs /etc/ssl/certs /etc/ssl/certs
COPY app /
CMD ["/app"]
