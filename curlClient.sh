#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# — Load .env ---------------------------------------------------------------
ENV_FILE=".env"
if [[ ! -f $ENV_FILE ]]; then
  echo "Error: $ENV_FILE not found." >&2
  exit 1
fi

set -o allexport
# shellcheck disable=SC2046
source <(grep -vE '^\s*#' "$ENV_FILE")
set +o allexport

# — Validate required variables ---------------------------------------------
: "${CLIENT_ID:?Environment variable CLIENT_ID is required in .env}"
: "${CLIENT_SECRET:?Environment variable CLIENT_SECRET is required in .env}"
: "${WORKSPACE_NAME:?Environment variable WORKSPACE_NAME is required in .env}"
: "${CRIBL_AUDIENCE:?Environment variable CRIBL_AUDIENCE is required in .env}"
: "${ORG_ID:?Environment variable ORG_ID is required in .env}"
: "${CRIBL_DOMAIN:?Environment variable CRIBL_DOMAIN is required in .env}"
: "${CRIBL_AUDIENCE:?Environment variable CRIBL_AUDIENCE is required in .env}"
# — Fetch and extract token ------------------------------------------------
response=$(
  curl -sS \
    -X POST "https://login.${CRIBL_DOMAIN}/oauth/token" \
    -H "Content-Type: application/json" \
    -d @- <<EOF
{
  "grant_type":    "client_credentials",
  "client_id":     "${CLIENT_ID}",
  "client_secret": "${CLIENT_SECRET}",
  "audience":      "${CRIBL_AUDIENCE}"
}
EOF
)
ACCESS_TOKEN=$(
  printf '%s' "$response" \
  | grep -o '"access_token"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -n1 \
  | sed -E 's/.*"access_token"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/'
)
echo $ACCESS_TOKEN

API_URL="https://${WORKSPACE_NAME}-${ORG_ID}.${CRIBL_DOMAIN}/api/v1/m/default/system/inputs"
echo $API_URL
echo "Querying inputs API…" >&2
api_response=$(
  curl -sS -w "\n%{http_code}" \
    -X GET "$API_URL" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json"
)

api_body=$(printf '%s' "$api_response" | sed '$d')
api_status=$(printf '%s' "$api_response" | tail -n1)

if [[ $api_status -ne 200 ]]; then
  echo "Error: inputs API returned HTTP $api_status" >&2
  echo "$api_body" >&2
  exit 1
fi

# pretty‑print or raw output
if command -v jq &>/dev/null; then
  printf '%s\n' "$api_body" | jq .
else
  printf '%s\n' "$api_body"
fi