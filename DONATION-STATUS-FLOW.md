# Donation Status Flow - How Statuses are Fetched and Determined

## Overview
The donation status system tracks the payment state of donations. Statuses are stored in the `donations.status` column in the database and are updated from multiple sources.

## Status Values

### Database Status Values:
- `'created'` → Displayed as **⏳ PENDING**
- `'active'` → Displayed as **✅ ACTIVE** (for recurring subscriptions)
- `'paid'` → Displayed as **✅ PAID** (for one-time payments)
- `'paused'` → Displayed as **⏸️ PAUSED**
- `'cancelled'` → Displayed as **❌ CANCELLED**
- `'failed'` → Displayed as **❌ FAILED**
- Any other value → Displayed as **UNKNOWN**

## How Status is Determined

### 1. **Initial Status (When Donation is Created)**

#### For Recurring Donations (Subscriptions):
```javascript
// Location: routes/donations.js - create-subscription endpoint
const donationStatus = (subscription.status === 'active' || subscription.status === 'authenticated') 
  ? 'active' 
  : 'created';
```
- If Razorpay subscription is `active` or `authenticated` → Status = `'active'`
- Otherwise → Status = `'created'` (pending)

#### For One-Time Donations:
```javascript
// Location: routes/donations.js - create-payment endpoint
// Status starts as 'created' (pending) until payment is confirmed
```

### 2. **Status Updates from Razorpay Webhooks**

Webhooks automatically update status when events occur:

```javascript
// Location: routes/donations.js - webhook endpoint

// When subscription is activated or charged:
if (event === 'subscription.activated' || event === 'subscription.charged') {
  status = 'active';
}

// When subscription is paused:
if (event === 'subscription.paused') {
  status = 'paused';
}

// When subscription is cancelled:
if (event === 'subscription.cancelled') {
  status = 'cancelled';
}

// When payment fails:
if (event === 'payment.failed') {
  status = 'failed';
}
```

### 3. **Status Updates from Manual Sync**

#### Sync Single Subscription:
```javascript
// Location: routes/donations.js - sync-razorpay endpoint
// Maps Razorpay status to database status:

Razorpay Status → Database Status:
- 'active' or 'authenticated' → 'active'
- 'paused' → 'paused'
- 'cancelled' or 'expired' → 'cancelled'
- 'completed' → 'active'
- Others → 'created'
```

#### Sync All Subscriptions:
```javascript
// Location: routes/donations.js - sync-all endpoint
// Fetches all subscriptions from Razorpay and updates status:

if (subscription.status === 'active' || subscription.status === 'authenticated') {
  dbStatus = 'active';
} else if (subscription.status === 'paused') {
  dbStatus = 'paused';
} else if (subscription.status === 'cancelled' || subscription.status === 'expired') {
  dbStatus = 'cancelled';
}
```

### 4. **Status Updates from Verify & Cleanup**

```javascript
// Location: routes/donations.js - verify-and-cleanup endpoint

// If subscription is active in Razorpay:
if (subscription.status === 'active' || subscription.status === 'authenticated') {
  status = 'active'; // Activate pending donations
}

// If subscription is cancelled/expired:
if (subscription.status === 'cancelled' || subscription.status === 'expired') {
  // Delete if no successful payments, otherwise mark as cancelled
  status = 'cancelled';
}
```

### 5. **Status Updates from Payment Success Callback**

```javascript
// Location: routes/donations.js - create-donor endpoint
// When payment is successful (one-time or recurring):

if (payment.status === 'captured' || payment.status === 'authorized') {
  status = 'paid'; // For one-time payments
}

if (subscription.status === 'active' || subscription.status === 'authenticated') {
  status = 'active'; // For recurring subscriptions
}
```

## Status Display in Frontend

### Frontend Status Badge Function:
```javascript
// Location: client/src/components/admin/DonationsManager.js

const getStatusBadge = (status) => {
  // Maps database status to display:
  'created' → '⏳ PENDING' (gray badge)
  'active' → '✅ ACTIVE' (green badge)
  'paid' → '✅ PAID' (green badge)
  'paused' → '⏸️ PAUSED' (yellow badge)
  'cancelled' → '❌ CANCELLED' (red badge)
  'failed' → '❌ FAILED' (red badge)
  unknown → 'UNKNOWN' (gray badge)
}
```

## Status Filtering in Admin Panel

### Backend Filtering:
```javascript
// Location: routes/donations.js - /admin endpoint

Filter Options:
- 'successful' → Shows only status IN ('active', 'paid')
- 'active' → Shows only status = 'active'
- 'paid' → Shows only status = 'paid'
- 'failed' → Shows only status IN ('failed', 'cancelled')
- 'pending' → Shows only status = 'created'
- 'all-statuses' → Shows all statuses
- 'all' → Shows all (no filter)
```

## Status Flow Diagram

```
1. Donation Created
   ↓
   Status: 'created' (PENDING)
   ↓
2. Payment Processing
   ↓
   ├─→ Success → Status: 'active' (recurring) or 'paid' (one-time)
   │              (via webhook or callback)
   │
   ├─→ Failed → Status: 'failed'
   │             (via webhook)
   │
   └─→ Cancelled → Status: 'cancelled'
                  (via webhook or manual)
   ↓
3. Ongoing Updates
   ↓
   ├─→ Webhook Events → Auto-update status
   ├─→ Manual Sync → Fetch latest from Razorpay
   └─→ Verify & Cleanup → Check and update status
```

## Key Points

1. **Status is stored in database** - The `donations.status` column holds the current status
2. **Multiple update sources** - Status can be updated from:
   - Razorpay webhooks (automatic)
   - Manual sync operations
   - Payment success callbacks
   - Verify & cleanup operations
3. **Status mapping** - Razorpay statuses are mapped to our database statuses
4. **Display mapping** - Database statuses are mapped to user-friendly labels with icons
5. **Filtering** - Admin panel can filter donations by status

## Common Status Scenarios

### Scenario 1: New Recurring Donation
1. User creates subscription → Status: `'created'`
2. Payment succeeds → Webhook: `subscription.activated` → Status: `'active'`
3. Monthly charge → Webhook: `subscription.charged` → Status remains: `'active'`

### Scenario 2: One-Time Donation
1. User creates payment → Status: `'created'`
2. Payment succeeds → Callback → Status: `'paid'`

### Scenario 3: Failed Payment
1. User creates subscription → Status: `'created'`
2. Payment fails → Webhook: `payment.failed` → Status: `'failed'`

### Scenario 4: Cancelled Subscription
1. Active subscription → Status: `'active'`
2. User cancels → Webhook: `subscription.cancelled` → Status: `'cancelled'`

## How to Check Current Status

1. **Database Query:**
   ```sql
   SELECT id, status, razorpay_subscription_id FROM donations WHERE id = ?;
   ```

2. **Admin Panel:**
   - View donations table - status badge shows current status
   - Filter by status to see specific states

3. **Sync with Razorpay:**
   - Click "Sync with Razorpay" to fetch latest status from Razorpay
   - Status will be updated based on Razorpay's current state

## Troubleshooting Status Issues

### If status shows "UNKNOWN":
- Check database for actual status value
- Verify status mapping in `getStatusBadge()` function
- Status might be NULL or unexpected value

### If status is not updating:
- Check if Razorpay webhooks are enabled
- Manually sync using "Sync with Razorpay" button
- Check webhook logs for errors

### If status is incorrect:
- Run "Verify & Cleanup" to check status with Razorpay
- Manually sync the specific subscription
- Check Razorpay dashboard for actual subscription status

