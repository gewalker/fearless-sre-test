package main

import (
	"context"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
)

// the invocation will send an identifier for the request and the uri to be examined
type MyEvent struct {
	URI string `json:"uri"`
}

// The response type will consist of the expiration date for the certificate and a bool indicating if the certificate needs renewal
type MyResponse struct {
	expiration_date string `json:"expiration_date"`
	needs_renewal   bool   `json:"needs_renewal"`
}

// function handler will receive the uri, and return the expiry date and a boolean needs_renewal flag.
func HandleRequest(ctx context.Context, event MyEvent) (MyResponse, error) {
	edate, renewal, err := testURI(MyEvent.URI)
	if err != nil {
		panic("really sort of late to be hitting an error, but patterns is patterns: " + err.Error())
	}
	return MyResponse{expiration_date: edate, needs_renewal: renewal}, nil
}
func testURI(uri string) (string, bool, error) {
	/* Temporarily making this a no-op
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
	*/
	return time.Now().Format(time.RFC822), true
}

func main() {
	lambda.Start(Handle)
}
