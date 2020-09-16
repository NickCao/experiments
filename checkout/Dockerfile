FROM golang:alpine as build
ADD . checkout
WORKDIR checkout
RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -o /go/bin/checkout

FROM chromedp/headless-shell:latest
RUN apt-get update && apt-get install -y tini ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /go/bin/checkout /usr/local/bin/checkout
EXPOSE 8080
ENTRYPOINT ["tini", "/usr/local/bin/checkout"]
