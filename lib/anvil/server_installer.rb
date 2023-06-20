# frozen_string_literal: true

require_relative "ssh_executor"
require_relative "logger"

# The server installer uses Net::SSH to connect to the server and then run the following steps:
# - Sets the server hostname and timezone
# - Installs various necessary packages, plus dokku itself
# - Sets up the firewall
# - Creates unix users for each app, adding them to the sudo and docker groups, and setting their authorized_keys files with the given public key
# - Sets the dokku deployment branch to `main`
# - Schedule a `docker system prune` once per week to clean up any dangling images or containers
# - Configure nginx
# - Install dokku plugins and run any configuration you have defined
# - Disallows root and passwordless logins over SSH
class Anvil::ServerInstaller < Struct.new(:hostname, :configuration, :private_key, :passphrase)
  require_relative "server_installer/set_hostname"
  require_relative "server_installer/set_timezone"
  require_relative "server_installer/install_packages"
  require_relative "server_installer/create_users"
  require_relative "server_installer/configure_dokku"
  require_relative "server_installer/configure_docker"
  require_relative "server_installer/install_plugins"
  require_relative "server_installer/configure_firewall"
  require_relative "server_installer/configure_ssh_server"
  def call
    Anvil::SshExecutor.new(hostname, server_configuration["user"], logger).call do |ssh_connection|
      logger.info "SetHostname"
      Anvil::ServerInstaller::SetHostname.new(ssh_connection, hostname).call
      logger.info "SetTimezone"
      Anvil::ServerInstaller::SetTimezone.new(ssh_connection, server_configuration["timezone"]).call
      logger.info "InstallPackages"
      Anvil::ServerInstaller::InstallPackages.new(ssh_connection, server_configuration["public_key"]).call
      logger.info "ConfigureDokku"
      Anvil::ServerInstaller::ConfigureDokku.new(ssh_connection, hostname).call
      logger.info "CreateUsers"
      Anvil::ServerInstaller::CreateUsers.new(ssh_connection, app_names).call
      logger.info "InstallPlugins"
      Anvil::ServerInstaller::InstallPlugins.new(ssh_connection, server_configuration["plugins"]).call
      logger.info "ConfigureDocker"
      Anvil::ServerInstaller::ConfigureDocker.new(ssh_connection).call
      logger.info "ConfigureFirewall"
      Anvil::ServerInstaller::ConfigureFirewall.new(ssh_connection, server_configuration["ports"]).call
      logger.info "ConfigureSshServer"
      Anvil::ServerInstaller::ConfigureSshServer.new(ssh_connection).call
    end
  end

  def server_configuration
    configuration["server_config"]
  end

  def app_names
    configuration["apps"].keys
  end

  def logger
    Anvil::Logger.new(hostname)
  end
end
