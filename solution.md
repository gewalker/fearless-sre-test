## Greetings Reviewers
As your HR personnel are well aware, everything is chaos around here this last week.  My wife fell off a ladder and broke her shoulder last Wednesday and things have been pretty hectic. That said, although I haven't finished everything I would like I've decided that I'll submit things to you as they are at the 48 hour mark. You can look over what I've put together thus far and draw your own conclusions.

So:  in the repo you will find the following:

* **function**: this directory contains the golang code to implement the lambda function.
* **terraform**: this directory contains the terraform infrastructure as code portion of the project.
* **build.md**: build and deploy instructions in markdown. Think of this as an outline for building an associated ci/cd pipeline
* **solution.md**: this file

There's nothing complex here, a lambda function, a simple golang program to check a uri's ssl cert, etc. I went with golang simply because I like the aws API for golang better than the comparable one for Python.

Known issues:
There's a bug somewhere in the API Gateway config that I haven't had time to swat yet that is causing it to give a 502 error when invoked from api gateway even though independent invocation of the lambda via the cli or console work fine. The defaults listed for the variables in vars.tf should change based on your aws environment, obviously.

Further things to do:
This is a POC so there are lots of things that would be better done differently in the context of security oversight. Particularly, assuming this was a lambda performing some useful internal function, I would make it a private endpoint and restrict it to associated vpcs at a minimum. The entire API Gateway/endpoint proxies, lambda function and bucket items should be broken out into a terraform module and make as opinionated choices as the dev traffic will bear. Finally when a CI/CD pipline is implemented, repeated package builds should be replaced by artifact storage/promotion either in S3 or a dedicated repo such as Artifactory.
