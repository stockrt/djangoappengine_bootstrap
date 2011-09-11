#!/usr/bin/env bash

# Copyright (C) 2011 Rogério Carvalho Schneider <stockrt@gmail.com>
#
# This file is part of djangoappengine bootstrap.
#
# djangoappengine bootstrap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# djangoappengine bootstrap is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with djangoappengine bootstrap.  If not, see <http://www.gnu.org/licenses/>.
#
#
# djangoappengine_bootstrap.sh
#
# Created:  Mar 10, 2011
# Author:   Rogério Carvalho Schneider <stockrt@gmail.com>

temp_dir="/tmp/djangoappengine_bootstrap"
download_dir="/tmp/djangoappengine_bootstrap_downloads"

gae_prefix="/usr/google_appengine"

python_src_version="2.5.6"
python_src_download_url="http://www.python.org/ftp/python/$python_src_version/Python-$python_src_version.tar.bz2"
python_src_prefix="/usr/python25"

python_bin="${PYTHON_BIN:-$(which python2.5)}"

wget="wget -q -c"

basedir="$(dirname $0)"
cd "$basedir"
basedir="$PWD"

die () {
    echo
    echo "An error occurred. Please see above."
    echo
    exit 1
}

os_install () {
    package="$1"
    echo "Installing with os native package tool: $package"
    (which port >/dev/null 2>&1 && sudo port install $package) || \
    (which yum >/dev/null 2>&1 && sudo yum -y install $package) || \
    (which apt-get >/dev/null 2>&1 && sudo apt-get -y install $package)
}

download_apps () {
    echo
    echo "Downloading ..."
    mkdir -p $download_dir >/dev/null 2>&1
    cd $download_dir || die

    echo "django-testapp"
    $wget https://bitbucket.org/wkornewald/django-testapp/get/tip.tar.gz -O django-testapp.tar.gz || die
    echo "django-nonrel"
    $wget https://bitbucket.org/wkornewald/django-nonrel/get/tip.tar.gz -O django-nonrel.tar.gz || die
    echo "djangoappengine"
    $wget https://bitbucket.org/wkornewald/djangoappengine/get/tip.tar.gz -O djangoappengine.tar.gz || die
    echo "djangotoolbox"
    $wget https://bitbucket.org/wkornewald/djangotoolbox/get/tip.tar.gz -O djangotoolbox.tar.gz || die
    echo "django-dbindexer"
    $wget https://bitbucket.org/wkornewald/django-dbindexer/get/tip.tar.gz -O django-dbindexer.tar.gz || die
    echo "django-autoload"
    $wget https://bitbucket.org/twanschik/django-autoload/get/tip.tar.gz -O django-autoload.tar.gz || die
    echo "nonrel-search"
    $wget https://bitbucket.org/twanschik/nonrel-search/get/tip.tar.gz -O nonrel-search.tar.gz || die
    echo "django-permission-backend-nonrel"
    $wget https://github.com/fhahn/django-permission-backend-nonrel/tarball/master -O django-permission-backend-nonrel.tar.gz || die
}

extract_apps () {
    echo
    echo "Extracting ..."
    for f in *.tar.gz
    do
        echo "$f"
        tar xzmf $f || die
    done
}

copy_apps () {
    echo
    echo "Copying ..."
    rm -rf $temp_dir
    mkdir -p $temp_dir >/dev/null 2>&1

    echo "django-testapp"
    cp -a wkornewald-django-testapp-*/* $temp_dir || die
    echo "django-nonrel"
    cp -a wkornewald-django-nonrel-*/django $temp_dir || die
    echo "djangoappengine"
    mkdir -p $temp_dir/djangoappengine >/dev/null 2>&1
    cp -a wkornewald-djangoappengine-*/* $temp_dir/djangoappengine || die
    echo "djangotoolbox"
    cp -a wkornewald-djangotoolbox-*/djangotoolbox $temp_dir || die
    echo "django-dbindexer"
    cp -a wkornewald-django-dbindexer-*/dbindexer $temp_dir || die
    echo "django-autoload"
    cp -a twanschik-django-autoload-*/autoload $temp_dir || die
    echo "nonrel-search"
    cp -a twanschik-nonrel-search-*/search $temp_dir || die
    echo "django-permission-backend-nonrel"
    cp -a fhahn-django-permission-backend-nonrel-*/permission_backend_nonrel $temp_dir || die
}

test_python () {
    if [[ "$python_bin" == "" ]]
    then
        return 1
    else
        if [[ ! -f "$python_bin" ]]
        then
            echo "Warning: Provided python binary does not exist: $python_bin"
            echo "Warning: Commands below may not work as suggested."
        fi
    fi

    return 0
}

install_python () {
    # emerge
    os_install "python"
    os_install "sqlite"

    # apt-get / yum
    os_install "python2.5"

    # apt-get
    os_install "libsqlite3-dev"

    # yum
    os_install "sqlite-devel"

    # ports
    os_install "python25"
    os_install "py25-sqlite3"

    python_bin="$(which python2.5)"

    # src
    if [[ "$python_bin" == "" ]]
    then
        if [[ ! -f "$python_src_prefix/bin/python" ]]
        then
            echo
            echo "Downloading Python ..."
            $wget $python_src_download_url || die

            echo
            echo "Extracting Python ..."
            tar xjmf Python-$python_src_version.tar.bz2 || die
            cd Python-$python_src_version || die

            echo
            echo "Configuring Python (output on $download_dir/python.log) ..."
            ./configure --prefix=$python_src_prefix > $download_dir/python.log 2>&1 || die

            echo
            echo "Building Python (output on $download_dir/python.log) ..."
            make >> $download_dir/python.log 2>&1 || die

            echo
            echo "Installing Python (output on $download_dir/python.log) ..."
            sudo make install >> $download_dir/python.log 2>&1 || die
        fi

        python_bin="$python_src_prefix/bin/python"
    fi
}

all_start_message () {
    echo "
Creating environment.

Using python: $python_bin
You may override this by setting PYTHON_BIN env var:
PYTHON_BIN=/usr/bin/python2.5 ./djangoappengine_bootstrap.sh"
}

all_end_message () {
    echo "
Done."
}

final_message () {
    echo "
############################################################################
# djangoappengine sample app is available at:
    $temp_dir

# if you want to setup django's admin:
    cat $basedir/admin/settings.py > $temp_dir/settings.py
    cat $basedir/admin/urls.py > $temp_dir/urls.py

# configure:
    vi $temp_dir/app.yaml

# using:
    cd $temp_dir
    $python_bin manage.py createsuperuser
    $python_bin manage.py syncdb
    $python_bin manage.py runserver
    $python_bin $gae_prefix/appcfg.py update_indexes .
    $python_bin manage.py deploy
    $python_bin manage.py remote ...

# trying:
    http://127.0.0.1:8000
    http://127.0.0.1:8000/admin
############################################################################"
}

##########
## MAIN ##
##########

all_start_message
download_apps
extract_apps
copy_apps
test_python || install_python
all_end_message
final_message
