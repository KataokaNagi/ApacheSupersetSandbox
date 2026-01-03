# Windows ユーザー向けセットアップガイド / Windows Setup Guide

## 🪟 Windows環境での Apache Superset セットアップ

このガイドは、WindowsでApache Supersetを実行するための詳細な手順を説明します。

## 前提条件

以下のいずれかがインストールされている必要があります：

### オプション1: Docker Desktop (推奨)

1. **Windows 10/11 Pro または Enterprise** (Hyper-V対応)
2. **WSL2** 有効化
3. **Docker Desktop for Windows** 最新版

#### Docker Desktopのインストール

1. [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)をダウンロード
2. インストーラーを実行
3. WSL2バックエンドを有効化（推奨）
4. Docker Desktopを起動

#### 動作確認

PowerShellまたはコマンドプロンプトで実行：

```powershell
# Dockerが動作しているか確認
docker --version

# Docker Composeが利用可能か確認
docker compose version
```

### オプション2: Podman Desktop

1. **Windows 10/11** (Home、Pro、Enterprise)
2. **WSL2** 推奨（必須ではない）
3. **Podman Desktop for Windows** 最新版
4. **Python 3.x** (podman-compose用)

#### Podman Desktopのインストール

1. [Podman Desktop](https://podman-desktop.io/)をダウンロード
2. インストーラーを実行
3. Podman Desktopを起動
4. podman-composeをインストール：

```powershell
# Pythonがインストールされている場合
pip install podman-compose

# または pipx を使用
pipx install podman-compose
```

#### 動作確認

```powershell
# Podmanが動作しているか確認
podman --version

# podman-composeが利用可能か確認
podman-compose --version
```

## 🚀 クイックスタート

### 方法1: quickstart.bat を使用（最も簡単）

1. リポジトリをクローン：
```cmd
git clone https://github.com/KataokaNagi/ApacheSupersetSandbox.git
cd ApacheSupersetSandbox
```

2. `quickstart.bat` をダブルクリック、またはコマンドプロンプトから実行：
```cmd
quickstart.bat
```

3. 環境を選択（1: 開発環境、2: サンドボックス、3: 本番環境）

4. ブラウザで http://localhost:8088 にアクセス（サンドボックスは8089）

### 方法2: 手動実行

#### Docker Desktop使用時

```cmd
cd ApacheSupersetSandbox
copy .env.development .env
docker compose --env-file .env.development --profile with-local-db up -d
```

#### Podman Desktop使用時

```cmd
cd ApacheSupersetSandbox
copy .env.development .env
podman-compose --env-file .env.development --profile with-local-db up -d
```

## ⚠️ よくある問題と解決方法

### 問題1: quickstart.batがすぐに閉じてしまう

**原因:** Composeコマンドが見つからない、またはDocker/Podmanが起動していない

**解決方法:**

1. Docker Desktop または Podman Desktop が起動しているか確認
2. コマンドが利用可能か確認：
   ```cmd
   docker compose version
   ```
   または
   ```cmd
   podman-compose --version
   ```

3. Podman使用時で podman-compose が無い場合：
   ```cmd
   pip install podman-compose
   ```

4. それでも解決しない場合、quickstart.bat を編集して最初の行を：
   ```batch
   @echo off
   ```
   から
   ```batch
   @echo on
   ```
   に変更してエラーメッセージを確認

### 問題2: コンテナが起動していない

**確認方法（Docker Desktop）:**

```powershell
# コンテナの状態を確認
docker ps -a

# ログを確認
docker compose --env-file .env.development logs superset
```

**確認方法（Podman Desktop）:**

```powershell
# コンテナの状態を確認
podman ps -a

# ログを確認
podman-compose --env-file .env.development logs superset
```

**よくある原因:**

1. **ポートが既に使用されている**
   - 他のアプリケーションが8088ポートを使用している
   - 解決: `.env`ファイルで`SUPERSET_PORT=8090`などに変更

2. **WSL2が正しく設定されていない**
   - Docker Desktop設定で「Use the WSL 2 based engine」を有効化

3. **リソース不足**
   - Docker Desktop設定でメモリを4GB以上に設定

### 問題3: "permission denied" エラー

**解決方法:**
- コマンドプロンプトまたはPowerShellを**管理者として実行**
- Docker Desktopが完全に起動するまで待つ

### 問題4: ネットワークエラー

**Docker Desktop使用時:**
1. Docker Desktop → Settings → Resources → Network
2. DNSサーバーを手動設定（8.8.8.8など）

**Podman Desktop使用時:**
1. WSL2内でPodmanを実行することを推奨
2. Windows Defenderのファイアウォール設定を確認

## 📝 環境の管理

### コンテナの停止

```cmd
docker compose --env-file .env.development down
```

または

```cmd
podman-compose --env-file .env.development down
```

### データの完全削除（ボリュームも削除）

```cmd
docker compose --env-file .env.development down -v
```

### ログの確認

```cmd
docker compose --env-file .env.development logs -f superset
```

### コンテナの再構築

```cmd
docker compose --env-file .env.development build --no-cache superset
docker compose --env-file .env.development --profile with-local-db up -d
```

## 🔧 WSL2での実行（推奨）

WSL2環境内で実行すると、Linuxコマンドが使用できパフォーマンスも向上します：

1. WSL2を有効化：
   ```powershell
   wsl --install
   ```

2. Ubuntuなどのディストリビューションをインストール

3. WSL2内で作業：
   ```bash
   cd /mnt/c/Users/YourName/ApacheSupersetSandbox
   ./quickstart.sh
   ```

## 🌐 アクセス方法

セットアップ完了後：

- **開発環境:** http://localhost:8088
- **サンドボックス環境:** http://localhost:8089
- **ユーザー名:** admin
- **パスワード:** admin（開発/サンドボックス）

## 📚 追加リソース

- [Docker Desktop ドキュメント](https://docs.docker.com/desktop/windows/)
- [Podman Desktop ドキュメント](https://podman-desktop.io/docs)
- [WSL2 セットアップガイド](https://learn.microsoft.com/ja-jp/windows/wsl/install)
- [SETUP.md](SETUP.md) - 詳細なセットアップガイド
- [FAQ.md](FAQ.md) - よくある質問

## 🆘 サポート

問題が解決しない場合：

1. [FAQ.md](FAQ.md) のトラブルシューティングセクションを確認
2. GitHubのIssuesで質問を投稿
3. Docker/Podmanのログファイルを確認
4. Docker Desktop / Podman Desktopを再起動

---

**注意:** Windowsでは、ファイルパスの区切り文字が異なるため、スクリプト内では適切に処理されています。
