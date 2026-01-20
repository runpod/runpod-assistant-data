# NVIDIA Driver and CUDA Versions on Runpod

## Current Driver Requirements

Runpod maintains a minimum driver version of **550.xx** across most GPU pools, supporting CUDA up to 12.9.

## CUDA 13 and Driver 580.xx

For CUDA 13 and NVIDIA Blackwell architecture (B200, RTX 5090), driver version 580.xx or higher is required.

### Current Status

- Driver 580.xx rollout is in progress across Runpod datacenters
- Not all regions have been upgraded yet
- EU-RO-1 and some other regions may still be on 550.xx

### Selecting Compatible Hosts

When creating a pod that requires specific driver versions:

1. **Use the GPU filter**: Select GPUs that support your CUDA version
2. **Check datacenter**: Some datacenters receive updates before others
3. **Use Secure Cloud**: Secure Cloud hosts are typically updated first

### Recommended Images for Blackwell GPUs

For Blackwell GPUs (RTX 5090, B200), use images with CUDA 12.4+:

```
runpod/pytorch:1.0.3-cu1281-torch280-ubuntu2404
```

## Checking Driver Version

Once your pod is running, check the driver version:

```bash
nvidia-smi --query-gpu=driver_version --format=csv,noheader
```

Or check CUDA version:

```bash
nvcc --version
```

## Version Compatibility Matrix

| CUDA Version | Minimum Driver | Notes |
|--------------|----------------|-------|
| 12.4 - 12.9  | 550.xx         | Current standard |
| 13.0+        | 580.xx         | Blackwell support |

## Requesting Specific Drivers

Currently, there is no self-service way to request specific driver versions. If you require a particular driver version:

1. Check if Secure Cloud pods meet your requirements
2. Try different datacenters
3. Contact support at help@runpod.io for enterprise needs
