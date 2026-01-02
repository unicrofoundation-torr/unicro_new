# PowerShell Script to Test Razorpay Webhook
# Usage: .\test-webhook.ps1

$WEBHOOK_SECRET = $env:RAZORPAY_WEBHOOK_SECRET
$WEBHOOK_URL = "https://theonerupeerevolution.org/api/donations/razorpay/webhook"

if (-not $WEBHOOK_SECRET) {
    Write-Host "⚠️  WARNING: RAZORPAY_WEBHOOK_SECRET environment variable not set" -ForegroundColor Yellow
    Write-Host "   Set it with: `$env:RAZORPAY_WEBHOOK_SECRET = 'your_secret_here'" -ForegroundColor Yellow
    exit 1
}

# Function to generate HMAC SHA256 signature
function Generate-Signature {
    param(
        [string]$Payload,
        [string]$Secret
    )
    
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($Secret)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Payload)
    $hash = $hmac.ComputeHash($bytes)
    $signature = [System.BitConverter]::ToString($hash).Replace("-", "").ToLower()
    
    return $signature
}

# Test payload
$testPayload = @{
    event = "subscription.activated"
    payload = @{
        subscription = @{
            entity = @{
                id = "sub_test_$(Get-Date -Format 'yyyyMMddHHmmss')"
                status = "active"
                plan_id = "plan_test123"
                notes = @{
                    donor_name = "Test Donor"
                    donor_email = "test@example.com"
                    donor_phone = "1234567890"
                    cycle = "monthly"
                    amount = "700"
                }
            }
        }
    }
} | ConvertTo-Json -Depth 10

Write-Host "`n🧪 Testing Razorpay Webhook" -ForegroundColor Cyan
Write-Host ("=" * 60)
Write-Host "URL: $WEBHOOK_URL"
Write-Host "Secret: $($WEBHOOK_SECRET.Substring(0, [Math]::Min(10, $WEBHOOK_SECRET.Length)))..."
Write-Host "`nPayload:" -ForegroundColor Yellow
Write-Host $testPayload

# Generate signature
$signature = Generate-Signature -Payload $testPayload -Secret $WEBHOOK_SECRET
Write-Host "`nSignature: $signature" -ForegroundColor Green

# Send webhook
try {
    $headers = @{
        "Content-Type" = "application/json"
        "X-Razorpay-Signature" = $signature
    }
    
    Write-Host "`n📤 Sending webhook..." -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri $WEBHOOK_URL -Method Post -Body $testPayload -Headers $headers -ContentType "application/json"
    
    Write-Host "`n✅ SUCCESS" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "`n❌ ERROR" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
        
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    } else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

$separator = "=" * 60
Write-Host ("`n" + $separator)
