#!/bin/bash
# worktreeをHammerspoonにデプロイ（上書きコピー）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
HS_DIR="$HOME/.hammerspoon"

usage() {
    echo "Usage: $0 [worktree-path | main]"
    echo "  worktree-path: .worktrees/配下のパス（例: feat, chore/readme）"
    echo "  main: メインブランチに戻す"
    echo "  (引数なし): 現在のディレクトリから自動検出"
    echo ""
    echo "Available worktrees:"
    ls -1 "$REPO_ROOT/.worktrees/" 2>/dev/null || echo "  (none)"
}

# 引数がない場合は現在のディレクトリから自動検出
if [ -z "$1" ]; then
    CURRENT_DIR="$(pwd)"

    if [[ "$CURRENT_DIR" == "$REPO_ROOT/.worktrees/"* ]]; then
        # .worktrees/ 配下にいる場合はそのまま使用
        TARGET_PATH="$CURRENT_DIR"
    elif [[ "$CURRENT_DIR" == "$REPO_ROOT" || "$CURRENT_DIR" == "$REPO_ROOT/"* && "$CURRENT_DIR" != "$REPO_ROOT/.worktrees/"* ]]; then
        # main リポジトリ内にいる場合
        TARGET_PATH="$REPO_ROOT"
    else
        echo "Error: Cannot detect worktree from current directory"
        echo "Current directory: $CURRENT_DIR"
        usage
        exit 1
    fi
else
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
fi

# init.lua が存在するか確認
if [ ! -f "$TARGET_PATH/init.lua" ]; then
    echo "Error: init.lua not found in $TARGET_PATH"
    echo "Hint: You may need to specify a subpath (e.g., chore/readme instead of chore)"
    exit 1
fi

# 既存のシンボリックリンクがあれば削除
if [ -L "$HS_DIR" ]; then
    rm "$HS_DIR"
fi

# ディレクトリがなければ作成
mkdir -p "$HS_DIR"

# 必要なファイルのみコピー（テスト・開発用ファイルは除外）
rsync -a --delete \
    --include='init.lua' \
    --include='config.lua' \
    --include='assets/***' \
    --include='core/***' \
    --include='plugins/***' \
    --include='utils/***' \
    --exclude='*' \
    "$TARGET_PATH/" "$HS_DIR/"

echo "Deployed: $TARGET_PATH -> $HS_DIR"

# Hammerspoon をリロード
if command -v hs &> /dev/null; then
    if hs -c "hs.reload()" 2>/dev/null; then
        echo "Hammerspoon reloaded"
    else
        echo "Note: Could not reload Hammerspoon (not running or IPC not loaded)"
    fi
else
    echo "Run 'hs.reload()' in Hammerspoon console to apply changes"
fi
