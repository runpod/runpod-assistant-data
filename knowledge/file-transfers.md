# File Transfers to and from Pods

## TL;DR

**SCP is the recommended way to transfer files**, but it requires SSH to be set up first. There are two ways to set up SSH:

1. **Password-based SSH (quick)** - Run a script in your pod's web terminal, get a password, done
2. **SSH key authentication (permanent)** - Add your key to Runpod account, requires pod restart

Once SSH is set up, use SCP from your local machine:
```bash
# Copy file to pod
scp -P <port> /local/file.txt root@<pod-ip>:/workspace/

# Copy file from pod
scp -P <port> root@<pod-ip>:/workspace/file.txt /local/path/
```

**If you haven't set up SSH yet, let me know and I can walk you through either method.**

**Alternative if SSH isn't working:**
- **runpodctl** - Pre-installed on Runpod's official templates (like Runpod Pytorch) or templates based on them. Simple send/receive model, no SSH needed.

---

## Before Helping with File Transfers

**Important:** Ask the user if they are using an official Runpod template or a custom template. Official templates have SSH and networking pre-configured. Custom templates may require additional setup.

## IMPORTANT: SSH/SCP Prerequisites

**SSH and SCP require authentication to be set up first.** Before users can SSH or SCP into their pod, they need ONE of these:

### Decision Tree: How to Set Up SSH Access

**Ask the user these questions to guide them:**

1. **Is your pod currently running?**
   - YES → Options A, B, or C below
   - NO (creating new pod) → Option D is easiest

2. **Do you need one-time or permanent access?**
   - ONE-TIME → Option A (password) or Option B (manual key)
   - PERMANENT → Option C (if running) or Option D (with restart)

3. **Do you have access to the pod's web terminal?**
   - YES → Options A, B, or C
   - NO → Need to use Option D (requires restart)

### SSH Setup Options

| Option | Method | Works on Running Pod? | Permanent? | Requires |
|--------|--------|----------------------|------------|----------|
| **A** | Password-based script | ✅ Yes | ❌ No (until restart) | Web terminal access |
| **B** | Manually add key to ~/.ssh/authorized_keys | ✅ Yes | ❌ No (lost on restart) | Web terminal access |
| **C** | Add key via SSH_PUBLIC_KEY env var | ❌ No (requires restart) | ✅ Yes | Pod restart |
| **D** | Add key to Runpod account settings | ❌ No (requires restart) | ✅ Yes | Pod restart |

### Option A: Password-based SSH (Quick, Running Pods)
- Run setup script in web terminal
- Get a password, use it to SSH/SCP
- **Best for:** Quick one-time access, users who don't want to manage keys

### Option B: Manual Key Injection (One-time, Running Pods)
- Add your public key to `~/.ssh/authorized_keys` via web terminal
- Works immediately, but lost on pod restart
- **Best for:** One-time SSH access when you have your key handy

### Option C: Environment Variable (Permanent, Requires Restart)
- Set `SSH_PUBLIC_KEY` environment variable in pod settings
- Requires pod restart to take effect
- **Best for:** Permanent access, overriding account-level keys for specific pod

### Option D: Account Settings (Permanent, Requires Restart)
- Add key to Runpod account SSH settings
- Key injected on pod start/restart
- **Best for:** Permanent access across all pods

### IMPORTANT: When users ask about SSH

**Always clarify what they're trying to do and guide them to the right option:**

1. "Do you need to SSH/SCP into your pod right now, or set up permanent access?"
2. "Is your pod currently running? Do you have important data outside /workspace?"
3. Based on answers, recommend the appropriate option above

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

If SSH isn't working or you prefer a simpler tool, use `runpodctl`. It's **pre-installed on Runpod's official templates** (like Runpod Pytorch) and templates based on them. If you're using a custom template, runpodctl may not be available.

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
- You're using a Runpod official template like Runpod Pytorch (or one based on it) and want a simple transfer method
- You're less comfortable with SSH commands
- Quick one-off transfers without worrying about connection details

**Note:** runpodctl is only available on Runpod's official templates (like Runpod Pytorch) or templates based on them. Custom templates may not have it installed.

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
→ Recommend SCP, but **always clarify that SCP requires SSH to be set up first**. After explaining SCP, add:

"SCP requires SSH to be configured. If you haven't set up SSH yet, there are two options:
1. **Password-based SSH** (quick) - Run a setup script in your pod's web terminal
2. **SSH key authentication** (permanent) - Add your key to Runpod account, requires pod restart

Let me know if you need help setting up SSH, or if you'd prefer to use runpodctl which doesn't require SSH."

### "How do I migrate data between pods?"
→ Use a network volume for persistent shared storage, or use SCP/runpodctl to download locally then upload to new pod.

### "I can't SSH into my pod"
→ Check if using official template. If custom, ports may not be configured. Suggest runpodctl as alternative since it doesn't require SSH.

### "How do I set up SSH for my pod?" or "How do I SSH into my pod?"
→ **Ask clarifying questions first:**
1. "Is your pod currently running, or are you setting up a new pod?"
2. "Do you need quick one-time access, or permanent SSH access?"
3. "Do you have important data on the pod outside of /workspace?"

**Then guide them based on answers:**

| Situation | Recommendation |
|-----------|---------------|
| Running pod, need quick access | **Password-based** (Option A) - run script in web terminal |
| Running pod, have SSH key handy | **Manual key injection** (Option B) - add to authorized_keys |
| Can restart pod, want permanent access | **Account settings** (Option D) - add key, restart pod |
| Creating new pod | **Account settings** (Option D) - key injected on first start |

**Always warn about restart risks:** If they need to restart, remind them that data outside `/workspace` will be lost.

### "How do I set up SSH keys specifically?"
→ Explain the two permanent options:
1. **Account-level** - Add key to Runpod account settings, applies to all new pods
2. **Pod-level** - Set `SSH_PUBLIC_KEY` env var for specific pod

Both require pod restart. If pod is running with important data, suggest password-based or manual key injection as alternatives that don't require restart.

### "I lost my data after restarting"
→ Data outside `/workspace` is not persistent. Always save important files to `/workspace` or attach a network volume.

## Best Practices

1. **Use official templates when possible** - They have SSH and networking pre-configured
2. **Always save data to /workspace** - This persists across pod restarts
3. **Consider network volumes** - For data that needs to persist across different pods
4. **Start with SCP** - It's the standard tool and works immediately on official templates
5. **Fall back to runpodctl** - If SSH isn't working or you want something simpler
