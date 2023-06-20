# frozen_string_literal: true

class Anvil::ServerInstaller::InstallPlugins < Struct.new(:ssh_connection, :plugins)
  def call
    plugins.each do |name, config|
      scripts = ["dokku plugin:install #{config["url"]} #{name}"]
      plugin_config = config["config"] || []
      scripts += plugin_config.collect do |cmd|
        "dokku #{name}:#{cmd}"
      end
      ssh_connection.exec! scripts.join("\n"), "InstallPlugins"
    end
  end
end
