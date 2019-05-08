#!/bin/bash

time=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
API_KEY=################

curl -X POST \
  https://api.clockify.me/api/v1/workspaces/5cad884169b7cc19c5c2cae8/time-entries \
  -H "X-Api-Key: ${API_KEY}" \
  -H 'content-type: application/json' \
  -d '{
    "start": "'${time}'",
    "billable": true,
    "description": "",
    "projectId": "5cad987e1080ec1cfa267c5d"
  }'
