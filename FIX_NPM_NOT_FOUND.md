# Fix: npm command not found in cPanel

## Problem
When running `npm install --production` in cPanel Terminal, you get:
```
npm: command not found
```

## Solution: Find npm in cPanel

### Method 1: Use cPanel Node.js App Settings (Easiest)

1. **Go to cPanel** → **Setup Node.js App**
2. **Click on your application**
3. **Look for "NPM Install" or "Install Dependencies" button**
4. **Click it** - cPanel will install dependencies automatically

This is the easiest method if available in your cPanel.

---

### Method 2: Find npm Path Manually

In cPanel Terminal, try to find npm:

```bash
# Try to find npm
which npm
whereis npm

# Check common cPanel Node.js paths
ls -la /opt/cpanel/ea-nodejs*/bin/npm
ls -la /usr/bin/npm
ls -la ~/bin/npm
```

Once you find npm, use the full path:

```bash
# Example if npm is at /opt/cpanel/ea-nodejs18/bin/npm
/opt/cpanel/ea-nodejs18/bin/npm install --production

# Or if it's at /opt/cpanel/ea-nodejs20/bin/npm
/opt/cpanel/ea-nodejs20/bin/npm install --production
```

---

### Method 3: Use Node.js Version Manager

cPanel might use a Node.js version manager. Try:

```bash
# Check if nvm is available
source ~/.nvm/nvm.sh
nvm use default
npm install --production

# Or check for n
which n
```

---

### Method 4: Check Your Node.js App Settings

1. **Go to cPanel** → **Setup Node.js App**
2. **Click on your application**
3. **Check "Node.js Version"** - note the version (e.g., 18.20.0)
4. **Use the corresponding npm path**:
   - Node.js 18 → `/opt/cpanel/ea-nodejs18/bin/npm`
   - Node.js 20 → `/opt/cpanel/ea-nodejs20/bin/npm`
   - Node.js 16 → `/opt/cpanel/ea-nodejs16/bin/npm`

---

### Method 5: Add npm to PATH (Temporary)

In cPanel Terminal:

```bash
# Find your Node.js version in cPanel app settings
# Then add to PATH (replace 18 with your version)
export PATH="/opt/cpanel/ea-nodejs18/bin:$PATH"

# Verify npm is now available
which npm
npm --version

# Now install dependencies
cd ~/nodejs
npm install --production
```

**Note:** This is temporary - you'll need to do this each time you open a new terminal session.

---

### Method 6: Create Alias (Permanent)

Add to your `~/.bashrc` or `~/.bash_profile`:

```bash
# Edit bashrc
nano ~/.bashrc

# Add this line (replace 18 with your Node.js version)
alias npm='/opt/cpanel/ea-nodejs18/bin/npm'
alias node='/opt/cpanel/ea-nodejs18/bin/node'

# Save and exit (Ctrl+X, then Y, then Enter)

# Reload bashrc
source ~/.bashrc

# Now npm should work
npm --version
```

---

## Quick Test Script

Run this in cPanel Terminal to find npm:

```bash
echo "Searching for npm..."
echo ""

# Check common locations
for path in /opt/cpanel/ea-nodejs18/bin/npm /opt/cpanel/ea-nodejs20/bin/npm /opt/cpanel/ea-nodejs16/bin/npm /usr/bin/npm ~/bin/npm; do
  if [ -f "$path" ]; then
    echo "✅ Found npm at: $path"
    echo "   Version: $($path --version)"
    echo ""
    echo "Use this command to install dependencies:"
    echo "   $path install --production"
    echo ""
  fi
done

# If nothing found, check what Node.js versions are installed
echo "Checking installed Node.js versions:"
ls -la /opt/cpanel/ea-nodejs*/bin/node 2>/dev/null || echo "No Node.js found in /opt/cpanel/"
```

---

## Alternative: Install Dependencies Locally and Upload

If npm still doesn't work, you can:

1. **Install dependencies locally** (on your computer):
   ```bash
   cd /mnt/e/kanishk\ data/projects/UNICRO
   npm install --production
   ```

2. **Upload node_modules folder** to cPanel:
   ```bash
   # Using rsync (from your deployment script)
   rsync -avz \
     --exclude='.git/' \
     -e "ssh -i ~/.ssh/key_private -p 21098" \
     node_modules/ theomkiq@server357.web-hosting.com:~/nodejs/node_modules/
   ```

**⚠️ Warning:** This might be slow and upload large files. Only use if other methods fail.

---

## Recommended Solution

**Best approach:** Use Method 1 (cPanel Node.js App Settings) if available, or Method 2 (find npm path manually).

Most likely, npm is at:
- `/opt/cpanel/ea-nodejs18/bin/npm` (for Node.js 18)
- `/opt/cpanel/ea-nodejs20/bin/npm` (for Node.js 20)

Try these paths first!

---

## After Finding npm

Once you find npm, install dependencies:

```bash
cd ~/nodejs

# Use the full path to npm (replace with your actual path)
/opt/cpanel/ea-nodejs18/bin/npm install --production

# Or if you added to PATH
npm install --production
```

You should see:
```
added X packages
```

Then restart your Node.js app in cPanel.

