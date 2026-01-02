#!/bin/bash

# Bash Script to Test Razorpay Webhook
# Usage: ./test-webhook.sh
# For WSL/Ubuntu

WEBHOOK_SECRET="efK2L8e_VX6LjfZ"
WEBHOOK_URL="https://theonerupeerevolution.org/api/donations/razorpay/webhook"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if webhook secret is set
if [ -z "$WEBHOOK_SECRET" ]; then
    echo -e "${YELLOW}⚠️  WARNING: RAZORPAY_WEBHOOK_SECRET environment variable not set${NC}"
    echo -e "${YELLOW}   Set it with: export RAZORPAY_WEBHOOK_SECRET='your_secret_here'${NC}"
    exit 1
fi

# Function to generate HMAC SHA256 signature
generate_signature() {
    local payload="$1"
    local secret="$2"
    echo -n "$payload" | openssl dgst -sha256 -hmac "$secret" | sed 's/^.* //'
}

# Test payload
TIMESTAMP=$(date +%Y%m%d%H%M%S)
TEST_PAYLOAD=$(cat <<EOF
{
  "event": "subscription.activated",
  "payload": {
    "subscription": {
      "entity": {
        "id": "sub_test_${TIMESTAMP}",
        "status": "active",
        "plan_id": "plan_test123",
        "customer_id": "cust_test123",
        "current_start": $(date +%s),
        "current_end": $(($(date +%s) + 2592000)),
        "notes": {
          "donor_name": "Test Donor",
          "donor_email": "test@example.com",
          "donor_phone": "1234567890",
          "donor_address": "123 Test Street, Test City",
          "cycle": "monthly",
          "amount": "700"
        }
      }
    }
  }
}
EOF
)

echo ""
echo -e "${CYAN}🧪 Testing Razorpay Webhook${NC}"
echo "============================================================"
echo "URL: $WEBHOOK_URL"
echo "Secret: ${WEBHOOK_SECRET:0:10}..."
echo ""
echo -e "${YELLOW}Payload:${NC}"
echo "$TEST_PAYLOAD" | jq '.' 2>/dev/null || echo "$TEST_PAYLOAD"

# Generate signature
SIGNATURE=$(generate_signature "$TEST_PAYLOAD" "$WEBHOOK_SECRET")
echo ""
echo -e "${GREEN}Signature: $SIGNATURE${NC}"

# Send webhook
echo ""
echo -e "${CYAN}📤 Sending webhook...${NC}"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-Razorpay-Signature: $SIGNATURE" \
  -d "$TEST_PAYLOAD")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✅ SUCCESS${NC}"
    echo -e "${YELLOW}Status Code: $HTTP_CODE${NC}"
    echo -e "${YELLOW}Response:${NC}"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
else
    echo -e "${RED}❌ ERROR${NC}"
    echo -e "${RED}Status Code: $HTTP_CODE${NC}"
    echo -e "${RED}Response: $BODY${NC}"
fi

echo ""
echo "============================================================"
echo ""

