# File Transfers to and from Pods

## TL;DR

**SCP is the recommended way to transfer files**, but it requires SSH to be set up first.

For a quick overview:
- **Official Runpod templates** (like Runpod Pytorch) have openssh pre-installed and port 22 exposed
- **If your SSH key is registered with Runpod**, it's auto-injected when the pod starts
- **For running pods without SSH set up**, use the password script in the web terminal
- **runpodctl** is an alternative that doesn't need SSH (only on official templates)

**This is a complex topic with multiple paths.** Feel free to ask for more details on any specific option.

---

## How SSH Works on Runpod

### Understanding the Two SSH Methods

Runpod offers **two ways to SSH into a pod**:

| Method | Command Format | SCP/SFTP Support | Requirements |
|--------|---------------|------------------|--------------|
| **Proxy SSH** | `ssh podId@ssh.runpod.io -i ~/.ssh/key` | ❌ No | SSH key registered with Runpod |
| **Direct TCP SSH** | `ssh root@<ip> -p <port> -i ~/.ssh/key` | ✅ Yes | TCP port 22 exposed |

**Important:** For file transfers with SCP/SFTP, you need **Direct TCP SSH** (port 22 exposed).

### What Official Templates Provide

Runpod's official templates (like Runpod Pytorch, Stable Diffusion) come with:
- **openssh-server pre-installed** and running
- **TCP port 22 exposed** - gives you a public IP and mapped port
- Ready for both proxy SSH and direct TCP SSH

Custom templates may not have these configured.

---

## SSH Setup Options

### The SSH Key Auto-Injection System

**If you add your SSH public key to your Runpod account settings:**
- Runpod automatically injects it via the `SSH_PUBLIC_KEY` environment variable when the pod starts
- The key gets added to `~/.ssh/authorized_keys` during pod startup
- This only works on pod start/restart - **not on already-running pods**

### Decision Tree: How to Get SSH Access

**Ask these questions:**

1. **Is your pod already running?**
   - YES, and I have terminal access → Use **Option A** (password script) or **Option B** (manual key)
   - YES, but no terminal access → Need to restart pod (see Option C/D)
   - NO, creating new pod → Use **Option C** or **Option D**

2. **Do you need one-time or permanent access?**
   - ONE-TIME → Option A or B
   - PERMANENT → Option C or D (but requires restart if pod is running)

### Option A: Password Script (Running Pods, Quick Access)

For quick SSH/SCP access to a **running pod**, use the password setup script:

**Requirements:**
- TCP port 22 must be exposed (official templates have this)
- Access to the pod's web terminal

**Steps:**
1. Open your pod's **web terminal** in the Runpod console
2. Run:
   ```bash
   wget https://raw.githubusercontent.com/justinwlin/Runpod-SSH-Password/main/passwordrunpod.sh && chmod +x passwordrunpod.sh && ./passwordrunpod.sh
   ```
3. Enter a password when prompted
4. The script outputs your SSH/SCP commands:
   ```bash
   ssh root@<ip> -p <port>
   scp -P <port> file.txt root@<ip>:/workspace/
   ```

**Pros:** Works immediately on running pods, no restart needed
**Cons:** Password-based (less secure than keys), need to re-run after restart

### Option B: Manual Key Injection (Running Pods, One-Time)

If you have your SSH key handy and want key-based access to a **running pod**:

**Steps:**
1. Open your pod's **web terminal**
2. Run:
   ```bash
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```
3. SSH in using: `ssh root@<ip> -p <port> -i ~/.ssh/your_key`

**Pros:** Key-based authentication, no password
**Cons:** Lost on pod restart (unless you save to /workspace/.ssh/)

### Option C: Add Key to Runpod Account (Permanent, Requires Restart)

For **permanent** SSH access across all your pods:

