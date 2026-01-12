.PHONY: test lint ci deploy deploy-main help

WORKTREE ?=

# デフォルト: lint + test
all: lint test

# 静的解析
lint:
	luacheck .

# テスト実行
test:
	busted --verbose

# CI用（lint + test）
ci: lint test

# 個別テスト
test-fuzzy:
	busted spec/utils/fuzzy_spec.lua

test-plugin-loader:
	busted spec/core/plugin_loader_spec.lua

# worktreeデプロイ（引数なしで現在のディレクトリから自動検出）
deploy:
	@./scripts/deploy.sh $(WORKTREE)

# メインをデプロイ
deploy-main:
	@./scripts/deploy.sh main

# ヘルプ
help:
	@echo "Usage:"
	@echo "  make lint                        # luacheckを実行"
	@echo "  make test                        # テストを実行"
	@echo "  make ci                          # lint + test"
	@echo "  make deploy                      # 現在のディレクトリをデプロイ"
	@echo "  make deploy WORKTREE=<name>      # 指定worktreeをデプロイ"
	@echo "  make deploy-main                 # メインをデプロイ"
	@echo ""
	@echo "Available worktrees:"
	@ls -1 .worktrees/ 2>/dev/null || echo "  (none)"
