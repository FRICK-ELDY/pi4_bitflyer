# Step 01: Nervesファームウェアプロジェクトの生成

Raspberry Pi 4用のNervesファームウェアプロジェクトを生成します。

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

### 3. 依存関係の取得

```bash
cd firmware
export MIX_TARGET=rpi4
mix deps.get
```

## 生成後のディレクトリ構造

```
pi4_bitflyer/
└── firmware/
    ├── config/
    │   ├── config.exs
    │   ├── host.exs
    │   └── target.exs
    ├── lib/
    │   └── firmware/
    │       ├── application.ex
    │       └── ...
    ├── mix.exs
    └── ...
```

## 次のステップ

ファームウェアプロジェクトが生成されたら、次は`step_02_wifi.md`を参照して、WiFi設定を行います。

## 参考

- [Nerves Project Structure](https://hexdocs.pm/nerves/getting-started.html)
- [Nerves Supported Targets](https://hexdocs.pm/nerves/supported-targets.html)
