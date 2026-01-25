# Step 02: WiFi設定

NervesデバイスをWiFi接続で使用するための設定を行います。

## 前提条件

- `step_01_gen_firmware.md`の手順で、Nervesファームウェアプロジェクトが生成済みであること

## 手順

### 1. .envファイルの作成

`firmware/.env.example`をコピーして、`firmware/.env`ファイルを作成します：

```bash
cd firmware
cp .env.example .env
```

### 2. WiFi設定の編集

`firmware/.env`ファイルを開き、実際のWiFi設定を記入します：

```bash
# WiFi設定
WIFI_SSID=YOUR_WIFI_SSID
WIFI_PASSWORD=YOUR_WIFI_PASSWORD
```

**重要**: 
- `YOUR_WIFI_SSID`を実際のWiFiネットワーク名（SSID）に置き換えてください
- `YOUR_WIFI_PASSWORD`を実際のWiFiパスワードに置き換えてください
- `.env`ファイルは`.gitignore`に追加されているため、Gitにはコミットされません

### 3. firmware/config/target.exs の設定確認

`firmware/config/target.exs`で、WiFi設定が正しく記述されているか確認します：

```elixir
config :vintage_net,
  regulatory_domain: "JP",  # 国コードを設定（例: "US", "JP", "GB"）
  config: [
    {"usb0", %{type: VintageNetDirect}},
    # WiFi設定（優先）
    {"wlan0",
     %{
       type: VintageNetWiFi,
       vintage_net_wifi: %{
         networks: [
           %{
             ssid: System.get_env("WIFI_SSID") || raise("WIFI_SSID environment variable is not set"),
             key_mgmt: :wpa_psk,
             psk: System.get_env("WIFI_PASSWORD") || raise("WIFI_PASSWORD environment variable is not set")
           }
         ]
       },
       ipv4: %{method: :dhcp}
     }},
    # 有線LANは無効化（コメントアウト）
    # {"eth0",
    #  %{
    #    type: VintageNetEthernet,
    #    ipv4: %{method: :dhcp}
    #  }}
  ]
```

**設定の説明**:
- `regulatory_domain`: 2文字の国コード（例: "JP"=日本, "US"=アメリカ, "GB"=イギリス）
- `ssid`: WiFiネットワーク名（`.env`ファイルから読み込み）
- `psk`: WiFiパスワード（`.env`ファイルから読み込み）
- `key_mgmt: :wpa_psk`: WPA/WPA2パーソナル認証を使用

### 4. firmware/config/config.exs の確認

`firmware/config/config.exs`で、`.env`ファイルの読み込み設定が含まれているか確認します：

```elixir
# Load environment variables from .env file if it exists
env_file = Path.join([__DIR__, "..", ".env"])
if File.exists?(env_file) do
  File.stream!(env_file)
  |> Stream.filter(fn line ->
    trimmed = String.trim(line)
    trimmed != "" and not String.starts_with?(trimmed, "#")
  end)
  |> Enum.each(fn line ->
    case String.split(line, "=", parts: 2) do
      [key, value] ->
        System.put_env(String.trim(key), String.trim(value))
      _ ->
        :ok
    end
  end)
end
```

## 動作確認

### ファームウェアのビルドと書き込み

```bash
cd firmware
export MIX_TARGET=rpi4
mix firmware
mix firmware.burn
```

### WiFi接続の確認

SDカードをRaspberry Pi 4に挿入して起動後、以下で接続を確認します：

```bash
# mDNS経由で接続確認
ping -c 3 nerves.local

# SSH接続確認
ssh root@nerves.local

# SSH接続後、WiFi接続状態を確認
# IExプロンプトで以下を実行
VintageNet.get(["wlan0", "connection"])
```

## トラブルシューティング

### WiFi接続できない

1. **SSIDとパスワードの確認**
   - `.env`ファイルの値が正しいか確認
   - 大文字・小文字、スペースに注意

2. **規制ドメインの確認**
   - 正しい国コードが設定されているか確認
   - 日本: "JP", アメリカ: "US"

3. **ファームウェアの再ビルド**
   - 設定を変更した場合は、必ずファームウェアを再ビルド・再書き込みしてください

### 有線LANとWiFiの優先順位

現在の設定では、WiFiが優先されます。有線LANも使用したい場合は、`target.exs`の有線LAN設定のコメントを外してください。

#### 有線LAN（eth0）の有効化

有線LANからもアクセスできるようにするには、`firmware/config/target.exs`で有線LAN設定のコメントを外します：

```elixir
config :vintage_net,
  regulatory_domain: "JP",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    # WiFi設定（優先）
    {"wlan0",
     %{
       type: VintageNetWiFi,
       vintage_net_wifi: %{
         networks: [
           %{
             ssid: System.get_env("WIFI_SSID") || raise("WIFI_SSID environment variable is not set"),
             key_mgmt: :wpa_psk,
             psk: System.get_env("WIFI_PASSWORD") || raise("WIFI_PASSWORD environment variable is not set")
           }
         ]
       },
       ipv4: %{method: :dhcp}
     }},
    # 有線LAN設定（コメントを外して有効化）
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }}
  ]
```

設定を変更したら、ファームウェアを再ビルドしてアップロードしてください：

```bash
cd firmware
export MIX_TARGET=rpi4
mix firmware
mix upload  # または mix firmware.burn
```

有線LANとWiFiの両方が有効になると、どちらからでもアクセスできます：
- WiFi経由: `http://nerves.local:4000` または WiFiのIPアドレス
- 有線LAN経由: `http://nerves.local:4000` または 有線LANのIPアドレス

有線LANのIPアドレスを確認するには、SSH接続後に以下を実行：
```bash
ssh root@nerves.local
VintageNet.get_by_name("eth0")
```

## 次のステップ

WiFi設定が完了したら、次は`step_03_gen_ui.md`を参照して、Phoenix UIプロジェクトを生成します。

## 参考

- [Vintage Net Documentation](https://github.com/nerves-networking/vintage_net)
- [Nerves Networking](https://hexdocs.pm/nerves/networking.html)
