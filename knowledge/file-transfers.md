# File Transfers to and from Pods

## Overview

This document covers common methods for transferring files to/from Runpod pods, including runpodctl, SSH/SCP, and best practices for data management.

## Quick Recommendation

**For users who want the easiest option, runpodctl is recommended.** It's pre-installed on all official Runpod templates and requires no SSH knowledge.

**For more technical users who want more control, SCP (over passwordless SSH) is a great choice.** It uses standard tools and works immediately with official Runpod templates.

## Before Helping with File Transfers

**Important:** Ask the user if they are using an official Runpod template or a custom template. Official templates have networking and ports pre-configured correctly. Custom templates may require additional setup for SSH access.

## Method 1: runpodctl (Easiest)

runpodctl is Runpod's CLI tool for file transfers. **It's pre-installed on all official Runpod templates**, making it the easiest option for most users.

```bash
# On your LOCAL machine, install runpodctl first:
# See: https://docs.runpod.io/cli/install-runpodctl

# Send file to pod (run on local machine)
runpodctl send /local/path/file.txt
# This gives you a code like "abc123"

# Receive file on pod (run from pod terminal)
runpodctl receive abc123
```

**Why use runpodctl:**
- Pre-installed on official templates - no setup needed on the pod
- Simple send/receive model - no SSH knowledge required
- Works even if SSH ports aren't configured properly

**Note:** You only need to install runpodctl on your local machine. The pod already has it.

## Method 2: Passwordless SSH with SCP (For Technical Users)

For users comfortable with SSH, SCP offers more control and flexibility:

1. **Get the SSH command** from the pod's connection info in the console
2. **Use SCP to transfer files:**
   ```bash
   # From local to pod
   scp -P <port> /local/path/file.txt root@<pod-ip>:/workspace/

   # From pod to local
   scp -P <port> root@<pod-ip>:/workspace/file.txt /local/path/
   ```

**Why use SCP:**
- More control over file transfers (wildcards, recursive copies, etc.)
- Familiar to developers who already use SSH
- Can integrate into scripts and automation

## Method 3: Setting Up SSH Keys

Users can set up SSH keys for passwordless authentication, but there are important caveats:

1. **Requires pod restart** - Adding SSH keys to the pod configuration requires restarting the pod
2. **Data loss risk** - Any data NOT in `/workspace` will be lost on restart
3. **Only use this if:** The user has saved all important data to `/workspace` or a network volume

## Important: Understanding the /workspace Directory

For official templates:

- `/workspace` is the persistent storage directory
- **Do NOT create /workspace** - it should already exist. Just `cd /workspace`
- The root home directory (`~`) is often a layer above where users expect:
  ```bash
  cd ~       # Goes to /root
  cd ~/..    # Goes up one level
  ls         # Will show /workspace and other directories
  ```
- If a user says they can't find `/workspace`, have them run:
  ```bash
  cd /
  ls
  # They should see workspace listed
  cd /workspace
  ```

## Networking and Port Configuration

**For official templates:** Ports are pre-configured. SSH should work out of the box.

**For custom templates:** Users may need to:
- Expose the correct ports (typically 22 for SSH)
- Configure their firewall/security settings
- Set up SSH server if not included in their image

If a user has a custom template with networking issues, recommend:
1. Using runpodctl as a fallback (it doesn't need SSH)
2. Starting fresh with an official template if possible
3. Checking community solutions for their specific setup

## Common Scenarios

### "How do I transfer files to my pod?"
→ Recommend runpodctl first (easiest). If they're more technical and want more control, suggest SCP.

### "How do I migrate data between pods?"
→ Use a network volume for persistent shared storage, or use runpodctl/SCP to download locally then upload to new pod.

### "I can't SSH into my pod"
→ Suggest runpodctl as it doesn't require SSH. If using a custom template, ports may not be configured.

### "I lost my data after restarting"
→ Data outside `/workspace` is not persistent. Always save important files to `/workspace` or attach a network volume.

## Best Practices

1. **Use official templates when possible** - They have runpodctl pre-installed and networking pre-configured
2. **Always save data to /workspace** - This persists across pod restarts
3. **Consider network volumes** - For data that needs to persist across different pods
4. **Start with runpodctl** - It's the simplest option for most users
5. **Early decisions matter** - If users are just starting, recommend official templates with proper networking rather than debugging custom setups
