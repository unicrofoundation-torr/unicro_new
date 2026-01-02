# How to Access Webhook Logs from Backend

## Overview
Webhook logs are stored in the `webhook_logs` database table and can be accessed through multiple methods.

---

## Method 1: Admin Panel UI (Easiest)

### Access via Web Interface:
1. **Login to Admin Panel**: `https://theonerupeerevolution.org/admin`
2. **Navigate to "Logs" tab** in the sidebar
3. **View all webhook logs** in a table format
4. **Filter logs** by:
   - Event Type (subscription.activated, payment.captured, etc.)
   - Status (success, error, signature_invalid, etc.)
   - Subscription ID
5. **Click "View Details"** on any log to see full request/response payloads

**Features:**
- Pagination (50 logs per page)
- Real-time filtering
- Detailed modal view with JSON payloads
- Status badges and signature validation indicators

---

## Method 2: API Endpoints (Programmatic Access)

### Get All Webhook Logs

**Endpoint:** `GET /api/donations/admin/webhook-logs`

**Authentication:** Required (Bearer token)

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Logs per page (default: 50)
- `event_type` (optional): Filter by event type (e.g., `subscription.activated`)
- `status` (optional): Filter by status (e.g., `success`, `error`)
- `subscription_id` (optional): Filter by subscription ID

