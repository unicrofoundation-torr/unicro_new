# Backend Deployment Guide

## Problem
Your cPanel doesn't support Node.js (npm not found). The backend needs to be deployed separately.

## Solution Options

### Option 1: Deploy to Heroku (Recommended - Free Tier Available)

#### Step 1: Install Heroku CLI
```bash
# Windows (using WSL)
curl https://cli-assets.heroku.com/install.sh | sh

# Or download from: https://devcenter.heroku.com/articles/heroku-cli
```

#### Step 2: Login to Heroku
```bash
heroku login
```

#### Step 3: Create Heroku App
```bash
cd /mnt/e/kanishk\ data/projects/UNICRO
heroku create unicro-backend
```

#### Step 4: Add Buildpack
```bash
heroku buildpacks:set heroku/nodejs
```

#### Step 5: Set Environment Variables
```bash
heroku config:set NODE_ENV=production
heroku config:set DB_HOST=your_cpanel_db_host
heroku config:set DB_USER=your_cpanel_db_user
heroku config:set DB_PASSWORD=your_cpanel_db_password
heroku config:set DB_NAME=your_cpanel_db_name
heroku config:set JWT_SECRET=your_jwt_secret
heroku config:set PORT=5000
```

#### Step 6: Deploy
```bash
git push heroku main
```

#### Step 7: Update Frontend API URL
In `client/src/services/api.js`, set:
```javascript
const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://unicro-backend.herokuapp.com/api';
```

Then rebuild and redeploy frontend.

---

### Option 2: Deploy to Railway (Easy - Free Tier Available)

1. **Sign up**: https://railway.app
2. **New Project** → **Deploy from GitHub**
3. **Select your repository**
4. **Set Root Directory**: Leave empty (or set to project root)
5. **Set Start Command**: `node server.js`
6. **Add Environment Variables**:
   - `NODE_ENV=production`
   - `DB_HOST=your_cpanel_db_host`
   - `DB_USER=your_cpanel_db_user`
   - `DB_PASSWORD=your_cpanel_db_password`
   - `DB_NAME=your_cpanel_db_name`
   - `JWT_SECRET=your_jwt_secret`
   - `PORT=5000`
7. **Deploy** - Railway will automatically deploy
8. **Get URL**: Railway will give you a URL like `https://your-app.railway.app`
9. **Update Frontend API URL** to point to Railway URL

---

### Option 3: Deploy to Render (Free Tier Available)

1. **Sign up**: https://render.com
2. **New** → **Web Service**
3. **Connect GitHub** → Select your repository
4. **Configure**:
   - **Name**: `unicro-backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `node server.js`
   - **Plan**: Free
5. **Add Environment Variables** (same as Railway)
6. **Create Web Service**
7. **Get URL**: Render will give you a URL
8. **Update Frontend API URL**

---

### Option 4: Use VPS (DigitalOcean, AWS EC2, etc.)

If you have a VPS:

1. **SSH into your VPS**
2. **Install Node.js**:
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```
3. **Clone your repository**:
   ```bash
   git clone https://github.com/unicrofoundation-torr/unicro_new.git
   cd unicro_new
   ```
4. **Install dependencies**:
   ```bash
   npm install --production
   ```
5. **Create .env file**:
   ```bash
   nano .env
   ```
   Add your database credentials
6. **Install PM2** (process manager):
   ```bash
   npm install -g pm2
   ```
7. **Start server**:
   ```bash
   pm2 start server.js --name unicro-backend
   pm2 save
   pm2 startup
   ```
8. **Update Frontend API URL** to point to your VPS IP/domain

---

## Important: Update Frontend After Backend Deployment

After deploying backend, you need to:

1. **Update API URL** in `client/src/services/api.js`:
   ```javascript
   const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://your-backend-url.com/api';
   ```

2. **Rebuild frontend**:
   ```bash
   cd client
   npm run build
   cd ..
   ```

3. **Redeploy frontend** using your deployment script

---

## Database Connection from Backend

Your backend needs to connect to your cPanel database. Make sure:

1. **Database host**: Usually `localhost` or your cPanel database host
2. **Database user**: Has remote access (if backend is on different server)
3. **Database name**: Correct database name
4. **Firewall**: Allow connections from backend server IP

**Note**: If backend is on different server, you may need to:
- Enable remote MySQL access in cPanel
- Add backend server IP to allowed hosts
- Or use a database connection service

---

## Quick Test

After deploying backend, test it:
```bash
curl https://your-backend-url.com/api/settings
```

Should return JSON data if working correctly.

