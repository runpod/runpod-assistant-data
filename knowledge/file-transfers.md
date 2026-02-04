# File Transfers to and from Pods

## TL;DR

**Use SCP over passwordless SSH.** Official Runpod templates have SSH pre-configured - just grab the SSH command from your pod's connection info and use SCP. No setup or restart needed.

```bash
# Copy file to pod
scp -P <port> /local/file.txt root@<pod-ip>:/workspace/

# Copy file from pod
scp -P <port> root@<pod-ip>:/workspace/file.txt /local/path/
```

**Alternatives:**
- **runpodctl** - If you're less familiar with SSH or it's not working. Pre-installed on pods, simple send/receive model.
- **SSH keys** - For permanent/repeated access. More setup involved and requires pod restart to configure through console.

---

## Before Helping with File Transfers

**Important:** Ask the user if they are using an official Runpod template or a custom template. Official templates have SSH and networking pre-configured. Custom templates may require additional setup.

## Method 1: SCP over Passwordless SSH (Recommended for Quick Transfers)

For official Runpod templates, **passwordless SSH works out of the box** - no setup required. This is the recommended method for one-time or occasional file transfers.

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

**Why passwordless SCP is recommended:**
- Works immediately with official templates (no setup needed)
- No pod restart required - use it on running pods right away
- Full control over transfers (wildcards, recursive, etc.)
- Standard tool - integrates with scripts and automation
- Best for one-time or occasional transfers

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

## Method 3: Setting Up SSH Keys (For Permanent/Repeated Access)

SSH key authentication is **more involved to set up but better for permanent or repeated access**. Use this if you'll be connecting frequently and want to avoid the web terminal for SSH details.

**Important caveats:**

1. **Cannot be added to running pods through the console** - SSH keys configured in pod settings are applied at pod start. To add keys to an already-running pod, you must either:
   - Restart the pod (which applies the key from settings), OR
   - Manually add your public key to `~/.ssh/authorized_keys` inside the pod (temporary - lost on restart unless in `/workspace`)

2. **Pod restart required for console-configured keys** - If you add your SSH public key in the pod's configuration (Edit Pod → SSH Public Key), the pod must restart for it to take effect

3. **Data loss risk on restart** - Any data NOT in `/workspace` will be lost when the pod restarts

4. **Best for:** Users who want permanent key-based auth and are okay with the initial restart, or users creating new pods where they can set the key before first start

**For one-time or occasional transfers, stick with passwordless SSH (Method 1)** - it works immediately without any setup or restart.

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

### "How do I set up SSH keys for my pod?"
→ For a running pod, you can't add keys through the console without restarting. Options: (1) Add key in pod settings and restart (data outside /workspace is lost), or (2) manually add your public key to ~/.ssh/authorized_keys inside the pod (temporary). For one-time transfers, just use passwordless SSH - it works immediately.

### "I lost my data after restarting"
→ Data outside `/workspace` is not persistent. Always save important files to `/workspace` or attach a network volume.

## Best Practices

1. **Use official templates when possible** - They have SSH and networking pre-configured
2. **Always save data to /workspace** - This persists across pod restarts
3. **Consider network volumes** - For data that needs to persist across different pods
4. **Start with SCP** - It's the standard tool and works immediately on official templates
5. **Fall back to runpodctl** - If SSH isn't working or you want something simpler
