# よくある質問 (FAQ) / Frequently Asked Questions

## 🚀 セットアップ関連

### Q1: DockerとPodmanの違いは何ですか？

**A:** PodmanはDockerの代替となるコンテナ管理ツールです。主な違い：

- **Podman**: デーモンレス、rootless実行可能、Kubernetesとの互換性が高い
- **Docker**: 最も一般的、豊富なドキュメント、Docker Hubとの統合

このプロジェクトはどちらでも動作します。コマンドは `docker` を `podman` に、`docker-compose` を `podman-compose` に置き換えるだけです。

### Q2: どの環境を使うべきですか？

**A:** 用途に応じて選択してください：

- **開発環境**: 日常的な開発作業、機能テスト
- **サンドボックス**: 実験的な機能、破壊的テスト（開発環境と並行実行可能）
- **本番環境**: 実際のサービス提供、Azure PostgreSQLと連携

### Q3: システム要件は？

**A:** 推奨スペック：

- **CPU**: 2コア以上
- **メモリ**: 4GB以上（8GB推奨）
- **ディスク**: 10GB以上の空き容量
- **OS**: Linux, macOS, Windows 10/11

## 🔧 設定関連

### Q4: SECRET_KEYはどうやって生成しますか？

**A:** 以下のコマンドで生成できます：

```bash
# Python
python -c "import secrets; print(secrets.token_urlsafe(32))"

# OpenSSL
openssl rand -base64 32

# bashの場合
head -c 32 /dev/urandom | base64
```

生成したキーを`.env`ファイルの`SUPERSET_SECRET_KEY`に設定してください。

### Q5: Azure PostgreSQLへの接続方法は？

**A:** `.env.production`で以下を設定：

```bash
DATABASE_USER=your_user@your_server
DATABASE_PASSWORD=your_password
DATABASE_HOST=your-server.postgres.database.azure.com
DATABASE_PORT=5432
DATABASE_DB=superset
```

また、Azure側でファイアウォール設定が必要です：
1. Azureポータルでデータベースを選択
2. 「接続のセキュリティ」を選択
3. クライアントIPアドレスを追加

### Q6: ポート番号を変更したい

**A:** `.env`ファイルで変更できます：

```bash
SUPERSET_PORT=9000  # デフォルトは8088
REDIS_PORT=6380     # デフォルトは6379
POSTGRES_PORT=5433  # デフォルトは5432
```

変更後、コンテナを再起動してください。

### Q7: サンプルデータは必要ですか？

**A:** 環境により異なります：

- **開発/サンドボックス**: `SUPERSET_LOAD_EXAMPLES=yes` (推奨)
- **本番環境**: `SUPERSET_LOAD_EXAMPLES=no` (推奨)

`.env`ファイルで制御できます。

## 🌐 言語・UI関連

### Q8: 日本語が表示されない

**A:** 以下を確認してください：

1. ブラウザのキャッシュをクリア
2. 右上のユーザーメニュー → Settings → Language → 日本語を選択
3. 一度ログアウトして再ログイン
4. それでも解決しない場合、コンテナを再ビルド：
   ```bash
   docker compose build --no-cache superset
   ```

### Q9: 他の言語を追加できますか？

**A:** はい。`superset/superset_config.py`の`LANGUAGES`辞書に追加：

```python
LANGUAGES = {
    'ja': {'flag': 'jp', 'name': '日本語'},
    'en': {'flag': 'us', 'name': 'English'},
    'zh': {'flag': 'cn', 'name': '中文'},  # 中国語を追加
}
```

変更後、コンテナを再ビルドしてください。

## 🔐 セキュリティ関連

### Q10: デフォルトの管理者パスワードを変更したい

**A:** 2つの方法があります：

**方法1: 起動前に.envファイルで設定**
```bash
ADMIN_PASSWORD=your_secure_password
```

**方法2: 起動後にWebUIで変更**
1. 管理者でログイン
2. 右上のユーザーメニュー → Settings
3. Passwordセクションでパスワード変更

### Q11: HTTPSを有効にしたい

**A:** 本番環境ではリバースプロキシ（Nginx等）の使用を推奨：

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8088;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Q12: ユーザー登録を無効にしたい

**A:** `superset/superset_config.py`で設定：

```python
AUTH_USER_REGISTRATION = False  # 自己登録を無効化
```

## 💾 データ管理関連

### Q13: データをバックアップしたい

**A:** 各コンポーネントごとにバックアップ：

**PostgreSQL:**
```bash
docker exec superset-postgres-dev pg_dump -U superset superset > backup_$(date +%Y%m%d).sql
```

**Superset Home:**
```bash
docker run --rm -v superset-home-dev:/data -v $(pwd):/backup alpine tar czf /backup/superset-home_$(date +%Y%m%d).tar.gz /data
```

**Redis (オプション):**
```bash
docker exec superset-redis-dev redis-cli SAVE
docker cp superset-redis-dev:/data/dump.rdb ./redis_backup_$(date +%Y%m%d).rdb
```

### Q14: バックアップからリストアしたい

**A:** 

**PostgreSQL:**
```bash
# データベースを空にする
docker exec superset-postgres-dev psql -U superset -d superset -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# バックアップをリストア
docker exec -i superset-postgres-dev psql -U superset superset < backup_20240101.sql
```

### Q15: 環境を完全にリセットしたい

**A:** 以下のコマンドで全データを削除：

```bash
# 開発環境の場合
docker compose --env-file .env.development down -v

# 再度起動すると初期状態から開始
docker compose --env-file .env.development --profile with-local-db up -d
```

**⚠️ 警告**: このコマンドは全データを削除します。必要なデータは事前にバックアップしてください。

## 🔄 運用関連

### Q16: 複数環境を同時に実行できますか？