**Example Request:**
```bash
curl -X GET "https://theonerupeerevolution.org/api/donations/admin/webhook-logs?page=1&limit=50&status=success" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**Example Response:**
```json
{
  "success": true,
  "logs": [
    {
      "id": 1,
      "event_type": "subscription.activated",
      "razorpay_subscription_id": "sub_xxx",
      "razorpay_payment_id": null,
      "razorpay_order_id": null,
      "signature_valid": true,
      "status": "success",
      "request_payload": { ... },
      "response_data": { ... },
      "error_message": null,
      "processing_time_ms": 125,
      "ip_address": "123.456.789.0",
      "user_agent": "Razorpay-Webhook/1.0",
      "created_at": "2025-01-02T12:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 150,
    "totalPages": 3
  }
}
```

### Get Single Webhook Log by ID

**Endpoint:** `GET /api/donations/admin/webhook-logs/:id`

**Authentication:** Required (Bearer token)

**Example Request:**
```bash
curl -X GET "https://theonerupeerevolution.org/api/donations/admin/webhook-logs/1" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**Example Response:**
```json
{
  "success": true,
  "log": {
    "id": 1,
    "event_type": "subscription.activated",
    "razorpay_subscription_id": "sub_xxx",
    "signature_valid": true,
    "status": "success",
    "request_payload": { ... },
    "response_data": { ... },
    "processing_time_ms": 125,
    "created_at": "2025-01-02T12:00:00.000Z"
  }
}
```

---

## Method 3: Direct Database Access

### Via phpMyAdmin (cPanel)

1. **Login to cPanel**
2. **Open phpMyAdmin**
3. **Select your database**
4. **Click on `webhook_logs` table**
5. **Browse or query the table**

### Via MySQL Command Line

**SSH into your server:**
```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
```

**Connect to MySQL:**
```bash
mysql -u your_username -p your_database_name
```

**Query Examples:**

```sql
-- Get all logs (latest first)
SELECT * FROM webhook_logs ORDER BY created_at DESC LIMIT 50;

-- Get logs by event type
SELECT * FROM webhook_logs 
WHERE event_type = 'subscription.activated' 
ORDER BY created_at DESC;

-- Get failed webhooks
SELECT * FROM webhook_logs 
WHERE status = 'error' 
ORDER BY created_at DESC;

-- Get logs for a specific subscription
SELECT * FROM webhook_logs 
WHERE razorpay_subscription_id = 'sub_xxx' 
ORDER BY created_at DESC;

-- Get logs with invalid signatures
SELECT * FROM webhook_logs 
WHERE signature_valid = 0 
ORDER BY created_at DESC;

-- Count logs by status
SELECT status, COUNT(*) as count 
FROM webhook_logs 
GROUP BY status;

-- Get logs from last 24 hours
SELECT * FROM webhook_logs 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR) 
ORDER BY created_at DESC;
```

---

## Method 4: Using Node.js Script

Create a script `fetch-logs.js`:

```javascript
const axios = require('axios');

const ADMIN_TOKEN = 'your_admin_token_here';
const API_URL = 'https://theonerupeerevolution.org/api/donations/admin/webhook-logs';

async function fetchLogs() {
  try {
    const response = await axios.get(API_URL, {
      headers: {
        'Authorization': `Bearer ${ADMIN_TOKEN}`
      },
      params: {
        page: 1,
        limit: 50,
        status: 'success' // Optional filter
      }
    });
    
    console.log('Total logs:', response.data.pagination.total);
    console.log('Logs:', JSON.stringify(response.data.logs, null, 2));
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

fetchLogs();
```

**Run:**
```bash
node fetch-logs.js
```

---

## Method 5: Using Postman

1. **Create new GET request**
2. **URL:** `https://theonerupeerevolution.org/api/donations/admin/webhook-logs`
3. **Headers:**
   - `Authorization: Bearer YOUR_ADMIN_TOKEN`
4. **Query Params (optional):**
   - `page`: 1
   - `limit`: 50
   - `event_type`: subscription.activated
   - `status`: success
5. **Send request**

---

## Database Schema

The `webhook_logs` table structure:

```sql
CREATE TABLE webhook_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  event_type VARCHAR(100) NOT NULL,
  razorpay_subscription_id VARCHAR(100),
  razorpay_payment_id VARCHAR(100),
  razorpay_order_id VARCHAR(100),
  signature_valid BOOLEAN DEFAULT FALSE,
  status VARCHAR(50) DEFAULT 'received',
  request_payload JSON,
  response_data JSON,
  error_message TEXT,
  processing_time_ms INT DEFAULT 0,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (event_type),
  INDEX (razorpay_subscription_id),
  INDEX (razorpay_payment_id),
  INDEX (created_at),
  INDEX (status)
);
```

---

## Log Status Values

- `success` - Webhook processed successfully
- `error` - Error during processing
- `signature_invalid` - Signature verification failed
- `parse_error` - Failed to parse JSON payload
- `received` - Webhook received but not yet processed

---

## Event Types

Common event types logged:
- `subscription.activated`
- `subscription.charged`
- `subscription.cancelled`
- `subscription.paused`
- `payment.captured`
- `payment.failed`
- `payment.authorized`

---

## Quick Access Examples

### Get Latest 10 Success Logs:
```bash
curl -X GET "https://theonerupeerevolution.org/api/donations/admin/webhook-logs?limit=10&status=success" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get All Failed Webhooks:
```bash
curl -X GET "https://theonerupeerevolution.org/api/donations/admin/webhook-logs?status=error" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Logs for Specific Subscription:
```bash
curl -X GET "https://theonerupeerevolution.org/api/donations/admin/webhook-logs?subscription_id=sub_xxx" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Notes

- **Authentication Required**: All API endpoints require admin authentication
- **Pagination**: Default limit is 50 logs per page
- **JSON Fields**: `request_payload` and `response_data` are stored as JSON and automatically parsed in API responses
- **Performance**: Logs are indexed for fast queries by event_type, status, subscription_id, and created_at
- **Retention**: Logs are stored indefinitely (consider implementing cleanup for old logs if needed)

---

## Troubleshooting

### If logs are not appearing:
1. Check if webhook is actually being called (check Razorpay dashboard)
2. Verify database table exists: `SHOW TABLES LIKE 'webhook_logs';`
3. Check server logs for errors in webhook handler
4. Verify authentication token is valid

### If API returns 404:
1. Ensure endpoint is deployed: `/api/donations/admin/webhook-logs`
2. Check Node.js app is running
3. Verify route is registered in `routes/donations.js`

### If database query fails:
1. Check database connection
2. Verify table exists: `DESCRIBE webhook_logs;`
3. Check user permissions

