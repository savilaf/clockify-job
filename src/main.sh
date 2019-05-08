#!/bin/bash

API_KEY=###########

TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
DAY_MONTH=$(date -u +'%d-%m')
USER=

init() {
  require_user_id
  opt=$(require_option "$@")

  if [ "$opt" = "start" ]; then
    start_task
  elif [ "$opt" = "finish" ]; then
    finish_task
  else
    echo $opt
  fi
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

finish_task() {
	task_in_progress=$(curl -sX GET \
  https://api.clockify.me/api/v1/workspaces/5cad884169b7cc19c5c2cae8/user/${USER}/time-entries?in-progress=true \
  -H "X-Api-Key: ${API_KEY}" \
  -H 'content-type: application/json')

  if [ "$task_in_progress" = "[]" ]; then
	  echo 'Task is not started, not doing anything.'
    osascript -e 'display notification "No hay una tarea iniciada" with title "No se pudo parar el tiempo"'
  else

    id=$(echo $task_in_progress | jq -r .[0].id)
    start_time=$(echo $task_in_progress | jq -r .[0].timeInterval.start)

    status_code=$( curl -sX PUT -o /dev/null -w "%{http_code}" \
    https://api.clockify.me/api/v1/workspaces/5cad884169b7cc19c5c2cae8/time-entries/${id} \
    -H "X-Api-Key: ${API_KEY}" \
    -H 'content-type: application/json' \
    -d '{
        "start": "'${start_time}'",
        "end": "'${TIMESTAMP}'",
        "billable": true,
        "description": "Fin jornada '${DAY_MONTH}'",
        "projectId": "5cad987e1080ec1cfa267c5d"
    }')
    echo 'HTTP RESPONSE STATUS:'
    echo $status_code

    if [[ $status_code == 20* ]]; then
      osascript -e 'display notification "Se ha parado el tiempo." with title "Fin de jornada"'
    else
      osascript -e 'display notification "Al finalizar jornada" with title "ERROR HTTP '$status_code'"'
    fi

  fi
}

require_user_id() {
	if [ -z $USER ]; then
    user_response=$(curl -sX GET https://api.clockify.me/api/v1/user \
    -H "X-Api-Key: XNMBLxCA7ATZl2Eg" \
    -H 'content-type: application/json')

    id=$(echo $user_response | jq -r .id)
    USER=$id
    sed -i '' -e '1,/USER=/s/USER=/USER='${id}'/' ./main.sh  # TODO Replace name with final script name
  fi
}

require_option() {
	while getopts ":t:" opt; do
	case ${opt} in
	t )
    if [[ "$OPTARG" = "finish" ]] || [[ "$OPTARG" = "start" ]]; then
      echo $OPTARG
      exit 0
    else
      echo "Usage: try '-t' [start || finish]"
      exit 1
    fi
	  ;;
	\? )
	  echo "Usage: try '-t' [start || finish]"
	  exit 1
	  ;;
	: )
	  echo "Invalid option: $OPTARG requires an argument" 1>&2
    exit 1
	  ;;
  esac
  done
  echo "Usage: try '-t' [start || finish]"
  exit 1
}

init "$@"
