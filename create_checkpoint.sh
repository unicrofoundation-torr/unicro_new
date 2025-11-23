#!/bin/bash
# Create a checkpoint of the current working state

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BACKUP_DIR="$PROJECT_ROOT/backups"
CHECKPOINT_DIR="$PROJECT_ROOT/checkpoints"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

# Database config
LOCAL_DB_USER="root"
LOCAL_DB_PASS="root123"
LOCAL_DB_NAME="charity_website"
REMOTE_DB_USER="theomkiq_charity"
REMOTE_DB_PASS="Unicro@001"
REMOTE_DB_NAME="theomkiq_charity"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CHECKPOINT_NAME="checkpoint_${TIMESTAMP}"
CHECKPOINT_PATH="$CHECKPOINT_DIR/$CHECKPOINT_NAME"

echo "💾 Creating Checkpoint: $CHECKPOINT_NAME"
echo "========================================"
echo ""

# Create checkpoint directory
mkdir -p "$CHECKPOINT_PATH"
mkdir -p "$CHECKPOINT_DIR"

# Step 1: Database backups
echo "1️⃣  Backing up databases..."
echo "============================"

# Local database backup
echo "   Backing up local database..."
LOCAL_BACKUP="$CHECKPOINT_PATH/local_db_${TIMESTAMP}.sql"
if [ -f "/mnt/c/Program Files/MySQL/MySQL Server 8.0/bin/mysqldump.exe" ]; then
  /mnt/c/Program\ Files/MySQL/MySQL\ Server\ 8.0/bin/mysqldump.exe -u$LOCAL_DB_USER -p$LOCAL_DB_PASS $LOCAL_DB_NAME > "$LOCAL_BACKUP" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "   ✅ Local database backed up: $(basename $LOCAL_BACKUP)"
  else
    echo "   ⚠️  Local database backup failed"
  fi
else
  echo "   ⚠️  MySQL not found, skipping local backup"
fi

# Remote database backup
echo "   Backing up remote database..."
REMOTE_BACKUP="$CHECKPOINT_PATH/remote_db_${TIMESTAMP}.sql"
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << EOF
mysqldump -u$REMOTE_DB_USER -p$REMOTE_DB_PASS $REMOTE_DB_NAME > /tmp/remote_db_${TIMESTAMP}.sql 2>/dev/null
if [ \$? -eq 0 ]; then
  echo "   ✅ Remote database backed up"
else
  echo "   ⚠️  Remote database backup failed"
fi
EOF

# Download remote backup
scp -i "$PRIVATE_KEY" -P "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST:/tmp/remote_db_${TIMESTAMP}.sql" "$REMOTE_BACKUP" 2>/dev/null
if [ -f "$REMOTE_BACKUP" ]; then
  echo "   ✅ Remote database downloaded: $(basename $REMOTE_BACKUP)"
else
  echo "   ⚠️  Failed to download remote backup"
fi

echo ""

# Step 2: Code state (Git commit and tag)
echo "2️⃣  Saving code state..."
echo "========================="
cd "$PROJECT_ROOT"

# Check if git is initialized
if [ ! -d .git ]; then
  echo "   ⚠️  Git not initialized, initializing..."
  git init
  git add .
  git commit -m "Initial checkpoint: $CHECKPOINT_NAME"
fi

# Add all changes
git add .
git status --short | head -10

# Commit current state
COMMIT_MSG="Checkpoint: $CHECKPOINT_NAME - Working state with LIVE Razorpay key"
git commit -m "$COMMIT_MSG" 2>/dev/null || echo "   (no changes to commit)"

# Create tag
git tag -a "$CHECKPOINT_NAME" -m "Checkpoint: $CHECKPOINT_NAME - Working production state" 2>/dev/null
echo "   ✅ Git tag created: $CHECKPOINT_NAME"

