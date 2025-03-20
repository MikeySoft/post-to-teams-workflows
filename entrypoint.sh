#!/bin/bash

set -e
IFS=', ' read -r -a VALID_RESPONSES <<< "${INPUT_VALID_RESPONSES}"

if [ "${INPUT_RAW}" == "null" ] || [ "${INPUT_RAW}" == "" ]; then
  PAYLOAD="$(cat "./payload_template.json")"
else
  PAYLOAD="${INPUT_RAW}"
fi

# Update Title, Message and style
if [ "${INPUT_TITLE}" != "null" ] && [ "${INPUT_TITLE}" != "" ]; then
  TITLE="${INPUT_TITLE}"
else
  TITLE="Title"
fi
if [ "${INPUT_MESSAGE}" != "null" ] && [ "${INPUT_MESSAGE}" != "" ]; then
  MESSAGE="${INPUT_MESSAGE}"
else
  MESSAGE="Message"
fi
PAYLOAD="$(jq ".attachments[0].content.body[0].items[0].text = \"${TITLE}\" | .attachments[0].content.body[0].items[1].text = \"${MESSAGE}\" | .attachments[0].content.body[0].style = \"${INPUT_STYLE}\"" <<< "${PAYLOAD}")"

# Print Payload when set
if [ "${INPUT_PAYLOAD}" == "true" ]; then
  jq <<< "${PAYLOAD}"
fi

# Post to URL
RESPONSE="$(curl --write-out '%{http_code}' --silent -H 'Content-Type: application/json' -d "$(tr -d '\n' <<< "${PAYLOAD}")" "${INPUT_WEBHOOK_URL}")"
case $RESPONSE in
  200)
    MESSAGE="OK"
    ;;
  202)
    MESSAGE="Accepted"
    ;;
  400)
    MESSAGE="Bad Request"
    ;;
  403)
    MESSAGE="Forbidden"
    ;;
  404)
    MESSAGE="Not Found"
    ;;
  405)
    MESSAGE="Method Not Allowed"
    ;;
  500)
    MESSAGE="Internal Server Error"
    ;;
  501)
    MESSAGE="Not Implemented"
    ;;
  502)
    MESSAGE="Bad Gateway"
    ;;
  503)
    MESSAGE="Service Unavailable"
    ;;
  *)
    MESSAGE="Unknown"
    ;;
esac

if ! [ "$(echo "${VALID_RESPONSES[@]}" | grep -o "${RESPONSE}" | wc -w | tr -d ' ')" == "1" ]; then
  echo "POST to Microsoft Teams failed"
  echo -e "\n$RESPONSE $MESSAGE"
  exit 1
else
  echo "$RESPONSE $MESSAGE"
fi

# Set Output
echo "response=${RESPONSE}" >> "${GITHUB_OUTPUT}"
echo "message=${MESSAGE}" >> "${GITHUB_OUTPUT}"
