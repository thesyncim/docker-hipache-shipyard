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
}'

#install required dependencies
apt-get update 
apt-get install -y linux-image-extra-`uname -r`
apt-get install -y lxc curl xz-utils mercurial git python-dev python-setuptools libxml2-dev libxslt-dev libmysqlclient-dev  git-core redis-server supervisor

#install node
wget -O - http://nodejs.org/dist/v0.8.23/node-v0.8.23-linux-x64.tar.gz | tar -C /usr/local/ --strip-components=1 -zxv

#install go 
mkdir $HOME/go && wget -O - https://go.googlecode.com/files/go1.1.2.linux-amd64.tar.gz | tar -C $HOME/go/ --strip-components=1 -zxv
echo "export GOROOT=\$HOME/go" >> ~/.profile
echo "PATH=$PATH:\$GOROOT/bin" >> ~/.profile
echo "export GOPATH=\$HOME/gocode" >> ~/.profile
echo "PATH=\$PATH:\$GOPATH/bin" >> ~/.profile
mkdir ~/gocode
source ~/.profile

#install docker
mkdir -p $GOPATH/src/github.com/dotcloud
cd $GOPATH/src/github.com/dotcloud
git clone https://github.com/dotcloud/docker.git
cd $GOPATH/src/github.com/dotcloud/docker
go get -v github.com/dotcloud/docker/...
ln -s $GOPATH/bin/docker /usr/local/bin/docker
echo 'alias docker="docker -H=tcp://127.0.0.1:4243"' >> ~/.profile

SUPERVISORDOCKER=/etc/supervisor/conf.d/supervisord-docker.conf
cat << EOF >> $SUPERVISORDOCKER
[program:docker]
command=/usr/local/bin/docker -H=tcp://127.0.0.1:4243 -d
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
autorestart=true
EOF

#install hipache
cd $GOPATH/src/github.com/dotcloud
git clone https://github.com/dotcloud/hipache.git
cd $GOPATH/src/github.com/dotcloud/hipache
npm install hipache -g
echo $HIPACHECONF > /usr/local/lib/node_modules/hipache/config/config.json

SUPERVISORSHIPACHE=/etc/supervisor/conf.d/supervisord-hipache.conf
cat << EOF >> $SUPERVISORSHIPACHE
[program:hipache]
command=/usr/local/bin/hipache -c /usr/local/lib/node_modules/hipache/config/config.json
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
autorestart=true
EOF
#install shipyard
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

SUPERVISORSHIPYARD=/etc/supervisor/conf.d/supervisord-shipyard.conf
cat << EOF >> $SUPERVISORSHIPYARD
[program:docker]
[program:shipyard]
priority=10
directory=/opt/apps/shipyard
command=/usr/local/bin/uwsgi
    --http-socket 0.0.0.0:8000
    -p 4
    -b 32768
    -T
    --master
    --max-requests 5000
    -H /opt/ve/shipyard
    --static-map /static=/opt/apps/shipyard/static
    --static-map /static=/opt/ve/shipyard/lib/python2.7/site-packages/django/contrib/admin/static
    --module wsgi:application
user=root
autostart=true
autorestart=true

[program:worker]
priority=99
directory=/opt/apps/shipyard
command=/opt/ve/shipyard/bin/python manage.py rqworker shipyard
user=root
autostart=true
autorestart=true
EOF

supervisorctl reread
supervisorctl update

