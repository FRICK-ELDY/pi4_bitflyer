# Step 06: Firmwareのビルドとアップロード

firmwareのdev環境とprod環境でのビルドとアップロード方法を説明します。

## 前提条件

- `step_04_link.md`の手順で、firmwareとuiのリンクが完了していること
- `step_05_databese.md`の手順で、SQLiteデータベースが設定されていること
- Raspberry Pi 4が同じネットワークに接続されていること（アップロードする場合）

## ビルドスクリプト

プロジェクトルートに以下のスクリプトが用意されています：

### 開発環境（dev）

- **ビルド**: `./bin/firmware_build_dev.sh`
- **アップロード**: `./bin/firmware_upload_dev.sh [device_hostname]`

### 本番環境（prod）

- **ビルド**: `./bin/firmware_build_prod.sh`
- **アップロード**: `./bin/firmware_upload_prod.sh [device_hostname]`

## 手順

### 1. 開発環境（dev）でのビルドとアップロード

#### 1.1. ファームウェアのビルド

```bash
# プロジェクトルートから実行
./bin/firmware_build_dev.sh
```

このスクリプトは以下を実行します：
1. UIアセットのビルド（`mix assets.deploy`）
2. 開発環境でのファームウェアのビルド（`MIX_ENV=dev mix firmware`）

**出力**: `firmware/_build/rpi4_dev/nerves/images/firmware.fw`

#### 1.2. ファームウェアのアップロード

```bash
# デフォルトのホスト名（nerves.local）でアップロード
./bin/firmware_upload_dev.sh

# または、カスタムホスト名を指定
./bin/firmware_upload_dev.sh nerves-1234.local
```

このスクリプトは以下を実行します：
1. ファームウェアファイルの存在確認
2. SSH経由でファームウェアをアップロード（`mix upload`）
3. デバイスの自動再起動

### 2. 本番環境（prod）でのビルドとアップロード

#### 2.1. ファームウェアのビルド

```bash
# プロジェクトルートから実行
./bin/firmware_build_prod.sh
```

このスクリプトは以下を実行します：
1. UIアセットのビルド（`MIX_ENV=prod mix assets.deploy`）
2. 本番環境でのファームウェアのビルド（`MIX_ENV=prod mix firmware`）

**出力**: `firmware/_build/rpi4_prod/nerves/images/firmware.fw`

**注意**: 本番環境のビルドは最適化されるため、開発環境より時間がかかる場合があります。

#### 2.2. ファームウェアのアップロード

```bash
# デフォルトのホスト名（nerves.local）でアップロード
./bin/firmware_upload_prod.sh

# または、カスタムホスト名を指定
./bin/firmware_upload_prod.sh nerves-1234.local
```

## 手動でのビルドとアップロード

スクリプトを使用せずに手動で実行する場合：

### 開発環境

```bash
# 1. UIアセットのビルド
cd ui
mix assets.deploy
cd ..

# 2. ファームウェアのビルド
cd firmware
export MIX_TARGET=rpi4
export MIX_ENV=dev
mix firmware

# 3. アップロード
mix upload nerves.local
```

### 本番環境

```bash
# 1. UIアセットのビルド
cd ui
MIX_ENV=prod mix assets.deploy
cd ..

# 2. ファームウェアのビルド
cd firmware
export MIX_TARGET=rpi4
export MIX_ENV=prod
mix firmware

# 3. アップロード
mix upload nerves.local
```

## 環境の違い

### 開発環境（dev）

- **デバッグ情報**: 含まれる
- **最適化**: 最小限
- **ビルド時間**: 短い
- **ファイルサイズ**: 大きい
- **用途**: 開発・デバッグ

### 本番環境（prod）

- **デバッグ情報**: 削除される
- **最適化**: 最大限
- **ビルド時間**: 長い
- **ファイルサイズ**: 小さい
- **用途**: 本番運用

## トラブルシューティング

### エラー: `Can't continue due to errors on dependencies`

**対処法**: 依存関係を取得してください。

```bash
cd firmware
export MIX_TARGET=rpi4
mix deps.get
```

### エラー: `Firmware file not found`

**対処法**: 先にファームウェアをビルドしてください。

```bash
./bin/firmware_build_dev.sh  # または firmware_build_prod.sh
```

### エラー: `mix upload`が接続できない

**原因**: デバイスがネットワークに接続されていない、またはホスト名が間違っている

**対処法**:
1. デバイスが起動しているか確認
2. 同じネットワークに接続されているか確認
3. ホスト名を確認（`ping nerves.local`）
4. SSH接続を確認（`ssh root@nerves.local`）

### エラー: `WIFI_SSID`や`WIFI_PASSWORD`が設定されていない

**対処法**: `firmware/.env`ファイルにWiFi設定を追加してください。

```bash
cd firmware
cat > .env <<EOF
WIFI_SSID=your_wifi_ssid
WIFI_PASSWORD=your_wifi_password
EOF
```

## 動作確認

### 1. ビルドの確認

ビルドが成功すると、以下のファイルが生成されます：

- **開発環境**: `firmware/_build/rpi4_dev/nerves/images/firmware.fw`
- **本番環境**: `firmware/_build/rpi4_prod/nerves/images/firmware.fw`

### 2. アップロードの確認

アップロードが成功すると：
- デバイスが自動的に再起動します
- 再起動後、`http://nerves.local:4000`でアクセスできます

### 3. 環境の確認

SSH接続して環境を確認：

```bash
ssh root@nerves.local

# IExプロンプトで以下を実行
Application.get_env(:ui, Ui.Repo)
# 本番環境では、database: "/data/ui.db" が設定されていることを確認
```

## 次のステップ

ファームウェアのビルドとアップロードが完了したら、次はBitFlyer APIとの連携を実装します。

## 参考

- [Nerves Firmware](https://hexdocs.pm/nerves/getting-started.html)
- [Nerves Upload](https://hexdocs.pm/nerves/uploading-firmware.html)
- [Nerves Environments](https://hexdocs.pm/nerves/advanced-configuration.html#environments)
