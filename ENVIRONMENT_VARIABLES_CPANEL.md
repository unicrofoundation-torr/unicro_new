# Environment Variables for cPanel Node.js App

## How to Add Environment Variables in cPanel

1. **Login to cPanel** → **Setup Node.js App**
2. **Click on your application** to edit settings
3. **Scroll to "Environment Variables"** section
4. **Click "Add Variable"** for each variable below
5. **Enter Name and Value** as shown below
6. **Click "Save"** after adding all variables

---

## Required Environment Variables

### 1. Database Configuration

| **Name** | **Value** | **Description** |
|----------|-----------|-----------------|
| `DB_HOST` | `localhost` | Database host (usually localhost on cPanel) |
| `DB_USER` | `theomkiq_charity` | Your cPanel database username |
| `DB_PASSWORD` | `Unicro@001` | Your cPanel database password |
| `DB_NAME` | `theomkiq_charity_website` | Your cPanel database name |

**⚠️ Important:** Replace the values above with your actual database credentials from cPanel → MySQL Databases

---

### 2. Server Configuration

| **Name** | **Value** | **Description** |
|----------|-----------|-----------------|
| `NODE_ENV` | `production` | Environment mode (must be "production") |
| `PORT` | `5000` | Server port (cPanel may auto-assign this) |

**Note:** `PORT` might be automatically set by cPanel. Check your Node.js app settings - if it shows a different port, use that instead.

---

### 3. Security (JWT Secret)

| **Name** | **Value** | **Description** |
|----------|-----------|-----------------|
| `JWT_SECRET` | `your-secret-key-here` | Secret key for JWT tokens (see below) |

**⚠️ Important:** Generate a secure random string for JWT_SECRET:

**Option 1: Using Node.js (in Terminal)**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**Option 2: Using OpenSSL (in Terminal)**
```bash
openssl rand -hex 32
```

**Option 3: Online Generator**
- Visit: https://randomkeygen.com/
- Use a "CodeIgniter Encryption Keys" (256-bit)
- Copy the generated key

**Example JWT_SECRET value:**
```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
```

**⚠️ Security Warning:** 
- Use a long, random string (at least 32 characters)
- Never share this secret
- Keep it secure

---

### 4. Cashfree Payment Gateway (Optional - Only if using donations)

| **Name** | **Value** | **Description** |
|----------|-----------|-----------------|
| `CASHFREE_ENV` | `PROD` or `TEST` | Cashfree environment (PROD for production, TEST for testing) |
| `CASHFREE_APP_ID` | `your-app-id` | Your Cashfree App ID |
| `CASHFREE_SECRET_KEY` | `your-secret-key` | Your Cashfree Secret Key |
| `CASHFREE_RETURN_URL` | `https://theonerupeerevolution.org/donate?cf_return=1&order_id={order_id}` | Return URL after payment |
| `CASHFREE_NOTIFY_URL` | `https://theonerupeerevolution.org/api/donations/cf/webhook` | Webhook URL for payment notifications |
| `CASHFREE_WEBHOOK_SECRET` | `your-webhook-secret` | Webhook secret for Cashfree |

**Note:** Only add these if you're using Cashfree payment gateway. If not, you can skip these.

---

## Complete List (Copy-Paste Format)

Here's the complete list in a format you can easily copy:

```
NODE_ENV=production
PORT=5000
DB_HOST=localhost
DB_USER=theomkiq_charity
DB_PASSWORD=Unicro@001
DB_NAME=theomkiq_charity_website
JWT_SECRET=your-secret-key-here
```

**⚠️ Remember to:**
1. Replace `DB_USER`, `DB_PASSWORD`, `DB_NAME` with your actual database credentials
2. Replace `JWT_SECRET` with a secure random string
3. Replace `PORT` if cPanel assigns a different port

---

## Step-by-Step: Adding Variables in cPanel

1. **Login to cPanel**
   - Go to: `https://theonerupeerevolution.org:2083`

2. **Open Node.js App Settings**
   - Find **"Software"** section
   - Click **"Setup Node.js App"**
   - Click on your application name

3. **Add Environment Variables**
   - Scroll down to **"Environment Variables"** section
   - For each variable:
     - Click **"Add Variable"** or **"+"** button
     - Enter **Name** (e.g., `DB_HOST`)
     - Enter **Value** (e.g., `localhost`)
     - Click **"Save"** or **"Add"**

4. **Save Application**
   - After adding all variables, click **"Save"** or **"Update"** button at the bottom

5. **Restart Application**
   - Click **"Restart App"** button
   - Wait for app to restart

---

## Verification

After adding environment variables:

1. **Check Application Logs**
   - In cPanel → Setup Node.js App → View Logs
   - Should show: `✅ Database connection successful`
   - Should show: `🚀 Server is running on port 5000`

2. **Test API Endpoint**
   - Visit: `https://theonerupeerevolution.org/api/settings`
   - Should return JSON data (not error)

3. **Check for Errors**
   - If you see database connection errors, verify:
     - `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` are correct
     - Database user has permissions
     - Database exists

---

## Common Issues

### Issue 1: Database Connection Failed

**Error:** `❌ Database connection failed`

**Solution:**
- Verify `DB_HOST` is `localhost`
- Verify `DB_USER`, `DB_PASSWORD`, `DB_NAME` match your cPanel MySQL database
- Check database user has permissions in cPanel → MySQL Databases

### Issue 2: JWT Token Errors

**Error:** `Invalid or expired token`

**Solution:**
- Verify `JWT_SECRET` is set and is a long random string
- Make sure `JWT_SECRET` is the same if you have multiple environments

### Issue 3: Port Already in Use

**Error:** `Port 5000 is already in use`

**Solution:**
- Check what port cPanel assigned to your app
- Update `PORT` environment variable to match
- Or remove `PORT` variable and let cPanel auto-assign

---

## Quick Reference

### Minimum Required Variables (Must Have)
```
NODE_ENV=production
DB_HOST=localhost
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=your_db_name
JWT_SECRET=your_random_secret_key
```

### Optional Variables (Only if needed)
```
PORT=5000
CASHFREE_ENV=PROD
CASHFREE_APP_ID=your_app_id
CASHFREE_SECRET_KEY=your_secret_key
CASHFREE_RETURN_URL=https://theonerupeerevolution.org/donate?cf_return=1&order_id={order_id}
CASHFREE_NOTIFY_URL=https://theonerupeerevolution.org/api/donations/cf/webhook
CASHFREE_WEBHOOK_SECRET=your_webhook_secret
```

---

## Need Help?

If you're not sure about any values:
1. **Database credentials**: Check cPanel → MySQL Databases
2. **Port**: Check cPanel → Setup Node.js App → Your app settings
3. **JWT_SECRET**: Generate using the commands above
4. **Cashfree**: Check your Cashfree dashboard

