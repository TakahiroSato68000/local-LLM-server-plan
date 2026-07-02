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

### メモリ

| 項目 | 内容 |
|------|------|
| 型番 | CT2K32G56C46S5 |
| 製品名 | Crucial DDR5 5600 (PC5-44800) CL46 Unbuffered SODIMM 262pin |
| 容量 | 64 GB Kit（32 GB × 2） |
| 規格 | DDR5 SO-DIMM |
| 動作クロック | 5600 MHz |
| レイテンシ | CL46 |
| 状態 | **導入済み** |

### ストレージ

| 項目 | 内容 |
|------|------|
| 型番 | PGX4-020TA1 |
| 製品名 | ドスパラセレクト PGX4-020TA1 |
| 容量 | 2 TB |
| フォームファクタ | M.2 2280 |
| インターフェース | PCIe Gen4 NVMe |
| 状態 | **導入済み** |

> **備考：ベアボーンキットのため、ストレージは別途用意が必要です。**

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
> **本環境は64 GB DDR5を搭載しているため、70B級のモデルも4bit量子化で動作可能です。**

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

> **64 GB RAM搭載のため、70B級モデルも4bit量子化（Q4）で動作可能です。**  
> RAM使用量の目安はQ4量子化時の値です。

| モデル | パラメータ数 | RAM目安（Q4） | 備考 |
|--------|------------|---------------|------|
| llama3.2:3b | 3B | ~2 GB | 軽量・高速 |
| llama3.1:8b | 8B | ~5 GB | バランス型・推奨 |
| mistral:7b | 7B | ~5 GB | 高品質・汎用 |
| gemma2:9b | 9B | ~6 GB | Google製・高性能 |
| qwen2.5:7b | 7B | ~5 GB | 多言語対応（日本語強化） |
| phi4:14b | 14B | ~9 GB | Microsoft製・高効率 |
| deepseek-r1:14b | 14B | ~9 GB | 推論特化 |
| codestral:22b | 22B | ~14 GB | コード生成特化 |
| mixtral:8x7b | 47B相当 | ~26 GB | MoE・高性能 |
| llama3.1:70b | 70B | ~40 GB | 最高品質（要大容量RAM） |
| qwen2.5:72b | 72B | ~41 GB | 多言語最高品質（要大容量RAM） |
| deepseek-r1:32b | 32B | ~20 GB | 推論特化・大規模 |

モデル一覧は https://ollama.com/library で確認できます。
