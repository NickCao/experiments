package main

import (
	"flag"
	"github.com/google/gopacket"
	"log"
	"math/rand"
	"time"
	"github.com/Telefonica/nfqueue"
	"github.com/google/gopacket/layers"
)

var mode = flag.String("m", "out", "out or in, spread or gather")
var port = flag.Int("p", 443, "in out mode, for the starting port of spread;" +
	" in in mode, for the destination port of gather")
var span = flag.Int("s", 1000, "in out mode, the span of spread")
var queueID = flag.Int("i", 56, "the nfqueue id")
var debug = flag.Bool("v", false, "verbose output")
var opts = gopacket.SerializeOptions{
FixLengths:       true,
ComputeChecksums: true,
}

func main(){
	flag.Parse()
	if *mode == "out" {
		rand.Seed(time.Now().UnixNano())
	}
	config := &nfqueue.QueueConfig{}
	queue := nfqueue.NewQueue(uint16(*queueID), &handler{}, config)
	err := queue.Start()
	if err != nil {
		log.Fatal(err)
	}
}

type handler struct{}

func (_ *handler) Handle(p *nfqueue.Packet) {
	var ipv6 layers.IPv6
	var err error

	err = ipv6.DecodeFromBytes(p.Buffer,gopacket.NilDecodeFeedback)
	if err != nil{
		log.Print(err)
		_ = p.Accept()
		return
	}

	var tcp layers.TCP
	err = tcp.DecodeFromBytes(ipv6.Payload, gopacket.NilDecodeFeedback)
	if err != nil{
		log.Print(err)
		_ = p.Accept()
		return
	}

	var payload gopacket.Payload
	err = payload.DecodeFromBytes(tcp.Payload,gopacket.NilDecodeFeedback)
	if err != nil{
		log.Print(err)
		_ = p.Accept()
		return
	}

	if *debug{

	}

	switch *mode{
	case "in":
		tcp.DstPort = layers.TCPPort(*port)
	case "out":
		tcp.DstPort = layers.TCPPort(*port + rand.Intn(*span+1))
	}

	err = tcp.SetNetworkLayerForChecksum(&ipv6)
	if err != nil{
		log.Print(err)
		_ = p.Accept()
		return
	}

	buf := gopacket.NewSerializeBuffer()

	err = gopacket.SerializeLayers(buf, opts, &ipv6, &tcp, &payload)
	if err != nil{
		log.Print(err)
		_ = p.Accept()
		return
	}

	err = p.Modify(buf.Bytes())
	if err != nil{
		log.Print(err)
		_ = p.Accept()
		return
	}

	return
}