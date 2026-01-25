# Step 04: プロジェクト間のリンク

Ponchoプロジェクト構造では、`firmware`プロジェクトが`ui`プロジェクトを依存関係として参照します。

## 前提条件

- `step_01_gen_firmware.md`の手順で、Nervesファームウェアプロジェクトが生成済みであること
- `step_03_gen_ui.md`の手順で、Phoenix UIプロジェクトが生成済みであること

## 手順

### 1. firmware/mix.exs に ui を依存関係として追加

`firmware/mix.exs`の`deps/0`関数に、以下の行を追加します：

```elixir
defp deps do
  [
    # ... 既存の依存関係 ...
    {:nerves_system_rpi4, "~> 1.24", runtime: false, targets: :rpi4},
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

### 3. secret_key_baseの生成

Phoenixのセッション暗号化用のキーを生成します：

```bash
cd ui
mix phx.gen.secret
```

このコマンドで生成された文字列をコピーしておきます（次のステップで使用します）。

### 4. firmware/config/target.exs で Phoenix 設定を追加

`firmware/config/target.exs`の最後（`# Import target specific config.`のコメントの前）に、Phoenix UI用の設定を追加します：

```elixir
# Phoenix UI configuration for Nerves
config :ui, UiWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  server: true,
  secret_key_base: "ここに生成したsecret_key_baseを貼り付け",
  check_origin: false,
  force_ssl: false

# Disable code reloading in production
config :ui, UiWeb.Endpoint,
  code_reloader: false

# Disable DNSCluster for Nerves (not needed in embedded environment)
config :ui, :dns_cluster_query, :ignore

# Logger configuration
config :logger, level: :info

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
```

**設定の説明**:
- `http: [ip: {0, 0, 0, 0}, port: 4000]` - すべてのインターフェースでポート4000をリッスン
- `server: true` - Phoenixサーバーを起動
- `secret_key_base` - ステップ3で生成したキーを貼り付け（セッション暗号化用）
- `force_ssl: false` - SSL強制を無効化（Nerves環境ではHTTPを使用）
- `code_reloader: false` - 本番環境ではコードリロードを無効化

**注意**: 
- `secret_key_base`は機密情報なので、本番環境では環境変数から取得することを推奨します
- SQLiteを使用する場合は、`step_05_databese.md`の手順を完了してから、SQLite設定を追加してください

### 5. 依存関係の取得

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

# 開発用（デフォルト）
mix firmware

# または本番用（最適化）
# export MIX_ENV=prod
# mix firmware
```

**MIX_ENVの違い**:
- `MIX_ENV=dev`（デフォルト）: 開発用、デバッグ情報あり、ビルドが速い
- `MIX_ENV=prod`: 本番用、最適化済み、デバッグ情報削除、ビルドが遅い可能性

ビルドが成功すれば、リンクは正常に完了しています。

## 起動後の確認

SDカードをRaspberry Pi 4に挿入して起動後、以下でPhoenixにアクセスできます：

```bash
# mDNS経由
http://nerves.local:4000

# またはIPアドレス直接指定
http://<ラズパイのIPアドレス>:4000
```

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

### Phoenixが起動しない

1. `firmware/lib/firmware/application.ex`で`{Ui.Application, []}`が追加されているか確認
2. `firmware/config/target.exs`でPhoenix設定が追加されているか確認
3. SSH接続してログを確認: `ssh root@nerves.local` → `RingLogger.attach`

#### エラー: `Plug.Cowboy`が見つからない

**症状**:
- SSH接続時に`UiWeb.Endpoint is not running`と表示される
- IExで`Application.ensure_all_started(:ui)`を実行すると、以下のエラーが発生：
  ```
  ** (UndefinedFunctionError) function Plug.Cowboy.child_spec/1 is undefined (module Plug.Cowboy is not available)
  ```

**原因**:
Phoenix 1.8.3はデフォルトで`Plug.Cowboy`を使用しますが、依存関係に`plug_cowboy`が含まれていない場合に発生します。

**解決方法**:

1. `ui/mix.exs`の`deps/0`関数に`plug_cowboy`を追加：

```elixir
defp deps do
  [
    # ... 既存の依存関係 ...
    {:bandit, "~> 1.5"},
    {:plug_cowboy, "~> 2.7"}  # この行を追加
  ]
end
```

2. 依存関係を取得：

```bash
cd ui
mix deps.get
```

3. アセットをデプロイ：

```bash
cd ui
mix assets.deploy
```

4. firmwareディレクトリでも依存関係を取得：

```bash
cd firmware
export MIX_TARGET=rpi4
mix deps.get
```

5. ファームウェアを再ビルド：

```bash
cd firmware
export MIX_TARGET=rpi4
mix firmware
```

6. デバイスにアップロード：

```bash
cd firmware
export MIX_TARGET=rpi4
mix upload
```

アップロード後、デバイスが再起動し、Phoenixが正常に起動します。

## 次のステップ

プロジェクト間のリンクが完了したら、次は`step_05_databese.md`を参照して、SQLiteデータベースを追加します（オプション）。

## 参考

- [Poncho Projects](https://embedded-elixir.com/post/2017-05-19-poncho-projects/)
- [Nerves User Interfaces](https://hexdocs.pm/nerves/user-interfaces.html)
