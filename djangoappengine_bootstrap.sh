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

wget="wget -q -c"

basedir="$(dirname $0)"
cd "$basedir"
basedir="$PWD"

temp_dir="/tmp/djangoappengine_bootstrap"
download_dir="/tmp/djangoappengine_bootstrap_downloads"

gae_prefix="/usr/google_appengine"

python25_version="2.5.6"
python25_download_url="http://www.python.org/ftp/python/$python25_version/Python-$python25_version.tar.bz2"
python25_prefix="/usr/python25"

die () {
    echo
    echo "An error occurred. Please see above."
    echo
    exit 1
}

os_install() {
    package="$1"
    echo "Installing with os native package tool: $package"
    (which port >/dev/null 2>&1 && sudo port install $package) || \
    (which yum >/dev/null 2>&1 && sudo yum -y install $package) || \
    (which apt-get >/dev/null 2>&1 && sudo apt-get -y install $package)
}

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

echo
echo "Extracting ..."
for f in *.tar.gz
do
    echo "$f"
    tar xzmf $f || die
done

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

if [[ ! -f "$python25_prefix/bin/python" ]]
then
    echo
    echo "Downloading Python 2.5 ..."
    $wget $python25_download_url || die

    echo
    echo "Extracting Python 2.5 ..."
    tar xjmf Python-$python25_version.tar.bz2 || die
    cd Python-$python25_version || die

    echo
    echo "Installing Python 2.5 dependencies ..."
    os_install libsqlite3-dev
    os_install sqlite-devel

    echo
    echo "Configuring Python 2.5 (output on $download_dir/python25.log) ..."
    ./configure --prefix=$python25_prefix > $download_dir/python25.log 2>&1 || die

    echo
    echo "Building Python 2.5 (output on $download_dir/python25.log) ..."
    make >> $download_dir/python25.log 2>&1 || die

    echo
    echo "Installing Python 2.5 (output on $download_dir/python25.log) ..."
    sudo make install >> $download_dir/python25.log 2>&1 || die
fi

echo
echo "Done."

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
    $python25_prefix/bin/python manage.py createsuperuser
    $python25_prefix/bin/python manage.py syncdb
    $python25_prefix/bin/python manage.py runserver
    $python25_prefix/bin/python $gae_prefix/appcfg.py update_indexes .
    $python25_prefix/bin/python manage.py deploy
    $python25_prefix/bin/python manage.py remote ...

# trying:
    http://127.0.0.1:8000
    http://127.0.0.1:8000/admin
############################################################################"
