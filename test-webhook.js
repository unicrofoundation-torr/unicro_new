/**
 * Manual Webhook Testing Script
 * 
 * Usage:
 *   1. Set RAZORPAY_WEBHOOK_SECRET environment variable
 *   2. Run: node test-webhook.js
 * 
 * Or set the secret directly in this file (not recommended for production)
 */

const crypto = require('crypto');
const axios = require('axios');

// Configuration
const WEBHOOK_SECRET = process.env.RAZORPAY_WEBHOOK_SECRET || 'your_webhook_secret_here';
const WEBHOOK_URL = 'https://theonerupeerevolution.org/api/donations/razorpay/webhook';

// Test payloads
const testPayloads = {
  subscriptionActivated: {
    event: 'subscription.activated',
    payload: {
      subscription: {
        entity: {
          id: 'sub_test_' + Date.now(),
          status: 'active',
          plan_id: 'plan_test123',
          customer_id: 'cust_test123',
          current_start: Math.floor(Date.now() / 1000),
          current_end: Math.floor(Date.now() / 1000) + 2592000, // 30 days
          notes: {
            donor_name: 'Test Donor',
            donor_email: 'test@example.com',
            donor_phone: '1234567890',
            donor_address: '123 Test Street, Test City',
            cycle: 'monthly',
            amount: '700'
          }
        }
      }
    }
  },
  
  paymentCaptured: {
    event: 'payment.captured',
    payload: {
      payment: {
        entity: {
          id: 'pay_test_' + Date.now(),
          status: 'captured',
          amount: 70000, // in paise
          currency: 'INR',
          order_id: 'order_test_' + Date.now(),
          method: 'card',
          created_at: Math.floor(Date.now() / 1000)
        }
      }
    }
  },
  
  paymentFailed: {
    event: 'payment.failed',
    payload: {
      payment: {
        entity: {
          id: 'pay_test_' + Date.now(),
          status: 'failed',
          amount: 70000,
          currency: 'INR',
          order_id: 'order_test_' + Date.now(),
          method: 'card',
          created_at: Math.floor(Date.now() / 1000)
        }
      },
      subscription: {
        entity: {
          id: 'sub_test_' + Date.now(),
          status: 'active'
        }
      }
    }
  },
  
  subscriptionCharged: {
    event: 'subscription.charged',
    payload: {
      subscription: {
        entity: {
          id: 'sub_test_' + Date.now(),
          status: 'active',
          plan_id: 'plan_test123',
          notes: {
            donor_name: 'Test Donor',
            donor_email: 'test@example.com',
            cycle: 'monthly',
            amount: '700'
          }
        }
      },
      payment: {
        entity: {
          id: 'pay_test_' + Date.now(),
          status: 'captured',
          amount: 70000,
          currency: 'INR',
          method: 'card',
          created_at: Math.floor(Date.now() / 1000)
        }
      }
    }
  },
  
  subscriptionCancelled: {
    event: 'subscription.cancelled',
    payload: {
      subscription: {
        entity: {
          id: 'sub_test_' + Date.now(),
          status: 'cancelled',
          plan_id: 'plan_test123'
        }
      }
    }
  }
};

/**
 * Generate HMAC SHA256 signature for webhook payload
 */
function generateSignature(payload, secret) {
  const payloadString = typeof payload === 'string' ? payload : JSON.stringify(payload);
  return crypto
    .createHmac('sha256', secret)
    .update(payloadString)
    .digest('hex');
}

/**
 * Send test webhook
 */
async function sendTestWebhook(payloadName, payload) {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`Testing: ${payloadName}`);
  console.log(`${'='.repeat(60)}`);
  
  try {
    // Generate signature
    const payloadString = JSON.stringify(payload);
    const signature = generateSignature(payloadString, WEBHOOK_SECRET);
    
    console.log('📋 Payload:', JSON.stringify(payload, null, 2));
    console.log('🔑 Signature:', signature);
    console.log('🌐 URL:', WEBHOOK_URL);
    
    // Send webhook
    const response = await axios.post(WEBHOOK_URL, payload, {
      headers: {
        'Content-Type': 'application/json',
        'X-Razorpay-Signature': signature
      },
      timeout: 10000 // 10 seconds
    });
    
    console.log('\n✅ SUCCESS');
    console.log('Status:', response.status);
    console.log('Response:', JSON.stringify(response.data, null, 2));
    
    return { success: true, response: response.data };
    
  } catch (error) {
    console.log('\n❌ ERROR');
    if (error.response) {
      console.log('Status:', error.response.status);
      console.log('Response:', JSON.stringify(error.response.data, null, 2));
      console.log('Headers:', error.response.headers);
    } else if (error.request) {
      console.log('No response received');
      console.log('Error:', error.message);
    } else {
      console.log('Error:', error.message);
    }
    
    return { success: false, error: error.message };
  }
}

/**
 * Test webhook without signature (should fail gracefully)
 */
async function testWithoutSignature() {
  console.log(`\n${'='.repeat(60)}`);
  console.log('Testing: Webhook without signature (should return 200 OK with error)');
  console.log(`${'='.repeat(60)}`);
  
  try {
    const response = await axios.post(WEBHOOK_URL, { test: 'data' }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    console.log('✅ Response (expected):', response.data);
    console.log('Status:', response.status);
    
  } catch (error) {
    console.log('❌ Unexpected error:', error.message);
  }
}

/**
 * Main function
 */
async function main() {
  console.log('🧪 Razorpay Webhook Testing Script');
  console.log('==================================');
  console.log('Webhook URL:', WEBHOOK_URL);
  console.log('Webhook Secret:', WEBHOOK_SECRET.substring(0, 10) + '...');
  
  if (WEBHOOK_SECRET === 'your_webhook_secret_here') {
    console.log('\n⚠️  WARNING: Using default webhook secret. Set RAZORPAY_WEBHOOK_SECRET environment variable.');
    console.log('   Example: export RAZORPAY_WEBHOOK_SECRET="your_secret_here"');
  }
  
  // Test without signature first
  await testWithoutSignature();
  
  // Test all payloads
  const results = [];
  
  for (const [name, payload] of Object.entries(testPayloads)) {
    const result = await sendTestWebhook(name, payload);
    results.push({ name, ...result });
    
    // Wait 1 second between tests
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  
  // Summary
  console.log(`\n${'='.repeat(60)}`);
  console.log('📊 Test Summary');
  console.log(`${'='.repeat(60)}`);
  
  results.forEach(result => {
    const icon = result.success ? '✅' : '❌';
    console.log(`${icon} ${result.name}: ${result.success ? 'PASSED' : 'FAILED'}`);
  });
  
  const passed = results.filter(r => r.success).length;
  const total = results.length;
  
  console.log(`\nTotal: ${passed}/${total} tests passed`);
}

// Run tests
if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

module.exports = { sendTestWebhook, generateSignature, testPayloads };

