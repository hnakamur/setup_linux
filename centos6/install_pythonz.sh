#!/bin/bash

version=2.7.3

curl -kL https://raw.github.com/saghul/pythonz/master/pythonz-install | bash

cat >> /root/.bash_profile << 'EOF'

export PYTHONZ_ROOT=/usr/local/pythonz
. /usr/local/pythonz/etc/bashrc
EOF

export PYTHONZ_ROOT=/usr/local/pythonz
. /usr/local/pythonz/etc/bashrc
pythonz install $version

export PATH=$PYTHONZ_ROOT/CPython-$version/bin:$PATH
curl http://python-distribute.org/distribute_setup.py | python
curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py | python
pip install virtualenv virtualenvwrapper
