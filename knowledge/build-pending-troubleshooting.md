# Build Stuck in Pending State

When creating a serverless endpoint template, builds may get stuck in a PENDING state. Here's how to troubleshoot.

## Build States

| State | Description |
|-------|-------------|
| PENDING | Build is queued, waiting to start |
| BUILDING | Build is actively running |
| COMPLETED | Build finished successfully |
| FAILED | Build encountered an error |

## Why Builds Stay in PENDING

1. **High queue volume**: During peak times, builds queue behind others
2. **Platform maintenance**: Build infrastructure may be temporarily scaled down
3. **Resource constraints**: Large builds may wait for available capacity

## Expected Wait Times

- **Typical**: 1-5 minutes
- **Peak hours**: Up to 15-30 minutes
- **If longer than 30 minutes**: May indicate a platform issue

## Troubleshooting Steps

### 1. Check Runpod Status Page

Visit [status.runpod.io](https://status.runpod.io) to check for any ongoing incidents affecting the build service.

### 2. Cancel and Retry

If a build is stuck for an extended period:

1. Cancel the current build from the template settings
2. Wait a few minutes
3. Trigger a new build

### 3. Verify Dockerfile

Ensure your Dockerfile is valid and doesn't have issues that could cause build failures:

```dockerfile
# Example valid Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "handler.py"]
```

### 4. Check Image Size

Very large images (10GB+) may take longer to build and push. Consider:
- Using multi-stage builds
- Starting from a smaller base image
- Cleaning up unnecessary files

## Getting Help

If builds consistently fail or remain stuck:
- Check the Runpod Discord for similar reports
- Contact support at help@runpod.io with your template ID
