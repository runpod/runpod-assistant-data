#!/bin/bash
set -e

# Generate a unique run ID
RUN_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
echo "Run ID: $RUN_ID"

# Step 1: Create workflow run
echo "Creating workflow run..."
create_response=$(curl -s -w "\n%{http_code}" -X POST \
  "${RUNPOD_ASSISTANT_BASE_URL}/api/workflows/ingestKnowledgeWorkflow/create-run?runId=$RUN_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RUNPOD_ASSISTANT_API_KEY" \
  -d '{}')

create_code=$(echo "$create_response" | tail -n1)
create_body=$(echo "$create_response" | sed '$d')
echo "Create response: $create_body (HTTP $create_code)"

if [ "$create_code" -ne 200 ]; then
  echo "❌ Failed to create workflow run"
  exit 1
fi

# Step 2: Start workflow run
echo "Starting workflow run..."
start_response=$(curl -s -w "\n%{http_code}" -X POST \
  "${RUNPOD_ASSISTANT_BASE_URL}/api/workflows/ingestKnowledgeWorkflow/start?runId=$RUN_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RUNPOD_ASSISTANT_API_KEY" \
  -d '{"inputData": {"branch": "main"}}')

start_code=$(echo "$start_response" | tail -n1)
start_body=$(echo "$start_response" | sed '$d')
echo "Start response: $start_body (HTTP $start_code)"

if [ "$start_code" -eq 200 ]; then
  echo "✅ Successfully triggered knowledge ingestion workflow"
else
  echo "❌ Failed to start workflow"
  exit 1
fi
