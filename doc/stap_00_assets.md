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

# プロジェクトディレクトリでバージョンを設定
cd firmware
asdf local erlang 28.1.1
asdf local elixir 1.19.0-otp-28
```

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
