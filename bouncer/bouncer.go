package main

import (
	crand "crypto/rand"
	"crypto/rsa"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"flag"
	"io/ioutil"
	"log"
	"math/big"
	"math/rand"
	"net/http"
	"net/http/httputil"
	"time"
)

var Rand = rand.New(rand.NewSource(time.Now().Unix()))
var caCert *x509.Certificate
var caKey *rsa.PrivateKey

var certFile = flag.String("cert", "ca.cer", "the ca cert file")
var keyFile = flag.String("key", "ca.der", "the ca key file")
var laddr = flag.String("l", "127.0.0.1:10443", "the address to listen on")
var endpoint = flag.String("e", "", "the cf worker endpoint")

func main() {
	flag.Parse()
	var err error
	caCertData, err := ioutil.ReadFile(*certFile)
	if err != nil{
		log.Fatal(err)
	}
	caCert, err = x509.ParseCertificate(caCertData)
	if err != nil{
		log.Fatal(err)
	}
	caKeyData, err := ioutil.ReadFile(*keyFile)
	if err != nil{
		log.Fatal(err)
	}
	caKey, err  = x509.ParsePKCS1PrivateKey(caKeyData)
	if err != nil{
		log.Fatal(err)
	}

	rp := &httputil.ReverseProxy{
		Director: dir,
	}
	serv := http.Server{
		Addr:    *laddr,
		Handler: rp,
		TLSConfig: &tls.Config{
			GetCertificate: genCert,
		},
	}
	err = serv.ListenAndServeTLS("","")
	if err != nil {
		log.Fatal(err)
	}
}

func dir(req *http.Request) {
	req.Header.Set("X-BOUNCER-HOST", req.Host)
	req.URL.Scheme = "https"
	req.URL.Host = *endpoint
	req.Host = *endpoint
}

func genCert(ci *tls.ClientHelloInfo) (*tls.Certificate, error){
	serialNumberLimit := new(big.Int).Lsh(big.NewInt(1), 128)
	serialNumber, err := crand.Int(Rand, serialNumberLimit)
	if err != nil {
		return nil, err
	}
	template := &x509.Certificate{
		SerialNumber:            serialNumber,
		Issuer:                  pkix.Name{},
		Subject: pkix.Name{
			Organization: []string{"Bouncer"},
			CommonName: ci.ServerName,
		},
		NotBefore:                   time.Now(),
		NotAfter:                    time.Now().Add(time.Hour * 2400),
		KeyUsage:                    x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature,
		ExtKeyUsage:                 []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid:       true,
		DNSNames: []string{ci.ServerName},
	}

	serverKey, err := rsa.GenerateKey(Rand,2048)
	if err != nil{
		return nil,err
	}
	serverCertData, err := x509.CreateCertificate(Rand,template,caCert,serverKey.Public(),caKey)
	if err != nil{
		return nil, err
	}
	cert, err :=  tls.X509KeyPair(
	pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: serverCertData}),
	pem.EncodeToMemory(&pem.Block{Type: "RSA PRIVATE KEY", Bytes: x509.MarshalPKCS1PrivateKey(serverKey)}))
	if err != nil{
		return nil, err
	}
	return &cert, nil
}
