#!/bin/bash

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 


function token { echo -n "$(gcloud config config-helper --force-auth-refresh | grep access_token | grep -o -E '[^ ]+$')" ; }


set -e



requiredvarsareset=Y
if [ -z ${ORG} ]; then
    echo "Environment variable ORG is not set. It should contain the name of your organization.";
    requiredvarsareset=N
fi
if [ -z ${ENV} ]; then
    echo "Environment variable ENV is not set. It should contain the name of your organization's environment.";
    requiredvarsareset=N
fi
if [ "$requiredvarsareset" = "N" ]; then
    exit 1
fi


# variables:
# PROJECT ORG ENV

export API=json-sanitizer
export API_BUNDLE=$BASEDIR/json-sanitizer.zip

(cd $BASEDIR/json-sanitizer-bundle; zip -r $API_BUNDLE *)


# import
export REV=$(curl --silent -H "Authorization: Bearer $(token)" -F file=@$API_BUNDLE -X POST "https://apigee.googleapis.com/v1/organizations/$ORG/apis?action=import&name=$API" | jq -r '.revision')


export REV=$(curl --silent -H "Authorization: Bearer $(token)" -F file=@$API_BUNDLE -X POST "https://apigee.googleapis.com/v1/organizations/$ORG/apis?action=import&name=$API" | jq -r '.revision')

# deploy
echo "Deploying  Proxy: $API Revision: $REV to org: $ORG env: $ENV"
curl --fail -H "Authorization: Bearer $(token)" -X POST "https://apigee.googleapis.com/v1/organizations/$ORG/environments/$ENV/apis/$API/revisions/$REV/deployments?override=true"


# wait till ready
echo -n "Checking Deployment Status"
STATUS=""
while [ "$STATE" != "READY" ]; do
    STATE=$(curl --silent -H "Authorization: Bearer $(token)" "https://apigee.googleapis.com/v1/organizations/$ORG/environments/$ENV/apis/$API/revisions/$REV/deployments" | jq -r '.state')
    echo -n "."
    sleep 5
done
echo -e "\nProxy $API is deployed.\n"

API_BASEPATH=$(unzip -p $API_BUNDLE apiproxy/proxies/default.xml|awk 'BEGIN{FS="(>|<)"}/<BasePath>/{print $3; exit }')

cat <<EOF
Sample request:
  curl --cacert \$RUNTIME_SSL_CERT https://\$RUNTIME_HOST_ALIAS$API_BASEPATH -v --resolve "\$RUNTIME_HOST_ALIAS:443:\$RUNTIME_IP" --http1.1
EOF
