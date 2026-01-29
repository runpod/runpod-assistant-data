# runpod-assistant-data

Curated knowledge and scraped content for the Runpod Assistant's RAG pipeline.

## How it works

When files in `knowledge/` or `scraped/` are pushed to `main`, a GitHub Action triggers the Mastra `ingestKnowledgeWorkflow` to re-index the content into the vector database.

### Workflow steps

1. **Validate secrets** — Fails early if `MASTRA_BASE_URL` or `RUNPOD_ASSISTANT_API_KEY` are missing
2. **Create workflow run** — Registers a new run with a unique ID
3. **Start workflow run** — Kicks off the ingestion with `branch: main`
4. **Poll for completion** — Checks status every 5s (up to 5 min) and prints an ingestion summary

### Required secrets

Add these in the repo's GitHub Settings > Secrets > Actions:

| Secret | Description |
|--------|-------------|
| `MASTRA_BASE_URL` | Mastra deployment URL (e.g. `https://runpod-assistant.mastra.cloud`) |
| `RUNPOD_ASSISTANT_API_KEY` | API key for authenticating with the Mastra backend |

## Testing the workflow locally

You can run the GitHub Action locally using [nektos/act](https://github.com/nektos/act).

### Prerequisites

```bash
# Install act (macOS)
brew install act

# Docker must be running
```

### Setup

Create a `.secrets` file in the repo root (already gitignored):

```
MASTRA_BASE_URL=https://runpod-assistant-dev.mastra.cloud
RUNPOD_ASSISTANT_API_KEY=your-api-key-here
```

### Run

```bash
act push --secret-file .secrets \
  -W .github/workflows/trigger-knowledge-ingestion.yml \
  --container-architecture linux/amd64
```

### Expected output

```
✅ Validate secrets
✅ Create workflow run (Run ID: abc123...)
✅ Workflow started
✅ Knowledge ingestion completed successfully

Ingestion Summary:
  Total docs: 9
  New docs: 0
  Changed docs: 0
  Unchanged docs: 9
  Deleted docs: 0
  Total chunks: 0
  Duration: 842ms

🏁 Job succeeded
```

If the workflow fails, the error messages will tell you exactly what went wrong (missing secrets, auth failure, unreachable server, ingestion errors, etc.).

## Manual trigger

You can also trigger the workflow manually from the GitHub Actions tab (workflow_dispatch) without pushing any files.
