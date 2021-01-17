#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



requiredvarsareset=Y
if [ -z ${ORG+x} ]; then
    echo "Environment variable ORG is not set. It should contain the name of your organization."; 
    requiredvarsareset=N
fi
if [ -z ${ENV+x} ]; then
    echo "Environment variable ENV is not set. It should contain the name of your organization's environment."; 
    requiredvarsareset=N
fi
if [ -z ${ORG_ADMIN_USERNAME+x} ]; then
    echo "Environment variable ORG_ADMIN_USERNAME is not set. "; 
    requiredvarsareset=N
fi
if [ -z ${ORG_ADMIN_PASSWORD+x} ]; then
    echo "Environment variable ORG_ADMIN_PASSWORD is not set. "; 
    requiredvarsareset=N
fi
if [ "$requiredvarsareset" = "N" ]; then
    exit 1
fi


set -eu

cd $BASEDIR

apigeetool deployproxy -u "$ORG_ADMIN_USERNAME" -p "$ORG_ADMIN_PASSWORD" -o "$ORG" -e "$ENV" -n json-sanitizer -d ./eidas-certificate-bundle

echo "Quick test by running an example transaction..."
## TODO: 
##
cat <<"EOT"
curl --cacert $RUNTIME_SSL_CERT -H "Content-Type: application/json" https://$RUNTIME_HOST_ALIAS/json-sanitizer --resolve "$RUNTIME_HOST_ALIAS:443:$RUNTIME_IP" --http1.1 --data-binary @- <<EOD                                                           
{"xx":"<script>alert(1)</script>", "yy": 'yyy',"ar":[0,,2]}
EOD

Expected Output:

{"xx":"<script>alert(1)</script>", "yy": 'yyy',"ar":[0,,2]}
EOT
