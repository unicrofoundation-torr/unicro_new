# 🔍 Check Database Name Mismatch

## Problem

Your environment variable shows:
```
DB_NAME=theomkiq_charity
```

But deployment script expects:
```
DB_NAME=theomkiq_charity_website
```

This mismatch causes database connection to fail → app crashes → 508 error.

---

## Quick Fix

### Step 1: Check Actual Database Name

1. **Go to cPanel → MySQL Databases**
2. **Look at your databases list**
3. **Which one exists?**
   - `theomkiq_charity`?
   - `theomkiq_charity_website`?
   - Something else?

### Step 2: Update Environment Variable

**If database is `theomkiq_charity`:**
- Keep `DB_NAME=theomkiq_charity` (it's already correct)

**If database is `theomkiq_charity_website`:**
1. **Go to cPanel → Setup Node.js App → Your App → Environment Variables**
2. **Find `DB_NAME`**
3. **Change to:** `theomkiq_charity_website`
4. **Save**

### Step 3: Test Database Connection

**Via phpMyAdmin:**
1. **Go to cPanel → phpMyAdmin**
2. **Select the database** (whichever name is correct)
3. **Run:** `SELECT 1;`
4. **Does it work?**
   - ✅ Works = Database is fine
   - ❌ Error = Database issue

---

## After Fixing

1. **Restart app** in cPanel
2. **Test:** `https://theonerupeerevolution.org/api/settings`
3. **Should work now!**

---

**Most likely:** Database name mismatch is causing the crash. Check which database actually exists and update the environment variable to match!

