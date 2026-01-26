# Step 05: SQLiteデータベースの追加

Phoenixプロジェクトに後からSQLiteデータベースを追加する手順です。

## 前提条件

- `step_03_gen_ui.md`の手順で、`--no-ecto`オプションでPhoenixプロジェクトを作成済みであること
- `step_04_link.md`の手順で、firmwareとuiのリンクが完了していること（Nerves環境で使用する場合）

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

### 5. 設定ファイルへのecto_reposの追加

`ui/config/config.exs`に、以下の設定を追加します：

```elixir
config :ui,
  generators: [timestamp_type: :utc_datetime],
  ecto_repos: [Ui.Repo]
```

### 6. 環境別の設定

SQLiteはデフォルトでは同時接続に制限があるため、**WALモード（Write-Ahead Logging）**を有効化します。WALモードにより、複数の読み取り接続と1つの書き込み接続を同時に使用できるようになり、頻繁な書き込み操作（例：複数の仮想通貨の時価更新）に適しています。

#### 6.1. 開発環境（dev）の設定

`ui/config/dev.exs`に、以下の設定を追加します：

```elixir
# SQLite database configuration for development
# WAL mode enables multiple readers and one writer simultaneously
config :ui, Ui.Repo,
  database: Path.expand("../priv/repo/ui_dev.db", __DIR__),
  pool_size: 3,
  journal_mode: :wal
```

#### 6.2. テスト環境（test）の設定

`ui/config/test.exs`に、以下の設定を追加します：

```elixir
# SQLite database configuration for test
# WAL mode enables multiple readers and one writer simultaneously
config :ui, Ui.Repo,
  database: Path.expand("../priv/repo/ui_test.db", __DIR__),
  pool_size: 2,
  journal_mode: :wal
```

#### 6.3. 本番環境（prod/Nerves）の設定

`ui/config/prod.exs`に、以下の設定を追加します：

```elixir
# SQLite database configuration for production
# WAL mode enables multiple readers and one writer simultaneously
# This is important for BitFlyer auto-trading where multiple cryptocurrency prices are written frequently
config :ui, Ui.Repo,
  database: "/data/ui.db",
  pool_size: 3,
  journal_mode: :wal
```

**重要**: Nerves環境では、ルートファイルシステムは読み取り専用のため、書き込み可能な`/data`ディレクトリにデータベースを配置します。

また、`firmware/config/target.exs`にも同様の設定を追加します：

```elixir
# SQLite database configuration for Nerves
# /data is a writable directory in Nerves (root filesystem is read-only)
# WAL mode enables multiple readers and one writer simultaneously
# This is important for BitFlyer auto-trading where multiple cryptocurrency prices are written frequently
config :ui, Ui.Repo,
  database: "/data/ui.db",
  pool_size: 3,
  journal_mode: :wal
```

### 7. データベースの作成

#### 開発環境

```bash
cd ui
mix ecto.create
```

これで、`ui/priv/repo/ui_dev.db`にSQLiteデータベースが作成されます。WALモードは自動的に有効化されます。

#### テスト環境

```bash
cd ui
MIX_ENV=test mix ecto.create
```

### 8. マイグレーションの作成と実行

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
PRAGMA journal_mode;  # WALモードが有効か確認（"wal"と表示されればOK）
.quit    # 終了
```

## トラブルシューティング

### エラー1: `database is locked`

**原因**: 既に別のプロセスがデータベースを使用している、またはWALモードが有効化されていない

**対処法**:
```bash
# 実行中のPhoenixサーバーを停止
pkill -f "mix phx.server"

# または、Ctrl+Cで停止してから再起動

# WALモードが有効化されているか確認
sqlite3 ui/priv/repo/ui_dev.db "PRAGMA journal_mode;"
# "wal"と表示されればOK。表示されない場合は、データベースを再作成
cd ui
mix ecto.drop
mix ecto.create
```

**注意**: WALモードを有効化することで、複数の読み取り接続と1つの書き込み接続を同時に使用できるようになり、`database is locked`エラーが発生しにくくなります。

### エラー2: `You must provide a :database`

**原因**: データベース設定が正しく読み込まれていない、または`config/config.exs`に`ecto_repos`が設定されていない

**対処法**:
1. `ui/config/config.exs`に`ecto_repos: [Ui.Repo]`が設定されているか確認
2. `ui/config/dev.exs`、`ui/config/test.exs`、`ui/config/prod.exs`の設定を確認
3. `mix clean`を実行して再コンパイル
4. `mix deps.get`で依存関係を再取得

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
ssh root@nerves.local

# /dataディレクトリの確認
ls -la /data

# 必要に応じてディレクトリを作成（通常は自動的に作成される）
mkdir -p /data
```

### エラー5: WALモードが有効化されていない

**原因**: 既存のデータベースがWALモードで作成されていない

**対処法**:
```bash
# データベースを再作成（WALモードが自動的に有効化される）
cd ui
mix ecto.drop
mix ecto.create

# WALモードが有効化されているか確認
sqlite3 ui/priv/repo/ui_dev.db "PRAGMA journal_mode;"
# "wal"と表示されればOK
```

**注意**: `journal_mode: :wal`を設定ファイルに追加した後は、既存のデータベースを再作成する必要があります。新しいデータベースは自動的にWALモードで作成されます。

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

## WALモードについて

### WALモードのメリット

- **複数の読み取り接続と1つの書き込み接続を同時に使用可能**: 書き込み中でも読み取りがブロックされない
- **パフォーマンスの向上**: 頻繁な書き込み操作（例：複数の仮想通貨の時価更新）に適している
- **同時接続の改善**: `pool_size`を1より大きく設定できる（推奨: 2-3）

### pool_sizeの設定

- **開発環境**: `pool_size: 3` - 開発時の読み取り/書き込みの両方を考慮
- **テスト環境**: `pool_size: 2` - テスト時の同時接続を考慮
- **本番環境**: `pool_size: 3` - 複数の仮想通貨の時価を頻繁に書き込むBitFlyer自動売買に適した設定

### WALモードの確認方法

```bash
sqlite3 ui/priv/repo/ui_dev.db "PRAGMA journal_mode;"
```

`wal`と表示されれば、WALモードが有効化されています。

## 参考

- [Ecto SQLite3 Adapter](https://hexdocs.pm/ecto_sqlite3/)
- [Phoenix Contexts](https://hexdocs.pm/phoenix/contexts.html)
- [Ecto Migrations](https://hexdocs.pm/ecto_sql/Ecto.Migration.html)
- [SQLite WAL Mode](https://www.sqlite.org/wal.html)
