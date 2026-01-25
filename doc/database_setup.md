# データベース設定ガイド（初心者向け）

## SQLiteデータベースとは？

SQLiteは、ファイルベースの軽量データベースです。MySQLやPostgreSQLのようなサーバーを起動する必要がなく、1つのファイル（`.db`）にすべてのデータが保存されます。

## データベースの作成手順

### 1. データベースファイルの作成

```bash
cd ui
mix ecto.create
```

このコマンドで、`ui_dev.db`ファイルがプロジェクトルート（`pi4_bitflyer/`）に作成されます。

### 2. マイグレーションの実行

```bash
mix ecto.migrate
```

このコマンドで、データベースにテーブルなどの構造（スキーマ）が作成されます。

### 3. 設定の確認

データベースの設定は`ui/config/dev.exs`にあります：

```elixir
config :ui, Ui.Repo,
  database: Path.expand("../ui_dev.db", __DIR__),
  pool_size: 5
```

- `database:` - データベースファイルのパス
- `pool_size:` - 同時接続数（デフォルトは5）

## よくあるエラーと対処法

### エラー1: `database is locked`

**原因**: 既に別のプロセスがデータベースを使用している

**対処法**:
```bash
# 実行中のPhoenixサーバーを停止
pkill -f "mix phx.server"

# または、Ctrl+Cで停止してから再起動
```

### エラー2: `You must provide a :database`

**原因**: データベース設定が正しく読み込まれていない

**対処法**:
1. `ui/config/dev.exs`の設定を確認
2. `mix clean`を実行して再コンパイル
3. `mix deps.get`で依存関係を再取得

### エラー3: データベースファイルが見つからない

**原因**: データベースファイルが作成されていない

**対処法**:
```bash
cd ui
mix ecto.create
```

## データベースの場所

- **開発環境**: `pi4_bitflyer/ui_dev.db`（プロジェクトルート）
- **テスト環境**: `pi4_bitflyer/ui_test.db`（プロジェクトルート）
- **本番環境（Nerves）**: `/data/ui.db`（Raspberry Pi上）

## データベースの確認方法

### データベースファイルの存在確認

```bash
ls -la ui_dev.db
```

### データベースの中身を確認（SQLiteコマンド）

```bash
sqlite3 ui_dev.db
.tables  # テーブル一覧を表示
.schema  # スキーマを表示
.quit    # 終了
```

## トラブルシューティング

### データベースをリセットしたい場合

```bash
cd ui
mix ecto.drop    # データベースを削除
mix ecto.create  # データベースを再作成
mix ecto.migrate # マイグレーションを実行
```

### 設定を確認したい場合

```bash
cd ui
iex -S mix
iex> Application.get_env(:ui, Ui.Repo)
```

これでデータベース設定が表示されます。
