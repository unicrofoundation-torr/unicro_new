# How to Fix Database Deployment Issue

## Problem
The deployment script failed with:
```
ERROR 1044 (42000): Access denied for user 'theomkiq_charity'@'localhost' to database 'theomkiq_charity_website'
```

## Solution: Find Correct Database Credentials

### Step 1: Login to cPanel
1. Go to: `https://theonerupeerevolution.org:2083`
2. Login with your cPanel credentials

### Step 2: Check MySQL Databases
1. In cPanel, find **"Databases"** section
2. Click on **"MySQL Databases"**

### Step 3: Find Your Database Information
You'll see:
- **Current Databases**: List of all databases (usually prefixed with your username)
- **Database Users**: List of all database users
- **Add User To Database**: Section to assign users to databases

**Look for:**
- Database name (e.g., `theomkiq_charity_website` or `theomkiq_unicro`)
- Database user (e.g., `theomkiq_charity` or `theomkiq_unicro`)
- Make sure the user is assigned to the database!

### Step 4: Update deploy_v2_full.sh
Update these lines in `deploy_v2_full.sh`:

```bash
REMOTE_DB_USER="your_actual_db_user"      # From cPanel MySQL Databases
REMOTE_DB_PASS="your_actual_db_password"  # Your database password
REMOTE_DB_NAME="your_actual_db_name"      # From cPanel MySQL Databases
```

### Step 5: Manual SQL Import (Recommended)
Since automated import failed, import manually:

1. **Login to phpMyAdmin**
   - In cPanel, click **"phpMyAdmin"** (under Databases section)

2. **Select Your Database**
   - In left sidebar, click on your database name
   - Make sure it's the correct one!

3. **Import SQL File**
   - Click **"Import"** tab at the top
   - Click **"Choose File"** button
   - Select: `database/schema.sql` from your project
   - Click **"Go"** button at bottom
   - Wait for import to complete

4. **Verify Import**
   - Check if tables were created:
     - `pages`
     - `navigation_links`
     - `site_settings`
     - `slider_images`
     - `footer_settings`
     - `our_work`
     - `gallery`
     - `blogs`
     - `admin_users`
     - etc.

## Alternative: Create Database User with Full Permissions

If the user doesn't have permissions:

1. In cPanel → MySQL Databases
2. Scroll to **"Add User To Database"**
3. Select your database user
4. Select your database
5. Click **"Add"**
6. Make sure **"ALL PRIVILEGES"** is checked
7. Click **"Make Changes"**

## Common Issues

### Issue 1: Database name format
- cPanel usually prefixes: `username_dbname`
- Example: `theomkiq_charity_website` (not just `charity_website`)

### Issue 2: User not assigned to database
- User must be assigned to database in cPanel
- Go to "Add User To Database" section

### Issue 3: Wrong password
- Reset password in cPanel → MySQL Databases
- Update `REMOTE_DB_PASS` in script

## After Fixing

1. **Update deploy_v2_full.sh** with correct credentials
2. **Run deployment again** OR
3. **Import SQL manually via phpMyAdmin** (easier and more reliable)

