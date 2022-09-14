package main

import (
	"context"
	"crypto/tls"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
)

// the invocation will send an identifier for the request and the uri to be examined
type MyEvent struct {
	URI string `json:"uri"`
}

// The response type will consist of the expiration date for the certificate and boolean flags indicating
// if the cert is either currently invalid or in need of renewal in the next 14 days
type MyResponse struct {
	ExpirationDate string `json:"expiration_date"`
	IsValid        bool   `json:"is_valid"`
	NeedsRenewal   bool   `json:"needs_renewal"`
}

// function handler will receive the uri, and return the expiry date and a boolean needs_renewal flag.
func HandleRequest(ctx context.Context, event MyEvent) (MyResponse, error) {
	edate, validity, renewal, err := testURI(event.URI)
	if err != nil {
		edate = time.Now().Format("RFC822")
		validity = false
		renewal = true
	}
	return MyResponse{ExpirationDate: edate, IsValid: validity, NeedsRenewal: renewal}, err
}
func testURI(uri string) (string, bool, bool, error) {
	validity := false
	renew_soon := false
	// Attempt to perform a tls handshake. failure here weeds out bad certs, name mismatches and self-signed certs
	// there are a lot of additional tls jiggery pokery we could get up to here including geolocation fencing, etc. etc.
	conn, err := tls.Dial("tcp", uri, nil)
	if err != nil {
		return time.Now().Format(time.RFC822), validity, renew_soon, err
	}
	// this is a minimal "what's my expiration" routine
	expiry := conn.ConnectionState().PeerCertificates[0].NotAfter
	// if the certificate expires after the present we can consider it valid
	validity = expiry.After(time.Now())
	// if duration until the expiration date is less than 14d we set the renewal flag true
	renewal_threshold, _ := time.ParseDuration("14d")
	if time.Until(expiry) <= renewal_threshold {
		renew_soon = true
	}
	return expiry.Format(time.RFC822), validity, renew_soon, nil
}

func main() {
	lambda.Start(HandleRequest)
}
