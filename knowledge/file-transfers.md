# File Transfers to and from Pods

## Before You Start: What Your Template Gives You

Runpod is fundamentally a **GPU + Docker launcher**. The features available on your pod — SSH, web terminal, Jupyter, runpodctl — depend entirely on **what's in your Docker image (template)**.

### Official Templates vs Custom Templates

| Capability | Official Templates (e.g., Runpod Pytorch) | Custom Templates |
|---|:---:|:---:|
| Web terminal | Yes | Only if built into image |
| SSH (openssh-server) | Yes, pre-configured | Only if installed in image |
| TCP port 22 exposed | Yes | Only if configured |
| Jupyter notebook | Yes | Only if installed in image |
| runpodctl CLI | Yes | Only if installed in image |
| /workspace persistence | Yes | Depends on volume config |

**If you're using a custom template and missing features**, you have two options:
1. **Install what you need** in your Docker image (openssh, Jupyter, etc.)
2. **Base your Docker image on an official Runpod template** (e.g., use `runpod/pytorch` as your base image) to inherit all the pre-configured features. Official templates are cached on Runpod, so there's no download penalty.

Reference for official template source: https://github.com/runpod/containers/tree/main

### What This Means for File Transfers

The transfer methods available to you depend on what your template provides:

- **SSH-based methods (SCP, rsync, SFTP)** require openssh-server installed and TCP port 22 exposed
- **runpodctl** requires the CLI pre-installed (official templates have it)
- **croc** can be installed on any pod with terminal access
- **Jupyter upload/download** requires Jupyter in the template
- **Cloud Sync and Network Volume S3 API** work regardless of template — they don't depend on what's installed in the pod

---

## Choosing a Transfer Method

### Quick Comparison

| Method | Needs SSH? | Needs Terminal? | Best For | File Size |
|--------|:----------:|:---------------:|----------|-----------|
| **runpodctl** | No | Yes | Quick one-time transfers | Small-medium |
| **croc** | No | Yes | Quick transfers, any two machines | Small-medium |
| **SCP** | Yes | No (local CLI) | Standard file operations | Any |
| **rsync** | Yes | No (local CLI) | Large datasets, incremental sync | Any |
| **SFTP** | Yes | No (local CLI) | Interactive browsing + transfer | Any |
| **Jupyter upload** | No | No (browser) | Occasional small files | Small only |
| **Cloud Sync** (Console) | No | No (browser) | Backup, cloud provider integration | Any |
| **Network Volume S3 API** | No | No | Automation, no running pod needed | Any |
| **CopyParty** (community) | No | Yes (setup only) | GUI drag-and-drop in browser | Any |
| **Google Drive** (community) | No | No | Google ecosystem users | Medium |

### By Situation

**"I just need to move a file quickly"**
→ runpodctl or croc — both work without SSH setup

**"I have large datasets or need regular syncing"**
→ rsync (incremental, only transfers changed files) or Cloud Sync

**"I want to pre-load data before starting a pod"**
→ Network Volume S3 API — upload to a network volume, then attach it to your pod

**"I don't have SSH or terminal access"**
→ Cloud Sync (console GUI), Network Volume S3 API, or Jupyter upload (if available)

**"I want a drag-and-drop GUI"**
→ CopyParty (web file manager) or Jupyter (small files only)

**"I'm using a custom template with nothing pre-installed"**
→ Cloud Sync works regardless of template. Or install croc (one command). Or base your image on `runpod/pytorch` to get everything.

**Each method has trade-offs.** Ask me about any specific one and I can walk you through the details, or tell me your situation and I can recommend the best fit.

---

## Method 1: runpodctl (No SSH Needed)

The simplest way to transfer files. runpodctl is **pre-installed on official Runpod templates**. It uses peer-to-peer transfer — no SSH configuration required.

**Requirements:** runpodctl installed on both machines (pre-installed on official templates, needs manual install locally).

```bash
# On your LOCAL machine, install runpodctl first:
# See: https://docs.runpod.io/cli/install-runpodctl

# Send a file TO the pod (run on local machine)
runpodctl send /path/to/file.txt
# Outputs a one-time code like "8338-galileo-collect-fidel"

# Receive the file ON the pod (run in pod terminal)
runpodctl receive 8338-galileo-collect-fidel
```

**Pros:** No SSH setup, pre-installed on official templates, works immediately.
**Cons:** Only pre-installed on official templates (custom templates need manual install), requires both sides to run commands interactively, not easily scriptable.

---

## Method 2: croc (No SSH Needed)

