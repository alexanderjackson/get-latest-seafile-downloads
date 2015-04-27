#!/bin/bash
#set -x
# -------------------------------------------
# Get newest Seafile downloads and generate static links
# https://download.seafile.com.de
# -------------------------------------------


# -------------------------------------------
# Vars
# -------------------------------------------
TIME=$(date)
TEMPD=$(mktemp -d)
TEMP1=${TEMPD}/temp1
TEMP2=${TEMPD}/temp2
NGINX_DIR=/etc/nginx/conf.d
NGINX=${NGINX_DIR}/download.seafile.com.de.conf
NGINX_NEW=${NGINX_DIR}/download.seafile.com.de.conf.new
WEB_DIR=/var/www/download.seafile.com.de
WEB_INDEX=${WEB_DIR}/index.html
WEB_INDEX_NEW=${WEB_DIR}/index.html.new


# -------------------------------------------
# Get newest download urls and write formatted to ${TEMP1}
# -------------------------------------------
for i in \
  seafile.*.apk \
  seafile.*en.msi \
  seafile.*en-shibboleth.msi \
  seafile-client.*shibboleth.dmg \
  seafile-client.*.dmg \
  seafile-server.*i386.tar.gz \
  seafile-cli.*i386.tar.gz \
  seafile-server.*x86-64.tar.gz \
  seafile-cli.*x86-64.tar.gz \
  seafile-server.*pi.tar.gz \
  seafile-server.*win32.tar.gz \
  seafile.*i386.deb \
  seafile.*amd64.deb ; \
    do \
      wget -O- https://bitbucket.org/haiwen/seafile/downloads \
      | grep $i  \
      | grep -v beta \
      | sort -V  \
      | tail -n  1  \
      | awk -F'"' '{ print $6 }' >> ${TEMP1} ; \
done


# -------------------------------------------
# Sort content from ${TEMP1} and write to ${TEMP2}
# -------------------------------------------
cat ${TEMP1} | sort > ${TEMP2}


# -------------------------------------------
# Create HTML head for index page
# -------------------------------------------
cat >${WEB_INDEX_NEW}<<EOF
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Latest Seafile Downloads</title>
    <style>
      div { border: 0px solid; float: left; }
    </style>
  </head>
  <body>
    <h1>Latest Seafile Downloads</h1>
    <div>
      <ol>
EOF


# -------------------------------------------
# Create URL list
# -------------------------------------------
cat ${TEMP2} | \
  while read url ; \
    do echo "        <li><a href="$(basename ${url} \
    | sed 's/[0-9].[0-9].[0-9]/latest/')">$(basename ${url}| sed 's/[0-9].[0-9].[0-9]/latest/')</a></li>" \
    >> ${WEB_INDEX_NEW} ; \
  done


# -------------------------------------------
# Create HTML foot  for index page
# -------------------------------------------
cat >>${WEB_INDEX_NEW}<<EOF
      </ol>
      <h3>Last update: ${TIME}</h3>
    </div>
  </body>
</html>
EOF


# -------------------------------------------
# Deploy new index.html
# -------------------------------------------
mv ${WEB_INDEX_NEW} ${WEB_INDEX}


# -------------------------------------------
# Create NGINX head for download.seafile.com.de
# -------------------------------------------
cat >${NGINX_NEW}<<'EOF'
server {
    listen       80;
    server_name  download.seafile.com.de;

EOF

# -------------------------------------------
# Create URL rewrites
# -------------------------------------------
cat ${TEMP2} | \
  while read url ; \
    do echo "    rewrite ^/$(basename ${url}| sed 's/[0-9].[0-9].[0-9]/latest/')$    https://bitbucket.org/$url;" \
    >> ${NGINX_NEW} ; \
  done


# -------------------------------------------
# Create NGINX foot for download.seafile.com.de
# -------------------------------------------
cat >>${NGINX_NEW}<<'EOF'

    root   /var/www/download.seafile.com.de;

    index index.html;
}
EOF


# -------------------------------------------
# Deploy new index.html
# -------------------------------------------
mv ${NGINX_NEW} ${NGINX}


# -------------------------------------------
# Test NGINX configuration and restart if o.k.
# -------------------------------------------
nginx -t && service nginx restart


# -------------------------------------------
# Delete temporary directory
# -------------------------------------------
rm -r ${TEMPD}
