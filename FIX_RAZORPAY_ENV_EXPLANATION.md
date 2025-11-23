# Why cPanel Environment Variables Don't Work for React Frontend

## The Problem

You set `RAZORPAY_KEY_ID` in cPanel environment variables, but the frontend is still showing TEST mode. Here's why:

## How React Environment Variables Work

### ❌ What DOESN'T Work:
- Setting `REACT_APP_RAZORPAY_KEY_ID` in cPanel environment variables
- Setting it in server environment variables
- Setting it at runtime

**Why?** React apps are **pre-built** into static JavaScript files. The environment variables are **embedded at build time**, not read at runtime.

### ✅ What DOES Work:
- Setting `REACT_APP_RAZORPAY_KEY_ID` **during the build process**
- Hardcoding the key in the source code (as fallback)

## The Solution

### Option 1: Build with Environment Variable (Recommended)

When building the React app, set the environment variable:

```bash
REACT_APP_RAZORPAY_KEY_ID=rzp_live_RhWOsPuVUOT0Xx npm run build
```

This embeds the key into the JavaScript bundle.

### Option 2: Hardcoded Fallback (Already Done)

We've already added a hardcoded fallback in `Donate.js`:

```javascript
key: process.env.REACT_APP_RAZORPAY_KEY_ID || 'rzp_live_RhWOsPuVUOT0Xx'
```

This ensures the LIVE key is used even if the env var isn't set during build.

## Why cPanel Environment Variables Are Different

### Backend (Node.js):
- ✅ Reads environment variables at **runtime**
- ✅ Can use cPanel environment variables
- ✅ `RAZORPAY_KEY_ID` in cPanel works for backend

### Frontend (React):
- ❌ Environment variables must be set at **build time**
- ❌ cPanel environment variables are NOT available to browser
- ✅ Must be set during `npm run build`

## Current Setup

1. **Backend**: Uses `RAZORPAY_KEY_ID` from cPanel ✅
2. **Frontend**: Uses hardcoded fallback in `Donate.js` ✅

## To Fix

Run the rebuild script which sets the env var during build:

```bash
bash simple_rebuild_deploy.sh
```

This will:
1. Set `REACT_APP_RAZORPAY_KEY_ID` during build
2. Embed LIVE key into JavaScript bundle
3. Deploy the new build

## Summary

- **cPanel env vars** = For Node.js backend only
- **React env vars** = Must be set at build time
- **Hardcoded fallback** = Ensures LIVE key is always used

