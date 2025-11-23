# .htaccess Setup Guide - Complete Reference

## Overview

Your website uses **TWO** `.htaccess` files with different purposes:

1. **`~/public_html/api/.htaccess`** - For Node.js/Passenger (API)
2. **`~/public_html/.htaccess`** - For React Router (Frontend)

These files should **NEVER** conflict if set up correctly.

---

## File 1: `~/public_html/api/.htaccess`

**Purpose:** Routes `/api/*` requests to Node.js app via Passenger

**Location:** `~/public_html/api/.htaccess`

**Content:**
```apache
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION BEGIN
PassengerAppRoot "/home/theomkiq/nodejs"
PassengerBaseURI "/api"
PassengerNodejs "/home/theomkiq/nodevenv/nodejs/14/bin/node"
PassengerAppType node
PassengerStartupFile server.js
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION END
```

**Important:**
- ✅ Should have ONLY ONE Passenger config (CloudLinux managed)
- ❌ Should NOT have React Router rewrite rules
- ❌ Should NOT have duplicate Passenger configs

**When to update:**
- Only if cPanel changes the Passenger configuration
- Never manually edit unless you know what you're doing

---

## File 2: `~/public_html/.htaccess`

**Purpose:** Routes all other requests to React app (React Router)

**Location:** `~/public_html/.htaccess`

**Content:**
```apache
# React Router - Handle client-side routing
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  
  # Don't rewrite files or directories that exist
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  
  # Don't rewrite /api requests (handled by Passenger)
  RewriteCond %{REQUEST_URI} !^/api
  
  # Don't rewrite /uploads (static files)
  RewriteCond %{REQUEST_URI} !^/uploads
  
  # Send everything else to index.html for React Router
  RewriteRule . /index.html [L]
</IfModule>
```

**Important:**
- ✅ Should have ONLY React Router rewrite rules
- ❌ Should NOT have Passenger config
- ❌ Should NOT rewrite `/api/*` requests

**When to update:**
- Only if React Router routing changes
- When adding new static file paths to exclude

---

## How They Work Together

### Request Flow:

1. **`/api/settings`** request:
   - Apache checks `~/public_html/api/.htaccess`
   - Passenger routes to Node.js app
   - Node.js handles the request

2. **`/admin`** request:
   - Apache checks `~/public_html/.htaccess`
   - Rewrite rule sends to `index.html`
   - React Router handles the route

3. **`/donate`** request:
   - Same as `/admin` - React Router handles it

---

## Common Issues & Fixes

### Issue 1: Duplicate Passenger Configs
**Symptom:** 508 Loop Detected error

**Cause:** Multiple `PassengerAppRoot` entries in `~/public_html/api/.htaccess`

**Fix:** Run `bash fix_all_htaccess_comprehensive.sh`

---

### Issue 2: Admin Route 404
**Symptom:** `/admin` shows 404 Not Found

**Cause:** Missing or incorrect `~/public_html/.htaccess`

**Fix:** Run `bash fix_all_htaccess_comprehensive.sh`

---

### Issue 3: API Not Working
**Symptom:** `/api/settings` returns 502/508 error

**Cause:** Missing or incorrect `~/public_html/api/.htaccess`

**Fix:** Run `bash fix_all_htaccess_comprehensive.sh`

---

### Issue 4: Both Routes Broken
**Symptom:** Both API and frontend routes fail

**Cause:** Conflicting rewrite rules or missing files

**Fix:** Run `bash fix_all_htaccess_comprehensive.sh`

---

## One-Time Setup Script

**Run this to set up both files correctly:**

```bash
bash fix_all_htaccess_comprehensive.sh
```

This script:
- ✅ Backs up existing files
- ✅ Creates correct `~/public_html/api/.htaccess` (Passenger only)
- ✅ Creates correct `~/public_html/.htaccess` (React Router only)
- ✅ Verifies no conflicts
- ✅ Prevents future issues

---

## Best Practices

1. **Never manually edit** `.htaccess` files unless you understand Apache/Passenger
2. **Always backup** before making changes
3. **Use the fix script** if something breaks
4. **Don't add duplicate configs** - one Passenger config is enough
5. **Keep them separate** - API `.htaccess` for API, frontend `.htaccess` for frontend

---

## Verification

After running the fix script, verify:

```bash
# Check API .htaccess
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cat ~/public_html/api/.htaccess

# Check Frontend .htaccess
cat ~/public_html/.htaccess
```

**Expected:**
- API `.htaccess`: Only Passenger config (5-6 lines)
- Frontend `.htaccess`: Only React Router rewrite rules (10-15 lines)
- No duplicates
- No conflicts

---

## Summary

- **Two files, two purposes** - keep them separate
- **API .htaccess** = Passenger config only
- **Frontend .htaccess** = React Router only
- **Run fix script** if anything breaks
- **Don't manually edit** unless you know what you're doing