croc is similar to runpodctl — a peer-to-peer transfer tool that works between any two machines. It provides **end-to-end encryption**, supports resuming interrupted transfers, and works across platforms.

**Requirements:** croc installed on both machines. Can be installed on any pod with terminal access.

```bash
# Install croc on your pod (one-time)
curl https://getcroc.schollz.com | bash

# Send a file (from sender machine)
croc send /path/to/file.txt
# Outputs a code phrase

# Receive a file (on receiver machine)
croc <code-phrase>
```

croc can also be installed via **ohmyrunpod**, a community tool that sets up croc and SFTP helpers on your pod. See: https://github.com/kodxana/OhMyRunPod

**Pros:** End-to-end encrypted, resume-capable, works on any platform, easy install.
**Cons:** Needs manual install on custom templates, requires both sides to run commands interactively.

---

## Method 3: SCP (Requires SSH)

Standard command-line file transfer over SSH. Reliable and widely supported.

**Requirements:** SSH set up on the pod (see SSH Setup section below). Must use **"SSH over exposed TCP"** — proxy SSH does not support file transfers.

```bash
# Copy file TO pod
scp -P <port> -i ~/.ssh/id_ed25519 yourfile.txt root@<pod-ip>:/workspace/

# Copy file FROM pod
scp -P <port> -i ~/.ssh/id_ed25519 root@<pod-ip>:/workspace/yourfile.txt .

# Copy folder TO pod (recursive)
scp -rP <port> -i ~/.ssh/id_ed25519 yourfolder root@<pod-ip>:/workspace/
```

**Pros:** Standard tool, works on all operating systems, scriptable, supports folders.
**Cons:** Requires SSH setup, re-transfers entire files (no incremental sync), no compression.

---

## Method 4: rsync (Best for Large Datasets)

rsync is ideal for **large datasets and regular syncing** because it only transfers files that have changed (incremental). It also supports compression during transfer and can resume interrupted transfers.

**Requirements:** SSH set up on the pod, rsync installed on both machines. Pre-installed on Linux/Mac. Windows users need WSL.

```bash
# Sync local folder TO pod
rsync -avz -e "ssh -p <port> -i ~/.ssh/id_ed25519" /local/folder/ root@<pod-ip>:/workspace/folder/

# Sync pod folder TO local
rsync -avz -e "ssh -p <port> -i ~/.ssh/id_ed25519" root@<pod-ip>:/workspace/folder/ /local/folder/
```

**Key flags:**
- `-a` — archive mode (preserves permissions, timestamps)
- `-v` — verbose (shows progress)
- `-z` — compress during transfer
- `--delete` — remove files at destination that don't exist at source (use with caution)
- `--progress` — show per-file transfer progress

**Pros:** Incremental (only changed files), compression, resume-capable, preserves metadata, scriptable.
**Cons:** Requires SSH setup, slightly more complex syntax than SCP, Windows needs WSL.

---

## Method 5: SFTP (Interactive SSH File Transfer)

SFTP provides an **interactive file browsing and transfer session** over SSH. It's useful when you want to navigate directories on the pod and selectively transfer files.

**Requirements:** SSH set up on the pod. Must use "SSH over exposed TCP."

```bash
# Connect to pod via SFTP
sftp -P <port> -i ~/.ssh/id_ed25519 root@<pod-ip>

# Once connected, use these commands:
ls                          # List remote files
cd /workspace               # Change remote directory
lcd /local/path             # Change local directory
put localfile.txt           # Upload a file
get remotefile.txt          # Download a file
put -r localfolder          # Upload a folder
get -r remotefolder         # Download a folder
exit                        # Disconnect
```

**Pros:** Interactive browsing, selective transfers, familiar FTP-like interface.
**Cons:** Requires SSH setup, less efficient than rsync for large transfers, manual process.

---

## Method 6: Jupyter Upload/Download (Small Files Only)

If your pod has **Jupyter notebook** running (official templates include it), you can upload and download files through the Jupyter web interface.

**Requirements:** Jupyter installed and running on the pod (official templates have this by default).

**How to use:**
1. Open Jupyter from the pod's **Connect** button in the console
2. Navigate to the directory where you want the file
3. Click **Upload** to upload files from your computer
4. To download: right-click a file → **Download**

**Tip:** For multiple files, **zip them first** before uploading/downloading. Jupyter handles individual files well but can be slow with many files.

**Pros:** No SSH or terminal needed, browser-based, already available on official templates.
**Cons:** Small files only, slow for large or many files, requires Jupyter in the template.

---

## Method 7: Cloud Sync (Console GUI)

Runpod's built-in **Cloud Sync** feature lets you transfer files between your pod and cloud storage providers directly from the console — no terminal or SSH required. **Works regardless of template.**

