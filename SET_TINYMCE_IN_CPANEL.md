# Setting TinyMCE API Key in cPanel

## Important Clarification

**TinyMCE API key is for the FRONTEND (React app), not the backend!**

- **Frontend (React):** Environment variables are set **during build time** (when you run `npm run build`)
- **Backend (Node.js):** Environment variables are set in **cPanel Node.js app settings**

Since TinyMCE is used in the frontend, you **don't need to set it in cPanel** - it's already handled by your deployment script.

---

## Option 1: Use Deployment Script (Already Done ✅)

Your `deploy_v2_full.sh` script already sets the TinyMCE API key during build:

```bash
export REACT_APP_TINYMCE_API_KEY="umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7"
npm run build
```

**This is the correct way** - no cPanel configuration needed!

---

## Option 2: Create .env File (For Local Development)

If you want to set it locally for development:

### Step 1: Create `.env` file in `client/` directory

```bash
cd client
nano .env
```

### Step 2: Add the API key

```env
REACT_APP_TINYMCE_API_KEY=umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7
```

### Step 3: Add to .gitignore

Make sure `.env` is in `.gitignore`:

```bash
# In client/.gitignore
.env
.env.local
.env.production
```

### Step 4: Build

The `.env` file will be automatically loaded during build:

```bash
npm run build
```

---

## Option 3: Set in cPanel Build Process (Advanced)

If you want to set it in cPanel's build process (not recommended, but possible):

### Step 1: Login to cPanel

Go to: `https://theonerupeerevolution.org:2083`

### Step 2: Open Terminal

- Find **"Advanced"** section
- Click **"Terminal"**

### Step 3: Navigate to client directory

```bash
cd ~/public_html
# Or wherever your frontend build is located
```

### Step 4: Set environment variable and build

```bash
export REACT_APP_TINYMCE_API_KEY="umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7"
cd ~/path/to/your/project/client
npm run build
```

**Note:** This is not recommended because:
- Frontend should be built locally or in CI/CD
- cPanel is for hosting, not building
- Your deployment script already handles this

---

## Why You Don't Need cPanel for Frontend Env Vars

### Frontend (React) Environment Variables:
- ✅ Set **during build** (`npm run build`)
- ✅ Compiled into JavaScript bundle
- ✅ Already handled by your deployment script
- ❌ **Cannot** be changed after build (already compiled)

### Backend (Node.js) Environment Variables:
- ✅ Set in **cPanel Node.js app settings**
- ✅ Can be changed anytime
- ✅ Used at runtime
- ✅ Already configured (DB_HOST, DB_USER, etc.)

---

## Current Setup (What You Have)

### ✅ Frontend - Already Configured

Your `deploy_v2_full.sh` script sets the TinyMCE API key:

```bash
# Line 60 in deploy_v2_full.sh
export REACT_APP_TINYMCE_API_KEY="umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7"
npm run build
```

**This means:** Every time you run the deployment script, the API key is automatically set during build.

### ✅ Backend - Already Configured

Your backend environment variables are set in:
- **cPanel** → **Setup Node.js App** → **Your App** → **Environment Variables**

You already have:
- `DB_HOST`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `JWT_SECRET`
- `NODE_ENV`
- `PORT`

---

## What You Should Do

### For TinyMCE (Frontend):

**Nothing!** It's already configured in your deployment script. Just:

1. Run your deployment script:
   ```bash
   bash deploy_v2_full.sh
   ```

2. The script will:
   - Set `REACT_APP_TINYMCE_API_KEY` before building
   - Build the React app with the API key
   - Deploy to cPanel

3. TinyMCE will work in production! ✅

### For Backend (If Needed):

If you need to add more backend environment variables:

1. **Login to cPanel** → **Setup Node.js App**
2. **Click on your application**
3. **Scroll to "Environment Variables"**
4. **Click "Add Variable"**
5. **Enter Name and Value**
6. **Click "Save"**
7. **Restart your app**

---

## Summary

**Question:** How to set TinyMCE API key in cPanel?

**Answer:** You **don't need to** - it's already set in your deployment script!

The deployment script (`deploy_v2_full.sh`) automatically sets the environment variable before building, so TinyMCE will work in production.

**Just run your deployment script and it will work!** ✅

---

## Troubleshooting

### Issue: TinyMCE still not working in production

**Check:**
1. Did you rebuild after updating the script? (Old build won't have the env var)
2. Check browser console for errors
3. Verify the API key is correct
4. Make sure you're using the updated deployment script

### Issue: Want to change the API key

**Solution:**
1. Update the API key in `deploy_v2_full.sh` (line 60)
2. Or create `client/.env` file with the new key
3. Rebuild and redeploy

---

## Quick Reference

| Component | Where to Set | How |
|-----------|-------------|-----|
| **Frontend Env Vars** | During build | Deployment script or `.env` file |
| **Backend Env Vars** | cPanel | Setup Node.js App → Environment Variables |
| **TinyMCE API Key** | During build | Already in `deploy_v2_full.sh` ✅ |

**Bottom line:** Your setup is already correct! Just run the deployment script. 🚀

