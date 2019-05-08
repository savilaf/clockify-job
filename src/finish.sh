#!/bin/bash

API_KEY=XNMBLxCA7ATZl2Eg
USER=5cd28dbcd278ae0c521832b4

TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
DAY_MONTH=$(date -u +'%d-%m')

task_in_progress=$(curl -sX GET \
  https://api.clockify.me/api/v1/workspaces/5cad884169b7cc19c5c2cae8/user/${USER}/time-entries?in-progress=true \
  -H "X-Api-Key: ${API_KEY}" \
  -H 'content-type: application/json')

  if [ "$task_in_progress" = "[]" ]; then
	echo 'Task is not started, not doing anything.'
  else

    id=$(echo $task_in_progress | jq -r .[0].id)
    start_time=$(echo $task_in_progress | jq -r .[0].timeInterval.start)

    echo $id
    echo $start_time

    curl -sX PUT \
    https://api.clockify.me/api/v1/workspaces/5cad884169b7cc19c5c2cae8/time-entries/${id} \
    -H "X-Api-Key: ${API_KEY}" \
    -H 'content-type: application/json' \
    -d '{
        "start": "'${start_time}'",
        "end": "'${TIMESTAMP}'",
        "billable": true,
        "description": "Fin jornada '${DAY_MONTH}'",
        "projectId": "5cad987e1080ec1cfa267c5d"
    }'
  fi

