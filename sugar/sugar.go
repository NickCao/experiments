package main

import (
	"io"
	"log"
	"net"
	"net/http"
	"sync"
)

func main(){
	err := http.ListenAndServe("127.0.0.1:8102",handler{})
	if err != nil{
		log.Fatal(err)
	}
}

type handler struct{}

func (h handler) ServeHTTP(w http.ResponseWriter, req *http.Request){
	if req.Header.Get("Upgrade") != "broker/1"{
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	w.WriteHeader(http.StatusSwitchingProtocols)
	lconn, rw, err := w.(http.Hijacker).Hijack()
	defer lconn.Close()
	if err != nil{
		log.Println("failed to hijack")
		return
	}
	rconn, err := net.Dial("tcp","1.0.0.1:443")
	if err != nil{
		log.Println("failed to dial")
		return
	}
	wg := &sync.WaitGroup{}
	wg.Add(2)
	go func(){
		_,_ = io.Copy(rconn,rw)
		wg.Done()
	}()
	go func(){
		_,_ = io.Copy(rw,rconn)
		wg.Done()
	}()
	wg.Wait()
}