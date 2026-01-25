# This file is responsible for configuring your application and its
# dependencies.
#
# This configuration file is loaded before any dependency and is restricted to
# this project.
import Config

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

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1769323757"

if Mix.target() == :host do
  import_config "host.exs"
else
  import_config "target.exs"
end
