# runpod-assistant-data

Knowledge base and scraped content that feeds into the [runpod-assistant](https://github.com/runpod/runpod-assistant) RAG pipeline.

## Structure

```
knowledge/    # Curated markdown articles (support gaps, troubleshooting)
scraped/      # Cached JSON from runpod.io and blog (~540 files)
```

## Ingestion

Content from this repo is indexed into the assistant's vector store via two mechanisms:

### 1. GitHub Action (immediate, on push)

A [workflow](.github/workflows/trigger-knowledge-ingestion.yml) fires on every push to `main` that modifies `knowledge/` or `scraped/`. It calls the v2 production endpoint (`POST /api/ingest`) to trigger the `ingestKnowledgeWorkflow` on Convex.

Can also be triggered manually via workflow dispatch.

### 2. Convex cron (daily backup)

The assistant's Convex backend runs a `check-knowledge-repo` cron every 24 hours that polls this repo's latest commit SHA. If it detects a new commit, it triggers ingestion automatically. This serves as a backup in case the GitHub Action fails or is skipped.

### How ingestion works

1. Fetches the file tree from `runpod/runpod-assistant-data` via the GitHub API
2. Filters for `.md` files in `knowledge/`
3. Compares content hashes to skip unchanged files
4. Indexes into RAG (vector search) and mirrors to a documents table (BM25 full-text search)

Files are kept as single chunks (~1-3k tokens each) so full context stays together in vector results.

## Required secrets

The GitHub Action needs two repository secrets:

| Secret | Purpose |
|--------|---------|
| `RUNPOD_ASSISTANT_API_URL` | Base URL of the runpod-assistant v2 deployment (include `https://`) |
| `RUNPOD_ASSISTANT_API_KEY` | Authenticates against the runpod-assistant v2 API |

Set these in [repo settings > Secrets and variables > Actions](https://github.com/runpod/runpod-assistant-data/settings/secrets/actions).

> **Note:** The old `MASTRA_API_KEY` secret is no longer used and can be removed.

## Contributing

1. Add or edit markdown files in `knowledge/`
2. Push to `main`
3. Ingestion triggers automatically — no manual steps needed
