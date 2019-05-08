#!/bin/bash

API_KEY=XNMBLxCA7ATZl2Eg

init() {
  require_api_key
  require_jq

  pre_build_api_key
  pre_build_user_id

  build
}

require_api_key() {
  if [ -z $API_KEY ]; then
    echo 'Exit: API_KEY is missing.'
    exit 1
  fi
}

require_jq() {
  jq --version || brew install jq
}

pre_build_api_key() {
  sed -i '' -e '1,/API_KEY=/s/API_KEY=/API_KEY='${API_KEY}'/' ./src/clockify-start.sh
  sed -i '' -e '1,/API_KEY=/s/API_KEY=/API_KEY='${API_KEY}'/' ./src/clockify-finish.sh
}

pre_build_user_id() {
    user_response=$(curl -sX GET https://api.clockify.me/api/v1/user \
    -H "X-Api-Key: ${API_KEY}" \
    -H 'content-type: application/json')

    id=$(echo $user_response | jq -r .id)
    USER=$id

    sed -i '' -e '1,/USER=/s/USER=/USER='${id}'/' ./src/clockify-start.sh
    sed -i '' -e '1,/USER=/s/USER=/USER='${id}'/' ./src/clockify-finish.sh
}

build() {
  ./lib/appify.sh ./src/clockify-start.sh "Clockify Start"
  mv "Clockify start.app" build/
}

init "$@"