**A:** はい、開発とサンドボックスは同時実行可能です：

```bash
# 両方を起動
docker compose --env-file .env.development --profile with-local-db up -d
docker compose --env-file .env.sandbox --profile with-local-db up -d

# アクセス
# 開発: http://localhost:8088
# サンドボックス: http://localhost:8089
```

本番環境と開発環境は同じポート（8088）を使用するため、同時実行はできません。

### Q17: ログはどこで確認できますか？

**A:** 複数の方法があります：

```bash
# リアルタイムログ
docker compose --env-file .env.development logs -f

# 特定のサービスのみ
docker compose --env-file .env.development logs -f superset

# 最新100行
docker compose --env-file .env.development logs --tail=100 superset

# コンテナ内のログファイル
docker exec superset-dev ls -la /app/superset_home/logs/
```

### Q18: コンテナを更新したい

**A:** 最新のイメージに更新：

```bash
# イメージを最新化
docker compose --env-file .env.development pull

# コンテナを再作成
docker compose --env-file .env.development --profile with-local-db up -d
```

Supersetの設定を変更した場合は再ビルドが必要：

```bash
docker compose --env-file .env.development build --no-cache superset
docker compose --env-file .env.development --profile with-local-db up -d
```

## 🐛 トラブルシューティング

### Q19: "port is already allocated" エラーが出る

**A:** ポートが既に使用されています：

```bash
# 使用中のポートを確認（Linux/Mac）
sudo lsof -i :8088

# 使用中のポートを確認（Windows）
netstat -ano | findstr :8088

# 別のポート番号を使用するか、使用中のプロセスを停止
```

または`.env`ファイルでポート番号を変更してください。

### Q20: "Database connection timeout" エラー

**A:** データベース接続の問題です：

1. PostgreSQLが起動しているか確認
   ```bash
   docker ps | grep postgres
   ```

2. ログを確認
   ```bash
   docker compose logs postgres
   ```

3. 接続情報が正しいか`.env`ファイルを確認

4. Azure PostgreSQLの場合、ファイアウォール設定を確認

### Q21: コンテナが起動しない

**A:** 以下を順番に確認：

1. ログを確認
   ```bash
   docker compose logs superset
   ```

2. ディスク容量を確認
   ```bash
   docker system df
   ```

3. 古いコンテナとイメージを削除
   ```bash
   docker system prune -a
   ```

4. クリーンビルド
   ```bash
   docker compose build --no-cache
   ```

### Q22: メモリ不足エラーが出る

**A:** Docker/Podmanに割り当てるメモリを増やす：

**Docker Desktop:**
- Settings → Resources → Memory → 4GB以上に設定

**Podman:**
- Podmanはシステムメモリを直接使用するため、システムの空きメモリを確認

### Q23: パフォーマンスが遅い

**A:** 以下を試してください：

1. リソース設定を確認（CPU/メモリ）
2. Redisキャッシュが正常に動作しているか確認
   ```bash
   docker exec superset-redis-dev redis-cli ping
   ```
3. データベースインデックスの最適化
4. 不要なコンテナを停止

## 📚 その他

### Q24: Windowsで動作しますか？

**A:** はい。Docker Desktop for Windowsまたは WSL2 + Docker/Podman で動作します。

推奨環境：
- Windows 10/11 Pro/Enterprise
- WSL2有効化
- Docker Desktop最新版

### Q25: 商用利用は可能ですか？

**A:** はい。ただし各ソフトウェアのライセンスに従ってください：

- **Apache Superset**: Apache License 2.0（商用利用可能）
- **Redis**: BSD 3-Clause License（商用利用可能）
- **PostgreSQL**: PostgreSQL License（商用利用可能）

### Q26: サポートはありますか？

**A:** 
- **コミュニティサポート**: GitHubのIssuesセクション
- **公式ドキュメント**: https://superset.apache.org/docs/intro
- **Slack**: Apache Supersetコミュニティ

### Q27: カスタマイズは可能ですか？

**A:** はい。以下のファイルを編集してカスタマイズできます：

- `superset/superset_config.py`: Superset設定
- `superset/Dockerfile`: イメージのカスタマイズ
- `docker-compose.yml`: サービス構成
- `.env.*`: 環境変数

変更後は再ビルドが必要です。

### Q28: プラグインを追加したい

**A:** `superset/Dockerfile`に追加インストール手順を記述：

```dockerfile
USER root
RUN pip install superset-plugin-name
USER superset
```

その後、再ビルドしてください。

## 💡 ベストプラクティス

### Q29: 本番環境のセキュリティ対策は？

**A:** 以下を必ず実施してください：

1. ✅ 強力なSECRET_KEYを設定
2. ✅ デフォルトパスワードを変更
3. ✅ HTTPSを有効化（リバースプロキシ使用）
4. ✅ ファイアウォール設定
5. ✅ 定期的なバックアップ
6. ✅ ログ監視の実施
7. ✅ 定期的なセキュリティアップデート

### Q30: 定期メンテナンスは必要ですか？

**A:** 推奨メンテナンス項目：

**毎日:**
- ログの確認
- ヘルスチェック

**毎週:**
- バックアップの実行
- ディスク使用量の確認

**毎月:**
- セキュリティアップデートの適用
- 不要データの削除
- パフォーマンスレビュー

```bash
# ヘルスチェックスクリプト例
curl -f http://localhost:8088/health || echo "Superset is down!"
```

---

## ❓ 質問がある場合

上記で解決しない問題がある場合：

1. [SETUP.md](SETUP.md)のトラブルシューティングセクションを確認
2. [TESTING.md](TESTING.md)でテスト方法を確認
3. [ARCHITECTURE.md](ARCHITECTURE.md)でシステム構成を理解
4. GitHubのIssuesで質問を投稿
