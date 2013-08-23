#!/bin/bash
sudo apt-get -qq update
sudo apt-get install -y python-dev python-setuptools libxml2-dev libxslt-dev libmysqlclient-dev  git-core
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
