# Step 03: Phoenix UIプロジェクトの生成

Phoenix Webアプリケーションプロジェクトを生成します。

## 前提条件

- `step_01_gen_firmware.md`の手順で、Nervesファームウェアプロジェクトが生成済みであること

## 手順

### 1. Phoenix UIプロジェクトの生成（データベースなし）

```bash
# プロジェクトルートディレクトリにいることを確認
cd pi4_bitflyer

# Phoenixプロジェクトを生成（データベースなし）
mix phx.new ui --no-ecto
```

これにより、`ui/`ディレクトリが作成され、データベースなしのPhoenixプロジェクトが生成されます。

**注意**: 
- `ui/`は`firmware/`と同じ階層に配置します
- `ui/`は独立したプロジェクトとして生成されます（Umbrellaプロジェクトではありません）
- データベースは後から追加します（`step_05_databese.md`を参照）

### 2. 依存関係の取得

```bash
cd ui
mix deps.get
```

### 3. 動作確認（オプション）

開発環境でPhoenixサーバーが起動するか確認します：

```bash
cd ui
mix phx.server
```

ブラウザで `http://localhost:4000` にアクセスして、Phoenixのデフォルトページが表示されることを確認します。

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
    │   ├── ui/
    │   │   ├── application.ex
    │   │   └── ...
    │   └── ui_web/
    │       ├── controllers/
    │       ├── components/
    │       └── ...
    ├── mix.exs
    └── ...
```

## 次のステップ

Phoenix UIプロジェクトが生成されたら、次は`step_04_link.md`を参照して、firmwareとuiをリンクします。

## 参考

- [Phoenix Installation](https://hexdocs.pm/phoenix/installation.html)
- [Phoenix Guides](https://hexdocs.pm/phoenix/overview.html)
