# Setting Up TinyMCE Environment Variable for Production

## How React Environment Variables Work

React apps use environment variables that are **baked into the build** at build time, not runtime. This means:

✅ **Set before build** → Works in production  
❌ **Set after build** → Won't work (already compiled)

---

## Solution 1: Create .env File (Recommended)

### Step 1: Create `.env` file in `client/` directory

```bash
cd client
nano .env
```

Add this content:
```env
REACT_APP_TINYMCE_API_KEY=umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7
```

### Step 2: Add to .gitignore (Important!)

Make sure `.env` is in `.gitignore` so you don't commit your API key:

```bash
# In client/.gitignore, add:
.env
.env.local
.env.production
```

### Step 3: Build with environment variable

The environment variable will be automatically loaded during build:

```bash
cd client
npm run build
```

---

## Solution 2: Set in Deployment Script (Already Updated)

I've already updated your `deploy_v2_full.sh` script to set the environment variable during build:

```bash
export REACT_APP_TINYMCE_API_KEY="umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7"
npm run build
```

This means **your deployment script will automatically use the API key** when building.

---

## Solution 3: Set Before Build Command

You can also set it directly before building:

```bash
cd client
REACT_APP_TINYMCE_API_KEY=umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7 npm run build
```

---

## Why This Will Work

1. **Environment variable is set BEFORE build**
   - React reads `REACT_APP_*` variables during `npm run build`
   - They get compiled into the JavaScript bundle

2. **Your code already checks for it:**
   ```javascript
   const TINYMCE_API_KEY = process.env.REACT_APP_TINYMCE_API_KEY || 'umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7';
   ```
   - If env var is set → uses it
   - If not set → uses fallback key

3. **Deployment script now sets it:**
   - The script exports the variable before building
   - So it will be available during build

---

## Testing

### Test Locally

1. **Create `.env` file:**
   ```bash
   cd client
   echo "REACT_APP_TINYMCE_API_KEY=umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7" > .env
   ```

2. **Start dev server:**
   ```bash
   npm start
   ```

3. **Check if it works:**
   - Go to admin panel
   - Try editing content
   - Editor should load

### Test in Production

1. **Run deployment script:**
   ```bash
   bash deploy_v2_full.sh
   ```
   The script now sets the env var before building.

2. **Verify in production:**
   - Visit your live site
   - Go to admin panel
   - Try editing content
   - Editor should work

---

## Important Notes

### ⚠️ Security

- **Don't commit `.env` to Git** - it contains your API key
- Add `.env` to `.gitignore`
- The API key in the code is a fallback, but using env var is better

### ⚠️ Build Time vs Runtime

- **Build time:** When you run `npm run build` (env vars are read here)
- **Runtime:** When users visit your site (env vars already compiled in)

You **cannot** change env vars after build - they're baked into the JavaScript.

### ⚠️ Naming Convention

React only reads environment variables that start with `REACT_APP_`:
- ✅ `REACT_APP_TINYMCE_API_KEY` - Works
- ❌ `TINYMCE_API_KEY` - Won't work (missing REACT_APP_ prefix)

---

## Current Status

✅ **Your deployment script is updated** - it sets the env var before building  
✅ **Your code checks for env var** - with fallback to hardcoded key  
✅ **You can create .env file** - for local development  

**Next step:** Run your deployment script and it should work!

---

## Troubleshooting

### Issue: Editor still not working in production

**Check:**
1. Is the env var set before build? (Check deployment script)
2. Are you rebuilding after changes? (Old build won't have new env vars)
3. Check browser console for errors
4. Verify API key is correct

### Issue: Works locally but not in production

**Solution:**
- Make sure deployment script sets the env var
- Rebuild and redeploy
- Clear browser cache

### Issue: API key errors

**Solution:**
- Verify API key is correct
- Check if your TinyMCE account has access to premium plugins
- Some plugins require paid subscription

---

## Summary

**Yes, using environment variable will work!** 

The deployment script is already updated to set it. Just:
1. Run `bash deploy_v2_full.sh`
2. The script will set the env var before building
3. TinyMCE should work in production

Optionally, create a `.env` file for local development convenience.