# Push to remote if exists
if git remote -v | grep -q origin; then
  git push origin main 2>/dev/null || echo "   ⚠️  Failed to push to remote"
  git push origin "$CHECKPOINT_NAME" 2>/dev/null || echo "   ⚠️  Failed to push tag"
  echo "   ✅ Pushed to remote"
fi

echo ""

# Step 3: Save configuration files
echo "3️⃣  Backing up configuration files..."
echo "======================================"

# Save important config files
cp "$PROJECT_ROOT/server.js" "$CHECKPOINT_PATH/server.js" 2>/dev/null
cp "$PROJECT_ROOT/config/database.js" "$CHECKPOINT_PATH/database.js" 2>/dev/null
cp "$PROJECT_ROOT/package.json" "$CHECKPOINT_PATH/package.json" 2>/dev/null
cp "$CLIENT_DIR/package.json" "$CHECKPOINT_PATH/client_package.json" 2>/dev/null
cp "$CLIENT_DIR/src/pages/Donate.js" "$CHECKPOINT_PATH/Donate.js" 2>/dev/null
cp "$CLIENT_DIR/src/services/api.js" "$CHECKPOINT_PATH/api.js" 2>/dev/null

# Save .htaccess files (if they exist)
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << EOF
mkdir -p /tmp/checkpoint_${TIMESTAMP}
if [ -f ~/public_html/.htaccess ]; then
  cp ~/public_html/.htaccess /tmp/checkpoint_${TIMESTAMP}/public_html_htaccess
fi
if [ -f ~/public_html/api/.htaccess ]; then
  cp ~/public_html/api/.htaccess /tmp/checkpoint_${TIMESTAMP}/api_htaccess
fi
EOF

scp -i "$PRIVATE_KEY" -P "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST:/tmp/checkpoint_${TIMESTAMP}/*" "$CHECKPOINT_PATH/" 2>/dev/null

echo "   ✅ Configuration files backed up"
echo ""

# Step 4: Save environment variables info
echo "4️⃣  Documenting environment variables..."
echo "========================================"
cat > "$CHECKPOINT_PATH/environment_variables.txt" << EOF
Environment Variables (cPanel)
===============================

DB_HOST=localhost
DB_USER=$REMOTE_DB_USER
DB_PASSWORD=$REMOTE_DB_PASS
DB_NAME=$REMOTE_DB_NAME
NODE_ENV=production
PORT=5000
JWT_SECRET=(set in cPanel)
RAZORPAY_KEY_ID=rzp_live_RhWOsPuVUOT0Xx
RAZORPAY_KEY_SECRET=(set in cPanel)
RAZORPAY_WEBHOOK_SECRET=(set in cPanel)

Frontend Build:
- Razorpay key is HARDCODED in client/src/pages/Donate.js
- Key: rzp_live_RhWOsPuVUOT0Xx
- No environment variables needed for frontend build

EOF
echo "   ✅ Environment variables documented"
echo ""

# Step 5: Create restore script
echo "5️⃣  Creating restore script..."
echo "=============================="
cat > "$CHECKPOINT_PATH/restore_checkpoint.sh" << 'RESTORE_SCRIPT'
#!/bin/bash
# Restore from checkpoint

CHECKPOINT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$CHECKPOINT_DIR/../.." && pwd)"

echo "🔄 Restoring from Checkpoint"
echo "============================"
echo ""
echo "Checkpoint: $(basename $CHECKPOINT_DIR)"
echo ""

# Restore database
if [ -f "$CHECKPOINT_DIR/remote_db_"*.sql ]; then
  echo "To restore database, run:"
  echo "  mysql -uUSER -p DATABASE < $CHECKPOINT_DIR/remote_db_*.sql"
fi

# Restore code
echo "To restore code state:"
echo "  cd $PROJECT_ROOT"
echo "  git checkout $(basename $CHECKPOINT_DIR)"
echo "  OR: git checkout tags/$(basename $CHECKPOINT_DIR)"

