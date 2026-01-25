# Step 00: 必要なアセット（ツール）のインストール

Ponchoプロジェクト構造でNerves + Phoenixプロジェクトを構築するために必要なツールをインストールします。

## 必要なツール

### 1. Erlang/OTP と Elixir のインストール

`asdf`を使用してバージョン管理を行います。

```bash
# asdfがインストールされていない場合は、まずインストール
# macOSの場合
brew install asdf

# Erlang/OTP と Elixir のプラグインを追加
asdf plugin add erlang
asdf plugin add elixir

# 必要なバージョンをインストール
asdf install erlang 28.1.1
asdf install elixir 1.19.0-otp-28

# プロジェクトルートでバージョンを設定
cd pi4_bitflyer
asdf local erlang 28.1.1
asdf local elixir 1.19.0-otp-28
```

### 1.1. .tool-versionsファイルの設定

プロジェクトルートに`.tool-versions`ファイルを作成することで、asdfが自動的にバージョンを設定します。

プロジェクトルート（`pi4_bitflyer/`）に`.tool-versions`ファイルを作成します：

```bash
cd pi4_bitflyer
cat > .tool-versions << EOF
erlang 28.1.1
elixir 1.19.0-otp-28
EOF
```

`.tool-versions`ファイルの内容：

```
erlang 28.1.1
elixir 1.19.0-otp-28
```

**利点**:
- プロジェクトディレクトリに入ると自動的に正しいバージョンが使用されます
- チーム全体で同じバージョンを使用できます
- バージョン管理が簡単になります

**注意**: `.tool-versions`ファイルが存在する場合、`asdf local`コマンドを実行する必要はありません。ファイルが存在すれば、自動的にバージョンが設定されます。

### 2. Phoenix アーカイブのインストール

```bash
mix archive.install hex phx_new
```

### 3. Nerves ブートストラップのインストール

```bash
mix archive.install hex nerves_bootstrap
```

## バージョン確認

インストールが完了したら、バージョンを確認します：

```bash
# Erlang/OTP のバージョン確認
erl -version

# Elixir のバージョン確認
elixir --version

# Phoenix のバージョン確認
mix phx.new --version

# Nerves のバージョン確認
mix nerves.new --version
```

## 参考

- [Nerves Installation Guide](https://hexdocs.pm/nerves/installation.html)
- [Phoenix Installation Guide](https://hexdocs.pm/phoenix/installation.html)
- [asdf Version Manager](https://asdf-vm.com/)
