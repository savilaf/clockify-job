#!/bin/bash

API_KEY=XNMBLxCA7ATZl2Eg
USER=5cd28dbcd278ae0c521832b4

TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
DAY_MONTH=$(date -u +'%d-%m')

init() {
  start_task
}

start_task() {
  task_in_progress=$(curl -sX GET \
  https://api.clockify.me/api/v1/workspaces/5cad884169b7cc19c5c2cae8/user/${USER}/time-entries?in-progress=true \
  -H "X-Api-Key: ${API_KEY}" \
  -H 'content-type: application/json')

  if [ "$task_in_progress" = "[]" ]; then
	  echo 'Starting task...'
    status_code=$(curl -sX POST -o /dev/null -w "%{http_code}" \
    https://api.clockify.me/api/v1/workspaces/5cad884169b7cc19c5c2cae8/time-entries \
    -H "X-Api-Key: ${API_KEY}" \
    -H 'content-type: application/json' \
    -d '{
      "start": "'${TIMESTAMP}'",
      "billable": true,
      "description": "Inicio jornada '${DAY_MONTH}'",
      "projectId": "5cad987e1080ec1cfa267c5d"
    }')
    echo 'HTTP RESPONSE STATUS:'
    echo $status_code

    if [[ $status_code == 20* ]]; then
      osascript -e 'display notification "Mensaje motivador" with title "Inicio de jornada"'
    else
      osascript -e 'display notification "Al iniciar jornada" with title "ERROR HTTP '$status_code'"'
    fi

  else
    echo 'Task is already started, not doing anything.'
    osascript -e 'display notification "Ya hay una tarea iniciada" with title "No se pudo iniciar el tiempo"'
  fi
}

init "$@"
