# Next Steps Checklist - After Creating Node.js App in cPanel

## ✅ What You've Done
- [x] Created Node.js application in cPanel
- [x] Added environment variables (NODE_ENV, DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, JWT_SECRET)

## 📋 What to Do Next

### Step 1: Install Dependencies
- [ ] Open cPanel → Terminal
- [ ] Run: `cd ~/nodejs && npm install --production`
- [ ] Wait for installation to complete
- [ ] Should see: `added X packages` message

### Step 2: Verify Backend Files
- [ ] Check if files are in `~/nodejs`:
  - [ ] `server.js` exists
  - [ ] `package.json` exists
  - [ ] `config/` folder exists
  - [ ] `routes/` folder exists
- [ ] If files missing, run: `bash deploy_v2_full.sh`

### Step 3: Start/Restart App
- [ ] Go to cPanel → Setup Node.js App
- [ ] Click on your application
- [ ] Click "Restart App" button
- [ ] Status should show "Running" or "Active"

### Step 4: Check Logs
- [ ] View application logs in cPanel
- [ ] Should see: `✅ Database connection successful`
- [ ] Should see: `🚀 Server is running on port 5000`
- [ ] If errors, note them down

### Step 5: Test Backend API
- [ ] Visit: `https://theonerupeerevolution.org/api/settings`
- [ ] Should return JSON data (not 404 or 500 error)
- [ ] Test: `https://theonerupeerevolution.org/api/navigation`
- [ ] Should return JSON data

### Step 6: Verify Frontend
- [ ] Visit: `https://theonerupeerevolution.org`
- [ ] Open browser console (F12)
- [ ] Check for errors
- [ ] Navigation should load
- [ ] Footer should load
- [ ] No API errors in console

### Step 7: Import Database (If Not Done)
- [ ] Login to cPanel → phpMyAdmin
- [ ] Select your database
- [ ] Click "Import" tab
- [ ] Upload `database/schema.sql`
- [ ] Click "Go"
- [ ] Verify tables are created

## 🐛 Common Issues

### Issue: npm install fails
**Solution:**
- Check if npm is available: `which npm`
- Try: `/opt/cpanel/ea-nodejs18/bin/npm install --production`
- Or use cPanel Node.js app settings to install

### Issue: App won't start
**Solution:**
- Check logs for errors
- Verify environment variables are set correctly
- Check if `server.js` exists in app directory
- Verify database credentials are correct

### Issue: Database connection failed
**Solution:**
- Verify DB_HOST, DB_USER, DB_PASSWORD, DB_NAME are correct
- Check database user has permissions in cPanel → MySQL Databases
- Test database connection manually

### Issue: API returns 404
**Solution:**
- Check application URL in cPanel Node.js settings
- Verify app is running (status should be "Running")
- Check if routes are configured correctly in server.js

### Issue: API returns 500
**Solution:**
- Check application logs for errors
- Verify database connection
- Check environment variables
- Verify all dependencies are installed

## ✅ Success Indicators

You'll know everything is working when:
- ✅ App status shows "Running" in cPanel
- ✅ Logs show "Database connection successful"
- ✅ `https://theonerupeerevolution.org/api/settings` returns JSON
- ✅ Frontend loads without console errors
- ✅ Navigation and footer display correctly

## 📞 Need Help?

If you encounter issues:
1. Check application logs in cPanel
2. Verify all environment variables are set
3. Test database connection separately
4. Check if all files are uploaded correctly

