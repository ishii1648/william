#!/bin/bash
# worktreeをHammerspoonにデプロイ（シンボリックリンクを切り替え）

REPO_ROOT="/Users/sho/src/github.com/my-rancher"
HS_LINK="$HOME/.hammerspoon"

usage() {
    echo "Usage: $0 [worktree-name | main]"
    echo "  worktree-name: .worktrees/配下のworktree名"
    echo "  main: メインブランチに戻す"
    echo ""
    echo "Available worktrees:"
    ls -1 "$REPO_ROOT/.worktrees/" 2>/dev/null || echo "  (none)"
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

TARGET="$1"

if [ "$TARGET" = "main" ]; then
    TARGET_PATH="$REPO_ROOT"
else
    TARGET_PATH="$REPO_ROOT/.worktrees/$TARGET"
    if [ ! -d "$TARGET_PATH" ]; then
        echo "Error: Worktree '$TARGET' not found at $TARGET_PATH"
        usage
        exit 1
    fi
fi

# シンボリックリンクを更新
rm "$HS_LINK"
ln -s "$TARGET_PATH" "$HS_LINK"

echo "Deployed: $TARGET_PATH"
echo "Run 'hs.reload()' in Hammerspoon console to apply changes"
