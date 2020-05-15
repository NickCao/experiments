FROM alpine:edge
RUN apk add --no-cache iproute2
COPY nsescape.ko /root
COPY bin/* /bin/
ENTRYPOINT ["/bin/pause"]
