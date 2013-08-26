#!/bin/bash

apt-get update -qq
apt-get install -y linux-image-extra-`uname -r`

wget https://go.googlecode.com/files/go1.1.2.linux-amd64.tar.gz
wget -O - http://nodejs.org/dist/v0.8.23/node-v0.8.23-linux-x64.tar.gz | tar -C /usr/local/ --strip-components=1 -zxv
tar xf go1.1.2.linux-amd64.tar.gz
rm rf go1.1.2.linux-amd64.tar.gz

echo "export GOROOT=\$HOME/go" >> ~/.profile
echo "PATH=$PATH:\$GOROOT/bin" >> ~/.profile
source ~/.profile

mkdir ~/gocode
echo "export GOPATH=\$HOME/gocode" >> ~/.profile
echo "PATH=\$PATH:\$GOPATH/bin" >> ~/.profile
source ~/.profile

apt-get  install -y lxc curl xz-utils mercurial git python-dev python-setuptools libxml2-dev libxslt-dev libmysqlclient-dev  git-core redis-server


mkdir -p $GOPATH/src/github.com/dotcloud


cd $GOPATH/src/github.com/dotcloud
git clone https://github.com/dotcloud/docker.git


cd $GOPATH/src/github.com/dotcloud/docker
go get -v github.com/dotcloud/docker/...

ln -s $GOPATH/bin/docker /usr/local/bin/docker


cd $GOPATH/src/github.com/dotcloud
git clone https://github.com/dotcloud/hipache.git
cd $GOPATH/src/github.com/dotcloud/hipache
npm install hipache -g
mkdir -p /var/log/supervisor
cp supervisord.conf /etc/supervisor/conf.d/supervisord.conf
cp config/config_dev.json /usr/local/lib/node_modules/hipache/config/config_dev.json
cp config/config_test.json /usr/local/lib/node_modules/hipache/config/config_test.json
cp config/config.json /usr/local/lib/node_modules/hipache/config/config.json

//install shipyard
sudo easy_install pip
sudo pip install virtualenv
sudo pip install uwsgi
sudo virtualenv --no-site-packages /opt/ve/shipyard
sudo mkdir  -p /opt/apps && cd /opt/apps && sudo git clone https://github.com/ehazlett/shipyard.git
sudo find /opt/apps/shipyard -name "*.db" -delete
cd /opt/apps/shipyard && sudo git remote rm origin
cd /opt/apps/shipyard && sudo git remote add origin https://github.com/ehazlett/shipyard.git
sudo /opt/ve/shipyard/bin/pip install -r /opt/apps/shipyard/requirements.txt
cd /opt/apps/shipyard && sudo /opt/ve/shipyard/bin/python manage.py syncdb --noinput
cd /opt/apps/shipyard && sudo /opt/ve/shipyard/bin/python manage.py migrate
cd /opt/apps/shipyard && sudo /opt/ve/shipyard/bin/python manage.py update_admin_user --username=admin --password=shipyard
