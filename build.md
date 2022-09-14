## Build steps:

# Requirements:
* go >=1.18
* awscli 2.x
* zip
* terraform 1.2.9

From the repository root directory:
`cd function`
`GOARCH=amd64 GOOS=linux go build`
`zip ../function.zip tls_validator`
`cd ../terraform/`
`terraform apply -auto-approve -target aws_s3_bucket.this`
`cd ..`
`aws s3 cp ./function.zip s3://<your_s3_bucket>/<your_s3_keypath>/function.zip`
`cd terraform`
`terraform apply -auto-approve`


Remember that you will need a properly configured terraform and awscli environment to run these build steps.  Please do not disregard GOARCH and GOOS for Lambdas.
