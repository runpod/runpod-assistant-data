# Image URL Expiration and Lifetime

## Default Expiration

Image URLs returned by Runpod serverless endpoints (such as image generation or editing endpoints) have a **default TTL (time-to-live) of 24 hours**.

After 24 hours, the URL will no longer be accessible and will return a 404 or access denied error.

## Affected Endpoints

This applies to image URLs returned by:
- Image generation endpoints
- Image editing endpoints (e.g., Qwen image edit)
- Any endpoint that returns temporary image storage URLs

## Best Practices

### Download Images Promptly

Always download and store images you need to keep:

```python
import requests

response = requests.get(image_url)
with open("my_image.png", "wb") as f:
    f.write(response.content)
```

### Use Your Own Storage

For production applications, upload images to your own storage:

```python
import boto3

s3 = boto3.client('s3')
s3.upload_fileobj(
    requests.get(image_url, stream=True).raw,
    'my-bucket',
    'images/output.png'
)
```

### Handle Expired URLs

Implement error handling for expired URLs:

```python
response = requests.get(image_url)
if response.status_code == 404:
    # URL has expired, regenerate or handle gracefully
    pass
```

## Custom TTL

Currently, there is no option to configure a custom TTL for image URLs. If you need longer retention:
- Download images immediately after generation
- Store them in your own cloud storage (S3, GCS, etc.)
- Use a CDN for serving to end users

## Questions

For specific questions about image URL retention or enterprise storage options, contact help@runpod.io.
