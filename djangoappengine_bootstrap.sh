#!/bin/bash

WGET="wget -c"
TEMPDL="/tmp/daeb"
TEMP="/tmp/djangoappengine_bootstrap"

die () {
    echo
    echo "An error occurred. Please see above."
    echo
    exit 1
}

mkdir -p $TEMPDL >/dev/null 2>&1
cd $TEMPDL || die
$WGET https://bitbucket.org/wkornewald/django-testapp/get/tip.zip -O django-testapp.zip || die
$WGET https://bitbucket.org/wkornewald/django-nonrel/get/tip.zip -O django-nonrel.zip || die
$WGET https://bitbucket.org/wkornewald/djangoappengine/get/tip.zip -O djangoappengine.zip || die
$WGET https://bitbucket.org/wkornewald/djangotoolbox/get/tip.zip -O djangotoolbox.zip || die
$WGET https://bitbucket.org/wkornewald/django-dbindexer/get/tip.zip -O django-dbindexer.zip || die
$WGET https://bitbucket.org/twanschik/nonrel-search/get/tip.zip -O nonrel-search.zip || die
$WGET https://bitbucket.org/fhahn/django-permission-backend-nonrel/get/tip.zip -O django-permission-backend-nonrel.zip || die

for f in *.zip
do
    unzip -q -o $f || die
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
