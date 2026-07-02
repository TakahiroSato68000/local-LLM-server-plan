# ローカルLLMサーバ 構築ガイド（Ollama使用）

## 概要

Ollamaを使って最小構成のローカルLLMサーバを構築する手順です。  
Linux上で動作します。

---

## 採用ハードウェア・OS

### ミニPC本体

| 項目 | 内容 |
|------|------|
| 機種 | MINISFORUM AI X1 Pro 370 ベアボーンキット |
| フォームファクタ | ミニPC（ベアボーン） |
| APU | AMD Ryzen AI 9 HX 370（Zen 5、12コア/24スレッド） |
| 内蔵GPU | AMD Radeon 890M（RDNA 3.5、iGPU） |
| NPU | AMD XDNA 2（最大50 TOPS） |
| メモリスロット | DDR5 SO-DIMM × 2（最大96 GB対応） |
| ストレージスロット | M.2 NVMe PCIe 4.0 × 2 |

> **備考：ベアボーンキットのため、メモリ・ストレージは別途用意が必要です。**

### OS

| 項目 | 内容 |
|------|------|
| OS種別 | **Linux**（確定） |
| ディストリビューション | **未定** |

---

## 必要な環境（参考スペック）

| 項目 | 最小 | 推奨 |
|------|------|------|
| GPU/APU | iGPU または NVIDIA 8GB VRAM | AMD/NVIDIA 16GB VRAM以上 |
| RAM | 16 GB | 32 GB以上 |
| ストレージ | 50 GB (SSD) | 200 GB以上 (SSD) |
| OS | Linux（Ubuntu 20.04+等） | Ubuntu 22.04 LTS / Fedora 40+ |

> MINISFORUM AI X1 Pro 370 はAMD Radeon 890M（iGPU）を搭載。  
> ROCm対応により、CPU/APUを活用したLLM推論が可能です（llama.cpp / Ollama対応）。

---

## セットアップ手順

### Linux

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
