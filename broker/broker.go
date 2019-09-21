package main

import (
	"bufio"
	"io"
	"log"
	"net"
	"net/http"
	"net/url"
)

func main(){
	lis, err := net.Listen("tcp","127.0.0.1:8101")
	if err != nil{
		log.Fatal(err)
	}
	for {
		conn , err := lis.Accept()
		if err != nil{
			log.Println(err)
			continue
		}
		go handle(conn)
	}
}

func handle(lconn net.Conn){
	rconn,err := net.Dial("tcp","127.0.0.1:8102")
	if err != nil{
		log.Println(err)
		return
	}

	header := http.Header{}
	header.Set("Connection","upgrade")
	header.Set("Upgrade","broker/1")
	req := &http.Request{
		Method:           "GET",
		URL:              &url.URL{
			Path:       "/",
		},
		Header:           header,
	}
	err = req.Write(rconn)
	if err != nil{
		log.Println(err)
		return
	}
	resp, err := http.ReadResponse(bufio.NewReader(rconn), req)
	if err != nil{
		log.Println(err)
		return
	}

	if resp.StatusCode != http.StatusSwitchingProtocols {
		log.Println("failed to upg")
		return
	}
	go func(){
		_,_ = io.Copy(rconn,lconn)
	}()
	go func(){
		_,_ = io.Copy(lconn,rconn)
	}()
}