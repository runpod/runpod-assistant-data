# Running KoboldCPP on Runpod

The fastest way to get KoboldCPP running on Runpod is via the official template.

## Deploy the template

Go to the [Deploy Pod](https://www.runpod.io/console/deploy) page and select the KoboldCPP template, or navigate directly to the [official KoboldCPP template](https://console.runpod.io/explore/2peen7lpau).

## Set environment variables

Before booting, configure these environment variables to specify your model and runtime arguments:

| Variable | Description |
|---|---|
| `KCPP_MODEL` | URL(s) to your GGUF model file(s), comma-delimited for multiple files |
| `KCPP_ARGS` | Runtime arguments for KoboldCPP |
| `KCPP_IMGMODEL` | (Optional) URL to an image generation model |
| `KCPP_WHISPERMODEL` | (Optional) URL to a Whisper speech model |

Default example values:

```
KCPP_MODEL: https://huggingface.co/KoboldAI/LLaMA2-13B-Tiefighter-GGUF/resolve/main/LLaMA2-13B-Tiefighter.Q4_K_S.gguf
KCPP_ARGS: --usecublas mmq --gpulayers 999 --contextsize 4096 --multiuser 20 --flashattention --ignoremissing
KCPP_IMGMODEL: https://huggingface.co/fp16-guy/PicX_real/resolve/main/picX_real.safetensors
KCPP_WHISPERMODEL: https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin?download=true
```

**Important:** Ensure there is a space after each value and the next argument in `KCPP_ARGS`, otherwise you'll get a segfault.

## Access the endpoint

Once running, the OpenAI-compatible API endpoint is available on port 5001 via the Runpod proxy:

```
https://[your-pod-id]-5001.proxy.runpod.net/
```

You can also open this URL directly in a browser to access the KoboldCPP UI.

## Alternative: manual install

If you prefer to install KoboldCPP manually in a pod (e.g., to add it to an existing image), run:

```bash
curl -fLo koboldcpp https://koboldai.org/cpplinuxcu12
chmod +x koboldcpp
./koboldcpp --model <link-to-gguf-model>
```

## Sources

- [Runpod blog: GGUF quantized models with KoboldCPP](https://www.runpod.io/blog/gguf-quantized-models-koboldcpp-runpod#how-to-get-running-with-gguf-quants-immediately)
- [Official KoboldCPP template](https://console.runpod.io/explore/2peen7lpau)
