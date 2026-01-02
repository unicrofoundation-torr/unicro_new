# Fix SSH Key Permissions on Windows

## The Problem

When using SSH from WSL or Git Bash on Windows, you get:

```
WARNING: UNPROTECTED PRIVATE KEY FILE!
Permissions 0777 for '/mnt/c/Users/.../key_private' are too open.
```

## Why This Happens

- Windows file systems (NTFS) don't fully support Linux-style permissions
- Files on `/mnt/c/` (Windows drives mounted in WSL) have different permission handling
- SSH requires strict permissions (600) for security

## Solution: Copy Key to WSL Filesystem

The best solution is to copy your key to your WSL home directory where Linux permissions work properly.

### Step 1: Copy Key to WSL Home Directory

```bash
# In WSL or Git Bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cp /mnt/c/Users/KanishkRajSinghDodiy/Downloads/key_private ~/.ssh/key_private
chmod 600 ~/.ssh/key_private
```

### Step 2: Verify Permissions

```bash
ls -la ~/.ssh/key_private
# Should show: -rw------- (600 permissions)
```

### Step 3: Test SSH Connection

```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
```

### Step 4: Update deploy_full.sh

Change line 27 in `deploy_full.sh`:

```bash
# OLD (Windows path - causes permission issues):
PRIVATE_KEY="/mnt/c/Users/KanishkRajSinghDodiy/Downloads/key_private"

# NEW (WSL home path - works correctly):
PRIVATE_KEY="$HOME/.ssh/key_private"
```

## Alternative: Use Windows icacls (Less Reliable)

If you must use the Windows path, try:

```powershell
# In PowerShell (as Administrator)
icacls "C:\Users\KanishkRajSinghDodiy\Downloads\key_private" /inheritance:r
icacls "C:\Users\KanishkRajSinghDodiy\Downloads\key_private" /grant:r "$env:USERNAME:(R)"
```

But this may still not work with WSL/Git Bash SSH.

## Quick Fix Script

Run this in WSL or Git Bash:

```bash
#!/bin/bash
# Fix SSH key permissions

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy key from Windows Downloads to WSL home
if [ -f "/mnt/c/Users/KanishkRajSinghDodiy/Downloads/key_private" ]; then
    cp /mnt/c/Users/KanishkRajSinghDodiy/Downloads/key_private ~/.ssh/key_private
    chmod 600 ~/.ssh/key_private
    echo "✅ Key copied to ~/.ssh/key_private with correct permissions"
    echo "✅ You can now use: ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com"
else
    echo "❌ Key file not found at: /mnt/c/Users/KanishkRajSinghDodiy/Downloads/key_private"
    echo "Please check the path"
fi
```

## Update deploy_full.sh

After copying the key, update your deployment script:

```bash
# Line 27 - Change from:
PRIVATE_KEY="/mnt/c/Users/KanishkRajSinghDodiy/Downloads/key_private"

# To:
PRIVATE_KEY="$HOME/.ssh/key_private"
```

This will:
- ✅ Work in WSL, Git Bash, and Linux
- ✅ Have proper permissions
- ✅ Be more secure
- ✅ Follow standard SSH conventions

## Verify It Works

```bash
# Test SSH connection
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com

# Should connect without password prompt
```

## Why This Works

1. **WSL filesystem** (`~/.ssh/`) supports proper Linux permissions
2. **Standard location** - SSH automatically looks in `~/.ssh/`
3. **Secure** - 600 permissions (read/write for owner only)
4. **Portable** - Works across different environments

## Summary

**Problem:** Windows file permissions don't work with SSH in WSL/Git Bash

**Solution:** Copy key to `~/.ssh/key_private` in WSL and set permissions to 600

**Command:**
```bash
cp /mnt/c/Users/KanishkRajSinghDodiy/Downloads/key_private ~/.ssh/key_private && chmod 600 ~/.ssh/key_private
```

