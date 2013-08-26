#!/bin/bash

HIPACHECONF='
{
    "server": {
        "accessLog": "/var/log/hipache_access.log",
        "port": 80,
        "workers": 5,
        "maxSockets": 100,
        "deadBackendTTL": 30,
        "address": ["127.0.0.1"],
        "address6": ["::1"]
    },
    "redisHost": "127.0.0.1",
    "redisPort": 6379
    

}
'
cd ~
apt-get update -qq
apt-get install -y linux-image-extra-`uname -r`

wget -O - http://nodejs.org/dist/v0.8.23/node-v0.8.23-linux-x64.tar.gz | tar -C /usr/local/ --strip-components=1 -zxv
wget -O - https://go.googlecode.com/files/go1.1.2.linux-amd64.tar.gz | tar -C $HOME/go/ --strip-components=1 -zxv
echo "export GOROOT=\$HOME/go" >> ~/.profile
echo "PATH=$PATH:\$GOROOT/bin" >> ~/.profile
source ~/.profile

mkdir ~/gocode
echo "export GOPATH=\$HOME/gocode" >> ~/.profile
echo "PATH=\$PATH:\$GOPATH/bin" >> ~/.profile
echo 'alias docker="docker -H=tcp://127.0.0.1:4243"' >> ~/.profile
source ~/.profile

apt-get  install -y lxc curl xz-utils mercurial git python-dev python-setuptools libxml2-dev libxslt-dev libmysqlclient-dev  git-core redis-server supervisor

wget -O /etc/supervisor/conf.d/supervisord-docker.conf https://raw.github.com/thesyncim/docker-hipache-shipyard/master/supervisord-docker.conf
wget -O /etc/supervisor/conf.d/supervisord-hipache.conf https://raw.github.com/thesyncim/docker-hipache-shipyard/master/supervisord-hipache.conf
wget -O /etc/supervisor/conf.d/supervisord-shipyard.conf https://raw.github.com/thesyncim/docker-hipache-shipyard/master/supervisord-shipyard.conf


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


echo $HIPACHECONF > /usr/local/lib/node_modules/hipache/config/config.json


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
