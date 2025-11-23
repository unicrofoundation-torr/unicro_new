#!/bin/bash
# Restore from a checkpoint

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CHECKPOINT_DIR="$PROJECT_ROOT/checkpoints"

echo "🔄 Restore from Checkpoint"
echo "========================="
echo ""

# List available checkpoints
echo "Available checkpoints:"
echo "====================="
if [ -d "$CHECKPOINT_DIR" ]; then
  ls -1td "$CHECKPOINT_DIR"/checkpoint_* 2>/dev/null | while read checkpoint; do
    echo "   $(basename $checkpoint)"
  done
else
  echo "   No checkpoints found"
  exit 1
fi

echo ""
read -p "Enter checkpoint name to restore: " CHECKPOINT_NAME

CHECKPOINT_PATH="$CHECKPOINT_DIR/$CHECKPOINT_NAME"

if [ ! -d "$CHECKPOINT_PATH" ]; then
  echo "❌ Checkpoint not found: $CHECKPOINT_NAME"
  exit 1
fi

echo ""
echo "Restoring from: $CHECKPOINT_NAME"
echo ""

# Step 1: Restore code
echo "1️⃣  Restoring code from Git tag..."
cd "$PROJECT_ROOT"
if git tag -l | grep -q "^$CHECKPOINT_NAME$"; then
  git checkout tags/$CHECKPOINT_NAME
  echo "   ✅ Code restored"
else
  echo "   ⚠️  Git tag not found, restoring from files..."
  if [ -f "$CHECKPOINT_PATH/server.js" ]; then
    cp "$CHECKPOINT_PATH/server.js" "$PROJECT_ROOT/server.js"
  fi
  if [ -f "$CHECKPOINT_PATH/database.js" ]; then
    cp "$CHECKPOINT_PATH/database.js" "$PROJECT_ROOT/config/database.js"
  fi
  if [ -f "$CHECKPOINT_PATH/Donate.js" ]; then
    cp "$CHECKPOINT_PATH/Donate.js" "$PROJECT_ROOT/client/src/pages/Donate.js"
  fi
  echo "   ✅ Files restored"
fi
echo ""

# Step 2: Show database restore instructions
echo "2️⃣  Database restore..."
echo "======================"
if [ -f "$CHECKPOINT_PATH/remote_db_"*.sql ]; then
  DB_FILE=$(ls "$CHECKPOINT_PATH/remote_db_"*.sql | head -1)
  echo "   Remote database backup found: $(basename $DB_FILE)"
  echo "   To restore:"
  echo "     mysql -uUSER -p DATABASE < $DB_FILE"
else
  echo "   ⚠️  No database backup found"
fi
echo ""

# Step 3: Show next steps
echo "3️⃣  Next Steps..."
echo "================"
echo "   1. Review restored files"
echo "   2. Restore database if needed"
echo "   3. Rebuild frontend: cd client && npm run build"
echo "   4. Deploy: bash deploy_full.sh"
echo ""

echo "✅ Restore complete!"
echo "   See: $CHECKPOINT_PATH/CHECKPOINT_INFO.md for details"
echo ""

