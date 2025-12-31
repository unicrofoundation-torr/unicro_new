# Troubleshooting 404 Errors on Sync Endpoints

## Issue
Getting 404 errors when trying to use:
- Sync with Razorpay
- Verify & Cleanup

## Possible Causes

### 1. Server Not Restarted After Deployment
**Most Common Issue!**

After deploying the updated `routes/donations.js` file, you MUST restart the Node.js app:

1. Go to **cPanel → Setup Node.js App**
2. Find your app
3. Click **"Restart App"** button
4. Wait for it to restart (usually 10-30 seconds)

### 2. Routes File Not Deployed
Check if the file was actually uploaded:

1. Go to **cPanel → File Manager**
2. Navigate to `~/nodejs/routes/`
3. Open `donations.js`
4. Search for `sync-razorpay` - it should be around line 675
5. If not found, the file wasn't deployed correctly

### 3. Test the Routes
Try accessing this test endpoint in your browser (while logged into admin):
```
https://theonerupeerevolution.org/api/donations/admin/test-routes
```

If this returns JSON, routes are loaded. If 404, routes aren't loaded.

### 4. Check Server Logs
Check for errors in cPanel:
- **cPanel → Setup Node.js App → Your App → View Logs**

Look for:
- Syntax errors in `donations.js`
- Module loading errors
- Route registration errors

## Quick Fix Steps

1. **Verify File is Deployed:**
   ```bash
   # Check if file exists on server
   ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com "ls -la ~/nodejs/routes/donations.js"
   ```

2. **Check File Content:**
   ```bash
   # Verify sync routes exist
   ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com "grep 'sync-razorpay' ~/nodejs/routes/donations.js"
   ```

3. **Restart Node.js App:**
   - cPanel → Setup Node.js App → Restart App

4. **Test Endpoint:**
   - Visit: `https://theonerupeerevolution.org/api/donations/admin/test-routes`
   - Should return JSON with available endpoints

5. **Clear Browser Cache:**
   - Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)

## If Still Not Working

1. **Check Route Registration:**
   - Verify `server.js` has: `app.use('/api/donations', require('./routes/donations'));`

2. **Check Authentication:**
   - Make sure you're logged into admin panel
   - Token should be in localStorage: `localStorage.getItem('adminToken')`

3. **Manual Route Test:**
   ```bash
   # Test from server directly
   curl -X POST https://theonerupeerevolution.org/api/donations/admin/sync-all \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json"
   ```

## Expected Behavior

After proper deployment and restart:
- ✅ Test endpoint should return: `{"success":true,"message":"Routes are loaded!"}`
- ✅ Sync buttons should work without 404 errors
- ✅ Console should show successful API calls

