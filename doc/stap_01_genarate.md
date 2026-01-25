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

Phoenixプロジェクトに後からSQLiteを追加する場合は、`stap_03_databace.md`を参照してください。

詳細な手順は、`stap_02_link.md`でfirmwareとuiのリンクを完了した後に行うことを推奨します。

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

プロジェクトが生成されたら、次は以下の順序で進めてください：

1. **プロジェクト間のリンク**: `stap_02_link.md`を参照して、firmwareとuiをリンクします
2. **SQLiteデータベースの追加**（オプション）: `stap_03_databace.md`を参照して、SQLiteを追加します

## 参考

- [Poncho Projects](https://embedded-elixir.com/post/2017-05-19-poncho-projects/)
- [Nerves Project Structure](https://hexdocs.pm/nerves/getting-started.html)
