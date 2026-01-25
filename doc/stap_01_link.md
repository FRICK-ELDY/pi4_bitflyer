# Step 01: プロジェクト間のリンク

Ponchoプロジェクト構造では、`firmware`プロジェクトが`ui`プロジェクトを依存関係として参照します。

## 手順

### 1. firmware/mix.exs に ui を依存関係として追加

`firmware/mix.exs`の`deps/0`関数に、以下の行を追加します：

```elixir
defp deps do
  [
    # ... 既存の依存関係 ...
    {:nerves_system_rpi4, "~> 1.33", runtime: false, targets: :rpi4},
    # UIアプリケーションを依存関係として追加
    {:ui, path: "../ui", targets: @all_targets, env: Mix.env()}
  ]
end
```

**重要ポイント**:
- `path: "../ui"` - 相対パスでuiプロジェクトを参照
- `targets: @all_targets` - すべてのターゲットで有効
- `env: Mix.env()` - 現在のMix環境を使用

### 2. firmware/lib/firmware/application.ex で ui アプリを起動

`firmware/lib/firmware/application.ex`の`target_children/0`関数を修正します：

```elixir
else
  defp target_children() do
    [
      # Start the UI application (Phoenix) on Nerves targets
      {Ui.Application, []}
    ]
  end
end
```

これにより、Nervesターゲット（Raspberry Pi 4）で起動時にPhoenix UIアプリが自動的に起動します。

### 3. firmware/config/target.exs で Phoenix 設定を追加

`firmware/config/target.exs`の最後に、Phoenix UI用の設定を追加します：

```elixir
# Phoenix UI configuration for Nerves
config :ui, UiWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  server: true,
  secret_key_base: "nGY5pp5/24WZpEomazdLekUr3KKSpn6tI/rBBb95E2INqkEuBG/jq4qZHVHJzA0P",
  check_origin: false

# SQLite database configuration for Nerves
# /data is a writable directory in Nerves (root filesystem is read-only)
config :ui, Ui.Repo,
  database: "/data/ui.db",
  pool_size: 5

# Disable code reloading in production
config :ui, UiWeb.Endpoint,
  code_reloader: false

# Logger configuration
config :logger, level: :info
```

**設定の説明**:
- `http: [ip: {0, 0, 0, 0}, port: 4000]` - すべてのインターフェースでポート4000をリッスン
- `server: true` - Phoenixサーバーを起動
- `secret_key_base` - セッション暗号化用のキー（本番環境では環境変数から取得推奨）
- `database: "/data/ui.db"` - Nervesの書き込み可能ディレクトリ`/data`にSQLiteデータベースを配置
- `code_reloader: false` - 本番環境ではコードリロードを無効化

### 4. 依存関係の取得

設定が完了したら、依存関係を取得します：

```bash
cd firmware
export MIX_TARGET=rpi4
mix deps.get
```

これにより、`ui`プロジェクトが依存関係として取得されます。

## 動作確認

### UIアプリのアセットをビルド

```bash
cd ui
mix assets.deploy
cd ..
```

### ファームウェアのビルド

```bash
cd firmware
export MIX_TARGET=rpi4
mix firmware
```

ビルドが成功すれば、リンクは正常に完了しています。

## Ponchoプロジェクト構造の利点

1. **独立性**: `ui`と`firmware`は独立したプロジェクトとして管理可能
2. **柔軟性**: `ui`プロジェクトは単独で開発・テスト可能
3. **明確性**: Umbrellaプロジェクトのような複雑な設定が不要
4. **制御**: `firmware`から`ui`への依存関係を明示的に管理

## トラブルシューティング

### 依存関係が見つからない

```bash
# firmwareディレクトリから相対パスを確認
cd firmware
ls ../ui  # uiディレクトリが存在するか確認
```

### ビルドエラー

```bash
# クリーンビルドを試す
cd firmware
mix clean
mix deps.clean --all
mix deps.get
mix firmware
```

## 参考

- [Poncho Projects](https://embedded-elixir.com/post/2017-05-19-poncho-projects/)
- [Nerves User Interfaces](https://hexdocs.pm/nerves/user-interfaces.html)
