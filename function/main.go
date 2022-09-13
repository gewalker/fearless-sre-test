package main

import (
	"crypto/tls"
	"fmt"
	"time"
)

func main() {
	// Attempt to perform a tls handshake.
	conn, err := tls.Dial("tcp", "gewalker.net:443", nil)
	if err != nil {
		// Whoops! no point in looking at the expiration date of an invalid cert
		// replace panic here with something more useful
		panic("Server doesn't support SSL/TLS or invalid cert err: " + err.Error())
	}
	// this is a minimal "what's my expiration" routine
	expiry := conn.ConnectionState().PeerCertificates[0].NotAfter
	fmt.Printf("expires: %v\n", expiry.Format(time.RFC850))
}
