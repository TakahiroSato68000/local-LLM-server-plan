# ローカルLLMサーバ セットアップスクリプト（Windows）
# 使い方: PowerShellを管理者権限で実行し、.\setup_windows.ps1 を実行
#
# オプション:
#   -Model <モデル名>   取得するモデル（デフォルト: llama3）
#   -Port  <ポート番号> APIサーバのポート（デフォルト: 11434）

param(
    [string]$Model = "llama3",
    [int]$Port = 11434
)

$ErrorActionPreference = "Stop"

Write-Host "=== ローカルLLMサーバ セットアップ ===" -ForegroundColor Cyan
Write-Host "モデル: $Model"
Write-Host "ポート: $Port"
Write-Host ""

# --- 1. Ollamaのインストール ---
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue
if ($ollamaCmd) {
    Write-Host "[1/3] Ollama は既にインストールされています: $(ollama --version)" -ForegroundColor Green
} else {
    Write-Host "[1/3] Ollamaをダウンロード・インストールしています..."

    $installerUrl = "https://ollama.com/download/OllamaSetup.exe"
    $installerPath = "$env:TEMP\OllamaSetup.exe"

    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait

    # PATHを再読み込み
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")

    Write-Host "      Ollamaのインストールが完了しました。" -ForegroundColor Green
}

# --- 2. モデルの取得 ---
Write-Host "[2/3] モデル '$Model' を取得しています..."

$env:OLLAMA_HOST = "127.0.0.1:$Port"
$serverProcess = Start-Process ollama -ArgumentList "serve" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 5

try {
    ollama pull $Model
    Write-Host "      モデルの取得が完了しました。" -ForegroundColor Green
} finally {
    Stop-Process -Id $serverProcess.Id -Force -ErrorAction SilentlyContinue
}

# --- 3. 動作確認 ---
Write-Host "[3/3] 動作確認中..."

$serverProcess = Start-Process ollama -ArgumentList "serve" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 5

try {
    $response = Invoke-WebRequest -Uri "http://localhost:$Port/api/tags" `
                                  -UseBasicParsing -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "      APIサーバの動作を確認しました。" -ForegroundColor Green
    }
} catch {
    Write-Warning "APIサーバへの接続確認に失敗しました。手動で 'ollama serve' を実行してください。"
} finally {
    Stop-Process -Id $serverProcess.Id -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "=== セットアップ完了 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "サーバ起動コマンド:"
Write-Host "  ollama serve" -ForegroundColor Yellow
Write-Host ""
Write-Host "APIエンドポイント:"
Write-Host "  http://localhost:$Port/v1/chat/completions" -ForegroundColor Yellow
