# pi4 bitflyer

Raspberry Pi 4 + Nerves + Phoenix + SQLite3 でBitflyerの自動売買システムを構築するプロジェクトです。

## 使用バージョン

- **Erlang/OTP**: 28.1.1
- **Elixir**: 1.19.0
- **Phoenix**: 1.8.3
- **Nerves**: 1.12.0
- **nerves_system_rpi4**: 1.33.0

## セットアップ

### 必要なツール

```bash
# Phoenixのインストール
mix archive.install hex phx_new

# Nervesのインストール
mix archive.install hex nerves_bootstrap
```

### プロジェクトの初期化

```bash
# 1. Phoenixアプリ (UI) の作成
mix phx.new ui --database sqlite3

# 2. Nervesアプリ (Firmware) の作成
mix nerves.new firmware --target rpi4
```

## ビルドと書き込み

### 1. 依存関係のインストール

```bash
# UIアプリの依存関係をインストール
cd ui
mix deps.get
mix assets.setup
cd ..

# Firmwareアプリの依存関係をインストール
cd firmware
mix deps.get
cd ..
```

### 2. アセットのビルド

```bash
cd ui
mix assets.deploy
cd ..
```

### 3. ファームウェアのビルド

```bash
cd firmware
export MIX_TARGET=rpi4
mix firmware
```

### 4. SDカードへの書き込み

SDカードを接続してから：

```bash
# SDカードのデバイス名を確認（例: /dev/disk2）
mix firmware.burn
```

または、特定のデバイスを指定する場合：

```bash
mix firmware.burn -d /dev/disk2
```

### 5. 起動と確認

1. SDカードをRaspberry Pi 4に挿入
2. 電源を投入
3. 起動後、同じネットワーク内のPCから以下のURLでアクセス：
   - `http://nerves.local:4000` または
   - `http://<ラズパイのIPアドレス>:4000`

## 開発

### ホストマシンでの開発

```bash
cd ui
mix phx.server
```

ブラウザで `http://localhost:4000` にアクセス

### SSH接続（Nervesデバイス）

```bash
ssh nerves.local
# または
ssh nerves-<4桁のシリアル番号>.local
```

## 構成

- `firmware/` - Nervesファームウェアプロジェクト
- `ui/` - Phoenix Webアプリケーション

PhoenixアプリはNerves起動時に自動的に起動し、ポート4000でWebサーバーが動作します。
