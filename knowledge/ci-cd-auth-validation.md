# CI/CD Authentication Validation in Pull Requests

Best practice for validating environment authentication during pull requests to prevent deployment failures after merge.

## The Problem

When CI/CD workflows depend on secrets or environment variables (API keys, deployment tokens, cloud credentials), failures often only surface after merging to main. This creates issues:

- Broken deployments to production
- Blocked release pipelines
- Time wasted debugging authentication issues post-merge
- Potential downtime if the broken merge was already deployed

## Solution: Pre-Merge Authentication Checks

Add a workflow that runs on pull requests to validate:

1. **Required secrets exist** - Verify expected secrets are configured
2. **Authentication works** - Test that credentials can successfully authenticate
3. **Permissions are sufficient** - Confirm the credentials have required access levels

## Example: GitHub Actions Workflow

```yaml
# .github/workflows/validate-auth.yml
name: Validate Authentication

on:
  pull_request:
    branches: [main]

jobs:
  validate-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Check required secrets exist
        env:
          RUNPOD_API_KEY: ${{ secrets.RUNPOD_API_KEY }}
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
        run: |
          missing=""
          [ -z "$RUNPOD_API_KEY" ] && missing="$missing RUNPOD_API_KEY"
          [ -z "$VERCEL_TOKEN" ] && missing="$missing VERCEL_TOKEN"

          if [ -n "$missing" ]; then
            echo "::error::Missing required secrets:$missing"
            exit 1
          fi
          echo "All required secrets are configured"

      - name: Validate Runpod API Key
        env:
          RUNPOD_API_KEY: ${{ secrets.RUNPOD_API_KEY }}
        run: |
          response=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "Authorization: Bearer $RUNPOD_API_KEY" \
            "https://api.runpod.io/graphql" \
            -d '{"query":"{ myself { id } }"}')

          if [ "$response" != "200" ]; then
            echo "::error::Runpod API authentication failed (HTTP $response)"
            exit 1
          fi
          echo "Runpod API authentication successful"

      - name: Validate Vercel Token
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
        run: |
          response=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "Authorization: Bearer $VERCEL_TOKEN" \
            "https://api.vercel.com/v2/user")

          if [ "$response" != "200" ]; then
            echo "::error::Vercel authentication failed (HTTP $response)"
            exit 1
          fi
          echo "Vercel authentication successful"
```

## Key Principles

### 1. Fail Fast

Run authentication checks early in the PR workflow. Don't wait until deployment steps to discover credential issues.

### 2. Clear Error Messages

When authentication fails, provide actionable error messages:
- Which secret is missing or invalid
- What permission might be lacking
- How to fix the issue

### 3. Minimal Scope Testing

Only test that authentication works - don't perform actual deployments or modifications during PR validation.

### 4. Handle Secret Rotation

When secrets are rotated, the PR validation workflow will catch misconfigurations before they affect production.

## Common Services to Validate

| Service | Validation Endpoint | What to Check |
|---------|---------------------|---------------|
| Runpod | `api.runpod.io/graphql` | API key validity |
| Vercel | `api.vercel.com/v2/user` | Token and team access |
| AWS | `sts.amazonaws.com` (GetCallerIdentity) | IAM credentials |
| Docker Hub | `hub.docker.com/v2/users/login` | Registry push access |
| npm | `registry.npmjs.org/-/npm/v1/user` | Publish token |

## Runpod-Specific Validation

For Runpod deployments, validate:

```yaml
- name: Validate Runpod credentials
  env:
    RUNPOD_API_KEY: ${{ secrets.RUNPOD_API_KEY }}
  run: |
    # Check API key works
    result=$(curl -s \
      -H "Authorization: Bearer $RUNPOD_API_KEY" \
      -H "Content-Type: application/json" \
      "https://api.runpod.io/graphql" \
      -d '{"query":"{ myself { id email } }"}')

    if echo "$result" | grep -q "errors"; then
      echo "::error::Runpod API key is invalid or expired"
      exit 1
    fi

    echo "Runpod authentication verified"
```

## Benefits

- **Catch issues early**: Authentication problems surface during code review, not after merge
- **Faster debugging**: Clear which credential failed and why
- **Safer deployments**: Confidence that merge won't break due to auth issues
- **Documentation**: The workflow documents which secrets are required
