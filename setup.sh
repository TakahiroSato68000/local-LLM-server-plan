#!/usr/bin/env bash
# ローカルLLMサーバ セットアップスクリプト（Ubuntu / Linux）
# 使い方: chmod +x setup.sh && ./setup.sh

set -euo pipefail

MODEL="${1:-llama3}"
OLLAMA_HOST="${OLLAMA_HOST:-0.0.0.0}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"

echo "=== ローカルLLMサーバ セットアップ ==="
echo "モデル: $MODEL"
echo "ホスト: $OLLAMA_HOST:$OLLAMA_PORT"
echo ""

# --- 1. Ollamaのインストール ---
if command -v ollama &>/dev/null; then
    echo "[1/3] Ollama は既にインストールされています: $(ollama --version)"
else
    echo "[1/3] Ollamaをインストールしています..."
    curl -fsSL https://ollama.com/install.sh | sh
    echo "      Ollamaのインストールが完了しました。"
fi

# --- 2. サーバを一時起動してモデルを取得 ---
echo "[2/3] モデル '$MODEL' を取得しています..."

# バックグラウンドでサーバを起動（モデル取得のため）
OLLAMA_HOST="${OLLAMA_HOST}:${OLLAMA_PORT}" ollama serve &>/dev/null &
OLLAMA_PID=$!
sleep 3  # サーバ起動を待つ

ollama pull "$MODEL"

# 一時サーバを停止
kill "$OLLAMA_PID" 2>/dev/null || true
wait "$OLLAMA_PID" 2>/dev/null || true

echo "      モデルの取得が完了しました。"

# --- 3. 動作確認 ---
echo "[3/3] 動作確認中..."
OLLAMA_HOST="${OLLAMA_HOST}:${OLLAMA_PORT}" ollama serve &>/dev/null &
OLLAMA_PID=$!
sleep 3

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:${OLLAMA_PORT}/api/tags" || echo "000")

kill "$OLLAMA_PID" 2>/dev/null || true
wait "$OLLAMA_PID" 2>/dev/null || true

if [ "$HTTP_CODE" = "200" ]; then
    echo "      APIサーバの動作を確認しました。"
else
    echo "      警告: APIサーバへの接続確認に失敗しました (HTTP $HTTP_CODE)"
fi

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "サーバ起動コマンド:"
echo "  ollama serve"
echo ""
echo "systemdサービスとして登録する場合:"
echo "  sudo cp systemd/ollama.service /etc/systemd/system/"
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl enable --now ollama"
echo ""
echo "APIエンドポイント:"
echo "  http://localhost:${OLLAMA_PORT}/v1/chat/completions"
