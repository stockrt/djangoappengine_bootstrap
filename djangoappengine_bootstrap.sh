#!/bin/bash

WGET="wget -q -c"
TEMPDL="/tmp/daeb"
TEMP="/tmp/djangoappengine_bootstrap"
DLTYPE="tar.gz"

die () {
    echo
    echo "An error occurred. Please see above."
    echo
    exit 1
}

echo
echo "Downloading..."
mkdir -p $TEMPDL >/dev/null 2>&1
cd $TEMPDL || die
echo "django-testapp"
$WGET https://bitbucket.org/wkornewald/django-testapp/get/tip.$DLTYPE -O django-testapp.$DLTYPE || die
echo "django-nonrel"
$WGET https://bitbucket.org/wkornewald/django-nonrel/get/tip.$DLTYPE -O django-nonrel.$DLTYPE || die
echo "djangoappengine"
$WGET https://bitbucket.org/wkornewald/djangoappengine/get/tip.$DLTYPE -O djangoappengine.$DLTYPE || die
echo "djangotoolbox"
$WGET https://bitbucket.org/wkornewald/djangotoolbox/get/tip.$DLTYPE -O djangotoolbox.$DLTYPE || die
echo "django-dbindexer"
$WGET https://bitbucket.org/wkornewald/django-dbindexer/get/tip.$DLTYPE -O django-dbindexer.$DLTYPE || die
echo "nonrel-search"
$WGET https://bitbucket.org/twanschik/nonrel-search/get/tip.$DLTYPE -O nonrel-search.$DLTYPE || die
echo "django-permission-backend-nonrel"
$WGET https://bitbucket.org/fhahn/django-permission-backend-nonrel/get/tip.$DLTYPE -O django-permission-backend-nonrel.$DLTYPE || die

echo
echo "Extracting..."
for f in *.$DLTYPE
do
    echo "$f"

    # DLTYPE zip
    #unzip -q -o $f || die

    # DLTYPE tar.gz
    tar xzmf $f || die

    # DLTYPE tar.bz2
    #tar xjmf $f || die
done

echo
echo "Copying..."
mkdir -p $TEMP >/dev/null 2>&1
echo "django-testapp"
cp -a wkornewald-django-testapp-*/* $TEMP || die
echo "django-nonrel"
cp -a wkornewald-django-nonrel-*/django $TEMP || die
echo "djangoappengine"
mkdir -p $TEMP/djangoappengine >/dev/null 2>&1
cp -a wkornewald-djangoappengine-*/* $TEMP/djangoappengine || die
echo "djangotoolbox"
cp -a wkornewald-djangotoolbox-*/djangotoolbox $TEMP || die
echo "django-dbindexer"
cp -a wkornewald-django-dbindexer-*/dbindexer $TEMP || die
echo "nonrel-search"
cp -a twanschik-nonrel-search-*/search $TEMP || die
echo "django-permission-backend-nonrel"
cp -a fhahn-django-permission-backend-nonrel-*/permission_backend_nonrel $TEMP || die

echo
echo "Done."
sleep 1

echo "
############################################################################
# djangoappengine sample app is available at:
    $TEMP

# If you want to setup Django's Admin:
    cat admin/settings.py > $TEMP/settings.py
    cat admin/urls.py > $TEMP/urls.py

# Using:
    export PATH=\$PATH:/usr/google_appengine
    cd $TEMP
    # Fix your \"app.yaml\" and then:
    python2.5 manage.py createsuperuser
    python2.5 manage.py syncdb
    python2.5 manage.py runserver
    appcfg.py update_indexes .
    python2.5 manage.py deploy
    python2.5 manage.py remote ...
############################################################################"
