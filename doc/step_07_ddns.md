# Step 07: Cloudflare DDNS 常駐

Nerves 起動時に `Firmware.DdnsUpdater` を常駐させ、グローバル IPv4 が変わったときだけ Cloudflare の A レコードを更新します。

## 前提条件

- Cloudflare にゾーン（例: `frick-eldy.com`）があること
- 更新対象の A レコード（例: `vpn.frick-eldy.com`）が作成済みであること
- API Token を発行済みであること（権限: Zone Read + DNS Edit、対象ゾーン限定）

## 手順

### 1. `.env` に DDNS 設定を追加

`firmware/.env` に以下を追加します（トークンの実値は Git やチャットに貼らないこと）:

```bash
CF_API_TOKEN=YOUR_CLOUDFLARE_API_TOKEN
CF_ZONE_NAME=frick-eldy.com
CF_RECORD_NAME=vpn.frick-eldy.com
DDNS_INTERVAL_SEC=300
```

`firmware/.env.example` にも同じキーの雛形があります。

### 2. Cloudflare 側の確認

- レコードタイプ: **A**
- 名前: `vpn`（FQDN では `vpn.frick-eldy.com`）
- Proxy: VPN 用途なら通常 **DNS only（灰色雲）**
- Token 権限: **Zone → Zone → Read** / **Zone → DNS → Edit**

### 3. ファームウェアをビルド・アップロード

WiFi 設定と同様、`.env` の値は**ビルド時**にファームウェアへ取り込まれます。

```bash
./bin/firmware_build_dev.sh
./bin/firmware_upload_dev.sh
```

本番なら `firmware_build_prod.sh` / `firmware_upload_prod.sh` を使います。

### 4. 動作確認（デバイス上）

起動数秒後に最初の同期が走ります。IEx から手動実行もできます:

```elixir
Firmware.DdnsUpdater.sync_now()
```

ログ例:

```text
DDNS updater started for vpn.frick-eldy.com (every 300s)
DDNS updated: vpn.frick-eldy.com (unknown) -> x.x.x.x
```

IP が変わっていない場合は debug ログのみです。

## 仕組み

1. 起動 5 秒後に初回チェック（ネットワーク待ち）
2. `https://api.ipify.org` でグローバル IPv4 を取得
3. Cloudflare API で対象 A レコードを取得
4. 現在 IP と異なれば `PUT` で更新
5. `DDNS_INTERVAL_SEC` 間隔で繰り返す

## 注意

- トークンを再発行したら、`.env` を更新して**ファームウェアを再ビルド／再アップロード**してください
- トークンがログに出ないよう、エラーメッセージでは詳細を制限しています
- ポートフォリオサイト用ホスト名を別途使う場合は、DDNS 対象（`vpn...`）とサイト用レコードを分けて管理してください
