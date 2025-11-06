# Deployment Guide

## Quick Deploy (Single Command)

### Option 1: From Windows (PowerShell/CMD)
```bash
.\deploy-live.bat
```

### Option 2: From WSL/Ubuntu
```bash
bash deploy-live.sh
```

### Option 3: Using npm (from project root)
```bash
npm run deploy
```

## What the Deployment Script Does

1. **Installs Dependencies**
   - Installs root dependencies (`npm install`)
   - Installs client dependencies (`cd client && npm install`)

2. **Builds React App**
   - Creates production build of React app
   - Optimizes and minifies all assets
   - Outputs to `client/build/` directory

3. **Starts Production Server**
   - Sets `NODE_ENV=production`
   - Starts Node.js server on port 5000
   - Serves both API and React app from single server

## Access Your Live Website

After deployment, your website will be available at:
- **Frontend**: http://localhost:5000
- **API**: http://localhost:5000/api
- **Admin Panel**: http://localhost:5000/admin/login

## Important Notes

1. **Environment Variables**: Make sure your `.env` file is configured with production values:
   - Database credentials
   - JWT secret (change from default!)
   - Cashfree credentials (if using)

2. **Port Configuration**: The server runs on port 5000 by default. Change `PORT` in `.env` if needed.

3. **Database**: Ensure MySQL is running and accessible with the credentials in `.env`

4. **Stopping the Server**: 
   ```bash
   pkill -f "node server.js"
   ```

5. **Viewing Logs**:
   ```bash
   tail -f server.log
   ```

## Production Checklist

- [ ] Update `.env` with production database credentials
- [ ] Change `JWT_SECRET` to a secure random string
- [ ] Update `CASHFREE_ENV` to `PROD` if using production Cashfree
- [ ] Ensure MySQL is running and accessible
- [ ] Test the website after deployment
- [ ] Configure firewall/port forwarding if deploying to a server