**Supported providers:**
- Amazon S3
- Google Cloud Storage
- Microsoft Azure Blob Storage
- Dropbox
- Backblaze B2

**How to use:**
1. Go to your pod in the Runpod console
2. Click **Cloud Sync**
3. Select your cloud provider and enter credentials
4. Choose transfer direction (upload or download)
5. Start the sync

**Pros:** No terminal or SSH needed, works on any template, supports major cloud providers, good for large files.
**Cons:** Requires a cloud storage account with credentials, pod must be running.

---

## Method 8: Network Volume S3-Compatible API

Network volumes have an **S3-compatible API** that lets you upload, download, and manage files **without even running a pod**. This is powerful for automation, pre-loading data, and managing files programmatically.

**Requirements:** A network volume in a supported datacenter. No pod needed.

```bash
# Example using AWS CLI
aws s3 cp myfile.txt s3://your-network-volume-bucket/path/ --endpoint-url <your-s3-endpoint>

# Upload a folder
aws s3 sync ./local-folder s3://your-network-volume-bucket/path/ --endpoint-url <your-s3-endpoint>
```

Works with **AWS CLI** and **Boto3** (Python). Available in datacenters: EUR-IS-1, EU-RO-1, EU-CZ-1, US-KS-2, US-CA-2.

**How to get S3 credentials:** Go to Runpod Console → Storage → your network volume → S3 API Access.

**Pros:** No running pod needed, scriptable, works with standard S3 tools, cheapest storage ($0.07/GB/month), great for pre-loading data.
**Cons:** Network volume must be in a supported datacenter, requires S3 credentials setup, network latency for pod access.

---

## Method 9: Web File Manager — CopyParty (Community)

CopyParty is a **community-built web-based file manager** that gives you drag-and-drop file transfers in the browser — no SSH required.

**Requirements:** Terminal access to install it. Works on any pod.

**Setup (run in pod terminal):**
```bash
curl -sL https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py -o /tmp/copyparty.py
tmux new -d -s copyparty "python3 /tmp/copyparty.py -p 8888 /workspace"
```

Then open `https://<pod-ip>:<mapped-port>` in your browser.

**Features:** Drag-and-drop upload, download files/folders as zip, image/video preview, directory navigation.

**Pros:** GUI-based, drag-and-drop, no SSH needed, works in browser.
**Cons:** Community solution (not officially supported), requires exposing an HTTP port, need to install on each pod.

---

## Method 10: Google Drive via Colab (Community)

Transfer files between your Google Drive and Runpod pods using Colab notebooks. This is a **community-provided method**.

