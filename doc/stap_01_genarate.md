# Step 01: プロジェクトの生成

Ponchoプロジェクト構造では、**独立した2つのプロジェクト**を並べて配置します。

## プロジェクト構造

```
pi4_bitflyer/
├── firmware/    # Nervesファームウェアプロジェクト
└── ui/          # Phoenix Webアプリケーション（独立プロジェクト）
```

## 手順

### 1. プロジェクトルートディレクトリの作成

```bash
mkdir pi4_bitflyer
cd pi4_bitflyer
```

### 2. Nervesファームウェアプロジェクトの生成

```bash
mix nerves.new firmware --target rpi4
```

これにより、`firmware/`ディレクトリが作成され、Raspberry Pi 4用のNervesプロジェクトが生成されます。

**重要**: `--target rpi4`オプションでRaspberry Pi 4用のシステムを指定します。

### 3. Phoenix UIプロジェクトの生成（データベースなし）

```bash
mix phx.new ui --no-ecto
```

これにより、`ui/`ディレクトリが作成され、データベースなしのPhoenixプロジェクトが生成されます。

**注意**: 
- `ui/`は`firmware/`と同じ階層に配置します
- `ui/`は独立したプロジェクトとして生成されます（Umbrellaプロジェクトではありません）
- データベースは後から追加します（次のステップ参照）

### 4. SQLiteの追加（オプション）

Phoenixプロジェクトに後からSQLiteを追加する場合は、以下の手順を実行します：

#### 4.1. 依存関係の追加

`ui/mix.exs`の`deps/0`関数に、以下の依存関係を追加します：

```elixir
defp deps do
  [
    # ... 既存の依存関係 ...
    {:ecto_sqlite3, "~> 0.11.0"}
  ]
end
```

#### 4.2. 依存関係の取得

```bash
cd ui
mix deps.get
```

#### 4.3. Ectoの設定

`ui/config/config.exs`に、以下の設定を追加します：

```elixir
config :ui, Ui.Repo,
  database: Path.expand("../priv/repo/ui.db", __DIR__),
  pool_size: 5
```

#### 4.4. Repoモジュールの作成

`ui/lib/ui/repo.ex`を作成します：

```elixir
defmodule Ui.Repo do
  use Ecto.Repo,
    otp_app: :ui,
    adapter: Ecto.Adapters.SQLite3
end
```

#### 4.5. Applicationスーパーバイザーへの追加

`ui/lib/ui/application.ex`の`children`リストに、Repoを追加します：

```elixir
defmodule Ui.Application do
  # ... 既存のコード ...
  
  @impl true
  def start(_type, _args) do
    children = [
      # Start the Repo
      Ui.Repo,
      # ... 既存のchildren ...
    ]
    
    # ... 既存のコード ...
  end
end
```

#### 4.6. データベースの作成

```bash
cd ui
mix ecto.create
```

これで、SQLiteデータベースが`ui/priv/repo/ui.db`に作成されます。

## 生成後のディレクトリ構造

```
pi4_bitflyer/
├── firmware/
│   ├── config/
│   ├── lib/
│   ├── mix.exs
│   └── ...
└── ui/
    ├── assets/
    ├── config/
    ├── lib/
    ├── mix.exs
    └── ...
```

## 次のステップ

プロジェクトが生成されたら、次は`stap_02_link.md`を参照して、firmwareとuiをリンクします。

## 参考

- [Poncho Projects](https://embedded-elixir.com/post/2017-05-19-poncho-projects/)
- [Nerves Project Structure](https://hexdocs.pm/nerves/getting-started.html)
