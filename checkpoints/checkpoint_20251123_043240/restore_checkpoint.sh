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

