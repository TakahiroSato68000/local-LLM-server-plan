# 02_OSのインストール編

## OS仕様

| 項目 | 内容 |
|------|------|
| OS種別 | **Linux**（確定） |
| ディストリビューション | **Ubuntu 24.04 LTS**（確定） |
| カーネル | **OEM カーネル**（`linux-oem-24.04`） |

## インストール後の初期設定（Ubuntu）

```bash
# 0. OEM カーネルのインストール（新世代AMD APU向け最新カーネル）
sudo apt install linux-oem-24.04
sudo reboot

# カーネルバージョン確認
uname -r
```

## 起動用USBメモリ作成（Windows 11）

### 用意するもの

- USBメモリ（8GB以上、推奨16GB以上）
- Ubuntu 24.04 LTS のISOファイル
- Rufus

### 手順

1. Ubuntu公式サイトからISOファイルをダウンロードする
2. Rufusを起動し、対象USBメモリとISOを選択する
3. パーティション構成を `GPT`、ターゲットシステムを `UEFI` に設定する
4. 書き込みを開始する（USB内データは消去される）
5. インストール対象PCでUSBブートしてUbuntuをインストールする