- **Send files to pod:** Use the [Send Colab Notebook](https://colab.research.google.com/drive/1UaODD9iGswnKF7SZfsvwHDGWWwLziOsr)
- **Receive files from pod:** Use the [Receive Colab Notebook](https://colab.research.google.com/drive/1ot8pODgystx1D6_zvsALDSvjACBF1cj6)

**Pros:** Familiar Google ecosystem, no SSH or terminal skills needed.
**Cons:** Community solution, requires Google account, limited by Google Drive storage.

---

## SSH Setup (Required for SCP, rsync, and SFTP)

Several transfer methods require SSH access to your pod. **SSH requires openssh-server installed and TCP port 22 exposed** — official templates have this pre-configured, custom templates may not.

### The Two SSH Connection Types

Runpod shows **two SSH options** in the Connect → SSH tab:

| Method | Command | File Transfer Support |
|--------|---------|:---------------------:|
| **SSH over exposed TCP** | `ssh root@<ip> -p <port> -i ~/.ssh/key` | Yes (SCP, SFTP, rsync) |
| **Proxy SSH** | `ssh podId@ssh.runpod.io -i ~/.ssh/key` | No (shell only) |

**For file transfers, you must use "SSH over exposed TCP."** Proxy SSH only supports shell access — no SCP, SFTP, or rsync.

### Getting SSH Access

Choose based on your situation:

#### Already-running pod (no restart needed)

**Option A: Password script** — Fastest way to get SSH on a running pod.

Requirements: TCP port 22 exposed (official templates have this), web terminal access.

1. Open your pod's **web terminal** in the console
2. Run:
   ```bash
   wget https://raw.githubusercontent.com/justinwlin/Runpod-SSH-Password/main/passwordrunpod.sh && chmod +x passwordrunpod.sh && ./passwordrunpod.sh
   ```
3. Enter a password when prompted
4. The script outputs your SSH/SCP commands

Pros: Works immediately, no restart. Cons: Password-based, need to re-run after restart.

**Option B: Manual key injection** — Add your SSH key directly via the web terminal.

1. Open your pod's **web terminal**
2. Run:
   ```bash
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```
3. Connect: `ssh root@<ip> -p <port> -i ~/.ssh/your_key`

Pros: Key-based auth. Cons: Lost on pod restart (save to /workspace/.ssh/ to persist).

#### New pod or okay with restart (permanent access)

**Option C: Add key to Runpod account** — Permanent SSH across all pods.

1. Go to Runpod Console → Account Settings → SSH Keys
2. Paste your public key (from `~/.ssh/id_ed25519.pub`)
3. **Restart your pod** (or create a new one) — the key is auto-injected on startup

Pros: Permanent, applies to all pods. Cons: Requires pod restart.

**Option D: Set SSH_PUBLIC_KEY env var** — Per-pod key override.

1. Edit Pod → Environment Variables
2. Add: `SSH_PUBLIC_KEY=your_public_key_here`
3. **Restart the pod**

Pros: Pod-specific override. Cons: Requires pod restart.

### SSH Key Auto-Injection

When you add your SSH public key to your Runpod account settings, Runpod automatically injects it via the `SSH_PUBLIC_KEY` environment variable when the pod starts. The key gets added to `~/.ssh/authorized_keys` during startup. This only works on pod start/restart — **not on already-running pods**.

### Custom Templates: Getting SSH Working

If your custom template doesn't have SSH:
1. **Recommended:** Base your Docker image on `runpod/pytorch` to inherit SSH, Jupyter, web terminal, and runpodctl
2. **Manual:** Install openssh-server in your Dockerfile and expose TCP port 22
3. **Reference:** https://github.com/runpod/containers/tree/main

---

## Important: Understanding /workspace

For official Runpod templates:
- `/workspace` is the **persistent storage directory**
- **Do NOT create /workspace** — it should already exist on official templates
- Data **outside /workspace is lost on pod restart**
- Always transfer files to `/workspace` to ensure they survive restarts

---

## Common Questions

### "How do I transfer files to my pod?"

There are several options — the best one depends on your situation. A few questions that help narrow it down:
- What template are you using (official like Runpod Pytorch, or custom)?
- Is your pod already running?
- How large are the files?
- Do you need one-time transfer or regular syncing?

Based on your answers, I can recommend the best approach and walk you through the steps.

### "I can't SSH into my pod"

A few things to check:
1. **Is openssh-server installed?** Official templates have it, custom templates may not.
2. **Is TCP port 22 exposed?** Check pod settings. If not, adding it will restart the pod.
3. **Is your SSH key registered?** Check Account Settings → SSH Keys.

If SSH isn't an option, there are several methods that **don't need SSH:** runpodctl, croc, Cloud Sync, Jupyter upload, CopyParty, or Network Volume S3 API.

### "I'm using a custom template — what are my options?"

Custom templates only have what's in the Docker image. Your transfer options:
- **Cloud Sync** — works on any template (console feature)
- **Network Volume S3 API** — works without even running a pod
- **Install croc** — one command: `curl https://getcroc.schollz.com | bash`
- **Base your image on `runpod/pytorch`** — inherits SSH, Jupyter, web terminal, runpodctl

### "What's the best way to transfer model weights?"

For large model files (10+ GB), consider:
1. **Network volumes** — Pre-load the model once via S3 API, then attach the volume to any pod. No re-transfer needed.
2. **rsync** — Incremental transfer, resume if interrupted, compression.
3. **Cloud Sync** — Upload to S3/GCS first, then sync to pod.
4. **Hugging Face / model hubs** — Download directly on the pod using `wget`, `git lfs`, or the `transformers` library.

### "Can I transfer files without a running pod?"

Yes — use the **Network Volume S3-compatible API**. Upload, download, and manage files on a network volume using standard S3 tools (AWS CLI, Boto3) without any pod running. Available in select datacenters.

### "Proxy SSH vs SSH over exposed TCP — what's the difference?"

**SSH over exposed TCP** (`ssh root@<ip> -p <port>`) supports full SSH including SCP, SFTP, and rsync. Found in Connect → SSH → "SSH over exposed TCP."

**Proxy SSH** (`ssh podId@ssh.runpod.io`) is limited to shell access only — no file transfers. Only use this if direct TCP isn't available and you just need a shell.

---

## Multiple Paths Available

File transfers on Runpod have multiple valid approaches depending on your template, file size, and preferences. If you'd like more detail on any method, help choosing between options, or guidance on getting a specific method working, just ask — I can walk you through whatever fits your needs.
