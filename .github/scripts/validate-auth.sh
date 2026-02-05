#!/bin/bash
set -e

# Validate required environment variables exist
validate_env_vars() {
  local missing=""

  [ -z "$RUNPOD_ASSISTANT_API_URL" ] && missing="$missing RUNPOD_ASSISTANT_API_URL"
  [ -z "$RUNPOD_ASSISTANT_API_KEY" ] && missing="$missing RUNPOD_ASSISTANT_API_KEY"

  if [ -n "$missing" ]; then
    echo "::error::Missing required secrets:$missing"
    exit 1
  fi

  echo "✅ Required secrets are configured"
}

# Test authentication against the Runpod Assistant API
validate_auth() {
  echo "Testing authentication against $RUNPOD_ASSISTANT_API_URL..."

  response=$(curl -s -w "\n%{http_code}" \
    "${RUNPOD_ASSISTANT_API_URL}/api/workflows" \
    -H "Authorization: Bearer $RUNPOD_ASSISTANT_API_KEY")

  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | sed '$d')

  echo "Response: HTTP $http_code"

  if [ "$http_code" -eq 401 ] || [ "$http_code" -eq 403 ]; then
    echo "::error::RUNPOD_ASSISTANT_API_KEY authentication failed - key may be invalid or expired"
    exit 1
  fi

  if [ "$http_code" -ge 400 ]; then
    echo "::warning::API returned HTTP $http_code - endpoint may be unavailable"
  fi

  echo "✅ Authentication successful"
}

# Main
validate_env_vars
validate_auth
