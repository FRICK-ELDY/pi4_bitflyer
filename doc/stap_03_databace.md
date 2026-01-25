# Step 03: SQLiteデータベースの追加

Phoenixプロジェクトに後からSQLiteデータベースを追加する手順です。

## 前提条件

- `stap_01_genarate.md`の手順で、`--no-ecto`オプションでPhoenixプロジェクトを作成済みであること
- `stap_02_link.md`の手順で、firmwareとuiのリンクが完了していること（Nerves環境で使用する場合）

## 手順

### 1. 依存関係の追加

`ui/mix.exs`の`deps/0`関数に、以下の依存関係を追加します：

```elixir
defp deps do
  [
    # ... 既存の依存関係 ...
    {:ecto_sqlite3, "~> 0.11.0"}
  ]
end
```

### 2. 依存関係の取得

```bash
cd ui
mix deps.get
```

### 3. Repoモジュールの作成

`ui/lib/ui/repo.ex`を作成します：

```elixir
defmodule Ui.Repo do
  use Ecto.Repo,
    otp_app: :ui,
    adapter: Ecto.Adapters.SQLite3
end
```

### 4. Applicationスーパーバイザーへの追加

`ui/lib/ui/application.ex`の`children`リストに、Repoを追加します：

```elixir
defmodule Ui.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Repo
      Ui.Repo,
      # Start the Telemetry supervisor
      UiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ui.PubSub},
      # Start the Endpoint (http/https)
      UiWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Ui.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    UiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
```

**注意**: 既存の`children`リストに`Ui.Repo`を追加してください。上記は一例です。

### 5. 環境別の設定

#### 5.1. 開発環境（dev）の設定

`ui/config/dev.exs`に、以下の設定を追加します：

```elixir
config :ui, Ui.Repo,
  database: Path.expand("../priv/repo/ui_dev.db", __DIR__),
  pool_size: 5
```

#### 5.2. テスト環境（test）の設定

`ui/config/test.exs`に、以下の設定を追加します：

```elixir
config :ui, Ui.Repo,
  database: Path.expand("../priv/repo/ui_test.db", __DIR__),
  pool_size: 5
```

#### 5.3. 本番環境（prod/Nerves）の設定

`ui/config/prod.exs`に、以下の設定を追加します：

```elixir
config :ui, Ui.Repo,
  database: "/data/ui.db",
  pool_size: 5
```

**重要**: Nerves環境では、ルートファイルシステムは読み取り専用のため、書き込み可能な`/data`ディレクトリにデータベースを配置します。

また、`firmware/config/target.exs`にも同様の設定が必要です（`stap_02_link.md`を参照）。

### 6. データベースの作成

#### 開発環境

```bash
cd ui
mix ecto.create
```

これで、`ui/priv/repo/ui_dev.db`にSQLiteデータベースが作成されます。

#### テスト環境

```bash
cd ui
MIX_ENV=test mix ecto.create
```

### 7. マイグレーションの作成と実行

#### マイグレーションファイルの作成

```bash
cd ui
mix ecto.gen.migration create_example_table
```

これにより、`ui/priv/repo/migrations/`ディレクトリにマイグレーションファイルが作成されます。

#### マイグレーションファイルの編集

作成されたマイグレーションファイル（例：`ui/priv/repo/migrations/20240101000000_create_example_table.exs`）を編集します：

```elixir
defmodule Ui.Repo.Migrations.CreateExampleTable do
  use Ecto.Migration

  def change do
    create table(:examples) do
      add :name, :string
      add :description, :text
      add :created_at, :utc_datetime
    end
  end
end
```

#### マイグレーションの実行

```bash
cd ui
mix ecto.migrate
```

## データベースの場所

- **開発環境**: `ui/priv/repo/ui_dev.db`
- **テスト環境**: `ui/priv/repo/ui_test.db`
- **本番環境（Nerves）**: `/data/ui.db`（Raspberry Pi上）

## 動作確認

### 開発環境での確認

```bash
cd ui
mix phx.server
```

サーバーが正常に起動すれば、データベース設定は正しく動作しています。

### データベースファイルの確認

```bash
ls -la ui/priv/repo/*.db
```

データベースファイルが作成されていることを確認できます。

### SQLiteコマンドで中身を確認

```bash
sqlite3 ui/priv/repo/ui_dev.db
.tables  # テーブル一覧を表示
.schema  # スキーマを表示
.quit    # 終了
```

## トラブルシューティング

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
1. `ui/config/dev.exs`、`ui/config/test.exs`、`ui/config/prod.exs`の設定を確認
2. `mix clean`を実行して再コンパイル
3. `mix deps.get`で依存関係を再取得

### エラー3: `Repo is not started`

**原因**: ApplicationスーパーバイザーにRepoが追加されていない

**対処法**:
1. `ui/lib/ui/application.ex`を確認
2. `children`リストに`Ui.Repo`が含まれているか確認

### エラー4: Nerves環境でデータベースが作成できない

**原因**: `/data`ディレクトリが存在しない、または書き込み権限がない

**対処法**:
```bash
# NervesデバイスにSSH接続
ssh nerves.local

# /dataディレクトリの確認
ls -la /data

# 必要に応じてディレクトリを作成（通常は自動的に作成される）
mkdir -p /data
```

## データベースのリセット

開発中にデータベースをリセットしたい場合：

```bash
cd ui
mix ecto.drop    # データベースを削除
mix ecto.create  # データベースを再作成
mix ecto.migrate # マイグレーションを実行
```

## 次のステップ

SQLiteデータベースが追加されたら、次は以下の作業が可能です：

- マイグレーションの作成と実行
- スキーマの定義
- データの操作（CRUD操作）

詳細は、PhoenixとEctoの公式ドキュメントを参照してください。

## 参考

- [Ecto SQLite3 Adapter](https://hexdocs.pm/ecto_sqlite3/)
- [Phoenix Contexts](https://hexdocs.pm/phoenix/contexts.html)
- [Ecto Migrations](https://hexdocs.pm/ecto_sql/Ecto.Migration.html)
