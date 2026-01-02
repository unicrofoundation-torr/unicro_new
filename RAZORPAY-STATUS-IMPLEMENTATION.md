# Razorpay Exact Status Implementation

## Overview
This document explains how the exact Razorpay status (like "Captured", "Failed", "Active", etc.) is now stored and displayed in the system.

## Problem
Previously, we were mapping Razorpay statuses to our own statuses (active, paid, failed, etc.), but the user wanted to see the **exact status from Razorpay dashboard** to identify discrepancies.

## Solution
Added a new `razorpay_status` column to the `donations` table to store the exact status from Razorpay, while keeping our mapped `status` column for internal use.

---

## Database Changes

### New Column
```sql
ALTER TABLE donations ADD COLUMN razorpay_status VARCHAR(50) DEFAULT NULL;
```

This column stores the exact status from Razorpay:
- For **subscriptions**: `active`, `authenticated`, `paused`, `cancelled`, `expired`, `completed`, etc.
- For **payments**: `captured`, `failed`, `authorized`, `refunded`, etc.

---

## Code Changes

### 1. Database Schema (`routes/donations.js`)

**Added column in `ensureTables()`:**
```javascript
// Add razorpay_status column to store exact Razorpay status
try {
  await db.execute(`ALTER TABLE donations ADD COLUMN razorpay_status VARCHAR(50) DEFAULT NULL`);
} catch (err) {
  // Column already exists, ignore
}
```

### 2. Webhook Handler

**Stores exact Razorpay status when processing webhook events:**
```javascript
// For subscription events
const razorpayStatus = subscription.status || 'unknown';
await db.execute('UPDATE donations SET status = "active", razorpay_status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', 
  [razorpayStatus, donationId]);

// For payment events
const razorpayPaymentStatus = payment.status || 'unknown';
await db.execute('UPDATE donations SET status = "paid", razorpay_payment_id = ?, razorpay_status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', 
  [payment.id, razorpayPaymentStatus, donationId]);
```

### 3. Create Donor Endpoint

**Stores exact Razorpay status when creating donations:**
```javascript
// For one-time payments
const razorpayPaymentStatus = payment.status || 'unknown';
await db.execute(
  'INSERT INTO donations (..., status, razorpay_status, ...) VALUES (..., "paid", ?, ...)',
  [razorpayPaymentStatus, ...]
);

// For recurring subscriptions
const razorpayStatus = subscription.status || 'unknown';
await db.execute(
  'INSERT INTO donations (..., status, razorpay_status, ...) VALUES (..., "active", ?, ...)',
  [razorpayStatus, ...]
);
```

### 4. Sync Endpoints

**Sync endpoints now fetch and store exact Razorpay status:**
```javascript
// Sync single subscription
const razorpayStatus = subscription.status;
await db.execute('UPDATE donations SET status = ?, razorpay_status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', 
  [dbStatus, razorpayStatus, donationId]);

// Also fetch payment status for more accuracy
const payments = await razorpay.payments.all({ subscription_id: subscriptionId, count: 1 });
if (payments && payments.items && payments.items.length > 0) {
  const latestPayment = payments.items[0];
  await db.execute('UPDATE donations SET razorpay_status = ? WHERE id = ?', 
    [latestPayment.status || razorpayStatus, donationId]);
}
```

### 5. Admin Panel Display (`client/src/components/admin/DonationsManager.js`)

**Updated `getStatusBadge()` to show both statuses:**
```javascript
const getStatusBadge = (status, razorpayStatus = null) => {
  // ... existing status badge code ...
  
  // Show Razorpay status if available and different from our status
  const showRazorpayStatus = razorpayStatus && razorpayStatus.toLowerCase() !== status?.toLowerCase();
  
  return (
    <div className="flex flex-col gap-1">
      <span className={`px-2 py-1 rounded-full text-xs font-semibold ${colorClass}`}>
        {statusLabel}
      </span>
      {showRazorpayStatus && (
        <span className="px-2 py-0.5 rounded text-xs font-medium bg-blue-50 text-blue-700 border border-blue-200">
          Razorpay: {razorpayStatus.toUpperCase()}
        </span>
      )}
    </div>
  );
};
```

**Updated table to pass Razorpay status:**
```javascript
<td className="px-4 py-3 text-sm">{getStatusBadge(donation.status, donation.razorpay_status)}</td>
```

---

## Razorpay Status Values

### Subscription Statuses:
- `active` - Subscription is active and charging
- `authenticated` - Subscription is authenticated (for cards)
- `created` - Subscription created but not yet active
- `paused` - Subscription is paused
- `cancelled` - Subscription is cancelled
- `expired` - Subscription has expired
- `completed` - Subscription completed (all charges done)

### Payment Statuses:
- `captured` - Payment successfully captured
- `authorized` - Payment authorized but not yet captured
- `failed` - Payment failed
- `refunded` - Payment refunded
- `pending` - Payment pending

---

## Display in Admin Panel

### Status Badge Display:
1. **Our Status** (top badge):
   - ✅ ACTIVE / ✅ PAID (green)
   - ❌ FAILED / ❌ CANCELLED (red)
   - ⏳ PENDING (gray)
   - ⏸️ PAUSED (yellow)

2. **Razorpay Status** (bottom badge, if different):
   - Only shown if `razorpay_status` differs from our `status`
   - Blue badge with "Razorpay: [STATUS]"
   - Example: "Razorpay: CAPTURED" or "Razorpay: FAILED"

---

## Benefits

1. **Exact Status Visibility**: See the exact status from Razorpay dashboard
2. **Discrepancy Detection**: Easily identify when our status differs from Razorpay
3. **Payment Status Accuracy**: For subscriptions, we fetch the latest payment status for more accuracy
4. **Debugging**: Helps debug payment processing issues

---

## How It Works

1. **Webhook Events**: When Razorpay sends webhook events, we store the exact status from the event
2. **Payment Success**: When payment succeeds, we fetch the payment status from Razorpay API
3. **Sync Operations**: When syncing with Razorpay, we fetch the latest subscription and payment statuses
4. **Display**: Admin panel shows both our mapped status and the exact Razorpay status (if different)

---

## Example Scenarios

### Scenario 1: Successful Payment
- **Our Status**: ✅ PAID
- **Razorpay Status**: CAPTURED
- **Display**: Shows both badges (if different)

### Scenario 2: Failed Payment
- **Our Status**: ❌ FAILED
- **Razorpay Status**: FAILED
- **Display**: Only shows our status badge (same as Razorpay)

### Scenario 3: Active Subscription
- **Our Status**: ✅ ACTIVE
- **Razorpay Status**: ACTIVE
- **Display**: Only shows our status badge (same as Razorpay)

### Scenario 4: Subscription with Payment Issue
- **Our Status**: ✅ ACTIVE
- **Razorpay Status**: FAILED (latest payment failed)
- **Display**: Shows both badges to highlight the discrepancy

---

## Testing

After deployment, verify:
1. Check database: `SELECT id, status, razorpay_status FROM donations LIMIT 10;`
2. Check admin panel: Status badges should show Razorpay status when different
3. Test webhook: Make a test payment and verify status is stored
4. Test sync: Click "Sync with Razorpay" and verify statuses are updated

---

## Notes

- The `razorpay_status` column is nullable (can be NULL)
- For subscriptions, we prioritize payment status over subscription status when available
- Status is updated on every webhook event, sync operation, and payment success callback
- The admin panel only shows Razorpay status if it differs from our status to avoid clutter

