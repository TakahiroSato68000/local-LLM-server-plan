# ローカルLLMサーバ 構築ガイド（Ollama使用）

## 概要

Ollamaを使って最小構成のローカルLLMサーバを構築する手順です。  
GPU搭載のUbuntuまたはWindowsマシン上で動作します。

---

## 必要な環境

| 項目 | 最小 | 推奨 |
|------|------|------|
| GPU | NVIDIA 8GB VRAM | NVIDIA 16GB VRAM以上 |
| RAM | 16 GB | 32 GB以上 |
| ストレージ | 50 GB (SSD) | 200 GB以上 (SSD) |
| OS | Ubuntu 20.04+ / Windows 10+ | Ubuntu 22.04 / Windows 11 |
| CUDA | 11.8+ | 12.x |

---

## セットアップ手順

### Ubuntu / Linux

```bash
# スクリプトに実行権限を付与して実行
chmod +x setup.sh
./setup.sh
```

手動で行う場合：

```bash
# 1. Ollamaをインストール
curl -fsSL https://ollama.com/install.sh | sh

# 2. モデルを取得（Llama 3 8B）
ollama pull llama3

# 3. APIサーバを起動（デフォルトポート: 11434）
ollama serve
```

### Windows

PowerShellを管理者権限で実行：

```powershell
.\setup_windows.ps1
```

または手動で：

1. https://ollama.com/download から `OllamaSetup.exe` をダウンロード・インストール
2. PowerShellで `ollama pull llama3` を実行
3. `ollama serve` でサーバ起動

---

## APIの使い方

サーバ起動後、`http://localhost:11434` でアクセス可能です。

### OpenAI互換エンドポイント

```
POST http://localhost:11434/v1/chat/completions
```

#### リクエスト例（curl）

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "messages": [
      {"role": "user", "content": "こんにちは！"}
    ]
  }'
```

#### Pythonクライアント

`example_client.py` を参照してください。

```bash
pip install openai
python example_client.py
```

---

## systemdサービス（Linux自動起動）

```bash
sudo cp systemd/ollama.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
```

---

## 主なOllamaコマンド

```bash
ollama list            # インストール済みモデル一覧
ollama pull llama3     # モデルをダウンロード
ollama rm llama3       # モデルを削除
ollama run llama3      # 対話モードで起動
ollama serve           # APIサーバ起動
```

---

## 利用可能なモデル例

| モデル | サイズ | VRAM目安 |
|--------|--------|----------|
| llama3 | 8B | 8 GB |
| llama3:70b | 70B | 40 GB |
| mistral | 7B | 8 GB |
| gemma2 | 9B | 10 GB |
| qwen2 | 7B | 8 GB |

モデル一覧は https://ollama.com/library で確認できます。
