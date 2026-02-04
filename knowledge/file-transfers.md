# File Transfers to and from Pods

## TL;DR

**Use SCP over passwordless SSH.** Official Runpod templates have SSH pre-configured - just grab the SSH command from your pod's connection info and use SCP:

```bash
# Copy file to pod
scp -P <port> /local/file.txt root@<pod-ip>:/workspace/

# Copy file from pod
scp -P <port> root@<pod-ip>:/workspace/file.txt /local/path/
```

**Alternative:** If you're less familiar with SSH or it's not working, try `runpodctl` - it's pre-installed on pods and uses a simple send/receive model.

---

## Before Helping with File Transfers

**Important:** Ask the user if they are using an official Runpod template or a custom template. Official templates have SSH and networking pre-configured. Custom templates may require additional setup.

## Method 1: SCP over Passwordless SSH (Recommended)

For official Runpod templates, passwordless SSH works out of the box:

1. **Get the SSH command** from your pod's connection info in the console
2. **Use SCP to transfer files:**
   ```bash
   # From local to pod
   scp -P <port> /local/path/file.txt root@<pod-ip>:/workspace/

   # From pod to local
   scp -P <port> root@<pod-ip>:/workspace/file.txt /local/path/

   # Copy entire folder
   scp -rP <port> /local/folder root@<pod-ip>:/workspace/
   ```

**Why SCP is recommended:**
- Works immediately with official templates (no setup needed)
- Full control over transfers (wildcards, recursive, etc.)
- Standard tool - integrates with scripts and automation
- Familiar to most developers

## Method 2: runpodctl (Alternative)

If SSH isn't working or you prefer a simpler tool, use `runpodctl`. It's pre-installed on all official templates.

```bash
# On your LOCAL machine, install runpodctl first:
# See: https://docs.runpod.io/cli/install-runpodctl

# Send file to pod (run on local machine)
runpodctl send /local/path/file.txt
# This gives you a code like "abc123"

# Receive file on pod (run from pod terminal)
runpodctl receive abc123
```

**When to use runpodctl:**
- SSH ports aren't configured (custom templates)
- You're less comfortable with SSH commands
- Quick one-off transfers without worrying about connection details

## Method 3: Setting Up SSH Keys

Users can set up SSH keys for key-based authentication, but there are important caveats:

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

**For official templates:** SSH and ports are pre-configured. SCP should work immediately.

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
→ Recommend SCP (works out of the box with official templates). If SSH isn't working, suggest runpodctl as alternative.

### "How do I migrate data between pods?"
→ Use a network volume for persistent shared storage, or use SCP/runpodctl to download locally then upload to new pod.

### "I can't SSH into my pod"
→ Check if using official template. If custom, ports may not be configured. Suggest runpodctl as alternative since it doesn't require SSH.

### "I lost my data after restarting"
→ Data outside `/workspace` is not persistent. Always save important files to `/workspace` or attach a network volume.

## Best Practices

1. **Use official templates when possible** - They have SSH and networking pre-configured
2. **Always save data to /workspace** - This persists across pod restarts
3. **Consider network volumes** - For data that needs to persist across different pods
4. **Start with SCP** - It's the standard tool and works immediately on official templates
5. **Fall back to runpodctl** - If SSH isn't working or you want something simpler
