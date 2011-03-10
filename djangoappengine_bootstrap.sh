#!/bin/bash

WGET="wget -c"
TEMPDL="/tmp/daeb"
TEMP="/tmp/djangoappengine_bootstrap"
DLTYPE="tar.gz"

die () {
    echo
    echo "An error occurred. Please see above."
    echo
    exit 1
}

mkdir -p $TEMPDL >/dev/null 2>&1
cd $TEMPDL || die
$WGET https://bitbucket.org/wkornewald/django-testapp/get/tip.$DLTYPE -O django-testapp.$DLTYPE || die
$WGET https://bitbucket.org/wkornewald/django-nonrel/get/tip.$DLTYPE -O django-nonrel.$DLTYPE || die
$WGET https://bitbucket.org/wkornewald/djangoappengine/get/tip.$DLTYPE -O djangoappengine.$DLTYPE || die
$WGET https://bitbucket.org/wkornewald/djangotoolbox/get/tip.$DLTYPE -O djangotoolbox.$DLTYPE || die
$WGET https://bitbucket.org/wkornewald/django-dbindexer/get/tip.$DLTYPE -O django-dbindexer.$DLTYPE || die
$WGET https://bitbucket.org/twanschik/nonrel-search/get/tip.$DLTYPE -O nonrel-search.$DLTYPE || die
$WGET https://bitbucket.org/fhahn/django-permission-backend-nonrel/get/tip.$DLTYPE -O django-permission-backend-nonrel.$DLTYPE || die

for f in *.$DLTYPE
do
    # DLTYPE zip
    #unzip -q -o $f || die

    # DLTYPE tar.gz
    tar xzf $f || die

    # DLTYPE tar.bz2
    #tar xjf $f || die
done

mkdir -p $TEMP >/dev/null 2>&1
cp -a wkornewald-django-testapp-*/* $TEMP || die
cp -a wkornewald-django-nonrel-*/django $TEMP || die
cp -a wkornewald-djangoappengine-* $TEMP/djangoappengine || die
cp -a wkornewald-djangotoolbox-*/djangotoolbox $TEMP || die
cp -a wkornewald-django-dbindexer-*/dbindexer $TEMP || die
cp -a twanschik-nonrel-search-*/search $TEMP || die
cp -a fhahn-django-permission-backend-nonrel-*/permission_backend_nonrel $TEMP || die

echo "
################################################
djangoappengine sample app is available at $TEMP

If you want to setup Django's Admin:

-- $TEMP/settings.py --
INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'djangotoolbox',
    'search',
    'permission_backend_nonrel',
)

AUTHENTICATION_BACKENDS = (
    'permission_backend_nonrel.backends.NonrelPermissionBackend',
)

#SEARCH_BACKEND = 'search.backends.gae_background_tasks'
SEARCH_BACKEND = 'search.backends.immediate_update'

-- $TEMP/urls.py --
from django.conf.urls.defaults import *

# Django Admin
from django.contrib import admin
admin.autodiscover()

# Search for \"dbindexes.py\" in all installed apps
import dbindexer
dbindexer.autodiscover()

# Search for \"search_indexes.py\" in all installed apps
import search
search.autodiscover()

urlpatterns = patterns('',
    # Index
    (r'^\$', 'django.views.generic.simple.direct_to_template', {'template': 'home.html'}),

    # Django Admin
    (r'^admin/', include(admin.site.urls)),
)

cd $TEMP
- fix your app.yaml and then:
python2.5 manage.py createsuperuser
python2.5 manage.py runserver
python2.5 manage.py deploy
python2.5 manage.py remote createsuperuser
################################################"
