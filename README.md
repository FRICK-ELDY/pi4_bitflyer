# pi4 bitflyer

Raspberry Pi 4 + Nerves + Phoenix + SQLite3 でBitflyerの自動売買システムを構築するプロジェクトです。

## プロジェクト構造

このプロジェクトは**Ponchoプロジェクト構造**を使用しています（[参考](https://embedded-elixir.com/post/2017-05-19-poncho-projects/)）。

```
pi4_bitflyer/
├── firmware/    # Nervesファームウェアプロジェクト
├── ui/          # Phoenix Webアプリケーション（独立プロジェクト）
└── doc/         # セットアップ手順ドキュメント
```

## 使用バージョン

- **Erlang/OTP**: 28.1.1
- **Elixir**: 1.19.0
- **Phoenix**: 1.8.3
- **Nerves**: 1.12.0
- **nerves_system_rpi4**: 1.33.0

## クイックスタート

詳細な手順は [`doc/`](./doc/) ディレクトリを参照してください。

1. **必要なツールのインストール**: [`doc/stap_00_assets.md`](./doc/stap_00_assets.md)
2. **プロジェクトの生成**: [`doc/stap_01_genarate.md`](./doc/stap_01_genarate.md)
3. **プロジェクト間のリンク**: [`doc/stap_02_link.md`](./doc/stap_02_link.md)
4. **SQLiteデータベースの追加**（オプション）: [`doc/stap_03_databace.md`](./doc/stap_03_databace.md)

## ビルドと書き込み

```bash
# 1. アセットのビルド
cd ui
mix assets.deploy
cd ..

# 2. ファームウェアのビルド
cd firmware
export MIX_TARGET=rpi4
# 開発用（デフォルト）
mix firmware
# または本番用（最適化）
# export MIX_ENV=prod
# mix firmware

# 3. SDカードへの書き込み
mix firmware.burn
```

**注意**: 
- `MIX_ENV=dev`（デフォルト）: 開発用、デバッグ情報あり、ビルドが速い
- `MIX_ENV=prod`: 本番用、最適化済み、デバッグ情報削除、ビルドが遅い可能性

## 起動と確認

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
