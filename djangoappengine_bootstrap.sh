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
download_dir="/tmp/djangoappengine_bootstrap_download"

python_src_version="2.7.2"
python_src_download_url="http://www.python.org/ftp/python/$python_src_version/Python-$python_src_version.tar.bz2"
python_src_prefix="/usr/python27"

python_bin="${PYTHON_BIN:-$(which python2.7 2>/dev/null)}"
gae_prefix="${GAE_PREFIX:-/usr/local/google_appengine}"

wget="wget -q -c"

basedir="$(dirname $0)"
cd "$basedir"
basedir="$PWD"


die () {
    echo
    echo "Error: An error occurred. Please see above."
    echo
    exit 1
}

os_install () {
    package="$1"
    echo "Installing with OS native package tool: $package"
    (which port >/dev/null 2>&1 && sudo port install $package) || \
    (which yum >/dev/null 2>&1 && sudo yum -y install $package) || \
    (which apt-get >/dev/null 2>&1 && sudo apt-get -y install $package)
    (which emerge >/dev/null 2>&1 && sudo emerge $package)
}

download_apps () {
    echo
    echo "Downloading ..."
    mkdir -p $download_dir >/dev/null 2>&1
    cd $download_dir || die

    echo "django-testapp"
    $wget https://github.com/django-nonrel/django-testapp/tarball/master -O django-testapp.tar.gz || die
    echo "django-nonrel"
    $wget https://github.com/django-nonrel/django-nonrel/tarball/master -O django-nonrel.tar.gz || die
    echo "djangoappengine"
    $wget https://github.com/django-nonrel/djangoappengine/tarball/master -O djangoappengine.tar.gz || die
    echo "djangotoolbox"
    $wget https://github.com/django-nonrel/djangotoolbox/tarball/master -O djangotoolbox.tar.gz || die
    echo "django-dbindexer"
    $wget https://github.com/django-nonrel/django-dbindexer/tarball/master -O django-dbindexer.tar.gz || die
    echo "nonrel-search"
    $wget https://github.com/django-nonrel/nonrel-search/tarball/master -O nonrel-search.tar.gz || die
    echo "django-permission-backend-nonrel"
    $wget https://github.com/django-nonrel/django-permission-backend-nonrel/tarball/master -O django-permission-backend-nonrel.tar.gz || die
    echo "django-autoload"
    $wget https://bitbucket.org/twanschik/django-autoload/get/tip.tar.gz -O django-autoload.tar.gz || die
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
    cp -a django-nonrel-django-testapp-*/* $temp_dir || die
    echo "django-nonrel"
    cp -a django-nonrel-django-nonrel-*/django $temp_dir || die
    echo "djangoappengine"
    mkdir -p $temp_dir/djangoappengine >/dev/null 2>&1
    cp -a django-nonrel-djangoappengine-*/* $temp_dir/djangoappengine || die
    echo "djangotoolbox"
    cp -a django-nonrel-djangotoolbox-*/djangotoolbox $temp_dir || die
    echo "django-dbindexer"
    cp -a django-nonrel-django-dbindexer-*/dbindexer $temp_dir || die
    echo "nonrel-search"
    cp -a django-nonrel-nonrel-search-*/search $temp_dir || die
    echo "django-permission-backend-nonrel"
    cp -a django-nonrel-django-permission-backend-nonrel-*/permission_backend_nonrel $temp_dir || die
    echo "django-autoload"
    cp -a twanschik-django-autoload-*/autoload $temp_dir || die
}

test_python () {
    echo
    echo "Testing Python ..."

    if [[ "$python_bin" == "" ]]
    then
        return 1
    else
        if [[ ! -f "$python_bin" ]]
        then
            echo "Warning: Provided Python binary does not exist: $python_bin"
            echo "Warning: Commands below may not work as suggested."
        fi
    fi

    return 0
}

install_python () {
    echo
    echo "Installing Python ..."

    # emerge
    os_install "python"
    os_install "sqlite"

    # apt-get / yum
    os_install "python2.7"

    # apt-get
    os_install "libsqlite3-dev"

    # yum
    os_install "sqlite-devel"

    # ports
    os_install "python27"
    os_install "py27-sqlite3"

    python_bin="$(which python2.7 2>/dev/null)"

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

Using:
    Python:         $python_bin
    GAE:            $gae_prefix
    Downloads:      $download_dir
    Destination:    $temp_dir

You may override some of this by setting env vars:
    export PYTHON_BIN=/usr/bin/python2.7
    export GAE_PREFIX=/usr/local/google_appengine
    or at once:
    PYTHON_BIN=/usr/bin/python2.7 GAE_PREFIX=/usr/local/google_appengine ./djangoappengine_bootstrap.sh"
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
    export PATH="$gae_prefix:\$PATH"
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
