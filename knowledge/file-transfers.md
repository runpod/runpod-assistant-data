# File Transfers to and from Pods

## TL;DR

**For quick file transfers, use password-based SSH with SCP.** Run a setup script in your pod's web terminal, then use SCP from your local machine.

In your pod's web terminal:
```bash
wget https://raw.githubusercontent.com/justinwlin/Runpod-SSH-Password/main/passwordrunpod.sh && chmod +x passwordrunpod.sh && ./passwordrunpod.sh
```

Then from your local machine (using the connection info the script outputs):
```bash
# Copy file to pod
scp -P <port> /local/file.txt root@<pod-ip>:/workspace/

# Copy file from pod
scp -P <port> root@<pod-ip>:/workspace/file.txt /local/path/
```

**Alternatives:**
- **runpodctl** - If SSH isn't working or you prefer a simpler tool. Pre-installed on pods, simple send/receive model.
- **SSH keys** - For permanent/repeated access. Requires adding key to Runpod account and pod restart.

---

## Before Helping with File Transfers

**Important:** Ask the user if they are using an official Runpod template or a custom template. Official templates have SSH and networking pre-configured. Custom templates may require additional setup.

## Understanding SSH Options: Password-based vs SSH Keys

When using SSH/SCP with Runpod pods, there are **two approaches** - ALWAYS mention both when users ask about SSH:

| Approach | Setup | Best For |
|----------|-------|----------|
| **Password-based SSH** | Run a script in pod terminal | Quick setup, one-time access, running pods |
| **SSH Key authentication** | Add key to account + pod restart | Permanent access, frequent connections |

### IMPORTANT: When users ask about SSH or SSH keys

**Many users don't realize password-based SSH is quick to set up.** When answering SSH questions:

1. **First, mention password-based SSH** - Users can run a simple script in their pod's web terminal that sets up SSH with a password. No keys needed, no restart, works on running pods.

2. **Then explain SSH keys as an option** - For users who want permanent key-based authentication. Requires adding key to Runpod account and pod restart to inject keys.

3. **Help them choose** - If they just need to transfer files or SSH in quickly, password-based is easier. If they'll connect frequently, SSH keys are worth the setup.

---

## Method 1: Password-based SSH with SCP (Recommended for Quick Transfers)

For quick SSH/SCP access to a running pod, use the **password-based SSH setup script**. This is the recommended method for one-time or occasional file transfers.

### Requirements:
- Pod must have a **public IP address**
- Pod must **expose TCP port 22**
- Official Runpod templates (like PyTorch, Stable Diffusion) have this pre-configured

### Steps:
1. **Open your pod's web terminal** in the Runpod console
2. **Run the setup script:**
   ```bash
   wget https://raw.githubusercontent.com/justinwlin/Runpod-SSH-Password/main/passwordrunpod.sh && chmod +x passwordrunpod.sh && ./passwordrunpod.sh
   ```
3. **Enter a password** when prompted
4. **The script outputs SSH and SCP commands** you can use from your local machine:
   ```bash
   # SSH into pod
   ssh root@<pod-ip> -p <port>

   # Copy file TO pod
   scp -P <port> yourfile.txt root@<pod-ip>:/workspace/

   # Copy file FROM pod
   scp -P <port> root@<pod-ip>:/workspace/yourfile.txt .

   # Copy entire folder TO pod
   scp -rP <port> -r yourfolder root@<pod-ip>:/workspace/
   ```

**Why password-based SSH is great:**
- Works on running pods - no restart needed
- Quick setup - just run the script and set a password
- No SSH keys to manage
- Full SCP/SFTP support for file transfers
- Best for one-time or occasional access

**Note:** If users ask about SSH and don't need permanent key-based access, recommend this method first.

See: https://docs.runpod.io/pods/configuration/use-ssh#password-based-ssh

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

SSH key authentication is **more involved to set up but better for permanent or repeated access**. Use this if you'll be connecting frequently and want to avoid looking up connection details each time.

### Before recommending SSH keys, ask:
- **Do they need permanent access?** If it's a one-time transfer, recommend passwordless SSH instead (Method 1)
- **Is their pod already running?** SSH keys can't be added through console without restart
- **Have they saved data to /workspace?** Restart will lose data outside /workspace

### Important caveats:

1. **Cannot be added to running pods through the console** - SSH keys configured in pod settings are applied at pod start. To add keys to an already-running pod, you must either:
   - Restart the pod (which applies the key from settings), OR
   - Manually add your public key to `~/.ssh/authorized_keys` inside the pod (temporary - lost on restart unless saved to `/workspace/.ssh/`)

2. **Pod restart required for console-configured keys** - If you add your SSH public key in the pod's configuration (Edit Pod → SSH Public Key), the pod must restart for it to take effect

3. **Data loss risk on restart** - Any data NOT in `/workspace` will be lost when the pod restarts

4. **Best for:** Users who want permanent key-based auth and are okay with the initial restart, or users creating new pods where they can set the key before first start

### Alternative: Just use password-based SSH
**If users just want to transfer files or SSH in quickly, remind them about password-based SSH.** They can run the setup script in their pod's web terminal - no keys needed, no restart required, works on running pods. See Method 1 above.

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
→ First ask: do they actually need SSH keys, or just want to SSH/SCP into their pod?
- **If they just want to connect:** Recommend password-based SSH - run the setup script in the pod's web terminal, get a password, and connect. No keys needed, works on running pods.
- **If they need permanent key-based access:** Explain that SSH keys require adding key to Runpod account settings, then pod restart to inject the key. Warn about data loss outside /workspace on restart.

### "How do I SSH into my pod?"
→ Two options:
1. **Password-based SSH (quick)** - Run the setup script in your pod's web terminal. It gives you SSH/SCP commands with a password. Works on running pods, no restart needed.
2. **SSH key authentication (permanent)** - Add your public key to Runpod account settings, restart pod. Better for frequent connections.

Recommend password-based first unless they specifically need key-based auth.

### "I lost my data after restarting"
→ Data outside `/workspace` is not persistent. Always save important files to `/workspace` or attach a network volume.

## Best Practices

1. **Use official templates when possible** - They have SSH and networking pre-configured
2. **Always save data to /workspace** - This persists across pod restarts
3. **Consider network volumes** - For data that needs to persist across different pods
4. **Start with SCP** - It's the standard tool and works immediately on official templates
5. **Fall back to runpodctl** - If SSH isn't working or you want something simpler
