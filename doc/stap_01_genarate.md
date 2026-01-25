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

### 3. Phoenix UIプロジェクトの生成

```bash
mix phx.new ui --database sqlite3
```

これにより、`ui/`ディレクトリが作成され、SQLite3を使用するPhoenixプロジェクトが生成されます。

**注意**: 
- `ui/`は`firmware/`と同じ階層に配置します
- `ui/`は独立したプロジェクトとして生成されます（Umbrellaプロジェクトではありません）

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

プロジェクトが生成されたら、次は`stap_01_link.md`を参照して、firmwareとuiをリンクします。

## 参考

- [Poncho Projects](https://embedded-elixir.com/post/2017-05-19-poncho-projects/)
- [Nerves Project Structure](https://hexdocs.pm/nerves/getting-started.html)