**Steps:**
1. Go to [Runpod Console](https://console.runpod.io/) → Account Settings → SSH Keys
2. Paste your public key (from `~/.ssh/id_ed25519.pub`)
3. **Restart your pod** (or create a new one) - the key is injected on startup

**Pros:** Permanent, applies to all pods, auto-injected
**Cons:** Requires pod restart (data outside /workspace is lost)

### Option D: Set SSH_PUBLIC_KEY Env Var (Pod-Specific, Requires Restart)

To override the account-level key for a specific pod:

**Steps:**
1. Edit Pod → Environment Variables
2. Add: `SSH_PUBLIC_KEY=your_public_key_here`
3. **Restart the pod**

**Pros:** Pod-specific key override
**Cons:** Requires pod restart

---

## File Transfer Methods

### Method 1: SCP (Requires SSH Setup)

Once SSH is set up, use SCP from your local machine:

```bash
# Copy file TO pod
scp -P <port> yourfile.txt root@<pod-ip>:/workspace/

# Copy file FROM pod
scp -P <port> root@<pod-ip>:/workspace/yourfile.txt .

# Copy folder TO pod
scp -rP <port> yourfolder root@<pod-ip>:/workspace/
```

**Note:** SCP requires Direct TCP SSH (port 22 exposed), NOT proxy SSH.

### Method 2: runpodctl (No SSH Needed)

If SSH isn't working or you want something simpler, use `runpodctl`.

**Important:** runpodctl is only pre-installed on Runpod's official templates (like Runpod Pytorch). Custom templates may not have it.

```bash
# On your LOCAL machine, install runpodctl:
# See: https://docs.runpod.io/cli/install-runpodctl

# Send file to pod (local machine)
runpodctl send /path/to/file.txt
# Gives you a code like "abc123"

# Receive file on pod (in pod terminal)
runpodctl receive abc123
```

---

## Common Questions

### "How do I transfer files to my pod?"

SCP is recommended, but requires SSH to be set up first. Let me know:
- Is your pod already running?
- Do you have access to the web terminal?
- Is this a one-time transfer or do you need permanent access?

Based on your answers, I can guide you through the best option.

### "I can't SSH into my pod"

A few things to check:
1. **Is TCP port 22 exposed?** Check pod settings → if not, you can only use proxy SSH (no SCP)
2. **Is your SSH key registered?** Check account settings → SSH Keys
3. **Is the pod using an official template?** Custom templates may not have openssh installed

**Quick workaround:** If you have web terminal access, use the password script (Option A above).

### "How do I set up SSH keys?"

Two paths:
1. **Quick setup for running pod:** Use password script or manually add key (see Options A/B)
2. **Permanent setup:** Add key to Runpod account settings, then restart pod (see Option C)

Which would you prefer? Let me know your situation and I can give specific steps.

### "Proxy SSH vs Direct TCP SSH - what's the difference?"

- **Proxy SSH** (`ssh podId@ssh.runpod.io`): Works on all pods, but NO SCP/SFTP support. Good for shell access only.
- **Direct TCP SSH** (`ssh root@ip -p port`): Requires TCP port 22 exposed, but supports SCP/SFTP. Needed for file transfers.

---

## Important: Understanding /workspace

For official templates:
- `/workspace` is the **persistent storage directory**
- **Do NOT create /workspace** - it should already exist
- Data **outside /workspace is lost on pod restart**

If you can't find `/workspace`:
```bash
cd /
ls
# You should see workspace listed
cd /workspace
```

---

## Best Practices

1. **Always save data to /workspace** - survives pod restarts
2. **Use official templates when possible** - openssh and port 22 pre-configured
3. **For quick one-time access**, use the password script
4. **For permanent access**, add key to Runpod account settings
5. **runpodctl is a good fallback** if SSH isn't working (official templates only)

---

## This is a Complex Topic

SSH and file transfers on Runpod have multiple paths depending on your situation. If any of the above is unclear or you need more details on a specific option, just ask - I'm happy to dive deeper into any aspect.
