#!/bin/bash
rm $GOPATH/bin/docker
cd $GOPATH/src/github.com/dotcloud/docker && git pull origin master
go install -v github.com/dotcloud/docker/...
