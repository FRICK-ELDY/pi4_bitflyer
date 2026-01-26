# 本番環境（prod）での動作確認方法

本番環境での動作確認を行う方法を説明します。

## 方法1: 環境変数で本番環境を起動（開発環境での確認）

開発環境で本番設定を確認する方法です。データベースパスを環境変数で上書きします。

### 1. SECRET_KEY_BASEの生成

```bash
cd ui
mix phx.gen.secret
```

生成されたシークレットキーをコピーします（例：`IWCckZtEdnyypwljk3Ghq7qXWL+OHsvOKVmR2/a2vxEOb/5cNbY9OJ0Z35q4H+Bo`）

### 2. データベースの作成（本番環境用）

開発環境で確認する場合は、`DATABASE_PATH`環境変数でデータベースパスを指定します。

```bash
cd ui
export SECRET_KEY_BASE="生成したシークレットキー"
export DATABASE_PATH="$(pwd)/priv/repo/ui_prod.db"
MIX_ENV=prod mix ecto.create
```

**注意**: 
- `DATABASE_PATH`環境変数を設定することで、本番環境の設定（`/data/ui.db`）を上書きできます
- 開発環境での確認用に、相対パスまたは絶対パスを指定できます

### 3. 環境変数を設定してサーバーを起動

```bash
cd ui
export SECRET_KEY_BASE="生成したシークレットキー"
export DATABASE_PATH="$(pwd)/priv/repo/ui_prod.db"
export PHX_HOST="localhost"
export PORT=4000
MIX_ENV=prod mix phx.server
```

または、1行で実行：

```bash
cd ui
SECRET_KEY_BASE="生成したシークレットキー" \
DATABASE_PATH="$(pwd)/priv/repo/ui_prod.db" \
PHX_HOST="localhost" \
PORT=4000 \
MIX_ENV=prod mix phx.server
```

### 4. アクセス確認

ブラウザで `http://localhost:4000` にアクセスして、正常に動作することを確認します。

### 5. データベースの確認

```bash
# 本番環境のデータベースが作成されているか確認
ls -la ui/priv/repo/ui_prod.db

# WALモードが有効か確認
sqlite3 ui/priv/repo/ui_prod.db "PRAGMA journal_mode;"
# "wal"と表示されればOK
```

## 方法2: リリースビルドで確認（本番環境に近い形）

より本番環境に近い形で確認する方法です。

### 1. アセットのデプロイ

```bash
cd ui
MIX_ENV=prod mix assets.deploy
```

### 2. リリースの作成

```bash
cd ui
MIX_ENV=prod mix release
```

### 3. リリースの起動

```bash
cd ui
export SECRET_KEY_BASE="生成したシークレットキー"
export PHX_SERVER=true
export PORT=4000
_build/prod/rel/ui/bin/ui start
```

### 4. アクセス確認

ブラウザで `http://localhost:4000` にアクセスして、正常に動作することを確認します。

### 5. リリースの停止

```bash
cd ui
_build/prod/rel/ui/bin/ui stop
```

## 注意事項

### データベースパスについて

- **開発環境での確認**: 本番環境の設定（`/data/ui.db`）は開発環境では使用できないため、一時的に開発環境のパス（`priv/repo/ui_prod.db`）が使用されます
- **Nerves環境での実際の本番環境**: Raspberry Pi上では`/data/ui.db`が使用されます

### 環境変数について

本番環境では以下の環境変数が必要です：

- `SECRET_KEY_BASE`: 必須（セッション暗号化用）
- `PHX_HOST`: オプション（デフォルト: "example.com"）
- `PORT`: オプション（デフォルト: 4000）
- `PHX_SERVER`: リリースビルドを使用する場合に必要

### SSLについて

`config/prod.exs`では`force_ssl`が有効ですが、`localhost`と`127.0.0.1`は除外されているため、開発環境での確認時はHTTPでアクセスできます。

### データベースパスについて

- **開発環境での確認**: `DATABASE_PATH`環境変数でデータベースパスを指定できます（例：`$(pwd)/priv/repo/ui_prod.db`）
- **Nerves環境での実際の本番環境**: `DATABASE_PATH`が設定されていない場合、デフォルトの`/data/ui.db`が使用されます

## トラブルシューティング

### エラー: `environment variable SECRET_KEY_BASE is missing`

**対処法**: `SECRET_KEY_BASE`環境変数を設定してください。

```bash
export SECRET_KEY_BASE="生成したシークレットキー"
```

### エラー: データベースが見つからない

**対処法**: 本番環境のデータベースを作成してください。開発環境で確認する場合は、`DATABASE_PATH`環境変数を設定してください。

```bash
cd ui
export SECRET_KEY_BASE="生成したシークレットキー"
export DATABASE_PATH="$(pwd)/priv/repo/ui_prod.db"
MIX_ENV=prod mix ecto.create
```

### エラー: `force_ssl`でリダイレクトされる

**対処法**: `localhost`または`127.0.0.1`でアクセスしてください。`config/prod.exs`でこれらのホストはSSL強制から除外されています。
