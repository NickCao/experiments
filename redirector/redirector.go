package main

import (
	"context"
	"flag"
	"github.com/armon/go-socks5"
	"log"
	"net"
)

var laddr = flag.String("l", "127.0.0.1:2080", "the addr to listen on")
var raddr = flag.String("r", "127.0.0.1", "the addr of the mitm proxy")
var rport = flag.Int("p", 10443, "the port of the mitm proxy")

func main() {
	flag.Parse()
	conf := &socks5.Config{
		Rewriter: rewriter{},
	}
	server, err := socks5.New(conf)
	if err != nil {
		log.Fatal(err)
	}
	if err := server.ListenAndServe("tcp", *laddr); err != nil {
		log.Fatal(err)
	}
}

type rewriter struct{}

func (r rewriter) Rewrite(ctx context.Context, request *socks5.Request) (context.Context, *socks5.AddrSpec) {
	if request.DestAddr.Port == 443 {
		return ctx, &socks5.AddrSpec{IP: net.ParseIP(*raddr), Port: *rport}
	}
	return ctx, request.DestAddr
}
