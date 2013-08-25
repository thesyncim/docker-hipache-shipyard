#!/bin/bash
cd ~
apt-get update -qq
apt-get install -y linux-image-extra-`uname -r`

wget https://go.googlecode.com/files/go1.1.2.linux-amd64.tar.gz
tar xf go1.1.2.linux-amd64.tar.gz
rm rf go1.1.2.linux-amd64.tar.gz

echo "export GOROOT=\$HOME/go" >> ~/.profile
echo "PATH=$PATH:\$GOROOT/bin" >> ~/.profile
source ~/.profile

mkdir ~/gocode
echo "export GOPATH=\$HOME/gocode" >> ~/.profile
echo "PATH=\$PATH:\$GOPATH/bin" >> ~/.profile
source ~/.profile

sudo apt-get  -y install lxc curl xz-utils mercurial git


mkdir -p $GOPATH/src/github.com/dotcloud


cd $GOPATH/src/github.com/dotcloud
git clone https://github.com/dotcloud/docker.git


cd $GOPATH/src/github.com/dotcloud/docker
go get -v github.com/dotcloud/docker/...

ln -s $GOPATH/bin/docker /usr/local/bin/docker