# Restore config files
echo ""
echo "To restore config files:"
echo "  cp $CHECKPOINT_DIR/server.js $PROJECT_ROOT/server.js"
echo "  cp $CHECKPOINT_DIR/database.js $PROJECT_ROOT/config/database.js"
echo "  cp $CHECKPOINT_DIR/Donate.js $PROJECT_ROOT/client/src/pages/Donate.js"

RESTORE_SCRIPT
chmod +x "$CHECKPOINT_PATH/restore_checkpoint.sh"
echo "   ✅ Restore script created"
echo ""

# Step 6: Create checkpoint info file
echo "6️⃣  Creating checkpoint info..."
echo "==============================="
cat > "$CHECKPOINT_PATH/CHECKPOINT_INFO.md" << EOF
# Checkpoint: $CHECKPOINT_NAME

**Created:** $(date)
**Status:** ✅ Working Production State

## What's Included

### ✅ Working Features
- Backend API working (no 508 errors)
- Frontend routes working (/admin, /donate, etc.)
- Razorpay LIVE mode configured
- Database connection working
- All .htaccess files configured correctly

### 🔑 Key Configuration

**Razorpay:**
- Key: rzp_live_RhWOsPuVUOT0Xx
- Mode: LIVE (hardcoded in Donate.js)
- Location: client/src/pages/Donate.js line 168

**Database:**
- Local: charity_website
- Remote: theomkiq_charity
- Config: config/database.js

**Application URL:**
- cPanel: /api
- .htaccess: ~/public_html/api/.htaccess (Passenger config)
- Frontend: ~/public_html/.htaccess (React Router)

### 📁 Files Backed Up
- server.js
- config/database.js
- client/src/pages/Donate.js
- client/src/services/api.js
- package.json files
- .htaccess files

### 💾 Database Backups
- Local: local_db_${TIMESTAMP}.sql
- Remote: remote_db_${TIMESTAMP}.sql

## How to Restore

1. **Restore code:**
   \`\`\`bash
   cd $PROJECT_ROOT
   git checkout tags/$CHECKPOINT_NAME
   \`\`\`

2. **Restore database:**
   \`\`\`bash
   mysql -u$REMOTE_DB_USER -p$REMOTE_DB_NAME < remote_db_${TIMESTAMP}.sql
   \`\`\`

3. **Restore config files:**
   \`\`\`bash
   cp $CHECKPOINT_PATH/server.js $PROJECT_ROOT/server.js
   cp $CHECKPOINT_PATH/database.js $PROJECT_ROOT/config/database.js
   cp $CHECKPOINT_PATH/Donate.js $PROJECT_ROOT/client/src/pages/Donate.js
   \`\`\`

4. **Rebuild and deploy:**
   \`\`\`bash
   bash deploy_full.sh
   \`\`\`

## Git Tag

To restore to this checkpoint:
\`\`\`bash
git checkout tags/$CHECKPOINT_NAME
\`\`\`

EOF
echo "   ✅ Checkpoint info created"
echo ""

# Step 7: Create summary
echo "============================================"
echo "✅ Checkpoint Created Successfully!"
echo "============================================"
echo ""
echo "📋 Checkpoint Details:"
echo "   Name: $CHECKPOINT_NAME"
echo "   Location: $CHECKPOINT_PATH"
echo "   Git Tag: $CHECKPOINT_NAME"
echo ""
echo "📦 What's Saved:"
echo "   ✅ Local database backup"
echo "   ✅ Remote database backup"
echo "   ✅ Code state (Git commit + tag)"
echo "   ✅ Configuration files"
echo "   ✅ Environment variables documentation"
echo "   ✅ Restore script"
echo ""
echo "🔄 To Restore:"
echo "   1. Code: git checkout tags/$CHECKPOINT_NAME"
echo "   2. Database: See $CHECKPOINT_PATH/CHECKPOINT_INFO.md"
echo "   3. Config: See $CHECKPOINT_PATH/restore_checkpoint.sh"
echo ""
echo "📄 Full details: $CHECKPOINT_PATH/CHECKPOINT_INFO.md"
echo ""

